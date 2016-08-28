//
//  SearchHistoryCell.h
//  MapRouting
//
//  Created by admin on 8/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"

@interface SearchHistoryCell : UITableViewCell<CEReactiveView> {
    __weak IBOutlet UILabel *nameLabel, *addressLabel;
}

+ (UINib*)nib;

@end
