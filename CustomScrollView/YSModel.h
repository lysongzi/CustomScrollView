//
//  YSModel.h
//  CustomScrollView
//
//  Created by lysongzi on 16/1/7.
//  Copyright © 2016年 lysongzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSModel : NSObject

//模型名称
@property (copy, nonatomic) NSString *name;
//模型图标
@property (copy, nonatomic) NSString *logoName;

- (instancetype)initWithName:(NSString *)name logoName:(NSString *)logoName;

@end
