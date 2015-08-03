//
//  AVCamCaptureManager.m
//  视频录制处理器
//
//  Created by PfcStyle on 15-1-21.
//  Copyright (c) 2015年 PfcStyle. All rights reserved.
//

#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import "AVCamUtilities.h"
#import "ViewToolkit.h"
#import "FileTool.h"
#import "AnimationTool.h"
#import "DoCoExporterWriter.h"
#import "DoCoExporterManager.h"
#import "FinishTool.h"
#import "DoCoVideoLayerAnimationManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
#define COUNT_DUR_TIMER_INTERVAL 1.0/60.0
@interface AVCamCaptureManager (RecorderDelegate) <AVCamRecorderDelegate>
@end
@interface AVCamCaptureManager (DoCoExporterWriterDelegate) <DoCoExporterWriterDelegate>
@end
#pragma mark - 分类 工具类
@interface AVCamCaptureManager (InternalUtilityMethods)
//屏幕方向改变后
- (void)deviceOrientationDidChange;
//根据位置获取硬件
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
//获取前置摄像头
- (AVCaptureDevice *) frontFacingCamera;
//获取后置摄像头
- (AVCaptureDevice *) backFacingCamera;
//获取麦克
- (AVCaptureDevice *) audioDevice;
//获取临时文件夹url
- (NSURL *) tempFileURL;
//更改硬件设置
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange;
@end
@interface AVCamCaptureManager()<AVCaptureFileOutputRecordingDelegate>
{
    UIImage *_headImage;
    UIImage *_footImage;
	AVAsset *_videoAsset;
    NSString *_mergeVideoPath;
}

@end
@implementation AVCamCaptureManager
-(instancetype)init
{
	self = [super init];
	if(self){
		_orientation = AVCaptureVideoOrientationLandscapeRight;
        _maxRecordTime  = 10.0f;
		//初始化session
		[self setSession];
		
		self.videoFileDataArray = [[NSMutableArray alloc] init];
		self.totalVideoDur = 0.0f;
		self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
	}
	return self;
}

-(instancetype)initWithOrentation:(AVCaptureVideoOrientation)orientation andMaxRecorderTime:(float)maxRecorderTime
{
    self = [super init];
    if(self){
        //设置录制视频的方向
        if(orientation){
            _orientation = orientation;
        }else{
            _orientation = AVCaptureVideoOrientationPortrait;
        }
        
        if (maxRecorderTime) {
            _maxRecordTime = maxRecorderTime;
        }else{
            _maxRecordTime  = 10.0f;
        }
        
        [self setSession];
        
        self.videoFileDataArray = [[NSMutableArray alloc] init];
        self.totalVideoDur = 0.0f;
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    }
    return self;
}



- (BOOL)setSession
{
    
	BOOL success = NO;
	//初始化输入输出设备并添加到session中，默认是相机
	[self setInOutDeviceInSessionAndRecorder];
	
//	设置闪关灯模式为自动
//	 Set torch and flash mode to auto
	if ([[self backFacingCamera] hasFlash]) {
		[self changeFlashMode:AVCaptureFlashModeAuto];
	}
	//设置手电模式为自动
	if ([[self backFacingCamera] hasTorch]) {
		[self changeTorchMode:AVCaptureTorchModeAuto];
	}
	success = YES;
	
	return success;
    
}

-(void)setInOutDeviceInSessionAndRecorder{
	// Init the device inputs
    //设置视频录制的fps为25
    AVCaptureDevice *backFacing = [self backFacingCamera];
    if ( [backFacing lockForConfiguration:NULL] == YES ) {        backFacing.activeVideoMinFrameDuration = CMTimeMake(1, 25);
        backFacing.activeVideoMaxFrameDuration = CMTimeMake(1, 25);
        [backFacing unlockForConfiguration];
    }
	AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacing error:nil];
	AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
	//默认高质量分辨率
	// Create session (use default AVCaptureSessionPresetHigh)
	AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    
	if([newCaptureSession canSetSessionPreset:AVCaptureSessionPresetiFrame960x540]){
        [newCaptureSession setSessionPreset:AVCaptureSessionPresetiFrame960x540];
	}else{
		MyLog(@"不能设置SissionPreset");
	}
	// Add inputs and output to the capture session
	if ([newCaptureSession canAddInput:newVideoInput]) {
		[newCaptureSession addInput:newVideoInput];
	}
	if ([newCaptureSession canAddInput:newAudioInput]) {
		[newCaptureSession addInput:newAudioInput];
	}
	
	[self setCaptureVideoInput:newVideoInput];
	[self setCaptureAudioInput:newAudioInput];
	[self setCaptureSession:newCaptureSession];
        
    AVCamRecorder *newRecorder = [[AVCamRecorder alloc] initWithSession:self.captureSession];
    [newRecorder setDelegate:self];
        [self setRecorder:newRecorder];
        
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([newCaptureSession canAddOutput:stillImageOutput])
    {
        [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
        [newCaptureSession addOutput:stillImageOutput];
        [self setStillImageOutput:stillImageOutput];
    }

}

