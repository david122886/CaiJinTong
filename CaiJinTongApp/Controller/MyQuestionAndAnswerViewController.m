//
//  MyQuestionAndAnswerViewController.m
//  CaiJinTongApp
//
//  Created by david on 13-11-7.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "MyQuestionAndAnswerViewController.h"
@interface MyQuestionAndAnswerViewController ()
@property (nonatomic,strong) NSMutableArray *myQuestionArr;
@property (nonatomic,strong) MJRefreshHeaderView *headerRefreshView;
@property (nonatomic,strong) MJRefreshFooterView *footerRefreshView;
@property (nonatomic,strong) QuestionListInterface *questionListInterface;//所有问题的分页加载
@property (nonatomic,strong) GetUserQuestionInterface *userQuestionInterface;//我的回答或者我的提问分页加载
@property (nonatomic,strong) SubmitAnswerInterface *submitAnswerInterface;//提交回答或者是提交追问
@property (nonatomic,strong)  AnswerPraiseInterface *answerPraiseinterface;//提交赞接口
@property (nonatomic,strong) SearchQuestionInterface *searchQuestionInterface;//搜索问答接口
@property (nonatomic,strong) NSIndexPath *activeIndexPath;//正在处理中的cell
@property (nonatomic,assign) BOOL isReaskRefreshing;//判断是追问刷新还是上拉下拉刷新
@property (nonatomic,strong) DRAskQuestionViewController *askQuestionController;
@property (nonatomic,strong) UIViewController *modelController;
@property (nonatomic,strong) NSMutableDictionary *indexRowPathDic;
@property (nonatomic,strong) NSString *searchContent;//搜索关键字
@end

@implementation MyQuestionAndAnswerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark ask Question提问
- (IBAction)askQuestionBtClicked:(id)sender {
    if (!self.askQuestionController) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        self.askQuestionController  = [story instantiateViewControllerWithIdentifier:@"DRAskQuestionViewController"];
        self.askQuestionController.delegate = self;
    }
    
    [self.navigationController pushViewController:self.askQuestionController animated:YES];
}

#pragma mark --

-(void)willDismissPopoupController{
    CGPoint offset = self.tableView.contentOffset;
    [self.tableView setContentOffset:offset animated:NO];
}

#pragma mark 转换question indexpath成answer indexpath
-(void)changeQuestionIndexPathToAnswerIndexPath:(NSArray*)questionArr{
    int section = 0;
    int row = 0;
    int index = 0;
    NSMutableDictionary *indexPathDic = [NSMutableDictionary dictionary];
    for (QuestionModel *question  in questionArr) {
        row = -1;
        [indexPathDic setValue:[NSIndexPath indexPathForRow:row++ inSection:section] forKey:[NSString stringWithFormat:@"%d",index++]];
        for (AnswerModel *answer in question.answerList) {
            [indexPathDic setValue:[NSIndexPath indexPathForRow:row++ inSection:section] forKey:[NSString stringWithFormat:@"%d",index++]];
        }
        section++;
    }
    self.indexRowPathDic = indexPathDic;
    self.myQuestionArr = [NSMutableArray arrayWithArray:questionArr];
}

-(void)addQuestionIndexPathToAnswerIndexPath:(NSArray*)questionArr{
//    int section = 0;
//    int row = 0;
//    int index = 0;
//    if (self.indexRowPathDic.count > 0) {
//        index = self.indexRowPathDic.count;
//        NSIndexPath *path = [self.indexRowPathDic objectForKey:[NSString stringWithFormat:@"%d",index-1]];
//        section = path.section +1;
//    }
//    NSMutableDictionary *indexPathDic = [NSMutableDictionary dictionary];
//    for (QuestionModel *question  in questionArr) {
//        row = -1;
//        [indexPathDic setValue:[NSIndexPath indexPathForRow:row++ inSection:section] forKey:[NSString stringWithFormat:@"%d",index++]];
//        for (AnswerModel *answer in question.answerList) {
//            [indexPathDic setValue:[NSIndexPath indexPathForRow:row++ inSection:section] forKey:[NSString stringWithFormat:@"%d",index++]];
//        }
//        section++;
//    }
//    [self.indexRowPathDic addEntriesFromDictionary:indexPathDic];
//    [self.myQuestionArr addObjectsFromArray:questionArr];
    NSMutableArray *data = [NSMutableArray arrayWithArray:questionArr];
    [data addObjectsFromArray:self.myQuestionArr];
    [self changeQuestionIndexPathToAnswerIndexPath:data];
}


