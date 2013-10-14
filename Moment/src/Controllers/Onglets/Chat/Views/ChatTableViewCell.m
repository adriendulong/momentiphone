//
//  ChatTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 15/02/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "Config.h"
#import "UserCoreData+Model.h"
#import "FacebookManager.h"
#import "ChatViewController.h"
#import "ProfilViewController.h"

@implementation ChatTableViewCell

@synthesize navigationController = _navigationController;
@synthesize message = _message;
@synthesize texteMessageLabel = _texteMessageLabel;
@synthesize nomLabel = _nomLabel;
@synthesize jourLabel = _jourLabel;
@synthesize heureLabel = _heureLabel;

- (id)initWithChatMessage:(ChatMessage*)message
        withDateFormatter:(NSDateFormatter*)dateFormatter
               withHeight:(CGFloat)height
          reuseIdentifier:(NSString*)reuseIdentifier
     navigationController:(UINavigationController*)navController
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
    
        // Data
        self.message = message;
        self.navigationController = navController;
        
        // View Left / Right
        BOOL isRightView = (self.message.user.userId.intValue == [UserCoreData getCurrentUser].userId.intValue);
        NSString *nibFile = isRightView? @"ChatTableViewRightCell" : @"ChatTableViewLeftCell";
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:nibFile owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Frame
        CGRect frame = self.frame;
        frame.size.height = height + CHAT_CELL_OFFSET_HEIGHT;
        self.frame = frame;
        
        self.backgroundColor = [UIColor clearColor];
        
        //NSLog(@"height = %f - Default : %f",height, CHAT_CELL_DEFAULT_HEIGHT - CHAT_CELL_OFFSET_HEIGHT);
        if(height > CHAT_CELL_DEFAULT_HEIGHT - CHAT_CELL_OFFSET_HEIGHT) {
            // Text Size
            frame = self.texteMessageLabel.frame;
            frame.size.height = height;
            self.texteMessageLabel.frame = frame;
            
            // Background size
            frame = self.messageBackgroudView.frame;
            frame.size.height = height + 17.0f;
            self.messageBackgroudView.frame = frame;
            
            // Backfround image
            self.messageBackgroudView.image = [[VersionControl sharedInstance] resizableImageFromImage:self.messageBackgroudView.image withCapInsets:UIEdgeInsetsMake(28, 4, 4, 4) stretchableImageWithLeftCapWidth:4 topCapHeight:28];
        }
        
        // Config
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:9];
        
        // TexteMessage
        self.texteMessageLabel.text = message.message;
        self.texteMessageLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
        
        // Nom
        if(message.user.prenom && message.user.nom && (message.user.nom.length > 0))
            self.nomLabel.text = [NSString stringWithFormat:@"%@ %@.", message.user.prenom, [message.user.nom substringToIndex:1]];
        else if(message.user.prenom)
            self.nomLabel.text = [NSString stringWithFormat:@"%@", message.user.prenom];
        else
            self.nomLabel.text = @"...";
        self.nomLabel.font = font;
        [self.nomLabel sizeToFit];
        [self placerLabel:self.nomLabel horizontalyAfterView:nil withMarginX:0 verticalyAfter:self.messageBackgroudView withMarginY:1];
        
        // Jour
        dateFormatter.dateFormat = @"dd";
        NSString *jour = [dateFormatter stringFromDate:message.date];
        dateFormatter.dateFormat = @"MMMM yyyy";
        self.jourLabel.text = [NSString stringWithFormat:@"%d %@", [jour intValue], [dateFormatter stringFromDate:message.date]];
        self.jourLabel.font = font;
        [self.jourLabel sizeToFit];
        [self placerLabel:self.jourLabel horizontalyAfterView:self.nomLabel withMarginX:5 verticalyAfter:self.messageBackgroudView withMarginY:1];
        
        // Heures
        dateFormatter.dateFormat = @"HH";
        NSString *heures = [dateFormatter stringFromDate:message.date];
        dateFormatter.dateFormat = @"mm";
        self.heureLabel.text = [NSString stringWithFormat:@"%d:%@", [heures intValue], [dateFormatter stringFromDate:message.date]];
        self.heureLabel.font = font;
        [self.heureLabel sizeToFit];
        frame = self.heureLabel.frame;
        frame.origin.x = self.texteMessageLabel.frame.origin.x + self.texteMessageLabel.frame.size.width - frame.size.width;
        frame.origin.y = self.messageBackgroudView.frame.origin.y + self.messageBackgroudView.frame.size.height + 1;
        self.heureLabel.frame = frame;
        
        // Medaillon
        self.medallion.borderWidth = 2.0;
        //NSLog(@"message = %@", self.message);
        __weak ChatTableViewCell *dp = self;
        if(self.message.user.uimage || self.message.user.imageString) {
            [self.medallion setImage:self.message.user.uimage imageString:self.message.user.imageString withSaveBlock:^(UIImage *image) {
                [dp.message.user setUimage:image];
            }];
        }
        else if(self.message.user.facebookId) {
            [[FacebookManager sharedInstance] getFriendProfilePrictureURL:self.message.user.facebookId withEnded:^(NSString *url) {
                [self.medallion setImage:self.medallion.image imageString:url withSaveBlock:^(UIImage *image) {
                    [dp.message.user setUimage:image];
                }];
            }];
        } else {
            [self.medallion setImage:[UIImage imageNamed:@"profil_defaut.png"]];
        }
        [self.medallion addTarget:self action:@selector(clicProfile) forControlEvents:UIControlEventTouchUpInside];
        
        // Gold Profile
        if( 0 )
            self.medallion.borderColor = [Config sharedInstance].orangeColor;
    }
    return self;
}

- (void)placerLabel:(UILabel*)label horizontalyAfterView:(UIView*)originX withMarginX:(NSInteger)marginX verticalyAfter:(UIView*)originY withMarginY:(NSInteger)marginY
{
    CGRect frame = label.frame;
    if(originX)
        frame.origin.x = originX.frame.origin.x + originX.frame.size.width + marginX;
    if(originY)
        frame.origin.y = originY.frame.origin.y + originY.frame.size.height + marginY;
    label.frame = frame;
}

- (void)clicProfile {
    //NSLog(@"pop message = %@ user = %@ navController = %@\n\n", self.message, self.message.user, self.navigationController);
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:self.message.user];
    [self.navigationController pushViewController:profil animated:YES];
}


@end
