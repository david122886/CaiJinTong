//
//  LearningMaterialsViewController.m
//  CaiJinTongApp
//
//  Created by david on 14-1-8.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "LearningMaterialsViewController.h"
#import "DRImageButton.h"
/*
 显示资料列表
 */
@interface LearningMaterialsViewController ()
- (IBAction)timeSortBtClicked:(id)sender;
@property (strong, nonatomic) IBOutletCollection(DRImageButton) NSArray *drImageButtons;
- (IBAction)defaultSortBtClicked:(id)sender;
- (IBAction)nameSortBtClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *searchArray;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (nonatomic,assign) BOOL isReloading;//正在下载中
@property (nonatomic,assign) LearningMaterialsSortType sortType;
@property (nonatomic,strong) NSString *searchContent;

@property (nonatomic,strong) SearchLearningMatarilasListInterface *searchMaterialInterface;
@property (nonatomic,strong) LearningMatarilasListInterface *learningMaterialListInterface;

@property (nonatomic,strong) MJRefreshHeaderView *headerRefreshView;
@property (nonatomic,strong) MJRefreshFooterView *footerRefreshView;
@end

@implementation LearningMaterialsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc{
    [self.footerRefreshView free];
    [self.headerRefreshView free];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.drnavigationBar.titleLabel.text = @"我的资料";
    self.drnavigationBar.searchBar.searchTextLabel.placeholder = @"搜索资料";
    [self.drnavigationBar hiddleBackButton:YES];
	// Do any additional setup after loading the view.
}


-(void)changeLearningMaterialsDate:(NSArray*)learningMaterialArr withSortType:(LearningMaterialsSortType)sortType withCategoryId:(NSString*)categoryId widthAllDataCount:(int)dataCount isSearch:(BOOL)isSearch{
    if (!learningMaterialArr) {
        return;
    }
    self.isSearch = isSearch;
    self.totalCountLabel.text = [NSString stringWithFormat:@"目前有(%d)份资料",dataCount];
    self.lessonCategoryId = categoryId;
    self.dataArray = [NSMutableArray arrayWithArray:learningMaterialArr];
//    self.sortType = sortType;
    [self.tableView reloadData];
    [self.headerRefreshView endRefreshing];
    [self.footerRefreshView endRefreshing];
    self.headerRefreshView.isForbidden = NO;
    self.footerRefreshView.isForbidden = NO;
}
#pragma mark DRSearchBarDelegate搜索
-(void)drSearchBar:(DRSearchBar *)searchBar didBeginSearchText:(NSString *)searchText{
    self.isSearch = YES;
    UserModel *user = [[CaiJinTongManager shared] user];
     [MBProgressHUD showHUDAddedToTopView:self.view animated:YES];
    self.searchContent = searchText;
    [self.searchMaterialInterface searchLearningMaterilasListWithUserId:user.userId withSearchContent:self.searchContent withPageIndex:0 withSortType:self.sortType];
}

-(void)drSearchBar:(DRSearchBar *)searchBar didCancelSearchText:(NSString *)searchText{
    self.isSearch = NO;
    [self.tableView reloadData];
}
#pragma mark --

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark sort排序
- (IBAction)timeSortBtClicked:(id)sender {
    self.sortType = LearningMaterialsSortType_Date;
    UserModel *user = [[CaiJinTongManager shared] user];
     [MBProgressHUD showHUDAddedToTopView:self.view animated:YES];
    self.isReloading = YES;
    [self.learningMaterialListInterface downloadlearningMaterilasListForCategoryId:self.lessonCategoryId withUserId:user.userId withPageIndex:0 withSortType:self.sortType];
    [self sortButtnHighlight:(UIButton *)sender];
}

- (IBAction)defaultSortBtClicked:(id)sender {
    UserModel *user = [[CaiJinTongManager shared] user];
    self.sortType = LearningMaterialsSortType_Default;
     [MBProgressHUD showHUDAddedToTopView:self.view animated:YES];
    self.isReloading = YES;
    [self.learningMaterialListInterface downloadlearningMaterilasListForCategoryId:self.lessonCategoryId withUserId:user.userId withPageIndex:0 withSortType:self.sortType];
    [self sortButtnHighlight:(UIButton *)sender];
}

- (IBAction)nameSortBtClicked:(id)sender {
    UserModel *user = [[CaiJinTongManager shared] user];
    self.sortType = LearningMaterialsSortType_Name;
    [MBProgressHUD showHUDAddedToTopView:self.view animated:YES];
    self.isReloading = YES;
    [self.learningMaterialListInterface downloadlearningMaterilasListForCategoryId:self.lessonCategoryId withUserId:user.userId withPageIndex:0 withSortType:self.sortType];
    [self sortButtnHighlight:(UIButton *)sender];
}

