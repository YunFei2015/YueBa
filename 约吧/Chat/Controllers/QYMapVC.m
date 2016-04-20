//
//  QYMapViewController.m
//  约吧
//
//  Created by 云菲 on 3/28/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYMapVC.h"
#import "AppDelegate.h"
#import "QYMapAddrCell.h"
#import "QYCurrentAnnotation.h"
#import "QYCurrentAnnotationView.h"

#import "QYPinAnnotationView.h"

#import "QYMapSearchResultVC.h"
#import "QYLocationManager.h"

#import "QYChatManager.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

#define kMapViewHeight kScreenH / 2.f
#define kTableViewHeight kScreenH - kMapViewHeight
#define kNearByCapacityPerPage 20
#define kNearBySearchRadius 500



@interface QYMapVC () <BMKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, BMKPoiSearchDelegate, QYLocationManagerDelegate>
@property (strong, nonatomic) BMKPoiSearch *poiSearch;
@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) QYPinAnnotation *pinAnnotation;

@property (strong, nonatomic) UITableView *addrListTableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *nearbyBuildings;
@property (strong, nonatomic) NSString *selectedBuildingAddress;


@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic) BOOL firstIsPinAddr;
@property (nonatomic) BOOL isSearchingActivated;



@end

@implementation QYMapVC
#pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNavigationBar];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.addrListTableView];
    _nearbyBuildings = [NSMutableArray array];
    
    self.addrListTableView.delegate = self;
    self.addrListTableView.dataSource = self;
    
    //拿到当前位置
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *location = appDelegate.location;
    NSLog(@"%f,%f", location.coordinate.latitude, location.coordinate.longitude);
    _currentLocation = location;
    
    //在地图上标注当前位置
    [self configMapWithLocation:_currentLocation];
    
    //代理
    [QYLocationManager sharedInstance].delegate = self;
//    [[QYLocationManager sharedInstance] startToUpdateLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateAddress:) name:kAddressToLocateNotification object:self.searchController.searchResultsUpdater];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddressToLocateNotification object:self.searchController.searchResultsUpdater];
}


-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.poiSearch.delegate = self;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    self.mapView.delegate = nil; // 不用时，置nil
    self.poiSearch.delegate = nil;
}

#pragma mark - Custom Methods
-(void)configNavigationBar{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSharing)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
}

//搜索地点
-(void)search{
    [self presentViewController:self.searchController animated:YES completion:^{
        UIViewController *resultVC = (UIViewController *)_searchController.searchResultsUpdater;
        [resultVC setValue:_currentLocation forKey:@"location"];
    }];
}

//取消位置共享
-(void)cancelSharing{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//在地图上标注当前位置
-(void)configMapWithLocation:(CLLocation *)location{
    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
    self.mapView.zoomLevel = 16;
    
    QYCurrentAnnotation *annotation = [[QYCurrentAnnotation alloc] init];
    annotation.coordinate = location.coordinate;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:annotation];
    
    [self updatePinAnnotationToLocation:location.coordinate];
    _selectedBuildingAddress = @"当前位置";
    [self.mapView addAnnotation:self.pinAnnotation];
}

//更新大头针坐标
-(void)updatePinAnnotationToLocation:(CLLocationCoordinate2D)location{
    self.pinAnnotation.coordinate = location;
}

//kAddressToLocateNotification响应事件
-(void)locateAddress:(NSNotification *)notification{
    [self.searchController dismissViewControllerAnimated:YES completion:^{
        self.searchController.searchBar.text = @"";
        BMKPoiInfo *info = notification.userInfo[@"info"];
        [self geocodeAddress:info];
    }];
}

//对指定地址进行地理反编码
-(void)geocodeAddress:(BMKPoiInfo *)info{
    _selectedBuildingAddress = info.name;
    [[QYLocationManager sharedInstance] getLocationWithAddress:info.address];
}

//点击泡泡
-(void)shareBtnAction{
    //发送位置消息
    //        CGRect rect = [mapView convertRegion:mapView.region toRectToView:self.view];
    //        UIImage *locationImg = [mapView takeSnapshot:rect];
    [self dismissViewControllerAnimated:YES completion:^{
        _sendLocationToShare(self.pinAnnotation);
//        [[QYChatManager sharedManager] sendLocationMessageWithAnnotation:self.pinAnnotation];
    }];
}


//获取地址列表
//-(void)searchNearbyBuildingsWithLocation:(CLLocationCoordinate2D)location address:(NSString *)address atPage:(int)pageIndex{
//    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc] init];
//    option.pageIndex = pageIndex;
//    option.pageCapacity = kNearByCapacityPerPage;
//    option.keyword = address;
//    option.location = location;
//    option.radius = kNearBySearchRadius;
//    if ([self.poiSearch poiSearchNearBy:option]) {
//        NSLog(@"发起检索成功");
//    }else{
//        NSLog(@"发起检索失败");
//    }
//    option = nil;
//    
//}

#pragma mark - QYLocationManager Delegate
//-(void)didFinishUpdateLocation:(CLLocation *)location success:(BOOL)success{
//    NSLog(@"%f,%f", location.coordinate.latitude, location.coordinate.longitude);
//    //用户当前位置
//    _currentLocation = location;
//    
//    //在地图上标注当前位置
//    if (success) {
//        [self configMapWithLocation:_currentLocation];
//        [QYLocationManager sharedInstance] ;
//    }
//    
//}

