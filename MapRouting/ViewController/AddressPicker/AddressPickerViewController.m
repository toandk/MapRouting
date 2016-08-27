//
//  AddressPickerViewController.m
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AddressPickerViewController.h"
#import "CETableViewBindingHelper.h"
#import "AddressTableViewCell.h"
#import "SearchAddressServices.h"
#import "LocationManager.h"
#import "AppConfig.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlacePicker/GooglePlacePicker.h>

@interface AddressPickerViewController () {
    DTAddressPickerBlock completionBlock;
}

@property (strong, nonatomic) CETableViewBindingHelper *bindingHelper;


@end

@implementation AddressPickerViewController

+ (id)showInViewController:(UIViewController*)viewController withViewModel:(SearchAddressViewModel*)viewModel withCompletionHandler:(DTAddressPickerBlock)block {
    AddressPickerViewController *picker = [[AddressPickerViewController alloc] initUsingNib];
    picker.viewModel = viewModel;
    [picker setCompletionBlock:block];
    [viewController.navigationController pushViewController:picker animated:YES];
    return picker;
}

- (void)setCompletionBlock:(DTAddressPickerBlock)block {
    completionBlock = block;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUI];
    
    [self bindViewModel];
    [self bindTableView];
    [self handleResult];
}

- (void)setupDefaultUI {
    [searchTextField becomeFirstResponder];
    if (self.viewModel.defaultPlace) {
        if ([[LocationManager sharedManager] isCurrentLocation:self.viewModel.defaultPlace.coordinate])
            searchTextField.text = @"Your location";
        else searchTextField.text = self.viewModel.defaultPlace.name;
    }
    yourLocationButton.hidden = !self.viewModel.currentPlace;
    float posY = self.viewModel.currentPlace ? yourLocationButton.frame.origin.y + yourLocationButton.frame.size.height :
                yourLocationButton.frame.origin.y;
    resultView.frame = CGRectMake(resultView.frame.origin.x, posY, resultView.frame.size.width, self.view.frame.size.height - posY - 10);
}

- (void)bindTableView {
    self.bindingHelper  =
    [CETableViewBindingHelper bindingHelperForTableView:resultTableView
                                           sourceSignal:RACObserve(self.viewModel, searchResults)
                                       selectionCommand:[self.viewModel getSelectionAddressCommand]
                                           templateCell:[AddressTableViewCell nib]];
}

- (void)bindViewModel {
    RAC(self.viewModel, searchText) = searchTextField.rac_textSignal;
    RAC(resultView, hidden) = [self.viewModel.validSearchSignal not];
    
    [self.viewModel.executeSearchCommand.executionSignals
     subscribeNext:^(id x) {
     }];
    yourLocationButton.rac_command = [self.viewModel getChoosingCurrentLocationCommand];
}

- (void)handleResult {
    @weakify(self)
    [[RACObserve(self.viewModel, selectedPlace)
     deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
         @strongify(self)
         if (self.viewModel.selectedPlace) {
             completionBlock(self.viewModel.selectedPlace, nil);
             [self closeAction:nil];
         }
     }];
}

#pragma mark Actions
- (IBAction)closeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chooseOnMapAction:(id)sender {
    [self.view endEditing:YES];
    CLLocationCoordinate2D center = [[LocationManager sharedManager] currentLocation];
    if (center.longitude == 0 && center.latitude == 0)
        center = CLLocationCoordinate2DMake(DEFAULT_LATITUDE, DEFAULT_LONGITUDE);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.01,
                                                                  center.longitude + 0.01);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.01,
                                                                  center.longitude - 0.01);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    GMSPlacePicker *_placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (place != nil) {
            DTPlace *newPlace = [[DTPlace alloc] initWithGMSPlace:place];
            completionBlock(newPlace, nil);
            [self closeAction:nil]; 
        }
    }];
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end
