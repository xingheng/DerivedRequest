//
//  GenericTask.h
//  DerivedRequest
//
//  Created by WeiHan on 09/01/2018.
//

#import <DerivedRequest/BaseTask.h>

typedef Class (^SessionManagerClassGetter)(void);
typedef void (^RequestSetter)(BaseRequest *request);
typedef BaseSessionManager * (^SessionManagerGetter)();
typedef NetworkResponseDataHandler (^ResponseHandlerGetter)(void);
typedef void (^ResponseSetter)(BaseResponse *response);


/**
   GenericTask is designed as a sealed class for one-off tasks to send request easily and quickly.
 */
@interface GenericTask : BaseTask

- (GenericTask *(^)(SessionManagerClassGetter getter))setSessionManagerClass;

- (GenericTask *(^)(RequestSetter setter))requestEntity;

- (GenericTask *(^)(NetworkTaskProgress progress))progress;

- (GenericTask *(^)(NetworkTaskCompletion completion))completion;

- (GenericTask *(^)(DataTaskCompletion taskCompletion))taskCompleted;

- (GenericTask *(^)(ResponseHandlerGetter getter))responseHandlerBlock;

- (GenericTask *(^)(void))send;

@end

#pragma mark - Functions

GenericTask * NewGenericTask(void);
