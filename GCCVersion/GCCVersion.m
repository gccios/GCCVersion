//
//  GCCVersion.m
//  GCCToolCreate
//
//  Created by 郭春城 on 16/4/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "GCCVersion.h"

#define IngoreVersion @"GCCIngoreVersion"

#import <StoreKit/StoreKit.h>

@interface GCCVersion ()<SKStoreProductViewControllerDelegate>

{
    NSString * appStoreVersion;
}

@property (nonatomic, strong) NSDictionary * dataSource;
@property (nonatomic, strong) UIAlertController * alert;

@end

@implementation GCCVersion

+ (GCCVersion *)sharedInstance
{
    static GCCVersion *sharedInstance = nil;
    if (sharedInstance == nil)
    {
        sharedInstance = [[GCCVersion alloc] init];
    }
    return sharedInstance;
}

- (void)startCheckVersionUseAlert:(UpdateAlert)alert withAPPName:(NSString *)name
{
    if (nil == self.appStoreID) {
        return;
    }
    NSString * path = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", self.appStoreID];
    NSURL * url = [NSURL URLWithString:path];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil == error) {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            self.dataSource = [[dict objectForKey:@"results"] firstObject];
            
            NSString * current = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSString * last = [self.dataSource objectForKey:@"version"];
            appStoreVersion = last;
            
            NSString * ingore = [[NSUserDefaults standardUserDefaults] objectForKey:IngoreVersion];
            if (ingore) {
                if ([last isEqualToString:ingore]) {
                    return;
                }
            }
            
            double currentVersion = [current doubleValue];
            double lastVersion = [last doubleValue];
            
            if (currentVersion < lastVersion) {
                [self initAlert:name];
                switch (alert) {
                    case UpdateAlertDefault:
                        [self showUpdateAlertDefault];
                        break;
                        
                    case UpdateAlertForce:
                        [self showUpdateAlertForce];
                        break;
                        
                    case UpdateAlertIngore:
                        [self showUpdateAlertIngore];
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }];
    [task resume];
}

- (void)initAlert:(NSString *)name
{
    NSString * lastVersion = [self.dataSource objectForKey:@"version"];
    NSString * title = [NSString stringWithFormat:@"%@ 发现新版本: %@", name, lastVersion];
    
    NSString * introduce = [self.dataSource objectForKey:@"releaseNotes"];
    NSString * detail = [NSString stringWithFormat:@"此版本更新内容:\n%@", introduce];
    
    self.alert = [UIAlertController alertControllerWithTitle:title message:detail preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString * attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedTitle addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, title.length)];
    
    [self.alert setValue:attributedTitle forKey:@"attributedTitle"];
}

- (void)showUpdateAlertDefault
{
    UIViewController * viewController = [self getCurrentViewController];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"狠心忽略" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.alert popoverPresentationController];
    }];
    [self.alert addAction:action1];
    
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"下载更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self openAPPStore];
    }];
    [self.alert addAction:action2];
    
    if (viewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:self.alert animated:YES completion:nil];
        });
    }
}

- (void)showUpdateAlertForce
{
    UIViewController * viewController = [self getCurrentViewController];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"下载更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self openAPPStore];
    }];
    [self.alert addAction:action];
    
    if (viewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:self.alert animated:YES completion:nil];
        });
    }
}

- (void)showUpdateAlertIngore
{
    UIViewController * viewController = [self getCurrentViewController];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"忽略此版本" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.alert popoverPresentationController];
        [[NSUserDefaults standardUserDefaults] setValue:appStoreVersion forKey:IngoreVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    [self.alert addAction:action1];
    
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"下载更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self openAPPStore];
    }];
    [self.alert addAction:action2];
    
    if (viewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:self.alert animated:YES completion:nil];
        });
    }
}

//通过最上层的window以及对应其底层响应者获取当前视图控制器
- (UIViewController *)getCurrentViewController
{
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            
            UIViewController * viewController = nil;
            UIView *frontView = [[window subviews] objectAtIndex:0];
            id nextResponder = [frontView nextResponder];
            
            if ([nextResponder isKindOfClass:[UIViewController class]]){
                viewController = nextResponder;
            }
            else{
                viewController = window.rootViewController;
            }
            return viewController;
            
            break;
        }
    }
    return nil;
}

//应用内打开APPStore
- (void)openAPPStore
{
    SKStoreProductViewController * store = [[SKStoreProductViewController alloc] init];
    store.delegate = self;
    [store loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:self.appStoreID} completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (!error) {
            UIViewController * viewController = [self getCurrentViewController];
            [viewController presentViewController:store animated:YES completion:nil];
        }
    }];
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
