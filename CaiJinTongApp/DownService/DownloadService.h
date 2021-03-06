//
//  DownloadService.h
//  CaiJinTong
//
//  Created by comdosoft on 13-9-16.
//  Copyright (c) 2013年 CaiJinTong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASINetworkQueue;
#import "SectionSaveModel.h"

@interface DownloadService : NSObject

@property (nonatomic,retain) ASINetworkQueue *networkQueue;

-(void)addDownloadTask:(SectionSaveModel *) nm;//添加下载任务
-(void)removeTask:(SectionSaveModel *)nm;//根据VideoSaveModel删除下载任务
-(void)stopTask:(SectionSaveModel *)nm;//停止下载
@end
