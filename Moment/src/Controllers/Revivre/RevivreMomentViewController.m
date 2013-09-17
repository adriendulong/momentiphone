//
//  RevivreMomentViewController.m
//  Moment
//
//  Created by SkeletonGamer on 02/09/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "RevivreMomentViewController.h"
#import "Config.h"
#import "RevivreImportFBViewController.h"

@interface RevivreMomentViewController ()

@end

@implementation RevivreMomentViewController

@synthesize delegate = _delegate;
@synthesize timeLineViewContoller = _timeLineViewContoller;
@synthesize titleLabel = _titleLabel;
@synthesize contentView = _contentView;
@synthesize creaImageView = _creaImageView;
@synthesize recupererEventsButton = _recupererEventsButton;


#pragma mark - Init

- (id)initWithDDMenuDelegate:(DDMenuController *)delegate withTimeLine:(UIViewController <TimeLineDelegate> *)timeLine
{
    self = [super initWithNibName:@"RevivreMomentViewController" bundle:nil];
    if(self) {
        self.delegate = delegate;
        self.timeLineViewContoller = timeLine;
        
        [self initNavigationBar];
    }
    return self;
}

#pragma mark - NavigationBar

- (void)initNavigationBar
{
    [CustomNavigationController setBackButtonChevronWithViewController:self];
    [CustomNavigationController setTitle:@"Revivre" withColor:[UIColor blackColor] withViewController:self];
}

#pragma mark - View manager

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Google Analytics
    [[[GAI sharedInstance] defaultTracker] sendView:@"Revivre Event Accueil"];
    
    [AppDelegate updateActualViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Google Analytics
    self.trackedViewName = @"Vue Revivre Moments";
    
    self.contentView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    [self.recupererEventsButton setBackgroundImage:[UIImage imageNamed:@"btn_revivre.png"]
                                          forState:UIControlStateNormal];
    
    [self.recupererEventsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.recupererEventsButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    if ([[VersionControl sharedInstance] isIphone5]) {
        //CGFloat screenHeight = [VersionControl sharedInstance].screenHeight;
        
        // Bouton Revivre
        CGRect frame = self.recupererEventsButton.frame;
        frame.origin.y += 88;  // change the location
        [self.recupererEventsButton setFrame:frame];
        
        // Dessin
        frame = self.creaImageView.frame;
        frame.size.height += 88;  // change the size
        [self.creaImageView setFrame:frame];
    }
    
    
    if([[VersionControl sharedInstance] supportIOS6]) {
        
        //SUBTITLE
        [self.titleLabel setFont:[[Config sharedInstance] defaultFontWithSize:14]];
        
        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
        [titleText addAttribute:NSFontAttributeName value:[[Config sharedInstance] defaultFontWithSize:18] range:NSMakeRange(0, 1)];
        [self.titleLabel setAttributedText:titleText];
        
    } else {
        
        //SUBTITLE
        TTTAttributedLabel *titleText = [[TTTAttributedLabel alloc] initWithFrame:self.titleLabel.frame];
        [titleText setFont:[[Config sharedInstance] defaultFontWithSize:14]];
        //[subTitleText setTextColor:[UIColor orangeColor]];
        
        [titleText setText:self.titleLabel.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            // 1 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:18 onRange:NSMakeRange(0, 1)];
            
            return mutableAttributedString;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setCreaImageView:nil];
    [self setRecupererEventsButton:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (IBAction)clicRecupererEvents:(id)sender {
    RevivreImportFBViewController *fbViewController = [[RevivreImportFBViewController alloc] initWithTimeLine:self.timeLineViewContoller];
    
    [self.navigationController pushViewController:fbViewController animated:YES];
}

@end
