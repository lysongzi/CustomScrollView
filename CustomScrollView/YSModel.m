//
//  YSModel.m
//  CustomScrollView
//
//  Created by lysongzi on 16/1/7.
//  Copyright © 2016年 lysongzi. All rights reserved.
//

#import "YSModel.h"

@implementation YSModel

- (instancetype)init
{
    return [self initWithName:@"自定义" logoName:@"custom"];
}

- (instancetype)initWithName:(NSString *)name logoName:(NSString *)logoName
{
    self = [super init];
    if (self)
    {
        _name = name;
        _logoName = logoName;
    }
    return self;
}

@end
