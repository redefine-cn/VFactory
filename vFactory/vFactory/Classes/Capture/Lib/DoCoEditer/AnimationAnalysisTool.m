//
//  AnimationAnalysisTool.m
//  doco_ios_app
//
//  Created by developer on 15/6/1.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "AnimationAnalysisTool.h"
#import "AnimationTool.h"

@implementation AnimationAnalysisTool

-(void)setupLayerWithDic:(NSDictionary *)layer toLayer:(CALayer *)anilayer startTime:(float)startTime type:(NSString *)type{
    
    //获取透明度
    float opacity = [(NSNumber *)layer[@"opacity"] floatValue]/100;
    [anilayer setOpacity:opacity];
    
    //获取锚点
    NSDictionary *anchorpoint = layer[@"anchorpoint"];
    float ax,ay;
    //获取坐标
    NSDictionary *position = layer[@"position"];
    float px = [(NSNumber *)position[@"x"] floatValue];
    float py = [(NSNumber *)position[@"y"] floatValue];
    if (!_isPortrait) {//横屏
        ax = [(NSNumber *)anchorpoint[@"x"] floatValue]/960;
        ay = 1-[(NSNumber *)anchorpoint[@"y"] floatValue]/540;
        py = 540-py;
        anilayer.frame = CGRectMake(px, py, 960, 540);
    }else{
        ax = [(NSNumber *)anchorpoint[@"x"] floatValue]/540;
        ay = 1-[(NSNumber *)anchorpoint[@"y"] floatValue]/960;
        py = 960-py;
        anilayer.frame = CGRectMake(px, py, 540, 960);
    }
    //layer的大小
    //获取大小
    NSDictionary *size = layer[@"size"];
    
    float width = [(NSNumber *)size[@"width"] floatValue];
    float height = [(NSNumber *)size[@"height"] floatValue];
    if ([@"subtitle" isEqualToString:type]) {
        anilayer.frame = CGRectMake(0, 0, width, height+5);
    }
    anilayer.anchorPoint = CGPointMake(ax, ay);
    anilayer.position = CGPointMake(px, py);
    
    //获取scale
    NSDictionary *scale = layer[@"scale"];
    float sx = [(NSNumber *)scale[@"x"] floatValue]/100;
    float sy = [(NSNumber *)scale[@"y"] floatValue]/100;
    [anilayer setTransform:CATransform3DMakeScale(sx, sy, 1)];
    
    //解析动画 
    AnimationTool *tool = [[AnimationTool alloc]init];
    tool.isPortrait = _isPortrait;
    NSMutableDictionary *animations = [NSMutableDictionary dictionaryWithDictionary:layer[@"animations"]];
    NSDictionary *animation1 = animations[@"animation1"];
    if ([@"still"isEqualToString: animation1[@"name"]]) {
        MyLog(@"动画名：%@",animation1[@"name"]);
        return;
    }
    
    CAAnimationGroup *groupAnimation;
    groupAnimation = [tool groupAnimation:animations WithSegStartTime:startTime ];
    [anilayer addAnimation:groupAnimation forKey:nil];
}

