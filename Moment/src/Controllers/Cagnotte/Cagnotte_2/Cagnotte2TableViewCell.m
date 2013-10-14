//
//  Cagnotte2TableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 11/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "Cagnotte2TableViewCell.h"
#import "Config.h"

@implementation Cagnotte2TableViewCell

@synthesize product = _product;
@synthesize productImageView = _productImageView;
@synthesize titreLabel = _titreLabel;
@synthesize authorLabel = _authorLabel;
@synthesize priceLabel = _priceLabel;
@synthesize backgroundImageView = _backgroundImageView;

- (id)initWithProduct:(CagnotteProduct*)product
      reuseIdentifier:(NSString *)reuseIdentifier
                index:(NSInteger)index
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Save
        self.product = product;
        
        // Load from Xib
        NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"Cagnotte2TableViewCell" owner:self options:nil];
        [self addSubview:screens[0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Image
        [self.productImageView setImage:self.product.image imageString:self.product.imageURL placeHolder:[UIImage imageNamed:@"cover_defaut"] withSaveBlock:^(UIImage *image) {
            self.product.image = image;
        }];
        
        // Titre
        self.titreLabel.text = self.product.title;
        UIFont *font = [[Config sharedInstance] defaultFontWithSize:13];
        self.titreLabel.font = font;
        
        // Auteur
        self.authorLabel.text = self.product.authorName;
        self.authorLabel.font = font;
        
        // Prix
        self.priceLabel.text = [NSString stringWithFormat:@"%d%@", (int)self.product.price, self.product.currency];
        self.priceLabel.font = font;
        
        // Background
        if(index%2) {
            // White
            self.backgroundImageView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
        }
        else {
            // Grey
            self.backgroundImageView.backgroundColor = [UIColor colorWithHex:0xeeeeef];
        }
        
    }
    return self;
}

@end
