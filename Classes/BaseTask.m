//
//  BaseTask.m
//  DerivedRequest
//
//  Created by WeiHan on 5/22/17.
//  Copyright © 2017 Wei Han. All rights reserved.
//

#import "BaseTask.h"

#pragma mark - BaseTask

@interface BaseTask ()

@property (nonatomic, strong) __kindof BaseRequest *request;

@property (nonatomic, strong) __kindof BaseResponse *response;

@property (nonatomic, assign) BOOL isBatchTask;  // default is NO

@end

@implementation BaseTask

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, request: %@, session manager: %@, %@", [super description], self.request, self.sessionManager, self.response];
}

#pragma mark - Public

+ (instancetype)task
{
    BaseTask *task = [self new];

    task.sessionManagerClass = [BaseSessionManager class];

    return task;
}

+ (instancetype)taskAsBatchItem
{
    BaseTask *task = [self task];

    task.isBatchTask = YES;
    return task;
}

- (void)sendRequest:(NSString *)requestURL
             method:(HTTPMethod)method
         parameters:(id)parameters
         completion:(NetworkTaskCompletion)completionBlock
{
    [self sendRequest:requestURL method:method parameters:parameters progress:nil completion:completionBlock];
}

- (void)sendRequest:(NSString *)requestURL
             method:(HTTPMethod)method
         parameters:(id)parameters
           progress:(NetworkTaskProgress)taskProgress
         completion:(NetworkTaskCompletion)completionBlock
{
    NSAssert(self.sessionManager, @"Setup a request instance before sending request.");

    BaseRequest *request = [BaseRequest requestWithBlock:^(BaseRequest *request) {
        request.requestURL = requestURL;
        request.method = method;
        request.parameters = parameters;
        request.progress = taskProgress;
        request.completion = completionBlock;
        request.isBatchTask = self.isBatchTask;
    }];

    self.request = request;

    // From this time, the BaseSessionManager/AFHTTPSessionManager/NSURLSession
    //  retains the current task, too. Its retain count won't be decreased until
    //  the task completion be executed.
    [self.sessionManager sendRequest:request delegate:self];
}

- (void)resendRequest
{
    self.response = nil;

    NSAssert(self.sessionManager, @"Setup a request instance before sending request.");
    NSAssert(self.request, @"Invalid request entity was found before resending.");

    [self.sessionManager sendRequest:self.request delegate:self];
}

#pragma mark - Property

- (__kindof BaseSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [self.sessionManagerClass new];
    }

    return _sessionManager;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    BaseTask *task = [[self class] allocWithZone:zone];

    if (task) {
        task.request = [self.request copyWithZone:zone];

        task.sessionManager = [self.sessionManager copyWithZone:zone];
        task.sessionManagerClass = [self.sessionManagerClass copy];

        task.responseHandler = self.responseHandler;
        // task.response = self.response; When should we need it?
    }

    return task;
}

#pragma mark - BaseSessionManagerDelegate

- (void)sessionManager:(BaseSessionManager *)sessionManager sendingRequest:(__kindof BaseRequest *)request
{
    // NSLog(@"Sending request %@", request);
}

- (BaseResponse *)sessionManager:(BaseSessionManager *)sessionManager request:(__kindof BaseRequest *)request completeWithResponse:(id)responseObject task:(NSURLSessionDataTask *)task error:(NSError *)error
{
    BaseResponse *response = nil;

    if (self.responseHandler) {
        response = self.responseHandler(responseObject, error);
    } else {
        response = CreateResponse(responseObject, 0, error.localizedDescription, nil, error);
    }

    self.response = response;
    return response;
}

- (void)sessionManager:(BaseSessionManager *)sessionManager finishRequest:(__kindof BaseRequest *)request
{
    // NSLog(@"Finished request %@", request);
}

@end
