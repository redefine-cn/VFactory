//
//  selectView.m
//  doco_ios_app
//
//  Created by developer on 15/6/13.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoSelectView.h"

@implementation DoCoSelectView

-(instancetype)initWithFrame:(CGRect)frame withSelectImage:(UIImage *)selectImage imageView:(UIImageView *)imageView{
    self = [super initWithFrame:frame];
    if (self) {
        _selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _selectImageView.image = selectImage;
        
        _imageView = imageView;
        _imageView.center = _selectImageView.center;
        [self addSubview:_imageView];
        [self addSubview:_selectImageView];
        [self setSelected:NO];
    }
    return self;
}

-(void)setSelected:(BOOL)selected{
    if (selected) {
        _selectImageView.hidden = NO;
    }else{
        _selectImageView.hidden = YES;
    }
    _selected = selected;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
