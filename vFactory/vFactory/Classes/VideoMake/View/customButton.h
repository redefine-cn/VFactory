//
//  customButton.h
//  doco_ios_app
//
//  Created by developer on 15/5/9.
//  Copyright (c) 2015年 developer. All rights reserved.
//


@interface customButton : UIButton

@property(nonatomic,assign)BOOL isImageLeft;


- (instancetype)initWithFrame:(CGRect)frame withIsImageLeft:(BOOL)isImageLeft;
@end
