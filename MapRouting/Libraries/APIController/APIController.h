//
//  APIController.h
//  BaseProject
//
//  Created by Appota on 7/22/16.
//  Copyright © 2016 Appota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLSessionManager.h"
#import "AFHTTPSessionManager.h"

typedef void ( ^ GCAPIResponseBlock)(NSError* error, id object);

@interface APIController : NSObject {
    AFHTTPSessionManager *_httpManager;
    NSString *_authorizationValue;
}

+ (instancetype)sharedController;

- (void)POSTRequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler;

- (void)GETRequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler;

- (void)DELETERequestWithUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(GCAPIResponseBlock)completionHandler;




@end
