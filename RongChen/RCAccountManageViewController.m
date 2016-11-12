//
//  RCAccountManageViewController.m
//  RongChen
//
//  Created by YingheSun on 16/10/23.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCAccountManageViewController.h"

@interface RCAccountManageViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong) UITextField *nameTextField;
@property(nonatomic,strong) UILabel *genderLabel;
@property(nonatomic,strong) UIView *mPoint;
@property(nonatomic,strong) UIView *fPoint;
@property(nonatomic,strong) UILabel *mLabel;
@property(nonatomic,strong) UILabel *fLabel;
@property(nonatomic,strong) UISegmentedControl *genderControl;

@property(nonatomic,strong) NSString *putInfoRequest;
@property(nonatomic,strong) NSString *gender;

@end

@implementation RCAccountManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *userIdStr = getLocalData(RCUserId)
    NSString *requestStr = [NSString stringWithFormat:@"userProfiles/%@",userIdStr];
    _putInfoRequest = requestStr;
    _gender = @"Male";
    [self setBarView];
    [self makeViewAppear];
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    self.navigationItem.title = @"个人信息";
}

#pragma mark -- 加载UI
- (void)makeViewAppear{
    self.navigationController.navigationBar.hidden = NO;
    
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    [self.view addSubview:nameLabel];
    [nameLabel.layer setCornerRadius:5.0f];
    [nameLabel setClipsToBounds:YES];
    nameLabel.text = @"昵称";
    nameLabel.userInteractionEnabled = NO;
    nameLabel.textColor = [UIColor lightGrayColor];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.mas_offset(RCScreenWidth * 0.1);
        make.top.equalTo(self.view).with.mas_offset(RCScreenHeight * 0.3);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.2);
    }];
    
    _nameTextField = [[UITextField alloc]init];
    [self.view addSubview:_nameTextField];
    [_nameTextField.layer setCornerRadius:5.0f];
    [_nameTextField setClipsToBounds:YES];
//    _nameTextField.placeholder = @"昵称";
    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _nameTextField.backgroundColor = [UIColor whiteColor];
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel.mas_right);
        make.top.equalTo(self.view).with.mas_offset(RCScreenHeight * 0.3);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.6);
    }];
    
    _genderLabel = [[UILabel alloc]init];
    [self.view addSubview:_genderLabel];
    [_genderLabel.layer setCornerRadius:5.0f];
    [_genderLabel setClipsToBounds:YES];
    _genderLabel.text = @"性别";
    _genderLabel.userInteractionEnabled = NO;
    _genderLabel.textColor = [UIColor lightGrayColor];
    [_genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_nameTextField.mas_bottom).with.mas_offset(RCScreenHeight * 0.01);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
    
    //    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"男",@"女",nil];
    //    //初始化UISegmentedControl
    //    _genderControl = [[UISegmentedControl alloc] initWithItems:segmentedArray];
    //    // 设置默认选择项索引
    //    _genderControl.selectedSegmentIndex = 0;
    //    _genderControl.tintColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    //    [self.view addSubview:_genderControl];
    //    [_genderControl  mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerY.equalTo(_genderLabel);
    //        make.right.equalTo(_genderLabel).with.mas_offset(-10);
    //        make.height.mas_equalTo(40);
    //        make.width.mas_equalTo(RCScreenWidth * 0.4);
    //    }];
    //
    //    [_genderControl addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    
    _fPoint = [[UIButton alloc]init];
    [self.view addSubview:_fPoint];
    _fPoint.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    _fPoint.layer.cornerRadius = 5;
    //添加点按击手势监听器
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(femaleClicked)];
    //设置手势属性
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired=1;//设置点按次数，为1
    tapGesture.numberOfTouchesRequired=1;//点按的手指数
    [_fPoint addGestureRecognizer:tapGesture];
    [_fPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_genderLabel);
        make.left.equalTo(_genderLabel).with.mas_offset(120);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(10);
    }];
    
    _fLabel = [[UILabel alloc]init];
    [self.view addSubview:_fLabel];
