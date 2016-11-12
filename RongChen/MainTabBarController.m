//
//  MainTabBarController.m
//  RongChen
//
//  Created by YingheSun on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "MainTabBarController.h"
#import "BaseNavigationController.h"
#import "RCMainViewController.h"
#import "RCCoachViewController.h"
#import "RCAccountViewController.h"
#import "RCRecommendViewController.h"
#import "RCStudyViewController.h"

@interface MainTabBarController (){
    RCMainViewController *_mainVC;
    RCCoachViewController *_coachVC;
    RCAccountViewController *_accountVC;
    RCRecommendViewController *_recommendVC;
    RCStudyViewController *_studyVC;
}


@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //设置tabar背景颜色
    self.selectedIndex = 0;
    self.tabBar.barTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    UIView *bgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.tabBar insertSubview:bgView atIndex:0];
    self.tabBar.opaque = YES;
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    NSDictionary* dict = @{NSFontAttributeName:[UIFont systemFontOfSize:13],
                           NSForegroundColorAttributeName:[UIColor colorWithRed:129/255.0 green:127/255.0 blue:129/255.0 alpha:1.0]};
    
    [tabBarItem setTitleTextAttributes:dict forState:UIControlStateNormal];
    
}

-(void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    
    NSDictionary* dict = @{NSFontAttributeName:[UIFont systemFontOfSize:13],
                           NSForegroundColorAttributeName:[UIColor colorWithRed:209/255.0 green:187/255.0 blue:125/255.0 alpha:1.0]};
    [tabBarItem setTitleTextAttributes:dict forState:UIControlStateSelected];
}

- (UIImage *)fetUIImage:(NSString *)imageName{
    
    if (ISIOS8) {
        UIImage *image=[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        return image;
    }else{
        UIImage *image=[UIImage imageNamed:imageName];
        return image;
    }
    
}
#pragma mark 添加tabbar控制器
- (void)setupSubviews
{
    //按钮普通状态
    NSArray *normalImages=@[@"首页1",@"推荐1",@"学车1",@"教练1",@"我的1"];
    //按钮高亮状态
    NSArray *selectedImages=@[@"首页",@"推荐",@"学车",@"教练",@"我的"];
    //按钮标题
    NSArray *titlesArray=@[@"首页",@"推荐",@"学车",@"教练",@"我的"];
    //主页
    _mainVC = [[RCMainViewController alloc] init];
    _mainVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:titlesArray[0] image:[self fetUIImage:normalImages[0]] selectedImage:[self fetUIImage:selectedImages[0]]];
    _mainVC.tabBarItem.tag = 0;
    _mainVC.title = titlesArray[0];
    [self unSelectedTapTabBarItems:_mainVC.tabBarItem];
    [self selectedTapTabBarItems:_mainVC.tabBarItem];
    BaseNavigationController *mainNav = [[BaseNavigationController alloc] initWithRootViewController:_mainVC];
    //设置navigationbar不透明
    mainNav.navigationBar.translucent = NO;
    //推荐
    _recommendVC = [[RCRecommendViewController alloc] init];
    _recommendVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:titlesArray[1] image:[self fetUIImage:normalImages[1]] selectedImage:[self fetUIImage:selectedImages[1]]];
    _recommendVC.tabBarItem.tag = 1;
    _recommendVC.title = titlesArray[1];
    [self selectedTapTabBarItems:_recommendVC.tabBarItem];
    [self unSelectedTapTabBarItems:_recommendVC.tabBarItem];
    BaseNavigationController *recommendNav = [[BaseNavigationController alloc] initWithRootViewController:_recommendVC];
    //学车
    _studyVC = [[RCStudyViewController alloc] init];
    _studyVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:titlesArray[2] image:[self fetUIImage:normalImages[2]] selectedImage:[self fetUIImage:selectedImages[2]]];
    _studyVC.tabBarItem.tag = 2;
    _studyVC.title = titlesArray[2];
    [self selectedTapTabBarItems:_studyVC.tabBarItem];
    [self unSelectedTapTabBarItems:_studyVC.tabBarItem];
    BaseNavigationController *studyNav = [[BaseNavigationController alloc] initWithRootViewController:_studyVC];
    //教练
    _coachVC = [[RCCoachViewController alloc] init];
    _coachVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:titlesArray[3] image:[self fetUIImage:normalImages[3]] selectedImage:[self fetUIImage:selectedImages[3]]];
    _coachVC.tabBarItem.tag = 3;
    _coachVC.title = titlesArray[3];
    [self unSelectedTapTabBarItems:_coachVC.tabBarItem];
    [self selectedTapTabBarItems:_coachVC.tabBarItem];
    BaseNavigationController *coachNav = [[BaseNavigationController alloc] initWithRootViewController:_coachVC];
    //我的
    _accountVC = [[RCAccountViewController alloc] init];
    _accountVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:titlesArray[4] image:[self fetUIImage:normalImages[4]] selectedImage:[self fetUIImage:selectedImages[4]]];
    _accountVC.tabBarItem.tag = 4;
    _accountVC.title = titlesArray[4];
    [self selectedTapTabBarItems:_accountVC.tabBarItem];
    [self unSelectedTapTabBarItems:_accountVC.tabBarItem];
    BaseNavigationController *accountNav = [[BaseNavigationController alloc] initWithRootViewController:_accountVC];
    //如果有编辑过的项目，那么就设置编辑的项目为主页
    NSArray *controllers = @[mainNav,recommendNav,studyNav,coachNav,accountNav];
    self.viewControllers = controllers;
    
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSLog(@"open with Nav :%ld -> %@",item.tag,item.title);
}

@end
