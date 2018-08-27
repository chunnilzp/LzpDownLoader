//
//  ZipoLeeDownLoadManager.h
//  Downloader
//
//  Created by 李泽平 on 2018/8/27.
//  Copyright © 2018年 李泽平. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZipoLeeDownLoadManager : NSObject

+ (instancetype)shareDownLoadManager;

- (void) downLoadWithUrl:(NSURL *)url progress:(void(^)(float progress))progress completion:(void(^)(NSString *filePath))completion failed:(void(^)(NSString *error))failed;

- (void)pause:(NSURL *)url;

@end
