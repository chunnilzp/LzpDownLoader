//
//  ZipoLeeDownLoadManager.m
//  Downloader
//
//  Created by 李泽平 on 2018/8/27.
//  Copyright © 2018年 李泽平. All rights reserved.
//

#import "ZipoLeeDownLoadManager.h"
#import "LZPDownLoad.h"

/**
    每次实例化一个 manager 对应一个文件下载操作！！！
    如果该操作没有执行完毕，不需要再开启！！
    解决思路：下载缓冲池！
 
 */

@interface ZipoLeeDownLoadManager()

///下载操作的缓冲池
@property (nonatomic, strong) NSMutableDictionary *downLoadCache;

@property (nonatomic, copy) void(^failedBlock)(NSString *);

@end

@implementation ZipoLeeDownLoadManager

- (NSMutableDictionary *)downLoadCache{
    if (!_downLoadCache) {
        _downLoadCache = [[NSMutableDictionary alloc] init];
    }
    return _downLoadCache;
}

+ (instancetype)shareDownLoadManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (void) downLoadWithUrl:(NSURL *)url progress:(void(^)(float progress))progress completion:(void(^)(NSString *filePath))completion failed:(void(^)(NSString *error))failed{
    //1.判断缓冲池是否存在改下载任务
    LZPDownLoad *downLoad = self.downLoadCache[url.path];
    if (downLoad != nil) {
        NSLog(@"正在下载中");
        return;
    }
    self.failedBlock = failed;
    //2.创建新的下载任务
    downLoad = [[LZPDownLoad alloc] init];
    //3.将下载任务放入缓冲池
    [self.downLoadCache setObject:downLoad forKey:url.path];
    
    //开始下载任务
    /** 下载完成之后清除下载操作
        问题：下载完成是异步的回调
     */
    [downLoad downLoadWithUrl:url progress:progress completion:^(NSString *filePath) {
        //1.在缓冲池中删除下载操作
        [self.downLoadCache removeObjectForKey:url.path];
        //2.调用方的回调
        if (completion) {
            completion(filePath);
        }
    } failed:^(NSString *error) {
        //1.在缓冲池中删除下载操作
        [self.downLoadCache removeObjectForKey:url.path];
        //2.调用方的回调
        if (failed) {
            failed(error);
        }
    }];
}

- (void)pause:(NSURL *)url{
    //通过url获取下载任务
    LZPDownLoad *downLoad = self.downLoadCache[url.path];
    if (downLoad == nil && self.failedBlock) {
        self.failedBlock(@"已暂停");
        return;
    }
    //暂停下载任务
    [downLoad pause];
    //从缓冲池中删除下载任务
    [self.downLoadCache removeObjectForKey:url.path];
}

@end
