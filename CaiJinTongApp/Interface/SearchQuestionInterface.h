//
//  SearchQuestionInterface.h
//  CaiJinTongApp
//
//  Created by comdosoft on 13-11-1.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "BaseInterface.h"

@protocol SearchQuestionInterfaceDelegate;

@interface SearchQuestionInterface : BaseInterface<BaseInterfaceDelegate>

@property (nonatomic, assign) id<SearchQuestionInterfaceDelegate>delegate;

-(void)getSearchQuestionInterfaceDelegateWithUserId:(NSString *)userId andText:(NSString *)text;
@end

@protocol SearchQuestionInterfaceDelegate <NSObject>

-(void)getSearchQuestionInfoDidFinished:(NSDictionary *)result;
-(void)getSearchQuestionInfoDidFailed:(NSString *)errorMsg;

@end