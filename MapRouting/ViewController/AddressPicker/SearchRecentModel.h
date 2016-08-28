//
//  SearchRecentModel.h
//  MapRouting
//
//  Created by admin on 8/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Realm/Realm.h>
#import <GooglePlaces/GooglePlaces.h>

@interface SearchRecentModel : RLMObject

@property NSString *placeID;

@property NSString *name;

@property NSString *address;

- (id)initWithPrediction:(GMSAutocompletePrediction*)prediction;

@end
