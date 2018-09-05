//
//  RCCoachViewController.m
//  RongChen
//
//  Created by 孙滢贺 on 16/9/25.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCCoachViewController.h"
#import "RCCoachSearchViewController.h"
#import "RCCoachModel.h"
#import "RCCoachDetailViewController.h"

@interface RCCoachViewController ()<UIScrollViewDelegate , UIGestureRecognizerDelegate>

@property (nonatomic ,strong) UIScrollView *coachView;
@property (nonatomic ,strong) UIView *commView;

@property (nonatomic, strong) NSMutableArray *coachListArr; //教练数组,内部存储Model类型.
@property (assign, nonatomic) NSInteger page; //数据页数.表示下次请求第几页的数据.

@property (nonatomic ,strong) NSString *coachURL;

@end

@implementation RCCoachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _coachURL = @"coaches";
    [self setBarView];
    [self showCoachView];
    _page = 1;
    _coachListArr = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    //左侧的slider menu 取消
    self.navigationItem.title = @"智库作者";
    //    UIBarButtonItem *LeftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(sliderMenuShow)];
    UIBarButtonItem *RightItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchViewShow)];
    //    self.navigationItem.leftBarButtonItem = LeftItem;
    self.navigationItem.rightBarButtonItem = RightItem;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark - 搜索
-(void)searchViewShow{
    RCCoachSearchViewController *searchVC = [[RCCoachSearchViewController alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - 显示列表
-(void)showCoachView{
    _coachView = [[UIScrollView alloc]init];
    [self.view addSubview:_coachView];
    _coachView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    _coachView.scrollEnabled = YES;
    [_coachView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(RCScreenHeight);
    }];
    
    //下拉刷新
    _coachView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullToGetMore)];
    [self requestNetwithPage:@"1"];
    
}

#pragma mark - 请求接口
-(void)requestNetwithPage:(NSString *)pageNum{
    NSDictionary *dic = @{
                          @"page" : pageNum,
                          };
    [XSHttpTool GET:_coachURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsArr = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条信息",resultNum);
        [self resolveData:resultsArr];
    } failure:^(NSError *error) {
        [_coachView.mj_footer endRefreshingWithNoMoreData];
        NSLog(@"Error: %@", error);
    }];
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
            _commView.frame = CGRectMake(5, (RCScreenWidth / 2 + 52) * i/ 2 + 15, RCScreenWidth / 2 - 10, RCScreenWidth / 2 + 40);
        }else{
            _commView.frame = CGRectMake(RCScreenWidth / 2 + 5, (RCScreenWidth / 2 + 52) * (i - 1) / 2 + 15, RCScreenWidth / 2 - 10, RCScreenWidth / 2 + 40);
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
        NSString *pageStr = [NSString stringWithFormat:@"%ld",(long)_page];
        [self requestNetwithPage:pageStr];
}

@end
