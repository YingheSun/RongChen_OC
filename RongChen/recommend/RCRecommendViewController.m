//
//  RCRecommendViewController.m
//  RongChen
//
//  Created by 孙滢贺 on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCRecommendViewController.h"
#import "RCSliderMenuViewController.h"
#import "MenuView.h"
#import "RCRecommendSuccessViewController.h"


@interface RCRecommendViewController ()<HomeMenuViewDelegate>

@property (nonatomic ,strong) MenuView *menu;
@property (nonatomic ,strong) UITextField *PhoneField;
@property (nonatomic ,strong) UITextField *nameField;

@property (nonatomic ,strong) NSString *recommendsURL;

@end

@implementation RCRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBarView];
    [self initSliderMenu];
    [self showView];
    _recommendsURL = @"recommends";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    self.navigationItem.title = @"推荐学车";
    //左侧的slider menu 取消
//    UIBarButtonItem *LeftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(sliderMenuShow)];
//    self.navigationItem.leftBarButtonItem = LeftItem;
}

#pragma mark - slidermenu侧滑菜单
-(void)initSliderMenu{
    RCSliderMenuViewController *sliderMenu = [[RCSliderMenuViewController alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.8, RCScreenHeight)];
    sliderMenu.customDelegate = self;
    self.menu = [[MenuView alloc]initWithDependencyView:self.view MenuView:sliderMenu isShowCoverView:YES];
}

-(void)sliderMenuShow{
    [self.menu show];
}

#pragma mark - 侧滑菜单点击事件
-(void)LeftMenuViewClick:(NSInteger)tag{
    [self.menu hidenWithAnimation];
    NSLog(@"tag = %lu",tag);
}

#pragma mark -- 加载页面
- (void)showView{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    _PhoneField = [[UITextField alloc]init];
    [self.view addSubview:_PhoneField];
    [_PhoneField.layer setCornerRadius:5.0f];
    [_PhoneField setClipsToBounds:YES];
    _PhoneField.placeholder = @"手机号码";
    _PhoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _PhoneField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _PhoneField.backgroundColor = [UIColor whiteColor];
    [_PhoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.mas_offset(RCScreenHeight * 0.3);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
    _nameField = [[UITextField alloc]init];
    [self.view addSubview:_nameField];
    [_nameField.layer setCornerRadius:5.0f];
    [_nameField setClipsToBounds:YES];
    _nameField.placeholder = @"姓名";
    _nameField.backgroundColor = [UIColor whiteColor];
    [_nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_PhoneField.mas_bottom).with.mas_offset(RCScreenHeight * 0.01);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
    UIButton *commitBtn = [[UIButton alloc]init];
    [self.view addSubview:commitBtn];
    [commitBtn setTitle:@"推 荐" forState:UIControlStateNormal];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize: 22.0f];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [commitBtn.layer setCornerRadius:5.0f];
    [commitBtn setClipsToBounds:YES];
    [commitBtn addTarget:self action:@selector(commitRequest) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_nameField.mas_bottom).with.mas_offset(RCScreenHeight * 0.05);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
}

#pragma mark - 提交请求
-(void)commitRequest{
    if([self isValidateMobile:_PhoneField.text]){
        NSLog(@"->commit request: phone: %@ name: %@",_PhoneField.text , _nameField.text);
        NSString *userId = getLocalData(RCUserId);
        NSDictionary *dic = @{@"recommendMobile" : _PhoneField.text,
                              @"recommendUserName" : _nameField.text,
                              @"user" : userId
                              };
        [XSHttpTool GET:_recommendsURL param:dic success:^(id responseObject) {
            RCPSuccess(@"提交成功");
            RCRecommendSuccessViewController *successVC = [[RCRecommendSuccessViewController alloc]init];
            successVC.phoneStr = _PhoneField.text;
            [self.navigationController pushViewController:successVC animated:YES];
        } failure:^(NSError *error) {
            RCPError(@"提交失败");
        }];
    }else{
        RCPError(@"手机格式错误");
    }
}

//手机号码验证
- (BOOL) isValidateMobile:(NSString *)mobile{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

@end
