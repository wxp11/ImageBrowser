//
//  ListViewController.m
//  图片浏览器
//
//  Created by WangXiaopeng on 16/6/10.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import "ListViewController.h"
#import "DetailViewController.h"
#define KDeviceWidth [UIScreen mainScreen].bounds.size.width//屏幕宽
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height//屏幕高
#define KColNum 3 //列数
#define KImgCount 15 //图片个数
@interface ListViewController ()
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片浏览器";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupButton];
}
#pragma mark -- 布局子视图
- (void)setupButton {
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    CGFloat buttonW = KDeviceWidth / KColNum - 5;
    CGFloat buttonH = KDeviceWidth / KColNum - 5;
    CGFloat margin = (KDeviceWidth - KColNum * buttonW) / (KColNum + 1);//间隔
    for (int i = 0; i < KImgCount; i++) {
        int row = i / KColNum;//行号
        int col = i % KColNum;//列号
        CGFloat buttonX = margin + (margin + buttonW) *col;
        CGFloat buttonY = 64 + (margin + buttonH) * row;
        
        //按钮(缩略图)
        UIButton *aButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        aButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [aButton addTarget:self action:@selector(handleButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        aButton.tag = 100 + i;
        [aButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"风景%02d.jpg", i + 1]] forState:UIControlStateNormal];
        [scrollView addSubview:aButton];
    }
    //获取最后一个button的最大y值 为scrollView的contentSize赋值
    UIButton *btn = [scrollView viewWithTag:100 + KImgCount - 1];
    scrollView.contentSize = CGSizeMake(KDeviceWidth, CGRectGetMaxY(btn.frame) + 5);
    [self.view addSubview:scrollView];
    [scrollView release];
}
//点击缩略图查看大图
- (void)handleButtonAction:(UIButton *)sender {
    DetailViewController *detailVC = [[DetailViewController alloc]init];
    detailVC.index = sender.tag - 100; //属性传值
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)dealloc {
    [super dealloc];
}
@end
