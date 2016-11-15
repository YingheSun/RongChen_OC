//
//  RCCartViewController.m
//  RongChen
//
//  Created by YingheSun on 16/11/3.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCCartViewController.h"
#import "RCGoods.h"
#import "RCOrderPost.h"
#import "RCOrderViewController.h"

@interface RCCartViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic ,strong) UIScrollView *cartView;
@property (nonatomic ,strong) UIView *commView;
@property (nonatomic ,strong) UILabel *amountLabel;
@property (nonatomic ,strong) UILabel *totalPriceLabel;
@property (nonatomic ,strong) UITextField *nameField;
@property (nonatomic ,strong) UITextField *addressField;
@property (nonatomic ,strong) UITextField *phoneField;


@property (nonatomic ,strong) NSString *getCartURL;
@property (nonatomic ,strong) NSString *changeAmountURL;
@property (nonatomic ,strong) NSString *commitOrderURL;

@property (nonatomic ,strong) NSMutableArray *cartArr;
@property (nonatomic ,strong) NSMutableArray *commitArr;

@property (nonatomic ,assign) NSInteger totalPrice;

@end

@implementation RCCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBarView];
    [self makeViewShow];
    _getCartURL = @"shopcars";
    _commitOrderURL = @"orders";
    _commitArr = [[NSMutableArray alloc]init];
    _cartArr = [[NSMutableArray alloc]init];
    [self getCartInfo];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    //左侧的slider menu 取消
    self.navigationItem.title = @"购物车";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)makeViewShow{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    _cartView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, RCScreenHeight - 100 )];
    [self.view addSubview:_cartView];
    
    UIView *totalBar = [[UIView alloc]initWithFrame:CGRectMake(0, RCScreenHeight - 100, RCScreenWidth, 50)];
    totalBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:totalBar];
    
    UILabel *totalTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.4, 50)];
    totalTitle.text = @"总计:";
    totalTitle.textAlignment = NSTextAlignmentRight;
    [totalBar addSubview:totalTitle];
    
    _totalPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.4, 0, RCScreenWidth * 0.4, 50)];
    _totalPriceLabel.textAlignment = NSTextAlignmentLeft;
    _totalPriceLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [totalBar addSubview:_totalPriceLabel];
    
    UILabel *yfTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.8, 50)];
    yfTitle.text = @"不含运费";
    yfTitle.font = [UIFont systemFontOfSize:10.0f];
    yfTitle.textColor = [UIColor lightGrayColor];
    yfTitle.textAlignment = NSTextAlignmentRight;
    [totalBar addSubview:yfTitle];
    
    UIButton *submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, RCScreenHeight - 50, RCScreenWidth, 50)];
    submitBtn.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [submitBtn addTarget:self action:@selector(makeOrderCommit) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setTitle:@"提交订单" forState:UIControlStateNormal];
    submitBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:submitBtn];
}

-(void)makeOrderCommit{
    if (_nameField.text.length == 0) {
        RCPError(@"未填写姓名，不能提交");
    }
    else if (_addressField.text.length == 0) {
        RCPError(@"未填写地址，不能提交");
    }
    else if (_phoneField.text.length == 0) {
        RCPError(@"未填写电话，不能提交");
    }
    else{
        
        NSString *totalPrice = [NSString stringWithFormat:@"%ld",(long)_totalPrice];
        NSArray *tagModelArray = [self getTagModelArraywithDictionary];
        NSDictionary *params = @{
                                 @"totalPrice" : totalPrice,
                                 @"comment" : @"",
                                 @"receiver" : _nameField.text,
                                 @"receiverAddress" : _addressField.text,
                                 @"receiverPhone" : _phoneField.text,
                                 @"orderItem" : tagModelArray
                              };
        MyLog(@"%@", params);
        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
//        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        
//        MyLog(@"jsonString--%@", json);
        
//        NSDictionary *dic = @{@"body" : json};
        
        [XSHttpTool POSTOrder:_commitOrderURL param:params success:^(id responseObject) {
            RCPSuccess(@"下单成功");
            NSLog(@" order info : %@",responseObject);
            [self pushToOrderVC:responseObject];
        } failure:^(NSError *error) {
            MyLog(@"error----%@", error);
            RCPError(@"下单失败");
        }];
            
        }
    
//    NSDictionary *params = @{@"email": @"email@gmail.com", @"name": @"myName"};
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
//    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSDictionary *dict = @{@"body":json};
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager POST:@"http://myURL.com/user" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSString *myString = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding];
//        NSLog(@"Error: %@", myStri

    
}

