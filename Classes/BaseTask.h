//
//  BaseTask.h
//  DerivedRequest
//
//  Created by WeiHan on 5/22/17.
//  Copyright © 2017 Wei Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseSessionManager.h"
#import "BaseResponse.h"

@interface BaseTask : NSObject <NSCopying, BaseSessionManagerDelegate>

@property (nonatomic, strong) Class sessionManagerClass;
@property (nonatomic, strong) __kindof BaseSessionManager *sessionManager;

@property (nonatomic, strong, readonly) __kindof BaseRequest *request;

@property (nonatomic, assign) NetworkResponseDataHandler responseHandler;
@property (nonatomic, strong, readonly) __kindof BaseResponse *response;

+ (instancetype)task;

+ (instancetype)taskAsBatchItem;

- (void)sendRequest:(NSString *)requestURL
             method:(HTTPMethod)method
         parameters:(id)parameters
         completion:(NetworkTaskCompletion)completionBlock;

- (void)sendRequest:(NSString *)requestURL
             method:(HTTPMethod)method
         parameters:(id)parameters
           progress:(NetworkTaskProgress)taskProgress
         completion:(NetworkTaskCompletion)completionBlock;

/**
 *    @brief Make sure the task/request to be resent is valid before calling this method, a valid task
            will be invalidated after calling sendRequest:method:parameters:progress:completion.
            A task object used as a local autoreleased object generally, so the caller could get a valid
            task/request object from an invalid task/request via [task copy] to generate a new one
            which has same request entity and session manager configuration.
 */
- (void)resendRequest;

@end
