//
//  GenericTask.h
//  DerivedRequest
//
//  Created by WeiHan on 09/01/2018.
//

#import <DerivedRequest/BaseTask.h>

typedef BaseSessionManager * (^SessionManagerGetter)();
typedef void (^RequestSetter)(BaseRequest *request);
typedef NetworkResponseDataHandler (^ResponseHandlerGetter)();
typedef void (^ResponseSetter)(BaseResponse *response);


/**
   GenericTask is designed as a sealed class for one-off tasks to send request easily and quickly.
 */
@interface GenericTask : BaseTask

- (GenericTask *(^)(SessionManagerGetter getter))setSessionManager;

- (GenericTask *(^)(RequestSetter setter))sendRequest;

- (GenericTask *(^)(NetworkTaskProgress progress))progress;

- (GenericTask *(^)(NetworkTaskCompletion completion))completion;

- (GenericTask *(^)(DataTaskCompletion taskCompletion))taskCompleted;

- (GenericTask *(^)(ResponseHandlerGetter getter))responseHandlerBlock;

- (GenericTask *(^)())send;

@end

#pragma mark - Functions

GenericTask * NewGenericTask(void);
