//
//  XJWeatherHeaderView.m
//  我的天气
//
//  Created by xuejing on 15/9/18.
//  Copyright (c) 2015年 asone. All rights reserved.
//

#import "XJWeatherHeaderView.h"
#import "UMSocial.h"

static CGFloat inset = 20;
static CGFloat iconH = 40;
static CGFloat temperatureH = 100;
static CGFloat statusBarH = 20;

@implementation XJWeatherHeaderView

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        CGFloat temperatureY = frame.size.height - temperatureH - iconH;
        //1 cityLabel
        self.cityLabel = [UILabel labelWithFrame:CGRectMake(inset, statusBarH, frame.size.width - 2 * inset, iconH)];
//        self.cityLabel.backgroundColor = [UIColor redColor];
        self.cityLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.cityLabel];
        
        //2 iconView
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(inset,temperatureY - iconH, iconH, iconH)];
        self.iconView.image = [UIImage imageNamed:@"placeholder"];
        self.iconView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.iconView];
        
        //3 conditionsLabel
        self.conditionsLabel = [UILabel labelWithFrame:CGRectMake(inset + iconH ,temperatureY - iconH , frame.size.width - 2 * inset - iconH, iconH)];
        self.conditionsLabel.text = @"clear";
//        self.conditionsLabel.backgroundColor = [UIColor orangeColor];
        self.conditionsLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.conditionsLabel];
        
        //4 temperatureLabel
        self.temperatureLabel = [UILabel labelWithFrame:CGRectMake(inset,temperatureY , frame.size.width - 2 * inset, temperatureH)];
        self.temperatureLabel.backgroundColor = [UIColor purpleColor];
        self.temperatureLabel.text = @"0˚";
        self.temperatureLabel.textAlignment = NSTextAlignmentLeft;
        self.temperatureLabel.font = [UIFont systemFontOfSize:70];
        [self addSubview:self.temperatureLabel];
        
        //5 highLowLabel
        self.highLowLabel = [UILabel labelWithFrame:CGRectMake(inset, frame.size.height - iconH, frame.size.width - 2 * inset, iconH)];
        self.highLowLabel.backgroundColor = [UIColor greenColor];
        self.highLowLabel.text = @"0˚ / 0˚";
        self.highLowLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.highLowLabel];
        
       
        
    }
    return self;
}


@end
