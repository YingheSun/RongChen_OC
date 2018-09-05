//
//  RCStudyViewController.m
//  RongChen
//
//  Created by 孙滢贺 on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCStudyViewController.h"

@interface RCStudyViewController ()

@property (nonatomic ,strong) UITextField *PhoneField;
@property (nonatomic ,strong) UITextField *nameField;
@property (nonatomic ,strong) UITextField *idCardField;
@property (nonatomic ,strong) UIButton *commitBtn;

@property (nonatomic ,strong) NSString *userProfilesURL;
@property (nonatomic ,strong) NSString *requestURL;
@property (nonatomic ,strong) NSString *studiesListURL;

@end

@implementation RCStudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userProfilesURL = @"userProfiles";
    _requestURL = @"enroll";
    _studiesListURL = @"studies";
    [self setBarView];
//    [self showView];
}

- (void)viewWillAppear:(BOOL)animated{
    [self showView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setBarView{
    self.navigationItem.title = @"最新文章";
}

- (void)showView{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
//    [self requestForState];
}

#pragma mark - 网络请求
- (void)requestForState{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"user" : userId
                          };
    [XSHttpTool GET:_userProfilesURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *userinfoArr = responseDic[@"results"];
        NSLog(@"get userProfile success,user=> %@,states=> %@,info: %@",userId,userinfoArr[0][@"status"],responseDic);
        if ([userinfoArr[0][@"status"] isEqualToString:@"customer"]) {
            NSLog(@"需要注册！");
            [self makeSignUpViewAppearwithPhone:userinfoArr[0][@"mobile"]];
        }if ([userinfoArr[0][@"status"] isEqualToString:@"checking"]) {
            NSLog(@"审核中！");
            [self makeWaitingViewAppear];
        }else{
            [self requestForSubjects];
        }
    } failure:^(NSError *error) {
        RCPError(@"获取信息失败");
    }];
}

- (void)requestForSubjects{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"user" : userId
                          };
    [XSHttpTool GET:_studiesListURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *subjectArr = responseDic[@"results"];
        NSLog(@"get userStudiesList success,user=> %@,info: %@",userId,responseDic);
        [self makeDetailViewAppearwithInfo:subjectArr];
    } failure:^(NSError *error) {
        RCPError(@"获取信息失败");
    }];
}

- (void)commitRequest{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"mobile" : _PhoneField.text,
                          @"realName" : _nameField.text,
                          @"IDCard" : _idCardField.text
                          };
    [XSHttpTool POST:_requestURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"get userProfile success,user=> %@,mobile=> %@,name=> %@,id=> %@,info: %@",userId,_PhoneField.text,_nameField.text,_idCardField.text,responseDic);
        RCPSuccess(@"请求成功");
        [self clearSignUpViews];
        [self makeWaitingViewAppear];
    } failure:^(NSError *error) {
        RCPError(@"请求失败");
    }];
    
}

- (void)clearSignUpViews{
    [_PhoneField removeFromSuperview];
    [_nameField removeFromSuperview];
    [_idCardField removeFromSuperview];
    [_commitBtn removeFromSuperview];
}

