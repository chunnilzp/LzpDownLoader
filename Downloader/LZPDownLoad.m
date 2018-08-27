//
//  LZPDownLoadManager.m
//  Downloader
//
//  Created by 李泽平 on 2018/8/24.
//  Copyright © 2018年 李泽平. All rights reserved.
//

/** 目的 -----> 下载
 1. 先实现一个简单的下载功能
 2. 对外提供接口
 */

#import "LZPDownLoad.h"
#import "DownModel.h"

/** NSURLSession 下载
    1. 跟踪进度
    2. 断点续传，问题L这个resumeData丢失，再次下载的时候，无法续传！！
        考虑解决方案：
        - 将文件保存在固定的位置
        - 再次下载文件前，先检查固定的位置是否存在文件
        - 如果有，
 */

#define OutTime 20

@interface LZPDownLoad()<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *con;

//输出流
@property (nonatomic, strong) NSOutputStream *stream;

//下载文件的总大小
@property (nonatomic, assign) long long expectedContentLength;

//已下载的文件大小
@property (nonatomic, assign) long long currentSize;

//已下载的文件地址
@property (nonatomic, strong) NSString *filePath;

//下载地址
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, assign) CFRunLoopRef runLoop;

//-----------------block-----------------
@property (nonatomic, copy) void(^progressBlock)(float);

@property (nonatomic, copy) void(^completionBlock)(NSString *);

@property (nonatomic, copy) void(^failedBlock)(NSString *);
@end

@implementation LZPDownLoad


//这个方法给外界提供，内部不要写“碎代码”
- (void) downLoadWithUrl:(NSURL *)url progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed{
    self.progressBlock = progress;
    self.completionBlock = completion;
    self.failedBlock = failed;
    self.url = url;
    //1.检查服务器文件大小
    [self serverFileInfoWithUrl:url];
        
    //2.检查本地文件大小
    if (![self checkLocalFileInfo]) {
        NSLog(@"文件已存在！！！");
        completion(self.filePath);
        return;
    }
    
    //3.如果需要，从服务器开始下载！！
    [self downloadFile];
}

#pragma mark - <下载文件>
- (void)downloadFile{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //1.建立请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:1 timeoutInterval:OutTime];
        //设下瞎子的字节范围，从self.currentSize 开始之后所有的字节
        NSString *rangStr = [NSString stringWithFormat:@"bytes=%lld-", self.currentSize];
        //设置请求头字段
        [request setValue:rangStr forHTTPHeaderField:@"Range"];
        
        //2.开始网络连接
        self.con = [NSURLConnection connectionWithRequest:request delegate:self];
        [self.con start];
        
        self.runLoop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    });
}

#pragma mark - <私有方法>
/**
 
    return  YES需要下载，NO不用下载
 */
//检查本地文件大小
- (BOOL)checkLocalFileInfo{
    long long fileSize = 0;
    //1.文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        //2.获取文件大小
        fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL].fileSize;
        
    }
    self.currentSize = fileSize;
    //3.比较文件大小
    if (fileSize < self.expectedContentLength) {
        //3.1如果本地文件大小小于服务器文件大小，执行断点续传
        
    }else if (fileSize == self.expectedContentLength){
        //3.2如果本地文件大小等于服务器文件大小, 直接使用本地文件
        return NO;
    }else{
        //3.3如果本地文件大小大于服务器文件大小，删除本地文件，重新下载
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        fileSize = 0;
        return YES;
    }
    return YES;
}



//检查服务器文件大小
- (void)serverFileInfoWithUrl:(NSURL *)url{
    //1.请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:OutTime];
    request.HTTPMethod = @"HEAD";
    //解决无法获取文件的实际大小
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    //2.建立网络连接
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    //3.记录服务器的文件信息
    //3.1 文件大小
    self.expectedContentLength = response.expectedContentLength;
    //3.2 建议保存的文件名，将在文件保存在tmp，系统会自动回收
    self.filePath = [NSTemporaryDirectory() stringByAppendingString:response.suggestedFilename];
    return;
}

#pragma mark - <NSURLConnectionDataDelegate>
//1.接收到服务器的响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //打开输出流
    self.stream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    [self.stream open];
}

//2.接收到数据，用输出流拼接，计算下载进度
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //追求数据
    [self.stream write:data.bytes maxLength:[data length]];
    //更新已下载数据长度
    self.currentSize += [data length];
    float progress = (float)self.currentSize/self.expectedContentLength;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

//3.所有下载完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //关闭输出流
    [self.stream close];
    CFRunLoopStop(self.runLoop);
    if (self.completionBlock) {
        dispatch_sync(dispatch_get_main_queue(), ^{self.completionBlock(self.filePath);});
    }
}

//4.下载错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.stream close];
    if (self.failedBlock) {
        dispatch_sync(dispatch_get_main_queue(), ^{self.failedBlock(error.localizedDescription);});
    }
    CFRunLoopStop(self.runLoop);
}


#pragma mark - <暂停>
- (void) pause{
    [self.con cancel];
}



@end
