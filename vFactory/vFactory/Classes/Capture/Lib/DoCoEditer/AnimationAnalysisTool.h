//
//  AnimationAnalysisTool.h
//  doco_ios_app
//
//  Created by developer on 15/6/1.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoVideoLayerAnimationManager.h"

@interface AnimationAnalysisTool : NSObject

@property(nonatomic,assign)BOOL isPortrait;

-(void)setupLayerWithDic:(NSDictionary *)layer toLayer:(CALayer   *)anilayer startTime:(float)startTime type:(NSString *)type;

-(void)segmentAnimationAnalysisWithDic:(NSDictionary *)segment subtitles:(NSMutableArray *)subs parentLayer:(CALayer *)parentLayer headImage:(UIImage *)headImage footImage:(UIImage *)footImage;

-(void)overall_layerAnimationAnalysisWithDic:(NSDictionary *)layers parentLayer:(CALayer *)parentLayer;

-(void)cuttoLayerAnimationAnalysisWithDic:(NSDictionary *)cuttolayers parentLayer:(CALayer *)parentLayer manager:(DoCoVideoLayerAnimationManager *)manager;

-(void)cuttoAnimationAnalysisWithDic:(NSDictionary *)cuttos manager:(DoCoVideoLayerAnimationManager *)manager;

@end
