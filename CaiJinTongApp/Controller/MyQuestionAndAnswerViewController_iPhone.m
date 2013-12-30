//
//  MyQuestionAndAnswerViewController_iPhone.m
//  CaiJinTongApp
//
//  Created by apple on 13-12-6.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "MyQuestionAndAnswerViewController_iPhone.h"
@interface MyQuestionAndAnswerViewController_iPhone ()
@property (nonatomic,strong) NSMutableArray *myQuestionArr;
@property (nonatomic,strong) NSMutableArray *questionIndexesArray;//问题序号数组 ,储存所有Header的row值
@property (nonatomic,strong) MJRefreshHeaderView *headerRefreshView;
@property (nonatomic,strong) MJRefreshFooterView *footerRefreshView;
@property (nonatomic,strong) QuestionListInterface *questionListInterface;//所有问题的分页加载
@property (nonatomic,strong) GetUserQuestionInterface *userQuestionInterface;//我的回答或者我的提问分页加载
@property (nonatomic,strong) SubmitAnswerInterface *submitAnswerInterface;//提交回答或者是提交追问
@property (nonatomic,strong) NSIndexPath *activeIndexPath;//正在处理中的cell
@property (nonatomic,assign) BOOL isReaskRefreshing;//判断是追问刷新还是上拉下拉刷新
@property (nonatomic,strong) LHLAskQuestionViewController *askQuestionController;
@property (nonatomic,strong) UIButton *askQuestionBtn;  //我要提问button
@end

@implementation MyQuestionAndAnswerViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(void)willDismissPopoupController{
    CGPoint offset = self.tableView.contentOffset;
    [self.tableView setContentOffset:offset animated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.headerRefreshView endRefreshing];//instance refresh view
    [self.footerRefreshView endRefreshing];
    [self.tableView registerClass:[QuestionAndAnswerCell_iPhoneHeaderView class] forCellReuseIdentifier:@"header"];
    [self.tableView setFrame: CGRectMake(20,CGRectGetMaxY(self.noticeBarView.frame) + 5,281,IP5(568, 480) - CGRectGetMaxY(self.noticeBarView.frame) - 5 - self.tabBarController.tabBar.frame.size.height)];
    [self.lhlNavigationBar.rightItem setTitle:@"提问" forState:UIControlStateNormal];
    [self.lhlNavigationBar.rightItem setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    if(!self.askQuestionBtn){
        self.askQuestionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = self.lhlNavigationBar.rightItem.frame;
        [self.askQuestionBtn setFrame:(CGRect){frame.origin.x - 30,frame.origin.y,frame.size}];
        [self.askQuestionBtn setBackgroundColor:[UIColor clearColor]];
        [self.askQuestionBtn setBackgroundImage:[UIImage imageNamed:@"question1.png"] forState:UIControlStateNormal];
        [self.askQuestionBtn addTarget:self action:@selector(askQuestionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.lhlNavigationBar addSubview:self.askQuestionBtn];
    }
    [self.noticeBarImageView.layer setCornerRadius:4];
    
    self.questionIndexesArray = [NSMutableArray arrayWithCapacity:5];
    
    //测试数据
    [self makeTestData];
}

#pragma mark 测试数据

-(void)makeTestData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //此接口property及其代理+回调方法也删掉
    self.getUserQuestionInterface = [[GetUserQuestionInterface alloc] init];
    self.getUserQuestionInterface.delegate = self;
    self.questionAndAnswerScope = QuestionAndAnswerMYQUESTION;
    //请求我的回答
    [self.getUserQuestionInterface getGetUserQuestionInterfaceDelegateWithUserId:[CaiJinTongManager shared].userId andIsMyselfQuestion:@"0" andLastQuestionID:nil withCategoryId:nil];
}



#pragma mark --

//数据源
-(void)reloadDataWithDataArray:(NSArray*)data withQuestionChapterID:(NSString*)chapterID withScope:(QuestionAndAnswerScope)scope{
    self.questionAndAnswerScope = scope;
    self.chapterID = chapterID;
    self.myQuestionArr = [NSMutableArray arrayWithArray:data];
    if (self.myQuestionArr.count>0) {
        QuestionModel *question = [self.myQuestionArr  lastObject];
        self.question_pageIndex = question.pageIndex;
        self.question_pageCount = question.pageCount;
        dispatch_async ( dispatch_get_main_queue (), ^{
            [self.tableView reloadData];
        });
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark QuestionAndAnswerCell_iPhoneHeaderViewDelegate
//赞问题
-(void)questionAndAnswerCell_iPhoneHeaderView:(QuestionAndAnswerCell_iPhoneHeaderView *)header flowerQuestionAtIndexPath:(NSIndexPath *)path{
    
}
//将要点击回答问题按钮
-(void)questionAndAnswerCell_iPhoneHeaderView:(QuestionAndAnswerCell_iPhoneHeaderView *)header willAnswerQuestionAtIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self questionForIndexPath:path];
    question.isEditing = !question.isEditing;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (question.isEditing) {
        //把输入框textView移动到合适的位置
        [self closeOtherTextFieldsExcepteThisOne:path withType:YES];
        CGPoint offset = self.tableView.contentOffset;//当前窗口的偏移值
        CGRect rowFrame = [self.tableView rectForRowAtIndexPath:path];//当前row的位置
        CGFloat rowHeight = rowFrame.size.height;//row高度,其中回答模块高度87
        CGFloat aY = CGRectGetMaxY(rowFrame) - QUESTIONHEARD_VIEW_ANSWER_BACK_VIEW_HEIGHT;//回答模块的上沿坐标
        CGFloat aHeight = QUESTIONHEARD_VIEW_ANSWER_BACK_VIEW_HEIGHT + 246.0 - IP5(63, 50);//上沿坐标的理想高度(相对tableView下沿)
        CGFloat bHeight = self.tableView.frame.size.height - (rowFrame.origin.y - offset.y + rowHeight - QUESTIONHEARD_VIEW_ANSWER_BACK_VIEW_HEIGHT);//当前上沿的高度(相对tableView下沿)
        CGFloat toOffsetY = offset.y + (aHeight - bHeight);//理想高度时的窗口Y偏移值
        [UIView animateWithDuration:0.5 animations:^{
            if(self.tableView.contentSize.height > self.tableView.frame.size.height){
                if(aHeight > self.tableView.contentSize.height - aY){//如果aY以下内容不足呈现理想位置,则滑动到内容最下方
                    [self.tableView setContentOffset:(CGPoint){rowFrame.origin.x, self.tableView.contentSize.height - self.tableView.frame.size.height}];
                }else if(aHeight > bHeight){
                    //如果剩余内容高度足够,且ay比理想位置低,则移动到理想位置
                    [self.tableView setContentOffset:(CGPoint){offset.x,toOffsetY}];
                }
            }
        }];
    }
}

//提交问题的答案
-(void)questionAndAnswerCell_iPhoneHeaderView:(QuestionAndAnswerCell_iPhoneHeaderView *)header didAnswerQuestionAtIndexPath:(NSIndexPath *)path withAnswer:(NSString *)text{
    if ([[Utility isExistenceNetwork]isEqualToString:@"NotReachable"]) {
        [Utility errorAlert:@"暂无网络!"];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        QuestionModel *question = [self questionForIndexPath:path];
        question.isEditing = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:path]];
        [self.submitAnswerInterface getSubmitAnswerInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andReaskTyep:ReaskType_None andAnswerContent:text andQuestionId:question.questionId andAnswerID:answer.resultId  andResultId:@"0"];
    }
}

//开始编辑回答
-(void)questionAndAnswerCell_iPhoneHeaderView:(QuestionAndAnswerCell_iPhoneHeaderView *)header willBeginTypeAnswerQuestionAtIndexPath:(NSIndexPath *)path{
    float sectionHeight = [self getTableViewRowHeightWithIndexPath:path];
    CGRect sectionRect = [self.tableView rectForRowAtIndexPath:path];
    float sectionMinHeight = CGRectGetMinY(sectionRect) - self.tableView.contentOffset.y;
    float keyheight = CGRectGetHeight(self.tableView.frame) - sectionHeight-IP5(188, 200);
    if (sectionMinHeight > keyheight) {
        [self.tableView setContentOffset:(CGPoint){self.tableView.contentOffset.x,self.tableView.contentOffset.y+ (sectionMinHeight - keyheight)} animated:YES];
    }
}
#pragma mark --

