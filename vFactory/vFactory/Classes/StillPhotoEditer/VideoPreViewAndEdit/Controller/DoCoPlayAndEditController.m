//
//  DoCoPlayAndEditController.m
//  DCPlayer
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoPlayAndEditController.h"
#import "DCPlayView.h"
#import "DoCoVideoTrimmerView.h"
#import "DoCoProject.h"
#import "DoCoProjectPart.h"
#import "DoCoCollectionView.h"  
#import "DXPopover.h"
#import "UIView+Shadow.h"
#import "customButton.h"
#import "FileTool.h"
#import "MBProgressHUD.h"
#import "AVCamCaptureManager.h"
#import "ViewToolkit.h"
#import "VideoFinishController.h"
#import "DoCoExporterManager.h"
#import "AnimationAnalysisTool.h"
#import "DoCoExporterWriter.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZYQAssetPickerController.h"


#define leftArrowW 8
#define leftArrowH 14


#define cellSelecteColor color(122,204,17,1)
#define cellDeSelecteColor color(54,165,173,1)

#define titleCellH 32
#define circleH 5.5
#define titilLabelH 25
#define titleCellW 60
#define titleCellColumnSpace 7
#define titleTopMargin 5
#define titleFontSize 12

//箭头宽
#define arrowW 15.5
#define arrowH 15

#define commonBorderMargin 25
//player
#define playTopSpace 33.5

//timeView
#define timeViewW 85
#define timeViewH 17.5
#define timeFontSize 14
#define timeCornerR 4

//trim
#define trimTopSpace 13.5
#define trimH 36.5
#define trimW 290
#define trimLeftMargin 5
#define trimleftW 10

//text
#define textTopSpace 11.5
#define textTopH 28.5
#define textTopW 275

#define textLeftMargin 30
#define textVSpace 10

#define textViewW 250
#define textViewH 110
#define labelH 20
#define labelW 80
#define fieldW 150
#define fieldH 20

//button
#define previewBtnW 130
#define previewBtnH 33
#define previewTopSpace 10.5

#define btnBorderMargin 5
#define buttonBottomMargin 30
#define btnW  80.0
#define btnH  17
#define btnFontSize 20

#define popCellW 45
#define popCellH 20
#define popFontSize 9

#define kHeaderHeight 23*autoScaleY
#define kFooterHeight 23*autoScaleY

@interface DoCoPlayAndEditController()<DCPlayViewDelegate,DoCoCollectionViewDelegate,DoCoVideoTrimmerDelegate, UIAlertViewDelegate,AVCamCaptureManagerDelegate,UITextFieldDelegate,DoCoExporterWriterDelegate>
{
    DoCoVideoTrimmerView *docoTrimView;
    UIImageView *leftTrimView;
    UIImageView *rightTrimView;
    
    //字幕
    UIImageView *textTopView;
    UILabel *textLabel1;
    UITextField *textFiled1;
    
    UILabel *textLabel2;
    UITextField *textFiled2;
    
    UILabel *textLabel3;
    UITextField *textFiled3;
    
    UILabel *textLabel4;
    UITextField *textFiled4;
    UIImageView *textBottomView;
    
    CMTimeScale timeScale;
    
    DoCoProjectPart *currentPart;
    
    DoCoCollectionView *popCollection;
    
    UIButton *_previewBtn;
    
    BOOL isTextShow;
    
    UIView *_audioChoiceView;
    NSMutableArray *_audioCellFrames;
}
//播放器视图控制器
@property (nonatomic,strong) MPMoviePlayerViewController *moviePlayerViewController;

@property(nonatomic,strong)DXPopover *popView;
@property(nonatomic,strong)NSMutableArray *popSelect;

@property(nonatomic,strong)UIView *timeView;
@property(nonatomic,strong)UILabel *leftTimeLabel;
@property(nonatomic,strong)UILabel *rightTimeLabel;

@property(nonatomic,strong)DoCoCollectionView *titleCollection;
@property(nonatomic,strong)NSMutableArray *labels;
@property(nonatomic,strong)NSMutableArray *circles;

@property(nonatomic,strong)UIButton *leftArrowBtn;
@property(nonatomic,strong)UIButton *rightArrowBtn;
@property(nonatomic,strong)customButton *lastButton;
@property(nonatomic,strong)customButton  *nextButton;
@property(nonatomic,strong)customButton *musicButton;

