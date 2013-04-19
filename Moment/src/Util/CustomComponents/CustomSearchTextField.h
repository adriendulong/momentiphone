//
//  CustomSearchTextField.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSearchTextField : UITextField {
    NSInteger paddingLeft;
    NSInteger paddingTop;
}

@property(nonatomic) NSInteger paddingLeft;
@property(nonatomic) NSInteger paddingTop;

@end
