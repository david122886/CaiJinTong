//
//  QuestionV2ViewController.m
//  CaiJinTongApp
//
//  Created by david on 14-4-23.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "QuestionV2ViewController.h"
#import "QuestionRequestDataInterface.h"
#import "DRTypeQuestionContentViewController.h"
@interface DRActionSheet : UIActionSheet
@property (nonatomic,strong) NSIndexPath *path;
@property (nonatomic,strong) QuestionModel *questionModel;
@property (nonatomic,strong) AnswerModel *answerModel;
@property (nonatomic,assign) ReaskType reaskType;
@end
@implementation DRActionSheet



@end

@interface QuestionV2ViewController ()
@property (nonatomic,strong) DRActionSheet *actionSheet;
///提交文本控件
@property (nonatomic,strong) DRTypeQuestionContentViewController *typeContentController;

@property (nonatomic,strong) ChapterSearchBar_iPhone *searchBar;//搜索栏+按钮
@property (nonatomic,strong) DRTreeTableView *drTreeTableView;
@property (nonatomic,strong) UIButton *askQuestionBtn;  //我要提问button
@property (nonatomic,assign) BOOL menuVisible;//菜单是否可见

///分页加载时判断是否是加载搜索结果
@property (nonatomic,assign) BOOL isSearching;

@property (nonatomic,strong) MJRefreshHeaderView *headerRefreshView;
@property (nonatomic,strong) MJRefreshFooterView *footerRefreshView;

@end

@implementation QuestionV2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

