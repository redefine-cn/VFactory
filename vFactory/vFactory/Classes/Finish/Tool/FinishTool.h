//
//  FinishTool.h
//  doco_ios_app
//
//  Created by developer on 15/5/18.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FinishTool : NSObject
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time ;
@end
