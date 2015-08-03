//
//  VideoFinishController.m
//  doco_ios_app
//
//  Created by developer on 15/5/18.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "VideoFinishController.h"
#import "DCPlayView.h"
#import "customButton.h"
#import "MDRadialProgressView.h"
#import "DoCoExporterManager.h"
#import "AnimationAnalysisTool.h"
#import "DoCoExporterWriter.h"
#import "FinishTool.h"
#import "FileTool.h"
#import <MediaPlayer/MediaPlayer.h>

#define topBtnMargin 10
#define topBtnW 80
#define topBtnH 20
#define topBtnTopSpace 33

#define commonBorderMargin 25
#define playerTopSpace 21

#define recommendTopSpace 20
#define recommendLabelW 110
#define recommendSwitchW 51
#define recommendLabelSpaceSwitch 5
#define recommendH 31
#define recommendFont 15


#define progressTopSpace 27
#define progressW 78
#define progressBtnH 20

#define saveBtnW 43
#define saveBtnTopSpace 27
#define saveLabelTopSpace 5
#define saveLabelW 60
#define saveFontSize 12

#define shareImageH 9.5
#define shareImageW 198.5
#define shareImageTopSpace 30.5

#define bottomBtnW 34.5
#define bottomBtnH 45
#define bottomBtnHSpace 8
#define bottomViewTopSpace 23.5

#define btnFontSize 20
@interface VideoFinishController ()<DCPlayViewDelegate,DoCoExporterWriterDelegate>
@property(nonatomic,strong)customButton *backBtn;
@property(nonatomic,strong)customButton *finishBtn;
@property(nonatomic,strong)DCPlayView *dcPlayer;
@property(nonatomic,strong)UIView *recommendView;
@property(nonatomic,strong)UISwitch *recommemdSwitch;
@property(nonatomic,strong)MDRadialProgressView *progressView;
@property(nonatomic,strong)UIButton *progressBtn;
@property(nonatomic,assign)BOOL canSave;
@property(nonatomic,strong)UIImageView *shareIamgeView;
@property(nonatomic,strong)UIView *bottomView;

@property(nonatomic,copy)NSString *uploadUrl;
@property(nonatomic,strong)UIImage *coverImage;

@property(nonatomic,strong)dispatch_group_t dispatchGroup;
@property(nonatomic,strong)dispatch_queue_t myGlobalQ;


//播放器视图控制器
@property (nonatomic,strong) MPMoviePlayerViewController *moviePlayerViewController;

@property(nonatomic,assign)BOOL hasProcessed;
@end

@implementation VideoFinishController

- (void)viewDidLoad {
    [super viewDidLoad];
    _canSave = NO;
    [self buildUI];
    _hasProcessed = NO;
    
}

-(void)viewDidAppear:(BOOL)animated{
    if (!_hasProcessed) {
        [self.view setUserInteractionEnabled:NO];
        [self pressFinish];
        _hasProcessed = YES;
    }
    
}

-(void)dealloc{
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//去除状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)buildUI{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initTopBtn];
    [self initPlayer];
    [self initProgressView];
    [self initShareImage];
    [self initShareBtn];
    
}

