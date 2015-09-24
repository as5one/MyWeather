//
//  XJMainViewController.m
//  我的天气
//
//  Created by xuejing on 15/9/18.
//  Copyright (c) 2015年 asone. All rights reserved.
//

#import "XJMainViewController.h"

#import "XJWeatherHeaderView.h"
#import "TSMessage.h"
#import "TSMessageView.h"
#import "XJWeatherData.h"

#import "UIImageView+WebCache.h"
#import <CoreLocation/CoreLocation.h>

@interface XJMainViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
/**
 *  tableView
 */
@property (strong, nonatomic) UITableView *tableView;
/**
 *  背景图片
 */
@property (strong, nonatomic) UIImageView *bgImageView;
/**
 *  每天的天气数组
 */
@property (strong, nonatomic) NSArray *dailyArray;
/**
 *  每小时的天气数组
 */
@property (strong, nonatomic) NSArray *hourlyArray;
/**
 *  头部视图
 */
@property (strong, nonatomic) XJWeatherHeaderView *headerView;
//图片缓存的相关属性
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableDictionary *imagesDic;
@property (strong, nonatomic) NSString *cachesPath;
//定位相关的属性
@property (strong, nonatomic) CLLocationManager *mgr;
@property (assign, nonatomic) CLLocationDegrees longitude;
@property (assign, nonatomic) CLLocationDegrees latitude;

@end

@implementation XJMainViewController

- (CLLocationManager *)mgr {

    if (!_mgr) {
        _mgr = [[CLLocationManager alloc] init];
    }
    return _mgr;
}

- (NSOperationQueue *)queue {

    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (NSMutableDictionary *)imagesDic {

    if (!_imagesDic) {
        _imagesDic = [[NSMutableDictionary alloc] init];
    }
    return _imagesDic;
}

- (NSString *)cachesPath {

    if (!_cachesPath) {
        _cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    }
    return _cachesPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //征求用户登陆的同意
    [self getUserLocation];
    
    [self setUpTableView];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self setUpHeaderView];
    
//    [self getAndParseJSON];
}

- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;

}

#pragma mark 定位
- (void)getUserLocation {

    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        
        [self.mgr requestWhenInUseAuthorization];
        
    }else {
        NSLog(@"您有新版本更新");
    }
    
    self.mgr.delegate = self;
    self.latitude = 0.0;
    self.longitude = 0.0;

}

#pragma mark location代理方法实现
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //设定定位的准确度
        self.mgr.desiredAccuracy = kCLLocationAccuracyBest;
        //开始定位
        [self.mgr startUpdatingLocation];
    }else if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"无法获取数据");
        //手动让用户选择城市 弹出城市选择框 请您选择您当前所在的城市
    }
}

//定位到用户的位置，会调用多次
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //获取用户的位置
    CLLocation *location = [locations lastObject];
    self.latitude = location.coordinate.longitude;
    self.longitude = location.coordinate.latitude;
    //手动停止定位
    [self.mgr stopUpdatingLocation];
    
    //开始解析数据
    [self getAndParseJSON];
}

#pragma mark 解析JSON数据
- (void)getAndParseJSON {
    [TSMessage setDefaultViewController:self];
    NSString *urlStr = nil;
    if (self.latitude!=0.0 && self.longitude!=0.0) {
        urlStr = [NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v2/weather.ashx?q=%f,%f&num_of_days=5&format=json&tp=6&key=12eed5db18fc79d78b16d55874dab",self.longitude,self.latitude];
    }else {
        urlStr = [NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v2/weather.ashx?q=beijing&num_of_days=5&format=json&tp=6&key=12eed5db18fc79d78b16d55874dab"];
    }
    
    //q =beijing -->q = 纬度 经度
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *parseError = nil;
        if (error == nil) {
         NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            
            //将模型对象存到数组
            self.hourlyArray = [self weatherFromJSON:weatherDic isHourly:YES];
            self.dailyArray = [self weatherFromJSON:weatherDic isHourly:NO];
            
            
            //回到主线程刷新tableView
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新头部视图控件的文本
                [self updateHeaderView:weatherDic];
                
                [self.tableView reloadData];
            });
            
        }else {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [TSMessage showNotificationWithTitle:@"前方高能预警!!!" subtitle:@"亲,网络小哥正在向您赶来哟" type:TSMessageNotificationTypeWarning];
                
            });
        }
        
        
    }];

    [task resume];
}




#pragma mark 解析JSON的方法
- (void)updateHeaderView:(NSDictionary *)weatherDic {

    //解析头部视图需要的数据
    XJWeatherData *weathermodel = [XJWeatherData weatherWithCurrentJSON:weatherDic];
    
    //更新控件的文本
    //城市名字
    self.headerView.cityLabel.text = weathermodel.cityName;
    //天气描述
    self.headerView.conditionsLabel.text = weathermodel.weatherDesc;
    //当前的天气温度
    self.headerView.temperatureLabel.text = [NSString stringWithFormat:@"%.0f˚",weathermodel.temp];
    //最高最低温度
    self.headerView.highLowLabel.text = [NSString stringWithFormat:@"%.0f˚ / %.0f˚", weathermodel.maxTemp, weathermodel.minTemp];
    
    NSData *data = [NSData dataWithContentsOfURL:weathermodel.iconURL];
    self.headerView.iconView.image = [UIImage imageWithData:data];

}