- (void) startRecordingWithOutputUrl:(NSURL *)outputUrl
{
    
    [self.recorder startRecordingWithOrientation:_orientation outputFileURL:outputUrl];

}

- (void)startCountDurTimer
{
	self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
	self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
	if ([_delegate respondsToSelector:@selector(captureManager:didRecordingToOutPutFileAtURL:duration:recordedVideosTotalDur:)]) {
		[_delegate captureManager:self didRecordingToOutPutFileAtURL:_currentFileURL duration:_currentVideoDur recordedVideosTotalDur:_totalVideoDur];
	}
    if (_currentVideoDur >= _maxRecordTime) {
        
        if ([_delegate respondsToSelector:@selector(captureDidToMaxVideoTime)]) {
            [_delegate captureDidToMaxVideoTime];
        }
        [self stopRecording];
    }
}

- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
}

//会调用delegate
//删除最后一段视频
- (void)deleteLastVideo
{
	if ([_videoFileDataArray count] == 0) {
		return;
	}
	
	Video *data = (Video *)[_videoFileDataArray lastObject];
	
	NSURL *videoFileURL = data.fileURL;
	CGFloat videoDuration = data.duration;
	
	[_videoFileDataArray removeLastObject];
	_totalVideoDur -= videoDuration;
	
	//delete
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString *filePath = [[videoFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:filePath]) {
			NSError *error = nil;
			[fileManager removeItemAtPath:filePath error:&error];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				//delegate
				if ([_delegate respondsToSelector:@selector(captureManager:didRemoveVideoFileAtURL:totalDur:error:)]) {
					[_delegate captureManager:self didRemoveVideoFileAtURL:videoFileURL totalDur:_totalVideoDur error:error];
				}
			});
		}
	});
}


//不调用delegate
//删除所有的视频

- (void)deleteAllVideo
{
	for (Video *data in _videoFileDataArray) {
		NSURL *videoFileURL = data.fileURL;
		[FileTool removeFile:videoFileURL];
		
	}
    [_videoFileDataArray removeAllObjects];
    _totalVideoDur = 0.0f;
    dispatch_async(dispatch_get_main_queue(), ^{
        //delegate
        if ([_delegate respondsToSelector:@selector(captureManager:didRemoveVideoFileAtURL:totalDur:error:)]) {
            [_delegate captureManager:self didRemoveVideoFileAtURL:nil totalDur:_totalVideoDur error:nil];
        }
    });
}


- (void) stopRecording
{
    [self stopCountDurTimer];
    [[self recorder] stopRecording];
}

