//
//  MyTableViewCell.h
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (nonatomic, retain) UILabel *downloadNameLabel; // 展示文件名称的
@property (nonatomic, retain) UIProgressView *downloadProgressView; // 展示进度
@property (nonatomic, retain) UILabel *downloadAlreadyDownloadLabel; // 已经下载的
@property (nonatomic, retain) UILabel *downloadTotalByteLabel; // 问件大小
@property (nonatomic, retain) UILabel *downloadSpeedLabel; // 下载速度
@property (nonatomic, retain) UIButton *downloadButton; // 下载或者暂停按钮

@end
