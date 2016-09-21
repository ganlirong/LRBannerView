//
//  LRBannerView.h
//  LRBannerView
//
//  Created by 甘立荣 on 15/5/26.
//  Copyright (c) 2015年 甘立荣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, LRBannerScrollDirection) {
    // 水平滚动
    LRBannerScrollDirectionHorizontal,
    // 垂直滚动
    LRBannerScrollDirectionVertical
};

typedef NS_ENUM(NSInteger, BannerViewPageStyle) {
    PageStyle_None,
    PageStyle_Left,
    PageStyle_Right,
    PageStyle_Middle
};

typedef void(^ImageDownloadFinishBlock)(void);
typedef void(^ImageDownloadFailureBlock)(void);
typedef void(^DidSelectImageBlock)(NSInteger);


@interface LRBannerView : UIView<UIScrollViewDelegate> {
    UIScrollView *_scrollView;
    UIButton *_closeButton;
    NSInteger _totalPage;
    NSInteger _currentPage;
    NSUInteger _totalCount;
}

@property (nonatomic, strong) NSArray *imagesArray;// 存放所有需要滚动的图片URL NSString
@property (nonatomic, assign) LRBannerScrollDirection scrollDirection;// scrollView滚动的方向
@property (nonatomic, assign) NSTimeInterval rollingDelayTime;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) BOOL enableScroll;
@property (nonatomic, copy) ImageDownloadFinishBlock downloadFinoshBlock;
@property (nonatomic, copy) ImageDownloadFailureBlock downloadFailureBlock;
@property (nonatomic, copy) DidSelectImageBlock didSelectImageBlock;

- (id)initWithFrame:(CGRect)frame
    scrollDirection:(LRBannerScrollDirection)direction
             images:(NSArray *)images;

- (void)reloadBannerWithData:(NSArray *)images;
- (void)startDownloadImage;
- (void)setSquare:(NSInteger)asquare; //设置圆角
- (void)setPageControlStyle:(BannerViewPageStyle)pageStyle;
- (void)showCloseButton:(BOOL)show;
- (void)startScroll;
- (void)stopScroll;
- (void)refreshScrollView;


@end
