//
//  JLPathManager.h
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DownloadPath [JLPathManager sharedPathManager]

#define MB (1024*1024.0)


@interface JLPathManager : NSObject

// 此处是第一个模块
@property (nonatomic, strong) NSString *alreadyDownloadPath; // 已经下载下来的数据存放的位置。
@property (nonatomic, retain) NSString *downloadedPlistPath; // 正在下载进度信息保存的路径
@property (nonatomic, retain) NSString *tempStr; // 临时文件路径

// 使用单例获取对象。
+(JLPathManager *)sharedPathManager;
// 判断正在下载的plist文件中是否存在该下载。
- (BOOL)existTaskWithUrl:(NSString *)str;


@end