- (void)mergeVideoFiles:(NSMutableArray  *)fileURLArray headImage:(UIImage *)headImage footImage:(UIImage *)footImage WithType:(NSString *)type foldePath:(NSString *)foldePath
{
    _mergeVideoPath = [FileTool getVideoMergeFilePathStringWithFolderPath:foldePath];
    _headImage = headImage;
    _footImage = footImage;
    if ([@"ZHY" isEqualToString:type]) {
        NSURL *headURL = [[NSBundle mainBundle]URLForResource:@"head" withExtension:@"mp4"];
        
        NSURL *footURL = [[NSBundle mainBundle]URLForResource:@"foot" withExtension:@"mp4"];
        [fileURLArray addObject:footURL];
        
        [DoCoExporterManager videoApplyAnimationAtFileURL:headURL orientation:_orientation duration:0 outputFilePath:_mergeVideoPath
        Animation:^(AVMutableVideoComposition *videoCom,CGSize size){
            CALayer *parentLayer = [CALayer layer];
            CALayer *videoLayer1 = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
            videoLayer1.frame = CGRectMake(0, 0, size.width, size.height);
            [parentLayer addSublayer:videoLayer1];
            //人物
            CALayer *renwuLayer = [CALayer layer];
            renwuLayer.frame = CGRectMake(-600, 0, size.height*4/3, size.height);
            UIImage *renwuImage = _headImage;
            [renwuLayer setContents:(id)renwuImage.CGImage];
            CABasicAnimation *renwuAnimation = [AnimationTool moveX:4.6f X:[NSNumber numberWithFloat:950]];
            renwuAnimation.beginTime = 1.0f;
            renwuAnimation.timingFunction = [[CAMediaTimingFunction alloc]initWithControlPoints:0.25 :0.35 :0 :1];
            [renwuLayer addAnimation:renwuAnimation forKey:nil];
            [parentLayer addSublayer:renwuLayer];
            //灰块左
            CALayer *leftLayer = [CALayer layer];
            leftLayer.frame = CGRectMake(0, 0, size.width, size.height);
            UIImage *leftImage = [UIImage imageNamed:@"left.png"];
            [leftLayer setContents:(id)leftImage.CGImage];
            [parentLayer addSublayer:leftLayer];
            videoCom.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer1 inLayer:parentLayer];
        }
        Completion:^(NSURL *outputURL){
            [fileURLArray insertObject:outputURL atIndex:0];
            [self mergeAndExportVideosAtFileURLs:fileURLArray];
        }];
    }else if([@"GQT" isEqualToString:type]){
        NSURL *headURL = [[NSBundle mainBundle]URLForResource:@"5-5" withExtension:@"mp4"];
        NSURL *footURL = [[NSBundle mainBundle]URLForResource:@"5-1" withExtension:@"mp4"];
        
        [fileURLArray addObject:footURL];
        
        [DoCoExporterManager videoApplyAnimationAtFileURL:headURL orientation:_orientation duration:0 outputFilePath:_mergeVideoPath
        Animation:^(AVMutableVideoComposition *videoCom,CGSize size)
        {
            CALayer *parentLayer = [CALayer layer];
            CALayer *videoLayer1 = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
            videoLayer1.frame = CGRectMake(0, 0, size.width, size.height);
            [parentLayer addSublayer:videoLayer1];
            
            //人物
            CALayer *renwuLayer = [CALayer layer];
            renwuLayer.frame = CGRectMake(-600, 0, size.height*4/3, size.height);
            UIImage *renwuImage = _headImage;
            [renwuLayer setContents:(id)renwuImage.CGImage];
            CABasicAnimation *renwuAnimation = [AnimationTool moveX:4.7f X:[NSNumber numberWithFloat:950]];
            renwuAnimation.beginTime = 1.0f;
            renwuAnimation.timingFunction = [[CAMediaTimingFunction alloc]initWithControlPoints:0.25 :0.35 :0 :1];
            [renwuLayer addAnimation:renwuAnimation forKey:nil];
            [parentLayer addSublayer:renwuLayer];
            
            videoCom.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer1 inLayer:parentLayer];
            
        }
        Completion:^(NSURL *outputURL){
            [fileURLArray insertObject:outputURL atIndex:0];
            [self mergeAndExportVideosAtFileURLs2:fileURLArray];
        }];
    }
}

- (void)mergeAndExportVideosAtFileURLs2:(NSArray *)fileURLArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        CGSize renderSize = CGSizeMake(0, 0);
        //video的工具数组
        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
        //音频的的工具数组
        NSMutableArray *audioMixParas = [[NSMutableArray alloc]init];
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        CMTime totalDuration = kCMTimeZero;
        
        //先取assetTrack 也为了取renderSize
        NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
        NSMutableArray *assetArray = [[NSMutableArray alloc] init];
        
        for (NSURL *fileURL in fileURLArray) {
            
            AVAsset *asset = [AVAsset assetWithURL:fileURL];
            if (!asset) {
                MyLog(@"asset竟然为空了呀＝＝＝＝＝＝＝＝＝＝＝＝");
                continue;
            }
            [assetArray addObject:asset];
            AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [assetTrackArray addObject:assetTrack];

        }
        if (_orientation ==AVCaptureVideoOrientationPortrait) {
            //如果是竖屏
            renderSize.width = 540;
            renderSize.height = 960;
        }else{//横屏
            renderSize.width = 960;
            renderSize.height = 540;
        }
        for (int i = 0; i < [assetArray count] && i < [assetTrackArray count]; i++) {
            
            AVAsset *asset = [assetArray objectAtIndex:i];
            AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];
            
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            NSArray *trackarr = [asset tracksWithMediaType:AVMediaTypeAudio];
            CMTime coverTime = CMTimeMake(600,600);
            //还没有减去重叠时间
            if (i==2) {
                [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeMake(600,600), asset.duration)
                    ofTrack:([trackarr count]>0)?[trackarr objectAtIndex:0]:nil
                     atTime:totalDuration
                      error:nil];
            }else{
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                    ofTrack:([trackarr count]>0)?[trackarr objectAtIndex:0]:nil
                     atTime:totalDuration
                      error:nil];
            }
            //音频的效果设置  总时间还没有变化！！！
