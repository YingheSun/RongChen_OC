//
//  RCOrderDetailViewController.m
//  RongChen
//
//  Created by YingheSun on 16/11/10.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCOrderDetailViewController.h"

@interface RCOrderDetailViewController ()

@property (nonatomic ,strong) UIScrollView *orderView;

@property (nonatomic ,strong) UIView *commView;

@end

@implementation RCOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBarView];
    [self makeViewShow];
    [self makeScrollViewShow];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigationbar导航栏设置
-(void)setBarView{
    //左侧的slider menu 取消
    self.navigationItem.title = @"订单详情";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)makeViewShow{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    _orderView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, RCScreenHeight)];
    [self.view addSubview:_orderView];
}

-(void)makeScrollViewShow{
    [_orderView clearsContextBeforeDrawing];
    
    NSArray *detailArr = self.orderDetail[@"orderItem"];
    
    for (int i = 0; i < detailArr.count; i++) {
        
        _commView = [[UIView alloc] init];
        _commView.frame = CGRectMake(0, 51*i, RCScreenWidth, 50);
        _commView.backgroundColor = [UIColor whiteColor];
        [_orderView addSubview:_commView];
        
        UIImageView *coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        [_commView addSubview:coverImage];
        if([detailArr[i][@"coverImage"] isEqualToString:@""]){
            [coverImage setImage:[UIImage imageNamed:@"defaultLoading"]];
        }else{
            NSString *imgStrURL = [NSString stringWithFormat:@"%@%@%@",RCImageURL,detailArr[i][@"coverImage"],@"@!mobile"];
            [coverImage sd_setImageWithURL:[NSURL URLWithString:imgStrURL] placeholderImage:[UIImage imageNamed:@"defaultLoading"]];
        }
        coverImage.layer.cornerRadius = 5.0f;
        [coverImage setClipsToBounds:YES];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, RCScreenWidth - 160, 20)];
        titleLabel.text = detailArr[i][@"name"];
        titleLabel.font = [UIFont systemFontOfSize:12.0f];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commView addSubview:titleLabel];
        
        UILabel *priceView = [[UILabel alloc]initWithFrame:CGRectMake(120 , 5, RCScreenWidth - 160, 20)];
        NSString *priceStr = [NSString stringWithFormat:@"¥%@",detailArr[i][@"price"]];
        priceView.text = priceStr;
        priceView.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
        priceView.font = [UIFont systemFontOfSize:12.0f];
        priceView.numberOfLines = 4;
        [_commView addSubview:priceView];
        
        UILabel *amountView = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth -30 , 5, 30, 20)];
        NSString *amountStr = [NSString stringWithFormat:@"*%@",detailArr[i][@"amount"]];
        amountView.text = amountStr;
        amountView.font = [UIFont systemFontOfSize:12.0f];
        amountView.numberOfLines = 4;
        [_commView addSubview:amountView];
        
        UILabel *totalView = [[UILabel alloc]initWithFrame:CGRectMake(60 , 30, RCScreenWidth - 160, 20)];
        float total = [detailArr[i][@"price"] floatValue] * [detailArr[i][@"amount"] floatValue];
        NSString *totalStr = [NSString stringWithFormat:@"¥%ld",(long)total];
        totalView.text = totalStr;
        totalView.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
        totalView.font = [UIFont systemFontOfSize:12.0f];
        totalView.numberOfLines = 4;
        [_commView addSubview:totalView];
        
        _orderView.contentSize = CGSizeMake(RCScreenWidth, YH(_commView) + 150);
        
    }
    
    UIView *totalView = [[UIView alloc] init];
    totalView.frame = CGRectMake(0, 51 * detailArr.count + 20, RCScreenWidth, 50);
    totalView.backgroundColor = [UIColor whiteColor];
    [_orderView addSubview:totalView];
    
    UILabel *totalTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.4, 50)];
    totalTitle.text = @"总计:";
    totalTitle.textAlignment = NSTextAlignmentRight;
    [totalView addSubview:totalTitle];
    
    UILabel *totalPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(RCScreenWidth * 0.5, 0, RCScreenWidth * 0.4, 50)];
    totalPriceLabel.textAlignment = NSTextAlignmentLeft;
    totalPriceLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    NSString *totalStr = [NSString stringWithFormat:@"¥%@" ,self.orderDetail[@"totalPrice"]];
    totalPriceLabel.text = totalStr;
    [totalView addSubview:totalPriceLabel];
    
    UIView *nameView = [[UIView alloc] init];
    nameView.frame = CGRectMake(0, 51 * detailArr.count + 80, RCScreenWidth, 50);
    nameView.backgroundColor = [UIColor whiteColor];
    [_orderView addSubview:nameView];
    
    UILabel *nameTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.4, 50)];
    nameTitle.text = @"姓名:";
    nameTitle.textAlignment = NSTextAlignmentLeft;
    [nameView addSubview:nameTitle];
    
    UILabel *nameTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, 50)];
    nameTextLabel.textAlignment = NSTextAlignmentRight;
    nameTextLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    nameTextLabel.text = self.orderDetail[@"receiver"];
    [nameView addSubview:nameTextLabel];

    UIView *addressView = [[UIView alloc] init];
    addressView.frame = CGRectMake(0, 51 * detailArr.count + 131, RCScreenWidth, 50);
    addressView.backgroundColor = [UIColor whiteColor];
    [_orderView addSubview:addressView];
    
    UILabel *addressTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.4, 50)];
    addressTitle.text = @"地址:";
    addressTitle.textAlignment = NSTextAlignmentLeft;
    [addressView addSubview:addressTitle];
    
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, 50)];
    addressLabel.textAlignment = NSTextAlignmentRight;
    addressLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    addressLabel.text = self.orderDetail[@"receiverAddress"];
    [addressView addSubview:addressLabel];
    
    UIView *phoneView = [[UIView alloc] init];
    phoneView.frame = CGRectMake(0, 51 * detailArr.count + 182, RCScreenWidth, 50);
    phoneView.backgroundColor = [UIColor whiteColor];
    [_orderView addSubview:phoneView];
    
    UILabel *phoneTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth * 0.4, 50)];
    phoneTitle.text = @"电话:";
    phoneTitle.textAlignment = NSTextAlignmentLeft;
    [phoneView addSubview:phoneTitle];
    
    UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, 50)];
    phoneLabel.textAlignment = NSTextAlignmentRight;
    phoneLabel.textColor = [UIColor colorWithRed:30.0f/255.0f green:190.0f/255.0f blue:144.0f/255.0f alpha:1];
    phoneLabel.text = self.orderDetail[@"receiverPhone"];
    [phoneView addSubview:phoneLabel];

}


@end
