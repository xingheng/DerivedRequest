//
//  BaseResponse.m
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import "BaseResponse.h"

@interface BaseResponse ()

@property (nonatomic, strong) id rawData;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) NSUInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id data;

@property (nonatomic, assign) BaseResponseState state;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id> *_stateInfo;

@end

@implementation BaseResponse

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error
{
    BaseResponse *response = [self responseWithData:rawData error:error code:0 message:nil data:nil];

    response.state = BaseResponseStateIdle;
    return response;
}

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error
                            code:(NSUInteger)code
                         message:(NSString *)message
                            data:(id)data
{
    BaseResponse *response = [self new];

    response.rawData = rawData;
    response.error = error;
    response.code = code;
    response.message = message;
    response.data = data;
    response.state = BaseResponseStateReady;

    return response;
}

- (void)markAsReady:(id)context
{
    self.state = BaseResponseStateReady;
    self._stateInfo[@(BaseResponseStateReady)] = context;
}

- (void)markAsResolved:(id)context
{
    self.state = BaseResponseStateResolved;
    self._stateInfo[@(BaseResponseStateResolved)] = context;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Response: code: %ld, message: %@, data: %@", (long)self.code, self.message, self.data];
}

#pragma mark - Property

- (NSString *)message
{
    if (!_message) {
        _message = self.error.localizedDescription;
    }

    return _message;
}

- (NSDictionary<NSNumber*, id> *)stateInfo
{
    return [self._stateInfo copy];
}

- (NSMutableDictionary<NSNumber*, id> *)_stateInfo
{
    if (!__stateInfo) {
        __stateInfo = [NSMutableDictionary new];
    }

    return __stateInfo;
}

@end