//            AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
//            [trackMix setVolume:1.0f atTime:totalDuration];
//            [audioMixParas addObject:trackMix];
            
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            if(i==2){
                [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                ofTrack:assetTrack
                 atTime:CMTimeSubtract(totalDuration, coverTime)
                  error:&error];

            }else{
                [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                ofTrack:assetTrack
                 atTime:totalDuration
                  error:&error];
            }
            
            //调整视频方向一致
            AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            if(i==1){
                
                totalDuration = CMTimeAdd(totalDuration, asset.duration);
                CMTimeRange animationRange = CMTimeRangeMake(CMTimeSubtract(totalDuration, coverTime), coverTime);

                [layerInstruciton setOpacityRampFromStartOpacity:1.0f toEndOpacity:0.0f timeRange:animationRange];
            }else if(i==2){

                CMTimeRange animationRange = CMTimeRangeMake(CMTimeSubtract(totalDuration, coverTime), coverTime);
                [layerInstruciton setOpacityRampFromStartOpacity:0.0f toEndOpacity:1.0f timeRange:animationRange];
                //总时间计算  减去与前一段重叠的时间
                totalDuration = CMTimeAdd(totalDuration, asset.duration);
                totalDuration = CMTimeSubtract(totalDuration, coverTime);
            }else{
                totalDuration = CMTimeAdd(totalDuration, asset.duration);
            }
//            CGAffineTransform transform = CGAffineTransformMakeScale(0.5, 0.5);
//            
//            if (assetTrack.preferredTransform.a==-1) {
//                transform = CGAffineTransformMakeRotation(M_PI);
//                transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(renderSize.width, renderSize.height));
//                transform = CGAffineTransformScale(transform, 0.5, 0.5);
//            }
//            [layerInstruciton setTransform:transform atTime:kCMTimeZero];
            
            [layerInstruciton setOpacity:0.0 atTime:totalDuration];
            //data
            [layerInstructionArray insertObject:layerInstruciton atIndex:0];
        }

        
        //添加背景音乐
        NSString * path = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp3"];
        NSURL *assetURL = [NSURL fileURLWithPath:path];
        CMTime startTime = CMTimeMakeWithSeconds(0, 1);
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
        AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [self setUpAndAddAudioAtPath:sourceAudioTrack toComposition:mixComposition start:startTime dura:totalDuration mixparas:audioMixParas Type:@"music"];
        
        
        
        //get save path
        NSString *filePath = _mergeVideoPath;
        NSURL *mergeFileURL = [NSURL fileURLWithPath:filePath];
        
        
        //export
        //audio
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = [NSArray arrayWithArray:audioMixParas];
        
        //video
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        mainInstruciton.layerInstructions = layerInstructionArray;
        AVMutableVideoComposition *videoCom = [AVMutableVideoComposition videoComposition];
        videoCom.instructions = @[mainInstruciton];
        videoCom.frameDuration = CMTimeMake(1, 25);
        videoCom.renderSize = CGSizeMake(renderSize.width, renderSize.height);
        
        [self applyVideoEffectsToComposition2:videoCom size:renderSize];
        
        DoCoExporterWriter *editer = [[DoCoExporterWriter alloc]initWithSource:mixComposition videoComposition:videoCom audioMix:audioMix outputURL:mergeFileURL Script:@"GQT"];
        
        editer.delegate =self;
        
//        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset960x540];
        //		exporter.videoComposition = videoCom;
        //		exporter.outputURL = mergeFileURL;
        //		exporter.outputFileType = AVFileTypeMPEG4;
        //		exporter.shouldOptimizeForNetworkUse = YES;
        //		[exporter exportAsynchronouslyWithCompletionHandler:^{
        //			dispatch_async(dispatch_get_main_queue(), ^{
        
        //                [self readingAndWritingDidFinishSuccessfullyWithOutputURL:exporter.outputURL];
        //                
        //			});
        //		}];
    });
}



- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
        DoCoVideoLayerAnimationManager *tool = [[DoCoVideoLayerAnimationManager alloc]init];
        tool.renderSize  = renderSizeL;
		for (NSURL *fileURL in fileURLArray) {

			AVAsset *asset = [AVAsset assetWithURL:fileURL];
			if (!asset) {
				continue;
			}
			[tool.assetArray addObject:asset];
		}
        [tool firstTrack];
        for (int i=1; i<tool.assetArray.count; i++) {
            [tool cuttoAnimationtranslationAsset:tool.assetArray[i] direction:@"right" duration:500];
        }
        
        //添加背景音乐
        NSString * path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
        NSURL *assetURL = [NSURL fileURLWithPath:path];
        CMTime startTime = CMTimeMakeWithSeconds(0, 1);
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
        AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        
        [tool setUpAndAddAudioAtPath:sourceAudioTrack start:startTime dura:tool.totalDuration Type:@"music"];
        
		//get save path
        NSString *filePath = _mergeVideoPath;
		NSURL *mergeFileURL = [NSURL fileURLWithPath:filePath];
        
        
		//export
        //audio
        AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
        audioMix.inputParameters = [NSArray arrayWithArray:tool.audioMixParas];
        
        //video
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, tool.totalDuration);
        mainInstruciton.layerInstructions = tool.layerInstructionArray;
        AVMutableVideoComposition *videoCom = [AVMutableVideoComposition videoComposition];
        videoCom.instructions = @[mainInstruciton];
        videoCom.frameDuration = CMTimeMake(1, 25);
        videoCom.renderSize = renderSizeL;
        
        [self applyVideoEffectsToComposition:videoCom size:renderSizeL];
        
        DoCoExporterWriter *editer = [[DoCoExporterWriter alloc]initWithSource:tool.mixComposition videoComposition:videoCom audioMix:audioMix outputURL:mergeFileURL Script:@"ZHY"];
        editer.delegate = self;
        
//		AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset960x540];
//		exporter.videoComposition = videoCom;
//		exporter.outputURL = mergeFileURL;
//		exporter.outputFileType = AVFileTypeMPEG4;
//		exporter.shouldOptimizeForNetworkUse = YES;
//		[exporter exportAsynchronouslyWithCompletionHandler:^{
//			dispatch_async(dispatch_get_main_queue(), ^{
        
//                [self readingAndWritingDidFinishSuccessfullyWithOutputURL:exporter.outputURL];
//                
//			});
//		}];
	});
}

- (void) setUpAndAddAudioAtPath:(AVAssetTrack*)sourceAudioTrack toComposition:(AVMutableComposition *)mixComposition start:(CMTime)start dura:(CMTime)dura mixparas:(NSMutableArray *)audioMixParas Type:(NSString *)type{
    AVMutableCompositionTrack *track = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error = nil;
    BOOL ok = NO;
    
    CMTime startTime = start;
    CMTime trackDuration = dura;
    CMTimeRange tRange = CMTimeRangeMake(startTime, trackDuration);
    
//    //Set Volume
//    AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
//    [trackMix setVolume:0.05f atTime:startTime];
//    [audioMixParas addObject:trackMix];
    
    
    //Insert audio into track  //offset CMTimeMake(0, 44100)
    ok = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:kCMTimeZero error:&error];
}



#pragma mark-动画
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size{
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer1 = [CALayer layer];
    [videoLayer1 setMasksToBounds:YES];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer1.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer1];
    
    
    //片尾
    CABasicAnimation *rightAnimation = [AnimationTool opacityTimes_Animation:1 durTimes:0.25f fromOpacity:0.0f toOpacity:1.0f];
    rightAnimation.beginTime =  24.06;
    CABasicAnimation *renwuAnimation = [AnimationTool opacityTimes_Animation:1 durTimes:0.25f fromOpacity:0.0f toOpacity:1.0f];
    renwuAnimation.beginTime =  24.10;
    
    UIImage *renwuImage = _footImage;
    //第二个人
    CALayer *renwuLayer2 = [CALayer layer];
    renwuLayer2.opacity = 0.0f;
    renwuLayer2.frame = CGRectMake(0,0,size.height*4/3,size.height);
    [renwuLayer2 setContents:(id)renwuImage.CGImage];
    [renwuLayer2 addAnimation:renwuAnimation forKey:nil];
    [videoLayer1 addSublayer:renwuLayer2];
