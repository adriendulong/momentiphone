//
//  CustomSegmentedControl.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomSegmentedControl.h"
#import "Config.h"

#import "TTTAttributedLabel.h"
#import "NSMutableAttributedString+FontAndTextColor.h"

@implementation CustomSegmentedControl {
    @private
    NSInteger bigSize, smallSize;
}

@synthesize labelsArray = _labelsArray;
@synthesize ttLabelsArray = _ttLabelsArray;

#pragma mark - Init

- (void)customSetup
{
    bigSize = 15;
    smallSize = 13;
    
    [self setSectionTitles:@[NSLocalizedString(@"CustomSegmentedControl_Maybe", nil),
                            NSLocalizedString(@"CustomSegmentedControl_Coming", nil),
                            NSLocalizedString(@"CustomSegmentedControl_Unknown", nil)
                            ]];
    
    [self setSelectedSegmentIndex:1];
    [self setBackgroundColor:[UIColor clearColor]];
    //[self setTextColor:[UIColor clearColor]];
    // --
    [self setTextColor:[Config sharedInstance].textColor];
    [self setFont:[[Config sharedInstance] defaultFontWithSize:smallSize]];
    // --
    [self setSelectionIndicatorColor:[Config sharedInstance].orangeColor];
    [self setSelectionIndicatorHeight:2.5];
    
    //[self initLabels];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self customSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [self customSetup];
}

- (CGRect)frameForSelectionIndicator {
    CGFloat stringWidth = [[self.sectionTitles objectAtIndex:self.selectedSegmentIndex] sizeWithFont:self.font].width;
    
    if (self.selectionIndicatorStyle == HMSelectionIndicatorResizesToStringWidth && stringWidth <= self.segmentWidth) {
        CGFloat widthToEndOfSelectedSegment = (self.segmentWidth * self.selectedSegmentIndex) + self.segmentWidth;
        CGFloat widthToStartOfSelectedIndex = (self.segmentWidth * self.selectedSegmentIndex);
        
        CGFloat x = ((widthToEndOfSelectedSegment - widthToStartOfSelectedIndex) / 2) + (widthToStartOfSelectedIndex - stringWidth / 2);
        return CGRectMake(x, self.frame.size.height - self.selectionIndicatorHeight, stringWidth, self.selectionIndicatorHeight);
    } else {
        return CGRectMake(self.segmentWidth * self.selectedSegmentIndex, 0.0, self.segmentWidth, self.selectionIndicatorHeight);
    }
}

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated
{
    [super setSelectedSegmentIndex:index animated:animated];
    
    // Change text color
    // ...
}

/*

#pragma mark - Labels

- (void)updateLabelAtIndex:(NSInteger)index selected:(BOOL)selected
{
    UIColor *color = selected? [Config sharedInstance].orangeColor : [Config sharedInstance].textColor;
    NSString *text = self.sectionTitles[index];
    NSInteger taille = [text length];
    
    UILabel *label = self.labelsArray[index];
    TTTAttributedLabel *ttLabel = self.ttLabelsArray[index];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:bigSize] range:range];
        range = NSMakeRange(1, taille-1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:smallSize] range:range];
        [attributedString setTextColor:color];
        
        [label setAttributedText:attributedString];
        label.textAlignment = kCTCenterTextAlignment;
        //[label sizeToFit];
        ttLabel.hidden = YES;
    }
    else
    {
        [ttLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange(1, taille-1)];
            [cf updateTTTAttributedString:mutableAttributedString withColor:color onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        //[ttLabel sizeToFit];
        //[label.superview addSubview:ttLabel];
        label.hidden = YES;
    }
    
}

- (void)initLabels
{
    int taille = [self.sectionTitles count];
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:bigSize];
    CGFloat stringHeight = [self.sectionTitles[0] sizeWithFont:font].height;
    CGFloat y = ((self.height - self.selectionIndicatorHeight) / 2) + (self.selectionIndicatorHeight - stringHeight / 2);
    CGRect rect;
    UILabel *label = nil;
    TTTAttributedLabel *ttLabel = nil;
    
    for (int i=0; i<taille; i++) {
        
        rect = CGRectMake(self.segmentWidth * i, y, self.segmentWidth, stringHeight);
        
        label = [[UILabel alloc] initWithFrame:rect];
        ttLabel = [[TTTAttributedLabel alloc] initWithFrame:rect];
        
        [self.labelsArray addObject:label];
        [self.ttLabelsArray addObject:ttLabel];
        
        [self updateLabelAtIndex:i selected:(i == self.selectedSegmentIndex)];
        
        [self addSubview:label];
        [self addSubview:ttLabel];
    }
}
*/

@end
