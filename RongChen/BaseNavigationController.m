//
//  BaseNavigationController.m
//  RongChen
//
//  Created by YingheSun on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBarTintColor:[UIColor colorWithRed:41.0f/255.0f green:132.0f/255.0f blue:196.0f/255.0f alpha:1]];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setTitleTextAttributes:@{
                                     NSForegroundColorAttributeName :[UIColor whiteColor] ,
                                     NSFontAttributeName : [UIFont systemFontOfSize:20]
                                     }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
