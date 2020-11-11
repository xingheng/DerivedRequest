//
//  GenericTask.m
//  DerivedRequest
//
//  Created by WeiHan on 09/01/2018.
//

#import "GenericTask.h"

@interface GenericTask ()

@property (nonatomic, strong) BaseRequest *request;

@property (nonatomic, copy) DataTaskCompletion taskCompletion;

@end

@implementation GenericTask

@dynamic request;

#pragma mark - Public

#define AssumeTaskRequest(__request__)        \
    BaseRequest * __request__ = self.request; \
    if (!__request__)                         \
    {                                         \
        __request__ = [BaseRequest new];      \
        self.request = __request__;           \
    }

- (GenericTask *(^)(SessionManagerClassGetter getter))setSessionManagerClass
{
    AssumeTaskRequest(request);

    return ^id (SessionManagerClassGetter getter) {
               self.sessionManagerClass = getter ? getter() : nil;
               NSAssert([self.sessionManagerClass.new isKindOfClass:BaseSessionManager.class], @"Invalid session manager class!");
               return self;
    };
}

- (GenericTask *(^)(RequestSetter setter))requestEntity
{
    AssumeTaskRequest(request);

    return ^id (RequestSetter setter) {
               setter ? setter(request) : nil;
               return self;
    };
}

- (GenericTask *(^)(NetworkTaskProgress progress))progress
{
    AssumeTaskRequest(request);

    return ^id (NetworkTaskProgress progress) {
               request.progress = progress;
               return self;
    };
}

- (GenericTask *(^)(NetworkTaskCompletion completion))completion
{
    AssumeTaskRequest(request);

    return ^id (NetworkTaskCompletion completion) {
               request.completion = completion;
               return self;
    };
}

- (GenericTask *(^)(DataTaskCompletion taskCompletion))taskCompleted
{
    AssumeTaskRequest(request);

    return ^id (DataTaskCompletion taskCompletion) {
               self.taskCompletion = taskCompletion;
               return self;
    };
}

- (GenericTask *(^)(ResponseHandlerGetter getter))responseHandlerBlock
{
    return ^id (ResponseHandlerGetter getter) {
               self.responseHandler = getter ? getter() : nil;
               return self;
    };
}

- (GenericTask *(^)(void))send
{
    return ^id () {
               // From this time, the BaseSessionManager/AFHTTPSessionManager/NSURLSession
               //  retains the current task, too. Its retain count won't be decreased until
               //  the task completion be finished.
               [self.sessionManager sendRequest:self.request delegate:self];
               return self;
    };
}

#pragma mark - BaseSessionManagerDelegate (Override)

- (BaseResponse *)sessionManager:(BaseSessionManager *)sessionManager request:(__kindof BaseRequest *)request completeWithResponse:(id)responseObject task:(NSURLSessionDataTask *)task error:(NSError *)error
{
    BaseResponse *response = [super sessionManager:sessionManager request:request completeWithResponse:responseObject task:task error:error];

    if ([request isEqual:self.request] && self.taskCompletion) {
        self.taskCompletion(response, task);
    }

    return response;
}

@end


#pragma mark - Functions

GenericTask * NewGenericTask()
{
    return [GenericTask task];
}