-(void)initTopBtn{
    
    _backBtn = [[customButton alloc]initWithFrame:CGRectMake(topBtnMargin, topBtnTopSpace*autoScaleY, topBtnW*autoScaleX, topBtnH*autoScaleY)withIsImageLeft:YES];
    [_backBtn setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn setTitleColor:color(55,165,175, 1) forState:UIControlStateNormal];
    [_backBtn.titleLabel setFont:[UIFont fontWithName:commonFont size:btnFontSize]];
    [_backBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    UIImage *image = [UIImage imageNamed:@"right_arrow"];
    _finishBtn = [[customButton alloc]initWithFrame:CGRectMake(DEVICE_SIZE.width-topBtnMargin-topBtnW*autoScaleX, topBtnTopSpace*autoScaleY, topBtnW*autoScaleX, topBtnH*autoScaleY) withIsImageLeft:NO];
    [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_finishBtn.titleLabel setFont:[UIFont fontWithName:commonFont size:btnFontSize]];
    [_finishBtn setImage:image forState:UIControlStateNormal];
    [_finishBtn setTitleColor:color(55,165,175, 1) forState:UIControlStateNormal];
    [_finishBtn addTarget:self action:@selector(finishButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_finishBtn];
}

-(void)initPlayer{
    float y = CGRectGetMaxY(_backBtn.frame)+playerTopSpace;
    float width = DEVICE_SIZE.width-90;
    _dcPlayer = [[DCPlayView alloc]initWithFrame:CGRectMake(0, y, width, width*9/16)];
    _dcPlayer.hidden = YES;
    [self.view addSubview:_dcPlayer];
}


-(void)switchChanged:(id)sender{
    
}

-(void)initProgressView{
    float y = CGRectGetMaxY(_dcPlayer.frame)+progressTopSpace;
    float width = progressW*autoScaleX;
    float x = (DEVICE_SIZE.width - width)/2;
    _progressView = [[MDRadialProgressView alloc]initWithFrame:CGRectMake(x, y, width, width)];
    [_progressView setBackgroundColor:[UIColor whiteColor]];
    _progressView.progressTotal = 100;
    _progressView.progressCurrent = 1;
    _progressView.completedColor = color(55,165,175, 1);
    _progressView.incompletedColor = [UIColor grayColor];
    _progressView.sliceDividerHidden = YES;
    _progressView.thickness = 10;
    [self.view addSubview:_progressView];
    
    _progressBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, progressW*autoScaleX, progressBtnH*autoScaleY)];
    _progressBtn.center = _progressView.center;
    [_progressBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_progressBtn setTitle:@"合成中" forState:UIControlStateNormal];
    [_progressBtn setTitleColor:color(55,165,175, 1) forState:UIControlStateNormal];
    [_progressBtn.titleLabel setFont:[UIFont fontWithName:commonFont size:progressBtnH]];
    [_progressBtn addTarget:self action:@selector(uploadWithURL) forControlEvents:UIControlEventTouchUpInside];
    _progressBtn.enabled = NO;
    [self.view addSubview:_progressBtn];
}

