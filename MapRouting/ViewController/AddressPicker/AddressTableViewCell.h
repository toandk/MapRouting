//
//  AddressTableViewCell.h
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"

@interface AddressTableViewCell : UITableViewCell<CEReactiveView> {
    __weak IBOutlet UILabel *nameLabel, *addressLabel;
}

+ (UINib*)nib;

@end