#pragma mark QuestionAndAnswerCell_iPhoneDelegate


-(float)QuestionAndAnswerCell_iPhone:(QuestionAndAnswerCell_iPhone *)cell getCellheightAtIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self questionForIndexPath:path];
    AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:path]];
    
    NSAttributedString *attriString =  [Utility getTextSizeWithAnswerModel:answer withFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE+4] withWidth:QUESTIONANDANSWER_CELL_WIDTH];
    CGSize size = [Utility getAttributeStringSizeWithWidth:QUESTIONANDANSWER_CELL_WIDTH withAttributeString:attriString];
    return size.height;
}

//键盘弹出
-(void)QuestionAndAnswerCell_iPhone:(QuestionAndAnswerCell_iPhone *)cell willBeginTypeQuestionTextFieldAtIndexPath:(NSIndexPath *)path{
    float sectionHeight = [self getTableViewRowHeightWithIndexPath:path];
    CGRect sectionRect = [self.tableView rectForRowAtIndexPath:path];
    float sectionMinHeight = CGRectGetMinY(sectionRect) - self.tableView.contentOffset.y;
    float keyheight = CGRectGetHeight(self.tableView.frame) - sectionHeight-IP5(188, 200);
    if (sectionMinHeight > keyheight) {
        [self.tableView setContentOffset:(CGPoint){self.tableView.contentOffset.x,self.tableView.contentOffset.y+ (sectionMinHeight - keyheight)} animated:YES];
    }
}

-(void)QuestionAndAnswerCell_iPhone:(QuestionAndAnswerCell_iPhone *)cell flowerAnswerAtIndexPath:(NSIndexPath *)path{
    //    answer.isPraised = YES;
    if ([[Utility isExistenceNetwork]isEqualToString:@"NotReachable"]) {
        [Utility errorAlert:@"暂无网络!"];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        QuestionModel *question = [self questionForIndexPath:path];
        AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:path]];
        self.activeIndexPath = path;
        [self.answerPraiseinterface getAnswerPraiseInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andQuestionId:question.questionId andResultId:answer.resultId];
    }
}

//追问
-(void)QuestionAndAnswerCell_iPhone:(QuestionAndAnswerCell_iPhone *)cell summitQuestion:(NSString *)questionStr atIndexPath:(NSIndexPath *)path withReaskType:(ReaskType)reaskType{
    if ([[Utility isExistenceNetwork]isEqualToString:@"NotReachable"]) {
        [Utility errorAlert:@"暂无网络!"];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        QuestionModel *question = [self questionForIndexPath:path];
        AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:path]];
        [self.submitAnswerInterface getSubmitAnswerInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andReaskTyep:reaskType andAnswerContent:questionStr andQuestionId:question.questionId andAnswerID:answer.resultId  andResultId:@"1"];
    }
}

