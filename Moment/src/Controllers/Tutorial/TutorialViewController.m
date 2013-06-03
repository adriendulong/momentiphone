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
#import "UIImage+Alpha.h"
#import "VersionControl.h"

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@interface TutorialViewController ()

@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *imagePageControl;

@property(nonatomic) BOOL pageControlBeingUsed;

@property(strong, nonatomic) NSMutableArray *images;
@property(strong, nonatomic) UIButton *letsgoButton;

@property (strong, nonatomic) IBOutlet UIButton *page1;
@property (strong, nonatomic) IBOutlet UIButton *page2;
@property (strong, nonatomic) IBOutlet UIButton *page3;
@property (strong, nonatomic) IBOutlet UIButton *page4;

@property (nonatomic, assign) NSInteger lastContentOffset;

@end

@implementation TutorialViewController

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
    CGSize screenSize = [[VersionControl sharedInstance] screenSize];
    BOOL supportIOS6 = [[VersionControl sharedInstance] supportIOS6];
    BOOL isIphone5 = [[VersionControl sharedInstance] isIphone5];
    
    //[self.navigationController.navigationBar setHidden:YES];
    
    self.pageControlBeingUsed = NO;
    
    //[self.letsgoButton setHidden:YES];
    
    [self setImages:[NSMutableArray array]];
	
    if (isIphone5)
    {
        NSLog(@"iPhone 5");
        //NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];
        NSArray *images5 = [NSArray arrayWithObjects:
                            [UIImage imageNamed:@"walkthoughtv2_iphone5_part1"],
                            [UIImage imageNamed:@"walkthoughtv2_iphone5_part2"],
                            [UIImage imageNamed:@"walkthoughtv2_iphone5_part3"],
                            [UIImage imageNamed:@"walkthoughtv2_iphone5_part4"],
                            nil];
        
        [self.images setArray:images5];
    } else {
        NSLog(@"iPhone 4/4S or 3GS");
        NSArray *images4S = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"walkthoughtv2_iphone4_part1"],
                             [UIImage imageNamed:@"walkthoughtv2_iphone4_part2"],
                             [UIImage imageNamed:@"walkthoughtv2_iphone4_part3"],
                             [UIImage imageNamed:@"walkthoughtv2_iphone4_part4"],
                             nil];
        
        [self.images setArray:images4S];
    }
    
    //NSLog(@"scrollView.frame.size.height = %f", self.scrollView.frame.size.height);
    //NSLog(@"[[UIScreen mainScreen] bounds] = %@",  NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    
    
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
    
    
    [self setLetsgoButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.letsgoButton addTarget:self action:@selector(letsGo:) forControlEvents:UIControlEventTouchDown];
    
    int button_height_from_bottom = 0;
    
    if (isIphone5)
    {
        button_height_from_bottom = 125;
    } else {
        button_height_from_bottom = 45;
    }
    
    //Position Bouton Let's Go
    self.letsgoButton.frame = CGRectMake((self.scrollView.frame.size.width * self.pageControl.numberOfPages) - (self.scrollView.frame.size.width-82), self.scrollView.frame.size.height-button_height_from_bottom, 165.0, 34.0);
    
    //Position du contrôleur de page Orange
    self.imagePageControl.center = CGPointMake(screenSize.width/2, screenSize.height-29);
    self.page1.center = CGPointMake(64, screenSize.height-29);
    self.page2.center = CGPointMake(129, screenSize.height-29);
    self.page3.center = CGPointMake(196, screenSize.height-29);
    self.page4.center = CGPointMake(262, screenSize.height-29);
    
    
    
    
    
    UILabel *titlePage1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, 300, 60)];
    [titlePage1 setText:@"BIENVENUE !\nCECI EST VOTRE TIMELINE DE MOMENTS,\nCRÉEZ ET GÉREZ LES SIMPLEMENT"];
    
    if(supportIOS6) {
        
        [titlePage1 setBackgroundColor:[UIColor clearColor]];
        [titlePage1 setNumberOfLines:0];
        [titlePage1 setLineBreakMode:NSLineBreakByWordWrapping];
        [titlePage1 setTextAlignment:NSTextAlignmentCenter];
        [titlePage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [titlePage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titlePage1.text];
        //[text addAttribute:NSForegroundColorAttributeName value:(id) range:NSMakeRange(NSUInteger loc, NSUInteger len)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(10, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(12, 1)];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(39, 7)];
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
            
            // 1 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(10, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(12, 1)];
            
            // Autres Lettres Font
            //[cf updateTTTAttributedString:mutableAttributedString withFontSize:12.0 onRange:NSMakeRange(1, 38)];
            
            // 3 first Lettre Couleurs
            [cf updateTTTAttributedString:mutableAttributedString withColor:[UIColor orangeColor] onRange:NSMakeRange(39, 7)];
            
            // Autres Lettres Couleurs
            //[cf updateTTTAttributedString:mutableAttributedString withColor:textColor onRange:NSMakeRange(1, taille-1)];
            
            return mutableAttributedString;
        }];
        
        [self.scrollView addSubview:tttLabel];
    }
    
    
    // Page 2
    UILabel *titlePage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 5, 12, 300, 60)];
    [titlePage2 setText:@"RÉCUPÉREZ ENFIN TOUTES VOS PHOTOS\nAPRÈS VOS MOMENTS ENTRE AMIS !"];
    
    if(supportIOS6) {
        
        [titlePage2 setBackgroundColor:[UIColor clearColor]];
        [titlePage2 setNumberOfLines:0];
        [titlePage2 setLineBreakMode:NSLineBreakByWordWrapping];
        [titlePage2 setTextAlignment:NSTextAlignmentCenter];
        [titlePage2 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [titlePage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titlePage2.text];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(63, 1)];
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
            
            // 1 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(63, 1)];
            
            return mutableAttributedString;
        }];
        
        [self.scrollView addSubview:tttLabel];
    }
    
    
    
    
    //Page 3
    UILabel *titlePage3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 5, 12, 300, 60)];
    [titlePage3 setText:@"PRÉPAREZ, ORGANISEZ, ECHANGEZ\nDURANT VOS MOMENTS ENTRE PROCHES."];
    
    if(supportIOS6) {
        
        [titlePage3 setBackgroundColor:[UIColor clearColor]];
        [titlePage3 setNumberOfLines:0];
        [titlePage3 setLineBreakMode:NSLineBreakByWordWrapping];
        [titlePage3 setTextAlignment:NSTextAlignmentCenter];
        [titlePage3 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [titlePage3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titlePage3.text];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(0, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(10, 1)];
        [text addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Numans-Regular" size:17.0] range:NSMakeRange(21, 1)];
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
            
            // 1 first Lettre Font
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(0, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(10, 1)];
            [cf updateTTTAttributedString:mutableAttributedString withFontSize:17.0 onRange:NSMakeRange(21, 1)];
            
            return mutableAttributedString;
        }];
        
        [self.scrollView addSubview:tttLabel];
    }
    
    
    
    
    //Page 4
    UILabel *titlePage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 5, 12, 300, 60)];
    [titlePage4 setText:@"ET ENCORE PLUS ..."];
    
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
            
            // 1 first Lettre Font
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
    [cadeauxPage4 setText:@"CADEAUX"];
    [cadeauxPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    [self.scrollView addSubview:cadeauxPage4];
    
    UILabel *cagnottePage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 130, 375, 60, 20)];
    [cagnottePage4 setBackgroundColor:[UIColor clearColor]];
    [cagnottePage4 setTextAlignment:NSTextAlignmentCenter];
    [cagnottePage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:9]];
    [cagnottePage4 setText:@"CAGNOTTE"];
    [cagnottePage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    [self.scrollView addSubview:cagnottePage4];
    
    UILabel *comptesPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 215, 375, 60, 20)];
    [comptesPage4 setBackgroundColor:[UIColor clearColor]];
    [comptesPage4 setTextAlignment:NSTextAlignmentCenter];
    [comptesPage4 setFont:[UIFont fontWithName:@"Numans-Regular" size:9]];
    [comptesPage4 setText:@"COMPTES"];
    [comptesPage4 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
    [self.scrollView addSubview:comptesPage4];
    
    
    if (isIphone5)
    {
        //Page 1
        UILabel *basketPage1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 132, 125, 40)];
        [basketPage1 setBackgroundColor:[UIColor clearColor]];
        [basketPage1 setTextAlignment:NSTextAlignmentCenter];
        [basketPage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [basketPage1 setText:@"Basket entre potes"];
        [basketPage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:basketPage1];
        
        UILabel *annivPage1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 368, 300, 40)];
        [annivPage1 setBackgroundColor:[UIColor clearColor]];
        [annivPage1 setTextAlignment:NSTextAlignmentCenter];
        [annivPage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [annivPage1 setText:@"Anniversaire 23 ans de Paul"];
        [annivPage1 setTextColor:[UIColor whiteColor]];
        [annivPage1 setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [annivPage1 setShadowOffset:CGSizeMake(1.0, 1.0)];
        [self.scrollView addSubview:annivPage1];
        
        UILabel *vacNicePage1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 473, 125, 40)];
        [vacNicePage1 setBackgroundColor:[UIColor clearColor]];
        [vacNicePage1 setTextAlignment:NSTextAlignmentCenter];
        [vacNicePage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [vacNicePage1 setText:@"Vacances à Nice"];
        [vacNicePage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:vacNicePage1];
        
        
        
        
        //Page 2
        UILabel *parMarcPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 20, 123, 100, 20)];
        [parMarcPage2 setText:@"PAR MARC N."];
            
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
        [photoDatePage2 setText:@"12/10/12 21:04"];
        [photoDatePage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [photoDatePage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-8.25))];
        [self.scrollView addSubview:photoDatePage2];
        
        UILabel *downloadPhotoPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 20, 425, 300, 75)];
        [downloadPhotoPage2 setBackgroundColor:[UIColor clearColor]];
        [downloadPhotoPage2 setNumberOfLines:0];
        [downloadPhotoPage2 setLineBreakMode:NSLineBreakByWordWrapping];
        [downloadPhotoPage2 setTextAlignment:NSTextAlignmentCenter];
        [downloadPhotoPage2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:17.0]];
        [downloadPhotoPage2 setText:@"Téléchargez toutes les photos\ndirectement sur votre téléphone !"];
        [downloadPhotoPage2 setTextColor:[UIColor darkGrayColor]];
        [downloadPhotoPage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(6))];
        [self.scrollView addSubview:downloadPhotoPage2];
        
        
        
        
        
        //Page 3
        UILabel *message1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 117, 200, 20)];
        [message1Page3 setBackgroundColor:[UIColor clearColor]];
        [message1Page3 setTextAlignment:NSTextAlignmentLeft];
        [message1Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message1Page3 setText:@"JE RAMÈNE DES CHIPS ?"];
        [message1Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message1Page3];
        
        UILabel *dateMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 143, 150, 20)];
        [dateMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage1Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage1Page3 setText:@"Nico F. 3 août 2013"];
        [dateMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:dateMessage1Page3];
        
        UILabel *hourMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 143, 50, 20)];
        [hourMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage1Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage1Page3 setText:@"19:47"];
        [hourMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:hourMessage1Page3];
        
        
        UILabel *message2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 207, 200, 20)];
        [message2Page3 setBackgroundColor:[UIColor clearColor]];
        [message2Page3 setTextAlignment:NSTextAlignmentLeft];
        [message2Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message2Page3 setText:@"JE SAIS PAS JE M'OCCUPE DU PLAT.."];
        [message2Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message2Page3];
        
        UILabel *dateMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 233, 150, 20)];
        [dateMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage2Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage2Page3 setText:@"Julien V. 3 août 2013"];
        [dateMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage2Page3];
        
        UILabel *hourMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 233, 50, 20)];
        [hourMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage2Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage2Page3 setText:@"19:49"];
        [hourMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage2Page3];
        
        
        UILabel *message3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 285, 300, 20)];
        [message3Page3 setBackgroundColor:[UIColor clearColor]];
        [message3Page3 setNumberOfLines:0];
        [message3Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message3Page3 setTextAlignment:NSTextAlignmentLeft];
        [message3Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message3Page3 setText:@"MOI J'ARRIVE À 21H ! ET POUR LES CHIPS\nPREND TOUJOURS ON SAIT JAMAIS."];
        [message3Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message3Page3];
        
        UILabel *dateMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 310, 150, 20)];
        [dateMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage3Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage3Page3 setText:@"Adrien D. 3 août 2013"];
        [dateMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage3Page3];
        
        UILabel *hourMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 310, 50, 20)];
        [hourMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage3Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage3Page3 setText:@"19:55"];
        [hourMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage3Page3];
        
        
        UILabel *message4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 362, 300, 20)];
        [message4Page3 setBackgroundColor:[UIColor clearColor]];
        [message4Page3 setNumberOfLines:0];
        [message4Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message4Page3 setTextAlignment:NSTextAlignmentLeft];
        [message4Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message4Page3 setText:@"PREND DES CHIPS OUI ;) ON SE RETROUVE\nDANS 45 MIN !"];
        [message4Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message4Page3];
        
        UILabel *dateMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 387, 150, 20)];
        [dateMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage4Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage4Page3 setText:@"Rémi B. 3 août 2013"];
        [dateMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage4Page3];
        
        UILabel *hourMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 387, 50, 20)];
        [hourMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage4Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage4Page3 setText:@"20:03"];
        [hourMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage4Page3];
        
        
        UILabel *message5Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 447, 300, 20)];
        [message5Page3 setBackgroundColor:[UIColor clearColor]];
        [message5Page3 setTextAlignment:NSTextAlignmentLeft];
        [message5Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message5Page3 setText:@"MERCI LES GARS :) J'ARRIVE !"];
        [message5Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message5Page3];
        
        UILabel *dateMessage5Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 474, 150, 20)];
        [dateMessage5Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage5Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage5Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage5Page3 setText:@"Nico F. 3 août 2013"];
        [dateMessage5Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:dateMessage5Page3];
        
        UILabel *hourMessage5Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 474, 50, 20)];
        [hourMessage5Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage5Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage5Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage5Page3 setText:@"20:25"];
        [hourMessage5Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:hourMessage5Page3];
        
        
        
        
        //Page 4
        UILabel *facebookPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 60, 110, 300, 20)];
        [facebookPage4 setText:@"IMPORTER DEPUIS FACEBOOK"];
            
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
        [lieuPage4 setText:@"LIEU"];
            
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
        [placePage4 setText:@"AU BISTRO"];
        [placePage4 setTextColor:[UIColor whiteColor]];
        [placePage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
        [self.scrollView addSubview:placePage4];
        
        
        UILabel *addressPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 70, 270, 245, 20)];
        [addressPage4 setText:@"50 COURS LA REINE, 75006 PARIS"];
            
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
        [basketPage1 setText:@"Basket entre potes"];
        [basketPage1 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:basketPage1];
        
        UILabel *annivPage1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 355, 300, 40)];
        [annivPage1 setBackgroundColor:[UIColor clearColor]];
        [annivPage1 setTextAlignment:NSTextAlignmentCenter];
        [annivPage1 setFont:[UIFont fontWithName:@"Numans-Regular" size:12.0]];
        [annivPage1 setText:@"Anniversaire 23 ans de Paul"];
        [annivPage1 setTextColor:[UIColor whiteColor]];
        [annivPage1 setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        [annivPage1 setShadowOffset:CGSizeMake(1.0, 1.0)];
        [self.scrollView addSubview:annivPage1];
        
        
        
        
        //Page 2
        UILabel *parMarcPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 28, 95, 100, 20)];
        [parMarcPage2 setText:@"PAR MARC N."];
        
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
                
                // 1 first Lettre Font
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
        [photoDatePage2 setText:@"12/10/12 21:04"];
        [photoDatePage2 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [photoDatePage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-8.25))];
        [self.scrollView addSubview:photoDatePage2];
        
        UILabel *downloadPhotoPage2 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width + 20, 357, 300, 75)];
        [downloadPhotoPage2 setBackgroundColor:[UIColor clearColor]];
        [downloadPhotoPage2 setNumberOfLines:0];
        [downloadPhotoPage2 setLineBreakMode:NSLineBreakByWordWrapping];
        [downloadPhotoPage2 setTextAlignment:NSTextAlignmentCenter];
        [downloadPhotoPage2 setFont:[UIFont fontWithName:@"Hand Of Sean" size:12.0]];
        [downloadPhotoPage2 setText:@"Téléchargez toutes les photos\ndirectement sur votre téléphone !"];
        [downloadPhotoPage2 setTextColor:[UIColor whiteColor]];
        [downloadPhotoPage2 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-5))];
        [self.scrollView addSubview:downloadPhotoPage2];
        
        
        
        //Page 3
        UILabel *message1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 102, 200, 20)];
        [message1Page3 setBackgroundColor:[UIColor clearColor]];
        [message1Page3 setTextAlignment:NSTextAlignmentLeft];
        [message1Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message1Page3 setText:@"JE RAMÈNE DES CHIPS ?"];
        [message1Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message1Page3];
        
        UILabel *dateMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 128, 150, 20)];
        [dateMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage1Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage1Page3 setText:@"Nico F. 3 août 2013"];
        [dateMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:dateMessage1Page3];
        
        UILabel *hourMessage1Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 128, 50, 20)];
        [hourMessage1Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage1Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage1Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage1Page3 setText:@"19:47"];
        [hourMessage1Page3 setTextColor:[UIColor lightGrayColor]];
        [self.scrollView addSubview:hourMessage1Page3];
        
        
        UILabel *message2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 192, 200, 20)];
        [message2Page3 setBackgroundColor:[UIColor clearColor]];
        [message2Page3 setTextAlignment:NSTextAlignmentLeft];
        [message2Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message2Page3 setText:@"JE SAIS PAS JE M'OCCUPE DU PLAT.."];
        [message2Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message2Page3];
        
        UILabel *dateMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 218, 150, 20)];
        [dateMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage2Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage2Page3 setText:@"Julien V. 3 août 2013"];
        [dateMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage2Page3];
        
        UILabel *hourMessage2Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 218, 50, 20)];
        [hourMessage2Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage2Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage2Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage2Page3 setText:@"19:49"];
        [hourMessage2Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage2Page3];
        
        
        UILabel *message3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 280, 300, 20)];
        [message3Page3 setBackgroundColor:[UIColor clearColor]];
        [message3Page3 setNumberOfLines:0];
        [message3Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message3Page3 setTextAlignment:NSTextAlignmentLeft];
        [message3Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message3Page3 setText:@"MOI J'ARRIVE À 21H ! ET POUR LES CHIPS\nPREND TOUJOURS ON SAIT JAMAIS."];
        [message3Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message3Page3];
        
        UILabel *dateMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 305, 150, 20)];
        [dateMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage3Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage3Page3 setText:@"Adrien D. 3 août 2013"];
        [dateMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage3Page3];
        
        UILabel *hourMessage3Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 305, 50, 20)];
        [hourMessage3Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage3Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage3Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage3Page3 setText:@"19:55"];
        [hourMessage3Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage3Page3];
        
        
        UILabel *message4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 85, 362, 300, 20)];
        [message4Page3 setBackgroundColor:[UIColor clearColor]];
        [message4Page3 setNumberOfLines:0];
        [message4Page3 setLineBreakMode:NSLineBreakByWordWrapping];
        [message4Page3 setTextAlignment:NSTextAlignmentLeft];
        [message4Page3 setFont:[UIFont fontWithName:@"Numans-Regular" size:7.0]];
        [message4Page3 setText:@"PREND DES CHIPS OUI ;) ON SE RETROUVE\nDANS 45 MIN !"];
        [message4Page3 setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]];
        [self.scrollView addSubview:message4Page3];
        
        UILabel *dateMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 78, 387, 150, 20)];
        [dateMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [dateMessage4Page3 setTextAlignment:NSTextAlignmentLeft];
        [dateMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [dateMessage4Page3 setText:@"Rémi B. 3 août 2013"];
        [dateMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:dateMessage4Page3];
        
        UILabel *hourMessage4Page3 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*2 + 193, 387, 50, 20)];
        [hourMessage4Page3 setBackgroundColor:[UIColor clearColor]];
        [hourMessage4Page3 setTextAlignment:NSTextAlignmentRight];
        [hourMessage4Page3 setFont:[UIFont italicSystemFontOfSize:9.0]];
        [hourMessage4Page3 setText:@"20:03"];
        [hourMessage4Page3 setTextColor:[UIColor whiteColor]];
        [self.scrollView addSubview:hourMessage4Page3];
        
        
        
        
        //Page 4
        UILabel *facebookPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 60, 100, 300, 20)];
        [facebookPage4 setText:@"IMPORTER DEPUIS FACEBOOK"];
        
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
                
                // 1 first Lettre Font
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:16.0 onRange:NSMakeRange(0, 1)];
                [cf updateTTTAttributedString:mutableAttributedString withColor:[UIColor orangeColor] onRange:NSMakeRange(0, 1)];
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:14.0 onRange:NSMakeRange(16, 1)];
                
                return mutableAttributedString;
            }];
            
            [self.scrollView addSubview:tttLabel];
        }
        
        
        
        UILabel *lieuPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 205, 192, 100, 24)];
        [lieuPage4 setText:@"LIEU"];
        
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
                
                // 1 first Lettre Font
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
        [placePage4 setText:@"AU BISTRO"];
        [placePage4 setTextColor:[UIColor whiteColor]];
        [placePage4 setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(5))];
        [self.scrollView addSubview:placePage4];
        
        
        UILabel *addressPage4 = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*3 + 70, 265, 245, 20)];
        [addressPage4 setText:@"50 COURS LA REINE, 75006 PARIS"];
        
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
                
                // 1 first Lettre Font
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:12.0 onRange:NSMakeRange(0, 2)];
                [cf updateTTTAttributedString:mutableAttributedString withFontSize:12.0 onRange:NSMakeRange(19, 7)];
                
                return mutableAttributedString;
            }];
            
            [self.scrollView addSubview:tttLabel];
        }
    }
    
    [self.letsgoButton setBackgroundImage:[UIImage imageNamed:@"btn_go_up"] forState:UIControlStateNormal];
    [self.letsgoButton setBackgroundImage:[UIImage imageNamed:@"btn_go_down"] forState:UIControlStateSelected];
    
    [self.letsgoButton setTag:1000];
    
    
    [self.scrollView addSubview:self.letsgoButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!self.pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
		self.pageControl.currentPage = page;
        
        [self.imagePageControl setImage:[UIImage imageNamed:[@"bar" stringByAppendingString:[@(page+1) description]]]];
        
        //NSLog(@"scrollViewDidScroll - Page n°%i", self.pageControl.currentPage);
        if (![[VersionControl sharedInstance] isIphone5])
        {
            if (page == 3)
            {
                [self.imagePageControl setHidden:YES];
                [self.page1 setHidden:YES];
                [self.page2 setHidden:YES];
                [self.page3 setHidden:YES];
                [self.page4 setHidden:YES];
            } else {
                [self.imagePageControl setHidden:NO];
                [self.page1 setHidden:NO];
                [self.page2 setHidden:NO];
                [self.page3 setHidden:NO];
                [self.page4 setHidden:NO];
            }
        }
        
        self.pageControlBeingUsed = NO;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageControlBeingUsed = NO;
}

