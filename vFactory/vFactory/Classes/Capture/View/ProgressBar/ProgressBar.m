//
//  ProcessBar.m
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import "ProgressBar.h"
#import "ViewToolkit.h"

#define BAR_H 18
#define BAR_MARGIN 2

#define BAR_BLUE_COLOR color(68, 214, 254, 1)
#define BAR_MAX_COLOR color(191,98,105, 1)
#define BAR_MIN_COLOR color(193,39,45, 1)
#define BAR_RED_COLOR color(245,51,51, 1)
#define BAR_BG_COLOR color(38, 38, 38, 1)

#define BAR_MIN_W DEVICE_SIZE.width*MIN_VIDEO_DUR/MAX_VIDEO_DUR

#define BG_COLOR color(11, 11, 11, 1)

#define INDICATOR_W 10
#define INDICATOR_H 22

#define TIMER_INTERVAL 1.0f

@interface ProgressBar ()

@property (strong, nonatomic) NSMutableArray *progressViewArray;

@property (strong, nonatomic) UIView *barView;
@property (strong,nonatomic) UIView *intervalView;
@property (strong,nonatomic)UILabel *label;

@property (strong, nonatomic) NSTimer *shiningTimer;

@property(assign,nonatomic)float barMinW;

@property(assign,nonatomic)float barH;
@property(assign,nonatomic)float barMargin;

@property(assign,nonatomic)float indicatorH;

@end

@implementation ProgressBar

- (id)initWithFrame:(CGRect)frame minDuration:(float)min maxDuration:(float)max
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxDuration = max;
        _minDuration = min;
        _barMinW = frame.size.width*_minDuration/_maxDuration;
        _barH = frame.size.height;
        _indicatorH = frame.size.height+8;
        [self initalize];
        
    }
    return self;
}

- (void)initalize
{
    self.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundColor = BG_COLOR;
    self.progressViewArray = [[NSMutableArray alloc] init];
    
    //barView
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _barH)];
    _barView.backgroundColor = BAR_BG_COLOR;
    [self addSubview:_barView];
    
    
}

-(void)setIsCaptureProgress:(BOOL)isCaptureProgress{
    if(isCaptureProgress){
        //最短分割线
        _intervalView = [[UIView alloc] initWithFrame:CGRectMake(_barMinW, 0, 1, _barH)];
        _intervalView.backgroundColor = [UIColor blackColor];
        [_barView addSubview:_intervalView];

        //indicator
        self.progressIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_W, _indicatorH)];
        _progressIndicator.backgroundColor = [UIColor clearColor];
        _progressIndicator.image = [UIImage imageNamed:@"record_progressbar_front.png"];

        [self addSubview:_progressIndicator];
    }else{
        [_intervalView removeFromSuperview];
        [_progressIndicator removeFromSuperview];
    }
}

- (UIView *)getProgressView
{
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _barH)];
    progressView.backgroundColor = BAR_RED_COLOR;
    progressView.autoresizesSubviews = YES;
    
    return progressView;
}

- (void)refreshIndicatorPosition
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        _progressIndicator.center = CGPointMake(0, self.frame.size.height / 2);
        return;
    }
    
    _progressIndicator.center = CGPointMake(MIN(lastProgressView.frame.origin.x + lastProgressView.frame.size.width, self.frame.size.width - _progressIndicator.frame.size.width / 2 + 2), self.frame.size.height / 2);
}

- (void)onTimer:(NSTimer *)timer
{
    [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
        _progressIndicator.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
            _progressIndicator.alpha = 1;
        }];
    }];
}

-(void)setLabelText:(NSString *)labelText{
    
    _label = [[UILabel alloc]initWithFrame:self.frame];
    [_label setText:labelText];
    [_label setTextAlignment:NSTextAlignmentCenter];
    _labelText = labelText;
    [self addSubview:_label];
}

#pragma mark - method
- (void)startShining
{
    self.shiningTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)stopShining
{
    [_shiningTimer invalidate];
    self.shiningTimer = nil;
    _progressIndicator.alpha = 1;
}

-(void)hideShining{
    [_progressIndicator removeFromSuperview];
}

-(void)addShining{
    [self addSubview:_progressIndicator];
}

- (void)addProgressView
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    CGFloat newProgressX = 0.0f;
    
    if (lastProgressView) {
        CGRect frame = lastProgressView.frame;
        frame.size.width -= 1;
        lastProgressView.frame = frame;
        
        newProgressX = frame.origin.x + frame.size.width + 1;
    }
    
    UIView *newProgressView = [self getProgressView];
    [ViewToolkit setView:newProgressView toOriginX:newProgressX];
    
    [_barView addSubview:newProgressView];
    
    [_progressViewArray addObject:newProgressView];
}

- (void)setLastProgressToWidth:(CGFloat)width
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    [ViewToolkit setView:lastProgressView toSizeWidth:width];
    [self refreshIndicatorPosition];
}

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    switch (style) {
        case ProgressBarProgressStyleDelete:
        {
            lastProgressView.backgroundColor = BAR_BLUE_COLOR;
            _progressIndicator.hidden = YES;
        }
            break;
        case ProgressBarProgressStyleNormal:
        {
            lastProgressView.backgroundColor = BAR_RED_COLOR;
            _progressIndicator.hidden = NO;
        }
            break;
        case ProgressBarProgressStyleToMinTime:
        {
            lastProgressView.backgroundColor = BAR_MIN_COLOR;
            _progressIndicator.hidden = NO;
        }
            break;
        case ProgressBarProgressStyleToMaxTime:
        {
            lastProgressView.backgroundColor = BAR_MAX_COLOR;
            _progressIndicator.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)deleteLastProgress
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    [lastProgressView removeFromSuperview];
    [_progressViewArray removeLastObject];
    
    _progressIndicator.hidden = NO;
    
    [self refreshIndicatorPosition];
}

+ (ProgressBar *)getInstance
{
    ProgressBar *progressBar = [[ProgressBar alloc] initWithFrame:CGRectMake(0, 0, DEVICE_SIZE.width, BAR_H + BAR_MARGIN * 2)];
    return progressBar;
}

@end
























