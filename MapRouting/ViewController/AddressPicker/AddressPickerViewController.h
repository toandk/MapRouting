//
//  AddressPickerViewController.h
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import "SearchAddressViewModel.h"

typedef void (^DTAddressPickerBlock)(id object, NSError *error);

@interface AddressPickerViewController : BaseViewController {
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UITableView *resultTableView, *historyTableView;
    __weak IBOutlet UIView *resultView, *historyView;
    __weak IBOutlet UIButton *yourLocationButton;

}
@property (strong, nonatomic) SearchAddressViewModel *viewModel;

+ (id)showInViewController:(UIViewController*)viewController withViewModel:(SearchAddressViewModel*)viewModel withCompletionHandler:(DTAddressPickerBlock)block;

@end
