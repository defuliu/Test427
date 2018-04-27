//
//  ZGHttpRequest.m
//  ZGZhishu
//
//  Created by 杨佳 on 2018/1/30.
//  Copyright © 2018年 Melvins. All rights reserved.
//

#import "ZGHttpRequest.h"
#import "AFNetworking.h"
#define kSecretKey        @"blm.carrier.key"



@implementation ZGHttpRequest


+(ZGHttpRequest *)shareRequest
{
    
    return [[[self class] alloc] init];
}

// L2
+ (NSDictionary *)requestParameterPackage:(NSDictionary *)dict confusedID:(NSString *)handleID secretKey:(NSString *)key
{
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSArray * keyArray = [dict allKeys];

    Class myClazz = NSClassFromString(@"ZGFCoreUtil");
    SEL  selector = NSSelectorFromString(@"convertNullOrNil:");
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    for (NSString * key in keyArray) {
        
        [params setObject:[myClazz performSelector:selector withObject:dict[key] ]  forKey:key];
    }
    
    [params setObject:handleID forKey:@"appId"];
    //sign
    NSString *testString =[[[self class] generateSignString:params secretKey:key] uppercaseString];
    
    [params setObject:[myClazz performSelector:selector withObject:testString] forKey:@"sign"];
#pragma clang diagnostic pop
    
    return params;
}


+ (NSString *)generateSignString:(NSDictionary *)dict
{
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    // 加密方式修改为只按照key来排序
    NSArray *keyArray = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *uniArray = [NSMutableArray array];
    
    for (NSString *keyStr in keyArray) {
        NSString *str = [NSString stringWithFormat:@"%@%@", keyStr, dict[keyStr]];
        [uniArray addObject:str];
        
    }
    //    NSArray *sortedArray = [uniArray sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *str in uniArray) {
        [result appendString:[NSString stringWithFormat:@"%@", str]];
    }
    
    Class myClazz = NSClassFromString(@"ZGFToolUtil");
    SEL selector = NSSelectorFromString(@"md5:");
    
    NSString *retStr = [NSString stringWithFormat:@"%@%@",  result, kSecretKey];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [myClazz performSelector:selector withObject:retStr];
#pragma clang diagnostic pop
}


+ (NSString *)generateSignString:(NSDictionary *)dict secretKey:(NSString *)key
{
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    // 加密方式修改为只按照key来排序
    NSArray *keyArray = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *uniArray = [NSMutableArray array];
    
    for (NSString *keyStr in keyArray) {
        NSString *str = [NSString stringWithFormat:@"%@%@", keyStr, dict[keyStr]];
        [uniArray addObject:str];
        
    }
    //    NSArray *sortedArray = [uniArray sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *str in uniArray) {
        [result appendString:[NSString stringWithFormat:@"%@", str]];
    }
    
    Class myClazz = NSClassFromString(@"ZGFToolUtil");
    SEL selector = NSSelectorFromString(@"md5:");
    
    NSString *retStr = [NSString stringWithFormat:@"%@%@",  result, kSecretKey];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [myClazz performSelector:selector withObject:retStr];
#pragma clang diagnostic pop
}

- (void)mainHttpPostRequestInterface:(NSDictionary *)dict
                          requestUrl:(NSString *)url
                    replaceForNewUrl:( NSString *)newUrl
                      replacedOldUrl:( NSString *)oldUrl
                      whetherReplace:(BOOL)ifReplace
                             success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask  *operation,NSError *error ))failure
{
      Class myClazz = NSClassFromString(@"ZGFCoreUtil");
      SEL selector = NSSelectorFromString(@"convertNullOrNil:");
    
    __block BOOL requestMark = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *replaceMark = [myClazz performSelector:selector withObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"changeRequestUrl"]];
    newUrl = [myClazz performSelector:selector withObject:newUrl];
    oldUrl = [myClazz performSelector:selector withObject:oldUrl];
#pragma clang diagnostic pop
    
    if ((ifReplace == YES||[replaceMark isEqualToString:@"haveChangeRequestUrl"])&&(![newUrl isEqualToString:@""]&&![oldUrl isEqualToString:@""])) {
        url = [url stringByReplacingOccurrencesOfString:oldUrl withString:newUrl];
        requestMark = YES;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 系统状态栏请求状态的Activity
    // [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    //[[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer  = [AFJSONRequestSerializer  serializer];
    if (![[ZGHttpRequest convertNullOrNil:_httpTimeoutInterval] isEqualToString:@""]) {
        manager.requestSerializer.timeoutInterval = [_httpTimeoutInterval integerValue];
    }
    
    if (![ZGHttpRequest chackEmptyArray:_acceptableContentTypes]) {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:_acceptableContentTypes];
    }
    else {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    }
    
    if (_httpHeaderFieldDic.allKeys.count > 0) {
        for (NSString *keyStr in [_httpHeaderFieldDic allKeys]) {
            [manager.requestSerializer setValue:_httpHeaderFieldDic[keyStr] forHTTPHeaderField:keyStr];
        }
    }
    
    if (_customizeCachePolicy != NSURLRequestReloadIgnoringLocalAndRemoteCacheData && _customizeCachePolicy != NSURLRequestReloadRevalidatingCacheData) {
        [manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }
    
    //发送请求
    [manager POST:url parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([jsonString rangeOfString:@"null"].length > 0) {
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
        }
        requestMark = YES;
        NSData *completeData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        success(task,completeData);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if ((ifReplace == YES||![replaceMark isEqualToString:@"haveChangeRequestUrl"])&&(![newUrl isEqualToString:@""]&&![oldUrl isEqualToString:@""])&&requestMark == NO) {
            
           NSString *replaceUrl = [url stringByReplacingOccurrencesOfString:oldUrl withString:newUrl];
            [[NSUserDefaults standardUserDefaults] setObject:@"haveChangeRequestUrl" forKey:@"changeRequestUrl"];
            [manager POST:replaceUrl parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if ([jsonString rangeOfString:@"null"].length > 0) {
                    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
                }
                [[NSUserDefaults standardUserDefaults] setObject:@"haveChangeRequestUrl" forKey:@"changeRequestUrl"];
                requestMark = YES;
                NSData *completeData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                success(task,completeData);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                requestMark = YES;
               // [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                failure (task, error);
            }];
        }
        else {
            requestMark = YES;
           // [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
            failure (task, error);
        }
    }];
    
}

