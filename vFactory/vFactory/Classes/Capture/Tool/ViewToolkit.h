//
//  ViewToolkit.h
//  视频录制处理器
//
//  Created by PfcStyle on 15-3-29.
//  Copyright (c) 2015年 PfcStyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewToolkit : NSObject
+ (void)setView:(UIView *)view toSizeWidth:(CGFloat)width;
+ (void)setView:(UIView *)view toSizeHeight:(CGFloat)height;
+ (void)setView:(UIView *)view toOriginX:(CGFloat)x;
+ (void)setView:(UIView *)view toOriginY:(CGFloat)y;
+ (void)setView:(UIView *)view toOrigin:(CGPoint)origin;
+ (void)rotateView:(UIView *)view;
@end
