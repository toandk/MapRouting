//
//  SearchRecentModelFactory.h
//  MapRouting
//
//  Created by admin on 8/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlaces/GooglePlaces.h>

@interface SearchRecentModelFactory : NSObject

+ (NSArray*)getListSavedRecentModel;

+ (void)saveSearchPrediction:(GMSAutocompletePrediction*)prediction;

@end
