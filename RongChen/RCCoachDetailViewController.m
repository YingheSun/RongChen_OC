//
//  RCCoachDetailViewController.m
//  RongChen
//
//  Created by YingheSun on 16/10/13.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCCoachDetailViewController.h"

@interface RCCoachDetailViewController ()

@property (nonatomic ,strong) UIScrollView *coachCommentsScrollView;

@property (nonatomic ,strong) UITextField *commentField;
@property (nonatomic ,strong) UIView *bottomView;
@property (nonatomic ,strong) UIView *rewardView;

@property (nonatomic ,strong) UIButton *reward1Btn;
@property (nonatomic ,strong) UIButton *reward2Btn;
@property (nonatomic ,strong) UIButton *reward3Btn;
@property (nonatomic ,strong) UIButton *rewardCancelBtn;

@property (nonatomic ,strong) NSString *commentsURL;
@property (nonatomic ,strong) NSString *rewardURL;

@end

@implementation RCCoachDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _commentsURL = @"coachComments";
    _rewardURL = @"tip/transaction";
    self.title = self.coachInfo.name;
    [self makeCoachDetailShow];
//    [self keyboardGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

- (void)makeCoachDetailShow{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    //上面的不动区域
    UIView *coachView = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, RCScreenWidth, 150)];
    coachView.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [self.view addSubview:coachView];
    
    UIImageView *coachImage = [[UIImageView alloc]init];
    coachImage.layer.cornerRadius = 50.0f;
    [coachImage setClipsToBounds:YES];
    NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,self.coachInfo.avatar,@"@!mobile"];
    [coachImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"HeadIcon"]];
    [coachView addSubview:coachImage];
    [coachImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(coachView).with.mas_offset(12);
        make.centerX.equalTo(coachView);
        make.height.mas_equalTo(100);
        make.width.mas_equalTo(100);
    }];
    
    UIView *recommendView = [[UIView alloc]init];
    recommendView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:recommendView];
    [recommendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(coachView.mas_bottom);
        make.centerX.equalTo(coachView);
        make.height.mas_equalTo(100);
        make.width.mas_equalTo(RCScreenWidth);
    }];
    
    UILabel *recommendTitle = [[UILabel alloc]init];
    [recommendView addSubview:recommendTitle];
    recommendTitle.text = @"简介:";
    recommendTitle.textAlignment = NSTextAlignmentLeft;
    [recommendTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(coachView.mas_bottom).with.offset(5);
        make.centerX.equalTo(coachView);
        make.left.equalTo(coachView).with.offset(10);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(RCScreenWidth);
    }];
    
    UILabel *recommendDetail = [[UILabel alloc]init];
    [recommendView addSubview:recommendDetail];
    recommendDetail.text = self.coachInfo.intro;
    recommendDetail.textAlignment = NSTextAlignmentLeft;
    recommendDetail.textColor = [UIColor lightGrayColor];
    recommendDetail.numberOfLines = 4;
    [recommendDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(recommendTitle.mas_bottom);
        make.centerX.equalTo(recommendView);
        make.left.equalTo(coachView).with.offset(10);
        make.bottom.equalTo(recommendView.mas_bottom);
        make.width.mas_equalTo(RCScreenWidth);
    }];
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, RCScreenHeight - 50, RCScreenWidth, 50)];
    //    bottomView.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [self.view addSubview:_bottomView];
    
    _commentField = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, RCScreenWidth - 100, 30)];
    _commentField.layer.cornerRadius = 5.0f;
    _commentField.backgroundColor = [UIColor whiteColor];
    [_commentField setClipsToBounds:YES];
    [_bottomView addSubview:_commentField];
    
    UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(RCScreenWidth - 80, 10, 30, 30)];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"发送"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendCommentAndResign) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:sendBtn];
    
    UIButton *rewardBtn = [[UIButton alloc]initWithFrame:CGRectMake(RCScreenWidth - 40, 10, 27, 30)];
    [rewardBtn setBackgroundImage:[UIImage imageNamed:@"打赏"] forState:UIControlStateNormal];
    [rewardBtn addTarget:self action:@selector(rewardToCoach) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:rewardBtn];
    
    _coachCommentsScrollView = [[UIScrollView alloc]init];
    [self.view addSubview:_coachCommentsScrollView];
    [_coachCommentsScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(recommendView.mas_bottom);
        make.bottom.equalTo(_bottomView.mas_top);
        make.width.mas_equalTo(RCScreenWidth);
    }];
    
    [self getcoachComments];
}

