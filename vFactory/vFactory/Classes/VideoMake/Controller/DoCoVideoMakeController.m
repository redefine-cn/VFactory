//
//  DoCoVideoMakeController.m
//  doco_ios_app
//
//  Created by developer on 15/4/25.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoVideoMakeController.h"
#import "DoCoPlayAndEditController.h"
#import "DCPlayView.h"
#import "ViewToolkit.h"
#import "CommonTool.h"

#import "DoCoSelectView.h"
#import <MessageUI/MFMailComposeViewController.h>

//播放器
#define playerLeftMargin 0.0
#define playerTopSpace 19.0

//按钮
#define btnWidth 120 
#define btnHeight 17
#define btnMargin 5

//collection

#define leftArrowW 8
#define leftArrowH 14

#define previewItemH 53
#define previewItemW 65
#define previewImageH 36.5
#define previewLabelH 8
#define HPreviewSpace 3
#define previewTopSpace 8

#define cutoffArrowH 7
#define cutoffArrowW 270
#define cutoffArrowToPreViewTopSpace 10

#define selectItemH 48.5
#define selectItemW 86
#define HSelectSpace 6
#define HarrowSpace 13
#define selectTopSpace 14.5

#define cutoffArrowToSelectTopSpace 10

#define typeItemH 100
#define typeItemW 78
#define HTypeSpace 18.5
#define typeTopSpace 31.5

#define topBorderMargin 20
#define leftBorderMargin 25
#define VSpace 22.5

#define fontSize 20


@interface DoCoVideoMakeController ()<MFMailComposeViewControllerDelegate>
{
    UIProgressView *progress;
//    UIImageView *_overlayViewP;
//    UIImageView *_overlayViewS;
//    UIImageView *_overlayViewT;
}

@property(nonatomic,strong)NSMutableArray *previewData;
@property(nonatomic,strong)NSMutableArray *selectData;
@property(nonatomic,strong)NSMutableArray *typeData;
@property(nonatomic,strong)NSDictionary *allTypes;
@property(nonatomic,strong)NSDictionary *allModels;

@property(nonatomic,assign)BOOL isInit;

@property(nonatomic,assign)NSInteger currentTypeIndex;
@property(nonatomic,assign)NSInteger currentSelectIndex;
@property(nonatomic,assign)NSInteger currentPreviewIndex;

@end

@interface DoCoVideoMakeController(collectionDelegate)<DoCoCollectionViewDelegate>
@end

@interface DoCoVideoMakeController(play)<DCPlayViewDelegate>

@end

@implementation DoCoVideoMakeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isInit = NO;
    
    [self initScriptData];
    [self initFolder];
//    [self initProject];

}



//去除状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isInit) {
        return;
    }
    [self buildUI];
    _isInit = YES;
}

-(void)initFolder{
    NSString *folderName = [NSString stringWithFormat:@"project%@",[CommonTool getTimestamp]];
    NSString *projectsPath = [FileTool getSaveFolderPathStringWithFolderName:@"projects"];
    if([CommonTool createFolderIfNotExistForFolderPath:projectsPath]){
        MyLog(@"大文件夹创建成功");
    }
    //获取带有随机字符串的文件夹路径
    NSString *projectPath = [projectsPath stringByAppendingPathComponent:folderName];
    _project.folderPath = projectPath;
    _project.isNew = YES;
    _project.num = -1;
    _project.createTime = [CommonTool nowDate];
    
    if([CommonTool createFolderIfNotExistForFolderPath:projectPath]){
        MyLog(@"小文件夹创建成功");
    }
    
    if([CommonTool createFolderIfNotExistForFolderPath:[FileTool getSaveFolderPathStringWithFolderName:VIDEO_FOLDER]]){
        MyLog(@"videos文件夹创建成功");
    }
    
    if([CommonTool createFolderIfNotExistForFolderPath:[FileTool getSaveFolderPathStringWithFolderName:@"data"]]){
        MyLog(@"data文件夹创建成功");
    }

}

