//
//  SectionViewController.m
//  CaiJinTongApp
//
//  Created by comdosoft on 13-11-5.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "SectionViewController.h"

#import <QuartzCore/QuartzCore.h>
@interface SectionViewController ()

@end

@implementation SectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.drnavigationBar.titleLabel.text = @"课程名称";
    [self.drnavigationBar.navigationRightItem setTitle:@"关闭" forState:UIControlStateNormal];
    self.drnavigationBar.navigationRightItem.titleLabel.textColor = [UIColor darkGrayColor];
}
-(void)drnavigationBarRightItemClicked:(id)sender{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideLeftRight];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLog(@"%f",self.view.frame.size.width);
    if (self.section) {
        //封面
        SectionCustomView *sv = [[SectionCustomView alloc]initWithFrame:CGRectMake(10, 54, 250, 250) andSection:self.section andItemLabel:0];
        self.sectionView = sv;
        
        [self.view addSubview:self.sectionView];
        //显示分数
        CustomLabel *scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(480, 64, 60, 60)];
        scoreLabel.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:58.0/255.0 blue:94.0/255.0 alpha:1.0f];
        scoreLabel.text = self.section.sectionScore;
        scoreLabel.layer.cornerRadius = 7;
        [scoreLabel setColor:[UIColor whiteColor] fromIndex:0 length:scoreLabel.text.length];
        [scoreLabel setFont:[UIFont boldSystemFontOfSize:50] fromIndex:0 length:1];
        [scoreLabel setFont:[UIFont boldSystemFontOfSize:30] fromIndex:1 length:2];
        self.scoreLab = scoreLabel;
        [self.view addSubview:self.scoreLab];
        scoreLabel = nil;
        //
        CGFloat labelTop = 64;
        CGFloat labelSpace = 6;
        //标题
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, labelTop, 150, 30)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor grayColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        nameLabel.text =[NSString stringWithFormat:@"名称:%@",self.section.sectionName];
        self.nameLab = nameLabel;
        [self.view addSubview:self.nameLab];
        nameLabel = nil;
        labelTop +=self.nameLab.frame.size.height+labelSpace;
        //简介
        if (self.section.lessonInfo.length >0) {
            UIFont *aFont = [UIFont boldSystemFontOfSize:16];
            CGSize size = [self.section.lessonInfo sizeWithFont:aFont constrainedToSize:CGSizeMake(170, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat hh = 0;
            if (size.height-100>0){
                hh = 100;
                self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(275, labelTop, 170, hh)];
                self.scrollView.delegate = self;
                UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, size.height)];
                infoLabel.backgroundColor = [UIColor clearColor];
                infoLabel.textColor = [UIColor grayColor];
                infoLabel.numberOfLines = 0;
                infoLabel.font = aFont;
                infoLabel.text =[NSString stringWithFormat:@"简介:%@",self.section.lessonInfo];
                self.infoLab = infoLabel;
                [self.scrollView addSubview:self.infoLab];
                self.scrollView.contentSize = CGSizeMake(170,self.infoLab.frame.size.height);
                [self.view addSubview:self.scrollView];
                infoLabel = nil;
                labelTop +=self.scrollView.frame.size.height+labelSpace;
            }else {
                if (size.height-100<0 && size.height-30>0) {
                    hh = size.height;
                }else if (size.height-30<0) {
                    hh = 30;
                }
                UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, labelTop, 170, hh)];
                infoLabel.backgroundColor = [UIColor clearColor];
                infoLabel.textColor = [UIColor grayColor];
                infoLabel.numberOfLines = 0;
                infoLabel.font = aFont;
                infoLabel.text =[NSString stringWithFormat:@"简介:%@",self.section.lessonInfo];
                self.infoLab = infoLabel;
                [self.view addSubview:self.infoLab];
                infoLabel = nil;
                labelTop +=self.infoLab.frame.size.height+labelSpace;
            }
        }
        //讲师
        if (self.section.sectionTeacher.length >0) {
            UILabel *teacherLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, labelTop, 150, 30)];
            teacherLabel.backgroundColor = [UIColor clearColor];
            teacherLabel.textColor = [UIColor grayColor];
            teacherLabel.font = [UIFont boldSystemFontOfSize:16];
            teacherLabel.text =[NSString stringWithFormat:@"讲师:%@",self.section.sectionTeacher];
            self.teacherlab = teacherLabel;
            [self.view addSubview:self.teacherlab];
            teacherLabel = nil;
            labelTop +=self.teacherlab.frame.size.height+labelSpace;
        }
        //时长
        UILabel *lastLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, labelTop, 150, 30)];
        lastLabel.backgroundColor = [UIColor clearColor];
        lastLabel.textColor = [UIColor grayColor];
        lastLabel.font = [UIFont boldSystemFontOfSize:16];
        lastLabel.text =[NSString stringWithFormat:@"时长:%@",self.section.sectionLastTime];
        self.lastLab = lastLabel;
        [self.view addSubview:self.lastLab];
        lastLabel = nil;
        labelTop +=self.lastLab.frame.size.height+labelSpace;
        //已学习
        DLog(@"labtop = %f",labelTop);
        UILabel *studyLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, labelTop, 150, 30)];
        studyLabel.backgroundColor = [UIColor clearColor];
        studyLabel.textColor = [UIColor grayColor];
        studyLabel.font = [UIFont boldSystemFontOfSize:16];
        studyLabel.text =[NSString stringWithFormat:@"已学习:%@",self.section.sectionStudy];
        self.studyLab = studyLabel;
        [self.view addSubview:self.studyLab];
        studyLabel = nil;
        //播放按钮
        DLog(@"labtop = %f",labelTop);
        UIButton *palyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        palyButton.frame = CGRectMake(400, labelTop-20, 150, 50);
        [palyButton setTitle:NSLocalizedString(@"继续学习", @"button") forState:UIControlStateNormal];
        [palyButton setBackgroundColor:[UIColor clearColor]];
		[palyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [palyButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [palyButton setBackgroundImage:[UIImage imageNamed:@"btn0.png"] forState:UIControlStateNormal];
        self.playBtn = palyButton;
        [self.view addSubview:self.playBtn];
        palyButton = nil;
        [self displayView];
        
    }
}
-(void)playVideo:(id)sender {
    DLog(@"play");
    //先匹配本地,在数据库中查找纪录
}
-(void)displayView {
    self.slideSwitchView.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:232.0/255.0 alpha:1.0];
    //3个选项卡
    self.slideSwitchView.tabItemNormalColor = [SUNSlideSwitchView colorFromHexRGB:@"868686"];
