//
//  DoCoVideoTrimmerView.m
//  DoCoVideoTrimmer
//
//  Created by develper on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "DoCoVideoTrimmerView.h"
#import "ICGThumbView.h"

#define barWidth 20

@interface DoCoVideoTrimmerView() <UIScrollViewDelegate>



@property (strong, nonatomic) UIView *leftOverlayView;
@property (strong, nonatomic) UIView *rightOverlayView;
@property (strong, nonatomic) ICGThumbView *leftThumbView;
@property (strong, nonatomic) ICGThumbView *rightThumbView;

@property (strong, nonatomic) UIView *topBorder;
@property (strong, nonatomic) UIView *bottomBorder;

@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat endTime;

@property (nonatomic) CGFloat widthPerSecond;

@property (nonatomic) CGPoint leftStartPoint;
@property (nonatomic) CGPoint rightStartPoint;
@property (nonatomic) CGFloat overlayWidth;

@end

@implementation DoCoVideoTrimmerView

#pragma mark - Initiation

- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        [self resetSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset
{
    self = [super initWithFrame:frame];
    if (self) {
        _asset = asset;
        [self resetSubviews];
    }
    return self;
}


#pragma mark - Private methods

- (void)resetSubviews
{
    if (self.maxLength == 0) {
        self.maxLength = 15;
    }
    
    if (self.minLength == 0) {
        self.minLength = 3;
    }
    
    if (self.allLength == 0) {
        self.allLength = self.maxLength;
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
    
    self.frameView = [[UIView alloc] initWithFrame:CGRectMake(barWidth, 0, CGRectGetWidth(self.contentView.frame)-barWidth*2, CGRectGetHeight(self.contentView.frame))];
    [self.frameView.layer setMasksToBounds:YES];
    [self.contentView addSubview:self.frameView];
    
    [self addFrames];
    
    // add borders
    self.topBorder = [[UIView alloc] init];
    [self.topBorder setBackgroundColor:self.themeColor];
    [self addSubview:self.topBorder];
    
    self.bottomBorder = [[UIView alloc] init];
    [self.bottomBorder setBackgroundColor:self.themeColor];
    [self addSubview:self.bottomBorder];
    
    // width for left and right overlay views
    self.overlayWidth =  (CGRectGetWidth(self.frameView.frame) < CGRectGetWidth(self.frame) ? CGRectGetWidth(self.frameView.frame) : CGRectGetWidth(self.frame)) - (self.minLength * self.widthPerSecond)+100;
    
    // add left overlay view
    self.leftOverlayView = [[UIView alloc] initWithFrame:CGRectMake(barWidth - self.overlayWidth, 0, self.overlayWidth, CGRectGetHeight(self.frameView.frame))];
    CGRect leftThumbFrame = CGRectMake(self.overlayWidth-barWidth, 0, barWidth, CGRectGetHeight(self.frameView.frame));
    if (self.leftThumbImage) {
        self.leftThumbView = [[ICGThumbView alloc] initWithFrame:leftThumbFrame thumbImage:self.leftThumbImage];
    } else {
        self.leftThumbView = [[ICGThumbView alloc] initWithFrame:leftThumbFrame color:self.themeColor right:NO];
    }
    self.leftThumbView.layer.cornerRadius = 3.0f;
    self.leftThumbView.backgroundColor = color(12, 123, 100, 0.7);
    [self.leftOverlayView addSubview:self.leftThumbView];
    [self.leftOverlayView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *leftPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeftOverlayView:)];
    [self.leftOverlayView addGestureRecognizer:leftPanGestureRecognizer];
    [self.leftOverlayView setBackgroundColor:color(12, 123, 100, 0.7)];
    [self addSubview:self.leftOverlayView];
    
    // add right overlay view
    CGFloat rightViewFrameX = CGRectGetWidth(self.frameView.frame) < CGRectGetWidth(self.frame) ? CGRectGetMaxX(self.frameView.frame) : CGRectGetWidth(self.frame) - barWidth;
    self.rightOverlayView = [[UIView alloc] initWithFrame:CGRectMake(rightViewFrameX, 0, self.overlayWidth, CGRectGetHeight(self.frameView.frame))];
    if (self.rightThumbImage) {
        self.rightThumbView = [[ICGThumbView alloc] initWithFrame:CGRectMake(0, 0, barWidth, CGRectGetHeight(self.frameView.frame)) thumbImage:self.rightThumbImage];
    } else {
        self.rightThumbView = [[ICGThumbView alloc] initWithFrame:CGRectMake(0, 0, barWidth, CGRectGetHeight(self.frameView.frame)) color:self.themeColor right:YES];
    }
    self.rightThumbView.layer.cornerRadius = 3.0f;
    self.rightThumbView.backgroundColor = color(12, 123, 100, 0.7);
    [self.rightOverlayView setBackgroundColor:color(12, 123, 100, 0.7)];
    [self.rightOverlayView addSubview:self.rightThumbView];
    [self.rightOverlayView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *rightPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveRightOverlayView:)];
    [self.rightOverlayView addGestureRecognizer:rightPanGestureRecognizer];
    [self addSubview:self.rightOverlayView];
    
    [self updateBorderFrames];

}

