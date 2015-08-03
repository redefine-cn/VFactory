//
//  DCPlayView.m
//  DCPlayer
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//
void *DCPlayer =&DCPlayer;
#import "DCPlayView.h"

@implementation DCPlayView
{
    AVPlayerItem *_playItem;
}
+(Class)layerClass{
    return [AVPlayerLayer class];
}

-(id)initWithFrame:(CGRect)frame contentUrl:(NSString *)url{
    self =[super initWithFrame:frame];
    if (self) {
        self.contentUrl=url;
        
        
    }
    return self;
}


-(void)addTapGesture{
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [tapGes setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGes];
    [self setUserInteractionEnabled:YES];
    
}

//点击事件
-(void)tap:(UITapGestureRecognizer *)rec{
    if ([_delegate respondsToSelector:@selector(didTap)]){
        [_delegate didTap];
    }
}

- (void)setContentUrl:(NSString *)contentUrl
{
    [self addTapGesture];
    if (!contentUrl||[contentUrl length] == 0)
    {
        MyLog(@"请设置文件路径");
        return;
    }
    
    NSURL *videoURL = [NSURL URLWithString:contentUrl];
    if (!videoURL || ![videoURL scheme])
    {
        videoURL = [NSURL fileURLWithPath:contentUrl];
    }
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    [self  setAssert:movieAsset];
    
    _contentUrl = contentUrl;
}

-(void)dealloc{
    [self rmObserver];
}

-(void)rmObserver{
    
    [_playItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    
    [_playItem removeObserver:self forKeyPath:@"status" context:nil];
}

-(void)setAssert:(AVAsset *)assert{
    _playItem = [AVPlayerItem playerItemWithAsset:assert];
    self.player =[AVPlayer playerWithPlayerItem:_playItem];
    
    [self setVideoMode:AVLayerVideoGravityResizeAspectFill];
    
    [_playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    [_playItem addObserver:self forKeyPath:@"loadedTimeRanges"options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter  defaultCenter]addObserver:self  selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playItem];
}

-(void)setVideoMode:(NSString *)videoMode{
    if (videoMode==_videoMode||videoMode==nil) {
        return;
    }
    _videoMode=videoMode;
    ((AVPlayerLayer *)self.layer).videoGravity=_videoMode;
}

#pragma mark ---Notification func

- (void)moviePlayDidEnd:(NSNotification *)nac
{
    _playbackState=DCPlayerPlaybackStateStopped;
    
    if ([_delegate respondsToSelector:@selector(playEnd:)])
    {
        [_delegate playEnd:self];
    }
}

#pragma mark-播放控制
- (void)play
{
    
    [self.player play];
    _playbackState=DCPlayerPlaybackStatePlaying;

    
}
- (void)pause
{
    [self.player pause];
    
    _playbackState =DCPlayerPlaybackStatePaused;
    
}

- (void)repeatPlaying
{
    
    [self.player seekToTime:kCMTimeZero];
    
    [self.player play];
    _playbackState=DCPlayerPlaybackStatePlaying;
    
}

#warning speed
- (void)speed:(CMTime)speedTime
{
    
    [self.player.currentItem seekToTime:speedTime];
    
}

-(AVPlayer*)player{
    return [(AVPlayerLayer *)[self layer]player];
}

-(void)setPlayer:(AVPlayer *)player{
    [(AVPlayerLayer *)[self layer]setPlayer:player];
}

#pragma mark ---observeValueForKeyPath
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"])
    {
        //准备播放
        if ([playerItem status] == AVPlayerStatusReadyToPlay)
        {
            
            [self.player pause];
            _timeScale = playerItem.currentTime.timescale;
            CMTime duration = self.player.currentItem.duration;
            
            _totalTime=CMTimeGetSeconds(duration);
            if ([_delegate respondsToSelector:@selector(canStartPlaying:)])
            {
                [_delegate canStartPlaying:self];
            }
            
            _playbackState =DCPlayerPlaybackStatePaused;
            
            [self monitoringPlayback:self.player.currentItem];
            
        } else if ([playerItem status] == AVPlayerStatusFailed)
        {
            if ([_delegate respondsToSelector:@selector(dontPlayer:)])
            {
                [_delegate dontPlayer:self];
            }
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        
        NSTimeInterval timeInterval = [self availableDuration];
        if ([_delegate respondsToSelector:@selector(bufferTimeLengh:)])
        {
            [_delegate bufferTimeLengh:timeInterval];
        }
        
        int rate =[[NSString stringWithFormat:@"%f",self.player.rate] intValue];
        //网络不好
        if (_playbackState==DCPlayerPlaybackStatePlaying&&rate==0)
        {
            
            if ([_delegate respondsToSelector:@selector(networkNotBest:)])
            {
                [_delegate networkNotBest:self];
            }
            float ti =[[NSString stringWithFormat:@"%f",timeInterval] floatValue];
            if (ti >_currentTime+2) {
                [self.player play];
            }
        }
    }
}

#pragma mark ---private func
- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}
- (void)monitoringPlayback:(AVPlayerItem *)playerItem
{
    __block DCPlayView *blockSelf = self;
    
    id  obj = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 20) queue:NULL usingBlock:^(CMTime time)
               {
                   
                   CGFloat currentSecond = playerItem.currentTime.value*1.0f/playerItem.currentTime.timescale;
                   _currentTime = currentSecond;
                   if ([blockSelf.delegate respondsToSelector:@selector(currentPlayerTimeLengh:)])
                   {
                       [blockSelf.delegate  currentPlayerTimeLengh:currentSecond];
                   }
                   
               }];
    if (obj) {
        return;
    }
    
}


@end