//    //添加点按击手势监听器
//    UITapGestureRecognizer *tapGesture1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(femaleClicked)];
//    //设置手势属性
//    tapGesture1.delegate = self;
//    tapGesture1.numberOfTapsRequired=1;//设置点按次数，为1
//    tapGesture1.numberOfTouchesRequired=1;//点按的手指数
//    [_fLabel addGestureRecognizer:tapGesture1];
    _fLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    _fLabel.text = @"男";
    [_fLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_fPoint);
        make.left.equalTo(_fPoint).with.mas_offset(15);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(50);
    }];
    
    _mPoint = [[UIButton alloc]init];
    [self.view addSubview:_mPoint];
    //添加点按击手势监听器
    UITapGestureRecognizer *tapGesture2=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maleClicked)];
    //设置手势属性
    tapGesture2.delegate = self;
    tapGesture2.numberOfTapsRequired=1;//设置点按次数，为1
    tapGesture2.numberOfTouchesRequired=1;//点按的手指数
    [_mPoint addGestureRecognizer:tapGesture2];
    _mPoint.backgroundColor = [UIColor lightGrayColor];
    _mPoint.layer.cornerRadius = 5;
    [_mPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_fPoint);
        make.left.equalTo(_fPoint).with.mas_offset(60);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(10);
    }];
    
    _mLabel = [[UILabel alloc]init];
    [self.view addSubview:_mLabel];
//    //添加点按击手势监听器
//    UITapGestureRecognizer *tapGesture3=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maleClicked)];
//    //设置手势属性
//    tapGesture3.delegate = self;
//    tapGesture3.numberOfTapsRequired=1;//设置点按次数，为1
//    tapGesture3.numberOfTouchesRequired=1;//点按的手指数
//    [_mLabel addGestureRecognizer:tapGesture3];
    _mLabel.textColor = [UIColor lightGrayColor];
    _mLabel.text = @"女";
    [_mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_fPoint);
        make.left.equalTo(_mPoint).with.mas_offset(15);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(50);
    }];
    
    UIButton *commitBtn = [[UIButton alloc]init];
    [self.view addSubview:commitBtn];
    [commitBtn setTitle:@"提  交" forState:UIControlStateNormal];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize: 22.0f];
    [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitBtn setBackgroundImage:[UIImage imageNamed:@"loginBtn"] forState:UIControlStateNormal];
    [commitBtn.layer setCornerRadius:5.0f];
    [commitBtn setClipsToBounds:YES];
    [commitBtn addTarget:self action:@selector(putRequest) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_genderLabel.mas_bottom).with.mas_offset(RCScreenHeight * 0.05);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(RCScreenWidth * 0.8);
    }];
}

#pragma mark - 提交请求
- (void)putRequest{
    NSDictionary *dic = @{@"realName"  : _nameTextField.text,
                          @"gender"  : _gender,
                          };
    [XSHttpTool PUT:_putInfoRequest param:dic success:^(id responseObject) {
        RCPSuccess(@"设置成功");
    } failure:^(NSError *error) {
        RCPError(@"设置失败");
    }];
}

//- (void)didClicksegmentedControlAction:(UISegmentedControl *)Seg{
//    NSInteger Index = Seg.selectedSegmentIndex;
//    NSLog(@"Index %li", (long)Index);
//    switch (Index) {
//        case 0:
//            _gender = @"Male";
//            break;
//        case 1:
//            _gender = @"Female";
//            break;
//    }
//}

- (void)maleClicked{
    _gender = @"Male";
    _mLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    _mPoint.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    _fPoint.backgroundColor = [UIColor lightGrayColor];
    _fLabel.textColor = [UIColor lightGrayColor];
}

- (void)femaleClicked{
    _gender = @"Female";
    _mLabel.textColor = [UIColor lightGrayColor];
    _mPoint.backgroundColor = [UIColor lightGrayColor];
    _fPoint.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    _fLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
}

@end
