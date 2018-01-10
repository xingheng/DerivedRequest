//
//  BaseSessionManager.m
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import "BaseSessionManager.h"

#pragma mark - BaseRequest

@interface BaseRequest ()

// Used in - isEqual: to compare current request and generated from copyWithZone:.
@property (nonatomic, copy) NSString *identifier;

@end

@implementation BaseRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.identifier = [NSUUID UUID].UUIDString;
    }

    return self;
}

+ (instancetype)requestWithBlock:(void (^)(BaseRequest *))block
{
    BaseRequest *request = [BaseRequest new];

    if (block) {
        block(request);
    }

    return request;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: URL: %@, method: %@, parameters: %@", NSStringFromClass([self class]),
            self.requestURL, HTTPMethodString(self.method), self.parameters];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.identifier isEqualToString:((BaseRequest *)object).identifier];
    }

    return [super isEqual:object];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    BaseRequest *request = [[self class] allocWithZone:zone];

    if (request) {
        request.identifier = [self.identifier copyWithZone:zone];
        request.requestURL = [self.requestURL copyWithZone:zone];
        request.method = self.method;
        request.parameters = [self.parameters copyWithZone:zone];
        request.progress = [self.progress copy];
        request.completion = [self.completion copy];
        request.isBatchTask = self.isBatchTask;
    }

    return request;
}

@end

#pragma mark - BaseSessionManager

@interface BaseSessionManager ()

@property (nonatomic, strong) NSMutableDictionary<BaseRequest *, id<BaseSessionManagerDelegate> > *requests;

@end

@implementation BaseSessionManager

#pragma mark - Public

- (void)sendRequest:(BaseRequest *)request delegate:(id<BaseSessionManagerDelegate>)delegate
{
    if (request.isBatchTask) {
        return;
    }

    self.requests[request] = delegate ? : [NSNull null];

    if (delegate) {
        [delegate sessionManager:self sendingRequest:request];
    }

    NSString *requestURL = request.requestURL;
    HTTPMethod method = request.method;
    id parameters = request.parameters;
    NetworkTaskProgress taskProgress = request.progress;

    __weak typeof(self) weakSelf = self;

    id successBlock = ^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _responseCallback:task request:request response:responseObject error:nil];
    };

    id failureBlock = ^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf _responseCallback:task request:request response:nil error:error];
    };

    if (taskProgress && (method == HTTPMethodPut || method == HTTPMethodDelete)) {
        NSLog(@"taskProgress is invalid for PUT and DELETE request!");
    }

    switch (method) {
        case HTTPMethodGet:
            [self      GET:requestURL
                parameters:parameters
                  progress:taskProgress
                   success:successBlock
                   failure:failureBlock];
            break;

        case HTTPMethodPost:
            [self POST:requestURL
            parameters:parameters
              progress:taskProgress
               success:successBlock
               failure:failureBlock];
            break;

        case HTTPMethodPut:
            [self      PUT:requestURL
                parameters:parameters
                   success:successBlock
                   failure:failureBlock];
            break;

        case HTTPMethodDelete:
            [self DELETE:requestURL
              parameters:parameters
                 success:successBlock
                 failure:failureBlock];
            break;
    }
}

#pragma mark - Property

- (NSMutableDictionary<BaseRequest *, id<BaseSessionManagerDelegate> > *)requests
{
    if (!_requests) {
        _requests = [NSMutableDictionary new];
    }

    return _requests;
}

#pragma mark - Private

- (void)_responseCallback:(NSURLSessionDataTask *)task request:(BaseRequest *)request response:(id)responseObject error:(NSError *)error
{
    BaseResponse *response = nil;

    id<BaseSessionManagerDelegate> delegate = self.requests[request];

    if (delegate && ![delegate isEqual:[NSNull null]]) {
        response = [delegate sessionManager:self request:request completeWithResponse:responseObject task:task error:error];
    } else {
        response = responseObject ? : error;
        NSLog(@"No delegate to handle this response! %@. %@. %@", request, response, error);
    }

    NetworkTaskCompletion completionBlock = request.completion;

    if (completionBlock) {
        completionBlock(response);
    }

    // Make sure the BaseSessionManager itself could be release after finishing all the tasks.
    // https://github.com/AFNetworking/AFNetworking/issues/2149
    [self invalidateSessionCancelingTasks:NO];

    if (delegate && ![delegate isEqual:[NSNull null]]) {
        [delegate sessionManager:self finishRequest:request];
    }

    // Once the request completion is done, release the strong delegate reference explictly.
    [self.requests removeObjectForKey:request];
}

@end


#pragma mark - Functions

NSString * HTTPMethodString(HTTPMethod method)
{
    switch (method) {
        case HTTPMethodGet:
            return @"GET";

        case HTTPMethodPost:
            return @"POST";

        case HTTPMethodPut:
            return @"PUT";

        case HTTPMethodDelete:
            return @"DELETE";

        default:
            return nil;
    }
}
