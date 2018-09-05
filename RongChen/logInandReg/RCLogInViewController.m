//
//  RCLogInViewController.m
//  RongChen
//
//  Created by YingheSun on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//  登录页面

#import "RCLogInViewController.h"
#import<CommonCrypto/CommonDigest.h>
#import "MainTabBarController.h"
#import "RCRegisterViewController.h"
#import "RCForgetPassCodeViewController.h"

@interface RCLogInViewController ()

@property(nonatomic,strong) NSString *phoneNum;
@property(nonatomic,strong) NSString *passCode;
//@property(nonatomic,strong) NSString *token;

@property(nonatomic,strong) UITextField *phoneTextField;
@property(nonatomic,strong) UITextField *passWordTextField;
@property(nonatomic,strong) UIButton *logInBtn;
@property(nonatomic,strong) UIButton *regBtn;
@property(nonatomic,strong) UIButton *forgetBtn;

@property(nonatomic,strong) NSString *loginURL;

@end

@implementation RCLogInViewController
@synthesize phoneTextField = _phoneTextField;
@synthesize passWordTextField = _passWordTextField;

- (void)viewDidLoad {
    self.title = @"登陆页面";
    [super viewDidLoad];
    _loginURL = @"login";
    [self quickLogIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark -- 自动登录，安卓逻辑相对于加载的欢迎页面
- (void)quickLogIn{
    NSString *phoneNumStr = getLocalData(RCPhoneNumber);
    NSString *passWordStr = getLocalData(RCPassCode);
    if (phoneNumStr.length == 0 || passWordStr.length == 0) {
        [self makeViewAppear];
    }else{
        [self quickLoginRequest];
    }
}

#pragma mark -- 加载UI
- (void)makeViewAppear{
    //键盘处理->点击空白处键盘收起
    [self keyboardGesture];
    
    //backgroundImage
    UIImageView *backgroundView = [[UIImageView alloc]init];
    [self.view addSubview:backgroundView];
    backgroundView.image = [UIImage imageNamed:@"登陆背景"];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.self.center.equalTo(self.view);
        make.self.height.equalTo(self.view);
        make.self.width.equalTo(self.view);
    }];
    
    //phoneArea
    UIView *phoneArea = [[UIView alloc]init];
    [self.view addSubview:phoneArea];
    [phoneArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0.4 * RCScreenHeight);
        make.left.equalTo(self.view).with.offset(25);
        make.height.mas_equalTo(61);
        make.width.mas_equalTo(RCScreenWidth - 60);
    }];
    
    UIView *lineView1 = [[UIView alloc]init];
    [self.view addSubview:lineView1];
    lineView1.backgroundColor = [UIColor whiteColor];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(phoneArea);
        make.height.mas_equalTo(1);
        make.width.equalTo(phoneArea);
        make.centerX.equalTo(phoneArea);
    }];
    
    UIImageView *phoneLeftV = [[UIImageView alloc]init];
    [self.view addSubview:phoneLeftV];
    phoneLeftV.image = [UIImage imageNamed:@"phone"];
    [phoneLeftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(phoneArea).with.offset(5);
        make.centerY.equalTo(phoneArea);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(18);
    }];
    
    _phoneTextField = [[UITextField alloc]init];
    [self.view addSubview:_phoneTextField];
    _phoneTextField.placeholder = @"请输入手机号"; //默认显示的字
    _phoneTextField.textColor = [UIColor whiteColor];
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(phoneArea);
        make.left.equalTo(phoneLeftV).with.offset(40);
        make.right.equalTo(phoneArea);
        make.height.mas_equalTo(50);
    }];
    
    //password
    UIView *passArea = [[UIView alloc]init];
    [self.view addSubview:passArea];
    [passArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneArea).with.offset(0.1 * RCScreenHeight);
        make.left.equalTo(self.view).with.offset(25);
        make.height.mas_equalTo(61);
        make.width.mas_equalTo(RCScreenWidth - 60);
    }];
    
    UIView *lineView2 = [[UIView alloc]init];
    [self.view addSubview:lineView2];
    lineView2.backgroundColor = [UIColor whiteColor];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(passArea);
        make.height.mas_equalTo(1);
        make.width.equalTo(passArea);
        make.centerX.equalTo(passArea);
    }];
    
    UIImageView *passLeftV = [[UIImageView alloc]init];
    [self.view addSubview:passLeftV];
    passLeftV.image = [UIImage imageNamed:@"code"];
    [passLeftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(passArea).with.offset(5);
        make.centerY.equalTo(passArea);
        make.height.mas_equalTo(30.5);
        make.width.mas_equalTo(22);
    }];
    
    _passWordTextField = [[UITextField alloc]init];
    [self.view addSubview:_passWordTextField];
    _passWordTextField.placeholder = @"请输入密码"; //默认显示的字
    _passWordTextField.secureTextEntry = YES; //密码
    _passWordTextField.textColor = [UIColor whiteColor];
    _passWordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_passWordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(passArea);
        make.left.equalTo(passLeftV).with.offset(40);
        make.right.equalTo(passArea);
        make.height.mas_equalTo(50);
    }];
    
    //commit
    _logInBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:_logInBtn];
    [_logInBtn setTitle:@"登 陆" forState:UIControlStateNormal];
    _logInBtn.titleLabel.font = [UIFont systemFontOfSize: 22.0f];
    [_logInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_logInBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [_logInBtn.layer setCornerRadius:5.0f];
    [_logInBtn setClipsToBounds:YES];
    [_logInBtn addTarget:self action:@selector(commitRequest) forControlEvents:UIControlEventTouchUpInside];
    [_logInBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passArea.mas_bottom).with.offset(0.02 * RCScreenHeight);
        make.width.equalTo(passArea);
        make.centerX.equalTo(passArea);
        make.height.mas_equalTo(50);
    }];
    
    //register
    _forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_forgetBtn];
    [_forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    _forgetBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0f];
    [_forgetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_forgetBtn addTarget:self action:@selector(startForget) forControlEvents:UIControlEventTouchUpInside];
    [_forgetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logInBtn.mas_bottom).with.offset(0.01 * RCScreenHeight);
        make.width.mas_equalTo(100);
        make.left.equalTo(_logInBtn);
        make.height.mas_equalTo(20);
    }];
    
    
    //forfetPassCode
    _regBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_regBtn];
    [_regBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    _regBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [_regBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_regBtn addTarget:self action:@selector(startRegister) forControlEvents:UIControlEventTouchUpInside];
    [_regBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logInBtn.mas_bottom).with.offset(0.01 * RCScreenHeight);
        make.width.mas_equalTo(100);
        make.right.equalTo(_logInBtn);
        make.height.mas_equalTo(20);
    }];
    
}