-(void)sortButtnHighlight:(UIButton *)sender{
    DRImageButton *drImageButton = (DRImageButton *)[sender superview];
    for(DRImageButton *btn in self.drImageButtons){
        if ([btn isEqual:drImageButton]) {
            [btn setBackgroundColor:[UIColor colorWithRed:102.0/255.0 green:204.0/255.0 blue:255.0/255.0 alpha:1.0]];
            for(UIView *subview in btn.subviews){
                if([subview isKindOfClass:[UILabel class]]){
                    ((UILabel *)subview).textColor = [UIColor whiteColor];
                }
            }
        }else{
            [btn setBackgroundColor:[UIColor colorWithRed:223.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0]];
            for(UIView *subview in btn.subviews){
                if([subview isKindOfClass:[UILabel class]]){
                    ((UILabel *)subview).textColor = [UIColor lightGrayColor];
                }
            }
        }
    }
}

#pragma mark --

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark --

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LearningMaterialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.path = indexPath;
    cell.delegate = self;
    LearningMaterials *material = self.isSearch?[self.searchArray objectAtIndex:indexPath.row]:[self.dataArray objectAtIndex:indexPath.row];
    [cell setLearningMaterialData:material];
    if (indexPath.row%2 == 0) {
        cell.cellBackView.backgroundColor = [UIColor colorWithRed:235/255.0 green:245/255.0 blue:255/255.0 alpha:1];
    }else{
        cell.cellBackView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.isSearch? [self.searchArray count]:[self.dataArray count];
}


#pragma mark --

#pragma mark LearningMaterialCellDelegate
-(void)learningMaterialCell:(LearningMaterialCell *)cell scanLearningMaterialFileAtIndexPath:(NSIndexPath *)path{
    LearningMaterials *material = self.isSearch?[self.searchArray objectAtIndex:path.row]:[self.dataArray objectAtIndex:path.row];
    if (material.materialFileType == LearningMaterialsFileType_other || material.materialFileType == LearningMaterialsFileType_zip) {
        [Utility errorAlert:@"无法查看文件内容，请到电脑上下载查看！"];
    }else{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:(CGRect){0,0,800,700}];
        webView.scrollView.minimumZoomScale = 0.5;
        webView.scrollView.maximumZoomScale = 2.0;
        webView.scalesPageToFit = YES;
        UIViewController *webController = [[UIViewController alloc]init];
        [webController.view addSubview:webView];
        webController.view.frame = (CGRect){0,0,800,700};
        [webView loadRequest:[NSURLRequest requestWithURL:[[NSURL alloc] initFileURLWithPath:material.materialFileLocalPath]]];
        webController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:webController animated:YES completion:^{
            
        }];
    }
}
#pragma mark --


#pragma mark MJRefreshBaseViewDelegate 分页加载
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    UserModel *user = [[CaiJinTongManager shared] user];
    if (self.headerRefreshView == refreshView) {
        self.footerRefreshView.isForbidden = YES;
        if (self.isSearch) {
            [self.searchMaterialInterface searchLearningMaterilasListWithUserId:user.userId withSearchContent:self.searchContent withPageIndex:0 withSortType:self.sortType];
        }else{
            [self.learningMaterialListInterface downloadlearningMaterilasListForCategoryId:self.lessonCategoryId withUserId:user.userId withPageIndex:0 withSortType:self.sortType];
        }
    }else{  //加载更多数据
        self.headerRefreshView.isForbidden = YES;
        if (self.isSearch) {
             [self.searchMaterialInterface searchLearningMaterilasListWithUserId:user.userId withSearchContent:self.searchContent withPageIndex:self.searchMaterialInterface.currentPageIndex+1 withSortType:self.sortType];
        }else{
             [self.learningMaterialListInterface downloadlearningMaterilasListForCategoryId:self.lessonCategoryId withUserId:user.userId withPageIndex:self.learningMaterialListInterface.currentPageIndex+1 withSortType:self.sortType];
        }
    }
}

#pragma mark --

