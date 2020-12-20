//
//  BaseResponse.h
//  DerivedRequest
//
//  Created by WeiHan on 2/25/16.
//  Copyright © 2016 Wei Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseRequest;

typedef NS_ENUM(NSUInteger, BaseResponseState) {
    BaseResponseStateIdle,
    BaseResponseStateReady,
    BaseResponseStateResolved,
};

#define RETURN_IFNOT_READY(_response_)      if ((_response_).state != BaseResponseStateReady) return
#define RETURN_IFNOT_RESOLVED(_response_)   if ((_response_).state != BaseResponseStateResolved) return


@interface BaseResponse : NSObject

@property (nonatomic, strong, readonly, nonnull) id rawData;
@property (nonatomic, strong, readonly, nullable) NSError *error;

@property (nonatomic, assign, readonly) NSUInteger code;
@property (nonatomic, copy, readonly, nullable) NSString *message;
@property (nonatomic, strong, readonly, nullable) id data;

@property (nonatomic, assign, readonly) BaseResponseState state;
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSNumber/*<BaseResponseState>*/*, id> *stateInfo;

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error;

+ (instancetype)responseWithData:(id)rawData
                           error:(NSError *)error
                            code:(NSUInteger)code
                         message:(NSString *)message
                            data:(id)data;

- (void)markAsReady:(id)context;

- (void)markAsResolved:(id)context;

@end

typedef BaseResponse * (*NetworkResponseDataHandler)(BaseRequest *request, id responseObject, NSError *error);
typedef id (*NetworkResponseInterceptor)(BaseRequest *request, BaseResponse *response);
