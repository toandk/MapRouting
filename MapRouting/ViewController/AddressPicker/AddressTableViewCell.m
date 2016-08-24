//
//  AddressTableViewCell.m
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AddressTableViewCell.h"
#import <GooglePlaces/GooglePlaces.h>

@implementation AddressTableViewCell

+ (UINib*)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)bindViewModel:(id)viewModel {
    GMSAutocompletePrediction *prediction = viewModel;
    nameLabel.attributedText = prediction.attributedPrimaryText;
    addressLabel.attributedText = prediction.attributedSecondaryText;
}

@end