//点击cell触发
-(void)QuestionAndAnswerCell_iPhone:(QuestionAndAnswerCell_iPhone *)cell isHiddleQuestionView:(BOOL)isHiddle atIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self questionForIndexPath:path];
    AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:path]];
    answer.isEditing = isHiddle;
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (answer.isEditing) {
        //把输入框textView移动到合适的位置
        [self closeOtherTextFieldsExcepteThisOne:path withType:NO];
        CGPoint offset = self.tableView.contentOffset;//当前窗口的偏移值
        CGRect rowFrame = [self.tableView rectForRowAtIndexPath:path];//当前row的位置
        CGFloat rowHeight = rowFrame.size.height;//row高度,其中回答模块高度87
        CGFloat aY = CGRectGetMaxY(rowFrame) - 87;//回答模块的上沿坐标
        CGFloat aHeight = 87 + 246.0 - IP5(63, 50);//上沿坐标的理想高度(相对tableView下沿)
        CGFloat bHeight = self.tableView.frame.size.height - (rowFrame.origin.y - offset.y + rowHeight -87);//当前上沿的高度(相对tableView下沿)
        CGFloat toOffsetY = offset.y + (aHeight - bHeight);//理想高度时的窗口Y偏移值
        [UIView animateWithDuration:0.5 animations:^{
            if(self.tableView.contentSize.height > self.tableView.frame.size.height){
                if(aHeight > self.tableView.contentSize.height - aY){//如果aY以下内容不足呈现理想位置,则滑动到内容最下方
                    [self.tableView setContentOffset:(CGPoint){rowFrame.origin.x, self.tableView.contentSize.height - self.tableView.frame.size.height}];
                }else if(aHeight > bHeight){
                    //如果剩余内容高度足够,且ay比理想位置低,则移动到理想位置
                    [self.tableView setContentOffset:(CGPoint){offset.x,toOffsetY}];
                }
            }
        }];
    }
    
}
//采纳答案
-(void)QuestionAndAnswerCell_iPhone:(QuestionAndAnswerCell_iPhone *)cell acceptAnswerAtIndexPath:(NSIndexPath *)path{
    QuestionModel *question = [self questionForIndexPath:path];
    AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:path]];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self keyboardDismiss];
}

#pragma mark --

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger index = 0;
    if(!self.questionIndexesArray){
        [Utility errorAlert:@"self.questionIndexesArray错误!"];
    }else{
        [self.questionIndexesArray removeAllObjects];
        for(QuestionModel *question in self.myQuestionArr){
            [self.questionIndexesArray addObject:[NSString stringWithFormat:@"%i",index]];
            index ++;
            if(question.answerList.count > 0){
                index += question.answerList.count;
            }
        }
    }
    return index;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getTableViewRowHeightWithIndexPath:indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self cellIsHeader:indexPath.row]){
        QuestionAndAnswerCell_iPhoneHeaderView *cell = (QuestionAndAnswerCell_iPhoneHeaderView *)[tableView dequeueReusableCellWithIdentifier:@"header"];
        QuestionModel *question = [self questionForIndexPath:indexPath];
        [cell setQuestionModel:question withQuestionAndAnswerScope:self.questionAndAnswerScope];
        cell.backgroundColor = [UIColor whiteColor];
        cell.delegate = self;
        cell.path = indexPath;
        return cell;
    }else{
        QuestionAndAnswerCell_iPhone *cell = (QuestionAndAnswerCell_iPhone*)[tableView dequeueReusableCellWithIdentifier:@"questionAndAnswerCell"];
        QuestionModel *question = [self questionForIndexPath:indexPath];
        AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:indexPath]];
        [cell setAnswerModel:answer withQuestion:question];
        cell.delegate = self;
        cell.path = indexPath;
        cell.contentView.frame = (CGRect){cell.contentView.frame.origin,CGRectGetWidth(cell.contentView.frame),[self getTableViewRowHeightWithIndexPath:indexPath]};
        return cell;
    }
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

-(void)rightItemClicked:(id)sender{
    if(!self.menu){
        self.menu = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuQuestionTableViewController"];
        [self addChildViewController:self.menu];
        self.menu.myQAVC = self;
        self.menuVisible = YES;
        [self.view addSubview:self.menu.view];
    }else{
        self.menuVisible = !self.menuVisible;
    }
}

-(void)askQuestionBtnClicked:(id)sender{
    if (!self.askQuestionController) {
        self.askQuestionController  = [self.storyboard instantiateViewControllerWithIdentifier:@"LHLAskQuestionViewController"];
        self.askQuestionController.delegate = self;
    }
    
    [self.navigationController pushViewController:self.askQuestionController animated:YES];
    
}

