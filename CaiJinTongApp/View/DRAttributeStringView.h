//
//  DRAttributeStringView.h
//  NSMutableAttributedTest
//
//  Created by david on 13-12-31.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLParser.h"
#import "AnswerModel.h"
#import "QuestionModel.h"
typedef enum {DRURLFileType_IMAGR,DRURLFileType_WORD,DRURLFileType_PDF,DRURLFileType_OTHER}DRURLFileType;
@protocol DRAttributeStringViewDelegate;
@interface DRAttributeStringView : UIView
@property (strong,nonatomic) AnswerModel *answerModel;
@property (strong,nonatomic) QuestionModel *questionModel;
@property (assign,nonatomic) CGRect attributeStringRect;
@property (weak,nonatomic) id<DRAttributeStringViewDelegate> delegate;
+(CGRect)boundsRectWithAnswer:(AnswerModel*)answer withWidth:(float)width;
+(CGRect)boundsRectWithQuestion:(QuestionModel*)question withWidth:(float)width;
@end

@protocol DRAttributeStringViewDelegate <NSObject>

-(void)drAttributeStringView:(DRAttributeStringView*)attriView clickedFileURL:(NSURL*)url withFileType:(DRURLFileType)fileType;

@end