- (void)makeSignUpViewAppearwithPhone:(NSString *)phoneNum{
    _PhoneField = [[UITextField alloc]init];
    [self.view addSubview:_PhoneField];
    [_PhoneField.layer setCornerRadius:5.0f];
    [_PhoneField setClipsToBounds:YES];
    _PhoneField.placeholder = @"手机号码";
    _PhoneField.text = phoneNum;
    _PhoneField.userInteractionEnabled = NO;
    _PhoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _PhoneField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _PhoneField.backgroundColor = [UIColor whiteColor];
    [_PhoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).with.mas_offset(RCScreenHeight * 0.2);
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
    
    _idCardField = [[UITextField alloc]init];
    [self.view addSubview:_idCardField];
    [_idCardField.layer setCornerRadius:5.0f];
    [_idCardField setClipsToBounds:YES];
    _idCardField.placeholder = @"身份证号码";
    _idCardField.backgroundColor = [UIColor whiteColor];
    [_idCardField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_nameField.mas_bottom).with.mas_offset(RCScreenHeight * 0.01);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
    _commitBtn = [[UIButton alloc]init];
    [self.view addSubview:_commitBtn];
    [_commitBtn setTitle:@"我 要 报 名" forState:UIControlStateNormal];
    _commitBtn.titleLabel.font = [UIFont systemFontOfSize: 22.0f];
    [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_commitBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [_commitBtn.layer setCornerRadius:5.0f];
    [_commitBtn setClipsToBounds:YES];
    [_commitBtn addTarget:self action:@selector(commitRequest) forControlEvents:UIControlEventTouchUpInside];
    [_commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_idCardField.mas_bottom).with.mas_offset(RCScreenHeight * 0.05);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
}

- (void)makeWaitingViewAppear{
    
    UIView *stateView = [[UIView alloc]init];
    stateView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:stateView];
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(75);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.width.equalTo(self.view);
    }];
    
    UILabel *stateTitle = [[UILabel alloc]init];
    stateTitle.text = @"目前状态:";
    stateTitle.textAlignment = NSTextAlignmentLeft;
    stateTitle.textColor = [UIColor lightGrayColor];
    [self.view addSubview:stateTitle];
    [stateTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(stateView).with.offset(10);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.centerY.equalTo(stateView);
    }];
    
    UILabel *stateDetail = [[UILabel alloc]init];
    stateDetail.textAlignment = NSTextAlignmentRight;
    stateDetail.text = @"审核中";
    [self.view addSubview:stateDetail];
    [stateDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(stateView).with.offset(-10);
        make.width.mas_equalTo(RCScreenWidth - 100);
        make.height.mas_equalTo(50);
        make.centerY.equalTo(stateView);
    }];
    
}

