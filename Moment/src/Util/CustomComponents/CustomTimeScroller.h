//
//  CustomTimeScroller.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>



@class CustomTimeScroller;
 
@protocol CustomTimeScrollerDelegate <NSObject>

@required

- (NSDate *)dateForCell:(UITableViewCell *)cell;

@end


@interface CustomTimeScroller : UIImageView {

    id <CustomTimeScrollerDelegate> __weak _delegate;
    UITableView *_tableView;
    UILabel *_timeLabel;
    UILabel *_dateLabel;
    UIImageView *_backgroundView;
    UIView *_handContainer;
    UIView *_hourHand;
    UIView *_minuteHand;
    NSDate *_lastDate;
}

@property (nonatomic, weak) id <CustomTimeScrollerDelegate> delegate;
@property (nonatomic, copy) NSCalendar *calendar;

- (id)initWithDelegate:(id <CustomTimeScrollerDelegate>)delegate withTableView:(UITableView*)tableView;
- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDecelerating;
- (void)scrollViewWillBeginDragging;

@end
