//
//  ProcessBar.h
//  SBVideoCaptureDemo
//
//  Created by Pandara on 14-8-13.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ProgressBarProgressStyleNormal,
    ProgressBarProgressStyleDelete,
    ProgressBarProgressStyleToMinTime,
    ProgressBarProgressStyleToMaxTime,
} ProgressBarProgressStyle;

@interface ProgressBar : UIView

@property(nonatomic,assign)float minDuration;
@property(nonatomic,assign)float maxDuration;
@property(nonatomic,copy)NSString *labelText;
@property (strong, nonatomic) UIImageView *progressIndicator;
@property (assign,nonatomic)BOOL isCaptureProgress;

+ (ProgressBar *)getInstance;

- (id)initWithFrame:(CGRect)frame minDuration:(float)min maxDuration:(float)max;

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style;
- (void)setLastProgressToWidth:(CGFloat)width;

- (void)deleteLastProgress;
- (void)addProgressView;

- (void)stopShining;
- (void)startShining;
- (void)hideShining;
- (void)addShining;

@end
