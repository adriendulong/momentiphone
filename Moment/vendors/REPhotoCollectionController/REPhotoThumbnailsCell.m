//
// REPhotoThumbnailsCell.m
// REPhotoCollectionController
//
// Copyright (c) 2012 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REPhotoThumbnailsCell.h"

@implementation REPhotoThumbnailsCell

@synthesize delegate = _delegate;
@synthesize thumbnailViewClass = _thumbnailViewClass;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier thumbnailViewClass:(Class)thumbnailViewClass
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumbnailViewClass = thumbnailViewClass;
        _photos = [[NSMutableArray alloc] init];
        for (int i=0; i < 4; i++) {
            REPhotoThumbnailView *thumbnailView = [[[_thumbnailViewClass class] alloc] initWithFrame:CGRectMake(6+(72 * i + 6 * i), 6, 72, 72)];
            [thumbnailView setHidden:YES];
            thumbnailView.tag = i;
            [self addSubview:thumbnailView];
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)removeAllPhotos
{
    [_photos removeAllObjects];
}

- (void)addPhoto:(NSObject<REPhotoObjectProtocol> *)photo
{
    [_photos addObject:photo];
}

- (void)refresh
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[REPhotoThumbnailView class]]) {
            REPhotoThumbnailView *thumbnailView = (REPhotoThumbnailView *)view;
            
            
            UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            tapped.numberOfTapsRequired = 1;
            
            
            if (thumbnailView.tag < [_photos count]) {
                [thumbnailView setHidden:NO];
                if ([thumbnailView respondsToSelector:@selector(setPhoto:)]) {
                    Photo *photo = [_photos objectAtIndex:thumbnailView.tag];
                    [thumbnailView setPhoto:photo];
                    
                    if (photo.isSelected) {
                        [self selectPhoto:thumbnailView];
                        [self.delegate tableViewCell:self addPhotoToUpload:photo];
                    } else {
                        [self deselectPhoto:thumbnailView];
                        [self.delegate tableViewCell:self removePhotoToUpload:photo];
                    }
                    
                    [thumbnailView addGestureRecognizer:tapped];
                }
            } else {
                [thumbnailView setHidden:YES];
            }
        }
    }
}

#pragma mark - Select Photo

/*-(void)setPhotoCheck:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    
    UIImageView *imageForSelect = [self isPhotoSelect:gesture.view];
    
    if (imageForSelect != nil) {
        if ([imageForSelect.image isEqual:[UIImage imageNamed:@"picto_check.png"]]) {
            [imageForSelect removeFromSuperview];
            
            [self deselectPhoto:gesture];
        } else if ([imageForSelect.image isEqual:[UIImage imageNamed:@"picto_uncheck.png"]]) {
            [imageForSelect removeFromSuperview];
            
            [self selectPhoto:gesture];
        }
    }
}*/

/*- (void)selectPhoto:(UITapGestureRecognizer *)gesture
{
    UIImageView *checkPhoto = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picto_check.png"]];
    checkPhoto.frame = CGRectMake(gesture.view.frame.size.width-68, gesture.view.frame.size.height-24, 20, 20);
    
    [gesture.view addSubview:checkPhoto];
}

- (void)deselectPhoto:(UITapGestureRecognizer *)gesture
{
    UIImageView *checkPhoto = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picto_uncheck.png"]];
    checkPhoto.frame = CGRectMake(gesture.view.frame.size.width-68, gesture.view.frame.size.height-24, 20, 20);
    
    [gesture.view addSubview:checkPhoto];
}*/

- (void)selectPhoto:(REPhotoThumbnailView *)thumbnailView
{
    UIImageView *checkPhoto = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picto_check.png"]];
    checkPhoto.frame = CGRectMake(thumbnailView.frame.size.width-68, thumbnailView.frame.size.height-24, 20, 20);
    
    [thumbnailView addSubview:checkPhoto];
}

- (void)deselectPhoto:(REPhotoThumbnailView *)thumbnailView
{
    UIImageView *checkPhoto = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picto_uncheck.png"]];
    checkPhoto.frame = CGRectMake(thumbnailView.frame.size.width-68, thumbnailView.frame.size.height-24, 20, 20);
    
    [thumbnailView addSubview:checkPhoto];
}

/*- (UIImageView *)isPhotoSelect:(UIView *)tapView
{    
    UIImageView *checkImageView = nil;
    
    for (UIView *view in tapView.subviews) {
        
        if ([view isKindOfClass:[UIImageView class]]) {
            checkImageView = (UIImageView *)view;
            
            if ([checkImageView.image isEqual:[UIImage imageNamed:@"picto_check.png"]]) {
                //NSLog(@"La photo est cochée.");
                return checkImageView;
            } else if ([checkImageView.image isEqual:[UIImage imageNamed:@"picto_uncheck.png"]]) {
                //NSLog(@"La photo est décochée.");
                return checkImageView;
            }
        }
    }
    
    //NSLog(@"La photo est décochée.");
    return nil;
}

- (NSArray *)getSelectedPhotosToUpload
{
    NSMutableArray *photosArray = [NSMutableArray array];
    
    return [photosArray copy];
}

- (void)setPhotoStatusWithThumbnailView:(REPhotoThumbnailView *)thumbnailView
{
    for (UIView *view in thumbnailView.subviews) {
        if ([view isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)view;
            
            //NSLog(@"gesture.view.superview %@", gesture.view.superview);
            
            UIImageView *imageForSelect = [self isPhotoSelect:gesture.view];
            
            if (imageForSelect != nil) {
                Photo *photo = [_photos objectAtIndex:thumbnailView.tag];
                
                if ([imageForSelect.image isEqual:[UIImage imageNamed:@"picto_check.png"]]) {
                    photo.isSelected = YES;
                } else if ([imageForSelect.image isEqual:[UIImage imageNamed:@"picto_uncheck.png"]]) {
                    photo.isSelected = NO;
                }
            }
        }
    }
}*/

-(void)handleTap:(UITapGestureRecognizer *)tapRec
{
    if ([tapRec.view isKindOfClass:[REPhotoThumbnailView class]]) {
        REPhotoThumbnailView *thumbnailView = (REPhotoThumbnailView *)tapRec.view;
        
        if (thumbnailView.tag < _photos.count) {
            Photo *photo = [_photos objectAtIndex:thumbnailView.tag];
            
            if (photo.isSelected) {
                [self deselectPhoto:thumbnailView];
                [photo setIsSelected:NO];
                
                //NSLog(@"Photo désélectionnée !");
                //NSLog(@"Photo isSelected = %@", photo.isSelected ? @"YES" : @"NO");
                
                [self.delegate tableViewCell:self removePhotoToUpload:photo];
            } else {
                [self selectPhoto:thumbnailView];
                [photo setIsSelected:YES];
                
                //NSLog(@"Photo sélectionnée !");
                //NSLog(@"Photo isSelected = %@", photo.isSelected ? @"YES" : @"NO");
                
                [self.delegate tableViewCell:self addPhotoToUpload:photo];
            }
        }
    }
}

@end
