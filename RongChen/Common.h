//
//  Common.h
//  RongChen
//
//  Created by YingheSun on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#ifndef Common_h
#define Common_h

// 网络参数
#define RCImageURL @"http://image.soundlifeonline.com/p/"
#define RCNetRequestURL @"http://stardang.com:8020/"



// 日志输出宏定义
#ifdef DEBUG
// 调试状态
#define MyLog(...) NSLog(__VA_ARGS__)
#else
// 发布状态
#define MyLog(...)
#endif

//判断是否为ios8
#define ISIOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)

#define getLocalData(key) [[NSUserDefaults standardUserDefaults] objectForKey:key];
#define saveLocal(key,value) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];

#define RCScreenHeight [[UIScreen mainScreen] bounds].size.height
#define RCScreenWidth [[UIScreen mainScreen] bounds].size.width
#define W(obj)   (!obj?0:(obj).frame.size.width)
#define H(obj)   (!obj?0:(obj).frame.size.height)
#define X(obj)   (!obj?0:(obj).frame.origin.x)
#define Y(obj)   (!obj?0:(obj).frame.origin.y)
#define XW(obj) (X(obj)+W(obj))
#define YH(obj) (Y(obj)+H(obj))

#define RCPBlack(obj)  [SVProgressHUD showWithStatus:obj maskType:SVProgressHUDMaskTypeBlack];
#define RCPNone(obj)  [SVProgressHUD showWithStatus:obj maskType:SVProgressHUDMaskTypeNone];
#define RCPSuccess(obj) [SVProgressHUD showSuccessWithStatus:obj];
#define RCPError(obj) [SVProgressHUD showErrorWithStatus:obj];
#define RCPdismiss [SVProgressHUD dismiss];

#define RCPhoneNumber @"phoneNumber"
#define RCPassCode @"passCode"
#define RCUserId  @"userId"
#define RCToken  @"token"

#endif /* Common_h */
