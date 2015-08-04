//
//  AppDelegate.m
//  Doco
//
//  Created by developer on 15/4/14.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "AppDelegate.h"
#import "DocoVideoMakeController.h"
#import "DoCoPlayAndEditController.h"

#import "UncaughtExceptionHandl.h"

#import "VideoNavigationController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    setenv("XcodeColors", "YES", 0);
    UIApplication* app = [ UIApplication  sharedApplication ];
    app.networkActivityIndicatorVisible = YES;
    //配置服务器信息
    self.DocoConfigType = kConfigTypeNormal;
    
    //配置自定义日志框架
    [DDLog addLogger:[DDASLLogger sharedInstance]withLevel:DDLogLevelVerbose];
    [DDLog addLogger:[DDTTYLogger sharedInstance]withLevel:DDLogLevelVerbose];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagWarning];
    //配置日志文件   保持一周
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelWarning];
    
    InstallUncaughtExceptionHandler();
    //    MyLog(@"%@",fileLogger.logFileManager.logsDirectory);
    //fileLogger.logFileManager.logsDirectory
    
    if(DEVICE_SIZE.height > 480){
        
        //        self.autoSizeScaleX = 1.0;
        //        self.autoSizeScaleY = 1.0;
        
        self.autoSizeScaleX = DEVICE_SIZE.width/320;
        self.autoSizeScaleY = DEVICE_SIZE.height/568;
    }else{
        self.autoSizeScaleX = 1.0;
        self.autoSizeScaleY = 1.0;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    application.statusBarHidden = NO;
    DoCoPlayAndEditController *edit = [[DoCoPlayAndEditController alloc]init];
    VideoNavigationController *videoNavController = [[VideoNavigationController alloc]initWithRootViewController:edit];
    
    self.window.rootViewController = videoNavController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)initialFolder{
    //存放所有工程的的文件夹
    NSString *projectsPath = [FileTool getSaveFolderPathStringWithFolderName:@"projects"];
    if([CommonTool createFolderIfNotExistForFolderPath:projectsPath]){
        MyLog(@"大文件夹创建成功");
    }
    //存放工程s的总描述plist文件
    if([CommonTool createFolderIfNotExistForFolderPath:[FileTool getSaveFolderPathStringWithFolderName:@"data"]]){
        MyLog(@"data文件夹创建成功");
    }
    //存放所有model的资源的文件夹
    if([CommonTool createFolderIfNotExistForFolderPath:[FileTool getSaveFolderPathStringWithFolderName:@"models"]]){
        MyLog(@"models文件夹创建成功");
    }
    //存放所有music文件夹
    if([CommonTool createFolderIfNotExistForFolderPath:[FileTool getSaveFolderPathStringWithFolderName:@"music"]]){
        MyLog(@"music文件夹创建成功");
    }
    //存放下载文件的临时文件夹
    if([CommonTool createFolderIfNotExistForFolderPath:[FileTool getSaveFolderPathStringWithFolderName:@"temp"]]){
        MyLog(@"music文件夹创建成功");
    }
    
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    MyLog(@"内存警告，appDelegate！！");
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!!"
    //                                                    message:@"内存警告！"
    //                                                   delegate:self
    //                                          cancelButtonTitle:@"取消"
    //                                          otherButtonTitles:@"请退出程序", nil];
    //    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