-(void)segmentAnimationAnalysisWithDic:(NSDictionary *)segment subtitles:(NSMutableArray *)subs parentLayer:(CALayer *)parentLayer headImage:(UIImage *)headImage footImage:(UIImage *)footImage{
    float startTime = [self getTimeFromFrame:segment[@"starttime"]];
    
    if(segment[@"head"]){
        NSDictionary  *head = segment[@"head"];
        CALayer *anilayer = [CALayer layer];
        [self setupLayerWithDic:head toLayer:anilayer startTime:startTime type:nil];
        //设置片头的图片  （固定的路径）
        anilayer.contents = (id)headImage.CGImage;
        //等比例放大
        anilayer.contentsGravity = kCAGravityResizeAspect;
        [parentLayer addSublayer:anilayer];
        
    }else if (segment[@"foot"]){
        NSDictionary  *foot = segment[@"foot"];
        CALayer *anilayer = [CALayer layer];
        [self setupLayerWithDic:foot toLayer:anilayer startTime:startTime type:nil];
        //设置片尾的图片  （固定的路径）
        anilayer.contents = (id)footImage.CGImage;
        anilayer.contentsGravity = kCAGravityResizeAspect;
        [parentLayer addSublayer:anilayer];
    }else if (segment[@"heads"]){
        NSDictionary *layers = segment[@"heads"];
        for (int k=0; k<layers.count; k++) {
            NSString *layerkey = [NSString stringWithFormat:@"layer%d",k+1];
            if(!layers[layerkey]){
                break;
            }
            NSDictionary *layer = layers[layerkey];
            //创建layer
            CALayer *animationlayer = [CALayer layer];
            [self setupLayerWithDic:layer toLayer:animationlayer startTime:startTime type:nil];
            //获取图片名称
            NSString *imageName = layer[@"imageName"];
            UIImage *aniImage = [UIImage imageNamed:imageName];
            if (!aniImage) {
                MyLog(@"图片%@的名称错误或图片不存在",imageName);
            }
            [animationlayer setContents:(id)aniImage.CGImage];
            [parentLayer addSublayer:animationlayer];
        }
    }else if (segment[@"foots"]){
        NSDictionary *layers = segment[@"foots"];
        for (int k=0; k<layers.count; k++) {
            NSString *layerkey = [NSString stringWithFormat:@"layer%d",k+1];
            if(!layers[layerkey]){
                break;
            }
            NSDictionary *layer = layers[layerkey];
            //创建layer
            CALayer *animationlayer = [CALayer layer];
            [self setupLayerWithDic:layer toLayer:animationlayer startTime:startTime type:nil];
            //获取图片名称
            NSString *imageName = layer[@"imageName"];
            UIImage *aniImage = [UIImage imageNamed:imageName];
            if (!aniImage) {
                MyLog(@"图片%@的名称错误或图片不存在",imageName);
            }
            [animationlayer setContents:(id)aniImage.CGImage];
            [parentLayer addSublayer:animationlayer];
        }

    }
    for (int j=0; j<segment.count; j++) {
        NSString *trackkey = [NSString stringWithFormat:@"track%d",j+1];

        if (!segment[trackkey]) {
            break;
        }
        NSDictionary *layers = segment[trackkey];
        MyLog(@"%@开始合成",trackkey);
        [self layersAnimationAnalysisWithDic:layers parentLayer:parentLayer startTime:startTime];
        MyLog(@"%@合成完毕",trackkey);
    }
    
    //解析字幕
    NSDictionary *subtitles = segment[@"subtitles"];
    for (int i=0; i<subtitles.count; i++) {
//        NSString *subtitlekey = [NSString stringWithFormat:@"sublayer%d",i+1];
        NSString *subtitlekey = [NSString stringWithFormat:@"subtitle%d",i+1];
        if (!subtitles[subtitlekey]) {
            break;
        }
//        NSDictionary *sublayerDic = subtitles[subtitlekey];
        NSDictionary *subtitle = subtitles[subtitlekey];
        //创建字幕的画布
        CALayer *subDrawlayer = [CALayer layer];
//        [self setupLayerWithDic:sublayerDic toLayer:subDrawlayer startTime:startTime type:nil];
        
        //解析字幕专有属性
        CATextLayer *sublayer = [CATextLayer layer];
        [self setupLayerWithDic:subtitle toLayer:sublayer startTime:startTime type:@"subtitle"];
        NSDictionary *position = subtitle[@"position"];
        float px = [(NSNumber *)position[@"x"] floatValue];
        float py = [(NSNumber *)position[@"y"] floatValue];
        
        NSDictionary *size = subtitle[@"size"];
        float width = [(NSNumber *)size[@"width"] floatValue];
        float height = [(NSNumber *)size[@"height"] floatValue];
        //sublayer.frame = CGRectMake(0, 0, width, height);
        //sublayer.position = CGPointMake(px, py);
        //[subDrawlayer addSublayer:sublayer];
        //字体
        //NSString *fontName = subtitle[@"fontName"];
        //字体大小
        float fontSize = [(NSNumber *)subtitle[@"fontSize"] floatValue];
        //字体颜色
        NSDictionary *rgba = subtitle[@"fontColor"];
        UIColor *fontColor = color([rgba[@"r"] floatValue], [rgba[@"g"] floatValue], [rgba[@"b"] floatValue], [rgba[@"a"] floatValue]);
        //内容
        NSString *text = subtitle[@"textName"];
        if (subs.count<=i) {
            MyLog(@"描述文件和脚本文件的字幕不匹配，本条字幕放弃！");
            continue;
        }
        DoCoSubtitle *sub = subs[i];
        if (sub.text) {
            text = sub.text;
        }
//        for (DoCoSubtitle *sub in subs) {
//            MyLog(@"%@===",sub.textName);
//            if ([text isEqualToString:sub.textName]) {
//                text = sub.text;
//                break;
//            }
//        }
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:text attributes:@{
            NSForegroundColorAttributeName :fontColor,
            NSKernAttributeName:@1,
            NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:fontSize],
            //下面这个属性值是设置描边的颜色
//            NSStrokeColorAttributeName:[UIColor redColor],
//            //下面这个属性值是设置描边的宽度（像素）  正数为镂空，向外描边，负数为向内描边
//            NSStrokeWidthAttributeName:[NSNumber numberWithFloat:-1.5f],
            NSVerticalGlyphFormAttributeName:@(0),
        }];
        //在这里设置字体
        
        [sublayer setString:attributeStr];
        [sublayer setAlignmentMode:kCAAlignmentCenter];
        [parentLayer addSublayer:sublayer];
        //[parentLayer addSublayer:subDrawlayer];
    }
}

