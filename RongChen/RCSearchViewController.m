//
//  RCSearchViewController.m
//  RongChen
//
//  Created by YingheSun on 16/10/11.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCSearchViewController.h"
#import "RCNewsDetailViewController.h"
#import "RCNewsModel.h"

@interface RCSearchViewController ()<UIScrollViewDelegate , UIGestureRecognizerDelegate , UISearchBarDelegate>

@property (nonatomic ,strong) UIScrollView *newsView;
@property (nonatomic ,strong) UIView *commView;

@property (nonatomic ,strong) UIView *searchView;
@property (nonatomic ,strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *articles; //文章数组,内部存储Model类型.
@property (nonatomic, strong) NSMutableArray *articlesSave;//保存文章数组
@property (assign, nonatomic) NSInteger page; //数据页数.表示下次请求第几页的数据.

@property (nonatomic ,strong) NSString *articleURL;
@property (nonatomic ,strong) NSString *viewFlag;

@end

@implementation RCSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _articleURL = @"articles";
    _articles = [NSMutableArray arrayWithCapacity:0];
    [self searchViewShow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - 搜索
-(void)searchViewShow{
    self.view.backgroundColor = [UIColor whiteColor];
    
    _searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, self.navigationController.navigationBar.frame.size.height + 20)];
    _searchView.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [self.view addSubview:_searchView];
    _newsView = nil;
    
    //searchbar
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.barStyle = UIBarStyleDefault;
    _searchBar.placeholder = @"请输入要搜索的内容";
    _searchBar.backgroundColor=[UIColor clearColor];
    _searchBar.delegate = self;
    [_searchBar setBarTintColor :[ UIColor clearColor ]];
    [[[[_searchBar . subviews objectAtIndex : 0 ] subviews ] objectAtIndex : 0 ] removeFromSuperview ];
    [_searchBar setBackgroundColor :[ UIColor clearColor ]];
    _searchBar.barTintColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    _searchBar.layer.borderWidth = 0;
    [self.view addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_searchView).with.offset(12);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(_searchView.frame.size.width - 100);
        make.height.mas_equalTo(40);
    }];
    
    //取消按钮
    UIButton *searchBtn = [[UIButton alloc]init];
    [searchBtn setTitle:@"取消" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:searchBtn];
    [searchBtn addTarget:self action:@selector(searchViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_searchBar);
        make.leftMargin.equalTo(_searchBar.mas_right).with.offset(20);
        make.rightMargin.equalTo(_searchView).with.offset(-20);
        make.height.mas_equalTo(30);
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self showNewsView];
    [self doSearch:searchBar];
}

- (void)doSearch:(UISearchBar *)searchBar{
    NSLog(@"->search : %@",searchBar.text);
    NSDictionary *dic = @{@"search" : searchBar.text,
                          };
    [XSHttpTool GET:_articleURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsDic = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条新闻",resultNum);
        NSLog(@"->返回articles：%@",resultsDic);
        NSString *successStr = [NSString stringWithFormat:@"成功搜索到%@条结果",resultNum];
        [self resolveData:resultsDic andType:@"main"];
        RCPSuccess(successStr);
    } failure:^(NSError *error) {
        RCPError(@"请求失败");
    }];
    
}

-(void)searchViewHidden{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 显示主页新闻列表
-(void)showNewsView{
    _newsView = [[UIScrollView alloc]init];
    [self.view addSubview:_newsView];
    _newsView.backgroundColor = [UIColor whiteColor];
    _newsView.scrollEnabled = YES;
    [_newsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.mas_equalTo(self.navigationController.navigationBar.frame.size.height + 20);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(RCScreenHeight);
    }];
    
    //下拉刷新
    _newsView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullToGetMore)];
    
}

#pragma mark - 处理数据
- (void)resolveData:(NSArray *)dataArr andType:(NSString *)type{
    if ([type isEqualToString:@"main"]) {
        [_articles removeAllObjects];
        [_articles addObjectsFromArray:dataArr];
        NSLog(@"%@",_articles);
        _page ++;
        [self makeScrollViewShowWithType:@"main"];
    }else if([type isEqualToString:@"save"]){
        _articlesSave = nil;
        _articlesSave = _articles;
    }else if ([type isEqualToString:@"refresh"]){
        _articles = nil;
        _articles = _articlesSave;
        [self makeScrollViewShowWithType:@"main"];
    }else if([type isEqualToString:@"search"]){
        _articles = nil;
        [_articles addObjectsFromArray:dataArr];
        [self makeScrollViewShowWithType:@"search"];
    }
}

