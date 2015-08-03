//
//  MyProgress.m
//  doco_ios_app
//
//  Created by developer on 15/6/10.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "MyProgress.h"
#import "ViewToolkit.h"
@interface MyProgress()
@property(nonatomic,strong)UIView *progressView;

@end
@implementation MyProgress
- (instancetype)initWithFrame:(CGRect)frame minDuration:(float)min maxDuration:(float)max
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxDuration = max;
        [self setMinDuration:min];
        [self initalize];
        
    }
    return self;
}

-(void)initalize{
    self.layer.borderColor=[UIColor whiteColor].CGColor;
    [self setSelected:NO];
    self.autoresizingMask = UIViewAutoresizingNone;
    CGRect frame = self.frame;
    self.layer.cornerRadius = CGRectGetHeight(frame)/2;
    _backColor = color(0, 0, 0, 0.3);
    self.backgroundColor = _backColor;
    self.clipsToBounds = YES;
    float x = -CGRectGetWidth(frame)-10;
    float y = 0;
    _progressView = [[UIView alloc]initWithFrame:CGRectMake(x, y, CGRectGetWidth(frame)+10, CGRectGetHeight(frame))];
    _foreColor = [UIColor redColor];
    _progressView.backgroundColor = _foreColor;
    [self addSubview:_progressView];
    
    float labelx = 0+CGRectGetHeight(self.frame)/2;
    float width = CGRectGetWidth(self.frame)-CGRectGetHeight(self.frame);
    _label = [[UILabel alloc]initWithFrame:CGRectMake(labelx, 0, width, CGRectGetHeight(self.frame))];
    [_label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_label];
}

-(void)setMinDuration:(float)minDuration{
    //添加最短时间标志
    float x = minDuration / _maxDuration * CGRectGetWidth(self.frame);
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(x, CGRectGetHeight(self.frame)/4, 1, CGRectGetHeight(self.frame)/2)];
    [view setBackgroundColor:[UIColor redColor]];
    [self addSubview:view];
    _minDuration =minDuration;
}

-(void)setBackColor:(UIColor *)backColor{
    self.backColor = backColor;
    self.backgroundColor = backColor;
}

-(void)setForeColor:(UIColor *)foreColor{
    self.progressView.backgroundColor = foreColor;
    self.foreColor = foreColor;
}

-(void)setLabelText:(NSString *)labelText{
    
    [_label setText:labelText];
    _labelText = labelText;
}

-(void)setSelected:(BOOL)selected{
    if (!selected) {
        self.layer.borderWidth=0;
    }else{
        self.layer.borderWidth=1;
    }
}

- (void)setProgressToTime:(float)time;{
    self.autoresizingMask = UIViewAutoresizingNone;
    float x = ((time+0.15)/_maxDuration-1)*CGRectGetWidth(self.bounds)-10;
    
    if (time >= _minDuration) {
        _progressView.backgroundColor = color(122,204,17,1);
    }
    [ViewToolkit setView:_progressView toOriginX:x];
}

-(void)deleteProgress{
    _progressView.backgroundColor = [UIColor redColor];
    [ViewToolkit setView:_progressView toOriginX:-CGRectGetWidth(self.bounds)];
}

- (void)setProgressToStyle:(MyProgressStyle)style{
    switch (style) {
        case MyProgressStyleDelete:
        {
            
        }
            break;
        case MyProgressStyleNormal:
        {
            //[self setForeColor:[UIColor redColor]];
        }
            break;
        case MyProgressStyleToMinTime:
        {
            //[self setForeColor:color(122,204,17,1)];
        }
            break;
        case MyProgressStyleToMaxTime:
        {
            
        }
            break;
        default:
            break;
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
