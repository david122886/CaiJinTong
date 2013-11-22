//
//  DRNavigationController.m
//  CaiJinTongApp
//
//  Created by david on 13-11-17.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "DRNavigationController.h"
#import "DRMoviePlayViewController.h"
@interface DRNavigationController ()

@end

@implementation DRNavigationController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)shouldAutorotate {
    UIInterfaceOrientation interface = [[UIApplication sharedApplication] statusBarOrientation];
    UIViewController *subViewController = [[self childViewControllers] lastObject];
    if (subViewController && [subViewController isKindOfClass:[DRMoviePlayViewController class]]) {
        return [subViewController shouldAutorotate];
    }
    if (UIInterfaceOrientationIsLandscape(interface)) {
        return YES;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    UIViewController *subViewController = [[self childViewControllers] lastObject];
    if (subViewController && [subViewController isKindOfClass:[DRMoviePlayViewController class]]) {
        return [subViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}
// pre-iOS 6 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    UIViewController *subViewController = [[self childViewControllers] lastObject];
    if (subViewController && [subViewController isKindOfClass:[DRMoviePlayViewController class]]) {
        return [subViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
