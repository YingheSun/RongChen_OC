//
//  RCRecommendSuccessViewController.m
//  RongChen
//
//  Created by 孙滢贺 on 16/9/29.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCRecommendSuccessViewController.h"

@interface RCRecommendSuccessViewController ()

@end

@implementation RCRecommendSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBarView];
    [self showView];
    
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    self.navigationItem.title = @"推荐学车";
}

#pragma mark -- 加载页面
- (void)showView{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    UILabel *successText = [[UILabel alloc]init];
    [self.view addSubview:successText];
    NSString *successStr = [NSString stringWithFormat:@"成功推荐手机号为%@的用户，在用户成功报名后，您将获得200的推荐奖金。推荐记录在我的账户里查看处理的进度", self.phoneStr];
    successText.text = successStr;
    successText.textAlignment = NSTextAlignmentLeft;
    successText.numberOfLines = 10 ;
    [successText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.mas_offset(RCScreenHeight * 0.15);
        make.height.mas_equalTo(100);
        make.width.mas_equalTo(RCScreenWidth * 0.9);
    }];
}

@end
