//
//  RCForgetPassCodeViewController.m
//  RongChen
//
//  Created by 孙滢贺 on 16/9/29.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCForgetPassCodeViewController.h"
#import "MainTabBarController.h"
#import<CommonCrypto/CommonDigest.h>

@interface RCForgetPassCodeViewController ()

@property(nonatomic,strong) NSString *phoneNum;
@property(nonatomic,strong) NSString *passCode;
@property(nonatomic,strong) NSString *msgCode;
@property(nonatomic,strong) NSString *token;

@property(nonatomic,strong) UITextField *phoneTextField;
@property(nonatomic,strong) UITextField *messageTextField;
@property(nonatomic,strong) UITextField *passWordTextField;
@property(nonatomic,strong) UIButton *sendMsgBtn;

@property(nonatomic,strong) NSString *sendMsgURL;
@property(nonatomic,strong) NSString *changePassCodeURL;

@end

@implementation RCForgetPassCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBarView];
    [self makeViewAppear];
    _sendMsgURL = @"mobile/verifycode";
    _changePassCodeURL = @"reset_password";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    self.navigationItem.title = @"修改密码";
}

#pragma mark -- 加载UI
- (void)makeViewAppear{
    self.navigationController.navigationBar.hidden = NO;
    
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    _phoneTextField = [[UITextField alloc]init];
    [self.view addSubview:_phoneTextField];
    [_phoneTextField.layer setCornerRadius:5.0f];
    [_phoneTextField setClipsToBounds:YES];
    _phoneTextField.placeholder = @"手机号码";
    _phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _phoneTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _phoneTextField.backgroundColor = [UIColor whiteColor];
    [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.mas_offset(RCScreenHeight * 0.3);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
    _messageTextField = [[UITextField alloc]init];
    [self.view addSubview:_messageTextField];
    [_messageTextField.layer setCornerRadius:5.0f];
    [_messageTextField setClipsToBounds:YES];
    _messageTextField.placeholder = @"验证码";
    _messageTextField.backgroundColor = [UIColor whiteColor];
    [_messageTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_phoneTextField.mas_bottom).with.mas_offset(RCScreenHeight * 0.01);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
    _sendMsgBtn = [[UIButton alloc]init];
    [self.view addSubview:_sendMsgBtn];
    [_sendMsgBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    _sendMsgBtn.titleLabel.font = [UIFont systemFontOfSize: 18.0f];
    [_sendMsgBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendMsgBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [_sendMsgBtn.layer setCornerRadius:5.0f];
    [_sendMsgBtn setClipsToBounds:YES];
    [_sendMsgBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [_sendMsgBtn  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_messageTextField);
        make.right.equalTo(_messageTextField).with.mas_offset(-10);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(RCScreenWidth * 0.3);
    }];
    
    _passWordTextField = [[UITextField alloc]init];
    [self.view addSubview:_passWordTextField];
    [_passWordTextField.layer setCornerRadius:5.0f];
    [_passWordTextField setClipsToBounds:YES];
    _passWordTextField.placeholder = @"新密码";
    _passWordTextField.secureTextEntry = YES; //密码
    _passWordTextField.backgroundColor = [UIColor whiteColor];
    [_passWordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_messageTextField.mas_bottom).with.mas_offset(RCScreenHeight * 0.01);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
    UIButton *commitBtn = [[UIButton alloc]init];
    [self.view addSubview:commitBtn];
    [commitBtn setTitle:@"更 改 密 码" forState:UIControlStateNormal];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize: 22.0f];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [commitBtn.layer setCornerRadius:5.0f];
    [commitBtn setClipsToBounds:YES];
    [commitBtn addTarget:self action:@selector(commitRequest) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_passWordTextField.mas_bottom).with.mas_offset(RCScreenHeight * 0.05);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
}

#pragma mark - 获取验证码
- (void)sendMessage{
    if (_phoneTextField.text.length == 0) {
        RCPError(@"请输入手机号");
    }else{
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
}


#pragma mark - 提交请求
- (void)commitRequest{
    [self resolvePhoneValidation];
    [self resolvePassword];
    if(_phoneNum.length == 0 || _passCode.length == 0 || _messageTextField.text.length == 0){
        NSLog(@"->ERROR：login Commit:phone-> %@ ,passCode-> %@ ,存在错误",_phoneNum,_passCode);
    }else{
        NSLog(@"login Commit:phone-> %@ ,passCode-> %@",_phoneNum,_passCode);
        NSDictionary *dic = @{@"mobile"  : _phoneNum,
                              @"verifyCode"  : _messageTextField.text,
                              @"password" : _passCode
                              };
        [XSHttpTool POST:_changePassCodeURL param:dic success:^(id responseObject) {
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
    RCPSuccess(@"修改成功");
    [self.navigationController popToRootViewControllerAnimated:YES];
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
