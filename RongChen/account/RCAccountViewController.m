//
//  RCAccountViewController.m
//  RongChen
//
//  Created by 孙滢贺 on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCAccountViewController.h"
#import "RCAccountListViewController.h"
#import "RCRecommendListViewController.h"
#import "RCPhoneConfirmViewController.h"
#import "RCAccountManageViewController.h"
#import "RCShopViewController.h"
#import "RCCartViewController.h"
#import "RCMyOrderViewController.h"

@interface RCAccountViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic ,strong) NSString *userProfilesURL;

@property (nonatomic ,strong) NSArray *userInfoArr;

@end

@implementation RCAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userProfilesURL = @"userProfiles";
    [self setBarView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [self requestForState];
}

#pragma mark - 网络请求
- (void)requestForState{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"user" : userId
                          };
    [XSHttpTool GET:_userProfilesURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        _userInfoArr = responseDic[@"results"];
        NSLog(@"get userProfile success,user=> %@,info: %@",userId,responseDic);
        [self setViewShow];
    } failure:^(NSError *error) {
        RCPError(@"获取信息失败");
    }];
}


#pragma mark - navigationbar导航栏设置
- (void)setBarView{
    //左侧的slider menu 取消
    self.navigationItem.title = @"我的账户";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)setViewShow{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    UIView *userView = [[UIView alloc]initWithFrame:CGRectMake(0, 80, RCScreenWidth, 100)];
    userView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:userView];
    
    UIImageView *userImg = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 75 , 75)];
    userImg.layer.cornerRadius = 25.0f;
    [userImg setClipsToBounds:YES];
    [userView addSubview:userImg];
    if([_userInfoArr[0][@"avatar"] isEqualToString:@""]){
        [userImg setImage:[UIImage imageNamed:@"HeadIcon"]];
    }else{
        NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,_userInfoArr[0][@"avatar"],@"@!mobile"];
        [userImg sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"HeadIcon"]];
    }
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 15, 150, 30)];
    nameLabel.text = _userInfoArr[0][@"realName"];
    [userView addSubview:nameLabel];
    
    UILabel *IDnum = [[UILabel alloc]initWithFrame:CGRectMake(100, 55, RCScreenWidth - 150, 30)];
    NSString *phoneStr = getLocalData(RCPhoneNumber);
    NSString *IDStr = [NSString stringWithFormat:@"手机:%@",phoneStr];
    IDnum.text = IDStr;
    IDnum.textColor = [UIColor lightGrayColor];
    [userView addSubview:IDnum];
    
    UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(RCScreenWidth - 50, 45, 27 , 26)];
    [editBtn setBackgroundImage:[UIImage imageNamed:@"编辑"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(editViewPush) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:editBtn];
    
    UIView *phoneView = [[UIView alloc]initWithFrame:CGRectMake(0, 185, RCScreenWidth, 50)];
    phoneView.backgroundColor = [UIColor whiteColor];
    //添加点按击手势监听器
    UITapGestureRecognizer *phoneGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPhoneView)];
    //设置手势属性
    phoneGesture.delegate = self;
    phoneGesture.numberOfTapsRequired=1;//设置点按次数，为1
    phoneGesture.numberOfTouchesRequired=1;//点按的手指数
    [phoneView addGestureRecognizer:phoneGesture];
    [self.view addSubview:phoneView];
    
    UILabel *phoneTitle = [[UILabel alloc]initWithFrame:CGRectMake(10 , 5, RCScreenWidth, 40)];
    phoneTitle.text = @"用户电话";
    [phoneView addSubview:phoneTitle];
    
    UILabel *phoneDetail = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, RCScreenWidth - 10, 40)];
    phoneDetail.text = _userInfoArr[0][@"mobile"];
    phoneDetail.textAlignment = NSTextAlignmentRight;
    phoneDetail.textColor = [UIColor lightGrayColor];
    [phoneView addSubview:phoneDetail];

    
    UIView *levelView = [[UIView alloc]initWithFrame:CGRectMake(0, 236, RCScreenWidth, 50)];
    levelView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:levelView];
    
    UILabel *levelTitle = [[UILabel alloc]initWithFrame:CGRectMake(10 , 5, RCScreenWidth, 40)];
    levelTitle.text = @"用户等级";
    [levelView addSubview:levelTitle];
    
    UILabel *levelDetail = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, RCScreenWidth - 10, 40)];
    levelDetail.text = _userInfoArr[0][@"level"];
    levelDetail.textAlignment = NSTextAlignmentRight;
    levelDetail.textColor = [UIColor lightGrayColor];
    [levelView addSubview:levelDetail];
    
    UIView *recommendView = [[UIView alloc]initWithFrame:CGRectMake(0, 287, RCScreenWidth, 50)];
    recommendView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:recommendView];
    
    UILabel *recommendTitle = [[UILabel alloc]initWithFrame:CGRectMake(10 , 5, RCScreenWidth, 40)];
    recommendTitle.text = @"推荐记录:";
    //添加点按击手势监听器
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRecommendView)];
    //设置手势属性
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired=1;//设置点按次数，为1
    tapGesture.numberOfTouchesRequired=1;//点按的手指数
    [recommendView addGestureRecognizer:tapGesture];
    [recommendView addSubview:recommendTitle];
    
    UILabel *recommendDetail = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, RCScreenWidth - 10, 40)];
    NSString *recommendStr = [NSString stringWithFormat:@"推荐%@人,成功推荐%@人",_userInfoArr[0][@"recommendTotalCount"],_userInfoArr[0][@"recommendSuccessCount"]];
    recommendDetail.text = recommendStr;
    recommendDetail.textAlignment = NSTextAlignmentRight;
    recommendDetail.textColor = [UIColor lightGrayColor];
    [recommendView addSubview:recommendDetail];
    
    UIView *moneyView = [[UIView alloc]initWithFrame:CGRectMake(0, 338, RCScreenWidth, 50)];
    moneyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:moneyView];
    
    UILabel *moneyTitle = [[UILabel alloc]initWithFrame:CGRectMake(10 , 5, RCScreenWidth, 40)];
    moneyTitle.text = @"用户余额:";
    //添加点按击手势监听器
    UITapGestureRecognizer *tapMoneyView=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapMoneyView)];
    //设置手势属性
    tapMoneyView.delegate = self;
    tapMoneyView.numberOfTapsRequired=1;//设置点按次数，为1
    tapMoneyView.numberOfTouchesRequired=1;//点按的手指数
    [moneyView addGestureRecognizer:tapMoneyView];
    [moneyView addSubview:moneyTitle];
    
    UILabel *moneyDetail = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, RCScreenWidth - 10, 40)];
    NSString *moneyStr = [NSString stringWithFormat:@"%@",_userInfoArr[0][@"score"]];
    moneyDetail.text = moneyStr;
    moneyDetail.textAlignment = NSTextAlignmentRight;
    moneyDetail.textColor = [UIColor lightGrayColor];
    [moneyView addSubview:moneyDetail];
    
    UIView *myOrderView = [[UIView alloc]initWithFrame:CGRectMake(0, 389, RCScreenWidth, 50)];
    myOrderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:myOrderView];
    
    UILabel *myOrderTitle = [[UILabel alloc]initWithFrame:CGRectMake(10 , 5, RCScreenWidth, 40)];
    myOrderTitle.text = @"我的订单";
    //添加点按击手势监听器
    UITapGestureRecognizer *tapOrderView=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCartView)];
    //设置手势属性
    tapOrderView.delegate = self;
    tapOrderView.numberOfTapsRequired=1;//设置点按次数，为1
    tapOrderView.numberOfTouchesRequired=1;//点按的手指数
    [myOrderView addGestureRecognizer:tapOrderView];
    [myOrderView addSubview:myOrderTitle];
    
    UIImageView *myorderImg = [[UIImageView alloc]initWithFrame:CGRectMake(RCScreenWidth - 20, 17.5, 9, 15)];
    myorderImg.image = [UIImage imageNamed:@"arrow"];
    [myOrderView addSubview:myorderImg];

    UIView *shopView = [[UIView alloc]initWithFrame:CGRectMake(0, 440, RCScreenWidth, 50)];
    shopView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:shopView];
    
    UILabel *shopTitle = [[UILabel alloc]initWithFrame:CGRectMake(10 , 5, RCScreenWidth, 40)];
    shopTitle.text = @"逛商城";
    //添加点按击手势监听器
    UITapGestureRecognizer *tapShopView=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapShopView)];
    //设置手势属性
    tapShopView.delegate = self;
    tapShopView.numberOfTapsRequired=1;//设置点按次数，为1
    tapShopView.numberOfTouchesRequired=1;//点按的手指数
    [shopView addGestureRecognizer:tapShopView];
    [shopView addSubview:shopTitle];
    
    UIImageView *shopImg = [[UIImageView alloc]initWithFrame:CGRectMake(RCScreenWidth - 20, 17.5, 9, 15)];
    shopImg.image = [UIImage imageNamed:@"arrow"];
    [shopView addSubview:shopImg];

}

