//
//  DoCoExporterManager.m
//  doco_ios_app
//
//  Created by developer on 15/5/1.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoExporterManager.h"
#import "FileTool.h"
#import "DoCoVideoLayerAnimationManager.h"
#import "DoCoExporterWriter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation DoCoExporterManager

#pragma mark-实现类方法
//输出到相册
+ (void)exportDidFinish:(NSURL *)outputURL {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
    {
        
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                        message:@"保存相册失败"
                        delegate:nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
                        [alert show];
                } else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                            message:@"保存相册成功！"
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
                            [alert show];
                }
        });

            
        }];
    }
}

+(void)videoApplyAnimationAtFileURL:(NSURL *)fileURL orientation:(NSInteger)orientation duration:(float)duration outputFilePath:(NSString *)outputfilePath Animation:(AnimationBlock)animation Completion:(CompletionBlock)completion{
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        NSError *error = nil;
        CGSize renderSize;
        if (orientation == AVCaptureVideoOrientationPortrait)
        {
            renderSize = renderSizeP;
        }else{
            renderSize = renderSizeL;
        }
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        AVAsset *asset = [AVAsset assetWithURL:fileURL];
        AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        //assettrack默认是横屏模式，所以这里宽>高
        CGSize naturalSize;
        if (orientation ==AVCaptureVideoOrientationPortrait) {
            //如果是竖屏
            naturalSize.width = assetTrack.naturalSize.height;
            naturalSize.height = assetTrack.naturalSize.width;
        }else{//横屏
            naturalSize.width = assetTrack.naturalSize.width;
            naturalSize.height = assetTrack.naturalSize.height;
        }
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSArray *trackarr = [asset tracksWithMediaType:AVMediaTypeAudio];
    CMTime dur;
    if (duration>0) {
        dur = CMTimeMake(600*duration, 600);
    }else{
        dur = asset.duration;
    }
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, dur)
                            ofTrack:([trackarr count]>0)?[trackarr objectAtIndex:0]:nil
                             atTime:kCMTimeZero
                              error:nil];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, dur)
                            ofTrack:assetTrack
                             atTime:kCMTimeZero
                              error:&error];
        
        //调整视频方向、大小一致
        //视频大小调整策略
        /**
         *1.强制拉伸或者缩小到960*540  填满  --
         *2.保持比例不变，放缩到到等高或者等宽，居中显示
         *3.保持原大小，居中显示
         *
         **/
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
        float rateW = naturalSize.width/renderSize.width;
        float rateH = naturalSize.height/renderSize.height;
        
        CGAffineTransform transform = CGAffineTransformScale(assetTrack.preferredTransform, rateW, rateH);
        
        [layerInstruciton setTransform:transform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:asset.duration];

        //get save path
        
        NSURL *outputURL = [NSURL fileURLWithPath:outputfilePath];
        
        
        //export
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        mainInstruciton.layerInstructions = @[layerInstruciton];
        AVMutableVideoComposition *videoCom = [AVMutableVideoComposition videoComposition];
        videoCom.instructions = @[mainInstruciton];
        videoCom.frameDuration = CMTimeMake(1, 25);
        videoCom.renderSize = CGSizeMake(renderSize.width, renderSize.height);
        
        if(animation){
            animation(videoCom,renderSize);
        }

        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset960x540];
        exporter.videoComposition = videoCom;
        exporter.outputURL = outputURL;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completion){
                    completion(outputURL);
                }
                
            });
        }];
        
//    });

}

+ (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray orientation:(NSInteger )orientation mergerFilePath:(NSString *)mergeFilePath cutto:(CuttoBlock)cutto Animation:(OverallAnimationBlock)animation Begin:(BeginBlock)begin Completion:(CompletionBlock)completion
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        DoCoVideoLayerAnimationManager *manager = [[DoCoVideoLayerAnimationManager alloc]init];
        if (orientation == AVCaptureVideoOrientationPortrait) {
            manager.renderSize = renderSizeP;
        }else{
            manager.renderSize = renderSizeL;
        }

        for (NSURL *fileURL in fileURLArray) {
            
            AVAsset *asset = [AVAsset assetWithURL:fileURL];
            if (!asset) {
                continue;
            }
            [manager.assetArray addObject:asset];
        }
        [manager firstTrack];
        
        if (cutto) {
            cutto(manager);
        }
    NSURL *waterURL = [[NSBundle mainBundle]URLForResource:@"water" withExtension:@"mov"];
    AVAsset *waterAsset = [AVAsset assetWithURL:waterURL];
    
    NSArray *videoTracks = [waterAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack = videoTracks[0];
    if (videoTracks.count==0) {
        MyLog(@"videoTracks为空了");
    }
    
    AVMutableCompositionTrack *videoComTrack = [manager.mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [videoComTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, waterAsset.duration)
                           ofTrack:videoTrack
                            atTime:manager.totalDuration
                             error:nil];
    
    //后视频动画设置
    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoComTrack];
    
    manager.totalDuration = CMTimeAdd(manager.totalDuration, waterAsset.duration);
    //这是为了防止ghost现象  应该在本段最后添加效果
    [layerInstruciton setOpacity:0.0 atTime:manager.totalDuration];
    [manager.layerInstructionArray insertObject:layerInstruciton atIndex:0];

    
        //export
        
        //video
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, manager.totalDuration);
        mainInstruciton.layerInstructions = manager.layerInstructionArray;
        AVMutableVideoComposition *videoCom = [AVMutableVideoComposition videoComposition];
        videoCom.instructions = @[mainInstruciton];
        videoCom.frameDuration = CMTimeMake(1, 25);
        videoCom.renderSize = manager.renderSize;
        
        if(animation){
            animation(videoCom,manager.renderSize,manager);
        }
    //audio
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:manager.audioMixParas];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:mergeFilePath];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:manager.mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.audioMix = audioMix;
    exporter.videoComposition = videoCom;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion){
                completion(mergeFileURL);
            }
            
        });
    }];

    
//        if (begin) {//开始合成  用于writer
//            begin(manager.mixComposition,videoCom,audioMix,mergeFileURL);
//        }
    
    
    
//    });//global线程使用

}
//裁剪视频
+(void)trimVideo:(NSURL *)fileURL startTime:(float)startTime endTime:(float)endTime toFilePath:(NSString *)newPath Completion:(CompletionBlock)completion{
    
    NSURL *newURL = [NSURL fileURLWithPath:newPath];
    [FileTool removeFile:newURL];
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPreset960x540]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:asset presetName:AVAssetExportPreset960x540];
        // Implementation continues.
        exportSession.outputURL = newURL;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(startTime, asset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(endTime - startTime, asset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            if (completion) {
                completion(newURL);
                MyLog(@"error:%@",exportSession.error);
            }
        }];
    }

}

@end