-(void)layersAnimationAnalysisWithDic:(NSDictionary *)layers parentLayer:(CALayer *)parentLayer startTime:(float)startTime{
    for (int k=0; k<layers.count; k++) {
        NSString *layerkey = [NSString stringWithFormat:@"layer%d",k+1];
        if(!layers[layerkey]){
            break;
        }
        MyLog(@"%@开始合成",layerkey);
        NSDictionary *layer = layers[layerkey];
        //创建layer
        CALayer *animationlayer = [CALayer layer];
        [self setupLayerWithDic:layer toLayer:animationlayer startTime:startTime type:nil];
        //获取图片名称
        NSString *imageName = layer[@"imageName"];
        UIImage *aniImage = [UIImage imageNamed:imageName];
        if (!aniImage) {
            MyLog(@"图片%@的名称错误或图片不存在",imageName);
        }
        [animationlayer setContents:(id)aniImage.CGImage];
        [parentLayer addSublayer:animationlayer];
        MyLog(@"%@合成完毕",layerkey);
    }

}

-(void)overall_layerAnimationAnalysisWithDic:(NSDictionary *)layers parentLayer:(CALayer *)parentLayer{
    [self layersAnimationAnalysisWithDic:layers parentLayer:parentLayer startTime:0];
}


-(void)cuttoLayerAnimationAnalysisWithDic:(NSDictionary *)cuttolayers parentLayer:(CALayer *)parentLayer manager:(DoCoVideoLayerAnimationManager *)manager{
    //manager中是nsnumber   ms毫秒
//    添加背景音乐
    MyLog(@"转场元素动画开始");
    if (cuttolayers[@"backgroundMusic"] && ![@"" isEqualToString:cuttolayers[@"backgroundMusic"]]) {
        NSString * path = [[NSBundle mainBundle] pathForResource:cuttolayers[@"backgroundMusic"] ofType:@"mp3"];
        if ([FileTool fileIsExistAtPath:path]) {
            NSURL *musicURL = [NSURL fileURLWithPath:path];
            CMTime startTime = CMTimeMakeWithSeconds(0, 1);
            AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
            AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            [manager setUpAndAddAudioAtPath:sourceAudioTrack start:startTime dura:manager.totalDuration Type:@"bg"];
        }else{
            MyLog(@"背景音乐不存在");
        }

    }else{
        MyLog(@"背景音乐未填写");
    }
    
    //加载转场动画和音效
    int index = 1;
    for (int i=0; i<cuttolayers.count; i++) {
        NSString *cuttolayerkey = [NSString stringWithFormat:@"cutto%d",index];
        while (!cuttolayers[cuttolayerkey]) {
            index++;
            cuttolayerkey = [NSString stringWithFormat:@"cutto%d",index];
            if (index>cuttolayers.count+5) {//防止出现死循环
                MyLog(@"转场元素动画结束");
                return;
            }
        }
        MyLog(@"%@开始合成",cuttolayerkey);
        index++;
        //计算startTime  这里其实是被剪切掉的时长
        NSDictionary *layers = cuttolayers[cuttolayerkey];
        float nowStartTime = [(NSNumber *)manager.totalDurs[i] floatValue] - [self getTimeFromFrame:layers[@"duration"]]/2;
        
        float oldStartTime = [self getTimeFromFrame:layers[@"starttime"]];
        
        float starttime = oldStartTime - nowStartTime;
        [self layersAnimationAnalysisWithDic:layers parentLayer:parentLayer startTime:starttime];
        
        //转场音效添加
        if (layers[@"music"]) {
            NSString * path = [[NSBundle mainBundle] pathForResource:layers[@"music"] ofType:@"mp3"];
            if ([FileTool fileIsExistAtPath:path]) {
                NSURL *musicURL = [NSURL fileURLWithPath:path];
                CMTime startTime = CMTimeMakeWithSeconds((nowStartTime+[self getTimeFromFrame:layers[@"duration"]]/2)/1000, 1);
                CMTime duration = CMTimeMakeWithSeconds([self getTimeFromFrame:layers[@"duration"]]/1000, 1);
                AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:musicURL options:nil];
                AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
                [manager setUpAndAddAudioAtPath:sourceAudioTrack start:startTime dura:duration Type:@"cutto"];
            }else{
                MyLog(@"转场音效不存在");
            }
            
        }else{
            MyLog(@"转场音效未填");
        }
        MyLog(@"%@合成完毕",cuttolayerkey);
        
    }
    MyLog(@"转场元素动画结束");
}

