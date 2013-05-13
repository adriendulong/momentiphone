//
//  PlacesTableViewCell.m
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import "PlacesTableViewCell.h"
#import "Config.h"

@implementation PlacesTableViewCell

- (id)initWithPlace:(Place*)place
    reuseIdentifier:(NSString *)reuseIdentifier
              index:(NSInteger)index
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        
        // Setup
        [self setupWithIndex:index];
                
        // Titre
        self.titreLabel.text = place.titre;
        
        // Adresse
        self.adresseLabel.text = place.adresse;
        
        // Icone cachée
        self.icone.hidden = YES;
        
    }
    return self;
}

- (id)initWithCustomAdresse:(NSString*)adresse
{
    // Première cellule => Custom
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if(self) {
        
        // Setup
        [self setupWithIndex:0];
        
        // Titre
        self.titreLabel.text = adresse;
        
        // Adresse cachée
        self.adresseLabel.text = @"Custom Location";
        
        // Déplacer Titre
        CGRect frame = self.titreLabel.frame;
        NSInteger postionMax =  self.titreLabel.frame.origin.x + self.titreLabel.frame.size.width;
        frame.origin.x = self.icone.frame.origin.x + self.icone.frame.size.width + 5;
        frame.size.width = postionMax - frame.origin.x;
        self.titreLabel.frame = frame;
        frame.origin.y = self.adresseLabel.frame.origin.y;
        self.adresseLabel.frame = frame;
        
    }
    return self;
}

- (void)setupWithIndex:(NSInteger)index {
    
    // Load from Xib
    NSArray *screens = [[NSBundle mainBundle] loadNibNamed:@"PlacesTableViewCell" owner:self options:nil];
    [self addSubview:screens[0]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Fonts
    self.adresseLabel.font = [[Config sharedInstance] defaultFontWithSize:12];
    self.titreLabel.font = [[Config sharedInstance] defaultFontWithSize:13];
    
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

@end
