//
//  PhotoViewController.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 05/01/13.
//  Copyright (c) 2013 Mathieu PIERAGGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MomentClass+Model.h"

@interface PhotoViewController : UIViewController

@property (nonatomic, strong) MomentClass* moment;

- (id) initWithMoment:(MomentClass*)moment;

@end