#pragma mark -- 进入页面时加载网络数据
- (void)quickLoginRequest{
    _phoneNum = getLocalData(RCPhoneNumber);
    NSString *passWordStr = getLocalData(RCPassCode);
    _passCode = [self md5HexDigest:passWordStr];
//    _token = getLocalData(RCToken);
    [_phoneTextField setText:_phoneNum];
    [_passWordTextField setText:_passCode];
    [self commitRequest];
}

#pragma mark -- 登陆接口成功的处理
- (void)resolveData:(NSDictionary *)jsonData andWithToken:(NSString *)token{
    saveLocal(RCUserId, jsonData[@"id"]);
    saveLocal(RCToken, token);
    if(_passWordTextField.text.length != 0 && _phoneTextField.text.length != 0){
        [self dataPersistence:jsonData[@"id"]];
    }
    RCPSuccess(@"登录成功");
    //进入主页
    MainTabBarController *mainVC = [[MainTabBarController alloc] init];
    [self.navigationController pushViewController:mainVC animated:true];
}

#pragma mark -- 处理密码，数据加密
- (void)resolvePassword{
    
    if(_phoneNum.length == 0){
        NSLog(@"->phoneNum is invalid!!!");
    }else if(_passWordTextField.text.length < 6 && !_passWordTextField){
        RCPError(@"密码不能小于6位");
    }else{
        _passCode = [self md5HexDigest:_passWordTextField.text];
    }
}

#pragma mark -- 处理电话合法性
- (void)resolvePhoneValidation{
    if([self isValidateMobile:_phoneTextField.text]){
        _phoneNum = _phoneTextField.text;
    }else{
        RCPError(@"手机号码格式错误");
    }
}

#pragma mark -- 提交登录请求
- (void)commitRequest{
    //进入主页
    //testingCHG
    MainTabBarController *mainVC = [[MainTabBarController alloc] init];
    [self.navigationController pushViewController:mainVC animated:true];
    
    
    [self resolvePhoneValidation];
    [self resolvePassword];
    if(_phoneNum.length == 0 || _passCode.length == 0){
        NSLog(@"->ERROR：login Commit:phone-> %@ ,passCode-> %@ ,存在错误",_phoneNum,_passCode);
    }else{
        NSLog(@"login Commit:phone-> %@ ,passCode-> %@",_phoneNum,_passCode);
        NSDictionary *dic = @{@"username"  : _phoneNum,
                              @"password" : _passCode
                              };
//            /*testing*/
//            NSDictionary *dic = @{@"username"  : @"test",
//                                  @"password" : @"123456"
//                                  };
        [XSHttpTool POST:_loginURL param:dic success:^(id responseObject) {
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *userDic = [responseDic objectForKey:@"user"];
            NSString *token = [responseDic objectForKey:@"token"];
            NSLog(@"->登录返回userinfo：%@",userDic);
            NSLog(@"->登录返回token：%@",token);
            [self resolveData:userDic andWithToken:token];
        } failure:^(NSError *error) {
            RCPError(@"请求失败");
            if (!_logInBtn) {
                [self makeViewAppear];
            }
        }];
    }
}

#pragma mark -- 注册跳转
- (void)startRegister{
    RCRegisterViewController *regVC = [[RCRegisterViewController alloc]init];
    [self.navigationController pushViewController:regVC animated:YES];
}

#pragma mark -- 忘记密码跳转
-(void)startForget{
    RCForgetPassCodeViewController *forgetVC = [[RCForgetPassCodeViewController alloc]init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

#pragma mark -- 键盘处理->点击空白处键盘收起
- (void)keyboardGesture{
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

#pragma mark -- 登陆数据的持久化
- (void)dataPersistence:(NSString *)userId{
    saveLocal(RCPhoneNumber, _phoneTextField.text);
    saveLocal(RCPassCode, _passWordTextField.text);
    saveLocal(RCUserId, userId);
}

//点击空白处，键盘退下
- (void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [_phoneTextField resignFirstResponder];
    [_passWordTextField resignFirstResponder];
}

//点击return按钮时回调的方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //将键盘退下去
    [self.phoneTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    return YES;
}

//手机号码验证
- (BOOL) isValidateMobile:(NSString *)mobile{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

//md5
- (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str,  (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [ret appendFormat:@"%02x", result[i]];
    return ret;
}

@end
