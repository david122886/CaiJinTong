//
//  DRPopupController.h
//  CaiJinTongApp
//
//  Created by david on 13-10-31.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRPopupController : UIViewController
+(void)popuControllerView:(UIViewController*)controller parentController:(UIViewController*)parent didDismiss:(void (^)(BOOL dismiss))dismissBlock;
@end
