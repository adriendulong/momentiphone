//
//  NLImageShowCase.m
//  ImageShowcase
//
// Copyright © 2012, Mirza Bilal (bilal@mirzabilal.com)
// All rights reserved.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 1.	Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimer.
// 2.	Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation
//       and/or other materials provided with the distribution.
// 3.	Neither the name of Mirza Bilal nor the names of its contributors may be used
//       to endorse or promote products derived from this software without specific
//       prior written permission.
// THIS SOFTWARE IS PROVIDED BY MIRZA BILAL "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MIRZA BILAL BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
// ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NLImageShowCase.h"
#import <QuartzCore/QuartzCore.h>

@implementation NLImageShowCase {
    @private
    NSInteger lastIndexFull;
}

#ifdef ACTIVE_PRINT_MODE
@synthesize printMode = _printMode;
#endif
@synthesize deleteMode = _deleteMode;
@synthesize scrollView = _scrollView;
@synthesize itemsInShowCase = itemsInShowCase;
@synthesize photoViewControllerStyle = _photoViewControllerStyle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    itemsInShowCase = [[NSMutableArray alloc] init];
    lastIndex = -1;
    lastIndexFull = -1;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[self frame]];
    [self addSubview:_scrollView];
        
    _scrollView.contentMode = (UIViewContentModeScaleAspectFit);
    _scrollView.contentSize =  CGSizeMake(self.bounds.size.width,self.bounds.size.height);
    _scrollView.pagingEnabled = NO;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.autoresizingMask = ( UIViewAutoresizingFlexibleHeight);
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1;
    _scrollView.clipsToBounds = NO;
    
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        // Ignore touch: As we do not want to handle gesture here, so pass it to NLImageShowCaseCell
        return NO;
    }
    return YES;
}

- (id)setDataSource:(id<NLImageViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _cellSize  = [_dataSource imageViewSizeInShowcase:self];
    _leftOffset = [_dataSource imageLeftOffsetInShowcase:self];
    _topOffset = [_dataSource imageTopOffsetInShowcase:self];
    _rowSpacing = [_dataSource rowSpacingInShowcase:self];
    _columnSpacing = [_dataSource columnSpacingInShowcase:self];
    _itemsInRowCount = (self.frame.size.width - _leftOffset + _columnSpacing) / (_cellSize.width + _columnSpacing);
    
    return self;
}

- (void)rearrageItems:(CGFloat)frameWidth fromIndex:(NSInteger)index
{
    [UIView animateWithDuration:0.4 animations:
     ^{
         NLImageShowCaseCell* curCell = nil;
         NSInteger itemsCount = [itemsInShowCase count];
         int itr = index;
         for (; itr < itemsCount; itr++)
         {
             curCell = itemsInShowCase[itr];
             CGFloat newXPos = _leftOffset + (itr % _itemsInRowCount) * (_cellSize.width + _columnSpacing);
             CGFloat newYPos = _topOffset +  (itr / _itemsInRowCount) * (_cellSize.height + _rowSpacing);
             curCell.frame = CGRectMake(newXPos,newYPos,_cellSize.width,_cellSize.height);
         }
         if(itemsCount > 0)
         {
             curCell = itemsInShowCase[itemsCount-1 ];
             CGFloat scrollHeight = curCell.frame.origin.y + (_cellSize.height + _rowSpacing);
             _scrollView.contentSize =  CGSizeMake(frameWidth,scrollHeight);
         }
     }];
}

- (void) setFrame:(CGRect)frame
{
    // Call the parent class to move the view
    [super setFrame:frame];
    if(_dataSource == nil)
        _scrollView.contentSize =  CGSizeMake(frame.size.width,frame.size.height);
    else
    {
        _itemsInRowCount = (frame.size.width - _leftOffset + _columnSpacing) / (_cellSize.width + _columnSpacing);
        CGFloat frameWidth = frame.size.width;
        [self rearrageItems:frameWidth fromIndex:0];
    }
}

#pragma mark - Add Image

- (void)positonsForIndex:(NSInteger)index xPos:(CGFloat*)xPos yPos:(CGFloat*)yPos
{
    NSUInteger rowCount = index/_itemsInRowCount;
    if(xPos)
        *xPos = _leftOffset + (index % _itemsInRowCount) * (_cellSize.width + _columnSpacing);
    if(yPos)
        *yPos = _topOffset + rowCount * (_cellSize.height + _rowSpacing);
}

