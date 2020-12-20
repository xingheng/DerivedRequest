//
//  BaseSessionManager.h
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM (NSInteger, HTTPMethod) {
    HTTPMethodGet,
    HTTPMethodPost,
    HTTPMethodPut,
    HTTPMethodDelete
};

NSString * HTTPMethodString(HTTPMethod method);

@class BaseSessionManager, BaseResponse;

typedef void (^ TaskRequestHeaderConfiguration)(NSDictionary *headers);
typedef void (^ NetworkTaskProgress)(NSProgress *progress);
typedef void (^ NetworkTaskCompletion)(__kindof BaseResponse *response);
typedef void (^ DataTaskCompletion)(__kindof BaseResponse *response, NSURLSessionDataTask *task);

#pragma mark - BaseRequest

@interface BaseRequest : NSObject <NSCopying>

@property (nonatomic, strong) NSString *requestURL;

@property (nonatomic, assign) HTTPMethod method;

@property (nonatomic, strong) id parameters;

@property (nonatomic, copy) TaskRequestHeaderConfiguration headerConfiguration;

@property (nonatomic, copy) NetworkTaskProgress progress;

@property (nonatomic, copy) NetworkTaskCompletion completion;

@property (nonatomic, assign) BOOL isBatchTask;

+ (instancetype)requestWithBlock:(void (^)(BaseRequest *))block;

@end

#pragma mark - BaseSessionManagerDelegate

@protocol BaseSessionManagerDelegate <NSObject>

@required

/// Parse the raw response data to BaseResponse object.
/// @param sessionManager The attached session manager
/// @param request The corresponding request
/// @param responseObject Raw response data
/// @param task The attached task
/// @param error Response error
/// @return Response result object
- (BaseResponse *)sessionManager:(BaseSessionManager *)sessionManager request:(__kindof BaseRequest *)request completeWithResponse:(id)responseObject task:(NSURLSessionDataTask *)task error:(NSError *)error;

@optional

/// Entry for sending request.
/// @param sessionManager The attached session manager
/// @param request The corresponding request
- (void)sessionManager:(BaseSessionManager *)sessionManager sendingRequest:(__kindof BaseRequest *)request;

/// Entry for resolving the response globally.
/// @param sessionManager The attached session manager
/// @param request The corresponding request
/// @param response The parsed response
/// @return context result to tell the client end response routes.
- (id)sessionManager:(BaseSessionManager *)sessionManager resolveRequest:(__kindof BaseRequest *)request response:(BaseResponse *)response;

/// Entry for finishing request.
/// @param sessionManager The attached session manager
/// @param request The corresponding request
/// @param response The parsed response
- (void)sessionManager:(BaseSessionManager *)sessionManager finishRequest:(__kindof BaseRequest *)request response:(BaseResponse *)response;

@end

#pragma mark - BaseSessionManager

@interface BaseSessionManager : AFHTTPSessionManager

/**
   Send the request with corresponding delegate.

   @note Both the request and delegate will be retained till the request get response.

   @param request     The request to be sent
   @param delegate    The delegate used for the request status
 */
- (void)sendRequest:(BaseRequest *)request delegate:(id<BaseSessionManagerDelegate>)delegate;

@end