-(void)didGetLocation:(CLLocationCoordinate2D)location success:(BOOL)success{
    if (success) {
        [self updatePinAnnotationToLocation:location];
        self.mapView.centerCoordinate = location;
        
    }else{
        //获取经纬度失败
    }
}

-(void)didGetAddress:(NSString *)address nearBy:(NSArray *)nearByList success:(BOOL)success{
    //获取当前地图选中的点
    _firstIsPinAddr = YES;
    BMKPoiInfo *firstInfo = [[BMKPoiInfo alloc] init];
    firstInfo.name = _selectedBuildingAddress ? _selectedBuildingAddress : @"当前位置";
    firstInfo.address = address;
    
    //如果获取到的地址不在附近地址列表中，则显示地址名称；否则，保持不变（显示建筑名称）
    if (_selectedBuildingAddress) {
        self.pinAnnotation.title = _selectedBuildingAddress;
        _selectedBuildingAddress = nil;
    }else{
        self.pinAnnotation.title = address;
    }
    
    //获取附近地址列表
    [_nearbyBuildings removeAllObjects];
    [_nearbyBuildings addObject:firstInfo];
    [_nearbyBuildings addObjectsFromArray:nearByList];
    [self.addrListTableView reloadData];
    
    [self.mapView selectAnnotation:self.pinAnnotation animated:YES];
    
}

#pragma mark - BMKMap View Delegate
//地图加载完成后，获取当前地址经纬度
-(void)mapViewDidFinishLoading:(BMKMapView *)mapView{
//    [mapView selectAnnotation:self.pinAnnotation animated:YES];
    //获取大头针所在位置的地址
    [[QYLocationManager sharedInstance] getAddressWithLocation:mapView.centerCoordinate];
}

//地图区域改变之后，获取当前地址经纬度
-(void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    //获取大头针所在位置的地址
    [[QYLocationManager sharedInstance] getAddressWithLocation:mapView.centerCoordinate];
}

//地区区域即将改变，气泡消失
-(void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    [mapView deselectAnnotation:self.pinAnnotation animated:YES];
}

//地图渲染过程中，移动大头针的位置
-(void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status{
    [self updatePinAnnotationToLocation:mapView.region.center];
}

//设置地图标注的外观
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[QYPinAnnotation class]]) {
        QYPinAnnotationView *pinAnnotationView = [[QYPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 40, 41);
        [btn setTitle:@"分享" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
        pinAnnotationView.rightCalloutAccessoryView = btn;
        
        return pinAnnotationView;
    }else if ([annotation isKindOfClass:[QYCurrentAnnotation class]]){
        QYCurrentAnnotationView *currentAnnotationView = [[QYCurrentAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 20, 50)];
        return currentAnnotationView;
    }else
        return nil;
}


#pragma mark - BMKPoiSearch Delegate
-(void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        [self.nearbyBuildings removeAllObjects];
        [self.nearbyBuildings addObjectsFromArray:poiResult.poiInfoList];
        [_addrListTableView reloadData];
    }else{
        NSLog(@"未找到结果");
    }
}

#pragma mark - UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.nearbyBuildings.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QYMapAddrCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nearbyCell" forIndexPath:indexPath];
    
    //Configure cell...
    if (indexPath.row == 0 && _firstIsPinAddr) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    BMKPoiInfo *info = _nearbyBuildings[indexPath.row];
    cell.info = info;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QYMapAddrCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES];
    if (indexPath.row == 0 && _firstIsPinAddr) {
        return;
    }
    if (indexPath.row > 0 && _firstIsPinAddr){
        //删除第一行
        _firstIsPinAddr = NO;
        [_nearbyBuildings removeObjectAtIndex:0];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    //获取所点击行的经纬度
    BMKPoiInfo *info = cell.info;
    [self geocodeAddress:info];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    QYMapAddrCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
}


#pragma mark - Getters
-(BMKMapView *)mapView{
    if (_mapView == nil) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kMapViewHeight)];
    }
    return _mapView;
}

-(QYPinAnnotation *)pinAnnotation{
    if (_pinAnnotation == nil) {
        _pinAnnotation = [[QYPinAnnotation alloc] init];
    }
    return _pinAnnotation;
}

-(BMKPoiSearch *)poiSearch{
    if (_poiSearch == nil) {
        _poiSearch = [[BMKPoiSearch alloc] init];
    }
    return _poiSearch;
}

-(UITableView *)addrListTableView{
    if (_addrListTableView == nil) {
        _addrListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kMapViewHeight, kScreenW, kTableViewHeight) style:UITableViewStylePlain];
        _addrListTableView.rowHeight = 60;
        [_addrListTableView registerNib:[UINib nibWithNibName:@"QYMapAddrCell" bundle:nil] forCellReuseIdentifier:@"nearbyCell"];
    }
    return _addrListTableView;
}

-(UISearchController *)searchController{
    if (_searchController == nil) {
        QYMapSearchResultVC *resultVC = [[QYMapSearchResultVC alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:resultVC];
        _searchController.searchResultsUpdater = resultVC;
        _searchController.hidesNavigationBarDuringPresentation = NO;
    }
    return _searchController;
}

@end
