//
//  APIController+Map.m
//  MapRouting
//
//  Created by admin on 8/21/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "APIController+Map.h"
#import "APIConstants.h"
#import "AppConfig.h"


@implementation APIController (Map)

- (void)getMapDirectionFrom:(DTPlace*)startPoint
                         to:(DTPlace*)stopPoint
                   withMode:(NSString*)mode
          completionHandler:(GCAPIResponseBlock)completionHandler {
    
    NSDictionary *params = @{@"origin": [NSString stringWithFormat:@"%f,%f", startPoint.coordinate.latitude, startPoint.coordinate.longitude],
                             @"destination": [NSString stringWithFormat:@"%f,%f", stopPoint.coordinate.latitude, stopPoint.coordinate.longitude],
                             @"mode": mode,
                             @"key": GOOGLE_MAP_API_KEY};
    [self GETRequestWithUrl:GET_MAP_DIRECTIONS params:params completionHandler:^(NSError *error, id object) {
        completionHandler(error, object);
    }];
}

- (void)searchFirstPlaceWithLocation:(CLLocationCoordinate2D)location
             completionHandler:(GCAPIResponseBlock)completionHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"vi", @"language",
                                   [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude], @"location",
                                   GOOGLE_MAP_API_KEY, @"key",
                                   @(100), @"radius",
                                   @"distance", @"ranky",
                                   @"establishment", @"type",
                                   nil];
    
    [self GETRequestWithUrl:SEARCH_PLACES params:params completionHandler:^(NSError *error, id object) {
        if (!error && object[@"results"] && [object[@"results"] count] > 0) {
            NSArray *results = object[@"results"];
            completionHandler(nil, results[0]);
        }
        else {
            completionHandler(error, nil);
        }
    }];
}

@end
