//
//  LHLNavigationBar.m
//  CaiJinTongApp
//
//  Created by apple on 13-11-25.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "LHLNavigationBar.h"

@implementation LHLNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(52, 23, 216, 35)];
        self.title.textColor = [UIColor whiteColor];
        self.title.text = @"测试标题";
        [self.title setTextAlignment:NSTextAlignmentCenter];
        self.title.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        self.title.backgroundColor = [UIColor clearColor];
        [self addSubview:self.title];
        
        self.rightItem = [[UIButton alloc]initWithFrame:CGRectMake(278, 29, 24, 24)];
        [self.rightItem setBackgroundImage:[UIImage imageNamed:@"course-mycourse_03"] forState:UIControlStateNormal];
        self.rightItem.backgroundColor = [UIColor greenColor];
        self.rightItem.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.rightItem];
        
        self.leftItem = [[UIButton alloc]initWithFrame:CGRectMake(18, 29, 24, 24)];
        [self.leftItem setBackgroundImage:[UIImage imageNamed:@"course-mycourse_03"] forState:UIControlStateNormal];
        self.leftItem.backgroundColor = [UIColor greenColor];
        self.leftItem.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.leftItem];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self setBackgroundColor:[UIColor colorWithRed:14.0/255.0 green:50.0/255.0 blue:84.0/255.0 alpha:1.0]];
    }
    return self;
}



@end