//    //灰块右
    CALayer *rightLayer = [CALayer layer];
    rightLayer.frame = CGRectMake(0, 0, size.width, size.height);
    rightLayer.opacity = 0.0f;
    UIImage *rightImage = [UIImage imageNamed:@"right.png"];
    [rightLayer setContents:(id)rightImage.CGImage];
    
    [rightLayer addAnimation:rightAnimation forKey:nil];
    [videoLayer1 addSublayer:rightLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer1 inLayer:parentLayer];
}

- (void)applyVideoEffectsToComposition2:(AVMutableVideoComposition *)composition size:(CGSize)size{
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer1 = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer1.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer1];
    CABasicAnimation *renwuAnimation1 = [AnimationTool scale:[NSNumber numberWithFloat:1.0] orgin:[NSNumber numberWithFloat:2.0f] durTimes:2.0f Rep:1];
    renwuAnimation1.beginTime = 25;
    CABasicAnimation *renwuAnimation2 = [AnimationTool opacityTimes_Animation:1 durTimes:0.25f fromOpacity:0.0f toOpacity:1.0f];
    renwuAnimation2.beginTime = 25;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[renwuAnimation1,renwuAnimation2];
    group.beginTime =AVCoreAnimationBeginTimeAtZero;
    group.duration = 30.0f;
    
    UIImage *renwuImage = _footImage;
    //第二个人
    CALayer *renwuLayer2 = [CALayer layer];
    renwuLayer2.frame = CGRectMake(0,0,size.height*4/3,size.height);
    renwuLayer2.opacity = 0.0f;
    renwuLayer2.transform = CATransform3DScale(CATransform3DIdentity, 2.0, 2.0, 1.0);
    [renwuLayer2 setContents:(id)renwuImage.CGImage];
    [renwuLayer2 addAnimation:group forKey:nil];
    [parentLayer addSublayer:renwuLayer2];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer1 inLayer:parentLayer];
}



//将视频输出到相册并删除原视频
- (void)exportDidFinish:(NSURL *)outputURL {

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
    {
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (error) {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                        message:@"Video Saving Failed"
//                        delegate:nil
//                        cancelButtonTitle:@"OK"
//                        otherButtonTitles:nil];
//                    [alert show];
//                } else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved"
//                        message:@"Saved To Photo Album"
//                        delegate:self
//                        cancelButtonTitle:@"OK"
//                        otherButtonTitles:nil];
//                    [alert show];
//                }
//            });
        }];
    }
}

- (void) captureStillImage
{
        AVCaptureConnection *stillImageConnection = [AVCamUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
        if ([stillImageConnection isVideoOrientationSupported])
            [stillImageConnection setVideoOrientation:_orientation];
        
        [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
            completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                ALAssetsLibraryWriteImageCompletionBlock completionBlock = ^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                [[self delegate] captureManager:self didFailWithError:error];
                        }
                    }
            };
                                                                 
            if (imageDataSampleBuffer != NULL) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                if ([[self delegate] respondsToSelector:@selector(captureManagerStillImageCaptured:WithImage:)]) {
                    [[self delegate] captureManagerStillImageCaptured:self WithImage:image];
                }
            }else completionBlock(nil, error);
            
        }];
}



// 前后摄像头的转换
- (BOOL) exchangeCamera
{
	BOOL success = NO;
	
	if ([self cameraCount] > 1) {
		NSError *error;
		AVCaptureDeviceInput *newVideoInput;
		AVCaptureDevicePosition position = [[_captureVideoInput device] position];
		if (position == AVCaptureDevicePositionBack)
			newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
		else if (position == AVCaptureDevicePositionFront)
			newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
		else
			return success;
		if (newVideoInput != nil) {
			[[self captureSession] beginConfiguration];
			[[self captureSession] removeInput:[self captureVideoInput]];
			if ([[self captureSession] canAddInput:newVideoInput]) {
				[[self captureSession] addInput:newVideoInput];
				[self setCaptureVideoInput:newVideoInput];
			} else {
				[[self captureSession] addInput:[self captureVideoInput]];
			}
			[[self captureSession] commitConfiguration];
			success = YES;
		} else if (error) {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
				[[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
	return success;
}

//总时长
- (CGFloat)getTotalVideoDuration
{
	return _totalVideoDur;
}

//现在录了多少视频
- (NSUInteger)getVideoCount
{
	return [_videoFileDataArray count];
}

#pragma mark-Get Device Counts
- (NSUInteger) cameraCount
{
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
	return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

#pragma mark-Camera Properties
// 定点聚焦
- (void) autoFocusAtPoint:(CGPoint)point
{
	AVCaptureDevice *device = [[self captureVideoInput] device];
	if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeAutoFocus];
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
				[[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
}

// 自动聚焦模式
- (void) continuousFocusAtPoint:(CGPoint)point
{
	AVCaptureDevice *device = [[self captureVideoInput] device];
	
	if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
				[[self delegate] captureManager:self didFailWithError:error];
			}
		}
	}
}

// 锁定焦距
- (void) LockedFocus
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusPointOfInterestSupported] && [captureDevice isFocusModeSupported:AVCaptureFocusModeLocked]) {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
    }];
}

