//
//  ImageView.m
//
//
//  Created by 甘 立荣 on 13-3-19.
//  Copyright (c) 2013年 甘 立荣. All rights reserved.
//

#import "LRBannerTouchImageView.h"

@implementation LRBannerTouchImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self _init];
        
    }
    
    return self;
    
}

- (void)awakeFromNib{
    
    [super awakeFromNib];
    [self _init];
    
}

- (void)_init{
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGesture];
    
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    //NSLog(@"点击图片");
    if (self.touchBlock) {
        _touchBlock();
    }
}


@end
