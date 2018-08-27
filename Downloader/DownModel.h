//
//  DownModel.h
//  Downloader
//
//  Created by 李泽平 on 2018/8/24.
//  Copyright © 2018年 李泽平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZPDownLoad.h"

@interface DownModel : NSObject

@property (nonatomic, strong) NSString *downLoadPath;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, assign) float progress;

@property (nonatomic, assign) BOOL isKvo;

@end
