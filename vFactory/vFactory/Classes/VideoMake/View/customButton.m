//
//  customButton.m
//  doco_ios_app
//
//  Created by developer on 15/5/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "customButton.h"

@implementation customButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame withIsImageLeft:(BOOL)isImageLeft

{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        //可根据自己的需要随意调整
        if (isImageLeft) {
            self.titleLabel.textAlignment=NSTextAlignmentLeft;
            
            self.imageView.contentMode=UIViewContentModeRight;
        }else{
            self.titleLabel.textAlignment=NSTextAlignmentRight;
            
            self.imageView.contentMode=UIViewContentModeLeft;
        }
        _isImageLeft = isImageLeft;
        
    }
    
    return self;
    
}

//重写父类UIButton的方法

//更具button的rect设定并返回文本label的rect

- (CGRect)titleRectForContentRect:(CGRect)contentRect

{
    CGFloat titleW = contentRect.size.width*1/2;
    
    CGFloat titleH = contentRect.size.height;
    
    CGFloat titleX;
    
    CGFloat titleY;
    if(!_isImageLeft){
        titleX = 0;
        
        titleY = 0;
    }else{
        titleX = self.imageView.frame.size.width;
        
        titleY = 0;
    }
    contentRect = (CGRect){{titleX,titleY},{titleW,titleH}};
    return contentRect;
    
}

//更具button的rect设定并返回UIImageView的rect

- (CGRect)imageRectForContentRect:(CGRect)contentRect

{
    CGFloat imageW = contentRect.size.width*1/2;
    
    CGFloat imageH = contentRect.size.height;
    CGFloat imageX;
    CGFloat imageY;
    if (!_isImageLeft) {
        imageX = self.titleLabel.frame.size.width;
        
        imageY = 0;
    }else{
        imageX = 0;
        
        imageY = 0;
    }
    
    
    contentRect = (CGRect){{imageX,imageY},{imageW,imageH}};
    
    return contentRect;
    
}


@end
