//
//  TutorialViewController.m
//  Moment
//
//  Created by SkeletonGamer on 06/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "TutorialViewController.h"
#import "HomeViewController.h"
#import "Config.h"
#import "VersionControl.h"

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@interface TutorialViewController ()

@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) IBOutlet UIPageControl *pageControl;

@property(nonatomic) BOOL pageControlBeingUsed;

@property(strong, nonatomic) NSMutableArray *images;
@property(strong, nonatomic) UIButton *suivantPage1;
@property(strong, nonatomic) UIButton *suivantPage2;
@property(strong, nonatomic) UIButton *suivantPage3;
@property(strong, nonatomic) UIButton *letsgoButton;

@property (nonatomic, assign) NSInteger lastContentOffset;

@end

@implementation TutorialViewController

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize pageControlBeingUsed = _pageControlBeingUsed;
@synthesize images = _images;
@synthesize suivantPage1 = _suivantPage1;
@synthesize suivantPage2 = _suivantPage2;
@synthesize suivantPage3 = _suivantPage3;
@synthesize letsgoButton = _letsgoButton;
@synthesize lastContentOffset = _lastContentOffset;

- (id)initWithXib
{
    self = [super initWithNibName:@"TutorialViewController" bundle:nil];
    if(self) {
        //custom initialisation
        self.scrollView.delegate = self;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //CGSize screenSize = [[VersionControl sharedInstance] screenSize];
    BOOL supportIOS6 = [[VersionControl sharedInstance] supportIOS6];
    BOOL isIphone5 = [[VersionControl sharedInstance] isIphone5];
    
    //[self.navigationController.navigationBar setHidden:YES];
    
    self.pageControlBeingUsed = NO;
    
    //[self.letsgoButton setHidden:YES];
    
    [self setImages:[NSMutableArray array]];
    
    
    NSArray *backgrounds = [NSMutableArray arrayWithCapacity:4];
	
    if (isIphone5) {
        backgrounds = [NSArray arrayWithObjects:
                            [UIImage imageNamed:@"background_page1-568h"],
                            [UIImage imageNamed:@"background_page2-568h"],
                            [UIImage imageNamed:@"background_page3-568h"],
                            [UIImage imageNamed:@"background_page4-568h"],
                            nil];
    } else {
        backgrounds = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"background_page1"],
                             [UIImage imageNamed:@"background_page2"],
                             [UIImage imageNamed:@"background_page3"],
                             [UIImage imageNamed:@"background_page4"],
                             nil];
    }
    [self.images setArray:backgrounds];
    
    
    self.scrollView.frame = [[UIScreen mainScreen] bounds];
    
	for (int i = 0; i < self.images.count; i++) {
		CGRect frame;
		frame.origin.x = self.scrollView.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = self.scrollView.frame.size;
		
		UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
		subview.image = [self.images objectAtIndex:i];
		[self.scrollView addSubview:subview];
	}
	
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = self.images.count;
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.pageControl.numberOfPages, self.scrollView.frame.size.height);
    
    
    
    
    [self setSuivantPage1:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.suivantPage1 setBackgroundImage:[[UIImage imageNamed:@"add_photo_button.png"]
                                              stretchableImageWithLeftCapWidth:8.0f
                                              topCapHeight:0.0f]
                                    forState:UIControlStateNormal];
    [self.suivantPage1 setTitle:@"Suivant" forState:UIControlStateNormal];
    [self.suivantPage1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.suivantPage1.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.suivantPage1 setTag:1];
    [self.suivantPage1 addTarget:self action:@selector(goToPage:) forControlEvents:UIControlEventTouchDown];
    
    
    
    
    [self setSuivantPage2:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.suivantPage2 setBackgroundImage:[[UIImage imageNamed:@"add_photo_button.png"]
                                           stretchableImageWithLeftCapWidth:8.0f
                                           topCapHeight:0.0f]
                                 forState:UIControlStateNormal];
    [self.suivantPage2 setTitle:@"Suivant" forState:UIControlStateNormal];
    [self.suivantPage2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.suivantPage2.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.suivantPage2 setTag:2];
    [self.suivantPage2 addTarget:self action:@selector(goToPage:) forControlEvents:UIControlEventTouchDown];
    
    
    
    
    [self setSuivantPage3:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.suivantPage3 setBackgroundImage:[[UIImage imageNamed:@"add_photo_button.png"]
                                           stretchableImageWithLeftCapWidth:8.0f
                                           topCapHeight:0.0f]
                                 forState:UIControlStateNormal];
    [self.suivantPage3 setTitle:@"Suivant" forState:UIControlStateNormal];
    [self.suivantPage3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.suivantPage3.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.suivantPage3 setTag:3];
    [self.suivantPage3 addTarget:self action:@selector(goToPage:) forControlEvents:UIControlEventTouchDown];
    
    
    
    
    [self setLetsgoButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.letsgoButton setBackgroundImage:[[UIImage imageNamed:@"finish_tuto_button.png"]
                                           stretchableImageWithLeftCapWidth:8.0f
                                           topCapHeight:0.0f]
                                 forState:UIControlStateNormal];
    [self.letsgoButton setTitle:@"Terminer" forState:UIControlStateNormal];
    [self.letsgoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.letsgoButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.letsgoButton setTag:1000];
    [self.letsgoButton addTarget:self action:@selector(letsGo:) forControlEvents:UIControlEventTouchDown];
    
    
    /*int button_height_from_bottom = 0;
    
    if (isIphone5)
    {
        button_height_from_bottom = 125;
    } else {
        button_height_from_bottom = 51.5;
    }*/
    
    // 300 x 47
    
    self.suivantPage1.frame = CGRectMake((self.scrollView.frame.size.width * 1) - (self.scrollView.frame.size.width-10), self.scrollView.frame.size.height-51.5, 300.0, 47.0);
    self.suivantPage2.frame = CGRectMake((self.scrollView.frame.size.width * 2) - (self.scrollView.frame.size.width-10), self.scrollView.frame.size.height-51.5, 300.0, 47.0);
    self.suivantPage3.frame = CGRectMake((self.scrollView.frame.size.width * 3) - (self.scrollView.frame.size.width-10), self.scrollView.frame.size.height-51.5, 300.0, 47.0);
    
    //Position Bouton Let's Go
    //self.letsgoButton.frame = CGRectMake((self.scrollView.frame.size.width * self.pageControl.numberOfPages) - (self.scrollView.frame.size.width-77.5), self.scrollView.frame.size.height-button_height_from_bottom, 165.0, 34.0);
    self.letsgoButton.frame = CGRectMake((self.scrollView.frame.size.width * self.pageControl.numberOfPages) - (self.scrollView.frame.size.width-10), self.scrollView.frame.size.height-51.5, 300.0, 47.0);

    
    
    UILabel *titlePage1 = [[UILabel alloc] initWithFrame:CGRectMake(9, 12, 300, 60)];
    [titlePage1 setText:NSLocalizedString(@"TutorialViewController_titlePage1", nil)];
    
    if(supportIOS6) {
        
        [titlePage1 setBackgroundColor:[UIColor clearColor]];
        [titlePage1 setNumberOfLines:0];
        [titlePage1 setLineBreakMode:NSLineBreakByWordWrapping];
        [titlePage1 setTextAlignment:NSTextAlignmentCenter];
        [titlePage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [titlePage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titlePage1.text];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(10, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(12, 1)];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(19, 7)];
        [titlePage1 setAttributedText:text];
        
        [self.scrollView addSubview:titlePage1];
    } else {
        
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:titlePage1.frame];
        [tttLabel setBackgroundColor:[UIColor clearColor]];
        [tttLabel setNumberOfLines:0];
        [tttLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [tttLabel setTextAlignment:NSTextAlignmentCenter];
        [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [tttLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        [tttLabel setText:titlePage1.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(10, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(12, 1)];
            
            [cf updateTTTAttributedString:mutableAttributedString withColor:[UIColor orangeColor] onRange:NSMakeRange(19, 7)];
            
            return mutableAttributedString;
        }];
        
        [self.scrollView addSubview:tttLabel];
    }
    
    
    // Page 2
    UILabel *titlePage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 8, 12, 300, 60)];
    [titlePage2 setText:NSLocalizedString(@"TutorialViewController_titlePage2", nil)];
    
    if(supportIOS6) {
        
        [titlePage2 setBackgroundColor:[UIColor clearColor]];
        [titlePage2 setNumberOfLines:0];
        [titlePage2 setLineBreakMode:NSLineBreakByWordWrapping];
        [titlePage2 setTextAlignment:NSTextAlignmentCenter];
        [titlePage2 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [titlePage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titlePage2.text];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(titlePage2.text.length-1, 1)];
        [titlePage2 setAttributedText:text];
        
        [self.scrollView addSubview:titlePage2];
    } else {
        
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:titlePage2.frame];
        [tttLabel setBackgroundColor:[UIColor clearColor]];
        [tttLabel setNumberOfLines:0];
        [tttLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [tttLabel setTextAlignment:NSTextAlignmentCenter];
        [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [tttLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        [tttLabel setText:titlePage2.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(titlePage2.text.length-1, 1)];
            
            return mutableAttributedString;
        }];
        
        [self.scrollView addSubview:tttLabel];
    }
    
    
    
    
    //Page 3
    UILabel *titlePage3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 10, 12, 300, 60)];
    [titlePage3 setText:NSLocalizedString(@"TutorialViewController_titlePage3", nil)];
    
    if(supportIOS6) {
        
        [titlePage3 setBackgroundColor:[UIColor clearColor]];
        [titlePage3 setNumberOfLines:0];
        [titlePage3 setLineBreakMode:NSLineBreakByWordWrapping];
        [titlePage3 setTextAlignment:NSTextAlignmentCenter];
        [titlePage3 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [titlePage3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titlePage3.text];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(12, 1)];
        [titlePage3 setAttributedText:text];
        
        [self.scrollView addSubview:titlePage3];
    } else {
        
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:titlePage3.frame];
        [tttLabel setBackgroundColor:[UIColor clearColor]];
        [tttLabel setNumberOfLines:0];
        [tttLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [tttLabel setTextAlignment:NSTextAlignmentCenter];
        [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [tttLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        [tttLabel setText:titlePage3.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(12, 1)];
            
            return mutableAttributedString;
        }];
        
        [self.scrollView addSubview:tttLabel];
    }
    
    
    
    
    //Page 4
    UILabel *titlePage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 5, 12, 300, 60)];
    [titlePage4 setText:NSLocalizedString(@"TutorialViewController_titlePage4", nil)];
    
    if(supportIOS6) {
        
        [titlePage4 setBackgroundColor:[UIColor clearColor]];
        [titlePage4 setTextAlignment:NSTextAlignmentCenter];
        [titlePage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [titlePage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titlePage4.text];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(15, 3)];
        [titlePage4 setAttributedText:text];
        
        [self.scrollView addSubview:titlePage4];
    } else {
        
        TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:titlePage4.frame];
        [tttLabel setBackgroundColor:[UIColor clearColor]];
        [tttLabel setTextAlignment:NSTextAlignmentCenter];
        [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [tttLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        [tttLabel setText:titlePage4.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            Config *cf = [Config sharedInstance];
            
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(15, 3)];
            
            return mutableAttributedString;
        }];
        
        [self.scrollView addSubview:tttLabel];
    }
    
    
    
    
    UILabel *cadeauxPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 48, 375, 50, 20)];
    [cadeauxPage4 setBackgroundColor:[UIColor clearColor]];
    [cadeauxPage4 setTextAlignment:NSTextAlignmentCenter];
    [cadeauxPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:9]];
    [cadeauxPage4 setText:NSLocalizedString(@"TutorialViewController_cadeauxPage4", nil)];
    [cadeauxPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    [self.scrollView addSubview:cadeauxPage4];
    
    UILabel *cagnottePage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 130, 375, 60, 20)];
    [cagnottePage4 setBackgroundColor:[UIColor clearColor]];
    [cagnottePage4 setTextAlignment:NSTextAlignmentCenter];
    [cagnottePage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:9]];
    [cagnottePage4 setText:NSLocalizedString(@"TutorialViewController_cagnottePage4", nil)];
    [cagnottePage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    [self.scrollView addSubview:cagnottePage4];
    
    UILabel *comptesPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 215, 375, 60, 20)];
    [comptesPage4 setBackgroundColor:[UIColor clearColor]];
    [comptesPage4 setTextAlignment:NSTextAlignmentCenter];
    [comptesPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:9]];
    [comptesPage4 setText:NSLocalizedString(@"TutorialViewController_comptesPage4", nil)];
    [comptesPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    [self.scrollView addSubview:comptesPage4];
    
    
    if (isIphone5)
    {
        //Page 1
        UILabel *basketPage1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 132, 125, 40)];
        [basketPage1 setBackgroundColor:[UIColor clearColor]];
        [basketPage1 setTextAlignment:NSTextAlignmentCenter];
        [basketPage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [basketPage1 setText:NSLocalizedString(@"TutorialViewController_basketPage1", nil)];
        [basketPage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:basketPage1];
        
        UILabel *annivPage1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 368, 300, 40)];
        [annivPage1 setBackgroundColor:[UIColor clearColor]];
        [annivPage1 setTextAlignment:NSTextAlignmentCenter];
        [annivPage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [annivPage1 setText:NSLocalizedString(@"TutorialViewController_annivPage1", nil)];
        [annivPage1 setTextColor:[UIColor whiteColor]];
        [annivPage1 setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [annivPage1 setShadowOffset:CGSizeMake(1.0, 1.0)];
        [self.scrollView addSubview:annivPage1];
        
        UILabel *vacNicePage1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 473, 125, 40)];
        [vacNicePage1 setBackgroundColor:[UIColor clearColor]];
        [vacNicePage1 setTextAlignment:NSTextAlignmentCenter];
        [vacNicePage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [vacNicePage1 setText:NSLocalizedString(@"TutorialViewController_vacNicePage1", nil)];
        [vacNicePage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:vacNicePage1];
        
        
        
        
        //Page 2
        UILabel *parMarcPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 20, 123, 100, 20)];
        [parMarcPage2 setText:NSLocalizedString(@"TutorialViewController_parMarcPage2", nil)];
            
        [parMarcPage2 setBackgroundColor:[UIColor clearColor]];
        [parMarcPage2 setTextAlignment:NSTextAlignmentCenter];
        [parMarcPage2 setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
        [parMarcPage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [parMarcPage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-8.25))];
            
        NSMutableAttributedString *parMarcPage2AttributedString = [[NSMutableAttributedString alloc] initWithString:parMarcPage2.text];
        [parMarcPage2AttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:13.0] range:NSMakeRange(0, 1)];
        [parMarcPage2AttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:13.0] range:NSMakeRange(4, 1)];
        [parMarcPage2AttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:13.0] range:NSMakeRange(9, 1)];
        [parMarcPage2 setAttributedText:parMarcPage2AttributedString];
            
        [self.scrollView addSubview:parMarcPage2];
        
        
        
        UILabel *photoDatePage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 153, 105, 100, 20)];
        [photoDatePage2 setBackgroundColor:[UIColor clearColor]];
        [photoDatePage2 setTextAlignment:NSTextAlignmentCenter];
        [photoDatePage2 setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
        [photoDatePage2 setText:NSLocalizedString(@"TutorialViewController_photoDatePage2", nil)];
        [photoDatePage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [photoDatePage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-8.25))];
        [self.scrollView addSubview:photoDatePage2];
        
        UILabel *downloadPhotoPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 20, 425, 300, 75)];
        [downloadPhotoPage2 setBackgroundColor:[UIColor clearColor]];
        [downloadPhotoPage2 setNumberOfLines:0];
        [downloadPhotoPage2 setLineBreakMode:NSLineBreakByWordWrapping];
        [downloadPhotoPage2 setTextAlignment:NSTextAlignmentCenter];
        [downloadPhotoPage2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:17.0]];
        [downloadPhotoPage2 setText:NSLocalizedString(@"TutorialViewController_downloadPhotoPage2", nil)];
        [downloadPhotoPage2 setTextColor:[UIColor darkGrayColor]];
        [downloadPhotoPage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(6))];
        [self.scrollView addSubview:downloadPhotoPage2];
        
        
        
        
        
        //Page 3
        UILabel *message1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 117, 200, 20)];
        [message1Page3 setBackgroundColor:[UIColor clearColor]];
        [message1Page3 setTextAlignment:NSTextAlignmentLeft];
        [message1Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message1Page3 setText:NSLocalizedString(@"TutorialViewController_message1Page3", nil)];
        [message1Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message1Page3];
        
        UILabel *dateMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 143, 150, 20)];
        [dateMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage1Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage1Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage1Page3", nil)];
        [dateMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:dateMessage1Page3];
        
        UILabel *hourMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 143, 50, 20)];
        [hourMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage1Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage1Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage1Page3", nil)];
        [hourMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:hourMessage1Page3];
        
        
        UILabel *message2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 207, 200, 20)];
        [message2Page3 setBackgroundColor:[UIColor clearColor]];
        [message2Page3 setTextAlignment:NSTextAlignmentLeft];
        [message2Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message2Page3 setText:NSLocalizedString(@"TutorialViewController_message2Page3", nil)];
        [message2Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message2Page3];
        
        UILabel *dateMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 233, 150, 20)];
        [dateMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage2Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage2Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage2Page3", nil)];
        [dateMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage2Page3];
        
        UILabel *hourMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 233, 50, 20)];
        [hourMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage2Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage2Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage2Page3", nil)];
        [hourMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage2Page3];
        
        
        UILabel *message3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 285, 300, 20)];
        [message3Page3 setBackgroundColor:[UIColor clearColor]];
        [message3Page3 setNumberOfLines:0];
        [message3Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message3Page3 setTextAlignment:NSTextAlignmentLeft];
        [message3Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message3Page3 setText:NSLocalizedString(@"TutorialViewController_message3Page3", nil)];
        [message3Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message3Page3];
        
        UILabel *dateMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 310, 150, 20)];
        [dateMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage3Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage3Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage3Page3", nil)];
        [dateMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage3Page3];
        
        UILabel *hourMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 310, 50, 20)];
        [hourMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage3Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage3Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage3Page3", nil)];
        [hourMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage3Page3];
        
        
        UILabel *message4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 362, 300, 20)];
        [message4Page3 setBackgroundColor:[UIColor clearColor]];
        [message4Page3 setNumberOfLines:0];
        [message4Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message4Page3 setTextAlignment:NSTextAlignmentLeft];
        [message4Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message4Page3 setText:NSLocalizedString(@"TutorialViewController_message4Page3", nil)];
        [message4Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message4Page3];
        
        UILabel *dateMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 387, 150, 20)];
        [dateMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage4Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage4Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage4Page3", nil)];
        [dateMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage4Page3];
        
        UILabel *hourMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 387, 50, 20)];
        [hourMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage4Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage4Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage4Page3", nil)];
        [hourMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage4Page3];
        
        
        UILabel *message5Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 447, 300, 20)];
        [message5Page3 setBackgroundColor:[UIColor clearColor]];
        [message5Page3 setTextAlignment:NSTextAlignmentLeft];
        [message5Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message5Page3 setText:NSLocalizedString(@"TutorialViewController_message5Page3", nil)];
        [message5Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message5Page3];
        
        UILabel *dateMessage5Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 474, 150, 20)];
        [dateMessage5Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage5Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage5Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage5Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage5Page3", nil)];
        [dateMessage5Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:dateMessage5Page3];
        
        UILabel *hourMessage5Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 474, 50, 20)];
        [hourMessage5Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage5Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage5Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage5Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage5Page3", nil)];
        [hourMessage5Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:hourMessage5Page3];
        
        
        
        
        //Page 4
        UILabel *facebookPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 60, 110, 300, 20)];
        [facebookPage4 setText:NSLocalizedString(@"TutorialViewController_facebookPage4", nil)];
            
        [facebookPage4 setBackgroundColor:[UIColor clearColor]];
        [facebookPage4 setTextAlignment:NSTextAlignmentLeft];
        [facebookPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:11.0]];
        [facebookPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [facebookPage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-4))];
            
        NSMutableAttributedString *facebookPage4AttributedString = [[NSMutableAttributedString alloc] initWithString:facebookPage4.text];
        [facebookPage4AttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:16.0] range:NSMakeRange(0, 1)];
        [facebookPage4AttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, 1)];
        [facebookPage4AttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(16, 1)];
        [facebookPage4 setAttributedText:facebookPage4AttributedString];
            
        [self.scrollView addSubview:facebookPage4];
        
        
        
        
        
        UILabel *lieuPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 205, 196, 100, 24)];
        [lieuPage4 setText:NSLocalizedString(@"TutorialViewController_lieuPage4", nil)];
            
        [lieuPage4 setBackgroundColor:[UIColor clearColor]];
        [lieuPage4 setTextAlignment:NSTextAlignmentLeft];
        [lieuPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [lieuPage4 setTextColor:[UIColor whiteColor]];
        [lieuPage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
            
        NSMutableAttributedString *lieuPage4AttributedString = [[NSMutableAttributedString alloc] initWithString:lieuPage4.text];
        [lieuPage4AttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:19.0] range:NSMakeRange(0, 1)];
        [lieuPage4 setAttributedText:lieuPage4AttributedString];
        [lieuPage4 setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
        [lieuPage4 setShadowOffset:CGSizeMake(2.0, 2.0)];
            
        [self.scrollView addSubview:lieuPage4];
        
        
        
        
        UILabel *placePage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 117, 215, 175, 20)];
        [placePage4 setBackgroundColor:[UIColor clearColor]];
        [placePage4 setTextAlignment:NSTextAlignmentRight];
        [placePage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:12]];
        [placePage4 setText:NSLocalizedString(@"TutorialViewController_placePage4", nil)];
        [placePage4 setTextColor:[UIColor whiteColor]];
        [placePage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
        [self.scrollView addSubview:placePage4];
        
        
        UILabel *addressPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 70, 270, 245, 20)];
        [addressPage4 setText:NSLocalizedString(@"TutorialViewController_addressPage4", nil)];
            
        [addressPage4 setBackgroundColor:[UIColor clearColor]];
        [addressPage4 setTextAlignment:NSTextAlignmentLeft];
        [addressPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:8.0]];
        [addressPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [addressPage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
            
        NSMutableAttributedString *addressPage4AttributedText = [[NSMutableAttributedString alloc] initWithString:addressPage4.text];
        [addressPage4AttributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:12.0] range:NSMakeRange(0, 2)];
        [addressPage4AttributedText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:12.0] range:NSMakeRange(19, 7)];
        [addressPage4 setAttributedText:addressPage4AttributedText];
            
        [self.scrollView addSubview:addressPage4];
    } else {
        
        //Page 1
        UILabel *basketPage1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 120, 125, 40)];
        [basketPage1 setBackgroundColor:[UIColor clearColor]];
        [basketPage1 setTextAlignment:NSTextAlignmentCenter];
        [basketPage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [basketPage1 setText:NSLocalizedString(@"TutorialViewController_basketPage1", nil)];
        [basketPage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:basketPage1];
        
        UILabel *annivPage1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 355, 300, 40)];
        [annivPage1 setBackgroundColor:[UIColor clearColor]];
        [annivPage1 setTextAlignment:NSTextAlignmentCenter];
        [annivPage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [annivPage1 setText:NSLocalizedString(@"TutorialViewController_annivPage1", nil)];
        [annivPage1 setTextColor:[UIColor whiteColor]];
        [annivPage1 setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [annivPage1 setShadowOffset:CGSizeMake(1.0, 1.0)];
        [self.scrollView addSubview:annivPage1];
        
        
        
        
        //Page 2
        UILabel *parMarcPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 28, 95, 100, 20)];
        [parMarcPage2 setText:NSLocalizedString(@"TutorialViewController_parMarcPage2", nil)];
        
        if(supportIOS6) {
            
            [parMarcPage2 setBackgroundColor:[UIColor clearColor]];
            [parMarcPage2 setTextAlignment:NSTextAlignmentCenter];
            [parMarcPage2 setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
            [parMarcPage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
            [parMarcPage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-8.25))];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:parMarcPage2.text];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:13.0] range:NSMakeRange(0, 1)];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:13.0] range:NSMakeRange(4, 1)];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:13.0] range:NSMakeRange(9, 1)];
            [parMarcPage2 setAttributedText:text];
            
            [self.scrollView addSubview:parMarcPage2];
        } else {
            
            TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:parMarcPage2.frame];
            [tttLabel setBackgroundColor:[UIColor clearColor]];
            [tttLabel setTextAlignment:NSTextAlignmentCenter];
            [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
            [tttLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
            [tttLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-8.25))];
            
            [tttLabel setText:parMarcPage2.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                Config *cf = [Config sharedInstance];
                
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:13.0 onRange:NSMakeRange(0, 1)];
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:13.0 onRange:NSMakeRange(4, 1)];
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:13.0 onRange:NSMakeRange(9, 1)];
                
                return mutableAttributedString;
            }];
            
            [self.scrollView addSubview:tttLabel];
        }
        
        
        
        UILabel *photoDatePage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 152, 78, 100, 20)];
        [photoDatePage2 setBackgroundColor:[UIColor clearColor]];
        [photoDatePage2 setTextAlignment:NSTextAlignmentCenter];
        [photoDatePage2 setFont:[UIFont fontWithName:@"Numans-Regular" size:10.0]];
        [photoDatePage2 setText:NSLocalizedString(@"TutorialViewController_photoDatePage2", nil)];
        [photoDatePage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [photoDatePage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-8.25))];
        [self.scrollView addSubview:photoDatePage2];
        
        UILabel *downloadPhotoPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 20, 357, 300, 75)];
        [downloadPhotoPage2 setBackgroundColor:[UIColor clearColor]];
        [downloadPhotoPage2 setNumberOfLines:0];
        [downloadPhotoPage2 setLineBreakMode:NSLineBreakByWordWrapping];
        [downloadPhotoPage2 setTextAlignment:NSTextAlignmentCenter];
        [downloadPhotoPage2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:12.0]];
        [downloadPhotoPage2 setText:NSLocalizedString(@"TutorialViewController_downloadPhotoPage2", nil)];
        [downloadPhotoPage2 setTextColor:[UIColor whiteColor]];
        [downloadPhotoPage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5))];
        [self.scrollView addSubview:downloadPhotoPage2];
        
        
        
        //Page 3
        UILabel *message1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 102, 200, 20)];
        [message1Page3 setBackgroundColor:[UIColor clearColor]];
        [message1Page3 setTextAlignment:NSTextAlignmentLeft];
        [message1Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message1Page3 setText:NSLocalizedString(@"TutorialViewController_message1Page3", nil)];
        [message1Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message1Page3];
        
        UILabel *dateMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 128, 150, 20)];
        [dateMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage1Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage1Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage1Page3", nil)];
        [dateMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:dateMessage1Page3];
        
        UILabel *hourMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 128, 50, 20)];
        [hourMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage1Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage1Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage1Page3", nil)];
        [hourMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:hourMessage1Page3];
        
        
        UILabel *message2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 192, 200, 20)];
        [message2Page3 setBackgroundColor:[UIColor clearColor]];
        [message2Page3 setTextAlignment:NSTextAlignmentLeft];
        [message2Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message2Page3 setText:NSLocalizedString(@"TutorialViewController_message2Page3", nil)];
        [message2Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message2Page3];
        
        UILabel *dateMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 218, 150, 20)];
        [dateMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage2Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage2Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage2Page3", nil)];
        [dateMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage2Page3];
        
        UILabel *hourMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 218, 50, 20)];
        [hourMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage2Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage2Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage2Page3", nil)];
        [hourMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage2Page3];
        
        
        UILabel *message3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 280, 300, 20)];
        [message3Page3 setBackgroundColor:[UIColor clearColor]];
        [message3Page3 setNumberOfLines:0];
        [message3Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message3Page3 setTextAlignment:NSTextAlignmentLeft];
        [message3Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message3Page3 setText:NSLocalizedString(@"TutorialViewController_message3Page3", nil)];
        [message3Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message3Page3];
        
        UILabel *dateMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 305, 150, 20)];
        [dateMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage3Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage3Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage3Page3", nil)];
        [dateMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage3Page3];
        
        UILabel *hourMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 305, 50, 20)];
        [hourMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage3Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage3Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage3Page3", nil)];
        [hourMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage3Page3];
        
        
        UILabel *message4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 362, 300, 20)];
        [message4Page3 setBackgroundColor:[UIColor clearColor]];
        [message4Page3 setNumberOfLines:0];
        [message4Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message4Page3 setTextAlignment:NSTextAlignmentLeft];
        [message4Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message4Page3 setText:NSLocalizedString(@"TutorialViewController_message4Page3", nil)];
        [message4Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message4Page3];
        
        UILabel *dateMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 387, 150, 20)];
        [dateMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage4Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage4Page3 setText:NSLocalizedString(@"TutorialViewController_dateMessage4Page3", nil)];
        [dateMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage4Page3];
        
        UILabel *hourMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 387, 50, 20)];
        [hourMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage4Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage4Page3 setText:NSLocalizedString(@"TutorialViewController_hourMessage4Page3", nil)];
        [hourMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage4Page3];
        
        
        
        
        //Page 4
        UILabel *facebookPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 60, 100, 300, 20)];
        [facebookPage4 setText:NSLocalizedString(@"TutorialViewController_facebookPage4", nil)];
        
        if(supportIOS6) {
            
            [facebookPage4 setBackgroundColor:[UIColor clearColor]];
            [facebookPage4 setTextAlignment:NSTextAlignmentLeft];
            [facebookPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:11.0]];
            [facebookPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
            [facebookPage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-4))];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:facebookPage4.text];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:16.0] range:NSMakeRange(0, 1)];
            [text addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, 1)];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:14.0] range:NSMakeRange(16, 1)];
            [facebookPage4 setAttributedText:text];
            
            [self.scrollView addSubview:facebookPage4];
        } else {
            
            TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:facebookPage4.frame];
            [tttLabel setBackgroundColor:[UIColor clearColor]];
            [tttLabel setTextAlignment:NSTextAlignmentLeft];
            [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:11.0]];
            [tttLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
            [tttLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-4))];
            
            [tttLabel setText:facebookPage4.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                Config *cf = [Config sharedInstance];
                
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:16.0 onRange:NSMakeRange(0, 1)];
                [cf updateTTTAttributedString:mutableAttributedString withColor:[UIColor orangeColor] onRange:NSMakeRange(0, 1)];
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:14.0 onRange:NSMakeRange(16, 1)];
                
                return mutableAttributedString;
            }];
            
            [self.scrollView addSubview:tttLabel];
        }
        
        
        
        UILabel *lieuPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 205, 192, 100, 24)];
        [lieuPage4 setText:NSLocalizedString(@"TutorialViewController_lieuPage4", nil)];
        
        if(supportIOS6) {
            
            [lieuPage4 setBackgroundColor:[UIColor clearColor]];
            [lieuPage4 setTextAlignment:NSTextAlignmentLeft];
            [lieuPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:11.0]];
            [lieuPage4 setTextColor:[UIColor whiteColor]];
            [lieuPage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:lieuPage4.text];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:19.0] range:NSMakeRange(0, 1)];
            [lieuPage4 setAttributedText:text];
            [lieuPage4 setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
            [lieuPage4 setShadowOffset:CGSizeMake(2.0, 2.0)];
            
            [self.scrollView addSubview:lieuPage4];
        } else {
            
            TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:lieuPage4.frame];
            [tttLabel setBackgroundColor:[UIColor clearColor]];
            [tttLabel setTextAlignment:NSTextAlignmentLeft];
            [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:11.0]];
            [tttLabel setTextColor:[UIColor whiteColor]];
            [tttLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
            
            [tttLabel setText:lieuPage4.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                Config *cf = [Config sharedInstance];
                
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:19.0 onRange:NSMakeRange(0, 1)];
                
                return mutableAttributedString;
            }];
            [tttLabel setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
            [tttLabel setShadowOffset:CGSizeMake(2.0, 2.0)];
            
            [self.scrollView addSubview:tttLabel];
        }
        
        UILabel *placePage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 117, 210, 175, 20)];
        [placePage4 setBackgroundColor:[UIColor clearColor]];
        [placePage4 setTextAlignment:NSTextAlignmentRight];
        [placePage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:12]];
        [placePage4 setText:NSLocalizedString(@"TutorialViewController_placePage4", nil)];
        [placePage4 setTextColor:[UIColor whiteColor]];
        [placePage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
        [self.scrollView addSubview:placePage4];
        
        
        UILabel *addressPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 70, 265, 245, 20)];
        [addressPage4 setText:NSLocalizedString(@"TutorialViewController_addressPage4", nil)];
        
        if(supportIOS6) {
            
            [addressPage4 setBackgroundColor:[UIColor clearColor]];
            [addressPage4 setTextAlignment:NSTextAlignmentLeft];
            [addressPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:8.0]];
            [addressPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
            [addressPage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:addressPage4.text];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:12.0] range:NSMakeRange(0, 2)];
            [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:12.0] range:NSMakeRange(19, 7)];
            [addressPage4 setAttributedText:text];
            
            [self.scrollView addSubview:addressPage4];
        } else {
            
            TTTAttributedLabel *tttLabel = [[TTTAttributedLabel alloc] initWithFrame:addressPage4.frame];
            [tttLabel setBackgroundColor:[UIColor clearColor]];
            [tttLabel setTextAlignment:NSTextAlignmentLeft];
            [tttLabel setFont:[UIFont fontWithName:@"Numans-Regular" size:8.0]];
            [tttLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
            [tttLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
            
            [tttLabel setText:addressPage4.text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
                
                Config *cf = [Config sharedInstance];
                
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:12.0 onRange:NSMakeRange(0, 2)];
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:12.0 onRange:NSMakeRange(19, 7)];
                
                return mutableAttributedString;
            }];
            
            [self.scrollView addSubview:tttLabel];
        }
    }    
    
    [self.scrollView addSubview:self.suivantPage1];
    [self.scrollView addSubview:self.suivantPage2];
    [self.scrollView addSubview:self.suivantPage3];
    [self.scrollView addSubview:self.letsgoButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!self.pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
		self.pageControl.currentPage = page;
        
        self.pageControlBeingUsed = NO;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageControlBeingUsed = NO;
}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	self.pageControlBeingUsed = YES;
}

/*- (void)nextPage
{
    int nextPage = self.pageControl.currentPage+1;
    
    CGPoint offset = CGPointMake(nextPage * self.scrollView.frame.size.width, 0);
    [self.scrollView setContentOffset:offset animated:YES];
    
    self.pageControl.currentPage = nextPage;
}*/

- (void)goToPage:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *button = (UIButton *)sender;
        
        NSInteger pageDestination = [button tag];
        CGPoint offset = CGPointMake(pageDestination * self.scrollView.frame.size.width, 0);
        [self.scrollView setContentOffset:offset animated:YES];
        
        self.pageControl.currentPage = pageDestination;
        
        self.pageControlBeingUsed = YES;
    }
}

- (void)letsGo:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *pressedButton = (UIButton *)sender;
        
        if (pressedButton.tag == 1000)
        {
            //Premier lancement de l'application terminé
            
            //[self showHomeViewAnimated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
