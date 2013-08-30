//
//  Cagnotte2TableViewCell.h
//  Moment
//
//  Created by Mathieu PIERAGGI on 11/04/13.
//  Copyright (c) 2013 Moment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CagnotteProduct.h"
#import "CustomUIImageView.h"

@interface Cagnotte2TableViewCell : UITableViewCell

@property (nonatomic, strong) CagnotteProduct *product;
@property (nonatomic, weak) IBOutlet CustomUIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UILabel *titreLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

- (id)initWithProduct:(CagnotteProduct*)product
      reuseIdentifier:(NSString *)reuseIdentifier
                index:(NSInteger)index;

@end
