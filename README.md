# JLDownLoadManager
一个断点下载工具，封装自urlsession，支持断点下载，杀进程后可以继续下载。

![img](http://recordit.co/IhJOkS9CC8.gif)

## 简介
JLDownLoadManager包括三个部分：
### 一、首先是JLPathManager,这个是用来管理文件下载路径和缓存数据存储路径。
```Objective-C
 // 已经下载下来的数据存放的位置。
@property (nonatomic, strong) NSString *alreadyDownloadPath;

// 正在下载进度信息保存的路径
@property (nonatomic, retain) NSString *downloadedPlistPath; 

// 临时文件路径
@property (nonatomic, retain) NSString *tempStr; 
```
### 二、接下来是下载任务JLDownLoad,这个部分是所有下载任务的类型，处理下载任务的各种操作，包括任务开始、任务暂停、任务取消、任务进度回调、任务完成回调。
```Objective-C
// 初始化方法，可以通过下载链接的str进行初始化。
- (instancetype)initWithUrl:(NSString *)urlStr flag:(NSString *)flagStr;

// 开始下载
- (void)start;

// 暂停下载
- (void)suspended;

// 取消下载
- (void)cancel;
```

### 三、最后一部分是任务的管理中心JLDownLoadManager，用于所有下载任务的管理。

```Objective-C
//枚举值作为任务的当前状态
typedef NS_ENUM(NSInteger){
    Finish,  // 任务添加完成
    Complete,  // 已经下载完成
    Loading  // 正在下载中
}DownloadBackType;

// 设置默认最大并发数为5
#define DMaxDownloadCount 5

// 所有的任务
@property (nonatomic ,strong) NSMutableArray *taskArr; 

// 根据下载链接添加下载任务，回调参数为添加结果
- (void)addTaskSaveName:(NSString *)name urlStr:(NSString *)urlStr flag:(NSString *)flagStr 
duration:(NSString *)duration backType:(void(^)(DownloadBackType type))type;

// 无论下载是否完成，删除任务同时删除文件，可在block中实现block的回调。
- (void)deleteTaskWithUrl:(NSString *)urlStr complete:(void(^)())complete;

// 返回已经完成的任务
- (NSMutableArray *)finishedTasks;

// 暂停一个任务
- (void)suspendTask:(JLDownLoad *)task;

// 开启任务 ，如果达到并发数，你希望提示用户，将代码写在block中
- (void)begainTasks:(JLDownLoad *)task arriveMax:(void(^)())max;

```
## 使用
>1.首先下载demo,将断点下载的文件导入工程中，需要用到下载的页面导入头文件JLDownLoadManager;

>2.添加下载任务，任务自动开始
```Objective-C
[[JLDownLoadManager sharedDownloadManager] addTaskSaveName:self.titleArr[indexPath.row] urlStr:self.urlArr[indexPath.row] flag:@"标签" duration:@"" backType:^(DownloadBackType type) {
        if (type == Finish) {
            NSLog(@"添加成功");
        }else{
            NSLog(@"任务存在");
        }
    }];
```
>3.任务下载中的回调
```Objective-C
JLDownLoad *task = self.taskArr[indexPath.row];

task.loadingBlock = ^(long long current, float progress, float all, float writ, NSString *speed){
        cell.downloadProgressView.progress = progress; //进度
        cell.downloadAlreadyDownloadLabel.text = [NSString stringWithFormat:@"%.1fMB", writ];//已经下载文件大小
        cell.downloadTotalByteLabel.text = [NSString stringWithFormat:@"%.1fMB", all];//原文件大小
        cell.downloadSpeedLabel.text = speed;//下载速度,两秒刷新一次
};

```
>4.任务暂停与开始
```Objective-C
//拿到存储下载中任务的plist
NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
//拿到任务
JLDownLoad *task = self.taskArr[indexPath.row];
//给tempDic赋值，如果正在下载就把状态改为waiting、反之改为loading。
NSMutableDictionary *tempDic = [plist objectForKey:task.urlString];
    if ([[tempDic objectForKey:@"state"] isEqualToString:@"loading"]){
        [tempDic setObject:@"waiting" forKey:@"state"];
        [plist setObject:tempDic forKey:task.urlString];
        [plist writeToFile:DownloadPath.downloadedPlistPath atomically:YES];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        cell.downloadSpeedLabel.text = @"0 KB/s";
        [[JLDownLoadManager sharedDownloadManager] suspendTask:task];
        [task cancel];
    }else{
        [tempDic setObject:@"loading" forKey:@"state"];
        [plist setObject:tempDic forKey:task.urlString];
        [plist writeToFile:DownloadPath.downloadedPlistPath atomically:YES];
        [sender setTitle:@"下载" forState:UIControlStateNormal];
        task.date = [NSDate date];
        [task start];
    }

```
>5.任务下载完成的回调
[JLDownLoadManager sharedDownloadManager].reloadData = ^(){
        [self.myTableView reloadData];
};