- (void)editViewPush{
    NSLog(@"Account Manage Tapped");
    self.hidesBottomBarWhenPushed=YES;
    
    RCAccountManageViewController *accountManageVC = [[RCAccountManageViewController alloc]init];
    
    accountManageVC.name = _userInfoArr[0][@"realName"];
    accountManageVC.sex = _userInfoArr[0][@"gender"];
    
    [self.navigationController pushViewController:accountManageVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)tapPhoneView{
    NSLog(@"Phone Confirm Tapped");
    self.hidesBottomBarWhenPushed=YES;
    
    RCPhoneConfirmViewController *phoneConfirmVC = [[RCPhoneConfirmViewController alloc]init];
    
    [self.navigationController pushViewController:phoneConfirmVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)tapRecommendView{
    NSLog(@"RecommendView Tapped");
    self.hidesBottomBarWhenPushed=YES;
    
    RCRecommendListViewController *recommendListVC = [[RCRecommendListViewController alloc]init];
    
    [self.navigationController pushViewController:recommendListVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)tapMoneyView{
    NSLog(@"MoneyView Tapped");
    self.hidesBottomBarWhenPushed=YES;
    
    RCAccountListViewController *accountListVC = [[RCAccountListViewController alloc]init];
    NSString *account = [NSString stringWithFormat:@"¥%@",_userInfoArr[0][@"score"]];
    accountListVC.accountInfo = account;
    
    [self.navigationController pushViewController:accountListVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

- (void)tapCartView{
    NSLog(@"CartView Tapped");
    self.hidesBottomBarWhenPushed=YES;
    
    RCMyOrderViewController *orderVC = [[RCMyOrderViewController alloc]init];
    
    [self.navigationController pushViewController:orderVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
    
}

- (void)tapShopView{
    NSLog(@"ShopView Tapped");
    
    RCShopViewController *shopListVC = [[RCShopViewController alloc]init];
    
    [self.navigationController pushViewController:shopListVC animated:YES];

}

@end
