//
//  ViewController.m
//  LRBannerView
//
//  Created by 甘立荣 on 15/5/26.
//  Copyright (c) 2015年 甘立荣. All rights reserved.
//

#import "ViewController.h"
#import "LRBannerView.h"

//定义设备屏幕的高度
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

//定义设备屏幕的宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect tableRect = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64);
    UITableView *tableView = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    
    NSMutableArray *viewsArray = [NSMutableArray arrayWithObjects:@"http://pimg1.126.net/caipiao_info/images/headFigure/appad/1431931708669_1.jpg", @"http://pimg1.126.net/caipiao_info/images/headFigure/appad/1431931708781_2.jpg",@"http://pimg1.126.net/caipiao_info/images/headFigure/appad/1431338659702_1.jpg" ,@"http://pimg1.126.net/caipiao_info/images/headFigure/appad/1431338659745_2.jpg", nil];
    
    LRBannerView *bannerView = [[LRBannerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)
                                                   scrollDirection:LRScrollDirectionHorizontal
                                                            images:viewsArray];
    [bannerView setRollingDelayTime:4.0];
    [bannerView setPageControlStyle:PageStyle_Middle];
    [bannerView startScroll];
    tableView.tableHeaderView = bannerView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