- (void)updateBorderFrames
{
    CGFloat height = self.borderWidth ? self.borderWidth : 1;
    [self.topBorder setFrame:CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), 0, CGRectGetMinX(self.rightOverlayView.frame)-CGRectGetMaxX(self.leftOverlayView.frame), height)];
    [self.bottomBorder setFrame:CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), CGRectGetHeight(self.frameView.frame)-height, CGRectGetMinX(self.rightOverlayView.frame)-CGRectGetMaxX(self.leftOverlayView.frame), height)];
}

#pragma mark- 设置开始时间和结束时间
-(void)setStartTime:(CGFloat)startTime{
    CGRect frame = _leftOverlayView.frame;
    float x = startTime *_widthPerSecond + barWidth - frame.size.width;
    frame.origin.x = x;
    _leftOverlayView.frame = frame;
    _startTime = startTime;
}

-(void)setEndTime:(CGFloat)endTime{
    CGRect frame = _rightOverlayView.frame;
    float x = endTime *_widthPerSecond + barWidth;
    frame.origin.x = x;
    _rightOverlayView.frame = frame;
    _endTime = endTime;
}

- (void)moveLeftOverlayView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.leftStartPoint = [gesture locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            
            int deltaX = point.x - self.leftStartPoint.x;
            
            CGPoint center = self.leftOverlayView.center;
            
            CGFloat newLeftViewMidX = center.x += deltaX;;
            CGFloat maxWidth = CGRectGetMinX(self.rightOverlayView.frame) - (self.minLength * self.widthPerSecond);
            CGFloat newLeftViewMinX = newLeftViewMidX - self.overlayWidth/2;
            if (newLeftViewMinX < barWidth - self.overlayWidth) {
                newLeftViewMidX = barWidth - self.overlayWidth + self.overlayWidth/2;
            } else if (newLeftViewMinX + self.overlayWidth > maxWidth) {
                newLeftViewMidX = maxWidth - self.overlayWidth / 2;
            }
            
            self.leftOverlayView.center = CGPointMake(newLeftViewMidX, self.leftOverlayView.center.y);
            self.leftStartPoint = point;
            [self updateBorderFrames];
            [self notifyDelegateWithDirc:0];
        
            break;
        }
            
        default:
            break;
    }
    
    
}

- (void)moveRightOverlayView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.rightStartPoint = [gesture locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            
            int deltaX = point.x - self.rightStartPoint.x;
            
            CGPoint center = self.rightOverlayView.center;
            
            CGFloat newRightViewMidX = center.x += deltaX;
            CGFloat minX = CGRectGetMaxX(self.leftOverlayView.frame) + self.minLength * self.widthPerSecond;
            CGFloat maxX = CMTimeGetSeconds([self.asset duration]) <= self.maxLength + 0.5 ? CGRectGetMaxX(self.frameView.frame) : CGRectGetWidth(self.frame) - barWidth;
            if (newRightViewMidX - self.overlayWidth/2 < minX) {
                newRightViewMidX = minX + self.overlayWidth/2;
            } else if (newRightViewMidX - self.overlayWidth/2 > maxX) {
                newRightViewMidX = maxX + self.overlayWidth/2;
            }
            
            self.rightOverlayView.center = CGPointMake(newRightViewMidX, self.rightOverlayView.center.y);
            self.rightStartPoint = point;
            [self updateBorderFrames];
            [self notifyDelegateWithDirc:1];
            
            break;
        }
            
        default:
            break;
    }
}
//0为左  1为右
- (void)notifyDelegateWithDirc:(int)dir
{
    self.startTime = (CGRectGetMaxX(self.leftOverlayView.frame)-barWidth) / self.widthPerSecond ;
    self.endTime = (CGRectGetMinX(self.rightOverlayView.frame)-barWidth) / self.widthPerSecond ;
    //NSLog(@"start time: %f, end time: %f", self.startTime, self.endTime);
    if(dir==0){//左
        [self.delegate trimmerView:self didChangeLeftPosition:self.startTime];
    }else{//右
        [self.delegate trimmerView:self didChangeRightPosition:self.endTime];
    }
    [self.delegate trimmerView:self didChangeLeftPosition:self.startTime rightPosition:self.endTime];
}

- (void)addFrames
{
    [_frameView setBackgroundColor:[UIColor clearColor]];
    
    Float64 duration = CMTimeGetSeconds([self.asset duration]);
    CGFloat screenWidth = CGRectGetWidth(self.frame) - barWidth*2;
    // quick fix to make up for the width of thumb views
    CGFloat frameViewFrameWidth = (duration / self.maxLength) * screenWidth;
    self.widthPerSecond = frameViewFrameWidth / duration;
    
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0));
}
@end