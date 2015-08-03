//
//  UIImage+Add.h
//  Doco
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

@interface UIImage (Addition)

#pragma mark 可以自由拉伸的图片
+ (UIImage *)resizedImage:(NSString *)imgName;

#pragma mark 可以自由拉伸的图片 可传拉伸位置
+ (UIImage *)resizedImage:(NSString *)imgName xPos:(CGFloat)xPos yPos:(CGFloat)yPos;
@end