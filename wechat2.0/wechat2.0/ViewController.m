//
//  ViewController.m
//  wechat2.0
//
//  Created by 甄翰宏 on 2016/10/18.
//  Copyright © 2016年 甄翰宏. All rights reserved.
//

#import "ViewController.h"
#import "TLFriendsViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 100, 100, 40);
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"发送消息" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sender) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    // Do any additional setup after loading the view, typically from a nib.
}
-(void)sender{
    TLFriendsViewController *vc = [[TLFriendsViewController alloc]init];
//    TLUser *user = [[TLUser alloc] init];
//    user.username = @"真子丹";
//    user.userID = @"01";
//    user.nikename = @"真子丹";
//    user.avatarURL = @"10.jpeg";
//    vc.user = user;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