-(void)setMenuVisible:(BOOL)menuVisible{
    _menuVisible = menuVisible;
    [UIView animateWithDuration:0.3 animations:^{
        if(menuVisible){
            [self keyboardDismiss];
            self.menu.view.frame = CGRectMake(120,IP5(65, 55), 200, SCREEN_HEIGHT - IP5(63, 50) - IP5(65, 55));
        }else{
            self.menu.view.frame = CGRectMake(320,IP5(65, 55), 200, SCREEN_HEIGHT - IP5(63, 50) - IP5(65, 55));
        }
    }];
}

-(void)keyboardDismiss{
    //暴力遍历所有cell
    for(int i = 0; i < self.tableView.visibleCells.count;i ++ ){
        if([self.tableView.visibleCells[i] isKindOfClass:[QuestionAndAnswerCell_iPhone class]]){
            QuestionAndAnswerCell_iPhone *cell = self.tableView.visibleCells[i];
            for(UIView *view in cell.contentView.subviews){
                if(view.isFirstResponder){
                    [view resignFirstResponder];return;
                }
                for(UIView *view2 in view.subviews){
                    if(view2.isFirstResponder){
                        [view2 resignFirstResponder];return;
                    }
                    for(UIView *view3 in view2.subviews){
                        if(view3.isFirstResponder){
                            [view3 resignFirstResponder];return;
                        }
                        for(UIView *view4 in view3.subviews){
                            if(view4.isFirstResponder){
                                [view4 resignFirstResponder];return;
                            }
                        }
                    }
                }
            }
        }else if([self.tableView.visibleCells[i] isKindOfClass:[QuestionAndAnswerCell_iPhoneHeaderView class]]){
            QuestionAndAnswerCell_iPhoneHeaderView *cell = self.tableView.visibleCells[i];
            for(UIView *view in cell.subviews){
                if(view.isFirstResponder){
                    [view resignFirstResponder];return;
                }
                for(UIView *view2 in view.subviews){
                    if(view2.isFirstResponder){
                        [view2 resignFirstResponder];return;
                    }
                    for(UIView *view3 in view2.subviews){
                        if(view3.isFirstResponder){
                            [view3 resignFirstResponder];return;
                        }
                        for(UIView *view4 in view3.subviews){
                            if(view4.isFirstResponder){
                                [view4 resignFirstResponder];return;
                            }
                        }
                    }
                }
            }
        }
    }
}

-(void)closeOtherTextFieldsExcepteThisOne:(NSIndexPath *)path withType:(BOOL) isQuestion{
    //关闭除指定path之外所有可输入的textView,改变其cell状态
    if(isQuestion){
        QuestionModel *currentQuestion = [self questionForIndexPath:path];
        for(QuestionModel *q in self.myQuestionArr){
            if(q.questionId != currentQuestion.questionId){
                q.isEditing = NO;
            }
            for(AnswerModel *a in q.answerList){
                a.isEditing = NO;
            }
        }
    }else{
        NSInteger answerIndex = [self answerForCellIndexPath:path];
        AnswerModel *currentAnswer = [self questionForIndexPath:path].answerList[answerIndex];
        for(QuestionModel *q in self.myQuestionArr){
            q.isEditing = NO;
            for(AnswerModel *a in q.answerList){
                if(a.answerId != currentAnswer.answerId){
                    a.isEditing = NO;
                }
            }
        }
    }
    [self.tableView reloadData];
}

-(void)requestNewPageDataWithLastQuestionID:(NSString*)lastQuestionID{
    if (self.questionAndAnswerScope == QuestionAndAnswerALL) {
        [self.questionListInterface getQuestionListInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andChapterQuestionId:self.chapterID andLastQuestionID:lastQuestionID];
    }else
        if (self.questionAndAnswerScope == QuestionAndAnswerMYANSWER) {
//            [self.userQuestionInterface getGetUserQuestionInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andIsMyselfQuestion:@"1" andLastQuestionID:lastQuestionID];
        }else
            if (self.questionAndAnswerScope == QuestionAndAnswerMYQUESTION) {
//                [self.userQuestionInterface getGetUserQuestionInterfaceDelegateWithUserId:[[CaiJinTongManager shared] userId] andIsMyselfQuestion:@"0" andLastQuestionID:lastQuestionID];
            }
}