@property(nonatomic,strong)AVAsset *currentAsset;
@property(nonatomic,strong)MBProgressHUD *hud;
@property(nonatomic,strong)MBProgressHUD *hud2;
@property(nonatomic,assign)float uploadPercent;

@property(nonatomic,assign)NSInteger currentIndex;

@property(nonatomic,strong)CALayer *imageLayer;

@property(nonatomic,strong)UIView *textView;
@property(nonatomic,strong)UIView *contentView;

@property(nonatomic,strong)NSMutableDictionary *segments;
@property(nonatomic,strong)NSMutableDictionary *cuttos;
@property(nonatomic,strong)NSMutableDictionary *overalls;
@property(nonatomic,strong)NSMutableDictionary *cuttolayers;

@property(nonatomic,strong)dispatch_group_t dispatchGroup;
@end
@implementation DoCoPlayAndEditController
//去除状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self loadPlist];
    [self buildUI];
    
}


-(void)dealloc{
    //移除所有通知监控
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)loadPlist{
    
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:_project.scriptName ofType:@"plist"];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    _segments = [NSMutableDictionary dictionaryWithDictionary:plist[@"segments"]];
    _overalls = [NSMutableDictionary dictionaryWithDictionary: plist[@"overall_layers"]];
    _cuttolayers = [NSMutableDictionary dictionaryWithDictionary:plist[@"cutto_layers"]];
    _cuttos = [NSMutableDictionary dictionaryWithDictionary: plist[@"cuttos"]];
}

-(void)buildUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view setUserInteractionEnabled:YES];
    
    _contentView = [[UIView alloc]initWithFrame:self.view.frame];
    _contentView.backgroundColor = [UIColor whiteColor];
    [_contentView setUserInteractionEnabled:YES];
    [_contentView setClipsToBounds:YES];
    [self.view addSubview:_contentView];
    
    [self initTitleCollection];
    [self initPlayer];
    [self initTrimView];
    [self initTextView];
    [self initBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasHidden:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark-键盘的监听
-(void)keyboardwasShown:(NSNotification *) notify{
    
    NSDictionary *info = [notify userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGSize keyBoardSize = [aValue CGRectValue].size;
    
    CGRect rect = self.contentView.frame;
    rect.origin.y = - keyBoardSize.height + rect.size.height - CGRectGetMaxY(_textView.frame);
    self.contentView.frame = rect;
    
}

-(void) keyboardwasHidden:(NSNotification *) notify{
    CGRect rect = self.contentView.frame;
    rect.origin.y = 0;
    self.contentView.frame = rect;
}




-(void)initTitleCollection{
    
    long itemCount =_project.partArray.count;
    float width = titleCellW*4*autoScaleX+titleCellColumnSpace*3*autoScaleX;
    float height = titleCellH*autoScaleY;
    float x = (DEVICE_SIZE.width - width)/2;
    float y = titleTopMargin*autoScaleY;
    CGSize itemSize = CGSizeMake(titleCellW*autoScaleX, height);
    
    CGRect titleCollectionFrame = CGRectMake(x, y,width, height);
    CGRect contentFrame = CGRectMake(0, 0, itemSize.width, itemSize.height);
    NSMutableArray *contents = [[NSMutableArray alloc]init];
    _circles = [[NSMutableArray alloc]init];
    _labels = [[NSMutableArray alloc]init];
    for (int i=0; i<itemCount; i++) {
        DoCoProjectPart *part = _project.partArray[i];
        UIView *content = [[UIView alloc]initWithFrame:contentFrame];
        
        UIImageView *circle = [[UIImageView alloc]initWithFrame:CGRectMake((itemSize.width-circleH)/2, 0, circleH, circleH)];
        circle.image = [UIImage imageNamed:@"littlecircle"];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, itemSize.height - titilLabelH*autoScaleY, itemSize.width, titilLabelH*autoScaleY)];
        [content addSubview:circle];
        
        [label setText:part.partName];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [label.layer setCornerRadius:6.0f];
        [label.layer setBorderColor:color(255, 255, 255, 0.5).CGColor];
        [label setFont:[UIFont fontWithName:commonFont size:titleFontSize]];
        [label.layer setMasksToBounds:YES];
        [label.layer setBorderWidth:1.0f];
        label.backgroundColor = cellDeSelecteColor;
        circle.hidden = YES;
        if (i==1) {
            label.backgroundColor = cellSelecteColor;
            circle.hidden=NO;
        }
        [content addSubview:label];
        [_labels addObject:label];
        [_circles addObject:circle];
        [contents addObject:content];
        
    }
    _currentIndex = 1;
    currentPart = _project.partArray[1];
    
    _titleCollection = [[DoCoCollectionView alloc]initWithFrame:titleCollectionFrame dataSource:contents itemSize:itemSize itemColumnSpace:titleCellColumnSpace itemRowSpace:0 privateKey:@"title"];

    _titleCollection.docoDelegate = self;
    [_contentView addSubview:_titleCollection];
    
    //左右箭头
    float leftArrowX = CGRectGetMinX(_titleCollection.frame)-leftArrowW*autoScaleX-5;
    float arrowY = CGRectGetMaxY(_titleCollection.frame)-titilLabelH*autoScaleY/2-leftArrowH*0.5;
    UIImageView *leftArrow = [[UIImageView alloc]initWithFrame:CGRectMake(leftArrowX, arrowY, leftArrowW, leftArrowH)];
    leftArrow.image = [UIImage imageNamed:@"arrow_point_left"];
    [self.view addSubview:leftArrow];
    
    float rightArrowX = CGRectGetMaxX(_titleCollection.frame)+5;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(rightArrowX, arrowY, leftArrowW, leftArrowH)];
    rightArrow.image = [UIImage imageNamed:@"arrow_point_right"];
    [self.view addSubview:rightArrow];

}

