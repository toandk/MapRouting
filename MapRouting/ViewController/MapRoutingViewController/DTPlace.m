//
//  DTPlace.m
//  MapRouting
//
//  Created by admin on 8/23/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "DTPlace.h"

@implementation DTPlace

- (id)initWithGMSPlace:(GMSPlace*)place {
    if (self = [super init]) {
        _name = place.name;
        _coordinate = place.coordinate;
        _phoneNumber = place.phoneNumber;
        _formattedAddress = place.formattedAddress;
        _placeID = place.placeID;
    }
    return self;
}

- (NSString*)formattedAddress {
    if (_formattedAddress && _formattedAddress.length > 0) return _formattedAddress;
    if (_name && _name.length > 0) return _name;
    return [NSString stringWithFormat:@"(%f, %f)", _coordinate.latitude, _coordinate.longitude];
}

@end
