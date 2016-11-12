//
//  RCRegisterViewController.m
//  RongChen
//
//  Created by YingheSun on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCRegisterViewController.h"
#import<CommonCrypto/CommonDigest.h>
#import "MainTabBarController.h"

@interface RCRegisterViewController ()

@property(nonatomic,strong) NSString *phoneNum;
@property(nonatomic,strong) NSString *passCode;
@property(nonatomic,strong) NSString *msgCode;
@property(nonatomic,strong) NSString *token;

@property(nonatomic,strong) UITextField *phoneTextField;
@property(nonatomic,strong) UITextField *messageTextField;
@property(nonatomic,strong) UITextField *passWordTextField;
@property(nonatomic,strong) UIButton *sendMsgBtn;
@property(nonatomic,strong) UIButton *registBtn;
@property(nonatomic,strong) UIButton *backBtn;

@property(nonatomic,strong) NSString *registURL;
@property(nonatomic,strong) NSString *sendMsgURL;

@end

@implementation RCRegisterViewController
@synthesize phoneTextField = _phoneTextField;
@synthesize messageTextField = _messageTextField;
@synthesize passWordTextField = _passWordTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeViewAppear];
    _sendMsgURL = @"mobile/verifycode";
    _registURL = @"mobile/register";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- 加载UI
- (void)makeViewAppear{
    self.navigationController.navigationBar.hidden = YES;
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
    
    //back button
    UIImageView *backImage = [[UIImageView alloc]init];
    backImage.image = [UIImage imageNamed:@"back"];
    [self.view addSubview:backImage];
    [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0.05 * RCScreenHeight);
        make.left.equalTo(self.view).with.offset(25);
        make.height.mas_equalTo(27);
        make.width.mas_equalTo(15);
    }];
    
    UIButton *backButton = [[UIButton alloc]init];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0.05 * RCScreenHeight);
        make.left.equalTo(self.view).with.offset(20);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
    
    //phoneArea
    UIView *phoneArea = [[UIView alloc]init];
    [self.view addSubview:phoneArea];
    [phoneArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(0.3 * RCScreenHeight);
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
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(phoneArea);
        make.left.equalTo(phoneLeftV).with.offset(40);
        make.right.equalTo(phoneArea);
        make.height.mas_equalTo(50);
    }];
    
    //messageArea
    UIView *messageArea = [[UIView alloc]init];
    [self.view addSubview:messageArea];
    [messageArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneArea).with.offset(0.1 * RCScreenHeight);
        make.left.equalTo(self.view).with.offset(25);
        make.height.mas_equalTo(61);
        make.width.mas_equalTo(RCScreenWidth - 60);
    }];
    
    UIView *lineView2 = [[UIView alloc]init];
    [self.view addSubview:lineView2];
    lineView2.backgroundColor = [UIColor whiteColor];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(messageArea);
        make.height.mas_equalTo(1);
        make.width.equalTo(messageArea);
        make.centerX.equalTo(messageArea);
    }];
    
    UIImageView *messageLeftV = [[UIImageView alloc]init];
    [self.view addSubview:messageLeftV];
    messageLeftV.image = [UIImage imageNamed:@"验证码"];
    [messageLeftV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(messageArea).with.offset(5);
        make.centerY.equalTo(messageArea);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(24);
    }];
    
    _sendMsgBtn = [[UIButton alloc]init];
    [_sendMsgBtn.layer setCornerRadius:10.0f];
    [_sendMsgBtn setClipsToBounds:YES];
    [_sendMsgBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    _sendMsgBtn.titleLabel.font = [UIFont systemFontOfSize: 15.0f];
    [_sendMsgBtn setTitleColor:[UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1] forState:UIControlStateNormal];
    [_sendMsgBtn setBackgroundImage:[UIImage imageNamed:@"msgBtn"] forState:UIControlStateNormal];
    [_sendMsgBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sendMsgBtn];
    [_sendMsgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(messageArea);
        make.width.mas_equalTo(RCScreenWidth * 0.3);
        make.right.equalTo(messageArea);
        make.height.mas_equalTo(40);
    }];
    
    _messageTextField = [[UITextField alloc]init];
    [self.view addSubview:_messageTextField];
    _messageTextField.placeholder = @"请输入验证码"; //默认显示的字
    _messageTextField.textColor = [UIColor whiteColor];
    _messageTextField.keyboardType = UIKeyboardTypeNumberPad;
    _messageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_messageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(messageArea);
        make.left.equalTo(messageLeftV).with.offset(40);
        make.right.equalTo(_sendMsgBtn.mas_left);
        make.height.mas_equalTo(50);
    }];
    
    //password
    UIView *passArea = [[UIView alloc]init];
    [self.view addSubview:passArea];
    [passArea mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageArea).with.offset(0.1 * RCScreenHeight);
        make.left.equalTo(self.view).with.offset(25);
        make.height.mas_equalTo(61);
        make.width.mas_equalTo(RCScreenWidth - 60);
    }];
    
    UIView *lineView3 = [[UIView alloc]init];
    [self.view addSubview:lineView3];
    lineView3.backgroundColor = [UIColor whiteColor];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
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
    _registBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:_registBtn];
    [_registBtn setTitle:@"注 册" forState:UIControlStateNormal];
    _registBtn.titleLabel.font = [UIFont systemFontOfSize: 22.0f];
    [_registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [_registBtn.layer setCornerRadius:5.0f];
    [_registBtn setClipsToBounds:YES];
    [_registBtn addTarget:self action:@selector(commitRequest) forControlEvents:UIControlEventTouchUpInside];
    [_registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passArea).with.offset(0.12 * RCScreenHeight);
        make.width.equalTo(passArea);
        make.centerX.equalTo(passArea);
        make.height.mas_equalTo(50);
    }];
    
    //login at moment
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_backBtn];
    [_backBtn setTitle:@"立即登陆" forState:UIControlStateNormal];
    _backBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_registBtn.mas_bottom).with.offset(10);
        make.width.mas_equalTo(100);
        make.right.equalTo(_registBtn);
        make.height.mas_equalTo(20);
    }];
    
}