-(void)pressFinish{
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
//                message:@"请为自己的作品命名："
//               delegate:self
//      cancelButtonTitle:@"取消"
//      otherButtonTitles:@"确定", nil];
//        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//        [alert show];
//        
//    });
    
    NSMutableArray *fileURLs = [[NSMutableArray alloc]init];
    
    self.dispatchGroup = dispatch_group_create();
    self.myGlobalQ = dispatch_queue_create("myGlobalQ", DISPATCH_QUEUE_CONCURRENT);
    for (int i=0;i<_project.partArray.count; i++) {
        DoCoProjectPart *part = _project.partArray[i];
        if (!part.isSelected) {
            continue;
        }
        if (i==0) {
            dispatch_group_enter(self.dispatchGroup);
            if(part.okVideoUrl){
                
                _progressView.progressCurrent+=10;
                [fileURLs addObject:part.okVideoUrl];
                    dispatch_group_leave(self.dispatchGroup);
                continue;
            }
            NSString *outputPath = [NSString stringWithFormat:@"%@/%d.mp4",_project.folderPath,i+1];
            NSURL *outURL = [NSURL fileURLWithPath:outputPath];
            [fileURLs addObject:outURL];
            UIImage *headImage = part.image;
            NSURL *headURL = [[NSBundle mainBundle]URLForResource:@"heng" withExtension:@"mov"];
            [DoCoExporterManager videoApplyAnimationAtFileURL:headURL orientation:AVCaptureVideoOrientationLandscapeRight  duration:part.maxTime outputFilePath:outputPath
            Animation:^(AVMutableVideoComposition *videoCom,CGSize size){
                [self animation:videoCom Size:size headImage:headImage footImage:nil seg:_segments[@"segment1"] part:part];
            } Completion:^(NSURL *outputURL){
                part.okVideoUrl = outputURL;               _progressView.progressCurrent+=10;
                dispatch_group_leave(self.dispatchGroup);
                
            }];
        }
        else if (i==_project.partArray.count-1){
            dispatch_group_enter(self.dispatchGroup);
            if(part.okVideoUrl){
                _progressView.progressCurrent+=10;
                [fileURLs addObject:part.okVideoUrl];
                    dispatch_group_leave(self.dispatchGroup);
                
                continue;
            }
            UIImage *footImage = part.image;
            NSString *outputPath = [NSString stringWithFormat:@"%@/%d.mp4",_project.folderPath,i+1];
            NSURL *outURL = [NSURL fileURLWithPath:outputPath];
            [fileURLs addObject:outURL];
            NSURL *footURL = [[NSBundle mainBundle]URLForResource:@"heng" withExtension:@"mov"];
            [DoCoExporterManager videoApplyAnimationAtFileURL:footURL orientation:AVCaptureVideoOrientationLandscapeRight  duration:part.maxTime outputFilePath:outputPath
            Animation:^(AVMutableVideoComposition *videoCom,CGSize size){
                [self animation:videoCom Size:size headImage:nil footImage:footImage seg:_segments[[NSString stringWithFormat:@"segment%d",i+1]] part:part];
            } Completion:^(NSURL *outputURL){
                _progressView.progressCurrent+=10;
                
 part.okVideoUrl = outputURL;
dispatch_group_leave(self.dispatchGroup);
            }];
        }
        else{
            dispatch_group_enter(self.dispatchGroup);
            if(part.okVideoUrl){
                _progressView.progressCurrent+=10;
                [fileURLs addObject:part.okVideoUrl];
                    dispatch_group_leave(self.dispatchGroup);
                
                continue;
            }
            NSString *outputPath = [NSString stringWithFormat:@"%@/%d.mp4",_project.folderPath,i+1];
            NSURL *outURL = [NSURL fileURLWithPath:outputPath];
            [fileURLs addObject:outURL];
            NSURL *videoUrl1 = [NSURL fileURLWithPath:part.videoPath];
            NSString *trimPath = [NSString stringWithFormat:@"%@/trim%d.mp4",[FileTool getSaveFolderPathStringWithFolderName:VIDEO_FOLDER],i+1];
            [DoCoExporterManager trimVideo:videoUrl1 startTime:0 endTime:part.maxTime toFilePath:trimPath Completion:^(NSURL *outputURL) {
                [DoCoExporterManager videoApplyAnimationAtFileURL:outputURL orientation:AVCaptureVideoOrientationLandscapeRight  duration:0 outputFilePath:outputPath
            Animation:^(AVMutableVideoComposition *videoCom,CGSize size){
                
                [self animation:videoCom Size:size headImage:nil footImage:nil seg:_segments[[NSString stringWithFormat:@"segment%d",i+1]] part:part];
            }
           Completion:^(NSURL *outputURL){
               part.okVideoUrl = outputURL;
               _progressView.progressCurrent+=10;
                    dispatch_group_leave(self.dispatchGroup);
                }];
                
            }];
        }
        
    }//for循环的
    
    
    
    //分段合成完毕
    dispatch_group_notify(self.dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
        [DoCoExporterManager mergeAndExportVideosAtFileURLs:fileURLs orientation:AVCaptureVideoOrientationLandscapeRight mergerFilePath:[FileTool getVideoMergeFilePathStringWithFolderPath:_project.folderPath]
          cutto:^(DoCoVideoLayerAnimationManager *manager)
         {
             
             AnimationAnalysisTool *tool = [[AnimationAnalysisTool alloc]init];
             [tool cuttoAnimationAnalysisWithDic:_cuttos manager:manager];
             
         }
      Animation:^(
      
                  AVMutableVideoComposition *videoCom, CGSize size ,DoCoVideoLayerAnimationManager *manager) {
          CALayer *parentLayer = [CALayer layer];
          CALayer *videoLayer = [CALayer layer];
          parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
          videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
          [parentLayer addSublayer:videoLayer];
          AnimationAnalysisTool *tool = [[AnimationAnalysisTool alloc]init];
          tool.isPortrait = NO;
          [tool overall_layerAnimationAnalysisWithDic:_overalls parentLayer:parentLayer];
          [tool cuttoLayerAnimationAnalysisWithDic:_cuttolayers parentLayer:parentLayer manager:manager];
          
        #pragma mark-添加水印
          UIImage *waterImage = [UIImage imageNamed:@"watermark_doco"];
          CALayer *waterLayer = [CALayer layer];
          waterLayer.frame = CGRectMake(0, 0, 960, 540);
          [waterLayer setContents:(id)waterImage.CGImage];
          [parentLayer addSublayer:waterLayer];
          videoCom.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];

      }
      Begin:^(AVMutableComposition *mixComposition, AVVideoComposition *videoComposition, AVMutableAudioMix *audioMix, NSURL *outputURL) {
//          DoCoExporterWriter *editer = [[DoCoExporterWriter alloc]initWithSource:mixComposition videoComposition:videoComposition audioMix:audioMix outputURL:outputURL Script:@"GQT"];
//          
//          editer.delegate =self;

      }
    Completion:^(NSURL *outputURL) {
          [self.view setUserInteractionEnabled:YES];
          _progressView.progressCurrent = 100;
          [_progressBtn setTitle:@"播放" forState:UIControlStateNormal];
          _progressBtn.enabled = YES;
        _project.okVideoURL = outputURL;
        _coverImage = [FinishTool thumbnailImageForVideo:_project.okVideoURL atTime:_project.frameTime];
        
        _moviePlayerViewController = nil;
        [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
        //删除videos中的视频
        for (int j=2; j<_project.partArray.count; j++) {
            NSString *trimPath = [NSString stringWithFormat:@"%@/trim%d.mp4",[FileTool getSaveFolderPathStringWithFolderName:VIDEO_FOLDER],j+1];
            [FileTool removeFile:[NSURL fileURLWithPath:trimPath]];
        }
        }];
    });

}

