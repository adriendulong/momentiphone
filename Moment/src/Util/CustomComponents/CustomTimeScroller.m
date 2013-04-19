//
//  CustomTimeScroller.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomTimeScroller.h"

@interface CustomTimeScroller()

@property (nonatomic, copy) NSDateFormatter *timeDateFormatter;
@property (nonatomic, copy) NSDateFormatter *dayOfWeekDateFormatter;
@property (nonatomic, copy) NSDateFormatter *monthDayDateFormatter;
@property (nonatomic, copy) NSDateFormatter *monthDayYearDateFormatter;

@end

@implementation CustomTimeScroller

@synthesize timeDateFormatter = _timeDateFormatter;
@synthesize dayOfWeekDateFormatter = _dayOfWeekDateFormatter;
@synthesize  monthDayDateFormatter = _monthDayDateFormatter;
@synthesize monthDayYearDateFormatter = _monthDayYearDateFormatter;
@synthesize calendar = _calendar;
@synthesize delegate = _delegate;

- (id)initWithDelegate:(id<CustomTimeScrollerDelegate>)delegate withTableView:(UITableView*)tableView
{
    UIImage *background = [[UIImage imageNamed:@"timebox"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 35.0f, 0.0f, 12.0f)];
    
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, background.size.height)];
    if (self)
    {
        _tableView = tableView;
        
        self.calendar = [NSCalendar currentCalendar];
        [self.calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        
        self.frame = CGRectMake(0.0f, 0.0f, 320, CGRectGetHeight(self.frame));
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeTranslation(10.0f, 0.0f);
        
        _backgroundView = [[UIImageView alloc] initWithImage:background];
        _backgroundView.frame = CGRectMake(CGRectGetWidth(self.frame) - 80.0f, 0.0f, 80.0f, CGRectGetHeight(self.frame));
        [self addSubview:_backgroundView];
        
        _handContainer = [[UIView alloc] initWithFrame:CGRectMake(4.0f, 4.0f, 23.0f, 23.0f)];
        [_backgroundView addSubview:_handContainer];
        
        _hourHand = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 4.0f, 20.0f)];
        UIImageView *hourImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fleche_heure"]];
        [_hourHand addSubview:hourImageView];
        [_handContainer addSubview:_hourHand];
        
        _minuteHand = [[UIView alloc]  initWithFrame:CGRectMake(8.0f, 0.0f, 4.0f, 20.0f)];
        UIImageView *minuteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fleche_minute"]];
        [_minuteHand addSubview:minuteImageView];
        [_handContainer addSubview:_minuteHand];
        
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 4.0f, 50.0f, 20.0f)];
        _timeLabel.textColor = [UIColor colorWithHex:0x2a2a2a];
        //_timeLabel.shadowColor = [UIColor blackColor];
        //_timeLabel.shadowOffset = CGSizeMake(-0.5f, -0.5f);
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
        _timeLabel.autoresizingMask = UIViewAutoresizingNone;
        [_backgroundView addSubview:_timeLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 9.0f, 100.0f, 20.0f)];
        _dateLabel.textColor = [UIColor colorWithHex:0x8c949d];
        //_dateLabel.shadowColor = [UIColor blackColor];
        //_dateLabel.shadowOffset = CGSizeMake(-0.5f, -0.5f);
        _dateLabel.text = @"18:00";
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
        _dateLabel.alpha = 0.0f;
        [_backgroundView addSubview:_dateLabel];
        
        _delegate = delegate;
    }
    return self;
}


