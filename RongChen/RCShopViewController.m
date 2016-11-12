//
//  RCShopViewController.m
//  RongChen
//
//  Created by YingheSun on 16/11/3.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCShopViewController.h"
#import "RCProducts.h"
#import "RCProductDetailViewController.h"
#import "RCCartViewController.h"

@interface RCShopViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic ,strong) UIScrollView *shopView;
@property (nonatomic ,strong) UIView *commView;

@property (nonatomic, strong) NSMutableArray *shopListArr; //教练数组,内部存储Model类型.
@property (assign, nonatomic) NSInteger page; //数据页数.表示下次请求第几页的数据.

@property (nonatomic ,strong) NSString *shopURL;

@end

@implementation RCShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _shopURL = @"products";
    [self setBarView];
    [self showShopView];
    _page = 1;
    _shopListArr = [[NSMutableArray alloc]init];
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
    self.navigationItem.title = @"商城";
    //    UIBarButtonItem *LeftItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(sliderMenuShow)];
//    UIBarButtonItem *RightItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(cartViewShow)];
    UIBarButtonItem *RightItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cart"] style:UIBarButtonItemStylePlain target:self action:@selector(cartViewShow)];
    //    self.navigationItem.leftBarButtonItem = LeftItem;
    self.navigationItem.rightBarButtonItem = RightItem;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark - 显示列表
-(void)showShopView{
    _shopView = [[UIScrollView alloc]init];
    [self.view addSubview:_shopView];
    _shopView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    _shopView.scrollEnabled = YES;
    [_shopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(RCScreenHeight);
    }];
    
    //下拉刷新
    _shopView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(pullToGetMore)];
    [self requestNetwithPage:@"1"];
    
}

- (void)cartViewShow{
    NSLog(@"cart Open");
    
    self.hidesBottomBarWhenPushed=YES;
    
    RCCartViewController *cartVC = [[RCCartViewController alloc]init];
    
    [self.navigationController pushViewController:cartVC animated:YES];
    
    self.hidesBottomBarWhenPushed=NO;
}

#pragma mark - 请求接口
-(void)requestNetwithPage:(NSString *)pageNum{
    NSDictionary *dic = @{
                          @"page" : pageNum,
                          @"status" : @"published"
                          
                          };
    [XSHttpTool GET:_shopURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsArr = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条信息",resultNum);
        [self resolveData:resultsArr];
    } failure:^(NSError *error) {
        [_shopView.mj_footer endRefreshingWithNoMoreData];
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - 处理数据
- (void)resolveData:(NSArray *)dataArr{
    [_shopListArr addObjectsFromArray:dataArr];
    NSLog(@"%@",_shopListArr);
    _page ++;
    [self makeScrollViewShow];
}

-(void)makeScrollViewShow{
    [_shopView.mj_footer endRefreshing];
    [_shopView clearsContextBeforeDrawing];
    NSArray *productListArray = [RCProducts mj_objectArrayWithKeyValuesArray:_shopListArr];
    for (int i = 0; i < _shopListArr.count; i++) {
        
        RCProducts *shopInfo = productListArray[i];
        
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
        [_shopView addSubview:_commView];
        
        UIImageView *coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth / 2 - 10, RCScreenWidth / 2 - 10)];
        [_commView addSubview:coverImage];
        if(shopInfo.coverImage.length == 0){
            [coverImage setImage:[UIImage imageNamed:@"defaultLoading"]];
        }else{
            NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,shopInfo.coverImage,@"@!mobile"];
            [coverImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"defaultLoading"]];
        }
        coverImage.layer.cornerRadius = 5.0f;
        [coverImage clipsToBounds];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, RCScreenWidth / 2, 100, 30)];
        titleLabel.text = shopInfo.name;
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *experienceView = [[UILabel alloc]initWithFrame:CGRectMake(0, RCScreenWidth / 2, RCScreenWidth / 2 - 15, 30)];
        experienceView.textAlignment = NSTextAlignmentRight;
        experienceView.font = [UIFont systemFontOfSize:14.0f];
        experienceView.textColor = [UIColor grayColor];
        NSString *drivingYearsStr = [NSString stringWithFormat:@"¥%@",shopInfo.price];
        experienceView.text = drivingYearsStr;
        [_commView addSubview:experienceView];
        
    }
    _shopView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView)+15);
    if (_page > 2) {
        if (_shopListArr.count >= 20) {
            _shopView.contentOffset = CGPointMake(0, 20 * (_page - 2) * 52);
        }
    }
}


#pragma mark - 点击事件，跳转到详情页
- (void)tapUiscrollView:( UITapGestureRecognizer *)tap{
    
    NSLog(@"tapped => %ld",tap.view.tag - 1000);
    
    //跳转到详情页
    NSArray *shopListArray = [RCProducts mj_objectArrayWithKeyValuesArray:_shopListArr];
    RCProducts *shopInfo = shopListArray[tap.view.tag - 1000];
    self.hidesBottomBarWhenPushed=YES;
    
    RCProductDetailViewController *shopDetailVC = [[RCProductDetailViewController alloc]init];
    shopDetailVC.productInfo = shopInfo;
    
    [self.navigationController pushViewController:shopDetailVC animated:YES];
    self.hidesBottomBarWhenPushed=NO;
}

#pragma mark -- 上拉加载数据
-(void)pullToGetMore{
    NSString *pageStr = [NSString stringWithFormat:@"%ld",(long)_page];
    [self requestNetwithPage:pageStr];
}



@end
