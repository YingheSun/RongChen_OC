//
//  RCAccountListViewController.m
//  RongChen
//
//  Created by YingheSun on 16/10/14.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCAccountListViewController.h"

@interface RCAccountListViewController ()

@property (nonatomic ,strong) UIScrollView *listView;
@property (nonatomic ,strong) UIView *commView;

@property (nonatomic ,strong) NSMutableArray *listArr;
@property (nonatomic ,assign) NSInteger page;

@property (nonatomic ,strong) NSString *accountListURL;

@end

@implementation RCAccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _accountListURL = @"transactions";
    _listArr = [[NSMutableArray alloc]init];
    _page = 1;
    [self setBarView];
    [self showListView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setBarView{
    self.navigationItem.title = @"账户列表";
}

#pragma mark - 显示列表
-(void)showListView{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 70, RCScreenWidth, 50)];
    titleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 50)];
    titleLabel.text = @"余额:";
    [titleView addSubview:titleLabel];
    
    UILabel *account = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth / 3 + 10, 5, 100, 50)];
    account.text = self.accountInfo;
    account.textColor = [UIColor lightGrayColor];
    [titleView addSubview:account];
    
    UIButton *cacheBtn = [[UIButton alloc]initWithFrame:CGRectMake(RCScreenWidth - 85, 0, 70, 50)];
    [cacheBtn setImage:[UIImage imageNamed:@"提现"] forState:UIControlStateNormal];
    [titleView addSubview:cacheBtn];
    
    UILabel *cacheTitle = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth - 80, 0, 70, 50)];
    cacheTitle.text = @"提现";
    cacheTitle.textAlignment = NSTextAlignmentRight;
    cacheTitle.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [titleView addSubview:cacheTitle];
    
    _listView = [[UIScrollView alloc]init];
    [self.view addSubview:_listView];
    _listView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    _listView.scrollEnabled = YES;
    [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView.mas_bottom).with.offset(5);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    //下拉刷新
    _listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullToGetMore)];
    [self requestNetwithPage:@"1"];
}

#pragma mark - 请求接口
-(void)requestNetwithPage:(NSString *)pageNum{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"page" : pageNum,
                          @"user" : userId
                          };
    [XSHttpTool GET:_accountListURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsArr = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条信息,info:%@",resultNum,resultsArr);
        [self resolveData:resultsArr];
    } failure:^(NSError *error) {
        [_listView.mj_footer endRefreshingWithNoMoreData];
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - 处理数据
- (void)resolveData:(NSArray *)dataArr{
    [_listArr addObjectsFromArray:dataArr];
    NSLog(@"%@",_listArr);
    _page ++;
    [self makeScrollViewShow];
}

#pragma mark - 显示列表内容
-(void)makeScrollViewShow{
    [_listView.mj_footer endRefreshing];
    [_listView clearsContextBeforeDrawing];
    NSLog(@"%lu",(unsigned long)_listArr.count);
    for (int i = 0; i < _listArr.count; i++) {
        
        _commView = [[UIView alloc] init];
        _commView.backgroundColor = [UIColor whiteColor];
        _commView.frame = CGRectMake(0, 51 * i, RCScreenWidth, 50);
        [_listView addSubview:_commView];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 50)];
        NSString *dateStr = [NSString stringWithFormat:@"%@",_listArr[i][@"createDate"]];
        NSArray *separateArr = [dateStr componentsSeparatedByString:@"T"];
        dateLabel.text = separateArr[0];
        dateLabel.textColor = [UIColor lightGrayColor];
        dateLabel.font = [UIFont systemFontOfSize:15.0f];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:dateLabel];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth / 3 + 10, 5, 100, 50)];
        if([_listArr[i][@"tranType"] isEqualToString:@"recommend"]){
            NSString *scoreStr = [NSString stringWithFormat:@"+%@", _listArr[i][@"score"]];
            titleLabel.text =  scoreStr;
        }else{
            NSString *scoreStr = [NSString stringWithFormat:@"-%@", _listArr[i][@"score"]];
            titleLabel.text =  scoreStr;
        }
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth * 2 / 3, 5, 100, 50)];
        stateLabel.textAlignment = NSTextAlignmentRight;
        stateLabel.font = [UIFont systemFontOfSize:15.0f];
        stateLabel.text = _listArr[i][@"comment"];
        [_commView addSubview:stateLabel];
        
    }
    
    _listView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView) + 15);
    
}

#pragma mark -- 上拉加载数据
-(void)pullToGetMore{
    NSString *pageStr = [NSString stringWithFormat:@"%ld",(long)_page];
    [self requestNetwithPage:pageStr];
}

@end
