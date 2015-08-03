//
//  DoCoExporterManager.h
//  doco_ios_app
//
//  Created by developer on 15/5/1.
//  Copyright (c) 2015年 developer. All rights reserved.
//
#import "DoCoVideoLayerAnimationManager.h"

typedef void (^AnimationBlock)(AVMutableVideoComposition *videoCom,CGSize size);
typedef void (^CuttoBlock)(DoCoVideoLayerAnimationManager *manager);
typedef void (^OverallAnimationBlock)(AVMutableVideoComposition *videoCom,CGSize size,DoCoVideoLayerAnimationManager *manager);
typedef void (^CompletionBlock)(NSURL *outputURL);
typedef void (^BeginBlock)(AVMutableComposition *mixComposition,AVVideoComposition *videoComposition, AVMutableAudioMix *audioMix,NSURL *outputURL);

@interface DoCoExporterManager : NSObject

+(void)exportDidFinish:(NSURL *)outputURL;

+(void)videoApplyAnimationAtFileURL:(NSURL *)fileURL orientation:(NSInteger)orientation duration:(float)duration outputFilePath:(NSString *)outputfilePath Animation:(AnimationBlock)animation Completion:(CompletionBlock)completion;

+ (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray orientation:(NSInteger )orientation mergerFilePath:(NSString *)mergeFilePath cutto:(CuttoBlock)cutto Animation:(OverallAnimationBlock)animation Begin:(BeginBlock)begin Completion:(CompletionBlock)completion;

+(void)trimVideo:(NSURL *)fileURL startTime:(float)startTime endTime:(float)endTime toFilePath:(NSString *)newPath Completion:(CompletionBlock)completion;

@end
