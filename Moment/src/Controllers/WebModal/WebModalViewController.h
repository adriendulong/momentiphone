//
//  WebModalViewController.h
//  Moment
//
//  Created by SkeletonGamer on 08/07/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebModalViewController : UIViewController

@property(strong, nonatomic) NSURL *url;

- (id)initWithURL:(NSURL *)url;

@end
