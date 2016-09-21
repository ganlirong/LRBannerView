//
//  LRBannerView.m
//  LRBannerView
//
//  Created by 甘立荣 on 15/5/26.
//  Copyright (c) 2015年 甘立荣. All rights reserved.
//

#import "LRBannerView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "LRBannerTouchImageView.h"


static const NSUInteger BannerStartTag = 10000;
static const NSUInteger BannerViewCount = 3;

@implementation LRBannerView

- (id)initWithFrame:(CGRect)frame
    scrollDirection:(LRBannerScrollDirection)direction
             images:(NSArray *)images {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imagesArray = [[NSArray alloc] initWithArray:images];
        self.scrollDirection = direction;
        _totalPage = _imagesArray.count;
        _currentPage = 1;
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        // 在水平方向滚动
        if(_scrollDirection == LRBannerScrollDirectionHorizontal) {
            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*BannerViewCount,
                                                 _scrollView.frame.size.height);
        } else if (_scrollDirection == LRBannerScrollDirectionVertical) { // 在垂直方向滚动
            _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width,
                                                 _scrollView.frame.size.height*BannerViewCount);
        }
        
        for (NSInteger i = 0; i < BannerViewCount; i++) {
            
            LRBannerTouchImageView *imageView = [[LRBannerTouchImageView alloc] initWithFrame:_scrollView.bounds];
            imageView.userInteractionEnabled = YES;
            imageView.tag = BannerStartTag + i;
            imageView.touchBlock = ^{
                [self touchAction];
            };
            // 水平滚动
            if (_scrollDirection == LRBannerScrollDirectionHorizontal) {
                imageView.frame = CGRectOffset(imageView.frame, _scrollView.frame.size.width*i, 0);
            } else if (_scrollDirection == LRBannerScrollDirectionVertical) {// 垂直滚动
                imageView.frame = CGRectOffset(imageView.frame, 0, _scrollView.frame.size.height*i);
            }
            
            [_scrollView addSubview:imageView];
        }
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(5, frame.size.height - 15, 60, 15)];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.numberOfPages = self.imagesArray.count;
        self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        [self addSubview:self.pageControl];
        
        self.pageControl.currentPage = 0;
        [self refreshScrollView];
    }
    
    return self;
}

- (void)reloadBannerWithData:(NSArray *)images {
    
    if (self.enableScroll){
        [self stopScroll];
    }
    
    self.imagesArray = [[NSArray alloc] initWithArray:images];
    _totalPage = _imagesArray.count;
    _totalCount = _totalPage;
    _currentPage = 1;
    self.pageControl.numberOfPages = _totalPage;
    self.pageControl.currentPage = 0;
    [self startDownloadImage];
}

- (void)setSquare:(NSInteger)asquare {
    if (_scrollView){
        _scrollView.layer.cornerRadius = asquare;
        _scrollView.layer.masksToBounds = asquare == 0 ? NO :YES;
    }
}

- (void)setPageControlStyle:(BannerViewPageStyle)pageStyle {
    if (pageStyle == PageStyle_Left) {
        [self.pageControl setFrame:CGRectMake(5, self.bounds.size.height - 15, 60, 15)];
    } else if (pageStyle == PageStyle_Right) {
        [self.pageControl setFrame:CGRectMake(self.bounds.size.width - 5 - 60, self.bounds.size.height - 15, 60, 15)];
    } else if (pageStyle == PageStyle_Middle) {
        [self.pageControl setFrame:CGRectMake((self.bounds.size.width - 60)/2, self.bounds.size.height - 15, 60, 15)];
    } else if (pageStyle == PageStyle_None) {
        [self.pageControl setHidden:YES];
    }
}

- (void)showCloseButton:(BOOL)show {
    if (show) {
        if (!_closeButton) {
            _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_closeButton setFrame:CGRectMake(self.bounds.size.width - 40, 0, 40, 40)];
            [_closeButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
            [_closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [_closeButton setImage:[UIImage imageNamed:@"banner_close.png"] forState:UIControlStateNormal];
            [self addSubview:_closeButton];
        }
        _closeButton.hidden = NO;
    } else {
        if (_closeButton) {
            _closeButton.hidden = YES;
        }
    }
}

- (void)closeButtonAction{
    [self stopScroll];
}

#pragma mark - Custom Method
- (void)startDownloadImage {
    //取消已加入的延迟线程
    if (self.enableScroll) {
        [self cancelDelayAction];
    }
    
    for (NSInteger i = 0; i < _imagesArray.count; ++i) {
        NSString *url = _imagesArray[i];
        if (url){
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url]
                                                            options:0
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                              if (image){
                                                                  [self downImageSuccess];
                                                              } else {
                                                                  [self downImageFailed];
                                                              }
                                                          }];
        }
    }
}

