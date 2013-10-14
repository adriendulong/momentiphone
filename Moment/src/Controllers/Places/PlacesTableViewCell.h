//
//  PlacesTableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 08/05/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface PlacesTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titreLabel;
@property (nonatomic, weak) IBOutlet UILabel *adresseLabel;
@property (nonatomic, weak) IBOutlet UIImageView *icone;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

- (id)initWithPlace:(Place*)place
    reuseIdentifier:(NSString *)reuseIdentifier
              index:(NSInteger)index;

- (id)initWithCustomAdresse:(NSString*)adresse;

@end