-(void)initScriptData{
#pragma mark-删除视频数据
        NSString *Folder = [FileTool getSaveFolderPathStringWithFolderName:@"data"];
        NSURL *url = [NSURL fileURLWithPath:Folder];
        [FileTool removeFile:url];
        Folder = [FileTool getSaveFolderPathStringWithFolderName:@"projects"];
        url = [NSURL fileURLWithPath:Folder];
        [FileTool removeFile:url];
    
        Folder = [FileTool getSaveFolderPathStringWithFolderName:@"videos"];
        url = [NSURL fileURLWithPath:Folder];
        [FileTool removeFile:url];
    
    NSString *scriptDataPath = [[NSBundle mainBundle]pathForResource:@"allModels" ofType:@"plist" ];
    _allTypes = [NSDictionary dictionaryWithContentsOfFile:scriptDataPath];
    _allModels = [NSDictionary dictionaryWithDictionary:_allTypes[@"type1"]];
    _project = [[DoCoProject alloc]init];
    [self setProjectWithModel:_allModels[@"model1"]];
}

-(void)setProjectWithModel:(NSDictionary *)model {
    //这是allmodels里的model
    _project.scriptName = model[@"name"];
    //这里获取了截取帧的位置
    _project.frameTime = [self getTimeFromFrame:model[@"frameTime"]]/1000;
    //这里定义了视频方向
    _project.isPortrait = NO;
    //加载model的描述文件
    NSString *desModelPath = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@model",_project.scriptName] ofType:@"plist" ];
    NSDictionary *desModel = [NSDictionary dictionaryWithContentsOfFile:desModelPath];
    NSMutableArray *partArray = [[NSMutableArray alloc]init];
    for (int i=0; i<desModel.count-1; i++) {
        NSString *partkey = [NSString stringWithFormat:@"part%d",i+1];
        NSDictionary *partDic = desModel[partkey];
        DoCoProjectPart *part = [self getProjectPartWithPart:partDic];
        if (i==0||i==desModel.count-2) {
            part.image = [UIImage imageNamed:@"moter.png"];
        }else{
            part.videoPath = [[NSBundle mainBundle]pathForResource:@"example" ofType:@"mov"];
        }
        [partArray addObject:part];
    }
    _project.partArray = partArray;
}

-(float)getTimeFromFrame:(NSDictionary *)dic{
    float second = [(NSNumber *) dic[@"second"] floatValue];
    float frame = [(NSNumber *)dic[@"frame"] floatValue];
    float startTime = second*1000+frame*40;
    return startTime;
}

-(DoCoProjectPart *)getProjectPartWithPart:(NSDictionary *)partDic
{
    DoCoProjectPart *part = [[DoCoProjectPart alloc]init];
    part.partName = partDic[@"partName"];
    part.minTime = [self getTimeFromFrame:partDic[@"minTime"]]/1000;
    part.maxTime = [self getTimeFromFrame:partDic[@"maxTime"]]/1000;
    if (partDic[@"previewImage"] && ![@"" isEqualToString:partDic[@"previewImage"]]) {
        part.previewImage = [UIImage imageNamed:partDic[@"previewImage"]];
    }else{
        part.previewImage = [UIImage imageNamed:@"旅游1.png"];
    }
    if (partDic[@"previewVideo"] && ![@"" isEqualToString:partDic[@"previewVideo"]]) {
        part.previewVideo = [[NSBundle mainBundle]pathForResource:partDic[@"previewVideo"] ofType:nil];
    }else{
        part.previewVideo = [[NSBundle mainBundle]pathForResource:@"旅游1" ofType:@"mov"];
    }
    
    //解析字幕条目
    NSArray *subtitles = partDic[@"subtitles"];
    for (int i=0; i<subtitles.count;i++) {
        NSDictionary *subtitle = subtitles[i];
        DoCoSubtitle *st = [[DoCoSubtitle alloc]init];
        st.textName = subtitle[@"textName"];
        st.isShow = subtitle[@"isShow"];
        st.maxNum = [(NSNumber *)subtitle[@"maxNum"] floatValue];
        [part.subtitles addObject:st];
    }
    return part;
}

-(void)buildUI{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initialBackBtn];
    [self initialCaptureButton];
    [self initialPlayer];
    [self initialCollectionPreview];
    [self initialCollectionSelectView];
    [self initialCollectionTypeView];
    
}

