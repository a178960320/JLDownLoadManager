//
//  JLDownLoad.m
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import "JLDownLoad.h"
#import "JLPathManager.h"

@interface JLDownLoad ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation JLDownLoad

#pragma mark - 懒加载
- (NSURLSession *)session{ // 建立请求
    if (_session == nil) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue currentQueue]];
    }
    return _session;
}
- (NSString *)saveName{
    // 如果没有设置文件名称，则使用网址的文件名称
    if (_saveName == nil) {
        NSURLResponse *ss = [[NSURLResponse alloc] initWithURL:[NSURL URLWithString:self.urlString] MIMEType:nil expectedContentLength:1 textEncodingName:nil];
        _saveName = ss.suggestedFilename;
        // 也可以获取到其他的下载用到的信息。
    }
    return _saveName;
}
- (void)cancel{
    // 取消下载。
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
    self.downloadTask = nil;
}
#pragma mark - 对象的初始化
- (instancetype)initWithUrl:(NSString *)urlStr flag:(NSString *)flagStr{
    if ([super init]) {
        self.urlString = urlStr;
        self.isDownloading = NO;
        self.isFinish = NO;
        self.flagStr = flagStr;
        // 判断本地的Download.plist文件中是否存在下载
        if ([DownloadPath existTaskWithUrl:urlStr]) {
            // 存在，则获取到已下载的内容，然后继续下载
            self.downloadTask = [self.session downloadTaskWithResumeData:[self getResumeData]];
        }else{ // 不存在，则创建
            self.URL = [NSURL URLWithString:urlStr];
            self.downloadTask = [self.session downloadTaskWithURL:self.URL];
            self.date = [NSDate date];
        }
    }
    return self;
}
#pragma mark - 开始下载
- (void)start{
    
    self.isDownloading = YES;
    // 继续下载
    if ([self getResumeData]) {
        self.downloadTask = [self.session downloadTaskWithResumeData:[self getResumeData]];
    }
    [self.downloadTask resume];
}
#pragma mark - 下载完成调用的方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSString *savePath = [NSString stringWithFormat:@"%@%@", DownloadPath.alreadyDownloadPath, self.saveName];
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
    NSMutableDictionary *dic = [plist objectForKey:self.urlString];
    if (dic) {
        [dic setObject:@"complete" forKey:@"state"];
        // 留给外界的借口。下载的标签。
        [dic setObject:savePath forKey:@"savePath"];
        // 将此字典更新至plist文件中
        [plist setObject:dic forKey:self.urlString];
        // 更新数据库
        [plist writeToFile:DownloadPath.downloadedPlistPath atomically:YES];
    }
    // 如果下载完成的block已经实现，则执行
    if (self.complet) {
        self.complet();
    }
    self.isFinish = YES;
    // 将下载在临时文件里的文件移至相对应的文件。
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:savePath error:nil];
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finished" object:self];
}
#pragma mark - 定期发送的下载进度的通知
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    // 判断是否存在当前的下载plist文件中
    if (![DownloadPath existTaskWithUrl:self.urlString]) {
        // 第一次走的时候，应该没有写入plist
        [self saveResumeData];
    }else{
        // 获取到等待下载的文件
        NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([plist objectForKey:self.urlString]) {
            dic = [plist objectForKey:self.urlString];
        }
        [dic setObject:[NSString stringWithFormat:@"%.1f", totalBytesWritten/MB] forKey:@"already"];
        [dic setObject:@"loading" forKey:@"state"];
        
        [dic setObject:[NSString stringWithFormat:@"%.1f", totalBytesExpectedToWrite/MB] forKey:@"totalBytes"];
        [plist setObject:dic forKey:self.urlString];
        [plist writeToFile:DownloadPath.downloadedPlistPath atomically:YES];
        [self saveResumeData];
    }
    // 如果正在下载的block实现了，则调取相应的block
    if (self.loadingBlock) {
        self.bytesRead = self.bytesRead + bytesWritten;
        NSDate *currentDate = [NSDate date];
        double time = [currentDate timeIntervalSinceDate:self.date];
        if (time > 2) {
            // 计算速度
            long long speed = self.bytesRead/time;
            // 把速度转化为KB或M
            self.speed = [self formatByteCount:speed];
            // 维护变量，将计算过的清零
            self.bytesRead = 0.0;
            self.date = currentDate;
            self.loadingBlock(bytesWritten,(float)totalBytesWritten/(float)totalBytesExpectedToWrite,(totalBytesExpectedToWrite/MB),(totalBytesWritten/MB), self.speed);
        }
    }
}
// 把速度转化为KB或者M
- (NSString *)formatByteCount:(long long)size{
    return [NSString stringWithFormat:@"%@/s",[NSByteCountFormatter stringFromByteCount:size  countStyle:NSByteCountFormatterCountStyleFile]];
}

