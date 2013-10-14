//
//  InviteAddTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 27/01/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "InviteAddTableViewCell.h"
#import "Config.h"
#import "NSMutableAttributedString+FontAndTextColor.h"
#import "TTTAttributedLabel.h"
#import "ProfilViewController.h"
#import "FacebookManager.h"

enum InviteAddFontSize {
    InviteAddFontSizeSmall = 12,
    InviteAddFontSizeBig = 14
};

enum InviteAddTTLabel {
    InviteAddTTLabelNom = 1,
    InviteAddTTLabelAdresse = 2
    };

@implementation InviteAddTableViewCell

@synthesize navigationController = _navigationController;

@synthesize medallion = _medallion;
@synthesize nomLabel = _nomLabel;
@synthesize ttNomLabel = _ttNomLabel;
@synthesize nomText = _nomText;
@synthesize prenomText = _prenomText;
@synthesize adresseLabel = _adresseLabel;
@synthesize ttAdresseLabel = _ttAdresseLabel;
@synthesize adresseText = _adresseText;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize backgroundDefaultColor = _backgroundDefaultColor;
@synthesize isGoldProfile = _isGoldProfile;

- (id)initWithUser:(UserClass*)user
                   withStyle:(NSInteger)style
    withNavigationController:(UINavigationController*)navigationController
   reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
                
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"InviteAddTableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Save
        self.navigationController = navigationController;
        self.user = user;
        
        // Set Nom
        self.nomText = [user.nom uppercaseString];
        self.prenomText = [user.prenom uppercaseString];
        
        // Téléphone & Email
        self.phoneText = user.numeroMobile;;
        self.emailText = user.email;
        
        // Set Adresse
#warning Manque addresse
        self.adresseText = nil;
        
        // Update view
        [self setNomLabelTextWithColor:[Config sharedInstance].textColor ];
        [self setAdresseLabelTextWithColor:[Config sharedInstance].textColor];
        
        // Set image
        self.medallion.borderWidth = 3.0;
        self.medallion.defaultStyle = MedallionStyleProfile;
        //self.medallion.borderColor = [Config sharedInstance].orangeColor;
        if(user.uimage || user.imageString) {
            [self.medallion setImage:user.uimage imageString:user.imageString withSaveBlock:nil];
        }
        else if(user.facebookId) {
            [[FacebookManager sharedInstance] getFriendProfilePrictureURL:user.facebookId withEnded:^(NSString *url) {
                [self.medallion setImage:nil imageString:url withSaveBlock:^(UIImage *image) {
                    user.uimage = image;
                }];
            }];
        }
        [self.medallion addTarget:self action:@selector(clicProfile) forControlEvents:UIControlEventTouchUpInside];
        
        // Background
        UIColor *color = nil;
        if(style == 0)
            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
        self.backgroundDefaultColor = color;
        self.backgroundImageView.backgroundColor = self.backgroundDefaultColor;
        
        // Gold Profile
#warning Manque Gold Profile
        //if(attributes[@"goldProfile"] && ([attributes[@"goldProfile"] boolValue] == YES) )
            //self.isGoldProfile = YES;
        //else
            self.isGoldProfile = NO;

    }
    return self;
}

- (void)setAdresseLabelTextWithColor:(UIColor*)color
{
    NSString *text = nil;
    
    if( self.nomText || self.prenomText )
    {
        if(self.emailText)
            text = self.emailText;
        else if(self.adresseText)
            text = self.adresseText;
        else if(self.phoneText)
            text = self.phoneText;
    }
    
    if(text) {
        [self setCustomLabelText:self.adresseLabel withTTLabel:InviteAddTTLabelAdresse withColor:color withText:text withBigSize:InviteAddFontSizeBig-2 withSmallSize:InviteAddFontSizeSmall-2];
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
        [self setCustomLabelText:self.nomLabel withTTLabel:InviteAddTTLabelNom withColor:color withText:self.emailText withBigSize:InviteAddFontSizeBig withSmallSize:InviteAddFontSizeSmall];
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

- (void)setCustomLabelText:(CustomLabel*)label withTTLabel:(enum InviteAddTTLabel)ttLabelStyle withColor:(UIColor*)color withText:(NSString*)texteLabel withBigSize:(NSInteger)bigSize withSmallSize:(NSInteger)smallSize
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:texteLabel];
    NSInteger taille = [texteLabel length];
    
#pragma CustomLabel
    // Attributs du label
    NSRange range = NSMakeRange(0, 1);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:bigSize] range:range];
    range = NSMakeRange(1, taille-1);
    [attributedString setFont:[[Config sharedInstance] defaultFontWithSize:smallSize] range:range];
    
    [label setAttributedText:attributedString];
    label.textAlignment = kCTLeftTextAlignment;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    //self.backgroundColor = selected?[Config sharedInstance].orangeColor : self.backgroundDefaultColor;
    UIColor *fontColor = selected? [UIColor whiteColor] : [Config sharedInstance].textColor;
    if(self.isGoldProfile)
        self.medallion.borderColor = selected? [UIColor whiteColor] : [Config sharedInstance].orangeColor;
    if(self.ttNomLabel) {
        [self setNomLabelTextWithColor:fontColor];
        [self setAdresseLabelTextWithColor:fontColor];
    }
    else {
        self.nomLabel.textColor = fontColor;
        self.adresseLabel.textColor = fontColor;
    }
    self.backgroundImageView.backgroundColor = selected?[Config sharedInstance].orangeColor : self.backgroundDefaultColor;
}

- (void)clicProfile {
    ProfilViewController *profil = [[ProfilViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:profil animated:YES];
}

@end