-(float)getTableViewRowHeightWithIndexPath:(NSIndexPath*)path{
    QuestionModel *question = [self questionForIndexPath:path];
    if([self cellIsHeader:path.row]){  //如果是问题本身(header)
        if (question.isEditing) {
            return  [Utility getTextSizeWithString:question.questionName withFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE+4] withWidth:QUESTIONHEARD_VIEW_WIDTH + TEXT_PADDING * 2].height + TEXT_HEIGHT + QUESTIONHEARD_VIEW_ANSWER_BACK_VIEW_HEIGHT;
        }else{
            return  [Utility getTextSizeWithString:question.questionName withFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE+4] withWidth:QUESTIONHEARD_VIEW_WIDTH + TEXT_PADDING * 2].height + TEXT_HEIGHT;
        }
    }
    if (question.answerList == nil || [question.answerList count] <= 0) {
        return 0;
    }
    AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:path]];
    float questionTextFieldHeight = answer.isEditing?87:0;
    NSAttributedString *attriString =  [Utility getTextSizeWithAnswerModel:answer withFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE+4] withWidth:QUESTIONANDANSWER_CELL_WIDTH];
    CGSize size = [Utility getAttributeStringSizeWithWidth:QUESTIONANDANSWER_CELL_WIDTH withAttributeString:attriString];
    if (platform >= 7.0) {
        return size.height + TEXT_PADDING*4+ questionTextFieldHeight;
    }else{
        return size.height + TEXT_PADDING*4+ questionTextFieldHeight;
    }
}

#pragma mark --

#pragma mark headerCell索引数组管理

-(BOOL)cellIsHeader:(NSInteger)row{  //根据row判断一个cell是不是header
    for(NSString *index in self.questionIndexesArray){
        if(row == index.integerValue){
            return YES;
        }
    }
    return NO;
}

-(QuestionModel *)questionForIndexPath:(NSIndexPath *) indexPath{ //根据indexPath获得其相应的question对象
    for(int i = 1 ; i < self.questionIndexesArray.count;i ++){
        NSString *index = self.questionIndexesArray[i];
        if(index.integerValue > indexPath.row){
            return self.myQuestionArr[i - 1];
        }
        if(i == self.questionIndexesArray.count - 1){
            return self.myQuestionArr[i];
        }
    }
    return nil;
}

//根据cell的indexPath返回其在AnswerArray中的索引号
-(NSInteger)answerForCellIndexPath:(NSIndexPath *)indexPath{
    NSString *index;
    //1,计算其所属的问题索引
    //2,计算其与问题索引的偏差值,并以此作为从AnswerArray取出answer对象的依据
    for(int i = 1; i < self.questionIndexesArray.count; i ++ ){
        index = self.questionIndexesArray[i];
        if(index.integerValue > indexPath.row){
            NSString *headerIndex = self.questionIndexesArray[i - 1];
            return indexPath.row - headerIndex.integerValue - 1;
        }
    }
    return indexPath.row - index.integerValue - 1;
}

#pragma mark --