// 将下载信息保存到本地
- (void)saveResumeData{ // 主要是完成了先将未名下载信息进行解析，获取其真正的信息。然后再接着下载。
    __weak typeof(self) vc = self;
    // 此方法就是要获取刚开始下载的那些data，先通过取消下载，获取到data，然后将data内的数据存储到本地。之后再data的基础上继续下载。
    [vc.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        if (resumeData) {
            // 将当前信息更新至plist文件中，
            [vc parsingResumeData:resumeData];
            vc.downloadTask = nil;
            // 保存完信息之后开始继续下载。（不知道什么情况下会存在下载的东西不是自己点击的? 我知道了，就是要实现退出app还可以断点下载的。我去！）
            vc.downloadTask = [self.session downloadTaskWithResumeData:resumeData];
            // 继续下载
            [vc.downloadTask resume];
        }
    }];
    self.isFinish = NO;
}
// 此方法就是解析未名的下载信息，以获取需要的信息
- (void)parsingResumeData:(NSData *)resumeData{
    NSString *dataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
    NSString *integerStr = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>"].lastObject;
    // 记录当前的文件大小，以便断点下载是将实际文件大小替换。
    NSString *fileSize = [integerStr componentsSeparatedByString:@"</integer>"].firstObject;
    // 获取临时文件的名称
    //    NSString *tmpPath = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeInfoLocalPath</key>\n\t<string>"].lastObject;
    //    tmpPath = [tmpPath componentsSeparatedByString:@"</string>"].firstObject;
    NSString *tmpPath = [dataString componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject;
    tmpPath = [tmpPath componentsSeparatedByString:@"</string>"].firstObject;
    // 写入记录
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
    NSMutableDictionary *dic = [plist objectForKey:self.urlString];
    if (!dic) {
        dic = [[NSMutableDictionary alloc] init];
    }
    [dic setObject:tmpPath forKey:@"tempName"];
    [dic setObject:self.saveName forKey:@"fileName"];
    [dic setObject:fileSize forKey:@"fileSize"];
    [dic setObject:dataString forKey:@"dataString"];
    [dic setObject:@"loading" forKey:@"state"];
    [dic setObject:self.urlString forKey:@"httpAdd"];
    [plist setObject:dic forKey:self.urlString];
    [plist writeToFile:DownloadPath.downloadedPlistPath atomically:false];
}
// 获取已下载的data
- (NSData *)getResumeData{
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
    NSMutableDictionary *dic = [plist objectForKey:self.urlString];
    NSString *dataString = [dic objectForKey:@"dataString"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileSize;
    // 遍历获取所有临时文件大小
    NSArray *arr = [[NSFileManager defaultManager] subpathsAtPath:DownloadPath.tempStr];
    for (NSString *str in arr) {
        if ([str isEqualToString:dic[@"tempName"]]) {
            NSString *filePath = [DownloadPath.tempStr stringByAppendingString:str];
            // 将当前文件的长度值，即llu类型的转化为NSString类型。
            if ([fileManager fileExistsAtPath:filePath]) {
                fileSize = [NSString stringWithFormat:@"%llu", [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize]];
            }
        }
    }
    // 将实际文件大小替换到dataString中
    dataString = [dataString stringByReplacingOccurrencesOfString:[dic objectForKey:@"fileSize"] withString:fileSize];
    return [dataString dataUsingEncoding:NSUTF8StringEncoding];
}
// 暂停
- (void)suspended{
    [self.downloadTask suspend];
}
#pragma mark - ------ 错误
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"请求失效，error：%@", error);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (self.error) {
        self.error();
    }
}
@end
