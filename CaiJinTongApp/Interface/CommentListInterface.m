//
//  CommentListInterface.m
//  CaiJinTongApp
//
//  Created by comdosoft on 13-11-1.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "CommentListInterface.h"
#import "NSDictionary+AllKeytoLowerCase.h"
#import "NSString+URLEncoding.h"
#import "NSString+HTML.h"

#import "CommentModel.h"

@implementation CommentListInterface

-(void)getGradeInterfaceDelegateWithUserId:(NSString *)userId andSectionId:(NSString *)sectionId andPageIndex:(NSInteger)pageIndex {
    NSMutableDictionary *reqheaders = [[NSMutableDictionary alloc] init];

    [reqheaders setValue:[NSString stringWithFormat:@"%@",userId] forKey:@"userId"];
    [reqheaders setValue:[NSString stringWithFormat:@"%@",sectionId] forKey:@"sectionId"];
    [reqheaders setValue:[NSString stringWithFormat:@"%d",pageIndex] forKey:@"pageIndex"];
    
//    self.interfaceUrl = @"http://lms.finance365.com/api/ios.ashx?active=commentList&userId=17082&sectionId=2690&pageIndex=1";
    self.interfaceUrl= [NSString stringWithFormat:@"%@?active=commentList&userId=%@&sectionId=%@&pageIndex=%d",kHost,userId,sectionId,pageIndex];
    self.baseDelegate = self;
    self.headers = reqheaders;
    
    [self connect];
}
#pragma mark - BaseInterfaceDelegate

-(void)parseResult:(ASIHTTPRequest *)request{
    NSDictionary *resultHeaders = [[request responseHeaders] allKeytoLowerCase];
    if (resultHeaders) {
        NSData *data = [[NSData alloc]initWithData:[request responseData]];
        id jsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (jsonObject !=nil) {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonData=(NSDictionary *)jsonObject;
                DLog(@"data = %@",jsonData);
                if (jsonData) {
                    if ([[jsonData objectForKey:@"Status"]intValue] == 1) {
                        @try {
                            NSDictionary *dictionary =[jsonData objectForKey:@"ReturnObject"];
                            if (dictionary) {
                                SectionModel *section = [[SectionModel alloc]init];
                                section.sectionId = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"sectionId"]];
                                
                                //评论列表
                                if (![[dictionary objectForKey:@"commentList"]isKindOfClass:[NSNull class]] && [dictionary objectForKey:@"commentList"]!=nil) {
                                    NSArray *array_comment = [dictionary objectForKey:@"commentList"];
                                    if (array_comment.count>0) {
                                        section.commentList = [[NSMutableArray alloc]init];
                                        for (int i=0; i<array_comment.count; i++) {
                                            NSDictionary *dic_comment = [array_comment objectAtIndex:i];
                                            CommentModel *comment = [[CommentModel alloc]init];
                                            comment.nickName = [NSString stringWithFormat:@"%@",[dic_comment objectForKey:@"nickName"]];
                                            comment.time = [NSString stringWithFormat:@"%@",[dic_comment objectForKey:@"time"]];
                                            comment.content = [NSString stringWithFormat:@"%@",[dic_comment objectForKey:@"content"]];
                                            comment.pageIndex = [[dic_comment objectForKey:@"pageIndex"]intValue];
                                            comment.pageCount = [[dic_comment objectForKey:@"pageCount"]intValue];
                                            [section.commentList addObject:comment];
                                        }
                                    }
                                }
                                if (section) {
                                    [self.delegate getCommentListInfoDidFinished:section];
                                }
                            }else {
                                [self.delegate getCommentListInfoDidFailed:@"加载失败!"];
                            }
                        }
                        @catch (NSException *exception) {
                            [self.delegate getCommentListInfoDidFailed:@"加载失败!"];
                        }
                    }else
                        {
                            [self.delegate getCommentListInfoDidFailed:[jsonData objectForKey:@"Msg"]];
                        }
                }else {
                    [self.delegate getCommentListInfoDidFailed:@"加载失败!"];
                }
            }else {
                [self.delegate getCommentListInfoDidFailed:@"加载失败!"];
            }
        }else {
            [self.delegate getCommentListInfoDidFailed:@"加载失败!"];
        }
    }else {
        [self.delegate getCommentListInfoDidFailed:@"加载失败!"];
    }
}

-(void)requestIsFailed:(NSError *)error{
    [Utility requestFailure:error tipMessageBlock:^(NSString *tipMsg) {
        [self.delegate getCommentListInfoDidFailed:tipMsg];
    }];
}
@end
