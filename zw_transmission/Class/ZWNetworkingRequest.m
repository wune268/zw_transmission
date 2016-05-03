//
//  ZWNetworkingRequest.m
//  zw_transmission
//
//  Created by zzwu on 16/5/3.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import "ZWNetworkingRequest.h"
#import "AFNetworking.h"
#import "ZWFileObject.h"

@implementation ZWNetworkingRequest

+(void)zw_postWithURL:(NSString *)URLString
               params:(NSDictionary *)paramsDict
        formDataArray:(NSArray *)formDataArray
             progress:(void (^)(NSProgress *))progress
              success:(void (^)(id))success
              failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];    
    [manager POST:URLString parameters:paramsDict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (ZWFormData *zwFormData in formDataArray) {
            [formData appendPartWithFileData:zwFormData.data name:zwFormData.name fileName:zwFormData.filename mimeType:zwFormData.mimeType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end

@implementation ZWFormData


@end