-(int)convertIndexpathToRow:(NSIndexPath*)path{
    NSArray *allkeys = [self.indexRowPathDic allKeysForObject:path];
    int row = -1;
    for (NSString *key in allkeys) {
        if ([self.indexRowPathDic objectForKey:key] == path) {
            row = key.intValue;
            break;
        }
    }
    if (row < 0) {
        NSLog(@"@#############$@@@@@@@@@@row is less 0");
        return 0;
    }
    return row;
}
#pragma mark --

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[QuestionAndAnswerCellHeaderView class] forCellReuseIdentifier:@"questionCell"];
    [self.headerRefreshView endRefreshing];//instance refresh view
    [self.footerRefreshView endRefreshing];
    [self.drnavigationBar.navigationRightItem setTitle:@"提问" forState:UIControlStateNormal];
    [self.drnavigationBar hiddleBackButton:YES];
    self.drnavigationBar.searchBar.searchTextLabel.placeholder = @"搜索问题";
    [self.noticeBarImageView.layer setCornerRadius:4];
}

#pragma mark DRSearchBarDelegate搜索
-(void)drSearchBar:(DRSearchBar *)searchBar didBeginSearchText:(NSString *)searchText{
    self.isSearch = YES;
     self.isReaskRefreshing = NO;
    UserModel *user = [[CaiJinTongManager shared] user];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.searchContent = searchText;
    self.questionAndAnswerScope = QuestionAndAnswerSearchQuestion;
    [self.searchQuestionInterface getSearchQuestionInterfaceDelegateWithUserId:user.userId andText:self.searchContent withLastQuestionId:@"0"];
}

-(void)drSearchBar:(DRSearchBar *)searchBar didCancelSearchText:(NSString *)searchText{
    self.isSearch = NO;
    [self.tableView reloadData];
}
#pragma mark --

////数据源
-(void)reloadDataWithDataArray:(NSArray*)data withQuestionChapterID:(NSString*)chapterID withScope:(QuestionAndAnswerScope)scope isSearch:(BOOL)isSearch{
    self.isSearch = isSearch;
    self.questionAndAnswerScope = scope;
    self.chapterID = chapterID;
//    self.myQuestionArr = [NSMutableArray arrayWithArray:data];
    [self changeQuestionIndexPathToAnswerIndexPath:data];
    self.headerRefreshView.isForbidden = NO;
    self.footerRefreshView.isForbidden = NO;
    [self.headerRefreshView endRefreshing];
    [self.footerRefreshView endRefreshing];
    
    
    if (self.myQuestionArr.count>0) {
        [self.tableView reloadData];
    }
}