- (void)rewardToCoach{
    _rewardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, 50)];
    _rewardView.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [_bottomView addSubview:_rewardView];
    
    _reward1Btn = [[UIButton alloc]init];
    [_reward1Btn setTitle:@"20元" forState:UIControlStateNormal];
    [_reward1Btn.layer setCornerRadius:2.0];
    [_reward1Btn.layer setBorderWidth:1.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 1, 1, 1 });
    [_reward1Btn.layer setBorderColor:colorref];
    _reward1Btn.tag = 20;
    [_reward1Btn addTarget:self action:@selector(rewardCoachwithTips:) forControlEvents:UIControlEventTouchUpInside];
    [_rewardView addSubview:_reward1Btn];
    [_reward1Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_rewardView);
        make.left.equalTo(_rewardView).with.mas_offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(RCScreenWidth / 5);
    }];
    
    _reward2Btn = [[UIButton alloc]init];
    [_reward2Btn setTitle:@"50元" forState:UIControlStateNormal];
    _reward2Btn.tag = 50;
    [_reward2Btn addTarget:self action:@selector(rewardCoachwithTips:) forControlEvents:UIControlEventTouchUpInside];
    [_reward2Btn.layer setCornerRadius:2.0];
    [_reward2Btn.layer setBorderWidth:1.0]; //边框宽度
    [_reward2Btn.layer setBorderColor:colorref];
    [_rewardView addSubview:_reward2Btn];
    [_reward2Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_rewardView);
        make.left.equalTo(_reward1Btn.mas_right).with.mas_offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(RCScreenWidth / 5);
    }];
    
    _reward3Btn = [[UIButton alloc]init];
    [_reward3Btn setTitle:@"100元" forState:UIControlStateNormal];
    _reward3Btn.tag = 100;
    [_reward3Btn addTarget:self action:@selector(rewardCoachwithTips:) forControlEvents:UIControlEventTouchUpInside];
    [_reward3Btn.layer setCornerRadius:2.0];
    [_reward3Btn.layer setBorderWidth:1.0]; //边框宽度
    [_reward3Btn.layer setBorderColor:colorref];
    [_rewardView addSubview:_reward3Btn];
    [_reward3Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_rewardView);
        make.left.equalTo(_reward2Btn.mas_right).with.mas_offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(RCScreenWidth / 5);
    }];
    
    _rewardCancelBtn = [[UIButton alloc]init];
    [_rewardCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_rewardCancelBtn addTarget:self action:@selector(cancelReward) forControlEvents:UIControlEventTouchUpInside];
    [_rewardView addSubview:_rewardCancelBtn];
    [_rewardCancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_rewardView);
        make.right.equalTo(_rewardView.mas_right).with.mas_offset(-10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(RCScreenWidth / 5);
    }];
    
}

