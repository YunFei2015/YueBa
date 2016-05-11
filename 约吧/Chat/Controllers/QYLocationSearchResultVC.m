//
//  QYMapSearchResultVC.m
//  约吧
//
//  Created by 云菲 on 3/28/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYLocationSearchResultVC.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface QYLocationSearchResultVC ()  <UITableViewDelegate, UITableViewDataSource, BMKPoiSearchDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) BMKPoiSearch *poiSearch;
@end

@implementation QYLocationSearchResultVC

- (void)viewDidLoad {
    [self.view addSubview:self.tableView];
    self.results = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.poiSearch.delegate = self;
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.poiSearch.delegate = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Custom Methods
-(void)searchAddressWithKeyword:(NSString *)keyword ofPage:(int)pageIndex{
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc] init];
    option.pageIndex = pageIndex;
    option.pageCapacity = 20;
    option.keyword = keyword;
    option.location = _location.coordinate;
    option.radius = 5000;
    if ([self.poiSearch poiSearchNearBy:option]) {
        NSLog(@"发起检索成功");
    }else{
        NSLog(@"发起检索失败");
    }
    option = nil;
}

#pragma mark - UISearchResultUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *keyword = searchController.searchBar.text;
    if (keyword) {
        [self searchAddressWithKeyword:searchController.searchBar.text ofPage:0];
    }else{
        [_results removeAllObjects];
        [_tableView reloadData];
    }
}

#pragma mark - BMKPoiSearch Delegate
-(void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        [self.results removeAllObjects];
        [self.results addObjectsFromArray:poiResult.poiInfoList];
        [_tableView reloadData];
    }else{
        NSLog(@"未找到结果");
    }
}

#pragma mark - UITableView Delegate & DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _results.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCellSearched"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressCellSearched"];
    }
    
    BMKPoiInfo *info = _results[indexPath.row];
    cell.textLabel.text = info.name;
    cell.detailTextLabel.text = info.address;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BMKPoiInfo *info = _results[indexPath.row];
    //TODO: 改成用block块
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddressToLocateNotification object:self userInfo:@{@"info" : info}];
}

#pragma mark - Getters
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.rowHeight = 50;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tableView;
}

-(BMKPoiSearch *)poiSearch{
    if (_poiSearch == nil) {
        _poiSearch = [[BMKPoiSearch alloc] init];
    }
    return _poiSearch;
}

@end
