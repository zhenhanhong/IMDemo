//
//  TLRootViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/1/23.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLRootViewController.h"

#import "TLConversationViewController.h"
#import "TLFriendsViewController.h"
//#import "TLDiscoverViewController.h"
//#import "TLMineViewController.h"

static TLRootViewController *rootVC = nil;

@interface TLRootViewController ()

@property (nonatomic, strong) NSArray *childVCArray;

@property (nonatomic, strong) TLConversationViewController *conversationVC;
@property (nonatomic, strong) TLFriendsViewController *friendsVC;

@end

@implementation TLRootViewController

+ (TLRootViewController *) sharedRootViewController
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        rootVC = [[TLRootViewController alloc] init];
    });
    return rootVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setViewControllers:self.childVCArray];       // 初始化子控制器
}

- (id)childViewControllerAtIndex:(NSUInteger)index
{
    return [[self.childViewControllers objectAtIndex:index] rootViewController];
}

#pragma mark - Getters
- (NSArray *) childVCArray
{
    if (_childVCArray == nil) {
        TLNavigationController *friendsVC = [[TLNavigationController alloc] initWithRootViewController:self.friendsVC];
        _childVCArray = @[friendsVC];
    }
    return _childVCArray;
}

- (TLConversationViewController *) conversationVC
{
    if (_conversationVC == nil) {
        _conversationVC = [[TLConversationViewController alloc] init];
        [_conversationVC.tabBarItem setTitle:@"消息"];
        [_conversationVC.tabBarItem setImage:[UIImage imageNamed:@"tabbar_mainframe"]];
        [_conversationVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tabbar_mainframeHL"]];
    }
    return _conversationVC;
}
- (TLFriendsViewController *) friendsVC
{
    if (_friendsVC == nil) {
        _friendsVC = [[TLFriendsViewController alloc] init];
        [_friendsVC.tabBarItem setTitle:@"好友"];
        [_friendsVC.tabBarItem setImage:[UIImage imageNamed:@"tabbar_mainframe"]];
        [_friendsVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tabbar_mainframeHL"]];
    }
    return _friendsVC;
}

@end
