//
//  CustomSearchVolletTextField.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 21/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomSearchVolletTextField.h"
#import "Config.h"

@implementation CustomSearchVolletTextField

@synthesize paddingTop, paddingLeft;

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    NSInteger mT = 0;
    NSInteger mL = 0;
    
    if( self.paddingTop == 0)
        mT = 6;
    else
        mT = self.paddingTop;
    
    if( self.paddingLeft == 0)
        mL = 25;
    else
        mL = self.paddingLeft;
    
    return CGRectMake(bounds.origin.x + mL, bounds.origin.y + mT,
                      bounds.size.width - 55, bounds.size.height - (2*mT) );
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (void) drawRect:(CGRect)rect{
    
    self.font = [[Config sharedInstance] defaultFontWithSize:14];
    
    /*UIImage *image = [UIImage imageNamed:@"searchbar_moment.png"];
    
    //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 5)];
    
    image = [[VersionControl sharedInstance] resizableImageFromImage:image withCapInsets:UIEdgeInsetsMake(40, 0, 2, 0)  stretchableImageWithLeftCapWidth:40 topCapHeight:2];
    
    image = [image stretchableImageWithLeftCapWidth:40 topCapHeight:2];
    
    /\*
     image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 5)];
     image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:7];
     *\/
    
    self.background = image;*/
    
    [super drawRect:rect];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    [[UIColor colorWithHex:0x646464] setFill];
    [[self placeholder] drawInRect:rect withFont:[[Config sharedInstance] defaultFontWithSize:14]];
}

@end
