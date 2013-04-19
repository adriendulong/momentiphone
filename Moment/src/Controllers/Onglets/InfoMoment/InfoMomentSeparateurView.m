//
//  InfoMomentSeparateurView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 01/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import "InfoMomentSeparateurView.h"

@implementation InfoMomentSeparateurView

-(void)setup {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"separation.png"]];
}

- (id)initAtPosition:(CGFloat)position
{
    CGRect frame = CGRectMake(0, position, 320, 2);
    self = [self initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