//数据源
-(void)nextPageDataWithDataArray:(NSArray*)data withQuestionChapterID:(NSString*)chapterID withScope:(QuestionAndAnswerScope)scope{
    self.questionAndAnswerScope = scope;
    self.chapterID = chapterID;
//    [self.myQuestionArr addObjectsFromArray:data];
    [self addQuestionIndexPathToAnswerIndexPath:data];
    self.headerRefreshView.isForbidden = NO;
    self.footerRefreshView.isForbidden = NO;
    [self.headerRefreshView endRefreshing];
    [self.footerRefreshView endRefreshing];
    
    
    if (self.myQuestionArr.count>0) {
        [self.tableView reloadData];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark DRAttributeStringViewDelegate用户点击图片内容时调用
-(void)drAttributeStringView:(DRAttributeStringView *)attriView clickedFileURL:(NSURL *)url withFileType:(DRURLFileType)fileType{
    if (!self.modelController) {
       self.modelController = [[UIViewController alloc] init];
    }
    for (UIView *subView in self.modelController.view.subviews) {
        [subView removeFromSuperview];
    }
    UIWebView *webView = [[UIWebView alloc] init];
    [self.modelController.view addSubview:webView];
    self.modelController.view.frame = (CGRect){0,0,800,700};
    webView.frame = (CGRect){0,0,800,700};
    webView.scalesPageToFit = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self presentPopupViewController:self.modelController animationType:MJPopupViewAnimationSlideTopTop isAlignmentCenter:YES dismissed:^{
        
    }];
}
#pragma mark --

#pragma mark QuestionAndAnswerCellHeaderViewDelegate
-(void)questionAndAnswerCellHeaderView:(QuestionAndAnswerCellHeaderView *)header didIsExtendQuestionContent:(BOOL)isExtend atIndexPath:(NSIndexPath *)path{
//    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
//    question.isExtend = isExtend;
    int row = [self convertIndexpathToRow:path];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(BOOL)questionAndAnswerCellHeaderView:(QuestionAndAnswerCellHeaderView *)header isExtendAtIndexPath:(NSIndexPath *)path{
//    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
//    return question.isExtend;
     return YES;
}

-(float)questionAndAnswerCellHeaderView:(QuestionAndAnswerCellHeaderView *)header headerHeightAtIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
    CGRect rect = [DRAttributeStringView boundsRectWithQuestion:question withWidth:QUESTIONHEARD_VIEW_WIDTH];
    return rect.size.height;
}

//赞问题
-(void)questionAndAnswerCellHeaderView:(QuestionAndAnswerCellHeaderView *)header flowerQuestionAtIndexPath:(NSIndexPath *)path{

}
//将要点击回答问题按钮
-(void)questionAndAnswerCellHeaderView:(QuestionAndAnswerCellHeaderView *)header willAnswerQuestionAtIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
    question.isEditing = !question.isEditing;
     int row = [self convertIndexpathToRow:path];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (question.isEditing) {
        float sectionHeight = [self getTableViewHeaderHeightWithSection:row];
        CGRect sectionRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        float sectionMinHeight = CGRectGetMaxY(sectionRect) - self.tableView.contentOffset.y;
        float keyheight = CGRectGetMaxY(self.tableView.frame) - sectionHeight;
        if (sectionMinHeight > keyheight) {
            [self.tableView setContentOffset:(CGPoint){self.tableView.contentOffset.x,self.tableView.contentOffset.y+ (sectionMinHeight - keyheight)} animated:YES];
        }
    }

}

//提交问题的答案
-(void)questionAndAnswerCellHeaderView:(QuestionAndAnswerCellHeaderView *)header didAnswerQuestionAtIndexPath:(NSIndexPath *)path withAnswer:(NSString *)text{
    if ([[Utility isExistenceNetwork]isEqualToString:@"NotReachable"]) {
        [Utility errorAlert:@"暂无网络!"];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
        question.isEditing = NO;
         int row = [self convertIndexpathToRow:path];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.submitAnswerInterface getSubmitAnswerInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andReaskTyep:ReaskType_None andAnswerContent:text andQuestionId:question.questionId andAnswerID:nil  andResultId:@"0"];
    }
}

//开始编辑回答
-(void)questionAndAnswerCellHeaderView:(QuestionAndAnswerCellHeaderView *)header willBeginTypeAnswerQuestionAtIndexPath:(NSIndexPath *)path{
    int row = [self convertIndexpathToRow:path];
    float sectionHeight = [self getTableViewHeaderHeightWithSection:row];
    CGRect sectionRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    float sectionMinHeight = CGRectGetMaxY(sectionRect) - self.tableView.contentOffset.y;
    float keyheight = CGRectGetMaxY(self.tableView.frame) - sectionHeight-300;
    if (sectionMinHeight > keyheight) {
        [self.tableView setContentOffset:(CGPoint){self.tableView.contentOffset.x,self.tableView.contentOffset.y+ (sectionMinHeight - keyheight)} animated:YES];
    }

}
#pragma mark --

#pragma mark QuestionAndAnswerCellDelegate


