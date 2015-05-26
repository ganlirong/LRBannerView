//
//  ImageView.h
//  
//  图片的公共基类,使得点击图片能够链接到用户的个人信息
//  Created by 甘 立荣 on 13-3-19.
//  Copyright (c) 2013年 甘 立荣. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^imageBlock)(void);

@interface TouchImageView : UIImageView

@property (nonatomic,copy)imageBlock touchBlock;

@end
