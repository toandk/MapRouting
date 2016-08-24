//
//  MapRoutingViewController.m
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "MapRoutingViewController.h"
#import "AddressPickerViewController.h"
#import "APIController+Map.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "AppConfig.h"
#import "LocationManager.h"

@interface MapRoutingViewController () {
    GMSPolyline *routingLine;
}

@end

@implementation MapRoutingViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    [myMapView setMyLocationEnabled:YES];
    [self setupDefaultLocation];
    [self bindViewModel];
}

- (void)bindViewModel {
    @weakify(self);
    [[RACObserve(self.viewModel, currentPlace)
      deliverOn:[RACScheduler mainThreadScheduler]]
        subscribeNext:^(id x) {
         @strongify(self);
         [self centerMapWithCoordinate:self.viewModel.currentPlace.coordinate];
         [self updateUI];
     }];
    [[RACObserve(self.viewModel, startPlace)
      deliverOn:[RACScheduler mainThreadScheduler]]
      subscribeNext:^(id x) {
         @strongify(self);
         if (self.viewModel.startPlace)
             [self centerMapWithCoordinate:self.viewModel.startPlace.coordinate];
         [self updateUI];
      }];
    [[RACObserve(self.viewModel, stopPlace)
      deliverOn:[RACScheduler mainThreadScheduler]]
      subscribeNext:^(id x) {
         @strongify(self);
         [self updateUI];
      }];
    [[RACObserve(self.viewModel, encodedRoutingPoints)
      deliverOn:[RACScheduler mainThreadScheduler]]
      subscribeNext:^(id x) {
         @strongify(self);
         [self removeOldRoutingLine];
         [self drawMapRoutingWithPoints:x];
      }];
    
    reverveDirectionButton.rac_command = self.viewModel.reverseDirectionCommand;
    [self.viewModel.currentPlaceCommand execute:nil];
}

- (void)setupDefaultLocation {
    [self centerMapWithCoordinate:CLLocationCoordinate2DMake(DEFAULT_LATITUDE, DEFAULT_LONGITUDE)];    
}

- (void)centerMapWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (coordinate.latitude == 0 && coordinate.longitude == 0) return;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:DEFAULT_ZOOM_FACTOR];
    [myMapView setCamera:camera];
}

- (void)removeOldRoutingLine {
    if (routingLine) {
        routingLine.map = nil;
        routingLine = nil;
    }
}

- (void)drawMapRoutingWithPoints:(NSString*)encodedPoints {
    if ([encodedPoints isEqualToString:NO_ROUTE_KEY]) {
        [self showAlertWithTitle:@"Alert" withMessage:@"No route found!"];
        return;
    }
    
    GMSPath *path = [GMSPath pathFromEncodedPath:encodedPoints];
    routingLine = [GMSPolyline polylineWithPath:path];
    routingLine.strokeWidth = 6.0;
    switch (self.viewModel.transportMode) {
        case DTTransportingModeDriving:
            routingLine.strokeColor = [UIColor colorWithRed:0 green:122.0/255 blue:1.0 alpha:1.0];
            break;
        case DTTransportingModeTransit:
            routingLine.strokeColor = [UIColor colorWithRed:245.0/255 green:166.0/255 blue:35.0/255 alpha:1.0];
            break;
        case DTTransportingModeWalking:
            routingLine.strokeColor = [UIColor colorWithRed:126.0/255 green:211.0/255 blue:33.0/255 alpha:1.0];
            break;
        case DTTransportingModeBicycling:
            routingLine.strokeColor = [UIColor colorWithRed:144.0/255 green:19.0/255 blue:254.0/255 alpha:1.0];
            break;
            
        default:
            break;
    }
    
    routingLine.map = myMapView;
}

- (void)updateUI {
    [myMapView clear];
    
    if (self.viewModel.startPlace) {
        if ([[LocationManager sharedManager] isCurrentLocation:self.viewModel.startPlace.coordinate])
            startPointTextField.text = @"Your location";
        else startPointTextField.text = self.viewModel.startPlace.formattedAddress;
        GMSMarker *marker = [GMSMarker markerWithPosition:self.viewModel.startPlace.coordinate];
        marker.title = @"Starting point";
        marker.map = myMapView;
    }
    else {
        startPointTextField.text = @"";
    }
    if (self.viewModel.stopPlace) {
        if ([[LocationManager sharedManager] isCurrentLocation:self.viewModel.stopPlace.coordinate])
            stopPointTextField.text = @"Your location";
        else stopPointTextField.text = self.viewModel.stopPlace.formattedAddress;
        GMSMarker *marker = [GMSMarker markerWithPosition:self.viewModel.stopPlace.coordinate];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        marker.title = @"Destination";
        marker.map = myMapView;
    }
    else {
        stopPointTextField.text = @"";
    }
}

- (IBAction)pickAddressAction:(id)sender {
    NSInteger tag = [sender tag];
    DTPlace *place = (tag == 0) ? self.viewModel.startPlace : self.viewModel.stopPlace;
    SearchAddressViewModel *searchViewModel = [self.viewModel getAddressPickerViewModel:place];
    
    [AddressPickerViewController showInViewController:self withViewModel:searchViewModel withCompletionHandler:^(id object, NSError *error) {
        if (!error) {
            if (tag == 0) {
                self.viewModel.startPlace = object;
            }
            else self.viewModel.stopPlace = object;
        }
    }];
}

- (IBAction)changeTransportAction:(id)sender {
    NSInteger tag = [sender tag];
    for (UIButton *button in listTransportButton) {
        if (button.tag == tag) {
            button.tintColor = [UIColor whiteColor];
        }
        else button.tintColor = [UIColor colorWithRed:190.0/255 green:213.0/255 blue:251.0/255 alpha:1.0];
    }
    self.viewModel.transportMode = (DTTransportingMode)tag;
}

- (IBAction)showCurrentLocation:(id)sender {
    [[LocationManager sharedManager] askingPermissionScope];
    
    CLLocationCoordinate2D location = [[LocationManager sharedManager] currentLocation];
    if (location.longitude != 0 && location.latitude != 0)
        [myMapView animateToLocation:location];
}

@end
