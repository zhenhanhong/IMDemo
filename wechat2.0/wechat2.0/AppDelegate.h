//
//  AppDelegate.h
//  wechat2.0
//
//  Created by 甄翰宏 on 2016/10/18.
//  Copyright © 2016年 甄翰宏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

