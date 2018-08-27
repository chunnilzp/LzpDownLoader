//
//  DownLoadCell.m
//  Downloader
//
//  Created by 李泽平 on 2018/8/27.
//  Copyright © 2018年 李泽平. All rights reserved.
//

#import "DownLoadCell.h"
#import "DownModel.h"

@implementation DownLoadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.progressView];
        [self addSubview:self.btnPause];
    }
    return self;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(100, 20, self.frame.size.width - 160, 4)];
        _progressView.progressTintColor = [UIColor blueColor];
    }
    return _progressView;
}

- (UIButton *)btnPause{
    if (!_btnPause) {
        _btnPause = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnPause.backgroundColor = [UIColor lightGrayColor];
        _btnPause.frame = CGRectMake(self.frame.size.width - 50, 5, 40, 34);
        [_btnPause setTitle:@"暂停" forState:UIControlStateNormal];
        [_btnPause setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _btnPause;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"progress"]) {
        DownModel *model = (DownModel *)object;
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.progressView.progress = model.progress;
        });
    }
}


@end
