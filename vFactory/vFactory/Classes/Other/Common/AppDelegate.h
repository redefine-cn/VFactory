//
//  AppDelegate.h
//  doco_iso_app
//
//  Created by developer on 15/4/15.
//  Copyright (c) 2015年 developer. All rights reserved.
//

typedef enum{
    kConfigTypeNormal,
    kConfigTypeTest,
}DocoConfigType;

#import <UIKit/UIKit.h>
#import "DoCoProject.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property float autoSizeScaleX;
@property float autoSizeScaleY;


@property (nonatomic, assign) DocoConfigType DocoConfigType;
@property (nonatomic, copy) NSString *BaseURL;
@property (nonatomic, copy) NSString *ClientID;
@property (nonatomic, copy) NSString *ClientSecret;

@end

