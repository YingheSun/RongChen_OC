//
//  RCProductDetailViewController.m
//  RongChen
//
//  Created by YingheSun on 16/11/4.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCProductDetailViewController.h"

@interface RCProductDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *topScrollView;
@property (nonatomic,strong) UIPageControl *pageControll;
@property (nonatomic,strong) NSMutableArray *picModelArr;

@property (nonatomic,strong) NSString *addCartURL;

@end

@implementation RCProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBarView];
    _addCartURL = @"shopcars";
    [self picArrExec];
    [self viewShow];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)picArrExec{
    _picModelArr = [[NSMutableArray alloc]init];
    if (self.productInfo.contentImage1.length != 0) {
        [_picModelArr addObject:self.productInfo.contentImage1];
    }
    if(self.productInfo.contentImage2.length != 0){
        [_picModelArr addObject:self.productInfo.contentImage2];
    }
    if(self.productInfo.contentImage3.length != 0){
        [_picModelArr addObject:self.productInfo.contentImage3];
    }
    NSLog(@"pic Array:%@",_picModelArr);
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    //左侧的slider menu 取消
    self.navigationItem.title = @"商品详情";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

#pragma mark - view
-(void)viewShow{
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, RCScreenHeight)];
    backgroundView.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    [self.view addSubview:backgroundView];
    
    _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.layer.frame.size.height, RCScreenWidth, RCScreenWidth / 6 * 5)];
    //    _topScrollView.frame = CGRectMake(0, 0, kScreenWidth, kImageHight);
    _topScrollView.delegate = self;
    _topScrollView.tag = 202;
    _topScrollView.pagingEnabled = YES;
    _topScrollView.bounces = NO;
    _topScrollView.backgroundColor = [UIColor whiteColor];
    _topScrollView.showsHorizontalScrollIndicator = NO;
    _topScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_topScrollView];
    
    _pageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    _pageControll.center = CGPointMake(RCScreenWidth / 2, RCScreenWidth / 6 * 5 - 20);
    _pageControll.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControll.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControll.userInteractionEnabled = NO;
    [self.view addSubview:_pageControll];
    _pageControll.numberOfPages = _picModelArr.count;
    
    //创建上面的滚动图片
    for (int i = 0; i < _picModelArr.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(i * RCScreenWidth, 0, RCScreenWidth, RCScreenWidth / 6 * 5);
        NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,_picModelArr[i],@"@!mobile"];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"defaultLoading"]];
        [_topScrollView addSubview:imageView];
    }
    _topScrollView.contentSize = CGSizeMake(_picModelArr.count * RCScreenWidth, 0);
    
    UIView *titlebarView = [[UIView alloc]initWithFrame:CGRectMake(0, RCScreenWidth / 6 * 5 + 5, RCScreenWidth, 40)];
    titlebarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titlebarView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 40)];
    titleLabel.text = self.productInfo.name;
    [titlebarView addSubview:titleLabel];
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth - 100, 0, 90, 40)];
    NSString *priceStr = [NSString stringWithFormat:@"¥%@",self.productInfo.price];
    priceLabel.text = priceStr;
    priceLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    priceLabel.textAlignment = NSTextAlignmentRight;
    [titlebarView addSubview:priceLabel];
    
    UIView *commentView = [[UIView alloc]initWithFrame:CGRectMake(0, RCScreenWidth / 6 * 5 + 50, RCScreenWidth, 150)];
    commentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:commentView];
    
    UILabel *commentTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 200, 40)];
    commentTitleLabel.text = @"详情简介";
    [commentView addSubview:commentTitleLabel];
    
    UIWebView *commentLabel = [[UIWebView alloc]initWithFrame:CGRectMake(0, 40, RCScreenWidth, RCScreenHeight - RCScreenWidth / 6 * 5 - 100)];
    NSString *commentStr = [NSString stringWithFormat:@"%@",self.productInfo.content];
    [commentLabel loadHTMLString:commentStr baseURL:nil];
    [commentView addSubview:commentLabel];
    
    UIButton *getProductBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, RCScreenHeight - 50, RCScreenWidth, 50)];
    getProductBtn.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [getProductBtn addTarget:self action:@selector(addProductToCart) forControlEvents:UIControlEventTouchUpInside];
    [getProductBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    getProductBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:getProductBtn];
}

-(void)addProductToCart{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"user" : userId,
                          @"product" : self.productInfo.id,
                          @"amount" : @"1"
                        };
    [XSHttpTool POST:_addCartURL param:dic success:^(id responseObject) {
        RCPSuccess(@"成功添加商品到购物车");
    } failure:^(NSError *error) {
        RCPError(@"添加失败");
    }];
}

#pragma mark -- UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int i = _topScrollView.contentOffset.x / RCScreenWidth;
    _pageControll.currentPage = i;
}

@end