//    self.slideSwitchView.tabItemSelectedColor = [SUNSlideSwitchView colorFromHexRGB:@"bb0b15"];
    self.slideSwitchView.tabItemSelectedColor = [UIColor darkGrayColor];
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"play-courselist_0df3.png"]
                                        stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    
    self.section_ChapterView = [story instantiateViewControllerWithIdentifier:@"Section_ChapterViewController"];
    self.section_ChapterView.title = @"章节目录";
    self.section_ChapterView.dataArray = [NSMutableArray arrayWithArray:self.section.sectionList];
    
    
    self.section_GradeView = [story instantiateViewControllerWithIdentifier:@"Section_GradeViewController"];
    self.section_GradeView.title = @"打分";
    self.section_GradeView.dataArray = [NSMutableArray arrayWithArray:self.section.commentList];
    
    
    self.section_NoteView = [story instantiateViewControllerWithIdentifier:@"Section_NoteViewController"];
    self.section_NoteView.title = @"笔记";
    self.section_NoteView.dataArray = [NSMutableArray arrayWithArray:self.section.noteList];
    
    [self.slideSwitchView buildUI];
}

#pragma mark - 滑动tab视图代理方法

- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 3;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    if (number == 0) {
        return self.section_ChapterView;
    } else if (number == 1) {
        return self.section_GradeView;
    } else if (number == 2) {
        return self.section_NoteView;
    } else {
        return nil;
    }
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer *)panParam
{
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    Section_ChapterViewController *section_ChapterView = nil;
    Section_GradeViewController *section_GradeView = nil;
    Section_NoteViewController *section_NoteView = nil;
    if (number == 0) {
        section_ChapterView = self.section_ChapterView;
        [section_ChapterView viewDidCurrentView];
    } else if (number == 1) {
        section_GradeView = self.section_GradeView;
        [section_GradeView viewDidCurrentView];
    } else if (number == 2) {
        section_NoteView = self.section_NoteView;
        [section_NoteView viewDidCurrentView];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
