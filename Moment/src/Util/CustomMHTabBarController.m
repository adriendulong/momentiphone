//
//  CustomMHTabBarController.m
//  BestComparator.com
//
//  Created by Mathieu PIERAGGI on 29/06/12.
//  Copyright (c) 2012 Go and Up. All rights reserved.
//

#import "CustomMHTabBarController.h"

#define BLEU() [[VariableStore sharedInstance] bleu]
#define VERT() [[VariableStore sharedInstance] vert]
#define ROSE() [[VariableStore sharedInstance] rose]
#define GRIS() [[VariableStore sharedInstance] gris]

@interface CustomMHTabBarController (){
    
    @private
    NSInteger selectedButton;
}

@end


@implementation CustomMHTabBarController
    

@synthesize selectedTitleColor = _selectedTitleColor;


- (id)initWithTabBarHeigh:(float)heigh fontSize:(NSInteger)font
{
    self = [super initWithTabBarHeigh:heigh fontSize:font];
    if(self)
    {             
        self.selectedTitleColor = BLEU();
        selectedButton = 0;
    }
    
    
    
    return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.TAB_BAR_HEIGHT);
	self.tabButtonsContainerView = [[UIView alloc] initWithFrame:rect];
	self.tabButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.tabButtonsContainerView];
    
	rect.origin.y = self.TAB_BAR_HEIGHT;
	rect.size.height = self.view.bounds.size.height - self.TAB_BAR_HEIGHT;
	self.contentContainerView = [[UIView alloc] initWithFrame:rect];
	self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.contentContainerView];
    
	self.indicatorImageView = [[UIImageView alloc] initWithImage:[[self createIndicatorImage] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
	[self.view addSubview:self.indicatorImageView];
    
	[self reloadTabButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Overwrite

- (void)selectTabButton:(UIButton *)button
{       
    UIImage *image = [[self createButtonImage] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[button setBackgroundImage:image forState:UIControlStateNormal];
	[button setBackgroundImage:image forState:UIControlStateHighlighted];
    [button setBackgroundImage:image forState:UIControlStateSelected];
	
	[button setTitleColor:self.selectedTitleColor forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)deselectTabButton:(UIButton *)button
{   
	int tag = selectedButton;
       
    if( tag == 0)
        self.selectedTitleColor = BLEU();
    else if(tag == 1)
        self.selectedTitleColor = VERT();
    else if(tag == 2)
        self.selectedTitleColor = ROSE();
        
    UIImage *image = [[self createButtonImage] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[button setBackgroundImage:image forState:UIControlStateNormal];
	[button setBackgroundImage:image forState:UIControlStateHighlighted];
    [button setBackgroundImage:image forState:UIControlStateSelected];
    
	[button setTitleColor:GRIS() forState:UIControlStateNormal];
	[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Reload Indicator
    self.indicatorImageView.image = [[self createIndicatorImage] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
}

- (void)tabButtonPressed:(UIButton *)sender
{
	selectedButton = sender.tag - self.TAG_OFFSET;   
    [self setSelectedIndex:sender.tag - self.TAG_OFFSET animated:YES];
    
    for(UIButton *button in [self.tabButtonsContainerView subviews]){
        if( button.tag != selectedButton + 1000 )
            [self deselectTabButton:button];
    }
}


#pragma mark - MyFunctions


- (UIImage *)createButtonImage
{      
    CGFloat point = self.TAB_BAR_HEIGHT - 1;
    
    UIGraphicsBeginImageContext(CGSizeMake(1, self.TAB_BAR_HEIGHT));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Ligne blanche
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, point);
    [[UIColor whiteColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);
    
    // Ligne de couleur
    CGContextMoveToPoint(context, 0, point);
    CGContextAddLineToPoint(context, 0, self.TAB_BAR_HEIGHT);   
    [self.selectedTitleColor setStroke];
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)createIndicatorImage
{
    int widht = self.view.bounds.size.width / self.viewControllers.count;
    
    UIGraphicsBeginImageContext(CGSizeMake(widht, 3));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Ligne de couleur
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddRect(context, CGRectMake(0, 0, widht, 3));
    [self.selectedTitleColor setStroke];
    [self.selectedTitleColor setFill];
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