- (void)createFormatters
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setCalendar:self.calendar];
    [dateFormatter setTimeZone:self.calendar.timeZone];
    [dateFormatter setDateFormat:@"H:mm"];
    self.timeDateFormatter = dateFormatter;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setCalendar:self.calendar];
    [dateFormatter setTimeZone:self.calendar.timeZone];
    dateFormatter.dateFormat = @"cccc";
    self.dayOfWeekDateFormatter = dateFormatter;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setCalendar:self.calendar];
    [dateFormatter setTimeZone:self.calendar.timeZone];
    dateFormatter.dateFormat = @"d MMMM";
    self.monthDayDateFormatter = dateFormatter;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setCalendar:self.calendar];
    [dateFormatter setTimeZone:self.calendar.timeZone];
    dateFormatter.dateFormat = @"d MMMM yyyy";
    self.monthDayYearDateFormatter = dateFormatter;
}

- (void)setCalendar:(NSCalendar *)cal
{
    _calendar = cal;
    
    [self createFormatters];
}

- (void)captureTableView
{
    CGRect frame = self.frame;
    frame.origin.x = _tableView.frame.size.width - frame.size.width;
    frame.origin.y = (_tableView.frame.size.height - frame.size.height)/2.0f;
    self.frame = frame;
    
    [_tableView.superview addSubview:self];
}