-(void)initPlayer{
    float x = 0;
    float y = CGRectGetMaxY(_titleCollection.frame)+playTopSpace*autoScaleY;
    
    
    NSURL *fileURL =[NSURL fileURLWithPath:currentPart.videoPath];
    _currentAsset = [AVAsset assetWithURL:fileURL];
    timeScale = _currentAsset.duration.timescale;
    NSString *filepath = currentPart.videoPath;
    [_dcPlayView setBackgroundColor:[UIColor redColor]];
    float width = DEVICE_SIZE.width;
    float height = width*9/16;
    
    _dcPlayView =[[DCPlayView alloc]initWithFrame:CGRectMake(x,y,width,height) contentUrl:filepath];
    _dcPlayView.delegate=self;
    
    
    [_dcPlayView.layer setBorderColor:color(245, 199, 32, 1.0).CGColor];
    [_dcPlayView.layer setBorderWidth:2];
    _imageLayer = [CALayer layer];
    _imageLayer.frame = CGRectMake(0,0,CGRectGetWidth(_dcPlayView.frame),CGRectGetHeight(_dcPlayView.frame));
    [_imageLayer setContentsGravity:kCAGravityResizeAspect];
    _imageLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _imageLayer.opacity = 0.0f;
    [_dcPlayView.layer addSublayer:_imageLayer];
    
    [_contentView addSubview:_dcPlayView];
    
    [self initTimeView];
    
}

-(void)initTimeView{
    float x = (CGRectGetWidth(_dcPlayView.frame)-timeViewW*autoScaleX)/2;
    float y = CGRectGetHeight(_dcPlayView.frame)-timeViewH*autoScaleY-10;
    _timeView = [[UIView alloc]initWithFrame:CGRectMake(x, y, timeViewW*autoScaleX, timeViewH*autoScaleY)];
    [_timeView setBackgroundColor:color(0, 0, 0, 0.5)];
    [_timeView.layer setCornerRadius:timeCornerR*autoScaleX];
    [_timeView.layer setMasksToBounds:YES];
    [_dcPlayView addSubview:_timeView];
    
    _leftTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeCornerR*autoScaleX, 0, timeViewW*autoScaleX/2-timeCornerR*autoScaleX, timeViewH*autoScaleY)];
    [_leftTimeLabel setBackgroundColor:[UIColor clearColor]];
    [_leftTimeLabel setTextAlignment:NSTextAlignmentLeft];
    [_leftTimeLabel setTextColor:[UIColor whiteColor]];
    [_leftTimeLabel setFont:[UIFont fontWithName:commonFont size:timeFontSize]];
    [_leftTimeLabel setText:[NSString stringWithFormat:@"%.2f",currentPart.startTime ]];
    [_timeView addSubview:_leftTimeLabel];
    
    _rightTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeViewW*autoScaleX/2, 0, timeViewW*autoScaleX/2-timeCornerR*autoScaleX, timeViewH*autoScaleY)];
    [_rightTimeLabel setBackgroundColor:[UIColor clearColor]];
    [_rightTimeLabel setTextAlignment:NSTextAlignmentRight];
    [_rightTimeLabel setTextColor:[UIColor whiteColor]];
    [_rightTimeLabel setFont:[UIFont fontWithName:commonFont size:timeFontSize]];
    [_rightTimeLabel setText:[NSString stringWithFormat:@"%.2f",currentPart.endTime ]];
    [_timeView addSubview:_rightTimeLabel];
}