/*- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
 //self.pageControlBeingUsed = NO;
 CGFloat pageWidth = self.scrollView.frame.size.width;
 int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
 
 self.pageControl.currentPage = page;
 
 [self.imagePageControl setImage:[UIImage imageNamed:[@"bar" stringByAppendingString:[@(page+1) description]]]];
 
 NSLog(@"scrollViewDidEndDecelerating - Page n°%i", self.pageControl.currentPage);
 if (!IS_IPHONE_5)
 {
 if (self.pageControl.currentPage == 3)
 {
 [self.imagePageControl setHidden:YES];
 [self.page1 setHidden:YES];
 [self.page2 setHidden:YES];
 [self.page3 setHidden:YES];
 [self.page4 setHidden:YES];
 self.letsgoButton.frame = CGRectMake((self.scrollView.frame.size.width * self.images.count) - (self.scrollView.frame.size.width-82), self.scrollView.frame.size.height-45, 165.0, 34.0);
 } else {
 [self.imagePageControl setHidden:NO];
 [self.page1 setHidden:NO];
 [self.page2 setHidden:NO];
 [self.page3 setHidden:NO];
 [self.page4 setHidden:NO];
 }
 }
 
 self.pageControlBeingUsed = NO;
 }*/

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

- (IBAction)goToPage:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *button = (UIButton *)sender;
        
        NSInteger pageDestination = [button tag];
        CGPoint offset = CGPointMake(pageDestination * self.scrollView.frame.size.width, 0);
        [self.scrollView setContentOffset:offset animated:YES];
        [self.imagePageControl setImage:[UIImage imageNamed:[@"bar" stringByAppendingString:[@(pageDestination+1) description]]]];
        
        self.pageControl.currentPage = pageDestination;
        
        //NSLog(@"goToPage - Page n°%i", pageDestination);
        if (![[VersionControl sharedInstance] isIphone5])
        {
            if (pageDestination == 3)
            {
                [self.imagePageControl setHidden:YES];
                [self.page1 setHidden:YES];
                [self.page2 setHidden:YES];
                [self.page3 setHidden:YES];
                [self.page4 setHidden:YES];
            } else {
                [self.imagePageControl setHidden:NO];
                [self.page1 setHidden:NO];
                [self.page2 setHidden:NO];
                [self.page3 setHidden:NO];
                [self.page4 setHidden:NO];
            }
        }
        
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
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setPage4:nil];
    [self setPage3:nil];
    [self setPage2:nil];
    [self setPage1:nil];
    [self setImagePageControl:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}
@end
