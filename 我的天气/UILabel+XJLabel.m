//
//  UILabel+XJLabel.m
//  我的天气
//
//  Created by xuejing on 15/9/19.
//  Copyright (c) 2015年 asone. All rights reserved.
//

#import "UILabel+XJLabel.h"

@implementation UILabel (XJLabel)

+ (instancetype)labelWithFrame:(CGRect)frame {

    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    
    return label;

}

@end
