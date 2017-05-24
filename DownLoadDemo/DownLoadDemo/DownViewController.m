//
//  DownViewController.m
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import "DownViewController.h"
#import "JLDownLoadManager.h"
#import "MyTableViewCell.h"

@interface DownViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation DownViewController



- (NSArray *)taskArr{
    return [JLDownLoadManager sharedDownloadManager].taskArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.myTableView.rowHeight = 100;
    
    [self.myTableView registerClass:[MyTableViewCell class] forCellReuseIdentifier:@"downloadCell"];
    
    [JLDownLoadManager sharedDownloadManager].reloadData = ^(){
        [self.myTableView reloadData];
    };
    
    for (JLDownLoad *task in self.taskArr) {
        NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
        NSMutableDictionary *dic = [plist objectForKey:task.urlString];
        if ([dic[@"state"] isEqualToString:@"loading"]) {
            if (task.isDownloading == YES) {
            }else{
                [task start];
            }
            task.date = [NSDate date];
        }
    }
}



// tableView的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.taskArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadCell" forIndexPath:indexPath];
    JLDownLoad *task = self.taskArr[indexPath.row];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
    NSDictionary *taskDic = plist[task.urlString];
    task.loadingBlock = ^(long long current, float progress, float all, float writ, NSString *speed){
        cell.downloadProgressView.progress = progress;
        cell.downloadAlreadyDownloadLabel.text = [NSString stringWithFormat:@"%.1fMB", writ];
        cell.downloadTotalByteLabel.text = [NSString stringWithFormat:@"%.1fMB", all];
        cell.downloadSpeedLabel.text = speed;
    };
    cell.downloadNameLabel.text = [taskDic objectForKey:@"showName"];
    if (taskDic[@"already"]) {
        cell.downloadAlreadyDownloadLabel.text = [NSString stringWithFormat:@"%@MB", taskDic[@"already"]];
        cell.downloadTotalByteLabel.text = [NSString stringWithFormat:@"%@MB", taskDic[@"totalBytes"]];
        cell.downloadProgressView.progress = [taskDic[@"already"] floatValue]/[taskDic[@"totalBytes"] floatValue];
        cell.downloadSpeedLabel.text = @"0 KB/s";
    }else{
        cell.downloadAlreadyDownloadLabel.text = @"0MB";
        cell.downloadTotalByteLabel.text = @"∞MB";
        cell.downloadProgressView.progress = 0;
    }
    if ([taskDic[@"state"] isEqualToString:@"waiting"]) {
        [cell.downloadButton setTitle:@"暂停" forState:UIControlStateNormal];
    }else{
        [cell.downloadButton setTitle:@"下载" forState:UIControlStateNormal];
    }
    
    [cell.downloadButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)downloadAction:(UIButton *)sender{
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:DownloadPath.downloadedPlistPath];
    MyTableViewCell *cell = (MyTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    JLDownLoad *task = self.taskArr[indexPath.row];
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
    
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
