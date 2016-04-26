//
//  QYMapLocationVC.m
//  约吧
//
//  Created by 云菲 on 16/4/26.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYLocationMapVC.h"
#import "AppDelegate.h"

#import "QYPinAnnotationView.h"
#import "QYPinAnnotation.h"

#import <CoreLocation/CLLocation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
@interface QYLocationMapVC () <BMKMapViewDelegate>
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *name;

@end

@implementation QYLocationMapVC
-(instancetype)initWithLocation:(CLLocation *)location title:(NSString *)title{
    self = [super init];
    if (self) {
        _location = location;
        _name = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNavigationBar];
    [self.view addSubview:self.mapView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
}

#pragma mark - Custom Methods
-(void)configNavigationBar{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

//取消位置共享
-(void)closeAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BMKMapView Delegate
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
    QYPinAnnotation *annotation = [[QYPinAnnotation alloc] init];
    annotation.coordinate = mapView.centerCoordinate;
    annotation.title = _name;
    [mapView addAnnotation:annotation];
    [mapView selectAnnotation:annotation animated:YES];
}

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    QYPinAnnotationView *annotationView = [[QYPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAnnotation"];
    return annotationView;
}

-(void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    BOOL isHave = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
    NSLog(@"%d", isHave);

    //调起百度地图客户端，若用户没有安装客户端，则调起web百度地图
    BMKOpenDrivingRouteOption *opt = [[BMKOpenDrivingRouteOption alloc] init];//驾车路线
    opt.appScheme = @"baidumapsdk://mapsdk.baidu.com";//用于调起成功后，返回原应用
    //初始化起点节点
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    CLLocationCoordinate2D coor1;
    coor1.latitude = self.currentLocation.coordinate.latitude;
    coor1.longitude = self.currentLocation.coordinate.longitude;
    //指定起点名称
    start.name = @"";
    start.pt = coor1;
    //指定起点
    opt.startPoint = start;
    
    //初始化终点节点
    BMKPlanNode *end = [[BMKPlanNode alloc]init];
    CLLocationCoordinate2D coor2;
    coor2.latitude = self.location.coordinate.latitude;
    coor2.longitude = self.location.coordinate.longitude;
    end.pt = coor2;
    //指定终点名称
    end.name = _name;
    opt.endPoint = end;
    
    [BMKOpenRoute openBaiduMapDrivingRoute:opt];
}

#pragma mark - Getters
-(BMKMapView *)mapView{
    if (_mapView == nil) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _mapView.delegate = self;
        _mapView.zoomLevel = 16;
        _mapView.centerCoordinate = _location.coordinate;
    }
    return _mapView;
}

-(CLLocation *)currentLocation{
    if (_currentLocation == nil) {
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        _currentLocation = app.location;
    }
    return _currentLocation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