-(MPMoviePlayerViewController *)moviePlayerViewController{
    if (!_moviePlayerViewController) {
        _moviePlayerViewController=[[MPMoviePlayerViewController alloc]initWithContentURL:_project.okVideoURL];
        
        _moviePlayerViewController.moviePlayer.controlStyle =MPMovieControlStyleFullscreen;
        [_moviePlayerViewController.moviePlayer setFullscreen:YES];
        [self addNotification];
    }
    return _moviePlayerViewController;
}

#pragma mark - 控制器通知
/**
 *  添加通知监控媒体播放控制器状态
 */
-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackStateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayerViewController.moviePlayer];
    [notificationCenter addObserver:self selector:@selector(mediaPlayerPlaybackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerViewController.moviePlayer];
    
}

/**
 *  播放状态改变，注意播放完成时的状态是暂停
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackStateChange:(NSNotification *)notification{
    switch (self.moviePlayerViewController.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            break;
        case MPMoviePlaybackStatePaused:
            break;
        case MPMoviePlaybackStateStopped:
            break;
        default:
            break;
    }
}

/**
 *  播放完成
 *
 *  @param notification 通知对象
 */
-(void)mediaPlayerPlaybackFinished:(NSNotification *)notification{

}


-(void)uploadWithURL{
    _moviePlayerViewController = nil;
    
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
}

-(void)animation:(AVMutableVideoComposition *)videoCom Size:(CGSize)size headImage:(UIImage *)headImage footImage:(UIImage *)footImage seg:(NSDictionary *)segment part:(DoCoProjectPart *)part{
    //以后添加视频本身的效果
    //    NSDictionary *video = segment[@"video"];
    //        float startTime = [self getTimeFromFrame:segment[@"starttime"]];
    AnimationAnalysisTool *tool = [[AnimationAnalysisTool alloc]init];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    //    videoLayer = [tool setupLayerWithDic:video startTime:startTime type:nil];
    if (segment[@"backgroundImage"]) {//有背景图
        UIImage *bgImage = [UIImage imageNamed:segment[@"backgroundImage"]];
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, size.width, size.height);
        [layer setContents:(id)bgImage.CGImage];
        if (headImage||footImage) {//片头或者片尾添加到videolayer中
            [videoLayer addSublayer:layer];
        }else{//添加到videoLayer的下面
            [parentLayer addSublayer:layer];
        }
    }
    [parentLayer addSublayer:videoLayer];
    
    tool.isPortrait = NO;
    [tool segmentAnimationAnalysisWithDic:segment subtitles:part.subtitles parentLayer:parentLayer headImage:headImage footImage:footImage];
    
    videoCom.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}



-(void)initShareImage{
    float y = CGRectGetMaxY(_progressView.frame) + shareImageTopSpace;
    float width = shareImageW*autoScaleX;
    float x = (DEVICE_SIZE.width - width)/2;
    _shareIamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, width, shareImageH*autoScaleY)];
    _shareIamgeView.image = [UIImage imageNamed:@"finish_zi"];
    [self.view addSubview:_shareIamgeView];
}

-(void)initShareBtn{
    float y = CGRectGetMaxY(_shareIamgeView.frame) + bottomViewTopSpace;
    float width = bottomBtnW*autoScaleX;
    float x = (DEVICE_SIZE.width - width) / 2;
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(x, y,width , bottomBtnH*autoScaleY)];
    [self.view addSubview:_bottomView];
    
    UIButton *localBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, bottomBtnW*autoScaleX, bottomBtnH*autoScaleY)];
    [localBtn setImage:[UIImage imageNamed:@"finish_icon1"] forState:UIControlStateNormal];
    [localBtn addTarget:self action:@selector(localSave:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:localBtn];
    
}

-(void)localSave:(UIButton *)sender{
    [DoCoExporterManager exportDidFinish:_project.okVideoURL];
    sender.enabled = NO;
}



#pragma mark-点击事件
-(void)backButtonClick{
    for (DoCoProjectPart *part in _project.partArray){
        [FileTool removeFile:part.okVideoUrl];
        part.okVideoUrl = nil;
    }
    [FileTool removeFile:_project.okVideoURL];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)finishButtonClick{
    NSString *Folder = [FileTool getSaveFolderPathStringWithFolderName:VIDEO_FOLDER];
    NSURL *url = [NSURL fileURLWithPath:Folder];
    [FileTool removeFile:url];
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
