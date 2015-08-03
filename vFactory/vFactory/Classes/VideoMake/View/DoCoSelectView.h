//
//  selectView.h
//  doco_ios_app
//
//  Created by developer on 15/6/13.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoCoSelectView : UIView
-(instancetype)initWithFrame:(CGRect)frame withSelectImage:(UIImage *)selectImage imageView:(UIImageView *)imageView;
@property(nonatomic,strong)UIImageView *selectImageView;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,assign)BOOL selected;

@end