#pragma mark property
-(void)setQuestionAndAnswerScope:(QuestionAndAnswerScope)questionAndAnswerScope{
    _questionAndAnswerScope = questionAndAnswerScope;
    switch (questionAndAnswerScope) {
        case QuestionAndAnswerALL:
            self.lhlNavigationBar.title.text = @"所有问答";
            break;
        case QuestionAndAnswerMYQUESTION:
            self.lhlNavigationBar.title.text = @"我的提问";
            break;
        default:
            self.lhlNavigationBar.title.text = @"我的回答";
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
    CGRect frame = self.tableView.frame;
    [self.tableView setFrame: CGRectMake(frame.origin.x,self.lhlNavigationBar.frame.size.height + 5,frame.size.width,IP5(568, 480) - self.lhlNavigationBar.frame.size.height - 5 - self.tabBarController.tabBar.frame.size.height)];
}

#pragma mark DRAskQuestionViewControllerDelegate 提问问题成功时回调
-(void)askQuestionViewControllerDidAskingSuccess:(LHLAskQuestionViewController *)controller{
    self.isReaskRefreshing = YES;
    [self requestNewPageDataWithLastQuestionID:nil];
}
#pragma mark --

#pragma mark AnswerPraiseInterfaceDelegate 赞回调
-(void)getAnswerPraiseInfoDidFinished:(NSDictionary *)result{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:@"赞成功"];
    QuestionModel *question = [self questionForIndexPath:self.activeIndexPath];
    AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:self.activeIndexPath]];
    answer.answerPraiseCount = [NSString stringWithFormat:@"%d",[answer.answerPraiseCount integerValue]+1];
    answer.isPraised = @"1";
    [self.tableView reloadRowsAtIndexPaths:@[self.activeIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
                self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                [self.tableView reloadData];
            }else{
                if (self.headerRefreshView.isForbidden) {//加载下一页
                    [self.myQuestionArr addObjectsFromArray:chapterQuestionList];
                }else{//重新加载
                    self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                }
                [self.tableView reloadData];
                [self.headerRefreshView endRefreshing];
                self.headerRefreshView.isForbidden = NO;
                [self.footerRefreshView endRefreshing];
                self.footerRefreshView.isForbidden = NO;
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

-(void)getUserQuestionInfoDidFailed:(NSString *)errorMsg{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}

#pragma mark --

#pragma mark QuestionListInterfaceDelegate 加载所有问题新数据
-(void)getQuestionListInfoDidFinished:(NSDictionary *)result{
    if (!self.isReaskRefreshing) {
        if (result) {
            NSArray *chapterQuestionList = [result objectForKey:@"chapterQuestionList"];
            if (chapterQuestionList && [chapterQuestionList count] > 0) {
                if (self.headerRefreshView.isForbidden) {//加载下一页
                    [self.myQuestionArr addObjectsFromArray:chapterQuestionList];
                }else{//重新加载
                    self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                }
                QuestionModel *question = [self.myQuestionArr  lastObject];
                self.question_pageIndex = question.pageIndex;
                self.question_pageCount = question.pageCount;
                [self.tableView reloadData];
            }else{
                [Utility errorAlert:@"数据为空"];
            }
        }else{
            [Utility errorAlert:@"数据为空"];
        }
        [self.headerRefreshView endRefreshing];
        self.headerRefreshView.isForbidden = NO;
        [self.footerRefreshView endRefreshing];
        self.footerRefreshView.isForbidden = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }else{
        if (result) {
            NSArray *chapterQuestionList = [result objectForKey:@"chapterQuestionList"];
            if (chapterQuestionList && [chapterQuestionList count] > 0) {
                self.myQuestionArr = [NSMutableArray arrayWithArray:chapterQuestionList];
                QuestionModel *question = [self.myQuestionArr  lastObject];
                self.question_pageIndex = question.pageIndex;
                self.question_pageCount = question.pageCount;
                [self.tableView reloadData];
            }else{
                [Utility errorAlert:@"数据为空"];
            }
        }else{
            [Utility errorAlert:@"数据为空"];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

-(void)getQuestionListInfoDidFailed:(NSString *)errorMsg{
    [self.headerRefreshView endRefreshing];
    self.headerRefreshView.isForbidden = NO;
    [self.footerRefreshView endRefreshing];
    self.footerRefreshView.isForbidden = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}
#pragma mark --


#pragma mark -- AcceptAnswerInterfaceDelegate 采纳答案
-(void)getAcceptAnswerInfoDidFinished:(NSDictionary *)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            QuestionModel *question = [self questionForIndexPath:self.activeIndexPath];
            AnswerModel *answer = [question.answerList objectAtIndex:[self answerForCellIndexPath:self.activeIndexPath]];
            question.isAcceptAnswer = @"1";
            answer.IsAnswerAccept = @"1";
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.activeIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [Utility errorAlert:@"提交采纳正确回答成功"];
        });
    });
}
-(void)getAcceptAnswerInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}

-(void)dealloc{
    if (self.questionAndAnswerScope == QuestionAndAnswerALL) {
        [self.headerRefreshView free];
        [self.footerRefreshView free];
    }
}

@end
