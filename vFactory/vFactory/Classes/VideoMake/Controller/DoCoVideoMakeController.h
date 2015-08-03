//
//  DoCoVideoMakeController.h
//  doco_ios_app
//
//  Created by developer on 15/4/25.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "DoCoCollectionView.h"
#import "DoCoProject.h"
#import "DoCoProjectPart.h"
#import "DCPlayView.h"
#import "customButton.h"

@class  MainController;
@interface DoCoVideoMakeController : UIViewController

@property(nonatomic,strong)DoCoCollectionView * docoCollectionTypeView;

@property(nonatomic,strong)DCPlayView  *dcPlayView;

@property(nonatomic,strong)DoCoCollectionView *docoCollectionSelectView;

@property(nonatomic,strong)DoCoCollectionView *docoCollectionPreview;

@property(nonatomic,strong)customButton *captureButton;

@property(nonatomic,strong)UIButton *libraryButton;
@property(nonatomic,strong)DoCoProject *project;

@property(nonatomic,strong)MainController *lastController;

@end
