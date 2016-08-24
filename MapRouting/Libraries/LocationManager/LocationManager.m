//
//  LocationManager.m
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "LocationManager.h"
#import "AppConfig.h"


@implementation LocationManager

+ (instancetype)sharedManager {
    static LocationManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LocationManager alloc] init];
    });
    
    return manager;
}

- (id)init {
    if (self = [super init]) {
        self.permissionScope = [[PermissionScope alloc] init];
        [self.permissionScope addPermission:[[LocationWhileInUsePermission alloc] init]
                                    message:@"We use this display your location on the map"];
        self.locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)askingPermissionScope {
    if (self.permissionScope.statusLocationInUse != PermissionStatusAuthorized) {
        [self.permissionScope show:^(BOOL completed, NSArray *results) {
            NSLog(@"Changed: %@ - %@", @(completed), results);
        } cancelled:^(NSArray *x) {
            NSLog(@"cancelled");
        }];
    }
    else {
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
}

- (BOOL)isCurrentLocation:(CLLocationCoordinate2D)location {
    return (fabs(location.latitude - self.currentLocation.latitude) < 0.001 &&
            fabs(location.longitude - self.currentLocation.longitude) < 0.001);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        self.currentLocation = [locations[0] coordinate];
        [self.locationManager stopUpdatingLocation];
    }
}

@end
