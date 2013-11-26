//
//  AppDelegate.m
//  CaiJinTongApp
//
//  Created by david on 13-10-30.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "CaiJinTongManager.h"
#import "iRate.h"
#import "Section.h"
#import "SectionSaveModel.h"
@implementation AppDelegate
+(AppDelegate *)sharedInstance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
- (void)showRootView {
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
    [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
    [[MZFormSheetBackgroundWindow appearance] setBackgroundColor:[UIColor clearColor]];
    
    //设置是否加载图片
    BOOL isloadLargeImage = [[NSUserDefaults standardUserDefaults] boolForKey:ISLOADLARGEIMAGE_KEY];
    [[CaiJinTongManager shared] setIsLoadLargeImage:isloadLargeImage];
    
    //设置appstore上评分
     [iRate sharedInstance].appStoreID = 355313284;
    
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"] ;
    [self.hostReach startNotifier];  //开始监听，会启动一个run loop
    
    self.mDownloadService = [[DownloadService alloc]init];
    
    return YES;
}
//连接改变
-(void)reachabilityChanged:(NSNotification *)note
{
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    //如果没有连接到网络就弹出提醒实况
    self.isReachable = YES;
    if(status == NotReachable)
    {
        self.isReachable = NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
        [[CaiJinTongManager shared] run];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[CaiJinTongManager shared] stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
//程序退出
- (void)applicationWillTerminate:(UIApplication *)application
{
    //停止下载任务
    Section *sectionDb = [[Section alloc]init];
    NSArray *local_array = [sectionDb getDowningInfo];
    if (local_array.count>0) {
        for (int i=0; i<local_array.count; i++) {
            SectionSaveModel *nm = (SectionSaveModel *)[local_array objectAtIndex:i];
            [self.mDownloadService stopTask:nm];
        }
    }
}


-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSUInteger orientations = UIInterfaceOrientationMaskAll;
    
    if ([MZFormSheetController formSheetControllersStack] > 0) {
        MZFormSheetController *viewController = [[MZFormSheetController formSheetControllersStack] lastObject];
        return [viewController.presentedFSViewController supportedInterfaceOrientations];
    }
    
    return orientations;
}

#pragma mark property
-(NSMutableArray *)popupedControllerArr{
    if (!_popupedControllerArr) {
        _popupedControllerArr = [NSMutableArray array];
    }
    return _popupedControllerArr;
}
#pragma mark --
@end