- (NLImageShowCaseCell*)emptyCellAtIndex:(NSInteger)index
{
    CGFloat xPos, yPos;
    [self positonsForIndex:index xPos:&xPos yPos:&yPos];
    
    NLImageShowCaseCell *showCaseCell = [[NLImageShowCaseCell alloc] initWithFrame:CGRectMake(xPos, yPos, _cellSize.width, _cellSize.height)];
        
    [showCaseCell setMainImage:[UIImage imageNamed:@"cover_defaut"] isPlusButton:NO isPrintButton:NO];
    
    showCaseCell.index = ++lastIndex;
    showCaseCell.deleteMode = _deleteMode;
    
    return showCaseCell;
}

// Retourne tableau d'origine avec des cellules par défaut |||||||| à la fin |||||||| ou au début
- (NSMutableArray*)itemsInShowCaseWithSize:(NSInteger)size atStart:(BOOL)atStart
{
    NSInteger count = [self.itemsInShowCase count];
    if(size > count)
    {
        NSMutableArray *array = itemsInShowCase.mutableCopy;
        
        // Ajout en tête
        if(atStart)
        {
            NSInteger start, end, difference = (size - count);
            if(self.photoViewControllerStyle == PhotoViewControllerStyleComplete) {
                start = 1;
            }
            else {
                start = 0;
            }
            end = difference + start;
            
            // Décaller les cellules
            for (int i=start; i<count; i++) {
                NLImageShowCaseCell *cell = array[i];
                CGFloat xPos, yPos;
                NSInteger newIndex = (i+difference);
                [self positonsForIndex:newIndex xPos:&xPos yPos:&yPos];
                cell.frame = CGRectMake(xPos, yPos, cell.frame.size.width, cell.frame.size.height);
                cell.index = newIndex;
            }
            
            // Ajouter les cellules vides
            for (int i=start; i<end; i++) {
                NLImageShowCaseCell *cell = [self emptyCellAtIndex:i];
                [array insertObject:cell atIndex:i];
                [_scrollView addSubview:cell];
            }
        }
        // Ajout en queue
        else
        {
            for(int i=count; i<size; i++) {
                NLImageShowCaseCell *cell = [self emptyCellAtIndex:i];
                [array addObject:cell];
                [_scrollView addSubview:cell];
            }
        }
        
        return array;
    }
    return self.itemsInShowCase;
}

// Retourne tableau d'origine avec des cellules par défaut |||||||| à la fin
- (NSMutableArray*)itemsInShowCaseWithSize:(NSInteger)size
{
    return [self itemsInShowCaseWithSize:size atStart:NO];
}

- (void)updateItemsShowCaseWithSize:(NSInteger)size atStart:(BOOL)atStart
{
    int taille = [self.itemsInShowCase count];
    // Si il y a des cellules à ajouter
    if(size > taille) {
        
        BOOL printButton = NO;
        
#ifdef ACTIVE_PRINT_MODE
        // Si on passe par le Bouton Print, on l'ajoute
        if( (self.photoViewControllerStyle == PhotoViewControllerStyleComplete) && (size >= PHOTOVIEW_PRINT_BUTTON_INDEX) && (taille < PHOTOVIEW_PRINT_BUTTON_INDEX) ) {
            printButton = YES;
        }
#endif
        
        // Array avec cellules preload
        NSArray *newArray = [self itemsInShowCaseWithSize:size atStart:atStart];
        
        // Augmenter taille du tableau
        // Au début
        if(atStart)
        {
            NSInteger count = [self.itemsInShowCase count];
            NSInteger start, end, difference = (size - count);
            if(self.photoViewControllerStyle == PhotoViewControllerStyleComplete) {
                start = 1;
            }
            else {
                start = 0;
            }
            end = difference + start;
            
            for (int i=start; i<end; i++) {
                [self.itemsInShowCase insertObject:[NSNull null] atIndex:start];
            }
        }
        // A la fin
        else
        {
            for(int i=taille; i<size; i++) {
                [self.itemsInShowCase addObject:[NSNull null]];
            }
        }
        
        // Remplacer avec cellules par défaut
        [self.itemsInShowCase replaceObjectsInRange:NSMakeRange(0, size)
                               withObjectsFromArray:newArray];
        
        // Ajouter le bouton print si nécessaire
        if(printButton) {
            [self addImage:nil atIndex:PHOTOVIEW_PRINT_BUTTON_INDEX isPlusButton:NO isPrintButton:YES];
        }
        
        // Update scroll view size
        CGFloat yPos = 0;
        [self positonsForIndex:[itemsInShowCase count]-1 xPos:NULL yPos:&yPos];
        
        CGFloat contentHeight = yPos+_cellSize.height + _rowSpacing;
        if(contentHeight > _scrollView.contentSize.height) {
            _scrollView.contentSize =  CGSizeMake(self.bounds.size.width,contentHeight);
        }
    }
}

