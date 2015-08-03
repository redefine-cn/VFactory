//
//  Classification.h
//  Doco
//
//  Created by developer on 15/4/16.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Classification : NSObject
@property (nonatomic, assign) int classificationId; //类别Id
@property (nonatomic, copy) NSString *name; //类别名称

- (id)initWithDict:(NSDictionary *)dict;

@end