-(void)initTrimView{
    float y = CGRectGetMaxY(_dcPlayView.frame) + trimTopSpace*autoScaleY;
    
    leftTrimView = [[UIImageView alloc]initWithFrame:CGRectMake(trimLeftMargin, y, trimleftW*autoScaleX, trimH*autoScaleY)];
    leftTrimView.image = [UIImage imageNamed:@"wordmu_arrow"];
    [leftTrimView setBackgroundColor:[UIColor blackColor]];
    [leftTrimView setUserInteractionEnabled:YES];
    [self.contentView addSubview:leftTrimView];
    
    float trimX = CGRectGetMaxX(leftTrimView.frame);
    docoTrimView = [[DoCoVideoTrimmerView alloc]initWithFrame:CGRectMake(trimX, y, trimW*autoScaleX, trimH*autoScaleY) asset:_currentAsset];
    docoTrimView.layer.cornerRadius = 3.0f;
    [docoTrimView.layer setMasksToBounds:YES];
    [docoTrimView setClipsToBounds:YES];
    [docoTrimView setStartTime:0];
    float duration = CMTimeGetSeconds(_currentAsset.duration);
    [docoTrimView setEndTime:duration];
    
    [docoTrimView setThemeColor:color(245, 199, 32, 1.0)];
    docoTrimView.alpha = 0.5f;
    [docoTrimView setUserInteractionEnabled:NO];
    docoTrimView.minLength = currentPart.minTime;
    docoTrimView.maxLength = duration;
    
    [docoTrimView resetSubviews];
    docoTrimView.backgroundColor = color(92, 189, 164, 1.0);
    [docoTrimView setDelegate:self];
    [self.contentView addSubview:docoTrimView];
    
    float rightTrimX = CGRectGetMaxX(docoTrimView.frame);
    rightTrimView = [[UIImageView alloc]initWithFrame:CGRectMake(rightTrimX, y, trimleftW*autoScaleX, trimH*autoScaleY)];
    rightTrimView.image = [UIImage imageNamed:@"wordmu_arroright"];
    rightTrimView.backgroundColor = [UIColor blackColor];
    [rightTrimView setUserInteractionEnabled:YES];
    [self.contentView addSubview:rightTrimView];
}

-(void)initTextView{
    
    //top
    float topY = CGRectGetMaxY(docoTrimView.frame)+textTopSpace*autoScaleY;
    float topWidth = DEVICE_SIZE.width - 2*commonBorderMargin;
    textTopView = [[UIImageView alloc]initWithFrame:CGRectMake(commonBorderMargin, topY, topWidth, textTopH*autoScaleY   )];
    [textTopView setImage:[UIImage imageNamed:@"wordmu_wordmu"]];
    [self.contentView addSubview:textTopView];
    
    [self initMidText];
    
    //isTextShow = YES;
    //[self textBottomClick];
}