// Update la liste des photos avec des cellules par défaut et/ou le bouton print (et augmente la taille de la scrollview)
- (void)updateItemsShowCaseWithSize:(NSInteger)size
{
    [self updateItemsShowCaseWithSize:size atStart:NO];
}

// Index réelle (dans le tableau des photos NSArray <Photos*>
- (NSInteger)convertIndexForDataForCurrentStyle:(NSInteger)index
{
#ifdef ACTIVE_PRINT_MODE
    switch (self.photoViewControllerStyle) {
        case PhotoViewControllerStyleComplete:
            if(index>PHOTOVIEW_PRINT_BUTTON_INDEX)
                return index-1;
            return index;
            break;
            
        case PhotoViewControllerStyleProfil:
            return index;
            break;
    }
#endif
    return index;
}

// Ajoute un image à l'index "index"
- (BOOL)addImage:(UIImage*)image atIndex:(NSInteger)index isPlusButton:(BOOL)plusButton isPrintButton:(BOOL)printButton
{
    
#ifndef ACTIVE_PRINT_MODE
    printButton = NO;
#endif
    
    // Position de l'image
    CGFloat xPos, yPos;
    [self positonsForIndex:index xPos:&xPos yPos:&yPos];
        
    // Cellule
    NLImageShowCaseCell* showCaseCell = [[NLImageShowCaseCell alloc] initWithFrame:CGRectMake(xPos, yPos, _cellSize.width, _cellSize.height)];
    showCaseCell.cellDelegate = self;
    showCaseCell.index = [self convertIndexForDataForCurrentStyle:index];
    [showCaseCell setMainImage:image isPlusButton:plusButton isPrintButton:printButton];
    lastIndexFull = MAX(index, lastIndexFull);
    showCaseCell.deleteMode = _deleteMode;
        
    // Remove Default cell
    if( ([itemsInShowCase count] > 0) && (index < [itemsInShowCase count]) ) {
        [itemsInShowCase[index] removeFromSuperview];
    }
    else {
        [self updateItemsShowCaseWithSize:index+1];
    }
    
    // Add
    [itemsInShowCase replaceObjectAtIndex:index withObject:showCaseCell];
    [_scrollView addSubview:showCaseCell];
    
    return true;
}

- (bool)addImage: (UIImage*)image isPlusButton:(BOOL)plusButton isPrintButton:(BOOL)printButton
{
    NSUInteger itemCount = [itemsInShowCase count];
    return [self addImage:image atIndex:itemCount isPlusButton:plusButton isPrintButton:printButton];
}

#pragma mark - 

-(void) setDeleteMode:(BOOL)deleteMode
{
    _deleteMode = deleteMode;
    NSEnumerator *enumerator = [itemsInShowCase objectEnumerator];
    for (NLImageShowCaseCell *curItem in enumerator) {
        [curItem setDeleteMode:deleteMode];
    }
}

- (void) viewClicked
{
    if (_deleteMode) {
        [self setDeleteMode:false];
    }
}
- (void) deleteImage:(NLImageShowCaseCell *)imageShowCaseCell imageIndex:(NSInteger)index
{
    //NSLog(@"Deleting item with key: %d",index);
    NSInteger indexOfCell = [itemsInShowCase indexOfObject:imageShowCaseCell];
    [imageShowCaseCell removeFromSuperview];
    [itemsInShowCase removeObject:imageShowCaseCell ];
    [self rearrageItems:self.bounds.size.width fromIndex:indexOfCell];
}

- (void)imageClicked:(NLImageShowCaseCell *)imageShowCaseCell imageIndex:(NSInteger)index
{
    [_dataSource imageClicked:self imageShowCaseCell:imageShowCaseCell];
}

- (void)imageTouchLonger:(NLImageShowCaseCell *)imageShowCaseCell imageIndex:(NSInteger)index
{
    [_dataSource imageTouchLonger:self imageIndex:index];
    
}

@end
