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
    myMapView.delegate = self;
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
          if (!self.viewModel.startPlace)
              [self centerMapWithCoordinate:self.viewModel.stopPlace.coordinate];
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

- (void)centerMapToViewAllMarkers:(NSArray*)listMarkers {
    if (listMarkers.count != 2) return;
    GMSMarker *marker1 = listMarkers[0];
    GMSMarker *marker2 = listMarkers[1];
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:marker1.position.latitude longitude:marker1.position.longitude];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:marker2.position.latitude longitude:marker2.position.longitude];
    CLLocationDistance distance = [location1 distanceFromLocation:location2];
    if (distance < 100) {
        [self centerMapWithCoordinate:location1.coordinate];
        return;
    }
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    for (GMSMarker *marker in listMarkers)
        bounds = [bounds includingCoordinate:marker.position];
    
    [myMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(100, 50, 200, 50)]];

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
    
    NSMutableArray *markers = [NSMutableArray array];
    
    if (self.viewModel.startPlace) {
        if ([[LocationManager sharedManager] isCurrentLocation:self.viewModel.startPlace.coordinate])
            startPointTextField.text = @"Your location";
        else startPointTextField.text = self.viewModel.startPlace.formattedAddress;
        GMSMarker *marker = [GMSMarker markerWithPosition:self.viewModel.startPlace.coordinate];
//        marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:123.0/255 green:218.0/255 blue:0 alpha:1.0]];
        marker.icon = [UIImage imageNamed:@"location_pin_blue"];
        marker.title = @"Starting point";
        marker.map = myMapView;
        marker.draggable = YES;
        marker.userData = @"startingPoint";
        [markers addObject:marker];
        [myMapView setSelectedMarker:marker];
    }
    else {
        startPointTextField.text = @"";
    }
    if (self.viewModel.stopPlace) {
        if ([[LocationManager sharedManager] isCurrentLocation:self.viewModel.stopPlace.coordinate])
            stopPointTextField.text = @"Your location";
        else stopPointTextField.text = self.viewModel.stopPlace.formattedAddress;
        GMSMarker *marker = [GMSMarker markerWithPosition:self.viewModel.stopPlace.coordinate];
        marker.icon = [UIImage imageNamed:@"location_pin"];
        marker.title = @"Destination";
        marker.map = myMapView;
        marker.draggable = YES;
        marker.userData = @"Destination";
        [markers addObject:marker];
        [myMapView setSelectedMarker:marker];
    }
    else {
        stopPointTextField.text = @"";
    }
    if (markers.count == 2) {
        [self centerMapToViewAllMarkers:markers];
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
            button.tintColor = [UIColor colorWithRed:0 green:122.0/255 blue:1.0 alpha:1.0];
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

#pragma mark GMSMapView delegate
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    if ([marker.userData isEqualToString:@"startingPoint"]) {
        [self.viewModel changeLocation:marker.position forStartPlace:YES];
    }
    else {
        [self.viewModel changeLocation:marker.position forStartPlace:YES];
    }
}

@end
