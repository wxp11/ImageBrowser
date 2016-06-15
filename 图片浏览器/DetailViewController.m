//
//  DetailViewController.m
//  图片浏览器
//
//  Created by WangXiaopeng on 16/6/10.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import "DetailViewController.h"
#define KDeviceWidth [UIScreen mainScreen].bounds.size.width//屏幕宽
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height//屏幕高
#define KCS_Width scrollView.contentSize.width
#define KCS_Height scrollView.contentSize.height
#define KS_Width scrollView.frame.size.width
#define KS_Height scrollView.frame.size.height
#define KImgNum 15
@interface DetailViewController ()<UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger currentNum;//记录当前页
@property (nonatomic, retain) UIPageControl *pageControl;//分页控制器
@property (nonatomic, retain) UIScrollView *bigScrollView;//底部滑动视图
@property (nonatomic, assign) BOOL zoomTapClick;//记录双击缩放图片
@property (nonatomic, assign) BOOL hiddenNaviBarTapClick;//记录单击显示/隐藏状态栏
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = [NSString stringWithFormat:@"第%d张",self.index + 1];
    //赋初值
    self.zoomTapClick = NO;
    self.hiddenNaviBarTapClick = NO;
    //创建底部滑动视图&小滑动视图&imgView
    [self setupImageView];
    //创建分页控制器
    [self setupPageControl];
}

#pragma mark -- 创建ScrollView 以及imageView
- (void)setupImageView {
    //创建底部滑动视图
    self.bigScrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _bigScrollView.delegate = self;//设置代理
    _bigScrollView.contentSize = CGSizeMake(KDeviceWidth * KImgNum,0);//滑动区域大小
    _bigScrollView.contentOffset = CGPointMake(KDeviceWidth * self.index, 0);//偏移量
    for (int i = 0; i < KImgNum; i++) {
        //创建缩放滑动视图
        UIScrollView *zoomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(KDeviceWidth * i , 0, KDeviceWidth, KDeviceHeight)];
        zoomScrollView.delegate = self;//代理
        zoomScrollView.minimumZoomScale = 0.3;//最小缩放比
        zoomScrollView.maximumZoomScale = 3.0;//最大缩放比
        zoomScrollView.zoomScale = 1.0;//默认值
        zoomScrollView.directionalLockEnabled = NO;//方向锁定关闭
        //创建imgView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(KDeviceWidth * i, 0, KDeviceWidth, KDeviceHeight)];
        imageView.center = self.view.center;
        imageView.tag = 111 + i;
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"风景%02d.jpg",i + 1]];
        imageView.userInteractionEnabled = YES;
        
        //添加单击显示/隐藏导航栏手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        [tap release];
        
        //添加双击缩放手势
        UITapGestureRecognizer *zoomTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomTapAction:)];
        zoomTap.numberOfTapsRequired = 2;
        [imageView addGestureRecognizer:zoomTap];
        [tap requireGestureRecognizerToFail:zoomTap];
        [zoomTap release];
        
        [zoomScrollView addSubview:imageView];
        [_bigScrollView addSubview:zoomScrollView];
        [zoomScrollView release];
        [imageView release];
    }
    _bigScrollView.pagingEnabled = YES;//按页滑动
    [self.view addSubview:_bigScrollView];
    [_bigScrollView release];
}
#pragma mark -- tapAction
- (void)tapAction:(UITapGestureRecognizer *)tap {
    if (!_hiddenNaviBarTapClick) {
        self.navigationController.navigationBarHidden = YES;
        _hiddenNaviBarTapClick = YES;
    } else {
        self.navigationController.navigationBarHidden = NO;
        _hiddenNaviBarTapClick = NO;
    }
}
#pragma mark -- zoomTapAction
-(void)zoomTapAction:(UITapGestureRecognizer *)tap{
    UIScrollView *smallScrollView = (UIScrollView *)tap.view.superview;
    if (!_zoomTapClick) {
        [UIView animateWithDuration:0.3 animations:^{
            smallScrollView.zoomScale = 3.0;
            _zoomTapClick = YES;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            smallScrollView.zoomScale = 1.0;
            _zoomTapClick = NO;
        }];
    }
}

#pragma mark -- 创建PageControl
- (void)setupPageControl {
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, KDeviceHeight - 30, KDeviceWidth, 30)];
    self.pageControl.backgroundColor = [UIColor blackColor];
    self.pageControl.numberOfPages = KImgNum;//页数
    self.pageControl.currentPage = self.index;//当前显示的页码
    [self.pageControl addTarget:self action:@selector(hangdlePageControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pageControl];
    [_pageControl release];
}

#pragma mark -- 点击PageControl实现滑动视图滚动
- (void)hangdlePageControlAction:(UIPageControl *)sender {
    NSInteger index = sender.currentPage;//获取page当前的位置
    CGPoint offset = CGPointMake(index * KDeviceWidth, 0);//将圆点位置作为滑动视图偏移的参考
    [_bigScrollView setContentOffset:offset animated:YES];
    _zoomTapClick = NO;
    self.title = [NSString stringWithFormat:@"第%d张",index + 1];
    
    //滑动下一页上一页还原
    //记录当前的偏移量
    NSInteger currentPage = _bigScrollView.contentOffset.x / KDeviceWidth;
    if (self.currentNum != currentPage) {
        self.currentNum = currentPage;
        for (UIView *view in _bigScrollView.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)view;
                scrollView.zoomScale = 1.0;
            }
        }
    }
}
#pragma mark -- ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.bigScrollView]) {
        NSInteger currentPage = scrollView.contentOffset.x / KDeviceWidth;
        if (self.currentNum!=currentPage) {
            self.currentNum = currentPage;
            for (UIView *view in scrollView.subviews) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    UIScrollView *scrollView = (UIScrollView *)view;
                    scrollView.zoomScale = 1.0;
                }
            }
        }
        _pageControl.currentPage = currentPage;//从新定义pageControl的当前页
        self.title = [NSString stringWithFormat:@"第%d张",currentPage + 1];
        _zoomTapClick = NO;
    }
}

//返回要缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSInteger currentIndex = _bigScrollView.contentOffset.x / KDeviceWidth;
    return [scrollView viewWithTag:111 + currentIndex];
}
//视图已经缩放
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSInteger currentIndex = _bigScrollView.contentOffset.x/KDeviceWidth;
    UIImageView *imageview = (UIImageView *) [scrollView viewWithTag:111 + currentIndex];
    //先提前获取中心点的x
    CGFloat distance_x = KS_Width > KCS_Width ? (KS_Width - KCS_Width) / 2 : 0;
    //y
    CGFloat distance_y = KS_Height > KCS_Height ? (KS_Height - KCS_Height) / 2 : 0;
    //最后一步 居中
    imageview.center = CGPointMake(KCS_Width / 2 + distance_x, KCS_Height / 2 + distance_y);
}

- (void)dealloc {
    [_bigScrollView release];
    [_pageControl release];
    [super dealloc];
}
@end