- (NSArray *)weatherFromJSON:(NSDictionary *)jsonDic isHourly:(BOOL)isHourly {

    NSArray *hourlyArr = jsonDic[@"data"][@"weather"][0][@"hourly"];
    NSArray *dailyArr = jsonDic[@"data"][@"weather"];
    //声明两个可变数组接收数据
    NSMutableArray *hourlyMutableArr = [NSMutableArray array];
    NSMutableArray *dailyMutableArr = [NSMutableArray array];
    
    if (isHourly) {
        //解析每小时的数据
        for (NSDictionary *hourlyDic in hourlyArr) {
            XJWeatherData *hourlyData = [XJWeatherData weatherWithHourlyJSONDic:hourlyDic];
            [hourlyMutableArr addObject:hourlyData];
        }
        
    }else {
        //解析每天的数据
        for (NSDictionary *dailyDic in dailyArr) {
            
            XJWeatherData *dailyData = [XJWeatherData weatherWithDailyJSONDic:dailyDic];
            [dailyMutableArr addObject:dailyData];
        }
    
    }
    
    return isHourly ? [hourlyMutableArr copy] : [dailyMutableArr copy];

}


#pragma mark 初始化tableView
- (void)setUpTableView {
    //1 创建背景视图，并添加到view
    self.bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.bgImageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:self.bgImageView];
    //2 创建tableView，并添加到view
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = self.view.bounds;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.pagingEnabled = YES;
    //设置分隔线
    self.tableView.separatorColor = [UIColor colorWithWhite:0 alpha:0.2];
    //3 设置自己为代理
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
}

#pragma mark 数据源
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return section == 0 ? self.hourlyArray.count + 1 : self.dailyArray.count + 1;

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Hourly Forcast";
            cell.imageView.image = nil;
            cell.detailTextLabel.text = @"";
        }else {
            //获取indexPath对应的模型对象
            XJWeatherData *data = self.hourlyArray[indexPath.row - 1];
            [self configureCell:cell weather:data cellAtIndexPath:indexPath isHourly:YES];
        }
        
    }else {
        if (indexPath.row == 0) {
           cell.textLabel.text = @"Daily Forcast";
           cell.detailTextLabel.text = @"";
           
        }else {
            XJWeatherData *data = self.dailyArray[indexPath.row - 1];
            [self configureCell:cell weather:data cellAtIndexPath:indexPath isHourly:NO];
        }
    
    }
    
    return cell;

}

- (void)configureCell:(UITableViewCell *)cell weather:(XJWeatherData *)weather cellAtIndexPath:(NSIndexPath *)indexPath isHourly:(BOOL)isHourly {
    
    cell.textLabel.text = isHourly ? [NSString stringWithFormat:@"%.0f:00",weather.time] : weather.date;
    cell.detailTextLabel.text = isHourly ? [NSString stringWithFormat:@"%.0f˚", weather.temp] : [NSString stringWithFormat:@"%.0f˚ / %.0f˚", weather.maxTemp, weather.minTemp];
    
    [cell.imageView sd_setImageWithURL:weather.iconURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
}



#pragma mark 代理  计算行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

   NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
   return [UIScreen mainScreen].bounds.size.height / cellCount;
    
}



#pragma mark 初始化HeaderView
- (void)setUpHeaderView {

    self.headerView = [[XJWeatherHeaderView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.headerView.backgroundColor = [UIColor clearColor];
    
    self.tableView.tableHeaderView = self.headerView;

}

//#pragma mark 下载图片
//- (void)downloadImage:(XJWeatherData *)weather cell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
//
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//       
//        //子线程中执行下载操作
//        NSData *iconData = [NSData dataWithContentsOfURL:weather.iconURL];
//        
//        //往字典中缓存已经下载好的图片
//        UIImage *image = [UIImage imageWithData:iconData];
//        self.imagesDic[weather.iconURL] = image;
//        
//        //往沙盒中存图片
//        NSData *data = UIImagePNGRepresentation(image);
//        NSString *filePath = [self.cachesPath stringByAppendingPathComponent:[weather.iconURL lastPathComponent]];
//       
//        [data writeToFile:filePath atomically:YES];
//        
//        //回到主线程设置cell的image
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            //设置cell的图片
//            cell.imageView.image = [UIImage imageWithData:iconData];
//        }];
//        
//    }];
//    
//    [self.queue addOperation:operation];
//}

#warning 在收到系统的内存警告，清空内存数据
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    //先清空字典
    [self.imagesDic removeAllObjects];
    //再清空操作队列(停止队列中所有的下载操作)
    [self.queue cancelAllOperations];


}

#pragma mark 细节处理
//视图将要开始滚动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    //将操作队列挂起(暂停)
    [self.queue setSuspended:YES];
    

}

//视图停止滚动
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    //将操作中的队列继续进行
    [self.queue setSuspended:NO];

}


@end
