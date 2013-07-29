//
//  Cagnotte1ViewController.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 09/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Cagnotte1ViewController.h"
#import "Config.h"
#import "Cagnotte2ViewController.h"
#import "Cagnotte3ViewController.h"

@interface Cagnotte1ViewController ()

@end

@implementation Cagnotte1ViewController

@synthesize parametres = _parametres;
@synthesize bandeauView = _bandeauView;
@synthesize backgroundDescriptionView = _backgroundDescriptionView;
@synthesize descriptionTextView = _descriptionTextView;
@synthesize montantTextField = _montantTextField;
@synthesize beneficiaireTextField = _beneficiaireTextField;
@synthesize titreTextField = _titreTextField;

- (id)initWithMoment:(MomentClass*)moment
{
    self = [super initWithNibName:@"Cagnotte1ViewController" bundle:nil];
    if (self) {
        self.parametres = [[NSMutableDictionary alloc] init];
        self.parametres[@"moment"] = moment;
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
    CGSize size = self.scrollView.contentSize;
    self.scrollView.frame = frame;
    self.scrollView.contentSize = size;
    [self.view addSubview:self.scrollView];
    
    // Bandeau Label
    //self.bandeauLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
    
    // Bandeau Fond
    self.bandeauView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_panier"]];
    self.bandeauView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Description
    UIImage *image = [[VersionControl sharedInstance] resizableImageFromImage:self.backgroundDescriptionView.image withCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    self.backgroundDescriptionView.image = image;
    self.descriptionTextView.placeholder = @"Description";
    
    // Choix bouton label
    self.choixLabel.font = [[Config sharedInstance] defaultFontWithSize:14];
    
    // Boutons
    UIFont *font = [[Config sharedInstance] defaultFontWithSize:12];
    self.cagnotteLabel.font = font;
    self.cadeauLabel.font = font;
}

- (void)viewDidUnload {
    [self setBandeauLabel:nil];
    [self setBandeauView:nil];
    [self setParametres:nil];
    [self setBackgroundDescriptionView:nil];
    [self setDescriptionTextView:nil];
    [self setBeneficiaireTextField:nil];
    [self setTitreTextField:nil];
    [self setMontantTextField:nil];
    [self setDateFinTextField:nil];
    [self setChoixLabel:nil];
    [self setCagnotteLabel:nil];
    [self setCadeauLabel:nil];
    [self setBandeauLabel:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.beneficiaireTextField)
        [self.titreTextField becomeFirstResponder];
    else if(textField == self.titreTextField)
        [self.montantTextField becomeFirstResponder];
    else if(textField == self.montantTextField)
        [self.dateFinTextField becomeFirstResponder];
    else if(textField == self.dateFinTextField)
        [self.descriptionTextView becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView adjustOffsetToIdealIfNeeded];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.scrollView adjustOffsetToIdealIfNeeded];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == self.montantTextField)
    {
        // backspace
        if([string length]==0){
            return YES;
        }
        
        // Commence par un zéro
        if(textField.text.length > 0 && [[textField.text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"])
            return NO;
        
        //  limit to only numeric characters
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                return YES;
            }
        }
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Validation

- (BOOL)validateForm
{
    if( self.beneficiaireTextField.text.length == 0)
        [self.beneficiaireTextField becomeFirstResponder];
    else if(self.titreTextField.text.length == 0)
        [self.titreTextField becomeFirstResponder];
    else if(self.montantTextField.text.length == 0)
        [self.montantTextField becomeFirstResponder];
    else if(self.dateFinTextField.text.length == 0)
        [self.dateFinTextField becomeFirstResponder];
    else if(self.descriptionTextView.text.length == 0)
        [self.descriptionTextView becomeFirstResponder];
    else {
        
        // Save paramètres
        self.parametres[@"titre"] = self.titreTextField.text;
        self.parametres[@"montant"] = @([self.montantTextField.text floatValue]);
        self.parametres[@"beneficiaire"] = self.beneficiaireTextField.text;
        self.parametres[@"description"] = self.descriptionTextView.text;
        self.parametres[@"dateFin"] = self.dateFinTextField.text;
        
        return YES;
    }
    
    return NO;
}

- (IBAction)clicCadeau {
    if([self validateForm]) {
        Cagnotte2ViewController *cadeaux = [[Cagnotte2ViewController alloc] initWitParametres:self.parametres];
        [self.navigationController pushViewController:cadeaux animated:YES];
    }
}

- (IBAction)clicCagnotte {
    if([self validateForm]) {
        Cagnotte3ViewController *cagnotte = [[Cagnotte3ViewController alloc] initParametres:self.parametres];
        [self.navigationController pushViewController:cagnotte animated:YES];
    }
}

@end