-(float)questionAndAnswerCell:(QuestionAndAnswerCell *)cell getCellheightAtIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
    AnswerModel *answer = [question.answerList objectAtIndex:path.row];
    CGRect rect = [DRAttributeStringView boundsRectWithAnswer:answer withWidth:QUESTIONANDANSWER_CELL_WIDTH];
    return rect.size.height;
}

-(void)questionAndAnswerCell:(QuestionAndAnswerCell *)cell willBeginTypeQuestionTextFieldAtIndexPath:(NSIndexPath *)path{
    int row = [self convertIndexpathToRow:path];
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    float cellmaxHeight = CGRectGetMaxY(cellRect) - self.tableView.contentOffset.y;
    float keyheight = CGRectGetMaxY(self.tableView.frame) - 450;
    if (cellmaxHeight > keyheight) {
        [self.tableView setContentOffset:(CGPoint){self.tableView.contentOffset.x,self.tableView.contentOffset.y+ (cellmaxHeight - keyheight)} animated:YES];
    }
}

-(void)questionAndAnswerCell:(QuestionAndAnswerCell *)cell flowerAnswerAtIndexPath:(NSIndexPath *)path{
//    answer.isPraised = YES;
    if ([[Utility isExistenceNetwork]isEqualToString:@"NotReachable"]) {
        [Utility errorAlert:@"暂无网络!"];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
        AnswerModel *answer = [question.answerList objectAtIndex:path.row];
        self.activeIndexPath = path;
        [self.answerPraiseinterface getAnswerPraiseInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andQuestionId:question.questionId andResultId:answer.resultId];
    }
}

//追问
-(void)questionAndAnswerCell:(QuestionAndAnswerCell *)cell summitQuestion:(NSString *)questionStr atIndexPath:(NSIndexPath *)path withReaskType:(ReaskType)reaskType{
    if ([[Utility isExistenceNetwork]isEqualToString:@"NotReachable"]) {
        [Utility errorAlert:@"暂无网络!"];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
        AnswerModel *answer = [question.answerList objectAtIndex:path.row];
        [self.submitAnswerInterface getSubmitAnswerInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andReaskTyep:reaskType andAnswerContent:questionStr andQuestionId:question.questionId andAnswerID:answer.resultId  andResultId:@"1"];
    }
}

