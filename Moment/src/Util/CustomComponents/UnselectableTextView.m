//
//  UnselectableTextView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 19/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "UnselectableTextView.h"

@implementation UnselectableTextView

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end