- (void)mainHttpGetRequestInterface:(NSString *)url
                   replaceForNewUrl:(NSString *)newUrl
                     replacedOldUrl:(NSString *)oldUrl
                     whetherReplace:(BOOL)ifReplace
                            success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
                            failure:(void (^)(NSURLSessionDataTask *operation,NSError *error ))failure
{
    __block BOOL requestMark = NO;
    
    Class myClazz = NSClassFromString(@"ZGFCoreUtil");
    SEL selector = NSSelectorFromString(@"convertNullOrNil:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *replaceMark = [myClazz performSelector:selector withObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"changeRequestUrl"]];
    newUrl = [myClazz performSelector:selector withObject:newUrl];
    oldUrl = [myClazz performSelector:selector withObject:oldUrl];
#pragma clang diagnostic pop
    

    if ((ifReplace == YES||[replaceMark isEqualToString:@"haveChangeRequestUrl"])&&(![newUrl isEqualToString:@""]&&![oldUrl isEqualToString:@""])) {
        url = [url stringByReplacingOccurrencesOfString:oldUrl withString:newUrl];
        requestMark = YES;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (![[ZGHttpRequest convertNullOrNil:_httpTimeoutInterval] isEqualToString:@""]) {
        manager.requestSerializer.timeoutInterval = [_httpTimeoutInterval integerValue];
    }
    if (![ZGHttpRequest chackEmptyArray:_acceptableContentTypes]) {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:_acceptableContentTypes];
    }
    else {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    }
    
    if (_httpHeaderFieldDic.allKeys.count > 0) {
        for (NSString *keyStr in [_httpHeaderFieldDic allKeys]) {
            [manager.requestSerializer setValue:_httpHeaderFieldDic[keyStr] forHTTPHeaderField:keyStr];
        }
    }
    
    //发送请求
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        requestMark = YES;
        success(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ((ifReplace == YES||![replaceMark isEqualToString:@"haveChangeRequestUrl"])&&(![newUrl isEqualToString:@""]&&![oldUrl isEqualToString:@""])&&requestMark == NO) {
            [manager GET:replaceMark parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [[NSUserDefaults standardUserDefaults] setObject:@"haveChangeRequestUrl" forKey:@"changeRequestUrl"];
                requestMark = YES;
                success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                requestMark = YES;
                failure (task,error);
            }];
        }
        else {
            requestMark = YES;
            failure (task,error);
        }
        
    }];
    
}

- (void)statisticsUMHttpRequestCount:(NSString *)requestUMKey
{
    Class myClazz = NSClassFromString(@"MobClick");
    SEL selector = NSSelectorFromString(@"event:");
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ZGUMSettingKey"] isEqualToString:@"ZGUMHttpSettingValue"]&&![[ZGHttpRequest convertNullOrNil:requestUMKey] isEqualToString:@""]) {
        [myClazz performSelector:selector withObject:requestUMKey];
    }
    #pragma clang diagnostic pop
}

+ (NSString *)convertNullOrNil:(NSString *)str
{
    if (str != nil || str != NULL || str.length > 0) {
        return str;
    }
    else{
        return @"";
    }
}

+ (BOOL)chackEmptyArray:(NSArray *)array
{
    if (!array || [array isKindOfClass:[NSNull class]] || array.count <= 0) {
        return YES;
    } else {
        return NO;
    }
}

/***********缓存处理************/

//清理所有的网络缓存
+ (void)removeAllCachedResponses
{
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
}

//清理某个请求的缓存
+ (void)removeSomeoneCachedResponses:(NSString *)requestUrl
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeCachedResponseForRequest:request];
}

//不设置缓存，针对于网络请求，图片类的请求会照样
+ (void)notSetCachedResponses
{
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

//设置默认的缓存大小，内存512k，硬盘10M
+ (void)setDefaultCachedResponses
{
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:512 *1024
                                                            diskCapacity:10 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

//设置自定义的缓存大小，memoryNum为内存，diskNum为硬盘，大小为1K的倍数
+ (void)setCustomizeCachedResponses:(NSUInteger)memoryNum diskCapacity:(NSUInteger)diskNum
{
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryNum *1024
                                                            diskCapacity:diskNum * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}

@end