-(void)questionAndAnswerCell:(QuestionAndAnswerCell *)cell isHiddleQuestionView:(BOOL)isHiddle atIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
    AnswerModel *answer = [question.answerList objectAtIndex:path.row];
    answer.isEditing = isHiddle;
    int row = [self convertIndexpathToRow:path];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (answer.isEditing) {
        float cellHeight = [self getTableViewRowHeightWithIndexPath:path];
        CGRect cellRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        float cellmaxHeight = CGRectGetMaxY(cellRect) - self.tableView.contentOffset.y;
        float keyheight = CGRectGetMaxY(self.tableView.frame) - cellHeight-20;
        if (cellmaxHeight > keyheight) {
            [self.tableView setContentOffset:(CGPoint){self.tableView.contentOffset.x,self.tableView.contentOffset.y+ (cellmaxHeight - keyheight)} animated:YES];
        }
    }
    
}
#pragma mark -- 采纳答案
-(void)questionAndAnswerCell:(QuestionAndAnswerCell *)cell acceptAnswerAtIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
    AnswerModel *answer = [question.answerList objectAtIndex:path.row];
    if ([[Utility isExistenceNetwork]isEqualToString:@"NotReachable"]) {
        [Utility errorAlert:@"暂无网络!"];
    }else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.activeIndexPath = path;
        AcceptAnswerInterface *acceptAnswerInter = [[AcceptAnswerInterface alloc]init];
        self.acceptAnswerInterface = acceptAnswerInter;
        self.acceptAnswerInterface.delegate = self;
        [self.acceptAnswerInterface getAcceptAnswerInterfaceDelegateWithUserId:[CaiJinTongManager shared].userId andQuestionId:question.questionId andAnswerID:answer.answerId andCorrectAnswerID:answer.resultId];
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
    NSIndexPath *path  = [self.indexRowPathDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    if (path.row < 0) {//问题
        QuestionAndAnswerCellHeaderView *header = (QuestionAndAnswerCellHeaderView*)[tableView dequeueReusableCellWithIdentifier:@"questionCell"];
        QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
        [header setQuestionModel:question withQuestionAndAnswerScope:self.questionAndAnswerScope];
        header.backgroundColor = [UIColor whiteColor];
        header.delegate = self;
        header.questionContentAttributeView.delegate = self;
        header.path = path;
        return header;
    }else{//答案
        QuestionAndAnswerCell *cell = (QuestionAndAnswerCell*)[tableView dequeueReusableCellWithIdentifier:@"questionAndAnswerCell"];
        QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
        AnswerModel *answer = [question.answerList objectAtIndex:path.row];
        //    if ([[CaiJinTongManager shared] userId] && [[[CaiJinTongManager shared] userId] isEqualToString:question.askerId]) {
        //        answer.isEditing = YES;
        //    }else{
        //     answer.isEditing = NO;
        //    }
        [cell setAnswerModel:answer withQuestion:question];
        cell.delegate = self;
        cell.path = path;
        cell.answerAttributeTextView.delegate = self;
        cell.contentView.frame = (CGRect){cell.contentView.frame.origin,CGRectGetWidth(cell.contentView.frame),[self getTableViewRowHeightWithIndexPath:path]};
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *path  = [self.indexRowPathDic objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    if (path.row < 0) {
        return [self getTableViewHeaderHeightWithSection:path.section];
    }else{
        float height = [self getTableViewRowHeightWithIndexPath:path];
        return height;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.indexRowPathDic.count;
}

#pragma mark --

#pragma mark MJRefreshBaseViewDelegate 分页加载
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    self.isReaskRefreshing = NO;
    if (self.headerRefreshView == refreshView) {
        self.footerRefreshView.isForbidden = YES;
        [self requestNewPageDataWithLastQuestionID:nil];
    }else{
        self.headerRefreshView.isForbidden = YES;
        QuestionModel *question = [self.myQuestionArr  lastObject];
        [self requestNewPageDataWithLastQuestionID:question.questionId];
    }
}

#pragma mark --

#pragma mark action

-(void)requestNewPageDataWithLastQuestionID:(NSString*)lastQuestionID{
    UserModel *user = [[CaiJinTongManager shared] user];
    if (self.questionAndAnswerScope == QuestionAndAnswerALL) {
        [self.questionListInterface getQuestionListInterfaceDelegateWithUserId:user.userId andChapterQuestionId:self.chapterID andLastQuestionID:lastQuestionID];
    }else
        if (self.questionAndAnswerScope == QuestionAndAnswerMYANSWER) {
            [self.userQuestionInterface getGetUserQuestionInterfaceDelegateWithUserId:user.userId andIsMyselfQuestion:@"1" andLastQuestionID:lastQuestionID withCategoryId:self.chapterID];
        }else
            if (self.questionAndAnswerScope == QuestionAndAnswerMYQUESTION) {
                [self.userQuestionInterface getGetUserQuestionInterfaceDelegateWithUserId:user.userId andIsMyselfQuestion:@"0" andLastQuestionID:lastQuestionID withCategoryId:self.chapterID];
            }else if (self.questionAndAnswerScope == QuestionAndAnswerSearchQuestion){
                QuestionModel *question = [self.myQuestionArr lastObject];
                [self.searchQuestionInterface getSearchQuestionInterfaceDelegateWithUserId:user.userId andText:self.searchQuestionText withLastQuestionId:question.questionId];
            }
}

-(float)getTableViewHeaderHeightWithSection:(NSInteger)section{
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:section];
    CGRect rect = [DRAttributeStringView boundsRectWithQuestion:question withWidth:QUESTIONHEARD_VIEW_WIDTH];
    float height = rect.size.height;
    if (question.isEditing) {
        return height + TEXT_HEIGHT + TEXT_PADDING + QUESTIONHEARD_VIEW_ANSWER_BACK_VIEW_HEIGHT+ 10+40+10;
    }else{
        return height + TEXT_HEIGHT + TEXT_PADDING + 10+40+10;
    }

//    if (question.isExtend) {
//        if (question.isEditing) {
//            return rect.size.height + TEXT_HEIGHT + TEXT_PADDING + QUESTIONHEARD_VIEW_ANSWER_BACK_VIEW_HEIGHT+ 10+40+10;
//        }else{
//            return rect.size.height + TEXT_HEIGHT + TEXT_PADDING + 10+40+10;
//        }
//    }else{
//        float height = rect.size.height;
//        if (height > ContentMinHeight) {
//            height = ContentMinHeight;
//        }
//        if (question.isEditing) {
//            return height + TEXT_HEIGHT + TEXT_PADDING + QUESTIONHEARD_VIEW_ANSWER_BACK_VIEW_HEIGHT+ 10+40+10;
//        }else{
//            return height + TEXT_HEIGHT + TEXT_PADDING + 10+40+10;
//        }
//    }
}

//-(float)getTableViewRowHeightWithIndexPath:(NSIndexPath*)path{
//    NSLog(@"%d,%d",path.section,path.row);
//    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
//    if (question.answerList == nil || [question.answerList count] <= 0) {
//        return 0;
//    }
//    AnswerModel *answer = [question.answerList objectAtIndex:path.row];
//    float questionTextFieldHeight = answer.isEditing?141:0;
//
//    if (platform >= 7.0) {
//        return [Utility getTextSizeWithString:answer.answerContent withFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE+6] withWidth:QUESTIONANDANSWER_CELL_WIDTH].height+ TEXT_HEIGHT + TEXT_PADDING*3+ questionTextFieldHeight;
//    }else{
//        float height = [Utility getTextSizeWithString:answer.answerContent withFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE+6] withWidth:QUESTIONANDANSWER_CELL_WIDTH].height+ TEXT_HEIGHT + TEXT_PADDING+ questionTextFieldHeight;
//        return height;
//    }
//}

-(float)getTableViewRowHeightWithIndexPath:(NSIndexPath*)path{
    NSLog(@"%d,%d",path.section,path.row);
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:path.section];
    if (question.answerList == nil || [question.answerList count] <= 0) {
        return 0;
    }
    AnswerModel *answer = [question.answerList objectAtIndex:path.row];
    float questionTextFieldHeight = answer.isEditing?141:0;
    CGRect rect = [DRAttributeStringView boundsRectWithAnswer:answer withWidth:QUESTIONANDANSWER_CELL_WIDTH];
    if (platform >= 7.0) {
        return rect.size.height+ TEXT_HEIGHT + TEXT_PADDING*3+ questionTextFieldHeight;
    }else{
        float height = rect.size.height+ TEXT_HEIGHT + TEXT_PADDING+ questionTextFieldHeight;
        return height;
    }
}

