//
//  ViewToolkit.m
//  视频录制处理器
//
//  Created by PfcStyle on 15-3-29.
//  Copyright (c) 2015年 PfcStyle. All rights reserved.
//

#import "ViewToolkit.h"

@implementation ViewToolkit
+ (void)setView:(UIView *)view toSizeWidth:(CGFloat)width
{
	CGRect frame = view.frame;
	frame.size.width = width;
	view.frame = frame;
}

+ (void)setView:(UIView *)view toSizeHeight:(CGFloat)height{
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

+ (void)setView:(UIView *)view toOriginX:(CGFloat)x
{
	CGRect frame = view.frame;
	frame.origin.x = x;
	view.frame = frame;
}

+ (void)setView:(UIView *)view toOriginY:(CGFloat)y
{
	CGRect frame = view.frame;
	frame.origin.y = y;
	view.frame = frame;
}

+ (void)setView:(UIView *)view toOrigin:(CGPoint)origin
{
	CGRect frame = view.frame;
	frame.origin = origin;
	view.frame = frame;
}

+(void)rotateView:(UIView *)view{
    CGAffineTransform transform1 = CGAffineTransformMakeRotation(M_PI_2);
    [view setTransform:transform1];
}


@end
