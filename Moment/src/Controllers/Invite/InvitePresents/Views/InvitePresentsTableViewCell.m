//
//  InvitePresentsTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InvitePresentsTableViewCell.h"
#import "FacebookManager.h"
#import "Config.h"
#import "NSMutableAttributedString+FontAndTextColor.h"
#import "ProfilViewController.h"

#define cellHeight 70

enum InviteAddFontSize {
    InviteAddFontSizeSmall = 10,
    InviteAddFontSizeBig = 12
};

enum InviteAddTTLabel {
    InviteAddTTLabelNom = 1,
    InviteAddTTLabelAdresse = 2
};

@implementation InvitePresentsTableViewCell {
    @private
    BOOL adminAuthorisation;
}

@synthesize index = _index;
@synthesize delegate = _delegate;

@synthesize medaillon = _medaillon;
@synthesize nomLabel = _nomLabel;
@synthesize adresseLabel = _adresseLabel;
@synthesize ttNomLabel = _ttNomLabel;
@synthesize ttAdresseLabel = _ttAdresseLabel;
@synthesize adminButton = _adminButton;
@synthesize adminLabel = _adminLabel;
@synthesize adminSelected = _adminSelected;

@synthesize nomText = _nomText;
@synthesize prenomText = _prenomText;
@synthesize adresseText = _adresseText;
@synthesize emailText = _emailText;

@synthesize backgroundImageView = _backgroundImageView;
@synthesize backgroundDefaultColor = _backgroundDefaultColor;
@synthesize isGoldProfile = _isGoldProfile;

- (id)initWithAttributes:(NSMutableDictionary*)attributes
         withIndex:(NSInteger)index
         withAdmin:(BOOL)adminAccess
      withDelegate:(InvitePresentsTableViewController*)delegate
   reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"InvitePresentsTableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.autoresizesSubviews = NO;
        self.frame = CGRectMake(0,0,320,cellHeight);
        
        // Save
        UserClass *user = attributes[@"user"];
        self.user = user;
        self.index = index;
        
        // Set Nom
        self.nomText = [user.nom uppercaseString];;
        self.prenomText = [user.prenom uppercaseString];
        [self setNomLabelTextWithColor:[Config sharedInstance].textColor];
        
        // Téléphone & Email
        self.phoneText = user.numeroMobile;
        self.emailText = user.email;
        
        // Set Adresse
#warning Pas d'adresse
        self.adresseText = nil;
        [self setAdresseLabelTextWithColor:[Config sharedInstance].textColor];
        
        // Admin
        adminAuthorisation = adminAccess;
        if(adminAuthorisation) {
            self.adminLabel.text = NSLocalizedString(@"InvitePresentsTableViewCell_AdminLabel", nil);
            self.adminSelected = ([attributes[@"isAdmin"] boolValue]);
        }
        else {
            self.adminLabel.hidden = YES;
            self.adminButton.hidden = YES;
            self.adminSelected = NO;
        }
        
        // Set image
        self.medaillon.borderWidth = 2.0;
        self.medaillon.defaultStyle = MedallionStyleProfile;
        if(user.uimage || user.imageString) {
            [self.medaillon setImage:user.uimage imageString:user.imageString withSaveBlock:nil];
        }
        else if(user.facebookId) {
            [[FacebookManager sharedInstance] getFriendProfilePrictureURL:user.facebookId withEnded:^(NSString *url) {
                [self.medaillon setImage:self.medaillon.image imageString:url withSaveBlock:^(UIImage *image) {
                    user.uimage = image;
                }];
            }];
        }
        [self.medaillon addTarget:self action:@selector(clicProfile) forControlEvents:UIControlEventTouchUpInside];
        
        // Background
        UIColor *color = nil;
        if( index%2 == 0 )
            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
        self.backgroundDefaultColor = color;
        self.backgroundImageView.backgroundColor = self.backgroundDefaultColor;
        
        // Gold Profile
#warning Gold Profile
        //if(attributes[@"goldProfile"] && ([attributes[@"goldProfile"] boolValue] == YES) )
            //self.isGoldProfile = YES;
        //else
            self.isGoldProfile = NO;
        
        // Delegate
        self.delegate = delegate;
    }
    return self;
}

- (IBAction)clicAdmin {
    
    [self.delegate updateUserAtRow:self.index asAdmin:!self.adminSelected withEnded:^(BOOL success) {
        
        if(success) {
            self.adminSelected = !self.adminSelected;
            [self setSelected:self.adminLabel animated:YES];
        }
        
    }];
}


- (void)setAdresseLabelTextWithColor:(UIColor*)color
{
    if(self.adresseText) {
        [self setCustomLabelText:self.adresseLabel withTTLabel:InviteAddTTLabelAdresse withColor:color withText:self.adresseText withBigSize:InviteAddFontSizeBig-2 withSmallSize:InviteAddFontSizeSmall-2];
    } else {
        self.adresseLabel.hidden = YES;
    }
}

