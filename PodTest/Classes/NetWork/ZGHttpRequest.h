//
//  ZGHttpRequest.h
//  ZGZhishu
//
//  Created by 杨佳 on 2018/1/30.
//  Copyright © 2018年 Melvins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGHttpRequest : NSObject

//超时时间设置
@property (nonatomic, strong) NSString *httpTimeoutInterval;

//请求支持的Content-Type
@property (nonatomic, strong) NSMutableArray *acceptableContentTypes;

//请求头设置
@property (nonatomic, strong) NSMutableDictionary *httpHeaderFieldDic;

/*
 NSURLRequestUseProtocolCachePolicy = 0,     默认的缓存策略
 
 NSURLRequestReloadIgnoringLocalCacheData = 1,      忽略本地缓存数据，直接请求服务端.
 NSURLRequestReloadIgnoringLocalAndRemoteCacheData = 4, // Unimplemented 未实现
 NSURLRequestReloadIgnoringCacheData = NSURLRequestReloadIgnoringLocalCacheData,
 
 NSURLRequestReturnCacheDataElseLoad = 2,   有缓存就使用，不管其有效性(即忽略Cache-Control字段), 无则请求服务端.
 NSURLRequestReturnCacheDataDontLoad = 3,   死活加载本地缓存. 没有就失败. (确定当前无网络时使用)
 
 NSURLRequestReloadRevalidatingCacheData = 5, // Unimplemented 未实现
 */

@property (nonatomic, assign) NSURLRequestCachePolicy customizeCachePolicy;

//友盟统计请求的数目
- (void)statisticsUMHttpRequestCount:(NSString *)requestUMKey;

+(ZGHttpRequest *)shareRequest;

// L2
+ (NSDictionary *)requestParameterPackage:(NSDictionary *)dict confusedID:(NSString *)handleID secretKey:(NSString *)key;

// L3
+ (NSString *)generateSignDic:(NSDictionary *)dict AES256EncryptWithKey:(NSString *)key;

//post请求
- (void)mainHttpPostRequestInterface:(NSDictionary *)dict
                          requestUrl:(NSString *)url
                    replaceForNewUrl:(NSString *)newUrl
                      replacedOldUrl:(NSString *)oldUrl
                      whetherReplace:(BOOL)ifReplace
                             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask *operation,NSError *error ))failure;

//get请求
- (void)mainHttpGetRequestInterface:(NSString *)url
                   replaceForNewUrl:(NSString *)newUrl
                     replacedOldUrl:(NSString *)oldUrl
                     whetherReplace:(BOOL)ifReplace
                            success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                            failure:(void (^)(NSURLSessionDataTask *operation,NSError *error ))failure;

//设置自定义的缓存大小，memoryNum为内存，diskNum为硬盘，大小为1K的倍数
+ (void)setCustomizeCachedResponses:(NSUInteger)memoryNum diskCapacity:(NSUInteger)diskNum;

//设置默认的缓存大小，内存512k，硬盘10M
+ (void)setDefaultCachedResponses;

//不设置缓存，针对于网络请求
+ (void)notSetCachedResponses;

//清理某个请求的缓存
+ (void)removeSomeoneCachedResponses:(NSString *)requestUrl;

//清理所有的网络缓存
+ (void)removeAllCachedResponses;

@end

