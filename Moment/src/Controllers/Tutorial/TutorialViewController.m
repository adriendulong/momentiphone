//
//  TutorialViewController.m
//  Moment
//
//  Created by SkeletonGamer on 06/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIImageView *imagePageControl;


@property(strong, nonatomic) NSArray *pageImages;
@property(strong, nonatomic) NSMutableArray *pageViews;

@property(nonatomic) BOOL pageControlBeingUsed;

@property (strong, nonatomic) UIButton *letsgoButton;

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.pageControlBeingUsed = NO;
    
    [self.letsgoButton setHidden:YES];
	
	//NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor greenColor], [UIColor blueColor], nil];    
    NSArray *images = [NSArray arrayWithObjects:
     [UIImage imageNamed:@"Walkthoughtv2_01"],
     [UIImage imageNamed:@"Walkthoughtv2_02"],
     [UIImage imageNamed:@"Walkthoughtv2_03"],
     [UIImage imageNamed:@"Walkthoughtv2_04"],
     nil];
    
	for (int i = 0; i < images.count; i++) {
		CGRect frame;
		frame.origin.x = self.scrollView.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = self.scrollView.frame.size;
		
		UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
		subview.image = [images objectAtIndex:i];
		[self.scrollView addSubview:subview];
	}
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * images.count, self.scrollView.frame.size.height);
	
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = images.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!self.pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
		self.pageControl.currentPage = page;
        
        [self.imagePageControl setImage:[UIImage imageNamed:[@"bar" stringByAppendingString:[@(page+1) description]]]];
        
        if (page == 3)
        {
            if (self.lastContentOffset > self.scrollView.contentOffset.x)
            {
                [self.letsgoButton setHidden:NO];
            } else if (self.lastContentOffset == self.scrollView.contentOffset.x) {
                [self.letsgoButton setHidden:NO];
            } else if (self.lastContentOffset < self.scrollView.contentOffset.x) {
                [self.letsgoButton setHidden:YES];
            }
        } else {
            [self.letsgoButton setHidden:YES];
        }
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	//self.pageControlBeingUsed = NO;
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageControl.currentPage = page;
    
    [self.imagePageControl setImage:[UIImage imageNamed:[@"bar" stringByAppendingString:[@(page+1) description]]]];
    
    NSLog(@"scrollViewWillBeginDragging - Page n°%i", page);
    if (page == 3)
    {
        if (self.lastContentOffset > self.scrollView.contentOffset.x)
        {
            [self.letsgoButton setHidden:NO];
        } else if (self.lastContentOffset == self.scrollView.contentOffset.x) {
             [self.letsgoButton setHidden:NO];
        } else if (self.lastContentOffset < self.scrollView.contentOffset.x) {
            [self.letsgoButton setHidden:YES];
        }
    } else {
        [self.letsgoButton setHidden:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	//self.pageControlBeingUsed = NO;
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageControl.currentPage = page;
    
    [self.imagePageControl setImage:[UIImage imageNamed:[@"bar" stringByAppendingString:[@(page+1) description]]]];
    
    NSLog(@"Page n°%i", self.pageControl.currentPage);
    if (self.pageControl.currentPage == 3)
    {
        [self.letsgoButton setHidden:NO];
    }
    else
    {
        [self.letsgoButton setHidden:YES];
    }
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

- (IBAction)goToPage:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *button = (UIButton *)sender;
        
        NSInteger pageDestination = [button tag];
        CGPoint offset = CGPointMake(pageDestination * self.scrollView.frame.size.width, 0);
        [self.scrollView setContentOffset:offset animated:YES];
        [self.imagePageControl setImage:[UIImage imageNamed:[@"bar" stringByAppendingString:[@(pageDestination+1) description]]]];
        
        NSLog(@"Page n°%i", pageDestination);
        if (pageDestination == 3)
        {
            [self.letsgoButton setHidden:NO];
        }
        else
        {
            [self.letsgoButton setHidden:YES];
        }
        
        self.pageControlBeingUsed = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setLetsgoButton:nil];
    [self setPage4:nil];
    [self setPage3:nil];
    [self setPage2:nil];
    [self setPage1:nil];
    [self setImagePageControl:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    //[super viewDidUnload];
}
@end