- (void)initialBackBtn
{
    customButton *backButton = [[customButton alloc] initWithFrame:CGRectMake(btnMargin, topBorderMargin*autoScaleY, btnWidth*autoScaleX, btnHeight*autoScaleY) withIsImageLeft:YES];
    [backButton setImage:[UIImage imageNamed:@"template_wrong"] forState:UIControlStateNormal];

    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:color(55,165,175, 1) forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont fontWithName:commonFont size:fontSize]];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}
//监听返回按钮的点击
- (void)backButtonClick
{
//    MyLog(@"back");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //[_docoCollectionTypeView scrollToItemAtIndexPath:3 animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
}

-(void)initialCaptureButton{
    //image1用于矫正按钮的位置对称
    UIImage *image1 = [UIImage imageNamed:@"template_wrong"];
    UIImage *image = [UIImage imageNamed:@"right_arrow"];
    _captureButton = [[customButton alloc]initWithFrame:CGRectMake(DEVICE_SIZE.width-btnMargin-btnWidth*autoScaleX+image1.size.width*1/2, topBorderMargin*autoScaleY, btnWidth*autoScaleX, btnHeight*autoScaleY) withIsImageLeft:NO];
    [_captureButton setTitle:@"下一步" forState:UIControlStateNormal];
    [_captureButton.titleLabel setFont:[UIFont fontWithName:commonFont size:fontSize]];
    [_captureButton setImage:image forState:UIControlStateNormal];
    [_captureButton setTitleColor:color(55,165,175, 1) forState:UIControlStateNormal];
    [_captureButton addTarget:self action:@selector(toCapture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureButton];
}

-(void)toCapture{
    [_dcPlayView pause];
    DoCoPlayAndEditController *controller1 = [[DoCoPlayAndEditController alloc]init];
    
    controller1.project = _project;
    
    [self.navigationController pushViewController:controller1 animated:NO];

}


-(void)showProgressInView:(UIView *)view{
    progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame)-20, CGRectGetHeight(view.frame))];
    progress.transform = CGAffineTransformMakeScale(1.0f,4.0f);
    [progress.layer setCornerRadius:3];
    [progress.layer setMasksToBounds:YES];
    progress.trackTintColor = [UIColor whiteColor];
    progress.center = view.center;
    progress.progressViewStyle = UIProgressViewStyleDefault;
    [view addSubview:progress];
    
}

-(void)initialPlayer{
    DoCoProjectPart *part = _project.partArray[0];
    [_dcPlayView setBackgroundColor:[UIColor grayColor]];
    float x = playerLeftMargin;
    float y = CGRectGetMaxY(_captureButton.frame)+VSpace*autoScaleY;
    float width = DEVICE_SIZE.width-2*playerLeftMargin;
    float height = width*9/16;
    if (part.previewVideo && ![@"" isEqualToString:part.previewVideo]) {
        _dcPlayView =[[DCPlayView alloc]initWithFrame:CGRectMake(x,y,width,height) contentUrl:part.previewVideo];
    }else{
        _dcPlayView =[[DCPlayView alloc]initWithFrame:CGRectMake(x,y,width,height) contentUrl:[[NSBundle mainBundle]pathForResource:@"旅游1" ofType:@"mov"]];
    }
    
    _dcPlayView.delegate=self;

    self.view.userInteractionEnabled=NO;
    
    [self.view addSubview:_dcPlayView];
    
}