- (void)setNomLabelTextWithColor:(UIColor*)color
{
    if( (self.nomText && ([self.nomText length] > 0) ) && (self.prenomText && ([self.prenomText length] > 0)) ) {
        [self setNomAndPrenomLabelText:self.prenomText nom:self.nomText withColor:color];
    }else if(self.prenomText) {
        [self setCustomLabelText:self.nomLabel withTTLabel:InviteAddTTLabelNom withColor:color withText:self.prenomText withBigSize:InviteAddFontSizeBig withSmallSize:InviteAddFontSizeSmall];
    }
    else if(self.nomText) {
        [self setCustomLabelText:self.nomLabel withTTLabel:InviteAddTTLabelNom withColor:color withText:self.nomText withBigSize:InviteAddFontSizeBig withSmallSize:InviteAddFontSizeSmall];
    }
    else if(self.emailText) {
        [self setCustomLabelText:self.nomLabel withTTLabel:InviteAddTTLabelNom withColor:color withText:self.phoneText withBigSize:InviteAddFontSizeBig withSmallSize:InviteAddFontSizeSmall];
    }
    else if(self.phoneText) {
        [self setCustomLabelText:self.nomLabel withTTLabel:InviteAddTTLabelNom withColor:color withText:self.phoneText withBigSize:InviteAddFontSizeBig withSmallSize:InviteAddFontSizeSmall];
    }
    else {
        self.nomLabel.hidden = YES;
    }
}

- (void)setNomAndPrenomLabelText:(NSString*)prenom nom:(NSString*)nom withColor:(UIColor*)color
{
    NSString *total = [NSString stringWithFormat:@"%@ %@", prenom, nom];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:total];
    
    NSInteger taillePrenom = [prenom length];
    NSInteger tailleNom = [nom length];
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeBig] range:range];
        range = NSMakeRange(1, taillePrenom);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeSmall] range:range];
        range = NSMakeRange(taillePrenom+1, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeBig] range:range];
        
        if(taillePrenom > 1) {
            range = NSMakeRange(taillePrenom+2, tailleNom-1);
            [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:InviteAddFontSizeSmall] range:range];
        }
        
        [self.nomLabel setAttributedText:attributedString];
        self.nomLabel.textAlignment = kCTLeftTextAlignment;
    }
    else
    {
        
        TTTAttributedLabel *ttLabel = [[TTTAttributedLabel alloc] initWithFrame:self.nomLabel.frame];
        ttLabel.backgroundColor = [UIColor clearColor];
        [ttLabel setText:total afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeBig onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeSmall onRange:NSMakeRange(1, taillePrenom)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeBig onRange:NSMakeRange(taillePrenom+1, 1)];
            
            if(taillePrenom > 1) {
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:InviteAddFontSizeSmall onRange:NSMakeRange(taillePrenom+2, tailleNom-1)];
            }
            
            [cf updateTTTAttributedString:mutableAttributedString withColor:color onRange:NSMakeRange(0, [total length])];
            
            return mutableAttributedString;
        }];
        
        [self.nomLabel.superview addSubview:ttLabel];
        self.nomLabel.hidden = YES;
        if(self.ttNomLabel) {
            [self.ttNomLabel removeFromSuperview];
        }
        self.ttNomLabel = ttLabel;
    }
}

- (void)setCustomLabelText:(UILabel*)label withTTLabel:(enum InviteAddTTLabel)ttLabelStyle withColor:(UIColor*)color withText:(NSString*)texteLabel withBigSize:(NSInteger)bigSize withSmallSize:(NSInteger)smallSize
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
#pragma CustomLabel
    if( [[VersionControl sharedInstance] supportIOS6] )
    {
        // Attributs du label
        NSRange range = NSMakeRange(0, 1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:bigSize] range:range];
        range = NSMakeRange(1, taille-1);
        [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:smallSize] range:range];
        
        [label setAttributedText:attributedString];
        label.textAlignment = kCTLeftTextAlignment;
    }
    else
    {
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:label.frame];
        tttLabel.backgroundColor = [UIColor clearColor];
        [tttLabel setText:texteLabel afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:bigSize onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:smallSize onRange:NSMakeRange(1, taille-1)];
            
            [cf updateTTTAttributedString:mutableAttributedString withColor:color onRange:NSMakeRange(0, taille)];
            
            return mutableAttributedString;
        }];
        
        [label.superview addSubview:tttLabel];
        label.hidden = YES;
        
        if(ttLabelStyle == InviteAddTTLabelNom) {
            
            if(self.ttNomLabel) {
                [self.ttNomLabel removeFromSuperview];
            }
            self.ttNomLabel = tttLabel;
        } else {
            
            if(self.ttAdresseLabel) {
                [self.ttAdresseLabel removeFromSuperview];
            }
            self.ttAdresseLabel = tttLabel;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{    
    [self.adminButton setSelected:self.adminSelected];
    
    //self.backgroundColor = selected?[Config sharedInstance].orangeColor : self.backgroundDefaultColor;
    UIColor *fontColor = self.adminSelected? [UIColor whiteColor] : [Config sharedInstance].textColor;
    if(self.isGoldProfile)
        self.medaillon.borderColor = self.adminSelected? [UIColor whiteColor] : [Config sharedInstance].orangeColor;
    if(self.ttNomLabel) {
        [self setNomLabelTextWithColor:fontColor];
        [self setAdresseLabelTextWithColor:fontColor];
    }
    else {
        self.nomLabel.textColor = fontColor;
        self.adresseLabel.textColor = fontColor;
    }
    self.backgroundImageView.backgroundColor = nil;
    self.backgroundImageView.backgroundColor = self.adminSelected?[Config sharedInstance].orangeColor : self.backgroundDefaultColor;

    [super setSelected:self.adminSelected animated:animated];
}

- (void)clicProfile {
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:self.user];
    [self.delegate.navController pushViewController:profil animated:YES];
}


@end