- (void)makeDetailViewAppearwithInfo:(NSArray *)subjectInfo{
    
    UIView *stateView = [[UIView alloc]init];
    stateView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:stateView];
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(75);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(50);
        make.width.equalTo(self.view);
    }];
    
    UILabel *stateTitle = [[UILabel alloc]init];
    stateTitle.text = @"目前状态:";
    stateTitle.textAlignment = NSTextAlignmentLeft;
    stateTitle.textColor = [UIColor lightGrayColor];
    [self.view addSubview:stateTitle];
    [stateTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(stateView).with.offset(10);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.centerY.equalTo(stateView);
    }];
    
    UILabel *stateDetail = [[UILabel alloc]init];
    stateDetail.textAlignment = NSTextAlignmentRight;
    stateDetail.text = @"审核通过，未开始学习";
    [self.view addSubview:stateDetail];
    [stateDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(stateView).with.offset(-10);
        make.width.mas_equalTo(RCScreenWidth - 100);
        make.height.mas_equalTo(50);
        make.centerY.equalTo(stateView);
    }];
    
    
    //    //教练信息
    //    UIView *coachView = [[UIView alloc]init];
    //    coachView.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:coachView];
    //    [coachView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(subject4View.mas_bottom).with.offset(10);
    //        make.centerX.equalTo(self.view);
    //        make.height.mas_equalTo(50);
    //        make.width.equalTo(self.view);
    //    }];
    //
    //    UILabel *coachTitle = [[UILabel alloc]init];
    //    coachTitle.text = @"教练姓名:";
    //    coachTitle.textAlignment = NSTextAlignmentLeft;
    //    coachTitle.textColor = [UIColor lightGrayColor];
    //    [self.view addSubview:coachTitle];
    //    [coachTitle mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(coachView);
    //        make.width.mas_equalTo(100);
    //        make.height.mas_equalTo(50);
    //        make.centerY.equalTo(coachView);
    //    }];
    //
    //    UILabel *coachDetail = [[UILabel alloc]init];
    //    [self.view addSubview:coachDetail];
    //    [coachDetail mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.equalTo(coachView);
    //        make.width.mas_equalTo(RCScreenWidth - 100);
    //        make.height.mas_equalTo(50);
    //        make.centerY.equalTo(coachView);
    //    }];
    //
    //    UIView *phoneView = [[UIView alloc]init];
    //    phoneView.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:phoneView];
    //    [phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(coachView.mas_bottom).with.offset(1);
    //        make.centerX.equalTo(self.view);
    //        make.height.mas_equalTo(50);
    //        make.width.equalTo(self.view);
    //    }];
    //
    //    UILabel *phoneTitle = [[UILabel alloc]init];
    //    phoneTitle.text = @"电话号码:";
    //    phoneTitle.textAlignment = NSTextAlignmentLeft;
    //    phoneTitle.textColor = [UIColor lightGrayColor];
    //    [self.view addSubview:phoneTitle];
    //    [phoneTitle mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(phoneView);
    //        make.width.mas_equalTo(100);
    //        make.height.mas_equalTo(50);
    //        make.centerY.equalTo(phoneView);
    //    }];
    //
    //    UILabel *phoneDetail = [[UILabel alloc]init];
    //    [self.view addSubview:phoneDetail];
    //    [phoneDetail mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.equalTo(phoneView);
    //        make.width.mas_equalTo(RCScreenWidth - 100);
    //        make.height.mas_equalTo(50);
    //        make.centerY.equalTo(phoneView);
    //    }];
    //
    //    UIView *appointmentView = [[UIView alloc]init];
    //    appointmentView.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:appointmentView];
    //    [appointmentView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(phoneView.mas_bottom).with.offset(1);
    //        make.centerX.equalTo(self.view);
    //        make.height.mas_equalTo(50);
    //        make.width.equalTo(self.view);
    //    }];
    //
    //    UILabel *appointmentTitle = [[UILabel alloc]init];
    //    appointmentTitle.text = @"预约时间:";
    //    appointmentTitle.textAlignment = NSTextAlignmentLeft;
    //    appointmentTitle.textColor = [UIColor lightGrayColor];
    //    [self.view addSubview:appointmentTitle];
    //    [appointmentTitle mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(appointmentView);
    //        make.width.mas_equalTo(100);
    //        make.height.mas_equalTo(50);
    //        make.centerY.equalTo(appointmentView);
    //    }];
    //
    //    UILabel *appointmentDetail = [[UILabel alloc]init];
    //    [self.view addSubview:appointmentDetail];
    //    [appointmentDetail mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.equalTo(appointmentView);
    //        make.width.mas_equalTo(RCScreenWidth - 100);
    //        make.height.mas_equalTo(50);
    //        make.centerY.equalTo(appointmentView);
    //    }];
    
    for (int i = 0; i < subjectInfo.count ; i++) {
        UIView *subject1View = [[UIView alloc]init];
        subject1View.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:subject1View];
        [subject1View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(stateView.mas_bottom).with.offset(10);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(50);
            make.width.equalTo(self.view);
        }];
        
        UILabel *subject1Title = [[UILabel alloc]init];
        if(subjectInfo[0][@"itemName"]){
            subject1Title.text = subjectInfo[0][@"itemName"];
        }
        subject1Title.textAlignment = NSTextAlignmentLeft;
        subject1Title.textColor = [UIColor lightGrayColor];
        [self.view addSubview:subject1Title];
        [subject1Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(subject1View).with.offset(10);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject1View);
        }];
        
        UILabel *subject1Detail = [[UILabel alloc]init];
        subject1Detail.textAlignment = NSTextAlignmentRight;
        subject1Detail.text = @"未开始";
        [self.view addSubview:subject1Detail];
        [subject1Detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(subject1View).with.offset(-10);
            make.width.mas_equalTo(RCScreenWidth - 100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject1View);
        }];
        
        UIView *subject2View = [[UIView alloc]init];
        subject2View.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:subject2View];
        [subject2View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(subject1View.mas_bottom).with.offset(1);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(50);
            make.width.equalTo(self.view);
        }];
        
        UILabel *subject2Title = [[UILabel alloc]init];
        if(subjectInfo[1][@"itemName"]){
            subject2Title.text = subjectInfo[1][@"itemName"];
        }
        subject2Title.textAlignment = NSTextAlignmentLeft;
        subject2Title.textColor = [UIColor lightGrayColor];
        [self.view addSubview:subject2Title];
        [subject2Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(subject2View).with.offset(10);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject2View);
        }];
        
        UILabel *subject2Detail = [[UILabel alloc]init];
        subject2Detail.textAlignment = NSTextAlignmentRight;
        subject2Detail.text = @"未开始";
        [self.view addSubview:subject2Detail];
        [subject2Detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(subject2View).with.offset(-10);
            make.width.mas_equalTo(RCScreenWidth - 100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject2View);
        }];
        
        UIView *subject3View = [[UIView alloc]init];
        subject3View.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:subject3View];
        [subject3View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(subject2View.mas_bottom).with.offset(1);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(50);
            make.width.equalTo(self.view);
        }];
        
        UILabel *subject3Title = [[UILabel alloc]init];
        if(subjectInfo[2][@"itemName"]){
            subject3Title.text = subjectInfo[2][@"itemName"];
        }
        subject3Title.textAlignment = NSTextAlignmentLeft;
        subject3Title.textColor = [UIColor lightGrayColor];
        [self.view addSubview:subject3Title];
        [subject3Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(subject3View).with.offset(10);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject3View);
        }];
        
        UILabel *subject3Detail = [[UILabel alloc]init];
        subject3Detail.textAlignment = NSTextAlignmentRight;
        subject3Detail.text = @"未开始";
        [self.view addSubview:subject3Detail];
        [subject3Detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(subject3View).with.offset(-10);
            make.width.mas_equalTo(RCScreenWidth - 100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject3View);
        }];
        
        UIView *subject4View = [[UIView alloc]init];
        if( i == 3 ){
        subject4View.backgroundColor = [UIColor whiteColor];
        }
        [self.view addSubview:subject4View];
        [subject4View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(subject3View.mas_bottom).with.offset(1);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(50);
            make.width.equalTo(self.view);
        }];
        
        UILabel *subject4Title = [[UILabel alloc]init];
        if(i == 3){
            subject4Title.text = subjectInfo[3][@"itemName"];
        }
        subject4Title.textAlignment = NSTextAlignmentLeft;
        subject4Title.textColor = [UIColor lightGrayColor];
        [self.view addSubview:subject4Title];
        [subject4Title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(subject4View).with.offset(10);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject4View);
        }];
        
        UILabel *subject4Detail = [[UILabel alloc]init];
        subject4Detail.textAlignment = NSTextAlignmentRight;
        if(i == 3){
        subject4Detail.text = @"未开始";
        }
        [self.view addSubview:subject4Detail];
        [subject4Detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(subject4View).with.offset(-10);
            make.width.mas_equalTo(RCScreenWidth - 100);
            make.height.mas_equalTo(50);
            make.centerY.equalTo(subject4View);
        }];

        if ([subjectInfo[i][@"status"] isEqualToString:@"wait"]) {
            NSLog(@"%@ is unDone set default text<未开始> at step: => %@",subjectInfo[i][@"itemName"],subjectInfo[i][@"step"]);
        }else{
            long step = [subjectInfo[i][@"step"] integerValue];
            switch (step) {
                case 1:
                    if([subjectInfo[i][@"status"] isEqualToString:@"start"]){
                        stateDetail.text = subjectInfo[i][@"itemName"];
                    }
                    if ([subjectInfo[i][@"status"] isEqualToString:@"start"]) {
                        subject1Detail.text = @"学习中";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"fail"]) {
                        subject1Detail.text = @"失败";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"pass"]) {
                        subject1Detail.text = @"通过";
                    }
                    break;
                case 2:
                    if([subjectInfo[i][@"status"] isEqualToString:@"start"]){
                        stateDetail.text = subjectInfo[i][@"itemName"];
                    }
                    if ([subjectInfo[i][@"status"] isEqualToString:@"start"]) {
                        subject2Detail.text = @"学习中";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"fail"]) {
                        subject2Detail.text = @"失败";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"pass"]) {
                        subject2Detail.text = @"通过";
                    }
                    break;
                case 3:
                    if([subjectInfo[i][@"status"] isEqualToString:@"start"]){
                        stateDetail.text = subjectInfo[i][@"itemName"];
                    }
                    if ([subjectInfo[i][@"status"] isEqualToString:@"start"]) {
                        subject3Detail.text = @"学习中";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"fail"]) {
                        subject3Detail.text = @"失败";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"pass"]) {
                        subject3Detail.text = @"通过";
                    }
                    break;
                case 4:
                    stateDetail.text = subjectInfo[i][@"itemName"];
                    if ([subjectInfo[i][@"status"] isEqualToString:@"start"]) {
                        subject4Detail.text = @"学习中";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"fail"]) {
                        subject4Detail.text = @"失败";
                    }else if ([subjectInfo[i][@"status"] isEqualToString:@"pass"]) {
                        subject4Detail.text = @"通过";
                    }
                    break;
                default:
                    break;
            }
        }
    }
}

@end