//更改闪光灯模式
-(void)changeFlashMode:(AVCaptureFlashMode)flashMode{
	[self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
		if ([captureDevice isFlashModeSupported:flashMode]) {
			[captureDevice setFlashMode:flashMode];
		}
	}];

}
//更改手电模式
-(void)changeTorchMode:(AVCaptureTorchMode)torchMode{
	[self changeDeviceProperty:^(AVCaptureDevice *captureDevice){
		if ([captureDevice isTorchModeSupported:torchMode]) {
			[captureDevice setTorchMode:torchMode ];
		}
	}];
}

-(void) changeZoomFactor:(CGFloat)newZoom{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice){
        captureDevice.videoZoomFactor = newZoom;
    }];
}

//内存警告时及时销毁一些对象释放内存
- (void)memoryWarning:(NSNotification*)note{

}

#pragma mark-和outputfile的代理
-(void)				 captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
          fromConnections:(NSArray *)connections
{
    self.currentFileURL =  self.movieFileOutput.outputFileURL;
    self.currentVideoDur = 0.0f;
    [self startCountDurTimer];
    if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingBegan:)]) {
        [[self delegate] captureManagerRecordingBegan:self];
    }
}

- (void)			  captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)anOutputFileURL
           fromConnections:(NSArray *)connections
                     error:(NSError *)error
{
    Video *data = [[Video alloc]init];
    data.duration = _currentVideoDur;
    data.fileURL = anOutputFileURL;
    [_videoFileDataArray addObject:data];
    self.totalVideoDur += _currentVideoDur;
    self.currentVideoDur = 0.0f;
    if([_delegate respondsToSelector:@selector(captureManagerRecordingFinished:outputFileURL:)]){
        MyLog(@"将要进入录像完成的代理了--%@",[anOutputFileURL absoluteString]);
        [self.delegate captureManagerRecordingFinished:self outputFileURL:anOutputFileURL];
    }
}

@end



#pragma mark -对工具分类的实现
@implementation AVCamCaptureManager (InternalUtilityMethods)

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
//监控手机方向的变化  要和摄像头的方位保持一致
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
	
	if (deviceOrientation == UIDeviceOrientationPortrait)
		self.orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		self.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		self.orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		self.orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
//根据AVCaptureDevicePositon获取硬件，如果没有找到，返回nil
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			return device;
		}
	}
	return nil;
}

// Find a front facing camera, returning nil if one is not found
//获取前置摄像头，如果没有找到，返回nil
- (AVCaptureDevice *) frontFacingCamera
{
	return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
//获取后置摄像头，如果没有找到，返回nil
- (AVCaptureDevice *) backFacingCamera
{
	return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

// Find and return an audio device, returning nil if one is not found
//获取mic，如果没有找到，返回nil
- (AVCaptureDevice *) audioDevice
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
	if ([devices count] > 0) {
		return [devices objectAtIndex:0];
	}
	return nil;
}

//获取临时文件路径
- (NSURL *) tempFileURL
{
	return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"]];
}



//将硬件属性设置统一
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
	AVCaptureDevice *captureDevice= [self.captureVideoInput device];
	NSError *error;
	//注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
	if ([captureDevice lockForConfiguration:&error]) {
		propertyChange(captureDevice);
		[captureDevice unlockForConfiguration];
	}else{
		NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
	}
}

@end

#pragma mark -实现代理 RecorderDelegate
@implementation AVCamCaptureManager (RecorderDelegate)
//开始录像代理事件
-(void)recorderRecordingDidBegin:(AVCamRecorder *)recorder
{
	self.currentFileURL = recorder.movieFileOutput.outputFileURL;
	self.currentVideoDur = 0.0f;
	[self startCountDurTimer];
	if ([[self delegate] respondsToSelector:@selector(captureManagerRecordingBegan:)]) {
		[[self delegate] captureManagerRecordingBegan:self];
	}
}

