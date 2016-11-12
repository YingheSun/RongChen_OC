//
//  RCNewsModel.h
//  RongChen
//
//  Created by YingheSun on 16/9/27.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCNewsModel : NSObject
//跳转的URL
@property(nonatomic,strong)NSString *url;
//什么编号
@property(nonatomic,strong)NSString *id;
//标题
@property(nonatomic,strong)NSString *title;
//内容
@property(nonatomic,strong)NSString *content;
//类型
@property(nonatomic,strong)NSString *category;
//描述
@property(nonatomic,strong)NSString *comment;
//封面图片
@property(nonatomic,strong)NSString *coverImage;
//不清楚是什么
@property(nonatomic,strong)NSString *showOrder;
//时间
@property(nonatomic,strong)NSString *createDate;

@end
