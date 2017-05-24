//
//  JLDownLoadManager.h
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLDownLoad.h"
#import "JLPathManager.h"


typedef NS_ENUM(NSInteger){
    Finish,  // 任务添加完成
    Complete,  // 已经下载完成
    Loading  // 正在下载中
}DownloadBackType;

@interface JLDownLoadManager : NSObject



// 设置最大并发数
#define DMaxDownloadCount 5

@property (nonatomic ,strong) NSMutableArray *taskArr; // 所有的任务
@property (nonatomic, copy) void(^reloadData)(); // 回调刷新block

+ (JLDownLoadManager *)sharedDownloadManager;

// 需要自己管理下载对象时使用这个方法，这个对象不会加入下载中心。当然也支持断点续传。
- (JLDownLoad *)addTaskSaveName:(NSString *)name UrlStr:(NSString *)urlStr flag:(NSString *)flagStr;

// 回调参数为添加结果
- (void)addTaskSaveName:(NSString *)name urlStr:(NSString *)urlStr flag:(NSString *)flagStr duration:(NSString *)duration backType:(void(^)(DownloadBackType type))type;

// 任务是否已经下载完成
- (BOOL)completeFileWithUrl:(NSString *)urlStr;

// 文件是否已经存在于本地中
- (BOOL)exsitTaskWithUrl:(NSString *)urlStr;

// 删除任务同时删除文件。无论下载是否完成，有时候网速比较快，如果任务正在下载，取消会有0.5秒延迟。可在block中实现block的回调。
- (void)deleteTaskWithUrl:(NSString *)urlStr complete:(void(^)())complete;

// 返回已经完成的任务
- (NSMutableArray *)finishedTasks;

// 暂停一个任务
- (void)suspendTask:(JLDownLoad *)task;

// 开启任务 ，如果达到并发数，你希望提示用户，将代码写在block中
- (void)begainTasks:(JLDownLoad *)task arriveMax:(void(^)())max;


@end
