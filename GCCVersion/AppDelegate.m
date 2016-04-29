//
//  AppDelegate.m
//  GCCVersion
//
//  Created by 郭春城 on 16/4/29.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "GCCVersion.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    RootViewController * root = [RootViewController new];
    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];
    
    //填写Itunes Connect应用的APP ID, 一般为9位或者10位的数字
    [[GCCVersion sharedInstance] setAppStoreID:@"1058711881"];
    
    //开启检测更新功能，第一个参数：提示框类型，第二个参数APP的名字(可随意填写)
    [[GCCVersion sharedInstance] startCheckVersionUseAlert:UpdateAlertDefault withAPPName:@"牛逼的APP"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
