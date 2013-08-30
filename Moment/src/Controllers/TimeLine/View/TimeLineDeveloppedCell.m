//
//  TimeLineDeveloppedCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 29/12/12.
//  Copyright (c) 2012 Mathieu PIERAGGI. All rights reserved.
//

#import "TimeLineDeveloppedCell.h"
#import "Config.h"
#import "Photos.h"

@implementation TimeLineDeveloppedCell {
    @private
    CGAffineTransform originalMedallionTransform, originalTransform;
    CGPoint originalMedallionCenter, originalCenter;
}

@synthesize timeLineDelegate = _timeLineDelegate;
@synthesize moment = _moment;

@synthesize centerView = _centerView;
@synthesize medallion = _medallion;
@synthesize titreMoment = _titreMoment;
@synthesize dateLabel = _dateLabel;

@synthesize buttonPhoto = _buttonPhoto;
@synthesize buttonInfo = _buttonInfo;
@synthesize buttonMessage = _buttonMessage;
@synthesize buttonDelete = _buttonDelete;

- (void)initBouton:(UIButton*)button
{
    button.layer.cornerRadius = button.frame.size.width/2.0f;
}

- (void) addShadowToView:(UIView*)view
{
    view.layer.shadowColor = [[UIColor darkTextColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    view.layer.shadowRadius = 2.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.masksToBounds  = NO;
}

- (void)centerOriginForView:(UIView*)view {
    CGRect frame = view.frame;
    frame.origin.x = (self.timeLineDelegate.size.width*view.frame.origin.x)/320.0;
    view.frame = frame;
}

- (id)initWithMoment:(MomentClass*)param
        withDelegate:(id <TimeLineDelegate>)delegate
     reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        // Init
        self.moment = param;
        self.timeLineDelegate = delegate;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"TimeLineDeveloppedCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Centrer en fonction de la taille
        CGRect frame = self.centerView.frame;
        frame.origin.x = (self.timeLineDelegate.size.width - frame.size.width)/2.0;
        self.centerView.frame = frame;
        frame = self.titreMoment.frame;
        frame.size.width = self.timeLineDelegate.size.width;
        frame.origin.x = (self.timeLineDelegate.size.width - frame.size.width)/2.0;
        self.titreMoment.frame = frame;
        frame.origin.y = self.dateLabel.frame.origin.y;
        frame.size.height = self.dateLabel.frame.size.height;
        self.dateLabel.frame = frame;
        
        // Image
        self.medallion.borderWidth = 1.5;
        self.medallion.defaultStyle = MedallionStyleCover;
        __weak TimeLineDeveloppedCell *dp = self;
        [self.medallion addTarget:self action:@selector(medaillionClic) forControlEvents:UIControlEventTouchUpInside];
        [self.medallion setImage:self.moment.uimage imageString:self.moment.imageString withSaveBlock:^(UIImage *image) {
            [dp.moment setUimage:image];
        }];
        
        // Titre
        NSString *titreMoment = [[NSString alloc] init];
        if ([self.moment.titre length] > 28) {
            titreMoment = [self.moment.titre substringToIndex:28];
        } else {
            titreMoment = self.moment.titre;
        }
        
        self.titreMoment.text = titreMoment;
        [self addShadowToView:self.titreMoment];
        
        // Date
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE d MMMM - H"];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"] ];
        NSString *dateString = [NSString stringWithFormat:@"%@h", [df stringFromDate:self.moment.dateDebut] ];
        self.dateLabel.text = dateString;
        [self addShadowToView:self.dateLabel];
        
        // Boutons
        [self initBouton:self.buttonInfo];
        [self initBouton:self.buttonMessage];
        [self initBouton:self.buttonPhoto];
        [self initBouton:self.buttonDelete];
        
        // Afficher bouton supprimer que si owner
        /*if(![self.moment.owner.userId isEqualToNumber:[UserCoreData getCurrentUser].userId]) {
            self.buttonDelete.hidden = YES;
        }*/
        
        // Save Original Properties
        originalMedallionCenter = self.medallion.center;
        originalMedallionTransform = self.medallion.transform;
        originalCenter = self.center;
        originalTransform = self.transform;
        
    }
    return self;
}

