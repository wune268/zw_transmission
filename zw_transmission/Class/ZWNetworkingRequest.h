//
//  ZWNetworkingRequest.h
//  zw_transmission
//
//  Created by zzwu on 16/5/3.
//  Copyright © 2016年 zzwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWNetworkingRequest : NSObject

/**
 *  发送一个POST请求(上传文件数据)
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param formData  文件参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)zw_postWithURL:(NSString *)URLString
                params:(NSDictionary *)paramsDict
         formDataArray:(NSArray *)formDataArray
              progress:(void (^)(NSProgress *uploadProgress))progress
               success:(void (^)(id json))success
               failure:(void (^)(NSError *error))failure;

@end

/**
 *  用来封装文件数据的模型
 */
@interface ZWFormData : NSObject
/**
 *  文件数据
 */
@property (nonatomic, strong) NSData *data;

/**
 *  参数名
 */
@property (nonatomic, copy) NSString *name;

/**
 *  文件名
 */
@property (nonatomic, copy) NSString *filename;

/**
 *  文件类型
 */
@property (nonatomic, copy) NSString *mimeType;

@end
