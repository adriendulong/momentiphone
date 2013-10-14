//
//  RevivrePartagerViewController.h
//  Moment
//
//  Created by SkeletonGamer on 03/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface RevivrePartagerViewController : GAITrackedViewController

@property (nonatomic, strong) NSArray *moments;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSMutableArray *photosInCache;

@property (nonatomic, weak) UIViewController <TimeLineDelegate> *timeLine;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *sendToFaceBookFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *tweetToFollowersButton;
@property (weak, nonatomic) IBOutlet UIButton *sendSMSButton;
@property (weak, nonatomic) IBOutlet UIButton *backToTheTimeLineButton;


- (id)initWithTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
                moments:(NSArray *)moments
                 photos:(NSArray *)photos;

@end