///重新加载问答数据，所需的分类id，分类类型在CaiJinTongManager单利中
-(void)reloadQuestionData{
    UserModel *user = [[UserModel alloc] init];
    user.userId = @"17082";
    [CaiJinTongManager shared].user = user;
    [CaiJinTongManager shared].userId = @"17082";
    [CaiJinTongManager shared].selectedQuestionCategoryType = CategoryType_MyAnswer;
    ///////////////////////test
    switch ([CaiJinTongManager shared].selectedQuestionCategoryType) {
        case CategoryType_AllQuestion://所有问答
        {
            __weak QuestionV2ViewController *weakSelf = self;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [QuestionRequestDataInterface downloadALLQuestionListWithUserId:[CaiJinTongManager shared].user.userId andQuestionCategoryId:[CaiJinTongManager shared].selectedQuestionCategoryId andLastQuestionID:nil withSuccess:^(NSArray *questionModelArray) {
                QuestionV2ViewController *tempSelf = weakSelf;
                if (tempSelf) {
                    tempSelf.questionDataArray = [NSMutableArray arrayWithArray:questionModelArray];
                    [tempSelf.tableView reloadData];
                    [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
                }
            } withError:^(NSError *error) {
                QuestionV2ViewController *tempSelf = weakSelf;
                if (tempSelf) {
                    [Utility errorAlert:[error.userInfo  objectForKey:@"msg"]];
                    [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
                }
            }];
        }
            break;
        case CategoryType_MyQuestion://我的提问
        {
            __weak QuestionV2ViewController *weakSelf = self;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [QuestionRequestDataInterface downloadUserQuestionListWithUserId:[CaiJinTongManager shared].user.userId andIsMyselfQuestion:@"0" andLastQuestionID:nil withCategoryId:[CaiJinTongManager shared].selectedQuestionCategoryId withSuccess:^(NSArray *questionModelArray) {
                QuestionV2ViewController *tempSelf = weakSelf;
                if (tempSelf) {
                    tempSelf.questionDataArray = [NSMutableArray arrayWithArray:questionModelArray];
                    [tempSelf.tableView reloadData];
                    [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
                }
            } withError:^(NSError *error) {
                QuestionV2ViewController *tempSelf = weakSelf;
                if (tempSelf) {
                    [Utility errorAlert:[error.userInfo  objectForKey:@"msg"]];
                    [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
                }
            }];
        }
            break;
        case CategoryType_MyAnswer://我的回答
        {
            __weak QuestionV2ViewController *weakSelf = self;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [QuestionRequestDataInterface downloadUserQuestionListWithUserId:[CaiJinTongManager shared].user.userId andIsMyselfQuestion:@"1" andLastQuestionID:nil withCategoryId:[CaiJinTongManager shared].selectedQuestionCategoryId withSuccess:^(NSArray *questionModelArray) {
                QuestionV2ViewController *tempSelf = weakSelf;
                if (tempSelf) {
                    tempSelf.questionDataArray = [NSMutableArray arrayWithArray:questionModelArray];
                    [tempSelf.tableView reloadData];
                    [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
                }
            } withError:^(NSError *error) {
                QuestionV2ViewController *tempSelf = weakSelf;
                if (tempSelf) {
                    [Utility errorAlert:[error.userInfo  objectForKey:@"msg"]];
                    [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
                }
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark 顶部导航栏代理
-(void)rightItemClicked:(id)sender{
    [self.searchBar.searchTextField resignFirstResponder];
    
    if((!self.drTreeTableView || self.drTreeTableView.noteArr.count < 1) && self.menuVisible != YES){
        _drTreeTableView = [[DRTreeTableView alloc] initWithFrame:CGRectMake(0,55, 320, SCREEN_HEIGHT - IP5(63, 50) - 55) withTreeNodeArr:nil];
        _drTreeTableView.delegate = self;
        __weak QuestionV2ViewController *weakSelf = self;
        _drTreeTableView.hiddleBlock = ^(BOOL ishiddle){
            QuestionV2ViewController *tempSelf = weakSelf;
            if (tempSelf) {
                tempSelf.menuVisible = !ishiddle;
            }
            
        };
        [self.view addSubview:_drTreeTableView];
        //        [self.drTreeTableView setBackgroundColor:[UIColor colorWithRed:6.0/255.0 green:18.0/255.0 blue:27.0/255.0 alpha:1.0]];
//        [self getQuestionCategoryNodes];  //获取tree所需数据
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [QuestionRequestDataInterface downloadUserQuestionCategoryWithUserId:[CaiJinTongManager shared].user.userId withSuccess:^(NSArray *userQuestionCategoryArray) {
            QuestionV2ViewController *tempSelf = weakSelf;
            if (tempSelf) {
                tempSelf.drTreeTableView.noteArr = [NSMutableArray arrayWithArray:userQuestionCategoryArray];
                [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
            }
        } withError:^(NSError *error) {
            QuestionV2ViewController *tempSelf = weakSelf;
            if (tempSelf) {
                [Utility errorAlert:[error.userInfo  objectForKey:@"msg"]];
                [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
            }
        }];
        
        self.menuVisible = YES;
        [self.drTreeTableView setHiddleTreeTableView:!self.menuVisible withAnimation:YES];
    }else{
        self.menuVisible = !self.menuVisible;
        [self.drTreeTableView setHiddleTreeTableView:!self.menuVisible withAnimation:YES];
    }
}

-(void)leftItemClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//TODO::提问
-(void)askQuestionBtnClicked:(id)sender{
    LHLAskQuestionViewController * askQuestionController  = [self.storyboard instantiateViewControllerWithIdentifier:@"LHLAskQuestionViewController"];
    askQuestionController.delegate = self;
    
    [self.navigationController pushViewController:askQuestionController animated:YES];
    
}

#pragma mark --

//TODO::分页加载搜索的内容
-(void)downloadSearchContentWithLastQuestionId:(NSString*)lastQuestionId{
     __weak QuestionV2ViewController *weakSelf = self;
    [QuestionRequestDataInterface searchQuestionListWithUserId:[CaiJinTongManager shared].user.userId andText:self.searchBar.searchTextField.text withLastQuestionId:lastQuestionId withSuccess:^(NSArray *questionModelArray) {
        QuestionV2ViewController *tempSelf = weakSelf;
        if (tempSelf) {
            tempSelf.isSearching = YES;
            if (lastQuestionId) {
                [tempSelf.questionSearchDataArray addObjectsFromArray:questionModelArray];
            }else{
            tempSelf.tableView.contentOffset = (CGPoint){tempSelf.tableView.contentOffset.x,0};
            tempSelf.questionSearchDataArray = [NSMutableArray arrayWithArray:questionModelArray];
            }
            [tempSelf.tableView reloadData];
            [tempSelf.headerRefreshView endRefreshing];
            tempSelf.headerRefreshView.isForbidden = NO;
            [tempSelf.footerRefreshView endRefreshing];
            tempSelf.footerRefreshView.isForbidden = NO;
            [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
        }
    } withError:^(NSError *error) {
        QuestionV2ViewController *tempSelf = weakSelf;
        if (tempSelf) {
            [tempSelf.headerRefreshView endRefreshing];
            tempSelf.headerRefreshView.isForbidden = NO;
            [tempSelf.footerRefreshView endRefreshing];
            tempSelf.footerRefreshView.isForbidden = NO;
            [Utility errorAlert:[error.userInfo  objectForKey:@"msg"]];
            [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
        }
    }];
}

//TODO::加载所有问答数据
-(void)downloadAllQuestionContentWithLastQuestionId:(NSString*)lastQuestionId{
    __weak QuestionV2ViewController *weakSelf = self;
    self.isSearching = NO;
    [QuestionRequestDataInterface downloadALLQuestionListWithUserId:[CaiJinTongManager shared].user.userId andQuestionCategoryId:[CaiJinTongManager shared].selectedQuestionCategoryId andLastQuestionID:lastQuestionId withSuccess:^(NSArray *questionModelArray) {
        QuestionV2ViewController *tempSelf = weakSelf;
        if (tempSelf) {
            if (lastQuestionId) {
                [tempSelf.questionDataArray addObjectsFromArray:questionModelArray];
            }else{
                tempSelf.tableView.contentOffset = (CGPoint){tempSelf.tableView.contentOffset.x,0};
                tempSelf.questionDataArray = [NSMutableArray arrayWithArray:questionModelArray];
            }
            [tempSelf.tableView reloadData];
            [tempSelf.headerRefreshView endRefreshing];
            tempSelf.headerRefreshView.isForbidden = NO;
            [tempSelf.footerRefreshView endRefreshing];
            tempSelf.footerRefreshView.isForbidden = NO;
            [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
        }
    } withError:^(NSError *error) {
        QuestionV2ViewController *tempSelf = weakSelf;
        if (tempSelf) {
            [tempSelf.headerRefreshView endRefreshing];
            tempSelf.headerRefreshView.isForbidden = NO;
            [tempSelf.footerRefreshView endRefreshing];
            tempSelf.footerRefreshView.isForbidden = NO;
            [Utility errorAlert:[error.userInfo  objectForKey:@"msg"]];
            [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
        }
    }];
}

//TODO::加载我的问答数据
-(void)downloadMyQuestionContentWithLastQuestionId:(NSString*)lastQuestionId{
    __weak QuestionV2ViewController *weakSelf = self;
    self.isSearching = NO;
    NSString *myQuestion = @"1";
    if ([CaiJinTongManager shared].selectedQuestionCategoryType == CategoryType_MyQuestion) {
        myQuestion = @"0";
    }
    [QuestionRequestDataInterface downloadUserQuestionListWithUserId:[CaiJinTongManager shared].user.userId andIsMyselfQuestion:myQuestion andLastQuestionID:lastQuestionId withCategoryId:[CaiJinTongManager shared].selectedQuestionCategoryId withSuccess:^(NSArray *questionModelArray) {
        QuestionV2ViewController *tempSelf = weakSelf;
        if (tempSelf) {
            if (lastQuestionId) {
                [tempSelf.questionDataArray addObjectsFromArray:questionModelArray];
            }else{
                tempSelf.tableView.contentOffset = (CGPoint){tempSelf.tableView.contentOffset.x,0};
                tempSelf.questionDataArray = [NSMutableArray arrayWithArray:questionModelArray];
            }
            [tempSelf.tableView reloadData];
            [tempSelf.headerRefreshView endRefreshing];
            tempSelf.headerRefreshView.isForbidden = NO;
            [tempSelf.footerRefreshView endRefreshing];
            tempSelf.footerRefreshView.isForbidden = NO;
            [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
        }
    } withError:^(NSError *error) {
        QuestionV2ViewController *tempSelf = weakSelf;
        if (tempSelf) {
            [tempSelf.headerRefreshView endRefreshing];
            tempSelf.headerRefreshView.isForbidden = NO;
            [tempSelf.footerRefreshView endRefreshing];
            tempSelf.footerRefreshView.isForbidden = NO;
            [Utility errorAlert:[error.userInfo  objectForKey:@"msg"]];
            [MBProgressHUD hideHUDForView:tempSelf.view animated:YES];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"QuestionCellV2" bundle:nil] forCellReuseIdentifier:@"questionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AnswerForQuestionCellV2" bundle:nil] forCellReuseIdentifier:@"answerCell"];
    // Do any additional setup after loading the view from its nib.
    
    //提问按钮
    if(!self.askQuestionBtn){
        CGPoint center = self.lhlNavigationBar.leftItem.center;
        self.askQuestionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.askQuestionBtn setFrame:(CGRect){0,0,40,40}];
        self.askQuestionBtn.center = (CGPoint){center.x + 45 + 180,center.y};
        [self.askQuestionBtn setBackgroundColor:[UIColor clearColor]];
        [self.askQuestionBtn setImage:[UIImage imageNamed:@"_question_mark.png"] forState:UIControlStateNormal];
        [self.askQuestionBtn addTarget:self action:@selector(askQuestionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.lhlNavigationBar addSubview:self.askQuestionBtn];
    }
    
    //搜索
     [self.view addSubview:self.searchBar];
    
    [self.footerRefreshView endRefreshing];
    [self.headerRefreshView endRefreshing];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self downloadMyQuestionContentWithLastQuestionId:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
#pragma mark --

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = [self.questionDataArray objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[QuestionModel class]]) {
        QuestionModel *question = (QuestionModel*)model;
        QuestionCellV2 *questionCell = (QuestionCellV2*)[tableView dequeueReusableCellWithIdentifier:@"questionCell"];
        questionCell.path = indexPath;
        questionCell.delegate = self;
        [questionCell refreshCellWithQuestionModel:question];
        return questionCell;
    }else{
        AnswerModel *answer = (AnswerModel*)model;
        AnswerForQuestionCellV2 *answerCell = (AnswerForQuestionCellV2*)[tableView dequeueReusableCellWithIdentifier:@"answerCell"];
        answerCell.path = indexPath;
        answerCell.delegate = self;
        [answerCell refreshCellWithAnswerModel:answer];
        return answerCell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = [self.questionDataArray objectAtIndex:indexPath.row];
    if ([model isKindOfClass:[QuestionModel class]]) {
        QuestionModel *question = (QuestionModel*)model;
        CGRect richContentRect = [RichQuestionContentView richQuestionContentStringWithRichContentObjs:question.questionRichContentArray withWidth:260];
        return CGRectGetHeight(richContentRect) + 116;
    }else{
        AnswerModel *answer = (AnswerModel*)model;
        CGRect richContentRect = [RichQuestionContentView richQuestionContentStringWithRichContentObjs:answer.answerRichContentArray withWidth:260];
        return CGRectGetHeight(richContentRect) + 50;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.questionDataArray.count;
}

#pragma mark --



#pragma mark AnswerForQuestionCellV2Delegate 回答类代理
///选中内容图片时调用
-(void)answerForQuestionCellV2:(AnswerForQuestionCellV2*)answerCell selectedImageType:(RichContextObj*)richContentObj AtIndexPath:(NSIndexPath*)path{

}

///选择多动能按钮时调用
-(void)answerForQuestionCellV2:(AnswerForQuestionCellV2*)answerCell selectedMoreButtonAtIndexPath:(NSIndexPath*)path withAnswerType:(ReaskType)answerType{
    AnswerModel *answer = answerCell.answerModel;
    QuestionModel *question = (QuestionModel*)answer.questionModel;

    if ([question.askerId isEqualToString:[CaiJinTongManager shared].user.userId]) {
        //自己提问的问题
        if (answer.answerContentType == ReaskType_Answer) {
            //追问别人的回答
//            [self.actionSheet addButtonWithTitle:@"追问"];
            self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"追问",nil];
            if (![answer.answerIsCorrect isEqualToString:@"1"]) {
//                [self.actionSheet addButtonWithTitle:@"采纳答案"];
                self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"追问",@"采纳答案",nil];
            }
        }else
            if (answer.answerContentType == ReaskType_Reask) {
                //修改追问
//                [self.actionSheet addButtonWithTitle:@"修改追问"];
                self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"修改追问",nil];
            }else{
                //对回复进行追问
//                [self.actionSheet addButtonWithTitle:@"继续追问"];
                self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"继续追问",nil];
            }
    }else{
        //别人提问的问题
        if ([answer.answerUserId isEqualToString:[CaiJinTongManager shared].user.userId]) {
            if (answer.answerContentType == ReaskType_Answer) {
//                [self.actionSheet addButtonWithTitle:@"修改回答"];
                self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"修改回答",nil];
            }else
                if (answer.answerContentType == ReaskType_Reask){
                    //回复
//                    [self.actionSheet addButtonWithTitle:@"回复"];
                    self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",nil];
                }else{
                    //修改回复
//                     [self.actionSheet addButtonWithTitle:@"修改回复"];
                    self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"修改回复",nil];
                }
        }
    }
    
    if (answer.answerIsPraised && [answer.answerIsPraised isEqualToString:@"1"]) {
        
    }else{
        //赞
        if (![answer.answerUserId isEqualToString:[CaiJinTongManager shared].user.userId] && answer.answerContentType == ReaskType_Answer) {
            [self.actionSheet addButtonWithTitle:@"赞一下"];
        }
    }
    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    self.actionSheet.questionModel = answerCell.answerModel.questionModel;
    self.actionSheet.answerModel = answerCell.answerModel;
    self.actionSheet.path = path;
    
    [CaiJinTongManager shared].path = path;
    [CaiJinTongManager shared].questionModel = answerCell.answerModel.questionModel;
    [CaiJinTongManager shared].answerModel = answerCell.answerModel;
    [self.actionSheet showInView:self.view];
}
#pragma mark --


#pragma mark QuestionCellV2Delegate 问题cell代理
///选中内容图片时调用
-(void)questionCellV2:(QuestionCellV2*)questionCell selectedImageType:(RichContextObj*)richContentObj AtIndexPath:(NSIndexPath*)path{

}

///选中多功能按钮时调用
-(void)questionCellV2:(QuestionCellV2*)questionCell selectedMenuButtonAtIndexPath:(NSIndexPath*)path{
    QuestionModel *question = questionCell.questionModel;
    BOOL isAnswered = NO;
    for (AnswerModel *answer in question.answerList) {
        if ([answer.answerUserId isEqualToString:[CaiJinTongManager shared].user.userId]) {
            isAnswered = YES;
            break;
        }
    }
    
    self.actionSheet = [[DRActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:isAnswered?@"修改回答":@"回答", nil];
    self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    self.actionSheet.questionModel = questionCell.questionModel;
    self.actionSheet.path = path;
    self.actionSheet.answerModel = nil;
    [CaiJinTongManager shared].path = path;
    [CaiJinTongManager shared].questionModel = questionCell.questionModel;
    [CaiJinTongManager shared].answerModel = nil;
    [self.actionSheet showInView:self.view];
}

///点击回答或者问题内容时调用,展开回答相关内容
-(void)questionCellV2:(QuestionCellV2*)questionCell extendAnswerContentButtonAtIndexPath:(NSIndexPath*)path{

}

///点击查看附件时调用
-(void)questionCellV2:(QuestionCellV2*)questionCell viewAttachmentButtonAtIndexPath:(NSIndexPath*)path{

}
#pragma mark --

#pragma mark uiactionSheet弹出菜单代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    DRActionSheet *sheet = (DRActionSheet*)actionSheet;
    QuestionModel *question = sheet.questionModel;
    AnswerModel *answer = sheet.answerModel;
    NSArray *removedAnswerArray = nil;
    if (question) {
        removedAnswerArray = question.answerList;
    }else{
        removedAnswerArray = [(QuestionModel*)answer.questionModel answerList];
    }
    /////////////////////begin/////////////////////
    NSString *editTip = @"";
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"回答"]) {
        editTip = @"回答";
        [CaiJinTongManager shared].reaskType = ReaskType_Answer;
    }
    if ([title isEqualToString:@"回复"]) {
        editTip = @"回复";
        [CaiJinTongManager shared].reaskType = ReaskType_AnswerForReasking;
    }
    if ([title isEqualToString:@"修改回复"]) {
        editTip = @"修改回复";
        [CaiJinTongManager shared].reaskType = ReaskType_ModifyReaskAnswer;
    }
    if ([title isEqualToString:@"修改回答"]) {
        editTip = @"修改回答";
        [CaiJinTongManager shared].reaskType = ReaskType_ModifyAnswer;
    }
    if ([title isEqualToString:@"修改追问"]) {
        editTip = @"修改追问";
        [CaiJinTongManager shared].reaskType = ReaskType_ModifyReask;
    }
    if ([title isEqualToString:@"追问"]) {
        editTip = @"追问";
        [CaiJinTongManager shared].reaskType = ReaskType_Reask;
    }
    if ([title isEqualToString:@"继续追问"]) {
        editTip = @"继续追问";
        [CaiJinTongManager shared].reaskType = ReaskType_Reask;
    }
    if ([title isEqualToString:@"采纳答案"]) {
        editTip = @"采纳答案";
        [CaiJinTongManager shared].reaskType = ReaskType_AcceptAnswer;
    }
    if ([title isEqualToString:@"取消"]) {
        return;
    }
    /////////////////////end/////////////////////
    __weak QuestionV2ViewController *weakSelf = self;
    self.typeContentController.submitFinishedBlock = ^(NSArray *dataArray ,NSString *errorMsg){
        //刷新数据
        if (!dataArray || dataArray.count <= 0) {
            return;
        }
        QuestionV2ViewController *tempSelf = weakSelf;
        if (tempSelf) {
            [tempSelf.questionDataArray removeObjectsInArray:removedAnswerArray];
            int insertIndex = sheet.path.row+1;
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:insertIndex];
            for (int count = 1; count < dataArray.count; count++) {
                [indexSet addIndex:insertIndex + count];
            }
            [tempSelf.questionDataArray insertObjects:dataArray atIndexes:indexSet];
            [tempSelf.tableView reloadData];
        }
        
    };
    self.typeContentController.inputTextView.text = @"";
    [self presentViewController:self.typeContentController animated:YES completion:^{
        self.typeContentController.lhlNavigationBar.title.text = editTip;
    }];
 
}
#pragma mark --


#pragma mark DRAskQuestionViewControllerDelegate 提问问题成功时回调
-(void)askQuestionViewControllerDidAskingSuccess:(LHLAskQuestionViewController *)controller{
//    self.isReaskRefreshing = YES;
//    [self requestNewPageDataWithLastQuestionID:nil];
}
#pragma mark --


#pragma mark DRTreeTableViewDelegate //选择一个分类
-(void)drTreeTableView:(DRTreeTableView *)treeView didSelectedTreeNode:(DRTreeNode *)selectedNote{
    [CaiJinTongManager shared].selectedQuestionCategoryId = selectedNote.noteContentID;
    switch ([selectedNote.noteRootContentID integerValue]) {
        case CategoryType_AllQuestion://所有问答
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [CaiJinTongManager shared].selectedQuestionCategoryType = CategoryType_AllQuestion;
            [self downloadAllQuestionContentWithLastQuestionId:nil];
        }
            break;
        case CategoryType_MyQuestion://我的提问
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [CaiJinTongManager shared].selectedQuestionCategoryType = CategoryType_MyQuestion;
            [self downloadMyQuestionContentWithLastQuestionId:nil];
        }
            break;
        case CategoryType_MyAnswer://我的回答
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [CaiJinTongManager shared].selectedQuestionCategoryType = CategoryType_MyAnswer;
            [self downloadMyQuestionContentWithLastQuestionId:nil];
        }
            break;
        case CategoryType_MyAnswerAndQuestion://我的问答
        {
        }
            break;
        default:{
            
        }
            break;
    }
    

    self.menuVisible = NO;
    [self.drTreeTableView setHiddleTreeTableView:!self.menuVisible withAnimation:YES];
    self.searchBar.searchTextField.text = nil;
}

-(BOOL)drTreeTableView:(DRTreeTableView *)treeView isExtendChildSelectedTreeNode:(DRTreeNode *)selectedNote{
    return YES;
}

-(void)drTreeTableView:(DRTreeTableView*)treeView didExtendChildTreeNode:(DRTreeNode*)extendNote{
    [CaiJinTongManager shared].selectedQuestionCategoryId = extendNote.noteContentID;
    switch ([extendNote.noteRootContentID integerValue]) {
        case CategoryType_AllQuestion://所有问答
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [CaiJinTongManager shared].selectedQuestionCategoryType = CategoryType_AllQuestion;
            [self downloadAllQuestionContentWithLastQuestionId:nil];
        }
            break;
        case CategoryType_MyQuestion://我的提问
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [CaiJinTongManager shared].selectedQuestionCategoryType = CategoryType_MyQuestion;
            [self downloadMyQuestionContentWithLastQuestionId:nil];
        }
            break;
        case CategoryType_MyAnswer://我的回答
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [CaiJinTongManager shared].selectedQuestionCategoryType = CategoryType_MyAnswer;
            [self downloadMyQuestionContentWithLastQuestionId:nil];
        }
            break;
        case CategoryType_MyAnswerAndQuestion://我的问答
        {
        }
            break;
        default:{
            
        }
            break;
    }
    self.searchBar.searchTextField.text = nil;
}

-(void)drTreeTableView:(DRTreeTableView*)treeView didCloseChildTreeNode:(DRTreeNode*)extendNote{
    
}
#pragma mark --

#pragma mark -- ChapterSearchBar_iPhone搜索代理
-(void)chapterSeachBar_iPhone:(ChapterSearchBar_iPhone*)searchBar beginningSearchString:(NSString*)searchText{
    if (self.searchBar.searchTextField.text.length == 0) {
        [Utility errorAlert:@"请输入搜索内容!"];
    }else {
        [self.searchBar.searchTextField resignFirstResponder];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self downloadSearchContentWithLastQuestionId:nil];
    }
}

-(void)chapterSeachBar_iPhone:(ChapterSearchBar_iPhone *)searchBar clearSearchString:(NSString *)searchText{
    //留空
    self.isSearching = NO;
    [self.searchBar.searchTextField resignFirstResponder];
//    self.tableView.contentOffset = (CGPoint){self.tableView.contentOffset.x,0};
    [self.tableView reloadData];
}
#pragma mark --
#pragma mark MJRefreshBaseViewDelegate 分页加载
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    __weak QuestionV2ViewController *weakSelf = self;
    if (self.isSearching) {//分页加载搜索内容
        NSString *lastQuestionId = nil;
        if (self.headerRefreshView == refreshView) {
            self.footerRefreshView.isForbidden = YES;
            
        }else{
            self.headerRefreshView.isForbidden = YES;
            id model = [self.questionSearchDataArray  lastObject];
            if ([model isKindOfClass:[QuestionModel class]]) {
                lastQuestionId = [(QuestionModel*)model questionId];
            }else{
                lastQuestionId = [(QuestionModel*)[(AnswerModel*)model questionModel] questionId];
            }
        }
        [self downloadSearchContentWithLastQuestionId:lastQuestionId];
    }else{
        NSString *lastQuestionId = nil;
        if (self.headerRefreshView == refreshView) {
            self.footerRefreshView.isForbidden = YES;
            
        }else{
            self.headerRefreshView.isForbidden = YES;
            id model = [self.questionDataArray  lastObject];
            if ([model isKindOfClass:[QuestionModel class]]) {
                lastQuestionId = [(QuestionModel*)model questionId];
            }else{
                lastQuestionId = [(QuestionModel*)[(AnswerModel*)model questionModel] questionId];
            }
        }
        
        if ([CaiJinTongManager shared].selectedQuestionCategoryType == CategoryType_AllQuestion) {
            [self downloadAllQuestionContentWithLastQuestionId:lastQuestionId];
        }else{
            [self downloadMyQuestionContentWithLastQuestionId:lastQuestionId];
        }
    }
    
}

#pragma mark --

#pragma mark property

-(NSMutableArray *)questionDataArray{
    if (self.isSearching) {
        return self.questionSearchDataArray;
    }
    return _questionDataArray;
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

-(DRTypeQuestionContentViewController *)typeContentController{
    if (!_typeContentController) {
        _typeContentController = [[DRTypeQuestionContentViewController alloc] initWithNibName:@"DRTypeQuestionContentViewController" bundle:nil];
    }
    return _typeContentController;
}

-(ChapterSearchBar_iPhone *)searchBar{
    if(!_searchBar){
        _searchBar = [[ChapterSearchBar_iPhone alloc] initWithFrame:CGRectMake(19, IP5(63, 63), 282, 34)];
        _searchBar.delegate = self;
        //        [_searchBar setHidden:YES];
        //        [_searchBar setAlpha:0.0];
        [_searchBar.searchTextField setPlaceholder:@"搜索问题"];
        //        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}
#pragma mark --
@end
