//
//  RCSliderMenuViewController.m
//  RongChen
//
//  Created by 孙滢贺 on 16/9/26.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import "RCSliderMenuViewController.h"

#define ImageviewWidth    18
#define Frame_Width       self.frame.size.width
#define Frame_Height       self.frame.size.height

@interface RCSliderMenuViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong)UITableView *contentTableView;

@end

@implementation RCSliderMenuViewController

-(instancetype)initWithFrame:(CGRect)frame{
    
    if(self = [super initWithFrame:frame]){
        [self initView];
    }
    return  self;
}

-(void)initView{
    
    self.backgroundColor = [UIColor whiteColor];
    //添加背景
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Frame_Width, Frame_Height)];
    [backgroundView setImage:[UIImage imageNamed:@"菜单背景"]];
    [self addSubview:backgroundView];
    
    //添加头部
    UIView *headerView     = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Frame_Width, 120)];
    CGFloat width          = 120/2;
    
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(12, (120 - width) / 2, width, width)];
    imageview.layer.cornerRadius = imageview.frame.size.width / 2;
    imageview.layer.masksToBounds = YES;
    [imageview setImage:[UIImage imageNamed:@"HeadIcon"]];
    [headerView addSubview:imageview];
    
    UILabel *NameLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageview.frame.size.width + imageview.frame.origin.x * 2, imageview.frame.origin.y, 90, imageview.frame.size.height)];
    [NameLabel setText:@"郭志达"];
    [headerView addSubview:NameLabel];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 119, Frame_Width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    
    
    [self addSubview:headerView];
    [self addSubview:lineView];
    
    //中间tableview
    self.contentTableView        = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, Frame_Width, 46 * 6)
                                                                       style:UITableViewStylePlain];
    self.contentTableView.dataSource          = self;
    self.contentTableView.delegate            = self;
    self.contentTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.contentTableView setBackgroundColor:[UIColor clearColor]];
//    self.contentTableView.separatorStyle      = UITableViewCellSeparatorStyleNone;
    self.contentTableView.separatorColor = [UIColor whiteColor];
    [self addSubview:self.contentTableView];
    
}


#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 46 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = [NSString stringWithFormat:@"LeftView%li",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
//    UILabel *tableLine = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, Frame_Width-20, 0.5)];
//    [cell addSubview:tableLine];
    cell.hidden = NO;
    switch (indexPath.row) {
        case 0:
        {
            [cell.imageView setImage:[UIImage imageNamed:@"首页－菜单页"]];
            [cell.textLabel setText:@"首页"];
        }
            break;
        case 1:
        {
            [cell.imageView setImage:[UIImage imageNamed:@"推荐菜单页"]];
            [cell.textLabel setText:@"推荐"];
        }
            break;
        case 2:
        {
            [cell.imageView setImage:[UIImage imageNamed:@"分类"]];
            [cell.textLabel setText:@"分类"];
        }
            break;
        case 3:
        {
            [cell.imageView setImage:[UIImage imageNamed:@"管理"]];
            [cell.textLabel setText:@"管理"];
        }
            break;
        case 4:{
            [cell.imageView setImage:[UIImage imageNamed:@"设置"]];
            [cell.textLabel setText:@"设置"];
        }
            break;

        case 5:
        {
            [cell.imageView setImage:[UIImage imageNamed:@"反馈"]];
            [cell.textLabel setText:@"反馈"];
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.customDelegate respondsToSelector:@selector(LeftMenuViewClick:)]){
        [self.customDelegate LeftMenuViewClick:indexPath.row];
    }
    
}

@end
