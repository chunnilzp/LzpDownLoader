//
//  LZPDownLoadManager.h
//  Downloader
//
//  Created by 李泽平 on 2018/8/24.
//  Copyright © 2018年 李泽平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZPDownLoad : NSObject

/** 下载指定url的文件
    1.下载进度  - 通知下载的百分比
    2.是否完成  - 通知下载保存的路径
    3.是否出错  - 通知错误信息
 
    代理 / Block / 通知公告
 */
- (void) downLoadWithUrl:(NSURL *)url progress:(void(^)(float progress))progress completion:(void(^)(NSString *filePath))completion failed:(void(^)(NSString *error))failed;

//暂定当前操作
- (void) pause;

@end