-(void)initMidText{
    //mid
    float textViewY = CGRectGetMaxY(textTopView.frame)+textVSpace*autoScaleY;
    _textView = [[UIView alloc]initWithFrame:CGRectMake(textLeftMargin, textViewY, textViewW*autoScaleX, textViewH*autoScaleY)];
    _textView.backgroundColor  = [UIColor clearColor];
    
    for (int i=0; i<currentPart.subtitles.count; i++) {
        DoCoSubtitle *subtitle = currentPart.subtitles[i];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, (labelH+textVSpace)*i*autoScaleY, labelW*autoScaleX, labelH*autoScaleY)];
        label.textColor = cellDeSelecteColor;
        label.tag = i;
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), (labelH+textVSpace)*i*autoScaleY, fieldW*autoScaleX, fieldH*autoScaleY)];
        textField.tag=i;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        if (subtitle.isShow) {
            label.text = [NSString stringWithFormat:@"%@:",subtitle.textName];
        }else{
            label.text = @"字幕：";
            textField.placeholder = subtitle.textName;
            if (subtitle.text && ![subtitle.textName isEqualToString:subtitle.text]) {
                textField.text = subtitle.text;
            }else{
                subtitle.text = subtitle.textName;
            }
            [currentPart.subtitles removeObjectAtIndex:i];
            [currentPart.subtitles insertObject:subtitle atIndex:i];
        }
        [_textView addSubview:label];
        [_textView addSubview:textField];
    }
    
    [_contentView addSubview:_textView];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    DoCoSubtitle *subtitle = currentPart.subtitles[textField.tag];
    NSString *text;
    if (![textField.text isEqualToString:@""]) {
        text = textField.text;
    }else{
        text = textField.placeholder;
    }
    if([text isEqualToString:subtitle.text]){
        return;
    }
    [FileTool removeFile:currentPart.okVideoUrl];
    [currentPart.subtitles removeObjectAtIndex:textField.tag];
    subtitle.text = text;
    [currentPart.subtitles insertObject:subtitle atIndex:textField.tag];
    currentPart.okVideoUrl = nil;
}