- (void)backButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 获取验证码
- (void)sendMessage{
    [self resolvePhoneValidation];
    NSDictionary *dic = @{@"mobile"  : _phoneTextField.text,
                          };
    [XSHttpTool GET:_sendMsgURL param:dic success:^(id responseObject) {
        RCPSuccess(@"发送成功");
        NSLog(@"->发送短信成功。");
    } failure:^(NSError *error) {
        RCPError(@"请求失败");
    }];
    
}

#pragma mark - 提交请求
- (void)commitRequest{
    [self resolvePhoneValidation];
    [self resolvePassword];
    if(_phoneNum.length == 0 || _passCode.length == 0 || _messageTextField.text.length == 0){
        NSLog(@"->ERROR：login Commit:phone-> %@ ,passCode-> %@ ,存在错误",_phoneNum,_passCode);
    }else{
        NSLog(@"login Commit:phone-> %@ ,passCode-> %@ msg->%@",_phoneNum,_passCode,_messageTextField.text);
        NSDictionary *dics = @{@"mobile" : _phoneNum,
                              @"verifyCode" : _messageTextField.text,
                              @"password" : _passCode,
                              };
        [XSHttpTool POST:_registURL param:dics success:^(id responseObject) {
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *userDic = [responseDic objectForKey:@"user"];
            NSString *token = [responseDic objectForKey:@"token"];
            NSLog(@"->登录返回userinfo：%@",userDic);
            NSLog(@"->登录返回token：%@",token);
            [self resolveData:userDic andWithToken:token];
        } failure:^(NSError *error) {
            RCPError(@"请求失败");
        }];
    }
}

#pragma mark - 成功，跳转
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

#pragma mark -- 登陆数据的持久化
- (void)dataPersistence:(NSString *)userId{
    saveLocal(RCPhoneNumber, _phoneTextField.text);
    saveLocal(RCPassCode, _passWordTextField.text);
    saveLocal(RCUserId, userId);
}

#pragma mark -- 处理密码，数据加密
- (void)resolvePassword{
    if(_phoneNum.length == 0){
        NSLog(@"->phoneNum is invalid!!!");
    }else if(_passWordTextField.text.length < 6){
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

//点击空白处，键盘退下
- (void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [_phoneTextField resignFirstResponder];
    [_messageTextField resignFirstResponder];
    [_passWordTextField resignFirstResponder];
}

//点击return按钮时回调的方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //将键盘退下去
    return YES;
}

#pragma mark -- 键盘处理->点击空白处键盘收起
- (void)keyboardGesture{
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
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