- (void)updateDisplayWithCell:(UITableViewCell *)cell
{
    NSDate *date = [self.delegate dateForCell:cell];
    
    if (!date || [date isEqualToDate:_lastDate])
    {
        return;
    }
    if (!_lastDate) {
        _lastDate=[NSDate date];
    }
    NSDate *today = [NSDate date];
    
    NSDateComponents *dateComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
    NSDateComponents *todayComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
    NSDateComponents *lastDateComponents = [self.calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:_lastDate];
    
    _timeLabel.text = [self.timeDateFormatter stringFromDate:date];
    
    CGFloat currentHourAngle = 0.5f * ((lastDateComponents.hour * 60.0f) + lastDateComponents.minute);
    CGFloat newHourAngle = 0.5f * ((dateComponents.hour * 60.0f) + dateComponents.minute);
    CGFloat currentMinuteAngle = 6.0f * lastDateComponents.minute;
    CGFloat newMinuteAngle = 6.0f * dateComponents.minute;
    
    currentHourAngle = currentHourAngle > 360 ? currentHourAngle - 360 : currentHourAngle;
    newHourAngle = newHourAngle > 360 ? newHourAngle - 360 : newHourAngle;
    currentMinuteAngle = currentMinuteAngle > 360 ? currentMinuteAngle - 360 : currentMinuteAngle;
    newMinuteAngle = newMinuteAngle > 360 ? newMinuteAngle - 360 : newMinuteAngle;
    
    CGFloat hourPartOne;
    CGFloat hourPartTwo;
    CGFloat hourPartThree;
    CGFloat hourPartFour;
    
    CGFloat minutePartOne;
    CGFloat minutePartTwo;
    CGFloat minutePartThree;
    CGFloat minutePartFour;
    
    if (newHourAngle > currentHourAngle && [date timeIntervalSinceDate:_lastDate] > 0)
    {
        CGFloat diff = newHourAngle - currentHourAngle;
        CGFloat part = diff / 4.0f;
        hourPartOne = currentHourAngle + part;
        hourPartTwo = hourPartOne + part;
        hourPartThree = hourPartTwo + part;
        hourPartFour = hourPartThree + part;
    }
    else if (newHourAngle < currentHourAngle && [date timeIntervalSinceDate:_lastDate] > 0)
    {
        CGFloat diff = (360 - currentHourAngle) + newHourAngle;
        CGFloat part = diff / 4.0f;
        hourPartOne = currentHourAngle + part;
        hourPartTwo = hourPartOne + part;
        hourPartThree = hourPartTwo + part;
        hourPartFour = hourPartThree + part;
    }
    else if (newHourAngle > currentHourAngle && [date timeIntervalSinceDate:_lastDate] < 0)
    {
        CGFloat diff = ((currentHourAngle) * -1.0f) - (360 - newHourAngle);
        CGFloat part = diff / 4.0f;
        hourPartOne = currentHourAngle + part;
        hourPartTwo = hourPartOne + part;
        hourPartThree = hourPartTwo + part;
        hourPartFour = hourPartThree + part;
    }
    else if (newHourAngle < currentHourAngle && [date timeIntervalSinceDate:_lastDate] < 0)
    {
        CGFloat diff = currentHourAngle - newHourAngle;
        CGFloat part = diff / 4;
        hourPartOne = currentHourAngle - part;
        hourPartTwo = hourPartOne - part;
        hourPartThree = hourPartTwo - part;
        hourPartFour = hourPartThree - part;
    }
    else
    {
        hourPartOne = hourPartTwo = hourPartThree = hourPartFour = currentHourAngle;
    }
    
    if (newMinuteAngle > currentMinuteAngle && [date timeIntervalSinceDate:_lastDate] > 0)
    {
        CGFloat diff = newMinuteAngle - currentMinuteAngle;
        CGFloat part = diff / 4.0f;
        minutePartOne = currentMinuteAngle + part;
        minutePartTwo = minutePartOne + part;
        minutePartThree = minutePartTwo + part;
        minutePartFour = minutePartThree + part;
    }
    else if (newMinuteAngle < currentMinuteAngle && [date timeIntervalSinceDate:_lastDate] > 0)
    {
        CGFloat diff = (360 - currentMinuteAngle) + newMinuteAngle;
        CGFloat part = diff / 4.0f;
        minutePartOne = currentMinuteAngle + part;
        minutePartTwo = minutePartOne + part;
        minutePartThree = minutePartTwo + part;
        minutePartFour = minutePartThree + part;
    }
    else if (newMinuteAngle > currentMinuteAngle && [date timeIntervalSinceDate:_lastDate] < 0)
    {
        CGFloat diff = ((currentMinuteAngle) * -1.0f) - (360 - newMinuteAngle);
        CGFloat part = diff / 4.0f;
        minutePartOne = currentMinuteAngle + part;
        minutePartTwo = minutePartOne + part;
        minutePartThree = minutePartTwo + part;
        minutePartFour = minutePartThree + part;
    }
    else if (newMinuteAngle < currentMinuteAngle && [date timeIntervalSinceDate:_lastDate] < 0)
    {
        CGFloat diff = currentMinuteAngle - newMinuteAngle;
        CGFloat part = diff / 4;
        minutePartOne = currentMinuteAngle - part;
        minutePartTwo = minutePartOne - part;
        minutePartThree = minutePartTwo - part;
        minutePartFour = minutePartThree - part;
    }
    else
    {
        minutePartOne = minutePartTwo = minutePartThree = minutePartFour = currentMinuteAngle;
    }
    
    [UIView animateWithDuration:0.075f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
        
        _hourHand.transform =  CGAffineTransformMakeRotation(hourPartOne * (M_PI / 180.0f));
        _minuteHand.transform =  CGAffineTransformMakeRotation(minutePartOne * (M_PI / 180.0f));
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.075f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
            
            _hourHand.transform =  CGAffineTransformMakeRotation(hourPartTwo * (M_PI / 180.0f));
            _minuteHand.transform =  CGAffineTransformMakeRotation(minutePartTwo * (M_PI / 180.0f));
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.075f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
                
                _hourHand.transform =  CGAffineTransformMakeRotation(hourPartThree * (M_PI / 180.0f));
                _minuteHand.transform =  CGAffineTransformMakeRotation(minutePartThree * (M_PI / 180.0f));
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.075f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
                    
                    _hourHand.transform =  CGAffineTransformMakeRotation(hourPartFour * (M_PI / 180.0f));
                    _minuteHand.transform =  CGAffineTransformMakeRotation(minutePartFour * (M_PI / 180.0f));
                    
                } completion:nil];
                
            }];
            
        }];
        
    }];
    
    _lastDate = date;
    
    CGRect backgroundFrame;
    CGRect timeLabelFrame;
    CGRect dateLabelFrame = _dateLabel.frame;
    NSString *dateLabelString;
    NSString *timeLabelString = _timeLabel.text;
    CGFloat dateLabelAlpha;
        
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day)
    {
        dateLabelString = @"";
        
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - 80.0f, 0.0f, 80.0f, CGRectGetHeight(self.frame));
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 20.0f);
        dateLabelAlpha = 0.0f;
    }
    else if ((dateComponents.year == todayComponents.year) && (dateComponents.month == todayComponents.month) && (dateComponents.day == todayComponents.day - 1))
    {
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 10.0f);
        
        dateLabelString = @"Hier";
        dateLabelAlpha = 1.0f;
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - 85.0f, 0.0f, 85.0f, CGRectGetHeight(self.frame));
    }
    else if ((dateComponents.year == todayComponents.year) && (dateComponents.weekOfYear == todayComponents.weekOfYear))
    {
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 10.0f);
        dateLabelString = [self.dayOfWeekDateFormatter stringFromDate:date];
        dateLabelAlpha = 1.0f;
        
        CGFloat width = 0.0f;
        if ([dateLabelString sizeWithFont:_dateLabel.font].width < 50)
        {
            width = 85.0f;
        }
        else
        {
            width = 95.0f;
        }
        
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - width, 0.0f, width, CGRectGetHeight(self.frame));
    }
    else if (dateComponents.year == todayComponents.year)
    {
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 10.0f);
        
        dateLabelString = [self.monthDayDateFormatter stringFromDate:date];
        dateLabelAlpha = 1.0f;
        
        CGFloat width = [dateLabelString sizeWithFont:_dateLabel.font].width + 50.0f;
        
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - width, 0.0f, width, CGRectGetHeight(self.frame));
    }
    else
    {
        timeLabelFrame = CGRectMake(30.0f, 4.0f, 100.0f, 10.0f);
        dateLabelString = [self.monthDayYearDateFormatter stringFromDate:date];
        dateLabelAlpha = 1.0f;
        
        CGFloat width = [dateLabelString sizeWithFont:_dateLabel.font].width + 50.0f;
        
        backgroundFrame = CGRectMake(CGRectGetWidth(self.frame) - width, 0.0f, width, CGRectGetHeight(self.frame));
    }
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent animations:^{
        
        _timeLabel.frame = timeLabelFrame;
        _dateLabel.frame = dateLabelFrame;
        _dateLabel.alpha = dateLabelAlpha;
        _timeLabel.text = timeLabelString;
        _dateLabel.text = dateLabelString;
        _backgroundView.frame = backgroundFrame;
        
    } completion:nil];
}

- (void)scrollViewDidScroll
{
    // Point au milieu de l'écran
    CGPoint point = CGPointMake(CGRectGetMidX(_tableView.superview.frame), CGRectGetMidY(_tableView.superview.frame));
    // Equivalent dans la scroll View
    point = [_tableView.superview convertPoint:point toView:_tableView];
    // Index Path relatif au point
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    // Cellule relative
    UITableViewCell* cell=[_tableView cellForRowAtIndexPath:indexPath];
    
    // Update TimeScroller
    [self updateDisplayWithCell:cell];
    
    // Si le time scroller est caché, l'afficher
    if (![self alpha])
    {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self setAlpha:1.0f];
        } completion:nil];
    }
}

- (void)scrollViewDidEndDecelerating
{
    // Cacher picker quand on arrete de scroller
    [UIView animateWithDuration:0.3f delay:.1f options:UIViewAnimationOptionBeginFromCurrentState  animations:^{
        
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeTranslation(150.0f, 0.0f);
        
    } completion:nil];
}

- (void)scrollViewWillBeginDragging
{
    if (!_tableView)
    {
        [self captureTableView];
    }
    
    // Afficher Picker
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState  animations:^{
        
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity;
        
    } completion:nil];
    
}


@end
