//
//  VideoFinishController.h
//  doco_ios_app
//
//  Created by developer on 15/5/18.
//  Copyright (c) 2015年 developer. All rights reserved.
//

@interface VideoFinishController : UIViewController

@property (nonatomic, retain) NSString *videoUrl;
@property(nonatomic,strong)DoCoProject *project;

@property(nonatomic,strong)NSMutableDictionary *segments;
@property(nonatomic,strong)NSMutableDictionary *cuttos;
@property(nonatomic,strong)NSMutableDictionary *overalls;
@property(nonatomic,strong)NSMutableDictionary *cuttolayers;
@end
