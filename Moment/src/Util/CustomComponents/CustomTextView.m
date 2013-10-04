//
//  CustomTextView.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomTextView.h"
#import "Config.h"

@implementation CustomTextView

@synthesize paddingLeft;
@synthesize paddingTop;
@synthesize backgroundImage = _backgroundImage;

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    NSInteger mT = 0;
    NSInteger mL = 0;
    
    if( self.paddingTop == 0)
        mT = 6;
    else
        mT = self.paddingTop;
    
    if( self.paddingLeft == 0)
        mL = 8;
    else
        mL = self.paddingLeft;
    
    return CGRectMake(bounds.origin.x + mL, bounds.origin.y + mT,
                      bounds.size.width - (2*mL), bounds.size.height - (2*mT) );
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (void) drawRect:(CGRect)rect{
    
    self.font = [[Config sharedInstance] defaultFontWithSize:14];
    self.textColor = [Config sharedInstance].textColor;
    
    UIImage *image = self.backgroundImage;
    
    //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 5)];
    
    image = [[VersionControl sharedInstance] resizableImageFromImage:image withCapInsets:UIEdgeInsetsMake(4, 0, 2, 0)  stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    
    /*
     image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 5)];
     image = [image stretchableImageWithLeftCapWidth:7 topCapHeight:7];
     */
    
    //self.background = image;
    
    // PlaceHolder
    
    if( [[self placeholder] length] > 0 )
    {
        if ( self.placeHolderLabel == nil )
        {
            self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            self.placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.placeHolderLabel.numberOfLines = 0;
            self.placeHolderLabel.font = self.font;
            self.placeHolderLabel.backgroundColor = [UIColor clearColor];
            self.placeHolderLabel.textColor = self.placeholderColor;
            self.placeHolderLabel.alpha = 0;
            self.placeHolderLabel.tag = 999;
            [self addSubview:self.placeHolderLabel];
        }
        
        self.placeHolderLabel.text = self.placeholder;
        [self.placeHolderLabel sizeToFit];
        [self sendSubviewToBack:self.placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    
    [super drawRect:rect];
}

#pragma mark - PlaceHolder

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupPlaceHolder {
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor colorWithWhite: 0.70 alpha:1]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupPlaceHolder];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setupPlaceHolder];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (UIImage*)backgroundImage {
    if(!_backgroundImage) {
        _backgroundImage = [UIImage imageNamed:@"bg-textfield"];
    }
    return _backgroundImage;
}

@end