-(void)initialCollectionPreview{
    NSInteger itemCount =_project.partArray.count;
    float width = previewItemW*autoScaleX*4+HPreviewSpace*3*autoScaleX;
    float height = previewItemH*autoScaleY;
    float x = (DEVICE_SIZE.width-width)/2;//居中
    float y = CGRectGetMaxY(_dcPlayView.frame)+VSpace * autoScaleY;
    const CGRect collectionViewFrame = CGRectMake(x,y,width,height);

    CGSize itemSize = CGSizeMake(previewItemW*autoScaleX, previewItemH*autoScaleY);
    NSMutableArray *itemViews = [[NSMutableArray alloc]init];
    for (int i = 0; i < itemCount; i ++) {
        DoCoProjectPart * part = _project.partArray[i];
        UIView *content = [[UIView alloc]initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
        content.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(content.frame)-previewLabelH*autoScaleY, itemSize.width, previewLabelH*autoScaleY)];
//        if (i==0) {
//            [label setText:@"片头"];
//        }else if (i==itemCount-1){
//            [label setText:@"片尾"];
//        }else{
//            [label setText:[NSString stringWithFormat:@"片段%d",i]];
//        }
        [label setText:part.partName];
        [label setFont:[UIFont fontWithName:commonFont size:previewLabelH]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:color(180, 179, 179, 1.0)];
        content.alpha = 0.5;
        if (i==0) {
            content.alpha = 1;
        }
        [content addSubview:label];
        
        UIImage *image = part.previewImage;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, itemSize.width, previewImageH*autoScaleY);
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [content addSubview:imageView];
        [itemViews addObject:content];
        
    }
    _previewData = itemViews;
    _docoCollectionPreview = [[DoCoCollectionView alloc]initWithFrame:collectionViewFrame dataSource:_previewData itemSize:itemSize itemColumnSpace:HPreviewSpace*autoScaleX itemRowSpace:0 privateKey:@"Preview"];
    _docoCollectionPreview.docoDelegate = self;
    //默认选择第一个
    
    [self.view addSubview:_docoCollectionPreview];
    
    //左右箭头
    float leftArrowX = CGRectGetMinX(_docoCollectionPreview.frame)-leftArrowW*autoScaleX-3;
    float arrowY = CGRectGetMidY(_docoCollectionPreview.frame)-leftArrowH*0.5;
    UIImageView *leftArrow = [[UIImageView alloc]initWithFrame:CGRectMake(leftArrowX, arrowY, leftArrowW, leftArrowH)];
    leftArrow.image = [UIImage imageNamed:@"arrow_point_left"];
    //[self.view addSubview:leftArrow];
    
    float rightArrowX = CGRectGetMaxX(_docoCollectionPreview.frame)+3;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(rightArrowX, arrowY, leftArrowW, leftArrowH)];
    rightArrow.image = [UIImage imageNamed:@"arrow_point_right"];
    //[self.view addSubview:rightArrow];
    
    //下方向上的箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_docoCollectionPreview.frame), CGRectGetMaxY(_docoCollectionPreview.frame)+cutoffArrowToPreViewTopSpace*autoScaleY, cutoffArrowW*autoScaleX, cutoffArrowH*autoScaleY)];
    arrow.image = [UIImage imageNamed:@"template_line"];
    arrow.alpha = 0.3;
    [self.view addSubview:arrow];
    
    //选择框
//    _overlayViewP = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, previewItemW*autoScaleX, previewItemH*autoScaleY)];
//    [_overlayViewP setBackgroundColor:[UIColor clearColor]];
//    [_overlayViewP.layer setBorderColor:[UIColor greenColor].CGColor];
//    [_overlayViewP.layer setBorderWidth:2];
//    [self.view addSubview:_overlayViewP];
}

