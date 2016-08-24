//
//  DTPlace.h
//  MapRouting
//
//  Created by admin on 8/23/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>

@interface DTPlace : NSObject

@property(nonatomic, copy) NSString *name;

@property(nonatomic, copy) NSString *placeID;

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

@property(nonatomic, copy) NSString *phoneNumber;

@property(nonatomic, copy) NSString *formattedAddress;

- (id)initWithGMSPlace:(GMSPlace*)place;

@end