-(void)getCartInfo{
    NSString *userId = getLocalData(RCUserId);
    NSDictionary *dic = @{
                          @"user" : userId
                          };
    [XSHttpTool GET:_getCartURL param:dic success:^(id responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *resultsArr = [responseDic objectForKey:@"results"];
        NSString *resultNum = [responseDic objectForKey:@"count"];
        NSLog(@"->搜索到 ： %@ 条信息,info => %@",resultNum,resultsArr);
//        if ([resultNum isEqualToString:@"0"]) {
//            [_cartArr removeAllObjects];
//            [self makeScrollViewShow];
//        }
        [self resolveData:resultsArr];
    } failure:^(NSError *error) {
        RCPError(@"添加失败");
    }];
}

#pragma mark - 处理数据
- (void)resolveData:(NSArray *)dataArr{
    [_cartArr removeAllObjects];
    [_commitArr removeAllObjects];
    [_cartArr addObjectsFromArray:dataArr];
    [self makeScrollViewShow];
}

-(void)makeScrollViewShow{
    [_cartView clearsContextBeforeDrawing];
    _totalPrice = 0;
    NSArray *goodListArray = [RCGoods mj_objectArrayWithKeyValuesArray:_cartArr];
    
    for (int i = 0; i < _cartArr.count; i++) {
        
        RCGoods *goodInfo = goodListArray[i];
        
        _commView = [[UIView alloc] init];
        _commView.frame = CGRectMake(0, 51*i, RCScreenWidth, 50);
        _commView.backgroundColor = [UIColor whiteColor];
        _commView.tag = 1000 + i;
        [_cartView addSubview:_commView];
        
        UIImageView *coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        [_commView addSubview:coverImage];
        if(goodInfo.productCoverImage.length == 0){
            [coverImage setImage:[UIImage imageNamed:@"defaultLoading"]];
        }else{
            NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,goodInfo.productCoverImage,@"@!mobile"];
            //            NSLog(@"loading => %@ ",imgStrURL);
            [coverImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"defaultLoading"]];
        }
        coverImage.layer.cornerRadius = 5.0f;
        [coverImage setClipsToBounds:YES];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, RCScreenWidth - 160, 20)];
        titleLabel.text = goodInfo.productName;
        titleLabel.font = [UIFont systemFontOfSize:12.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *priceView = [[UILabel alloc]initWithFrame:CGRectMake(60, 30, RCScreenWidth - 160, 20)];
        NSString *priceStr = [NSString stringWithFormat:@"¥%@",goodInfo.productPrice];
        priceView.text = priceStr;
        priceView.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
        priceView.font = [UIFont systemFontOfSize:12.0f];
        priceView.numberOfLines = 4;
        [_commView addSubview:priceView];
        
        UIImageView *addImg = [[UIImageView alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.6, 10, 20, 20)];
        addImg.image = [UIImage imageNamed:@"加号"];

        [_commView addSubview:addImg];
        
        UIView *addView = [[UIView alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.6, 0, 50, 50)];
        addView.tag = 1000 + i;
        //添加点按击手势监听器
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAddView:)];
        //设置手势属性
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired=1;//设置点按次数，为1
        tapGesture.numberOfTouchesRequired=1;//点按的手指数
        [addView addGestureRecognizer:tapGesture];
        [_commView addSubview:addView];
        
        
        _amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.6 + 30, 0 , 40, 40)];
        _amountLabel.textAlignment = NSTextAlignmentCenter;
        _amountLabel.font = [UIFont systemFontOfSize:10.0f];
        _amountLabel.text = goodInfo.amount;
        _amountLabel.textColor = [UIColor grayColor];
        [_commView addSubview:_amountLabel];
        
        
        UIImageView *minusImg = [[UIImageView alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.6 + 70, 10, 20, 20)];
        minusImg.image = [UIImage imageNamed:@"减号"];
        minusImg.tag = 1000 + i;
        [_commView addSubview:minusImg];
        
        UIView *minusView = [[UIView alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.6 + 70, 0, 50, 50)];
        minusView.tag = 1000 + i;
        //添加点按击手势监听器
        UITapGestureRecognizer *tapGesture1=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapMinusView:)];
        //设置手势属性
        tapGesture1.delegate = self;
        tapGesture1.numberOfTapsRequired=1;//设置点按次数，为1
        tapGesture1.numberOfTouchesRequired=1;//点按的手指数
        [minusView addGestureRecognizer:tapGesture1];
        [_commView addSubview:minusView];
        
        UIImageView *rubbishImg = [[UIImageView alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.7 + 70, 30, 15, 15)];
        rubbishImg.image = [UIImage imageNamed:@"垃圾箱"];
        rubbishImg.tag = 10000 + i;
        [_commView addSubview:rubbishImg];
        
        UIView *rubblishView = [[UIView alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.7 + 70, 20, 30, 30)];
        rubblishView.tag = 10000 + i;
        //添加点按击手势监听器
        UITapGestureRecognizer *tapGestureR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRubblishView:)];
        //设置手势属性
        tapGestureR.delegate = self;
        tapGestureR.numberOfTapsRequired=1;//设置点按次数，为1
        tapGestureR.numberOfTouchesRequired=1;//点按的手指数
        [rubblishView addGestureRecognizer:tapGestureR];
        [_commView addSubview:rubblishView];
        
        _totalPrice = _totalPrice + [goodInfo.productPrice integerValue] * [goodInfo.amount integerValue];
        
        _cartView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView) + 170);
    
        //测试不通过
