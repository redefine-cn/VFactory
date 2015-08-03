//
//  DoCoExporterWriter.h
//  doco_ios_app
//
//  Created by developer on 15/4/19.
//  Copyright (c) 2015年 developer. All rights reserved.
//

@protocol DoCoExporterWriterDelegate ;
@interface DoCoExporterWriter : NSObject
@property(nonatomic,strong)AVAsset *asset;

@property(nonatomic,strong)AVVideoComposition *videoCom;
@property(nonatomic,strong)AVComposition *mixCom;
@property(nonatomic,strong)AVMutableAudioMix *audioMix;

@property(nonatomic,strong)AVAssetReader *assetReader;
@property(nonatomic,strong)AVAssetReaderOutput *assetReaderAudioOutput;
@property(nonatomic,strong)AVAssetReaderOutput *assetReaderVideoOutput;

@property(nonatomic,strong)AVAssetReaderVideoCompositionOutput *videoOutput;
@property(nonatomic,strong)AVAssetReaderAudioMixOutput *audioOutput;

@property(nonatomic,strong)AVAssetWriter *assetWriter;
@property(nonatomic,strong)AVAssetWriterInput *assetWriterAudioInput;
@property(nonatomic,strong)AVAssetWriterInput *assetWriterVideoInput;
@property(nonatomic,strong)NSURL *outputURL;

@property(nonatomic,assign)BOOL cancelled;
@property(nonatomic,assign)BOOL audioFinished;
@property(nonatomic,assign)BOOL videoFinished;

@property(nonatomic,strong)dispatch_queue_t mainSerializationQueue;
@property(nonatomic,strong)dispatch_queue_t rwAudioSerializationQueue;
@property(nonatomic,strong)dispatch_queue_t rwVideoSerializationQueue;
@property(nonatomic,strong)dispatch_group_t dispatchGroup;

@property(nonatomic,strong)id<DoCoExporterWriterDelegate> delegate;

@property(nonatomic,strong)CIContext *context;
@property(nonatomic,strong)AVAssetWriterInputPixelBufferAdaptor *videoPixelBufferAdaptor;

@property(nonatomic,copy)NSString *scriptName;

-(instancetype)initWithSourceURL:(NSURL *)sourceURL outputURL:(NSURL *)outputURL;

-(instancetype)initWithSource:(AVMutableComposition *)mixComposition videoComposition:(AVVideoComposition *)videoComposition audioMix:(AVMutableAudioMix *)audioMix outputURL:(NSURL *)outputURL Script:(NSString *)scriptName;

@end

@protocol DoCoExporterWriterDelegate <NSObject>
@optional

-(void)readingAndWritingDidBeginWithProgress:(float)progress;

-(void)readingAndWritingDidFinishSuccessfullyWithOutputURL:(NSURL *)outputURL;
@end
