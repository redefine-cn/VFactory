//
//  DoCoPlayAndEditController.h
//  doco_ios_app
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

typedef NS_ENUM(NSInteger, DCalertViewRemindState) {
    DCalertViewRemindStateNetNotBest = 0,
    SLalertViewRemindStateNetVideoBad,
};
@class DCPlayView;
@interface DoCoPlayAndEditController : UIViewController

@property(nonatomic,strong) DCPlayView *dcPlayView;
@property(nonatomic,strong) AVPlayerItem *playerItem;
@property(nonatomic,strong) UIImageView *playButton;
@property(nonatomic,assign) Boolean isPlaying;
@property(nonatomic,strong)NSString *filePath;
@property(nonatomic,strong)DoCoProject *project;

@end