//录像完成输出到文件的代理
-(void)recorder:(AVCamRecorder *)recorder recordingDidFinishToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error
{
	Video *data = [[Video alloc]init];
	data.duration = _currentVideoDur;
	data.fileURL = outputFileURL;
	[_videoFileDataArray addObject:data];
	self.totalVideoDur += _currentVideoDur;
    if([_delegate respondsToSelector:@selector(captureManagerRecordingFinished:outputFileURL:)]){
        MyLog(@"将要进入录像完成的代理了--%@",[outputFileURL absoluteString]);
		[self.delegate captureManagerRecordingFinished:self outputFileURL:outputFileURL];
	}
}


@end

@implementation AVCamCaptureManager(DoCoExporterWriterDelegate) 

-(void)readingAndWritingDidFinishSuccessfullyWithOutputURL:(NSURL *)outputURL{
    dispatch_async(dispatch_get_main_queue(), ^{
//        UIImage *image = [FinishTool thumbnailImageForVideo:outputURL atTime:8];
//        NSData *data = UIImagePNGRepresentation(image);
//        [BaseHttpTool uploadData:data token:@"vUQlBXXwgYNrGLunTtVbEi40TGU41MvT8rw8N2Qj:Z5qsp9O49BkzJJ5vEtHEePeBs_U=:eyJzY29wZSI6ImRvY28iLCJkZWFkbGluZSI6MTU4NzAxNDkxN30=" progress:nil
//            completion:^(NSDictionary *dic){
//                NSString *key = dic[@"key"];
//                NSString *baseUrl = @"http://7xir3h.com2.z0.glb.qiniucdn.com/";
//                NSString *imageUrl = [NSString stringWithFormat:@"%@%@",baseUrl,key];
//                [BaseHttpTool uploadFileWithFilePath:[FileTool getFilePathFromFileURL:outputURL] token:@"vUQlBXXwgYNrGLunTtVbEi40TGU41MvT8rw8N2Qj:Z5qsp9O49BkzJJ5vEtHEePeBs_U=:eyJzY29wZSI6ImRvY28iLCJkZWFkbGluZSI6MTU4NzAxNDkxN30="
//                                            progress:^(float percent){
//                                                if ([_delegate respondsToSelector:@selector(didBeginUploadFileWithProgress:)] ) {
//                                                    [_delegate didBeginUploadFileWithProgress:percent];
//                                                }
//                                            }completion:^(NSDictionary *dic){
//                                                
//                                                NSString *key = dic[@"key"];
//                                                NSString *baseUrl = @"http://7xir3h.com2.z0.glb.qiniucdn.com/";
//                                                NSString *absoluteUrl = [NSString stringWithFormat:@"%@%@",baseUrl,key];
//                                                [BaseHttpTool postWithPath:@"api/video/video_add/" params:@{
//                                                                                                            @"classification_id" : @"1",
//                                                                                                            @"name" : @"测试一下",
//                                                                                                            @"duration" :@"30",
//                                                                                                            @"description" : @"test",
//                                                                                                            @"url" : absoluteUrl,
//                                                                                                            @"cover" : imageUrl,
//                                                                                                            @"fps" : @"25",
//                                                                                                            @"resolution" : @"960*540",
//                                                                                                            @"extension_name" : @"mp4",
//                                                                                                            @"bitrate" : @"3.52mps",
//                                                                                                            @"is_editor_choice" : @"0",
//                                                                                                            @"is_private" : @"0",
//                                                                                                            @"is_cross_screen" : @"1",
//                                                                                                            @"tag" : @""
//                                                                                                            }
//                                                                   success:^(id JSON){
//                                                                       if ([_delegate respondsToSelector:@selector(didFinishUploadFileLocalUrl:QiNiuUrl:)]){
//                                                                           [_delegate didFinishUploadFileLocalUrl:outputURL QiNiuUrl:absoluteUrl];
//                                                                       }
//                                                                   }
//                                                                   failure:^(NSError *error){
//                                                                       
//                                                                   }];
//                                            }];
//
//            }];
//        
        [self exportDidFinish:outputURL];
        if ([_delegate respondsToSelector:@selector(captureManager:didFinishMergingVideosToOutPutFileAtURL:)]){
            [_delegate captureManager:self didFinishMergingVideosToOutPutFileAtURL:outputURL];
        }

    });
}

@end

