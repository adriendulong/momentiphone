//
//  CustomTextArea.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 02/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "CustomTextArea.h"
#import "Config.h"

#define defaultPlaceHolderString (NSLocalizedString(@"ChatViewController_SendBoxView_placeHolder", nil))
#define defaultPlaceHolderColor ([Config sharedInstance].textColor)
#define defaultBackgroundImage ([UIImage imageNamed:@""])
#define defaultEdgeInset_Left 5.0
#define defaultEdgeInset_Right 5.0
#define defaultEdgeInset_Top 5.0
#define defaultEdgeInset_Bottom 5.0

@implementation CustomTextArea {
    @protected
    UIImageView *backgroundImageView;
    UILabel *placeHolderLabel;
}

@synthesize edgeInsets = _edgeInsets;
@synthesize textView = _textView;

- (void)defaultInit {
    
    self.edgeInsets = UIEdgeInsetsMake(defaultEdgeInset_Top, defaultEdgeInset_Left, defaultEdgeInset_Bottom, defaultEdgeInset_Right);
    
    [self addSubview:backgroundImageView];
    [self addSubview:self.textView];
    
    [self setPlaceholder:defaultPlaceHolderString];
    [self setPlaceholderColor:defaultPlaceHolderColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
}

- (void)setup {
    
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultInit];
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

#pragma mark - Place Holder

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self.textView text] length] == 0)
    {
        [[self.textView viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self.textView viewWithTag:999] setAlpha:0];
    }
}

- (void)setText:(NSString *)text {
    [self.textView setText:text];
    [self textChanged:nil];
}

#pragma mark - Getters & Setters

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    [self setup];
}

- (UIImage*)convertImage:(UIImage*)origin {
    return origin;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    backgroundImageView.image = [self convertImage:backgroundImage];
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    self.textView.delegate = delegate;
}

- (CGRect)textViewFrame {
    return (CGRect){self.edgeInsets.left, self.edgeInsets.top, self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right, self.frame.size.height - self.edgeInsets.top - self.edgeInsets.bottom};
}

- (UITextView*)textView {
    if(!_textView) {
        _textView = [[UITextView alloc] initWithFrame:[self textViewFrame]];
    }
    return _textView;
}

- (UIImageView*)backgroundImageView {
    if(!backgroundImageView) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,self.frame.size.width, self.frame.size.height}];
        [self setBackgroundImage:defaultBackgroundImage];
        backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return backgroundImageView;
}

- (UIColor*)placeholderColor {
    if(!_placeholderColor) {
        _placeholderColor = defaultPlaceHolderColor;
    }
    return _placeholderColor;
}

@end
