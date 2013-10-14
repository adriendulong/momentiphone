//
//  CustomSearchTextField.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomSearchTextField.h"
#import "Config.h"

@implementation CustomSearchTextField
@synthesize paddingTop, paddingLeft;

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    NSInteger mT = 0;
    NSInteger mL = 0;
    
    if( self.paddingTop == 0)
        mT = 6;
    else
        mT = self.paddingTop;
    
    if( self.paddingLeft == 0)
        mL = 8;
    else
        mL = self.paddingLeft;
    
    return CGRectMake(bounds.origin.x + mL, bounds.origin.y + mT,
                      bounds.size.width - (4*mL), bounds.size.height - (2*mT) );
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (void) drawRect:(CGRect)rect{
    
    self.font = [[Config sharedInstance] defaultFontWithSize:14];
    
    UIImage *image = [UIImage imageNamed:@"champ_recherche"];
    
    //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 5)];
    
    image = [[VersionControl sharedInstance] resizableImageFromImage:image withCapInsets:UIEdgeInsetsMake(4, 0, 2, 0)  stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    /*
     image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 5)];
     image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:7];
     */
    
    self.background = image;
    
    [super drawRect:rect];
}


@end
