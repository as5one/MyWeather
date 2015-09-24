//
//  XJWeatherData.m
//  我的天气
//
//  Created by xuejing on 15/9/19.
//  Copyright (c) 2015年 asone. All rights reserved.
//

#import "XJWeatherData.h"

@implementation XJWeatherData

+ (instancetype)weatherWithHourlyJSONDic:(NSDictionary *)hourlyDic {

    return [[self alloc] initWithHourlyJSONDic:hourlyDic];

}

- (instancetype)initWithHourlyJSONDic:(NSDictionary *)hourlyDic {

    if (self = [super init]) {
    
        self.temp = [hourlyDic[@"tempC"] floatValue];

        self.time = [hourlyDic[@"time"] floatValue] / 100;

        NSString *iconStr = hourlyDic[@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
    }
    return self;
}

+ (instancetype)weatherWithDailyJSONDic:(NSDictionary *)dailyDic {

    return [[self alloc] initWithDailyJSONDic:dailyDic];
}

- (instancetype)initWithDailyJSONDic:(NSDictionary *)dailyDic {

    if (self = [super init]) {
        
        self.date = dailyDic[@"date"];
        
        self.maxTemp = [dailyDic[@"maxtempC"] floatValue];
        
        self.minTemp = [dailyDic[@"mintempC"] floatValue];
        
        NSString *iconStr =  dailyDic[@"hourly"][0][@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
    }
    return self;
}

+ (instancetype)weatherWithCurrentJSON:(NSDictionary *)currentDic {
    
    return [[self alloc] initWithCurrentJSON:currentDic];
}

- (instancetype)initWithCurrentJSON:(NSDictionary *)currentDic {

    if (self = [super init]) {
        
        NSDictionary *dataDic = currentDic[@"data"];
        
        self.cityName = dataDic[@"request"][0][@"query"];
        self.weatherDesc = dataDic[@"current_condition"][0][@"weatherDesc"][0][@"value"];
        NSString *iconStr = dataDic[@"current_condition"][0][@"weatherIconUrl"][0][@"value"];
        self.iconURL = [NSURL URLWithString:iconStr];
        
        self.temp = [dataDic[@"current_condition"][0][@"temp_C"] floatValue];
        self.maxTemp = [dataDic[@"weather"][0][@"maxtempC"] floatValue];
        self.minTemp = [dataDic[@"weather"][0][@"mintempC"] floatValue];
        
        
    }
    
    return self;

}
@end
