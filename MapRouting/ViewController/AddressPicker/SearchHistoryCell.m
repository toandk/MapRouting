//
//  SearchHistoryCell.m
//  MapRouting
//
//  Created by admin on 8/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SearchHistoryCell.h"
#import "SearchRecentModel.h"

@implementation SearchHistoryCell

+ (UINib*)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)bindViewModel:(id)viewModel {
    SearchRecentModel *recentModel = viewModel;
    nameLabel.text = recentModel.name;
    addressLabel.text = recentModel.address;
}

@end
