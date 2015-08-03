//
//  DCPlayView.h
//  DCPlayer
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, DCPlayerPlaybackState) {
    DCPlayerPlaybackStateStopped = 0,//播放结束状态
    DCPlayerPlaybackStatePlaying,//正在播放状态
    DCPlayerPlaybackStatePaused,//播放暂停状态
    DCPlayerPlaybackStateFailed,//播放失败（视频损坏或者无法识别）
    
};
@class DCPlayView;
@protocol DCPlayViewDelegate <NSObject>

@optional
-(void)canStartPlaying:(DCPlayView *)dcPlayView;
- (void)networkNotBest:(DCPlayView *)dcPlayView;
- (void)dontPlayer:(DCPlayView *)dcPlayView;
- (void)bufferTimeLengh:(CGFloat)time;
- (void)currentPlayerTimeLengh:(CGFloat)time;
- (void)playEnd:(DCPlayView *)dcPlayView;
- (void)didTap;
@end
@interface DCPlayView : UIView

@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,weak)id<DCPlayViewDelegate>delegate;
@property (nonatomic,assign) DCPlayerPlaybackState playbackState;
@property (nonatomic,copy) NSString *contentUrl;
@property (nonatomic,assign)CGFloat currentTime;
@property (nonatomic,assign,readonly) CGFloat   totalTime;
@property (nonatomic,readonly)CMTimeScale  timeScale;
@property (nonatomic,copy) NSString *videoMode;

- (id)initWithFrame:(CGRect)frame contentUrl:(NSString *)url ;
- (void)speed:(CMTime)speedValue;//跳转
- (void)play;
- (void)pause;
- (void)repeatPlaying;
-(void)rmObserver;
@end
