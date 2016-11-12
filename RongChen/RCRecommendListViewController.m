//
//  RCRecommendListViewController.m
//  RongChen
//
//  Created by YingheSun on 16/10/14.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCRecommendListViewController.h"

@interface RCRecommendListViewController ()

@property (nonatomic ,strong) UIScrollView *listView;
@property (nonatomic ,strong) UIView *commView;

@property (nonatomic ,strong) NSMutableArray *listArr;
@property (nonatomic ,assign) NSInteger page;

@property (nonatomic ,strong) NSString *recommendListURL;

@end

@implementation RCRecommendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _recommendListURL = @"recommends";
    
//    _recommendListURL = @"transactions";
    _listArr = [[NSMutableArray alloc]init];
    _page = 1;
    [self setBarView];
    [self showListView];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBarView{
    self.navigationItem.title = @"推荐列表";
}

#pragma mark - 显示列表
-(void)showListView{
    _listView = [[UIScrollView alloc]init];
    [self.view addSubview:_listView];
    _listView.backgroundColor = [UIColor whiteColor];
    _listView.scrollEnabled = YES;
    [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(RCScreenHeight);
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
    [XSHttpTool GET:_recommendListURL param:dic success:^(id responseObject) {
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
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth / 3 , 5, 200, 50)];
        NSString *phoneStr = [NSString stringWithFormat:@"%@",_listArr[i][@"recommendMobile"]];
        NSString *titleStr = @"";
        if (phoneStr.length > 0) {
            NSArray *phoneArr = [phoneStr componentsSeparatedByString:@"+86"];
            titleStr = [NSString stringWithFormat:@"%@%@",_listArr[i][@"recommendUserName"], phoneArr[1]];
        }
        titleLabel.text =  titleStr;
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth * 2 / 3, 5, 100, 50)];
        stateLabel.textAlignment = NSTextAlignmentRight;
        stateLabel.font = [UIFont systemFontOfSize:15.0f];
        if([_listArr[i][@"status"] isEqualToString:@"check"]){
            stateLabel.text = @"处理中";
            stateLabel.textColor = [UIColor lightGrayColor];
        }else if([_listArr[i][@"status"] isEqualToString:@"success"]){
            stateLabel.text = @"推荐成功";
            stateLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
        }else{
            stateLabel.text = @"推荐失败";
            stateLabel.textColor = [UIColor redColor];
        }
        
        [_commView addSubview:stateLabel];
        
    }
    
    _listView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView)+15);
    
}

#pragma mark -- 上拉加载数据
-(void)pullToGetMore{
    NSString *pageStr = [NSString stringWithFormat:@"%ld",(long)_page];
    [self requestNetwithPage:pageStr];
}


@end