- (void)refreshScrollView {
    
    NSArray *curimageUrls = [self getDisplayImagesWithPageIndex:_currentPage];
    
    for (NSInteger i = 0; i < BannerViewCount; i++) {
        UIImageView *imageView = (UIImageView *)[_scrollView viewWithTag:BannerStartTag + i];
        NSString *url = curimageUrls[i];
        if (imageView && [imageView isKindOfClass:[UIImageView class]] && url) {
            UIImage *defaultImg = [UIImage imageNamed:@"ad_default.png"];
            [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:defaultImg];
        }
    }
    
    // 水平滚动
    if (_scrollDirection == LRBannerScrollDirectionHorizontal) {
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
    } else if (_scrollDirection == LRBannerScrollDirectionVertical) {    // 垂直滚动
        _scrollView.contentOffset = CGPointMake(0, _scrollView.frame.size.height);
    }
    
    self.pageControl.currentPage = _currentPage - 1;
    
}

- (NSArray *)getDisplayImagesWithPageIndex:(NSInteger)page {
    
    NSInteger pre = [self getPageIndex:_currentPage - 1];
    NSInteger last = [self getPageIndex:_currentPage + 1];
    
    NSMutableArray *images = [NSMutableArray array];
    [images addObject:[_imagesArray objectAtIndex:pre - 1]];
    [images addObject:[_imagesArray objectAtIndex:_currentPage - 1]];
    [images addObject:[_imagesArray objectAtIndex:last - 1]];
    
    return images;
    
}

- (NSInteger)getPageIndex:(NSInteger)index {
    // value＝1为第一张，value = 0为前面一张
    if (index == 0) {
        index = _totalPage;
    }
    
    if (index == _totalPage + 1) {
        index = 1;
    }
    
    return index;
}


#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    NSInteger x = aScrollView.contentOffset.x;
    NSInteger y = aScrollView.contentOffset.y;
    
    if (self.enableScroll){
        [self cancelDelayAction];
    }
    
    // 水平滚动
    if(_scrollDirection == LRBannerScrollDirectionHorizontal) {
        //下一张
        if (x >= _scrollView.frame.size.width*2) {
            _currentPage = [self getPageIndex:_currentPage + 1];
            [self refreshScrollView];
        }
        
        if (x <= 0) {
            _currentPage = [self getPageIndex:_currentPage - 1];
            [self refreshScrollView];
        }
    } else if (_scrollDirection == LRBannerScrollDirectionVertical) {    // 垂直滚动
        //下一张
        if (y >= _scrollView.frame.size.height*2) {
            _currentPage = [self getPageIndex:_currentPage + 1];
            [self refreshScrollView];
        }
        
        if (y <= 0) {
            _currentPage = [self getPageIndex:_currentPage - 1];
            [self refreshScrollView];
        }
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    // 水平滚动
    if (_scrollDirection == LRBannerScrollDirectionHorizontal) {
        _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
    } else if (_scrollDirection == LRBannerScrollDirectionVertical) { //// 垂直滚动
        _scrollView.contentOffset = CGPointMake(0, _scrollView.frame.size.height);
    }
    
    if (self.enableScroll) {
        [self delayAction];
    }
}

- (void)startScroll {
    
    if ( self.imagesArray.count < 2){
        return;
    }
    
    [self stopScroll];
    self.enableScroll = YES;
    [self delayAction];
}

- (void)stopScroll{
    
    self.enableScroll = NO;
    [self cancelDelayAction];
    
}

- (void)scrollAction{
    
    [UIView animateWithDuration:0.25 animations:^{
        // 水平滚动
        if(_scrollDirection == LRBannerScrollDirectionHorizontal) {
            _scrollView.contentOffset = CGPointMake(1.99*_scrollView.frame.size.width, 0);
        } else if (_scrollDirection == LRBannerScrollDirectionVertical) {// 垂直滚动
            _scrollView.contentOffset = CGPointMake(0, 1.99*_scrollView.frame.size.height);
        }
    } completion:^(BOOL finished) {
        _currentPage = [self getPageIndex:_currentPage+1];
        [self refreshScrollView];
        if (self.enableScroll) {
            [self delayAction];
        }
    }];
}

- (void)delayAction {
    
    [self performSelector:@selector(scrollAction)
               withObject:nil
               afterDelay:self.rollingDelayTime];
    
}

- (void)cancelDelayAction {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(scrollAction)
                                               object:nil];
    
}

- (void)downImageSuccess {
    _totalCount--;
    if (_totalCount == 0){
        _currentPage = 1;
        [self refreshScrollView];
        if (_downloadFinoshBlock) {
            _downloadFinoshBlock();
        }
        
    }
    
}

- (void)downImageFailed {
    
    _totalCount--;
    if (_totalCount == 0){
        _currentPage = 1;
        [self refreshScrollView];
        if (_downloadFailureBlock) {
            _downloadFailureBlock();
        }
    }
    
}

- (void)touchAction {
    if (_didSelectImageBlock) {
        _didSelectImageBlock(_currentPage - 1);
    }
}

- (void)dealloc {
    [self cancelDelayAction];
}


@end