-(void)cuttoAnimationAnalysisWithDic:(NSDictionary *)cuttos manager:(DoCoVideoLayerAnimationManager *)manager{
    MyLog(@"视频转场开始");
    int index = 1;
    for (int i = 0; i<cuttos.count; i++) {
        
        NSString *cuttokey = [NSString stringWithFormat:@"cutto%d",index];
        while (!cuttos[cuttokey]) {
            index++;
            cuttokey = [NSString stringWithFormat:@"cutto%d",index];
        }
        MyLog(@"%@开始合成",cuttokey);
        index ++;
        NSDictionary *cutto = cuttos[cuttokey];
        NSString *name = cutto[@"cuttoname"];
        float duration = [self getTimeFromFrame:cutto[@"duration"]];

        if ([@"translation" isEqualToString:name]) {
            NSString *direction = cutto[@"direction"];
            [manager cuttoAnimationtranslationAsset:manager.assetArray[i+1] direction:direction duration:duration];
        }else{
        
            NSString *funcName = [NSString stringWithFormat:@"cuttoAnimation%@Asset:duration:",name];
            MyLog(@"动画名：%@",name);
            [manager performSelector:NSSelectorFromString(funcName) withObject:manager.assetArray[i+1] withObject:[NSNumber numberWithFloat:duration]];
        }
        MyLog(@"%@合成完毕",cuttokey);
        
    }
    MyLog(@"视频转场结束");
}

-(float)getTimeFromFrame:(NSDictionary *)dic{
    float second = [(NSNumber *) dic[@"second"] floatValue];
    float frame = [(NSNumber *)dic[@"frame"] floatValue];
    float startTime = second*1000+frame*40;
    return startTime;
}

@end
