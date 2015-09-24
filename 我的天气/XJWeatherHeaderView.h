//
//  XJWeatherHeaderView.h
//  我的天气
//
//  Created by xuejing on 15/9/18.
//  Copyright (c) 2015年 asone. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XJWeatherHeaderView : UIView
/**
 *  城市
 */
@property (strong, nonatomic)  UILabel *cityLabel;
/**
 *  天气图标
 */
@property (strong, nonatomic)  UIImageView *iconView;
/**
 *  天气描述
 */
@property (strong, nonatomic)  UILabel *conditionsLabel;
/**
 *  当前天气的温度
 */
@property (strong, nonatomic)  UILabel *temperatureLabel;
/**
 *  当天的最低最高温度
 */
@property (strong, nonatomic)  UILabel *highLowLabel;
@end
