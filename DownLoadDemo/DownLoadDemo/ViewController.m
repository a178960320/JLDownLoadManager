//
//  ViewController.m
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import "ViewController.h"
#import "JLDownLoadManager.h"
#import "DownViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) NSArray *urlArr;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.urlArr = @[@"http://sw.bos.baidu.com/sw-search-sp/software/447feea06f61e/QQ_mac_5.5.1.dmg",@"http://down.360safe.com/se/360se8.1.1.404.exe"];
    self.titleArr = @[@"qq_mac版",@"360_windows版"];
}


#pragma mark - tableView协议方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urlArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.titleArr[indexPath.row];
    cell.detailTextLabel.text = @"点击下载";
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[JLDownLoadManager sharedDownloadManager] addTaskSaveName:self.titleArr[indexPath.row] urlStr:self.urlArr[indexPath.row] flag:@"标签" duration:@"接口" backType:^(DownloadBackType type) {
        if (type == Finish) {
            NSLog(@"添加成功");
        }else{
            NSLog(@"任务存在");
        }
    }];
}


@end
