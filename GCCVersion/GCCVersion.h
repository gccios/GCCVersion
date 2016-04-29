//
//  GCCVersion.h
//  GCCToolCreate
//
//  Created by 郭春城 on 16/4/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UpdateAlertDefault, //可选取消和更新
    UpdateAlertForce, //强制用户更新
    UpdateAlertIngore, //可选更新和忽略此版本
} UpdateAlert;

@interface GCCVersion : NSObject

+ (GCCVersion *)sharedInstance;

/**
 *  开始检测更新
 *
 *  @param alert UpdateAlert表示警告框模式
 *  @param name  APP的名字，可不同于线上名字，自定义名字，会在提示框显示
 */
- (void)startCheckVersionUseAlert:(UpdateAlert)alert withAPPName:(NSString *)name;

@property (nonatomic, strong) NSString * appStoreID;

@end
