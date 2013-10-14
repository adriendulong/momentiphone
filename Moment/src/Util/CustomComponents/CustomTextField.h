//
//  CustomTextField.h
//  Moment
//
//  Created by Charlie FANCELLI on 03/10/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTAutocompleteTextField.h"

@interface CustomTextField : HTAutocompleteTextField {
    NSInteger paddingLeft;
    NSInteger paddingTop;
}

@property(nonatomic) NSInteger paddingLeft;
@property(nonatomic) NSInteger paddingTop;

@end
