//
//  CreationHomeViewController.m
//  Moment
//
//  Created by Charlie FANCELLI on 21/09/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "CreationHomeViewController.h"
#import "ImporterFBViewController.h"

@interface CreationHomeViewController ()

@end

@implementation CreationHomeViewController

@synthesize timeLineViewContoller = _timeLineViewContoller;
@synthesize user = _user;

@synthesize contentView = _contentView;
@synthesize nomTextField = _nomTextField;

- (id)initWithUser:(UserClass*)user withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [super initWithNibName:@"CreationHomeViewController" bundle:nil];
    if (self) {
        self.user = user;
        self.timeLineViewContoller = timeLine;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Ajout Event";
    
    [CustomNavigationController setBackButtonWithViewController:self];
    
    // Centrer la vue
    CGRect frame = _contentView.frame;
    frame.origin.y = ( [VersionControl sharedInstance].screenHeight - TOPBAR_HEIGHT - frame.size.height )/2.0;
    _contentView.frame = frame;
    
    [self.view addSubview:_contentView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [AppDelegate updateActualViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createNewEvent
{
    if([self.nomTextField.text length] > 0)
    {
        CreationFicheViewController *ficheViewController = [[CreationFicheViewController alloc] initWithUser:self.user withEventName:self.nomTextField.text withTimeLine:self.timeLineViewContoller];
        [self.navigationController pushViewController:ficheViewController animated:YES];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Champ vide"
                                    message:@"Veuillez remplir le champ"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] 
         show];
    }
}

-(IBAction)clicImportFB
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CreationHomeViewController_importFBAlertView_Title", nil)
            message:NSLocalizedString(@"CreationHomeViewController_importFBAlertView_Message", nil)
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"AlertView_Button_NO", nil)
                                                    otherButtonTitles:NSLocalizedString(@"AlertView_Button_YES", nil), nil]
    show];
}

#pragma mark - TextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    
    if([_nomTextField.text length] > 0)
    {
        [self createNewEvent];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_contentView adjustOffsetToIdealIfNeeded];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // --- Import FB Alert View ---
    
    // Oui -> Importer
    if(buttonIndex == 1) {
        ImporterFBViewController *fbViewController = [[ImporterFBViewController alloc] initWithTimeLine:self.timeLineViewContoller];
        
        // Remove this view controller
        // -> On pousse le ImportFB View controller et le bouton BACK retournera à la TimeLine
        NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
        [viewControllers removeLastObject];
        [viewControllers addObject:fbViewController];
        
        [self.navigationController setViewControllers:viewControllers animated:NO];
    }
    
}


@end
