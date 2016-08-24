//
//  LocationManager.h
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <PermissionScope/PermissionScope-Swift.h>

@interface LocationManager : NSObject<CLLocationManagerDelegate> {
    
}

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, strong) PermissionScope *permissionScope;
@property (nonatomic, strong) CLLocationManager *locationManager;

+ (instancetype)sharedManager;

- (void)askingPermissionScope;

- (BOOL)isCurrentLocation:(CLLocationCoordinate2D)location;

@end