#pragma mark SearchLearningMatarilasListInterfaceDelegate
-(void)searchLearningMaterilasListDataForCategoryDidFinished:(NSArray *)learningMaterialsList withCurrentPageIndex:(int)pageIndex withTotalCount:(int)allDataCount{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pageIndex > 0) {
            [self.searchArray addObjectsFromArray:learningMaterialsList];
        }else{
            self.searchArray = [NSMutableArray arrayWithArray:learningMaterialsList];
        }
        [self.tableView reloadData];
         [MBProgressHUD hideHUDFromTopViewForView:self.view animated:YES];
        [self.headerRefreshView endRefreshing];
        [self.footerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        self.footerRefreshView.isForbidden = NO;
        self.isReloading = NO;
    });
    self.drnavigationBar.titleLabel.text = @"搜索";
}

-(void)searchLearningMaterilasListDataForCategoryFailure:(NSString *)errorMsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDFromTopViewForView:self.view animated:YES];
        [self.headerRefreshView endRefreshing];
        [self.footerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        self.footerRefreshView.isForbidden = NO;
        self.isReloading = NO;
        [Utility errorAlert:errorMsg];
    });
}
#pragma mark --

#pragma mark LearningMatarilasListInterfaceDelegate
-(void)getlearningMaterilasListDataForCategoryDidFinished:(NSArray *)learningMaterialsList withCurrentPageIndex:(int)pageIndex withTotalCount:(int)allDataCount{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pageIndex > 0) {
            [self.dataArray addObjectsFromArray:learningMaterialsList];
        }else{
            self.dataArray = [NSMutableArray arrayWithArray:learningMaterialsList];
        }
        [self.tableView reloadData];
        self.totalCountLabel.text = [NSString stringWithFormat:@"目前有(%d)份资料",allDataCount];
        [self.headerRefreshView endRefreshing];
        [self.footerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        self.footerRefreshView.isForbidden = NO;
        self.isReloading = NO;
         [MBProgressHUD hideHUDFromTopViewForView:self.view animated:YES];
    });
}

-(void)getlearningMaterilasListDataForCategoryFailure:(NSString *)errorMsg{
dispatch_async(dispatch_get_main_queue(), ^{
     [MBProgressHUD hideHUDFromTopViewForView:self.view animated:YES];
    [self.headerRefreshView endRefreshing];
    [self.footerRefreshView endRefreshing];
    self.headerRefreshView.isForbidden = NO;
    self.footerRefreshView.isForbidden = NO;
    self.isReloading = NO;
    [Utility errorAlert:errorMsg];
});
}
#pragma mark --

#pragma mark property
-(void)setIsSearch:(BOOL)isSearch{
    _isSearch = isSearch;
    if (!isSearch) {
        self.drnavigationBar.searchBar.isSearch = NO;
    }
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(NSMutableArray *)searchArray{
    if (!_searchArray) {
        _searchArray = [NSMutableArray array];
    }
    return _searchArray;
}

-(SearchLearningMatarilasListInterface *)searchMaterialInterface{
    if (!_searchMaterialInterface) {
        _searchMaterialInterface = [[SearchLearningMatarilasListInterface alloc] init];
        _searchMaterialInterface.delegate = self;
    }
    return _searchMaterialInterface;
}

-(LearningMatarilasListInterface *)learningMaterialListInterface{
    if (!_learningMaterialListInterface) {
        _learningMaterialListInterface = [[LearningMatarilasListInterface alloc] init];
        _learningMaterialListInterface.delegate =self;
    }
    return _learningMaterialListInterface;
}

-(MJRefreshHeaderView *)headerRefreshView{
    if (!_headerRefreshView) {
        _headerRefreshView = [[MJRefreshHeaderView alloc] init];
        _headerRefreshView.scrollView = self.tableView;
        _headerRefreshView.delegate = self;
    }
    return _headerRefreshView;
}

-(MJRefreshFooterView *)footerRefreshView{
    if (!_footerRefreshView) {
        _footerRefreshView = [[MJRefreshFooterView alloc] init];
        _footerRefreshView.delegate = self;
        _footerRefreshView.scrollView = self.tableView;
        
    }
    return _footerRefreshView;
}

-(void)setLessonCategoryId:(NSString *)lessonCategoryId{
    if (self.isReloading) {
        return;
    }
    _lessonCategoryId = lessonCategoryId?:@"";
    if (lessonCategoryId) {
        self.isReloading = YES;
         [MBProgressHUD showHUDAddedToTopView:self.view animated:YES];
        UserModel *user = [[CaiJinTongManager shared] user];
        [self.learningMaterialListInterface downloadlearningMaterilasListForCategoryId:self.lessonCategoryId withUserId:user.userId withPageIndex:0 withSortType:self.sortType];
    }
}
#pragma mark --
@end
