//
//  DoCoVideoTrimmerView.h
//  DoCoVideoTrimmerView
//
//  Created by developer on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

@protocol DoCoVideoTrimmerDelegate;

@interface DoCoVideoTrimmerView : UIView

// Video to be trimmed
@property (strong, nonatomic) AVAsset *asset;

// Theme color for the trimmer view
@property (strong, nonatomic) UIColor *themeColor;

// Maximum length for the trimmed video
@property (assign, nonatomic) CGFloat maxLength;

// Minimum length for the trimmed video
@property (assign, nonatomic) CGFloat minLength;

@property (nonatomic,assign)CGFloat allLength;

// Show ruler view on the trimmer view or not
@property (assign, nonatomic) BOOL showsRulerView;

// Custom image for the left thumb
@property (strong, nonatomic) UIImage *leftThumbImage;

// Custom image for the right thumb
@property (strong, nonatomic) UIImage *rightThumbImage;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *frameView;

// Custom width for the top and bottom borders
@property (assign, nonatomic) CGFloat borderWidth;

@property(nonatomic,weak)id<DoCoVideoTrimmerDelegate> delegate;
-(void)setStartTime:(CGFloat)startTime;
-(void)setEndTime:(CGFloat)endTime;
- (instancetype)initWithAsset:(AVAsset *)asset;

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset;

- (void)resetSubviews;

@end

@protocol DoCoVideoTrimmerDelegate <NSObject>

- (void)trimmerView:(DoCoVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime;

- (void)trimmerView:(DoCoVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime;

- (void)trimmerView:(DoCoVideoTrimmerView *)trimmerView didChangeRightPosition:(CGFloat)endTime;

@end