-(void)makeScrollViewShowWithType:(NSString *)type{
    [_newsView.mj_footer endRefreshing];
    [_newsView clearsContextBeforeDrawing];
    if([type isEqualToString:@"search"]){
        _newsView.hidden = YES;
    }else{
        _newsView.hidden = NO;
    }
    NSArray *articleArray = [RCNewsModel mj_objectArrayWithKeyValuesArray:_articles];
    for (int i = 0; i < _articles.count; i++) {
        
        RCNewsModel *newsInfo = articleArray[i];
        
        _commView = [[UIView alloc] init];
        _commView.frame = CGRectMake(0, 170*i, RCScreenWidth, 170);
        _commView.tag = 1000 + i;
        //添加点按击手势监听器
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUiscrollView:)];
        //设置手势属性
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired=1;//设置点按次数，为1
        tapGesture.numberOfTouchesRequired=1;//点按的手指数
        [_commView addGestureRecognizer:tapGesture];
        [_newsView addSubview:_commView];
        
        UIImageView *coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 120, 120)];
        [_commView addSubview:coverImage];
        if(newsInfo.coverImage.length == 0){
            [coverImage setImage:[UIImage imageNamed:@"defaultLoading"]];
        }else{
            NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,newsInfo.coverImage,@"@!mobile"];
            [coverImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"defaultLoading"]];
        }
        coverImage.layer.cornerRadius = 5.0f;
        [coverImage clipsToBounds];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 30, RCScreenWidth - 160, 20)];
        titleLabel.text = newsInfo.title;
        titleLabel.font = [UIFont systemFontOfSize:18.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_commView addSubview:titleLabel];
        
        UILabel *commentView = [[UILabel alloc]initWithFrame:CGRectMake(150, 50, RCScreenWidth - 160, 80)];
        commentView.text = newsInfo.comment;
        commentView.numberOfLines = 4;
        [_commView addSubview:commentView];
        
        UILabel *timeView = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth - 100, 145, 90, 10)];
        timeView.textAlignment = NSTextAlignmentRight;
        timeView.font = [UIFont systemFontOfSize:10.0f];
        timeView.textColor = [UIColor grayColor];
        NSString *localCreateTime = [self getNowDateFromatAnDate:newsInfo.createDate];
        NSString *lastTime =[self compareCurrentTime:localCreateTime];
        timeView.text = lastTime;
        [_commView addSubview:timeView];
        
        UIView *grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 162, RCScreenWidth, 8)];
        grayView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
        [_commView addSubview:grayView];
        
    }
    _newsView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView)+15);
    if (_page > 2) {
        if (_articles.count >= 20) {
            _newsView.contentOffset = CGPointMake(0, 20 * (_page -2)*170 - RCScreenWidth/2);
        }
    }
}


#pragma mark - 点击事件，跳转到详情页
- (void)tapUiscrollView:( UITapGestureRecognizer *)tap{
    
    NSLog(@"tapped => %ld",tap.view.tag - 1000);
    
    //跳转到详情页
    NSArray *articleArray = [RCNewsModel mj_objectArrayWithKeyValuesArray:_articles];
    RCNewsModel *newsInfo = articleArray[tap.view.tag - 1000];
    self.hidesBottomBarWhenPushed=YES;
    
    RCNewsDetailViewController *newsVC = [[RCNewsDetailViewController alloc]init];
    newsVC.title = newsInfo.title;
    newsVC.Content = newsInfo.content;
    
    [self.navigationController pushViewController:newsVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

#pragma mark -- 上拉加载数据
-(void)pullToGetMore{
    if([_viewFlag isEqualToString:@"main"]){
        NSString *pageStr = [NSString stringWithFormat:@"%ld",(long)_page];
        [self requestNetwithPage:pageStr];
    }else{
        [_newsView.mj_footer endRefreshing];
    }
}

#pragma mark - 请求接口
-(void)requestNetwithPage:(NSString *)pageNum{
    NSDictionary *dic = @{@"page" : pageNum,
                          };
    [XSHttpTool GET:_articleURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsArr = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条新闻",resultNum);
        [self showNewsView];
        [self resolveData:resultsArr andType:@"main"];
    } failure:^(NSError *error) {
        [_newsView.mj_footer endRefreshingWithNoMoreData];
        NSLog(@"Error: %@", error);
    }];
    _viewFlag = @"main";
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
