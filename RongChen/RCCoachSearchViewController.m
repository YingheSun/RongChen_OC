//
//  RCCoachSearchViewController.m
//  RongChen
//
//  Created by YingheSun on 16/10/13.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCCoachSearchViewController.h"
#import "RCCoachModel.h"
#import "RCCoachDetailViewController.h"

@interface RCCoachSearchViewController ()<UIScrollViewDelegate , UIGestureRecognizerDelegate , UISearchBarDelegate>

@property (nonatomic ,strong) UIScrollView *coachView;
@property (nonatomic ,strong) UIView *commView;

@property (nonatomic ,strong) UISearchBar *searchBar;
@property (nonatomic ,strong) UIView *searchView;

@property (nonatomic, strong) NSMutableArray *coachListArr; //教练数组,内部存储Model类型.
@property (assign, nonatomic) NSInteger page; //数据页数.表示下次请求第几页的数据.

@property (nonatomic ,strong) NSString *coachURL;

@end

@implementation RCCoachSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _coachURL = @"coaches";
    [self setBarView];
    _page = 1;
    _coachListArr = [[NSMutableArray alloc]init];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    _searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, self.navigationController.navigationBar.frame.size.height + 20)];
    _searchView.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [self.view addSubview:_searchView];
    
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
    [self doSearch:searchBar];
    [self showCoachView];
}

#pragma mark - 请求接口
- (void)doSearch:(UISearchBar *)searchBar{
    NSLog(@"->search : %@",searchBar.text);
    NSDictionary *dic = @{@"search" : searchBar.text,
                          };
    [XSHttpTool GET:_coachURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsArr = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条信息",resultNum);
        NSLog(@"->返回结果：%@",resultsArr);
        NSString *successStr = [NSString stringWithFormat:@"成功搜索到%@条结果",resultNum];
        RCPSuccess(successStr);
        [self resolveData:resultsArr];
    } failure:^(NSError *error) {
        RCPError(@"请求失败");
    }];
    
}

-(void)searchViewHidden{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 显示列表
-(void)showCoachView{
    _coachView = [[UIScrollView alloc]init];
    [self.view addSubview:_coachView];
    _coachView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    _coachView.scrollEnabled = YES;
    [_coachView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.mas_equalTo(self.navigationController.navigationBar.frame.size.height + 20);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(RCScreenHeight);
    }];
    
    //下拉刷新
    _coachView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullToGetMore)];
    
}

#pragma mark - 处理数据
- (void)resolveData:(NSArray *)dataArr{
    [_coachListArr addObjectsFromArray:dataArr];
    NSLog(@"%@",_coachListArr);
    _page ++;
    [self makeScrollViewShow];
}

-(void)makeScrollViewShow{
    [_coachView.mj_footer endRefreshing];
    [_coachView clearsContextBeforeDrawing];
    NSArray *coachListArray = [RCCoachModel mj_objectArrayWithKeyValuesArray:_coachListArr];
    for (int i = 0; i < _coachListArr.count; i++) {
        
        RCCoachModel *coachInfo = coachListArray[i];
        
        _commView = [[UIView alloc] init];
        _commView.backgroundColor = [UIColor whiteColor];
        if ((i - 1) % 2) {
            _commView.frame = CGRectMake(5, (RCScreenWidth / 2 + 52) * i/ 2, RCScreenWidth / 2 - 10, RCScreenWidth / 2 + 40);
        }else{
            _commView.frame = CGRectMake(RCScreenWidth / 2 + 5, (RCScreenWidth / 2 + 52) * (i - 1) / 2, RCScreenWidth / 2 - 10, RCScreenWidth / 2 + 40);
        }
        _commView.tag = 1000 + i;
        _commView.layer.cornerRadius = 5.0f;
        [_commView setClipsToBounds:YES];
        //添加点按击手势监听器
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapUiscrollView:)];
        //设置手势属性
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired=1;//设置点按次数，为1
        tapGesture.numberOfTouchesRequired=1;//点按的手指数
        [_commView addGestureRecognizer:tapGesture];
        [_coachView addSubview:_commView];
        
        UIImageView *coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth / 2 - 10, RCScreenWidth / 2 - 10)];
        [_commView addSubview:coverImage];
        if(coachInfo.introImage.length == 0){
            [coverImage setImage:[UIImage imageNamed:@"defaultLoading"]];
        }else{
            NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,coachInfo.avatar,@"@!mobile"];
            [coverImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"defaultLoading"]];
        }
        coverImage.layer.cornerRadius = 5.0f;
        [coverImage clipsToBounds];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, RCScreenWidth / 2, 100, 30)];
        titleLabel.text = coachInfo.name;
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *experienceView = [[UILabel alloc]initWithFrame:CGRectMake(0, RCScreenWidth / 2, RCScreenWidth / 2 - 15, 30)];
        experienceView.textAlignment = NSTextAlignmentRight;
        experienceView.font = [UIFont systemFontOfSize:14.0f];
        experienceView.textColor = [UIColor grayColor];
        NSString *drivingYearsStr = [NSString stringWithFormat:@"%@年教练经验",coachInfo.drivingYears];
        experienceView.text = drivingYearsStr;
        [_commView addSubview:experienceView];
        
    }
    _coachView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView)+15);
    if (_page > 2) {
        if (_coachListArr.count >= 20) {
            _coachView.contentOffset = CGPointMake(0, 20 * (_page - 2) * 52);
        }
    }
}


#pragma mark - 点击事件，跳转到详情页
- (void)tapUiscrollView:( UITapGestureRecognizer *)tap{
    
    NSLog(@"tapped => %ld",tap.view.tag - 1000);
    
    //跳转到详情页
    NSArray *coachListArray = [RCCoachModel mj_objectArrayWithKeyValuesArray:_coachListArr];
    RCCoachModel *coachInfo = coachListArray[tap.view.tag - 1000];
    self.hidesBottomBarWhenPushed=YES;
    
    RCCoachDetailViewController *coachDetailVC = [[RCCoachDetailViewController alloc]init];
    coachDetailVC.coachInfo = coachInfo;
    
    [self.navigationController pushViewController:coachDetailVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

#pragma mark -- 上拉加载数据
-(void)pullToGetMore{
//    NSString *pageStr = [NSString stringWithFormat:@"%ld",(long)_page];
//    [self requestNetwithPage:pageStr];
    [_coachView.mj_footer endRefreshingWithNoMoreData];
}

@end