- (void)didAppear
{
    // On réduit la taille pour faire un effet de grandissement
    CGRect frame = self.medallion.frame, tempFrame = self.medallion.frame;
    //tempFrame.origin.y -= tempFrame.size.height/3.0;
    self.medallion.frame = tempFrame;
    self.medallion.transform =  CGAffineTransformScale(originalMedallionTransform, 0.35, 0.35);
    //self.transform = CGAffineTransformMakeTranslation(0, -0.6);
    self.buttonInfo.alpha = 0;
    self.buttonMessage.alpha = 0;
    self.buttonPhoto.alpha = 0;
    self.buttonDelete.alpha = 0;
    
    /*
    [self.medallion setNeedsDisplay];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.medallion.transform = originalMedallionTransform;
        self.medallion.center = originalMedallionCenter;
        self.medallion.frame = frame;
        
        [self.medallion.layer displayIfNeeded];
        */
        
    // On remet à la taille de base
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.medallion.transform = originalMedallionTransform;
        self.medallion.center = originalMedallionCenter;
        self.medallion.frame = frame;
    } completion:^(BOOL finished) {
        
        if(finished) {
            
            /*  // Apparition synchronisée des boutons
            [UIView beginAnimations:@"fadeButtonsAnimation" context:nil];
            self.buttonInfo.alpha = 1;
            self.buttonMessage.alpha = 1;
            self.buttonPhoto.alpha = 1;
            [UIView commitAnimations];
             */
            
            // Apparition décalée des boutons
            [UIView animateWithDuration:0.2 animations:^{
                self.buttonPhoto.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    self.buttonInfo.alpha = 1;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        self.buttonMessage.alpha = 1;
                    } completion:^(BOOL finished) {
                        
                        // Bouton Delete
                        if(self.moment.state.intValue == UserStateOwner)
                        {
                            [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
                                self.buttonDelete.alpha = 1;
                            } completion:nil];
                        }
                        
                    }];
                }];
            }];
            
            
        }
        
    }];
}

- (void)willDisappear
{
    // On décalle le centre des actions pour que le medallion garde le meme centre une foi redimentionné
    self.layer.anchorPoint = self.center;
    
    // Réduire medaillon
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformScale(originalTransform, 0.5, 0.5);
        self.center = originalCenter;
        self.alpha= 0;
    }completion:^(BOOL finished) {
        self.transform = originalTransform;
        self.center = originalCenter;
        // On replace le centre à son état d'origine
        self.layer.anchorPoint = CGPointMake(.5, .5);
    }];
}

- (IBAction)buttonPhotoClic {
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Direct icone Photo" value:nil];
    
    [self.timeLineDelegate showPhotoView:self.moment];
}

- (IBAction)buttonInfoClic {
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Direct icone Infos" value:nil];
    [self.timeLineDelegate showInfoMomentView:self.moment];
}

- (void)medaillionClic {
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic ouvrir Moment" value:nil];
    [self.timeLineDelegate showInfoMomentView:self.moment];
}

- (IBAction)buttonMessageClic {
    // Google Analytics
    [self sendGoogleAnalyticsEvent:@"Clic Bouton" label:@"Clic Direct icone Chat" value:nil];
    
    [self.timeLineDelegate showTchatView:self.moment];
}

- (IBAction)buttonDeleteClic {
    [self.timeLineDelegate deleteMoment:self.moment];
}

#pragma mark - Google Analytics

- (void)sendGoogleAnalyticsEvent:(NSString*)action label:(NSString*)label value:(NSNumber*)value {
    [[[GAI sharedInstance] defaultTracker]
     sendEventWithCategory:@"Timeline"
     withAction:action
     withLabel:label
     withValue:value];
}

@end
