//
//  RCMyOrderViewController.m
//  RongChen
//
//  Created by YingheSun on 16/11/10.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCMyOrderViewController.h"
#import "RCOrderDetailViewController.h"

@interface RCMyOrderViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic ,strong) NSString *getOrderURL;

@property (nonatomic ,strong) NSMutableArray *resultsArr;

@property (nonatomic ,strong) UIScrollView *historyView;
@property (nonatomic ,strong) UIView *commView;

@end

@implementation RCMyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _getOrderURL = @"orders";
    
    [self setBarView];
    [self getHistoryInfo];
    [self makeViewShow];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    //左侧的slider menu 取消
    self.navigationItem.title = @"历史订单";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)getHistoryInfo{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"user" : userId
                          };
    [XSHttpTool GET:_getOrderURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        _resultsArr = [responseDic objectForKey:@"results"];
        NSLog(@"->搜索到 ： %@ 条信息,info => %@",resultNum,_resultsArr);
        [self makeScrollViewShow];
    } failure:^(NSError *error) {
        RCPError(@"下单失败");
    }];
}

-(void)makeViewShow{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    _historyView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, RCScreenHeight)];
    [self.view addSubview:_historyView];
}

-(void)makeScrollViewShow{
    [_historyView clearsContextBeforeDrawing];
    
    for (int i = 0; i < _resultsArr.count; i++) {
        
        _commView = [[UIView alloc] init];
        _commView.frame = CGRectMake(0, 51*i, RCScreenWidth, 50);
        _commView.backgroundColor = [UIColor whiteColor];
        //添加点按击手势监听器
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
        //设置手势属性
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired=1;//设置点按次数，为1
        tapGesture.numberOfTouchesRequired=1;//点按的手指数
        [_commView addGestureRecognizer:tapGesture];
        _commView.tag = 1000 + i;
        [_historyView addSubview:_commView];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 50)];
        NSString *dateStr = [NSString stringWithFormat:@"%@",_resultsArr[i][@"createDate"]];
        NSArray *separateArr = [dateStr componentsSeparatedByString:@"T"];
        dateLabel.text = separateArr[0];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.font = [UIFont systemFontOfSize:15.0f];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:dateLabel];

        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth / 3 + 10, 5, 100, 50)];
        NSString *scoreStr = [NSString stringWithFormat:@"¥%@", _resultsArr[i][@"totalPrice"]];
        titleLabel.text =  scoreStr;
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth * 2 / 3, 5, 100, 50)];
        stateLabel.textAlignment = NSTextAlignmentRight;
        stateLabel.font = [UIFont systemFontOfSize:15.0f];
        stateLabel.text = _resultsArr[i][@"orderItem"][0][@"name"];
        [_commView addSubview:stateLabel];

        _historyView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView) + 15);
        
    }
}

-(void)tapView:( UITapGestureRecognizer *)tap{
    NSLog(@"tapped => %ld",tap.view.tag - 1000);
    
    self.hidesBottomBarWhenPushed=YES;
    
    RCOrderDetailViewController *orderDetailVC = [[RCOrderDetailViewController alloc]init];
    
    NSDictionary *pushDic = _resultsArr[tap.view.tag - 1000];
    
    orderDetailVC.orderDetail = pushDic;
    
    [self.navigationController pushViewController:orderDetailVC animated:YES];
    
    self.hidesBottomBarWhenPushed=NO;
}

@end