-(void)initBtn{
    
    //previewBtn
    float x = (DEVICE_SIZE.width - previewBtnW*autoScaleX)/2;
    float y = CGRectGetMaxY(_textView.frame)+previewTopSpace*autoScaleY;
    _previewBtn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, previewBtnW*autoScaleX, previewBtnH*autoScaleY)];
    [_previewBtn setImage:[UIImage imageNamed:@"wordmu_preview"] forState:UIControlStateNormal];
    [_previewBtn addTarget:self action:@selector(pressPreviewBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_previewBtn];
    //left
    float leftX = btnBorderMargin;
    float leftY = DEVICE_SIZE.height - btnH*autoScaleY-buttonBottomMargin*autoScaleY;
    self.lastButton = [[customButton alloc] initWithFrame:CGRectMake(leftX,leftY,btnW*autoScaleX,btnH*autoScaleX) withIsImageLeft:YES];
    [self.lastButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.lastButton setTitleColor:cellSelecteColor forState:UIControlStateNormal];
    [_lastButton.titleLabel setFont:[UIFont fontWithName:commonFont size:btnFontSize]];
    [_lastButton setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    [_lastButton addTarget:self action:@selector(pressLastBtn) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_lastButton];
    
    //right
    float rightX = DEVICE_SIZE.width - btnBorderMargin - btnW*autoScaleX;
    float rightY = DEVICE_SIZE.height - btnH*autoScaleY-buttonBottomMargin*autoScaleY;
    self.nextButton = [[customButton alloc] initWithFrame:CGRectMake(rightX,rightY,btnW*autoScaleX,btnH*autoScaleX) withIsImageLeft:NO];
    [_nextButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    [self.nextButton setTitle:@"完成" forState:UIControlStateNormal];
    [_nextButton.titleLabel setFont:[UIFont fontWithName:commonFont size:btnFontSize]];
    [self.nextButton setTitleColor:cellSelecteColor forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(pressNextBtn) forControlEvents:UIControlEventTouchUpInside];

    [_contentView addSubview:self.nextButton];
    
}


-(void)pressLastBtn{
    [_dcPlayView pause];
    for (DoCoProjectPart *part in _project.partArray){
        [FileTool removeFile:part.okVideoUrl];
        part.okVideoUrl = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishBtnClick
{
    [UIView animateWithDuration:0.5f animations:^{
        _audioChoiceView.frame = CGRectMake(0, DEVICE_SIZE.height, DEVICE_SIZE.width, DEVICE_SIZE.height - CGRectGetMaxY(_dcPlayView.frame));
    } completion:^(BOOL finished) {
        
    }];
}


-(void)pressPreviewBtn
{
    if (!currentPart.okVideoUrl) {
        if (!self.hud) {
            self.hud = [[MBProgressHUD alloc] initWithView:_contentView];
            _hud.labelText = @"努力处理中";
        }
        [_hud show:YES];
        [_contentView addSubview:_hud];
        
        NSInteger i = _currentIndex;
        if (i==0) {
            NSString *outputPath = [NSString stringWithFormat:@"%@/%lu.mp4",_project.folderPath,i+1];
            UIImage *headImage = currentPart.image;
            NSURL *headURL = [[NSBundle mainBundle]URLForResource:@"heng" withExtension:@"mov"];
            [DoCoExporterManager videoApplyAnimationAtFileURL:headURL orientation:AVCaptureVideoOrientationLandscapeRight  duration:currentPart.maxTime outputFilePath:outputPath
                Animation:^(AVMutableVideoComposition *videoCom,CGSize size){
                    [self animation:videoCom Size:size headImage:headImage footImage:nil seg:_segments[@"segment1"] subs:currentPart.subtitles];
                } Completion:^(NSURL *outputURL){
        
                    [_hud hide:YES];
                    [_hud removeFromSuperview];
                    _hud = nil;
                    currentPart.okVideoUrl = outputURL;
                    //保证每次点击都重新创建视频播放控制器视图，避免再次点击时由于不播放的问题
                    _moviePlayerViewController = nil;
                    
                    [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
                }];
            
        }
        else if (i==_project.partArray.count-1){
            UIImage *footImage = currentPart.image;
            NSString *outputPath = [NSString stringWithFormat:@"%@/%lu.mp4",_project.folderPath,i+1];
            NSURL *footURL = [[NSBundle mainBundle]URLForResource:@"heng" withExtension:@"mov"];
            [DoCoExporterManager videoApplyAnimationAtFileURL:footURL orientation:AVCaptureVideoOrientationLandscapeRight  duration:currentPart.maxTime outputFilePath:outputPath
            Animation:^(AVMutableVideoComposition *videoCom,CGSize size){
                [self animation:videoCom Size:size headImage:nil footImage:footImage seg:_segments[[NSString stringWithFormat:@"segment%lu",i+1]] subs:currentPart.subtitles];
            } Completion:^(NSURL *outputURL){
                [_hud hide:YES];
                [_hud removeFromSuperview];
                _hud = nil;
                currentPart.okVideoUrl = outputURL;
                //保证每次点击都重新创建视频播放控制器视图，避免再次点击时由于不播放的问题
                _moviePlayerViewController = nil;
                
                [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
            }];
        }
        else{
            NSURL *videoUrl1 = [NSURL fileURLWithPath:currentPart.videoPath];
            
            [DoCoExporterManager trimVideo:videoUrl1 startTime:0 endTime:currentPart.maxTime toFilePath:[FileTool getVideoSavePathString] Completion:^(NSURL *outputURL) {
                
                NSString *outputPath = [NSString stringWithFormat:@"%@/%lu.mp4",_project.folderPath,i+1];
                [DoCoExporterManager videoApplyAnimationAtFileURL:outputURL orientation:AVCaptureVideoOrientationLandscapeRight  duration:0 outputFilePath:outputPath
                Animation:^(AVMutableVideoComposition *videoCom,CGSize size){
                                                            
                    [self animation:videoCom Size:size headImage:nil footImage:nil seg:_segments[[NSString stringWithFormat:@"segment%lu",i+1]] subs:currentPart.subtitles];
                }
                 Completion:^(NSURL *outputURL){
                    [_hud hide:YES];
                    [_hud removeFromSuperview];
                    _hud = nil;
                    currentPart.okVideoUrl = outputURL;
                    //保证每次点击都重新创建视频播放控制器视图，避免再次点击时由于不播放的问题
                    _moviePlayerViewController = nil;
                    
                    [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
                
            }];

            }];
        }
    }else{
        //保证每次点击都重新创建视频播放控制器视图，避免再次点击时由于不播放的问题
        _moviePlayerViewController = nil;
        
        [self presentMoviePlayerViewControllerAnimated:self.moviePlayerViewController];
    }

}
-(void)pressNextBtn{
    [_dcPlayView pause];
    VideoFinishController *controller = [[VideoFinishController alloc]init];
    controller.project = _project;
    controller.segments = _segments;
    controller.cuttos = _cuttos;
    controller.overalls = _overalls;
    controller.cuttolayers = _cuttolayers;
    [self.navigationController pushViewController:controller animated:YES];
    
}


-(void)animation:(AVMutableVideoComposition *)videoCom Size:(CGSize)size headImage:(UIImage *)headImage footImage:(UIImage *)footImage seg:(NSDictionary *)segment subs:(NSMutableArray *)subs{
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
    [tool segmentAnimationAnalysisWithDic:segment subtitles:subs parentLayer:parentLayer headImage:headImage footImage:footImage];
    
    //加水印
    UIImage *waterImage = [UIImage imageNamed:@"watermark_doco"];
    CALayer *waterLayer = [CALayer layer];
    waterLayer.frame = CGRectMake(0, 0, 105, 104);
    [waterLayer setContents:(id)waterImage.CGImage];
    waterLayer.position = CGPointMake(960-105, 100);
    [parentLayer addSublayer:waterLayer];
    
    videoCom.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

-(float)getTimeFromFrame:(NSDictionary *)dic{
    float second = [(NSNumber *) dic[@"second"] floatValue];
    float frame = [(NSNumber *)dic[@"frame"] floatValue];
    float startTime = second*1000+frame*40;
    return startTime;
}

#pragma mark - UIResponder

- (void)didTap
{
    switch (_dcPlayView.playbackState)
    {
        case DCPlayerPlaybackStatePaused:
        {
            [_dcPlayView play];
            [self buttonHidden];
        }
            
            break;
        case DCPlayerPlaybackStatePlaying:
        {
            [_dcPlayView pause];
            [self buttonShow];
        }
            break;
        case DCPlayerPlaybackStateStopped:
        {
            [_dcPlayView repeatPlaying];
            [self buttonHidden];
        }
            break;
        case DCPlayerPlaybackStateFailed:
        {
            [_dcPlayView pause];
            [self buttonShow];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark-trimViewdelegate
- (void)trimmerView:(DoCoVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    [FileTool removeFile:currentPart.okVideoUrl];
    currentPart.okVideoUrl = nil;
}

//左
-(void)trimmerView:(DoCoVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime{
    _leftTimeLabel.text = [NSString stringWithFormat:@"%.2f",startTime ];
    currentPart.startTime = startTime;
    
    CMTime cmtime =CMTimeMake(startTime*timeScale, timeScale);

    [_dcPlayView speed:cmtime];
}

//右
-(void)trimmerView:(DoCoVideoTrimmerView *)trimmerView didChangeRightPosition:(CGFloat)endTime{
    _leftTimeLabel.text = [NSString stringWithFormat:@"%.2f",endTime ];
    currentPart.endTime = endTime;
    
    CMTime cmtime =CMTimeMake(endTime*timeScale, timeScale);
    
    [_dcPlayView speed:cmtime];
}


#pragma mark-DCPlayView Delegate
-(void)canStartPlaying:(DCPlayView *)dcPlayView {
    _contentView.userInteractionEnabled = YES;
}


- (void)dontPlayer:(DCPlayView *)dcPlayView{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"温馨提示：" message:@"亲！视频无法正常播放！@" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}
- (void)bufferTimeLengh:(CGFloat)time{
    
}
- (void)currentPlayerTimeLengh:(CGFloat)time{
    
}
- (void)playEnd:(DCPlayView *)dcPlayView{
    [self buttonShow];
}

#pragma mark-DoCoExporterWriter delegate实现
-(void)readingAndWritingDidFinishSuccessfullyWithOutputURL:(NSURL *)outputURL{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[DoCoExporterManager exportDidFinish:outputURL];
    });
}

#pragma mark- DoCocollectiondelegate 实现
-(void)itemDidSelectedWithIndex:(NSUInteger)index forKey:(NSString *)privateKey collection:(UICollectionView *)collection
{
    
    UICollectionViewCell *cell = [collection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];

    if ([privateKey isEqualToString:@"pop"]) {
        
        [UIView animateWithDuration:0.5f animations:^{
            cell.backgroundColor = [UIColor grayColor];
        }completion:^(BOOL finished){
            cell.backgroundColor = [UIColor clearColor];
        }];
        [_popView dismiss];
        switch (index) {
            case 0://重拍
                if (currentPart.image) {//替换照片
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
                                message:@"确定要替换图片吗？"
                               delegate:self
                      cancelButtonTitle:@"保留"
                      otherButtonTitles:@"替换", nil];
                        [alert show];
                    });
                }else{//替换视频
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip"
                                message:@"确定要替换视频吗？"
                               delegate:self
                      cancelButtonTitle:@"保留"
                      otherButtonTitles:@"替换", nil];
                        [alert show];
                    });
                }
                break;
            default:
                break;
        }
        
        
    }else if([privateKey isEqualToString:@"title"]){

        if (_currentIndex == index) {
            float x=CGRectGetMinX(cell.frame)+CGRectGetMinX(_titleCollection.frame)-_titleCollection.collectionView.contentOffset.x;
            float y;
            y = CGRectGetMinY(_titleCollection.frame);
            UIView *popView = [[UIView alloc]initWithFrame:CGRectMake(x, y, cell.frame.size.width, cell.frame.size.height)];
            [_popView showAtView:popView withContentView:popCollection];
            return;
        }
        [(UIView *)_labels[1] setBackgroundColor:cellDeSelecteColor];
        [(UIView *)_circles[1] setHidden:YES];
        [(UIView *)_labels[index] setBackgroundColor:cellSelecteColor];
        [(UIView *)_circles[index] setHidden:NO];
        //切换模板
        DoCoProjectPart *part = _project.partArray[index];
        [_dcPlayView pause];
        
        if (index==0||index==_project.partArray.count-1) {//图片
            [_dcPlayView pause];
            [_timeView setHidden:YES];
            [_dcPlayView setUserInteractionEnabled:NO];
            [_imageLayer setContents:(id)part.image.CGImage];
            _imageLayer.opacity = 1.0f;
            docoTrimView.alpha = 0.5f;
            [docoTrimView setUserInteractionEnabled:NO];
            
        }else{
            //player
            [_timeView setHidden:NO];
            [_dcPlayView setUserInteractionEnabled:YES];
            _imageLayer.opacity = 0.0f;
            NSURL *fileURL =[NSURL fileURLWithPath:part.videoPath];
            _currentAsset = [AVAsset assetWithURL:fileURL];
            timeScale = _currentAsset.duration.timescale;
            NSString *filepath = part.videoPath;
            [_dcPlayView rmObserver];
            [_dcPlayView setContentUrl:filepath];
            CMTime cmtime =CMTimeMake(part.startTime*timeScale, timeScale);
            [_dcPlayView speed:cmtime];
            
            //videotrimer
            docoTrimView.minLength = part.minTime;
            docoTrimView.maxLength = CMTimeGetSeconds(_currentAsset.duration);
            [docoTrimView resetSubviews];
            _leftTimeLabel.text = [NSString stringWithFormat:@"%.2f",part.startTime];
            _rightTimeLabel.text = [NSString stringWithFormat:@"%.2f",part.endTime];
            [docoTrimView setStartTime:part.startTime];
            [docoTrimView setUserInteractionEnabled:YES];
        }
        currentPart = part;
        _currentIndex = index;
        
        //更改字幕界面
        [_textView removeFromSuperview];
        [self initMidText];
    }
    
}

-(void)itemDidDeselectedWithIndex:(NSUInteger)index forKey:(NSString *)privateKey collection:(UICollectionView *)collection{
    [(UIView *)_labels[index] setBackgroundColor:cellDeSelecteColor];
    [(UIView *)_circles[index] setHidden:YES];
}

#pragma mark - Private function  (buttonHiddenAndShow)
- (void)buttonHidden
{
    _playButton.alpha = 1.0f;
    _playButton.hidden = NO;
    [UIView animateWithDuration:0.1f animations:^{
        _playButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _playButton.hidden = YES;
    }];
    
}

- (void)buttonShow
{
    
    _playButton.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        _playButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark textfielDelegate
-(BOOL)textFieldShouldReturn: (UITextField *)TextField{
    
    [TextField resignFirstResponder];

    return YES;
}

#pragma mark-mediaplayer的代理和通知

-(NSURL *)getFileUrl{
//    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"rain.mp4" ofType:nil];
//    NSURL *url=[NSURL fileURLWithPath:urlStr];
    DoCoProjectPart *part = _project.partArray[1];
    NSString *urlStr=part.videoPath;
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}


-(MPMoviePlayerViewController *)moviePlayerViewController{
    if (!_moviePlayerViewController) {
        _moviePlayerViewController=[[MPMoviePlayerViewController alloc]initWithContentURL:currentPart.okVideoUrl];
        
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

@end