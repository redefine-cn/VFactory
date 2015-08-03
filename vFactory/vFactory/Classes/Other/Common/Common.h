//
//  Common.h
//  Doco
//
//  Created by developer on 15/4/14.
//  Copyright (c) 2015年 developer. All rights reserved.
//
#import "AppDelegate.h"
#import "CommonTool.h"
#import "CocoaLumberjack.h"

//定义iphone版本
#define isIphone5 ([UIScreen mainScreen].bounds.size.height == 568)
#define isIphone6 ([UIScreen mainScreen].bounds.size.height == 667)
#define isIphone6p ([UIScreen mainScreen].bounds.size.height == 960)

//定义的全屏尺寸（包含状态栏）
#define DEVICE_BOUNDS [[UIScreen mainScreen] bounds]
#define DEVICE_SIZE [[UIScreen mainScreen] bounds].size

#define DEVICE_OS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//定义视频渲染尺寸
#define renderSizeL CGSizeMake(960, 540)
#define renderSizeP CGSizeMake(540, 960)

#define DELTA_Y (DEVICE_OS_VERSION >= 7.0f? 20.0f : 0.0f)

//5.获得RGB颜色
#define color(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define kColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

#define VIDEO_FOLDER @"videos"

#define myDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define autoScaleX ((AppDelegate *)[[UIApplication sharedApplication] delegate]).autoSizeScaleX
#define autoScaleY ((AppDelegate *)[[UIApplication sharedApplication] delegate]).autoSizeScaleY

//#define DEVICE_SIZE CGSizeMake(320*autoScaleX, 568*autoScaleY)

//字体：heiti k medium
//#define commonFont @"STHeitiK-Medium"

//系统默认字体
#define commonFont @"Helvetica"
#define kFont(n) [UIFont fontWithName:commonFont size:n]

////服务器配置、client_id 和 client_secret
#define kDocoUrl ((AppDelegate *)[[UIApplication sharedApplication] delegate]).BaseURL
#define kClientID ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ClientID
#define kClientSecret ((AppDelegate *)[[UIApplication sharedApplication] delegate]).ClientSecret

//2.日志输出宏定义
#ifdef DEBUG
//调试状态
#define MyLog(...) DDLogVerbose(__VA_ARGS__)
#else
//发布状态
#define MyLog(...)
#endif

#define kStatusBarHeight 20
#pragma mark - 导航栏
//导航栏的颜色
#define kNavBarColor kColor(54,165,173)
//导航栏的高度
#define kNavHeight 44//*autoScaleY
//导航栏按钮的宽高
#define kNavBtnWidthAndHeight kNavHeight
//导航栏的字体
#define kNavTextHeight 19//*autoScaleY
#define kNavFont kFont(kNavTextHeight)

//全局背景色
#define kGlobalBackgroundColor kColor(230, 230, 230)

#pragma mark - Dock
//Dock的字体颜色
#define kDockItemSelectColor kNavBarColor
#define kDockItemNormalColor kColor(168,168,168)
//Dock的高度
#define kDockHeight 60//*autoScaleY
//Dockitem的数量
#define kDockItemCount 3

//3.设置cell的边框宽度
#define kCellBorderWidth 10*autoScaleX
//设置tableView的边框宽度
#define kTableBorderWidth 4*autoScaleX
//设置底部额外的滚动区域
#define kScrollHeight 10*autoScaleY
//设置每个cell之间的间距
#define kCellMarginWidth 5*autoScaleX

#pragma mark - 视频播放界面
//视频播放上方空出的距离
#define kVideoShowTopHeight 40*autoScaleY
//返回按钮
#define kXBtnWidth 80*autoScaleX
#define kXBtnHeight 16.5*autoScaleY
#define kXBtnMarginWidth 27*autoScaleX
#define kXBtntopBorderMargin 31.5*autoScaleY
#define kBackBtnFont kFont(16.5*autoScaleY)

#define kVideoDetailTextColor kColor(102, 103, 103)
//播放按钮
#define playBtnCenterWidth 49*autoScaleX
#define playBtnCenterHeight 49*autoScaleY

//视频播放操作条(评论按钮和点赞按钮)
#define kLineRightMargin 70*autoScaleX
#define kOperationBtnWidth 16*autoScaleY
#define kOperationBtnHeight 16*autoScaleY
#define kOpetationBtnFont kFont(12*autoScaleY)
#define kBtnBGWidth 45*autoScaleX
#define kBtnBGHeight 45*autoScaleY

//评论cell
#define kCommentNameFont kFont(10*autoScaleY)
#define kCommentTimeFont kFont(6*autoScaleY)
#define kCommentTextFont kFont(10*autoScaleY)


//评论编辑区域的高度
#define kCommentEditViewHeight 40*autoScaleY
//评论区域字体
#define kCommentEditFont kFont(17*autoScaleY)
//评论编辑发送按钮的宽
#define kSendBtnWidth 55*autoScaleX


//空间背景
#define kZoneBackgroundImageHeightExtend 200*autoScaleY
#define kZoneNameFont kFont(16*autoScaleX)
#define kZoneNameBigFont kFont(20*autoScaleX)
#define kOrderByBtnTextFont kFont(11*autoScaleY)

//following
#define kFollowingZoneHeight 170*autoScaleY
#define kFollowingNameFont kFont(20*autoScaleY)
#define kFollowingUpdateTextHeight 12*autoScaleY
#define kFollowingUpdateTextWidth 12*4*autoScaleY
#define kUpdateWeekTextFont kFont(kFollowingUpdateTextHeight)

#define kFollowingNumHeight 11*autoScaleY
#define kupdateWeekNumberFont kFont(8*autoScaleY)

//我的
//video宽和高
#define kVideoShowSmallWidth 130
#define kVideoShowSmallHeight 73
#define kLBSIconWidth 13*2/3*autoScaleX
#define kLBSIconHeight 17*2/3*autoScaleY

#define kMyNameFont kFont(12*autoScaleY)
#define kMyNameColor [UIColor blackColor]
#define kDurationFont kFont(10*autoScaleY)
#define kOrderByBtnFont kFont(10*autoScaleY)
#define kLBSTextFont kFont(6*autoScaleY)

#define kSetUpCellTextFont kFont(11*autoScaleY)
#define kSetUpCellTextColor kColor(153, 153, 153)

#define kSetUpCellHeight 36.5*autoScaleY

//广场
#define kPlazaTextColor kColor(102, 103, 103)
#define kPlazaIconHeight 9*autoScaleY
#define kPlazaIconNumberFont kFont(9*autoScaleY)

#define kPlazaNameFont kFont(12*autoScaleY)
#define kPlazaVideoNameFont kFont(10*autoScaleY)

#define kPlazaSearchVideoNameFont kFont(10*autoScaleY)
#define kPlazaSearchUserNameFont kFont(6.5*autoScaleY)
#define kPlazaSearchTimeFont kFont(6.5*autoScaleY)

//7.图片尺寸
//三种类型头像的宽高
#define kIconSmallWidth 34*autoScaleX
#define kIconSmallHeight 34*autoScaleY
#define kIconDefaultWidth 50*autoScaleX
#define kIconDefaultHeight 50*autoScaleY
#define kIconBigWidth 155/2*autoScaleX
#define kIconBigHeight 155/2*autoScaleY

//9.刷新条数
#define kCommentCount 25
#define kFollowingCount 10
#define kVideoCount 10
#define kPlazaCount 10

//10. TimeView的宽高
#define kTimeViewWidth 50*autoScaleX
#define kTimeViewHeight 50*autoScaleY