#pragma mark --

#pragma mark property
-(NSMutableDictionary *)indexRowPathDic{
    if (!_indexRowPathDic) {
        _indexRowPathDic = [NSMutableDictionary dictionary];
    }
    return _indexRowPathDic;
}

-(void)setIsSearch:(BOOL)isSearch{
    _isSearch = isSearch;
    if (!isSearch) {
        self.drnavigationBar.searchBar.isSearch = NO;
    }
}

-(SearchQuestionInterface *)searchQuestionInterface{
    if (!_searchQuestionInterface) {
        _searchQuestionInterface = [[SearchQuestionInterface alloc] init];
        _searchQuestionInterface.delegate = self;
    }
    return _searchQuestionInterface;
}

-(void)setQuestionAndAnswerScope:(QuestionAndAnswerScope)questionAndAnswerScope{
    _questionAndAnswerScope = questionAndAnswerScope;
    switch (questionAndAnswerScope) {
        case QuestionAndAnswerALL:
            self.drnavigationBar.titleLabel.text = @"所有问答";
            break;
        case QuestionAndAnswerMYQUESTION:
            self.drnavigationBar.titleLabel.text = @"我的提问";
            break;
        default:
            self.drnavigationBar.titleLabel.text = @"我的回答";
            break;
    }
}

