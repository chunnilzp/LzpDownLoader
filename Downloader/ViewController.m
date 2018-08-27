//
//  ViewController.m
//  Downloader
//
//  Created by 李泽平 on 2018/8/24.
//  Copyright © 2018年 李泽平. All rights reserved.
//



#import "ViewController.h"
//#import "LZPDownLoadManager.h"
#import "DownLoadCell.h"
#import "DownModel.h"
#import "ZipoLeeDownLoadManager.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *aryData;

@property (nonatomic, strong) NSMutableArray *aryModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"下载管理器"];
    self.aryData = [[NSMutableArray alloc] initWithArray:@[@"QQ", @"weCat"]];
    self.aryModel = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.aryData.count; i++) {
        DownModel *model = [[DownModel alloc] init];
        model.progress = 0;
        model.isKvo = NO;
        [self.aryModel addObject:model];
    }
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

//tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.aryData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"ContactListCell";
    DownLoadCell *cell = (DownLoadCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DownLoadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.aryData[indexPath.row];
    DownModel *model = self.aryModel[indexPath.row];
    cell.progressView.progress = model.progress;
    cell.btnPause.tag = indexPath.row;
    [cell.btnPause addTarget:self action:@selector(pauseDownLoad:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DownModel *model = self.aryModel[indexPath.row];
    NSURL *url = [NSURL URLWithString:@"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.0.dmg"];
    if (indexPath.row == 1) {
        url = [NSURL URLWithString:@"https://dldir1.qq.com/weixin/mac/WeChat_2.3.18.18.dmg"];
    }
    [[ZipoLeeDownLoadManager shareDownLoadManager] downLoadWithUrl:url progress:^(float progress) {
        model.progress = progress;
    } completion:^(NSString *filePath) {
        model.filePath = filePath;
        NSLog(@"下载成功======文件地址：%@", model.filePath);
    } failed:^(NSString *error) {
        NSLog(@"下载失败:%@", error);
    }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    DownModel *model = self.aryModel[indexPath.row];
    if (!model.isKvo) {
        [model addObserver:cell forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    DownModel *model = self.aryModel[indexPath.row];
    if (model.isKvo) {
        [cell removeObserver:model forKeyPath:@"progress"];
    }
}

- (IBAction)pauseDownLoad:(UIButton *)btn{
    NSURL *url = [NSURL URLWithString:@"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.0.dmg"];
    if (btn.tag == 1) {
        url = [NSURL URLWithString:@"https://dldir1.qq.com/weixin/mac/WeChat_2.3.18.18.dmg"];
    }
    [[ZipoLeeDownLoadManager shareDownLoadManager] pause:url];
}

@end