//        NSDictionary *infoDic = @{
//                                  @"productID" : goodInfo.product,
//                                  @"amount" : goodInfo.amount
//                                  };
        
        //model的形势
        RCOrderPost *orderPost = [[RCOrderPost alloc]init];
        
        orderPost.amount = goodInfo.amount;
        orderPost.productID = goodInfo.product;
        
        [_commitArr addObject:orderPost];
    }
    if (_cartArr.count == 0) {
        [_commView removeFromSuperview];
    }
    
    UIView *userNameView = [[UIView alloc] init];
    userNameView.frame = CGRectMake(0, 51 * _cartArr.count + 20, RCScreenWidth, 50);
    userNameView.backgroundColor = [UIColor whiteColor];
    [_cartView addSubview:userNameView];
    
    UILabel *nameTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 51 * _cartArr.count  + 20, RCScreenWidth, 50)];
    nameTitle.text = @"姓名:";
    [_cartView addSubview:nameTitle];
    
    _nameField = [[UITextField alloc]initWithFrame:CGRectMake(0, 51 * _cartArr.count  + 20, RCScreenWidth, 50)];
    _nameField.textAlignment = NSTextAlignmentRight;
    [_cartView addSubview:_nameField];
    
    UIView *userAddrView = [[UIView alloc] init];
    userAddrView.frame = CGRectMake(0, 51 * _cartArr.count + 71, RCScreenWidth, 50);
    userAddrView.backgroundColor = [UIColor whiteColor];
    [_cartView addSubview:userAddrView];
    
    UILabel *addressTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 51 * _cartArr.count  + 71, RCScreenWidth, 50)];
    addressTitle.text = @"地址:";
    [_cartView addSubview:addressTitle];
    
    _addressField = [[UITextField alloc]initWithFrame:CGRectMake(0, 51 * _cartArr.count  + 71, RCScreenWidth, 50)];
    _addressField.textAlignment = NSTextAlignmentRight;
    [_cartView addSubview:_addressField];
    
    UIView *phoneView = [[UIView alloc] init];
    phoneView.frame = CGRectMake(0, 51 * _cartArr.count + 122, RCScreenWidth, 50);
    phoneView.backgroundColor = [UIColor whiteColor];
    [_cartView addSubview:phoneView];
    
    UILabel *phoneTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 51 * _cartArr.count  + 122, RCScreenWidth, 50)];
    phoneTitle.text = @"电话:";
    [_cartView addSubview:phoneTitle];
    
    _phoneField = [[UITextField alloc]initWithFrame:CGRectMake(0, 51 * _cartArr.count  + 122, RCScreenWidth, 50)];
    _phoneField.textAlignment = NSTextAlignmentRight;
    [_cartView addSubview:_phoneField];
    
    _totalPriceLabel.text = [NSString stringWithFormat:@"¥%ld",(long)_totalPrice];
}

