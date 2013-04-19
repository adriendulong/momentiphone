//
//  UILabel+BottomAlign.m
//
//  https://gist.github.com/3904688
//

#import "UILabel+BottomAlign.h"

@implementation UILabel (BottomAlign)

- (CGFloat)topAfterBottomAligningWithLabel:(UILabel *)label{
    return (label.frame.origin.y - ((label.frame.origin.y + self.frame.size.height) - (label.frame.origin.y + label.frame.size.height)) + (label.font.descender - self.font.descender));
}

@end
