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

@end
