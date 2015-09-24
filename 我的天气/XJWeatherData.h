//
//  XJWeatherData.h
//  我的天气
//
//  Created by xuejing on 15/9/19.
//  Copyright (c) 2015年 asone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XJWeatherData : NSObject

/**
 *  日期
 */
@property (strong, nonatomic) NSString *date;
/**
 *  最高温度
 */
@property (assign, nonatomic) float maxTemp;
/**
 *  最低温度
 */
@property (assign, nonatomic) float minTemp;
/**
 *  预报的间隔时间
 */
@property (assign, nonatomic) float time;
/**
 *  当前预报的温度
 */
@property (assign, nonatomic) float temp;
/**
 *  天气的图片
 */
@property (strong, nonatomic) NSURL *iconURL;
/**
 *  天气描述
 */
@property (strong, nonatomic) NSString *weatherDesc;
/**
 *  城市名字
 */
@property (strong, nonatomic) NSString *cityName;

/**
 *  解析每小时的天气情况
 */
+ (instancetype)weatherWithHourlyJSONDic:(NSDictionary *)hourlyDic;
/**
 *  解析每天的天气情况
 */
+ (instancetype)weatherWithDailyJSONDic:(NSDictionary *)dailyDic;
/**
 *  解析头部视图需要的天气数据
 */
+ (instancetype)weatherWithCurrentJSON:(NSDictionary *)currentDic;

@end
