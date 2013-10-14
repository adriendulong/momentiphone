//
//  CustomNumberBadgeView.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 11/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "MKNumberBadgeView.h"
#import "DDMenuController.h"

@interface CustomNumberBadgeView : MKNumberBadgeView

@property (nonatomic, weak) DDMenuController *delegate;

- (id)initWithDDMenuDelegate:(DDMenuController*)delegate;

@end