-(void)initialCollectionSelectView{
    
    NSInteger itemCount =_allModels.count -2;
    float width = selectItemW*autoScaleX*3+HSelectSpace*2*autoScaleX;
    float height = selectItemH*autoScaleY;
    float x = (DEVICE_SIZE.width-width)/2;//居中
    float y = CGRectGetMaxY(_docoCollectionPreview.frame)+VSpace * autoScaleY+HarrowSpace*autoScaleY;
    
    const CGRect collectionViewFrame = CGRectMake(x,y,width,height);
    CGSize itemSize = CGSizeMake(selectItemW*autoScaleX, selectItemH*autoScaleY);
    NSMutableArray *itemViews = [[NSMutableArray alloc]init];
    for (int i = 0; i < itemCount; i ++)
    {
        NSString *modelkey = [NSString stringWithFormat:@"model%d",i+1];
        if (!_allModels[modelkey]) {
            break;
        }
        NSDictionary *model  = _allModels[modelkey];
        UIImage *selectImage=[UIImage imageNamed:@"black_four"];
        UIImage * image = [UIImage imageNamed:model[@"imageName"]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, itemSize.width, itemSize.height);
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        DoCoSelectView *selectView = [[DoCoSelectView alloc]initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height) withSelectImage:selectImage imageView:imageView];
        if (i==0) {
            selectView.selected = YES;
        }
        [itemViews addObject:selectView];
        
    }
    _selectData = itemViews;
    _docoCollectionSelectView = [[DoCoCollectionView alloc]initWithFrame:collectionViewFrame dataSource:_selectData itemSize:itemSize itemColumnSpace:HSelectSpace*autoScaleX itemRowSpace:0 privateKey:@"Select"];
    _docoCollectionSelectView.docoDelegate = self;
    [self.view addSubview:_docoCollectionSelectView];
    
    //左右箭头
    float leftArrowX = CGRectGetMinX(_docoCollectionSelectView.frame)-leftArrowW*autoScaleX-12;
    float arrowY = CGRectGetMidY(_docoCollectionSelectView.frame)-leftArrowH*0.5;
    UIImageView *leftArrow = [[UIImageView alloc]initWithFrame:CGRectMake(leftArrowX, arrowY, leftArrowW, leftArrowH)];
    leftArrow.image = [UIImage imageNamed:@"arrow_point_left"];
    [self.view addSubview:leftArrow];
    
    float rightArrowX = CGRectGetMaxX(_docoCollectionSelectView.frame)+12;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(rightArrowX, arrowY, leftArrowW, leftArrowH)];
    rightArrow.image = [UIImage imageNamed:@"arrow_point_right"];
    [self.view addSubview:rightArrow];
    
    //下方向上的箭头
    UIImageView *arrow = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_docoCollectionPreview.frame), CGRectGetMaxY(_docoCollectionSelectView.frame)+cutoffArrowToPreViewTopSpace*autoScaleY, cutoffArrowW*autoScaleX, cutoffArrowH*autoScaleY)];
    arrow.image = [UIImage imageNamed:@"template_line"];
    arrow.alpha = 0.3;
    [self.view addSubview:arrow];

}

-(void)initialCollectionTypeView{
    NSInteger itemCount =_allTypes.count;
    float width = typeItemW*3*autoScaleX+HTypeSpace*(2)*autoScaleX;
    float height = typeItemH*autoScaleY;
    float x = (DEVICE_SIZE.width-width)/2;//居中
    float y = CGRectGetMaxY(_docoCollectionSelectView.frame)+VSpace * autoScaleY+HarrowSpace*autoScaleY;
    
    const CGRect collectionViewFrame = CGRectMake(x,y,width,height);
    CGSize itemSize = CGSizeMake(typeItemW*autoScaleX, typeItemH*autoScaleY);
    NSMutableArray *itemViews = [[NSMutableArray alloc]init];
    for (int i = 0; i < itemCount; i ++) {
        NSString *typekey = [NSString stringWithFormat:@"type%d",i+1];
        NSDictionary *type = _allTypes[typekey];
        
        UIImage *image = [UIImage imageNamed:type[@"imageName"]];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height-11)];
        imageView.image = image;
        
        UIImage *selectImage = [UIImage imageNamed:type[@"selectedImage"]];
        
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        DoCoSelectView *selecteView = [[DoCoSelectView alloc]initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height) withSelectImage:selectImage imageView:imageView];
        if (i==0) {
            [selecteView setSelected:YES];
        }
        [itemViews addObject:selecteView];
        
    }
    _typeData = itemViews;
    _docoCollectionTypeView = [[DoCoCollectionView alloc]initWithFrame:collectionViewFrame dataSource:_typeData itemSize:itemSize itemColumnSpace:HTypeSpace*autoScaleX itemRowSpace:0 privateKey:@"Type"];
    _docoCollectionTypeView.docoDelegate = self;
    
    [self.view addSubview:_docoCollectionTypeView];
    
    //左右箭头
    float leftArrowX = CGRectGetMinX(_docoCollectionTypeView.frame)-leftArrowW*autoScaleX-12;
    float arrowY = CGRectGetMidY(_docoCollectionTypeView.frame)-leftArrowH*0.5;
    UIImageView *leftArrow = [[UIImageView alloc]initWithFrame:CGRectMake(leftArrowX, arrowY, leftArrowW, leftArrowH)];
    leftArrow.image = [UIImage imageNamed:@"arrow_point_left"];
    [self.view addSubview:leftArrow];
    
    float rightArrowX = CGRectGetMaxX(_docoCollectionTypeView.frame)+12;
    UIImageView *rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(rightArrowX, arrowY, leftArrowW, leftArrowH)];
    rightArrow.image = [UIImage imageNamed:@"arrow_point_right"];
    [self.view addSubview:rightArrow];
    
