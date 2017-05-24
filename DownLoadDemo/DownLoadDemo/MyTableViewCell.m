//
//  MyTableViewCell.m
//  DownLoadDemo
//
//  Created by 住梦iOS on 2017/5/24.
//  Copyright © 2017年 qiongjiwuxian. All rights reserved.
//

#import "MyTableViewCell.h"

#define UISCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define UISCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@implementation MyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (UILabel *)downloadNameLabel{
    if (!_downloadNameLabel) {
        _downloadNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, UISCREENWIDTH/2-10, 30)];
        [self.contentView addSubview:_downloadNameLabel];
    }
    return _downloadNameLabel;
}
- (UIProgressView *)downloadProgressView{
    if (!_downloadProgressView) {
        _downloadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(70, 60, UISCREENWIDTH/2, 20)];
        [self.contentView addSubview:_downloadProgressView];
    }
    return _downloadProgressView;
}
- (UILabel *)downloadAlreadyDownloadLabel{
    if (!_downloadAlreadyDownloadLabel) {
        _downloadAlreadyDownloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 60, 20)];
        _downloadAlreadyDownloadLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_downloadAlreadyDownloadLabel];
    }
    return _downloadAlreadyDownloadLabel;
}
- (UILabel *)downloadTotalByteLabel{
    if (!_downloadTotalByteLabel) {
        _downloadTotalByteLabel = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2+80, 60, 60, 20)];
        _downloadTotalByteLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_downloadTotalByteLabel];
    }
    return _downloadTotalByteLabel;
}
- (UILabel *)downloadSpeedLabel{
    if (!_downloadSpeedLabel) {
        _downloadSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(UISCREENWIDTH/2+80, 10, 80, 30)];
        [self.contentView addSubview:_downloadSpeedLabel];
        _downloadSpeedLabel.font = [UIFont systemFontOfSize:14];
    }
    return _downloadSpeedLabel;
}
- (UIButton *)downloadButton{
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_downloadButton setFrame:CGRectMake(UISCREENWIDTH-60, 30, 40, 40)];
        [_downloadButton setTitle:@"下载" forState:UIControlStateNormal];
        [self.contentView addSubview:_downloadButton];
    }
    return _downloadButton;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
