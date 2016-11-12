//
//  RCSliderMenuViewController.h
//  RongChen
//
//  Created by 孙滢贺 on 16/9/26.
//  Copyright © 2016年 SoundLife. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HomeMenuViewDelegate <NSObject>

-(void)LeftMenuViewClick:(NSInteger)tag;

@end

@interface RCSliderMenuViewController : UIView

@property (nonatomic ,weak)id <HomeMenuViewDelegate> customDelegate;

@end
