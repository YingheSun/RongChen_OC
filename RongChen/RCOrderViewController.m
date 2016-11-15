//
//  RCOrderViewController.m
//  RongChen
//
//  Created by YingheSun on 16/11/8.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCOrderViewController.h"
#import "RCGoods.h"

@interface RCOrderViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic ,strong) UIScrollView *cartView;
@property (nonatomic ,strong) UIView *commView;
@property (nonatomic ,strong) UITextField *nameField;
@property (nonatomic ,strong) UITextField *addressField;
@property (nonatomic ,strong) UITextField *phoneField;

@property (nonatomic ,strong) NSString *payOrderURL;

@property (nonatomic ,strong) NSMutableArray *cartArr;
@property (nonatomic ,strong) UILabel *amountLabel;
@property (nonatomic ,strong) UILabel *totalPriceLabel;
@property (nonatomic ,assign) NSInteger totalPrice;

@end

@implementation RCOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _payOrderURL = [NSString stringWithFormat:@"orders/%@/pay",self.orderDic[@"id"]];
    _cartArr = [[NSMutableArray alloc]init];
    [self setBarView];
    [self makeViewShow];
    [self resolveData:self.orderDic[@"orderItem"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    //左侧的slider menu 取消
    self.navigationItem.title = @"订单";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)makeViewShow{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    _cartView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, RCScreenHeight - 100)];
    [self.view addSubview:_cartView];
    
    UIView *totalBar = [[UIView alloc]initWithFrame:CGRectMake(0, RCScreenHeight - 100, RCScreenWidth, 50)];
    totalBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:totalBar];
    
    UILabel *totalTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.4, 50)];
    totalTitle.text = @"合计:";
    totalTitle.textAlignment = NSTextAlignmentRight;
    [totalBar addSubview:totalTitle];
    
    _totalPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.5, 0, RCScreenWidth * 0.4, 50)];
    _totalPriceLabel.textAlignment = NSTextAlignmentLeft;
    _totalPriceLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [totalBar addSubview:_totalPriceLabel];
    
    UIButton *submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, RCScreenHeight - 50, RCScreenWidth, 50)];
    submitBtn.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    [submitBtn addTarget:self action:@selector(makeOrderPay) forControlEvents:UIControlEventTouchUpInside];
    [submitBtn setTitle:@"立即支付" forState:UIControlStateNormal];
    submitBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:submitBtn];
}

- (void)makeOrderPay{
    [XSHttpTool PUT:_payOrderURL param:nil success:^(id responseObject) {
        RCPSuccess(@"支付成功");
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        RCPError(@"支付失败");
    }];
}

#pragma mark - 处理数据
- (void)resolveData:(NSArray *)dataArr{
    [_cartArr removeAllObjects];
    [_cartArr addObjectsFromArray:dataArr];
    [self makeScrollViewShow];
}

-(void)makeScrollViewShow{
    [_cartView clearsContextBeforeDrawing];
    _totalPrice = 0;
    
    for (int i = 0; i < _cartArr.count; i++) {
        
        _commView = [[UIView alloc] init];
        _commView.frame = CGRectMake(0, 51*i, RCScreenWidth, 50);
        _commView.backgroundColor = [UIColor whiteColor];
        _commView.tag = 1000 + i;
        [_cartView addSubview:_commView];
        
        UIImageView *coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        [_commView addSubview:coverImage];
        NSString *imageStr = _cartArr[i][@"coverImage"];
        if(imageStr.length == 0){
            [coverImage setImage:[UIImage imageNamed:@"defaultLoading"]];
        }else{
            NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,imageStr,@"@!mobile"];
            NSLog(@"loading => %@ ",imgStrURL);
            [coverImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"defaultLoading"]];
        }
        coverImage.layer.cornerRadius = 5.0f;
        [coverImage setClipsToBounds:YES];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, RCScreenWidth - 160, 20)];
        titleLabel.text = _cartArr[i][@"name"];
        titleLabel.font = [UIFont systemFontOfSize:12.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *priceView = [[UILabel alloc]initWithFrame:CGRectMake(120 , 5, RCScreenWidth - 160, 20)];
        NSString *priceStr = [NSString stringWithFormat:@"¥%@",_cartArr[i][@"price"]];
        priceView.text = priceStr;
        priceView.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
        priceView.font = [UIFont systemFontOfSize:12.0f];
        priceView.numberOfLines = 4;
        [_commView addSubview:priceView];
        
        UILabel *amountView = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth -30 , 5, 30, 20)];
        NSString *amountStr = [NSString stringWithFormat:@"*%@",_cartArr[i][@"amount"]];
        amountView.text = amountStr;
        amountView.font = [UIFont systemFontOfSize:12.0f];
        amountView.numberOfLines = 4;
        [_commView addSubview:amountView];
        
        UILabel *totalView = [[UILabel alloc]initWithFrame:CGRectMake(60 , 30, RCScreenWidth - 160, 20)];
        float total = [_cartArr[i][@"price"] floatValue] * [_cartArr[i][@"amount"] floatValue];
        NSString *totalStr = [NSString stringWithFormat:@"¥%ld",(long)total];
        totalView.text = totalStr;
        totalView.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
        totalView.font = [UIFont systemFontOfSize:12.0f];
        totalView.numberOfLines = 4;
        [_commView addSubview:totalView];
        
        _cartView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView) + 170);
        
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
    _nameField.text = self.orderDic[@"receiver"];
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
    _addressField.text = self.orderDic[@"receiverAddress"];
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
    _phoneField.text = self.orderDic[@"receiverPhone"];
    [_cartView addSubview:_phoneField];
    
    _totalPriceLabel.text = [NSString stringWithFormat:@"¥%@",self.orderDic[@"totalPrice"]];
}

@end
