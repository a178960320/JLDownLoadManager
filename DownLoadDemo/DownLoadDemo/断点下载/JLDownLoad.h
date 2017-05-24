//
//  JLDownLoad.h
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLDownLoad : NSObject


@property (nonatomic, retain) NSURL *URL; // 下载地址
@property (nonatomic, retain) NSString *saveName; // 文件存储名
@property (nonatomic, retain) NSString *urlString; // 网址字符（可转化为上面的URL属性）
@property (nonatomic, assign) BOOL isFinish; // 是否完成
@property (nonatomic, assign) BOOL isDownloading; // 下载中
@property (nonatomic, copy) void(^loadingBlock)(long long, float, float, float, NSString *); // 下载回调
@property (nonatomic, copy) void(^complet)(); // 完成回调
@property (nonatomic, copy) void(^error)(); // 错误回调
@property (nonatomic, retain) NSString *showName; // 下载中展示的名字
@property (nonatomic, retain) NSString *duration; // 展示时间
@property (nonatomic, retain) NSString *flagStr; // 管理下载标签的

// 声明3个属性，用于计算下载速度
@property (nonatomic, assign) long long bytesRead;
@property (nonatomic, retain) NSString *speed;
@property (nonatomic, retain) NSDate *date;

// 初始化方法
- (instancetype)initWithUrl:(NSString *)urlStr flag:(NSString *)flagStr;
// 开始下载
- (void)start;
// 暂停下载
- (void)suspended;
// 取消下载
- (void)cancel;


@end
