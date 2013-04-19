//
//  PrintFormViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 14/03/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PrintFormViewController.h"
#import "Config.h"
#import "UILabel+BottomAlign.h"
#import "Config.h"

@interface PrintFormViewController ()

@end

@implementation PrintFormViewController

@synthesize photos = _photos;
@synthesize bandeauView = _bandeauView, nbPhotosLabel = _nbPhotosLabel;
@synthesize priceLabel = _priceLabel, tiretLabel = _tiretLabel, photosSelectionneesLabel = _photosSelectionneesLabel;
@synthesize prenomTextField = _prenomTextField, nomTextField = _nomTextField, adresseTextField = _adresseTextField;
@synthesize codePostalTextField = _codePostalTextField, villeTextField = _villeTextField;
@synthesize emailTextField = _emailTextField, facturationLabel = _facturationLabel;
@synthesize paysTextField = _paysTextField, scrollView = _scrollView;

- (id)initWithPhotosToPrint:(NSArray*)photos
{
    self = [super initWithNibName:@"PrintFormViewController" bundle:nil];
    if (self) {
        self.photos = photos;
        [CustomNavigationController setBackButtonWithViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // iPhone 5
    CGRect frame = self.view.frame;
    frame.size.height = [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT;
    self.view.frame = frame;
    frame = self.scrollView.frame;
    frame.origin.y = self.bandeauView.frame.size.height;
    frame.size.height = self.view.frame.size.height - self.bandeauView.frame.size.height;
    self.scrollView.frame = frame;
    
    // Bandeau
    self.bandeauView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_panier"]];
    self.bandeauView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Labels
    self.facturationLabel.font = [[Config sharedInstance] defaultFontWithSize:11];
    int count = [self.photos count];
    UIFont *bigfont = [[Config sharedInstance] defaultFontWithSize:16];
    self.nbPhotosLabel.text = [NSString stringWithFormat:@"%d", count];
    self.nbPhotosLabel.font = bigfont;
    [self.nbPhotosLabel sizeToFit];
    if(count > 1)
        self.photosSelectionneesLabel.text = NSLocalizedString(@"PhotoViewController_Bandeau_photosSelectionneesLabel_Pluriel", nil);
    else
        self.photosSelectionneesLabel.text = NSLocalizedString(@"PhotoViewController_Bandeau_photosSelectionneesLabel_Singulier", nil);
    UIFont *smallFont = [[Config sharedInstance] defaultFontWithSize:13];
    self.photosSelectionneesLabel.font = smallFont;
    [self.photosSelectionneesLabel sizeToFit];
    frame = self.photosSelectionneesLabel.frame;
    frame.origin.y = (self.bandeauView.frame.size.height - frame.size.height)/2.0;
    frame.origin.x = self.nbPhotosLabel.frame.origin.x + self.nbPhotosLabel.frame.size.width + 8;
    self.photosSelectionneesLabel.frame = frame;
    frame = self.nbPhotosLabel.frame;
    frame.origin.y = [self.nbPhotosLabel topAfterBottomAligningWithLabel:self.photosSelectionneesLabel];
    self.nbPhotosLabel.frame = frame;
    
    // Prix
    CGFloat prixUnitaire = 0.94 + (rand()%10)/10.0;
    CGFloat prix = count*prixUnitaire;
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f€", prix];
    self.priceLabel.font = bigfont;
    [self.priceLabel sizeToFit];
    frame = self.priceLabel.frame;
    frame.origin.y = [self.priceLabel topAfterBottomAligningWithLabel:self.photosSelectionneesLabel];
    self.priceLabel.frame = frame;
    self.tiretLabel.font = smallFont;
    frame = self.tiretLabel.frame;
    frame.origin.x = (self.photosSelectionneesLabel.frame.origin.x + self.photosSelectionneesLabel.frame.size.width + self.priceLabel.frame.origin.x - frame.size.width)/2.0;
    self.tiretLabel.frame = frame;
    
    // Préremplissage
    UserClass *user = [UserCoreData getCurrentUser];
    if(user.prenom)
        self.prenomTextField.text = user.prenom;
    if(user.nom)
        self.nomTextField.text = user.nom;
    if(user.email)
        self.emailTextField.text = user.email;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBandeauView:nil];
    [self setPriceLabel:nil];
    [self setTiretLabel:nil];
    [self setPhotosSelectionneesLabel:nil];
    [self setNbPhotosLabel:nil];
    [self setPrenomTextField:nil];
    [self setNomTextField:nil];
    [self setAdresseTextField:nil];
    [self setCodePostalTextField:nil];
    [self setVilleTextField:nil];
    [self setPaysTextField:nil];
    [self setFacturationLabel:nil];
    [self setEmailTextField:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (IBAction)clicCommander
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Valider la commande"
                                                             delegate:self
                                                    cancelButtonTitle:@"Annuler"
                                               destructiveButtonTitle:@"Commander"
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [[MTStatusBarOverlay sharedInstance] postImmediateFinishMessage:@"Commande envoyée" duration:1 animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