- (NSArray *)getTagModelArraywithDictionary {
    NSMutableArray *result = [NSMutableArray array];
    for (RCOrderPost *tag in _commitArr) {
        NSDictionary *orderDic = @{@"productID": tag.productID, @"amount":tag.amount};
        [result addObject:orderDic];
    }
    return [result copy];
}

-(void)tapAddView:( UITapGestureRecognizer *)tap{
    NSLog(@"tapped => %ld",tap.view.tag - 1000);
    NSArray *goodListArray = [RCGoods mj_objectArrayWithKeyValuesArray:_cartArr];
    RCGoods *goodInfo = goodListArray[tap.view.tag - 1000];
    long amount = [goodInfo.amount integerValue] + 1;
    NSLog(@"tapped Info:=>%@ =>amount:%ld",goodInfo.productName,amount);
    NSString *amountStr = [NSString stringWithFormat:@"%ld",amount];
    _changeAmountURL = [NSString stringWithFormat:@"shopcars/%@/changeamount",goodInfo.id];
    NSDictionary *dic = @{
                          @"amount" : amountStr
                          };
    [XSHttpTool PUT:_changeAmountURL param:dic success:^(id responseObject) {
        RCPSuccess(@"操作成功");
        [self getCartInfo];
    } failure:^(NSError *error) {
        RCPError(@"添加失败");
    }];
}

-(void)tapMinusView:( UITapGestureRecognizer *)tap{
    NSLog(@"tapped => %ld",tap.view.tag - 1000);
    NSArray *goodListArray = [RCGoods mj_objectArrayWithKeyValuesArray:_cartArr];
    RCGoods *goodInfo = goodListArray[tap.view.tag - 1000];
    long amount = [goodInfo.amount integerValue] - 1;
    if(amount > 0){
        NSLog(@"tapped Info:=>%@ =>amount:%ld",goodInfo.productName,amount);
        NSString *amountStr = [NSString stringWithFormat:@"%ld",amount];
        _changeAmountURL = [NSString stringWithFormat:@"shopcars/%@/changeamount",goodInfo.id];
        NSDictionary *dic = @{
                              @"amount" : amountStr
                              };
        [XSHttpTool PUT:_changeAmountURL param:dic success:^(id responseObject) {
            RCPSuccess(@"操作成功");
            [self getCartInfo];
        } failure:^(NSError *error) {
            RCPError(@"添加失败");
        }];
    }else{
//        _changeAmountURL = [NSString stringWithFormat:@"shopcars/%@",goodInfo.id];
//        [XSHttpTool DELETE:_changeAmountURL param:nil success:^(id responseObject) {
//            RCPSuccess(@"操作成功，一个商品已删除");
//            [self getCartInfo];
//        } failure:^(NSError *error) {
//            RCPError(@"操作失败");
//            [self getCartInfo];
//        }];
    }
}

-(void)pushToOrderVC:(NSDictionary *)pushDic{
    
    self.hidesBottomBarWhenPushed=YES;
    
    RCOrderViewController *orderVC = [[RCOrderViewController alloc]init];
    
    orderVC.orderDic = pushDic;
    
    [self.navigationController pushViewController:orderVC animated:YES];
}


-(void)tapRubblishView:( UITapGestureRecognizer *)tap{
    NSLog(@"tapped to delete=> %ld",tap.view.tag - 10000);
    NSArray *goodListArray = [RCGoods mj_objectArrayWithKeyValuesArray:_cartArr];
    RCGoods *goodInfo = goodListArray[tap.view.tag - 10000];
    _changeAmountURL = [NSString stringWithFormat:@"shopcars/%@",goodInfo.id];
            [XSHttpTool DELETE:_changeAmountURL param:nil success:^(id responseObject) {
//                RCPSuccess(@"操作成功，一个商品已删除");
                [self getCartInfo];
            } failure:^(NSError *error) {
                RCPError(@"操作失败");
                [self getCartInfo];
            }];
}

@end
