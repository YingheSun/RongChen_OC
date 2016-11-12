//
//  RCNewsDetailViewController.m
//  RongChen
//
//  Created by YingheSun on 16/10/11.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCNewsDetailViewController.h"

@interface RCNewsDetailViewController ()

@property (nonatomic ,strong) UIWebView *webView;

@end

@implementation RCNewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self makeContentShow];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeContentShow{
    self.view.backgroundColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1];
    
    _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, RCScreenWidth, RCScreenHeight)];
    [self.view addSubview:_webView];
    [_webView loadHTMLString:self.Content baseURL:nil];
    [_webView setScalesPageToFit:YES];
}

@end
