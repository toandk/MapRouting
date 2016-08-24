//
//  SearchAddressServices.h
//  MapRouting
//
//  Created by admin on 8/20/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <GooglePlaces/GooglePlaces.h>

typedef void (^DTSearchBlock)(id object, NSError *error);

@interface SearchAddressServices : NSObject

- (RACSignal*)getSearchSignalWithKeyword:(NSString*)keyword;

- (RACSignal*)getPlaceInfoSignalWithPlace:(NSString*)placeId;

@end