-(AnswerPraiseInterface *)answerPraiseinterface{
    if (!_answerPraiseinterface) {
        _answerPraiseinterface = [[AnswerPraiseInterface alloc] init];
        _answerPraiseinterface.delegate = self;
    }
    return _answerPraiseinterface;
}

-(SubmitAnswerInterface *)submitAnswerInterface{
    if (!_submitAnswerInterface) {
        _submitAnswerInterface = [[SubmitAnswerInterface alloc] init];
        _submitAnswerInterface.delegate = self;
    }
    return _submitAnswerInterface;
}

-(GetUserQuestionInterface *)userQuestionInterface{
    if (!_userQuestionInterface) {
        _userQuestionInterface = [[GetUserQuestionInterface alloc] init];
        _userQuestionInterface.delegate = self;
    }
    return _userQuestionInterface;
}

-(QuestionListInterface *)questionListInterface{
    if (!_questionListInterface) {
        _questionListInterface = [[QuestionListInterface alloc] init];
        _questionListInterface.delegate = self;
    }
    return _questionListInterface;
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

-(NSMutableArray *)myQuestionArr{
    if (!_myQuestionArr) {
        _myQuestionArr = [NSMutableArray array];
    }
    return _myQuestionArr;
}
#pragma mark --



- (IBAction)noticeHideBtnClick:(id)sender {
    [self.noticeBarView setHidden:YES];
}

#pragma mark DRAskQuestionViewControllerDelegate 提问问题成功时回调
-(void)askQuestionViewControllerDidAskingSuccess:(DRAskQuestionViewController *)controller{
    self.isReaskRefreshing = YES;
     [self requestNewPageDataWithLastQuestionID:nil];
}
#pragma mark --


#pragma mark SearchQuestionInterfaceDelegate搜索问答回调
-(void)getSearchQuestionInfoDidFailed:(NSString *)errorMsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.headerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        [self.footerRefreshView endRefreshing];
        self.footerRefreshView.isForbidden = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Utility errorAlert:errorMsg];
    });
}

-(void)getSearchQuestionInfoDidFinished:(NSDictionary *)result{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *chapterQuestionList = [result objectForKey:@"chapterQuestionList"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.question_pageIndex = self.question_pageIndex+1;
            if (self.headerRefreshView.isForbidden) {//加载下一页
                [self nextPageDataWithDataArray:chapterQuestionList withQuestionChapterID:self.chapterID withScope:QuestionAndAnswerSearchQuestion];
            }else{//重新加载
                [self reloadDataWithDataArray:chapterQuestionList withQuestionChapterID:self.chapterID withScope:QuestionAndAnswerSearchQuestion isSearch:self.isSearch];
            }
            
            [self.headerRefreshView endRefreshing];
            self.headerRefreshView.isForbidden = NO;
            [self.footerRefreshView endRefreshing];
            self.footerRefreshView.isForbidden = NO;
        });
    });
}
#pragma mark --


#pragma mark AnswerPraiseInterfaceDelegate 赞回调
-(void)getAnswerPraiseInfoDidFinished:(NSDictionary *)result{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:@"赞成功"];
    QuestionModel *question = [self.myQuestionArr  objectAtIndex:self.activeIndexPath.section];
    AnswerModel *answer = [question.answerList objectAtIndex:self.activeIndexPath.row];
    answer.answerPraiseCount = [NSString stringWithFormat:@"%d",[answer.answerPraiseCount integerValue]+1];
    answer.isPraised = @"1";
    int row = [self convertIndexpathToRow:self.activeIndexPath];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)getAnswerPraiseInfoDidFailed:(NSString *)errorMsg{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:@"赞失败"];
}
#pragma mark --

#pragma mark SubmitAnswerInterfaceDelegate 提交回答或者提交追问的代理
-(void)getSubmitAnswerInfoDidFinished:(NSDictionary *)result withReaskType:(ReaskType)reask{
    self.isReaskRefreshing = YES;
     [self.questionListInterface getQuestionListInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andChapterQuestionId:self.chapterID andLastQuestionID:nil];
}