- (void)rewardCoachwithTips:(UIButton *)tipsBtn{
    NSString *userStr = getLocalData(RCUserId);
    NSString *score = [NSString stringWithFormat:@"%ld",(long)tipsBtn.tag];
    NSDictionary *dic = @{
                          @"coachId" : self.coachInfo.id,
                          @"score" : score,
                          @"userId" : userStr,
                          };
    [XSHttpTool POST:_rewardURL param:dic success:^(id responseObject) {
        RCPSuccess(@"成功打赏教练");
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void)cancelReward{
    [_rewardView removeFromSuperview];
}

- (void)sendCommentAndResign{
    _bottomView.frame = CGRectMake(0, RCScreenHeight - 50, RCScreenWidth, 50);
    [self deallocNotifation];
    [_commentField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self sendComment];
}

- (void)sendComment{
    NSString *userStr = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"coach" : self.coachInfo.id,
                          @"star" : @"1",
                          @"user" : userStr,
                          @"content": _commentField.text
                          };
    [XSHttpTool POST:_commentsURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"-> info: %@",responseDic);
        [self getcoachComments];
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)getcoachComments{
    NSDictionary *dic = @{
                          @"coach" : self.coachInfo.id
                          };
    [XSHttpTool GET:_commentsURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsArr = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条评论,info: %@",resultNum,resultsArr);
        [self makeCommentViewShow:resultsArr];
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)makeCommentViewShow:(NSArray *)commentsArr{
    [_coachCommentsScrollView clearsContextBeforeDrawing];
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, RCScreenWidth, 20)];
    titleView.backgroundColor = [UIColor whiteColor];
    [_coachCommentsScrollView addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, RCScreenWidth, 20)];
    titleLabel.text = @"学员评价";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleView addSubview:titleLabel];
    
    for (int i = 0; i < commentsArr.count; i++) {
        
        UIView *commView = [[UIView alloc] init];
        commView.frame = CGRectMake(0, 100 * i + 25, RCScreenWidth, 97);
        commView.backgroundColor = [UIColor whiteColor];
        [_coachCommentsScrollView addSubview:commView];
        
        UIImageView *coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(10 , 5, 40, 40)];
        [commView addSubview:coverImage];
        if([commentsArr[i][@"coverImage"] isEqualToString:@""]){
            [coverImage setImage:[UIImage imageNamed:@"HeadIcon"]];
        }else{
            NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,commentsArr[i][@"coverImage"],@"@!large"];
            [coverImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"HeadIcon"]];
        }
        coverImage.layer.cornerRadius = 20.0f;
        [coverImage setClipsToBounds:YES];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 150, 20)];
        titleLabel.text = commentsArr[i][@"userName"];
        titleLabel.font = [UIFont systemFontOfSize:18.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [commView addSubview:titleLabel];
        
        UILabel *commentView = [[UILabel alloc]initWithFrame:CGRectMake(10 , 45, RCScreenWidth, 55)];
        commentView.text = commentsArr[i][@"content"];
        commentView.font = [UIFont systemFontOfSize:16.0f];
        commentView.textColor = [UIColor lightGrayColor];
        commentView.numberOfLines = 3;
        [commView addSubview:commentView];
        
        UILabel *timeView = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth - 100, 10, 90, 10)];
        timeView.textAlignment = NSTextAlignmentRight;
        timeView.font = [UIFont systemFontOfSize:10.0f];
        timeView.textColor = [UIColor grayColor];
        NSString *localCreateTime = [self getNowDateFromatAnDate:commentsArr[i][@"createDate"]];
        NSString *lastTime =[self compareCurrentTime:localCreateTime];
        timeView.text = lastTime;
        [commView addSubview:timeView];
        
        _coachCommentsScrollView.contentSize = CGSizeMake(RCScreenWidth, YH(commView)+15);
        
    }
    
}

#pragma mark -- 键盘处理->点击空白处键盘收起
- (void)keyboardGesture{
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

// 移除监听
- (void)deallocNotifation{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//点击空白处，键盘退下
- (void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    _bottomView.frame = CGRectMake(0, RCScreenHeight - 50, RCScreenWidth, 50);
    [self deallocNotifation];
    [_commentField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

// 监听键盘的frame即将改变的时候调用
- (void)keyboardWillChange:(NSNotification *)note{
    // 获得键盘的frame
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 执行动画
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        _bottomView.frame = CGRectMake(0, RCScreenHeight - frame.size.height - 50, RCScreenWidth, 50);
        NSLog(@"%f",frame.size.height);
        UIView *mengView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, RCScreenHeight - frame.size.height - 100)];
        [self.view addSubview:mengView];
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGr.cancelsTouchesInView = NO;
        [mengView addGestureRecognizer:tapGr];
        _bottomView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    }];
}

//处理UTC，北京时区
- (NSString *)getNowDateFromatAnDate:(NSString *)anyDate
{
    //转换格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormatter dateFromString:anyDate];
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    //转换格式
    NSDateFormatter *destinationDate=[[NSDateFormatter alloc] init];
    [destinationDate setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *destinationDateStr = [destinationDate stringFromDate:destinationDateNow];
    return destinationDateStr;
}

//处理当前时间相差时间
-(NSString *) compareCurrentTime:(NSString *)str
{
    
    //把字符串转为NSdate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *timeDate = [dateFormatter dateFromString:str];
    //得到与当前时间差
    NSTimeInterval  timeInterval = [timeDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    //标准时间和北京时间差8个小时
    timeInterval = timeInterval - 8*60*60;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
    }
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    return  result;
}

@end