//    _overlayViewT = [[UIImageView alloc]initWithFrame:CGRectMake(x-2, y-2, typeItemW*autoScaleX+4, typeItemH*autoScaleY+4)];
//    [_overlayViewT setBackgroundColor:[UIColor clearColor]];
//    [_overlayViewT.layer setBorderColor:[UIColor greenColor].CGColor];
//    [_overlayViewT.layer setBorderWidth:2];
//    [self.view addSubview:_overlayViewT];
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

@implementation DoCoVideoMakeController(collectionDelegate)

-(void)itemDidSelectedWithIndex:(NSUInteger)index forKey:(NSString *)privateKey collection:(UICollectionView *)collection{
//    UICollectionViewCell *cell = [collection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    if ([privateKey isEqualToString:@"Preview"]) {
        ((UIView *)_previewData[0]).alpha = 0.5f;
        ((UIView *)_previewData[index]).alpha = 1.0f;
        DoCoProjectPart *part = _project.partArray[index];
        [_dcPlayView rmObserver];
        [_dcPlayView setContentUrl:part.previewVideo];
        _currentPreviewIndex = index;
        
    }else if([@"Select" isEqualToString:privateKey]){
        
        ((DoCoSelectView *)_selectData[0]).selected = NO;
        ((DoCoSelectView *)_selectData[index]).selected = YES;
        
        //更换model数据
        NSString *modelKey = [NSString stringWithFormat:@"model%lu",(unsigned long)index+1];
        [self setProjectWithModel:_allModels[modelKey]];
        [_docoCollectionPreview removeFromSuperview];
        [self initialCollectionPreview];
        DoCoProjectPart *part = _project.partArray[0];
        if (part.previewVideo) {
            [_dcPlayView rmObserver];
            [_dcPlayView setContentUrl:part.previewVideo];
        }
        
    }else{
        ((DoCoSelectView *)_typeData[0]).selected = NO;
        ((DoCoSelectView *)_typeData[index]).selected = YES;
    }
}

-(void)itemDidDeselectedWithIndex:(NSUInteger)index forKey:(NSString *)privateKey collection:(UICollectionView *)collection{
    if ([privateKey isEqualToString:@"Preview"]) {
        ((UIView *)_previewData[index]).alpha = 0.5;
    }else if([privateKey isEqualToString:@"Select"]){
        ((DoCoSelectView *)_selectData[index]).selected = NO;
    }else{
        ((DoCoSelectView *)_typeData[index]).selected = NO;
    }
}

@end

@implementation DoCoVideoMakeController(play)
#pragma mark-DCPlayView Delegate

-(void)didTap{
    switch (_dcPlayView.playbackState)
    {
        case DCPlayerPlaybackStatePaused:
        {
            [_dcPlayView play];
        }
            
            break;
        case DCPlayerPlaybackStatePlaying:
        {
            [_dcPlayView pause];
        }
            break;
        case DCPlayerPlaybackStateStopped:
        {
            [_dcPlayView repeatPlaying];
        }
            break;
        case DCPlayerPlaybackStateFailed:
        {
            [_dcPlayView pause];
        }
            break;
        default:
            break;
    }

}
-(void)canStartPlaying:(DCPlayView *)dcPlayView {
    self.view.userInteractionEnabled = YES;
    [_dcPlayView play];
}


- (void)dontPlayer:(DCPlayView *)dcPlayView{
//    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"温馨提示：" message:@"亲！视频无法正常播放！@" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView show];
}
- (void)bufferTimeLengh:(CGFloat)time{
    
}
- (void)currentPlayerTimeLengh:(CGFloat)time{
    
}
- (void)playEnd:(DCPlayView *)dcPlayView{
    [_dcPlayView repeatPlaying];
}

@end