-(void)getSubmitAnswerDidFailed:(NSString *)errorMsg withReaskType:(ReaskType)reask{

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:@"提交失败"];
}

#pragma mark --
#pragma mark GetUserQuestionInterfaceDelegate 加载我的回答或者我的提问新数据
-(void)getUserQuestionInfoDidFinished:(NSDictionary *)result{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *chapterQuestionList = [result objectForKey:@"chapterQuestionList"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isReaskRefreshing) {
//                self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                [self changeQuestionIndexPathToAnswerIndexPath:chapterQuestionList];
                 [self.tableView reloadData];
            }else{
                if (self.headerRefreshView.isForbidden) {//加载下一页
//                    [self.myQuestionArr addObjectsFromArray:chapterQuestionList];
                    [self addQuestionIndexPathToAnswerIndexPath:chapterQuestionList];
                }else{//重新加载
//                    self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                    [self changeQuestionIndexPathToAnswerIndexPath:chapterQuestionList];
                }
                 [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.headerRefreshView endRefreshing];
                self.headerRefreshView.isForbidden = NO;
                [self.footerRefreshView endRefreshing];
                self.footerRefreshView.isForbidden = NO;
            }
        });
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

-(void)getUserQuestionInfoDidFailed:(NSString *)errorMsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.headerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        [self.footerRefreshView endRefreshing];
        self.footerRefreshView.isForbidden = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Utility errorAlert:errorMsg];
    });
}
#pragma mark --

#pragma mark QuestionListInterfaceDelegate 加载所有问题新数据
-(void)getQuestionListInfoDidFinished:(NSDictionary *)result{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isReaskRefreshing) {
            if (result) {
                NSArray *chapterQuestionList = [result objectForKey:@"chapterQuestionList"];
                if (chapterQuestionList && [chapterQuestionList count] > 0) {
                    if (self.headerRefreshView.isForbidden) {//加载下一页
//                        [self.myQuestionArr addObjectsFromArray:chapterQuestionList];
                        [self addQuestionIndexPathToAnswerIndexPath:chapterQuestionList];
                    }else{//重新加载
//                        self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                        [self changeQuestionIndexPathToAnswerIndexPath:chapterQuestionList];
                    }
                    [self.tableView reloadData];
                }else{
                    [Utility errorAlert:@"数据为空"];
                }
            }else{
                [Utility errorAlert:@"数据为空"];
            }
        }else{
            if (result) {
                NSArray *chapterQuestionList = [result objectForKey:@"chapterQuestionList"];
                if (chapterQuestionList && [chapterQuestionList count] > 0) {
//                    self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                    [self changeQuestionIndexPathToAnswerIndexPath:chapterQuestionList];
                    [self.tableView reloadData];
                }else{
                    [Utility errorAlert:@"数据为空"];
                }
            }else{
                [Utility errorAlert:@"数据为空"];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        [self.headerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        [self.footerRefreshView endRefreshing];
        self.footerRefreshView.isForbidden = NO;
    });
}

-(void)getQuestionListInfoDidFailed:(NSString *)errorMsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.headerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        [self.footerRefreshView endRefreshing];
        self.footerRefreshView.isForbidden = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Utility errorAlert:errorMsg];
    });
}
#pragma mark --


#pragma mark -- AcceptAnswerInterfaceDelegate 采纳答案
-(void)getAcceptAnswerInfoDidFinished:(NSDictionary *)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            QuestionModel *question = [self.myQuestionArr  objectAtIndex:self.activeIndexPath.section];
            AnswerModel *answer = [question.answerList objectAtIndex:self.activeIndexPath.row];
            question.isAcceptAnswer = @"1";
            answer.IsAnswerAccept = @"1";
            int row = [self convertIndexpathToRow:self.activeIndexPath];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [Utility errorAlert:@"提交采纳正确回答成功"];
        });
    });
}
-(void)getAcceptAnswerInfoDidFailed:(NSString *)errorMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [Utility errorAlert:errorMsg];
    });
}

-(void)dealloc{
    if (self.questionAndAnswerScope == QuestionAndAnswerALL) {
        [self.headerRefreshView free];
        [self.footerRefreshView free];
    }
}

@end
