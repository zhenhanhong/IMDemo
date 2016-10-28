//
//  TLChatBaseViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/15.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatBaseViewController.h"
#import "TLChatBaseViewController+Proxy.h"
#import "TLChatBaseViewController+ChatBar.h"
#import "TLChatBaseViewController+MessageDisplayView.h"
#import "UIImage+Size.h"
#import "DataHandel.h"
#import "YYModel.h"
#import "MQTTKit.h"
#import "SingleChartModel.h"
#define MC_PATH  "http://mc.mtcent.com"
#define DEV_EC_PATH  "http://mc.dev.mtcent.com"
#define MC_HOST  "mc.mtcent.com"
#define DEV_MC_HOST  "mc.dev.mtcent.com"
#define userGuid "64e5fb3c-e2b1-4372-9dd6-86eed183a85e"
#define targetGuid "4b63134b-0a2a-44cb-b417-14eb25fa27f3"
//#define userGuid "4b63134b-0a2a-44cb-b417-14eb25fa27f3"
//#define targetGuid "64e5fb3c-e2b1-4372-9dd6-86eed183a85e"
#define passWord "123456"
#define channel "topic"
#define userName @"真子丹"
#define NewUrlRequestforDev @"https://open.dev.mtcentcloud.com/"
@interface TLChatBaseViewController ()

@property (strong, nonatomic) MQTTClient *client;
@property(strong, nonatomic) NSDictionary *resultDic;
@property(strong, nonatomic)SingleChartModel *mdoel;

@end
@implementation TLChatBaseViewController

- (void)loadView
{
    [super loadView];
    
    [self.view addSubview:self.messageDisplayView];
    [self.view addSubview:self.chatBar];
    
    [self p_addMasonry];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadKeyboard];
    //获取token
    [self getToken];
    
}
-(void)getToken{
    [DataHandel GetDataWithURLstr:[NSString stringWithFormat:@"%@getFileCloudToken",NewUrlRequestforDev] complete:^(id result) {
        //   NSLog(@"%@",str);
        NSDictionary *dic = result;
        NSLog(@"%@",dic);
        NSDictionary *dicResult = [dic objectForKey:@"results"];
        self.cloudtoken = [dicResult objectForKey:@"token"];
        NSLog(@"%@",self.cloudtoken);
        
        
        
    }];
    
}
//#pragma mark 创建通道
////startSingleChat
//-(void)startSingleChat{
//    NSString *temp = [NSString stringWithFormat:@"http://%s/startSingleChat?source_username=%s&source_user_password=%s&target_username=%s&product_guid=4f454d8d-7dc9-4fd5-9a87-d15399f1ece4",DEV_MC_HOST,userGuid,passWord,targetGuid];
//    [DataHandel GetDataWithURLstr:temp complete:^(id result) {
//        if (result) {
//            NSLog(@"%@",result);
//            NSDictionary *dic = result;
//            NSString *code = [dic objectForKey:@"code"];
//            if (code.intValue == 200) {
//                _resultDic = [dic objectForKey:@"result"];
//                _mdoel = [SingleChartModel yy_modelWithDictionary:_resultDic];
//                [self connetChart];
//            }
//            
//        }
//    }];
//}
//-(void)connetChart{
//    NSString *clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
//    if (!self.client) {
//        self.client = [[MQTTClient alloc]initWithClientId:clientID];
//    }
//    
//    NSString *mcAccessToken = @"123456";
//    [self.client connectToHost:@DEV_MC_HOST andName:@userGuid andPassword:mcAccessToken completionHandler:^(MQTTConnectionReturnCode code) {
//        if (code == ConnectionAccepted) {
//            //订阅
//            [self.client subscribe:@"/user/chat/123-topic" withCompletionHandler:^(NSArray *grantedQos) {
//                NSLog(@"%@",grantedQos);
//                
//            }];
//        }
//    }];
//
//    [self.client setMessageHandler:^(MQTTMessage* message)
//     {
//         
//         dispatch_async(dispatch_get_main_queue(), ^{
//             //             //接收到消息，更新界面时需要切换回主线程
//             NSDictionary *dic = message.payloadDic;
//             NSLog(@"infor:"@"%@", dic);

// 
//
//             
//         });
//     }];
//    
//    
//    
//    
//}
//#pragma mark 发送聊天信息
///*
// * to_guid
// * from_guid
// * version
// * senderUsername
// * contentType 文本消息: 01
// * content
// */
//- (void)sendContentWithcontentSendMessage:(TLMessage *)message {
//    if (message.messageType == TLMessageTypeText) {
//        NSDictionary *sendData = @{@"to_guid":@targetGuid,@"from_guid":@userGuid,@"senderUsername":userName,@"contentType":@"01",@"content":@"sss"};
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *dicToString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        [self.client publishString:dicToString toTopic:@"/user/chat/123-topic" withQos:AtMostOnce retain:NO completionHandler:^(int mid) {
//            
//            NSLog(@"mid ==== %d",mid);
//            
//        }];
//    }else if (message.messageType == TLMessageTypeImage){
//        NSDictionary *sendData = @{@"to_guid":@targetGuid,@"from_guid":@userGuid,@"senderUsername":userName,@"contentType":@"02",@"content":@"fa"};
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *dicToString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        [self.client publishString:dicToString toTopic:@"/user/chat/123-topic" withQos:AtMostOnce retain:NO completionHandler:^(int mid) {
//            
//            NSLog(@"mid ==== %d",mid);
//            
//        }];
//    }
//    
//}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    [self startSingleChat];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[TLAudioPlayer sharedAudioPlayer] stopPlayingAudio];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#ifdef DEBUG_MEMERY
    NSLog(@"dealloc ChatBaseVC");
#endif
}

#pragma mark - # Public Methods
- (void)setPartner:(id<TLChatUserProtocol>)partner
{
    if (_partner && [[_partner chat_userID] isEqualToString:[partner chat_userID]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messageDisplayView scrollToBottomWithAnimation:NO];
        });
        return;
    }
    _partner = partner;
    [self.navigationItem setTitle:[_partner chat_username]];
    [self resetChatVC];
}

- (void)setChatMoreKeyboardData:(NSMutableArray *)moreKeyboardData
{
    [self.moreKeyboard setChatMoreKeyboardData:moreKeyboardData];
}

- (void)setChatEmojiKeyboardData:(NSMutableArray *)emojiKeyboardData
{
    [self.emojiKeyboard setEmojiGroupData:emojiKeyboardData];
}

- (void)resetChatVC
{
    NSString *chatViewBGImage;
    if (self.partner) {
        chatViewBGImage = [[NSUserDefaults standardUserDefaults] objectForKey:[@"CHAT_BG_" stringByAppendingString:[self.partner chat_userID]]];
    }
    if (chatViewBGImage == nil) {
        chatViewBGImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"CHAT_BG_ALL"];
        if (chatViewBGImage == nil) {
            [self.view setBackgroundColor:[UIColor colorGrayCharcoalBG]];
        }
        else {
            NSString *imagePath = [NSFileManager pathUserChatBackgroundImage:chatViewBGImage];
            UIImage *image = [UIImage imageNamed:imagePath];
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
        }
    }
    else {
        NSString *imagePath = [NSFileManager pathUserChatBackgroundImage:chatViewBGImage];
        UIImage *image = [UIImage imageNamed:imagePath];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:image]];
    }
    
    [self resetChatTVC];
}

#pragma mark - # Private Methods
- (void)p_addMasonry
{
    [self.messageDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.chatBar.mas_top);
    }];
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(self.view);
        make.height.mas_greaterThanOrEqualTo(HEIGHT_TABBAR);
    }];
    [self.view layoutIfNeeded];
}

#pragma mark - # Getter
- (TLChatMessageDisplayView *)messageDisplayView
{
    if (_messageDisplayView == nil) {
        _messageDisplayView = [[TLChatMessageDisplayView alloc] init];
        [_messageDisplayView setDelegate:self];
    }
    return _messageDisplayView;
}

- (TLChatBar *)chatBar
{
    if (_chatBar == nil) {
        _chatBar = [[TLChatBar alloc] init];
        [_chatBar setDelegate:self];
    }
    return _chatBar;
}

- (TLEmojiDisplayView *)emojiDisplayView
{
    if (_emojiDisplayView == nil) {
        _emojiDisplayView = [[TLEmojiDisplayView alloc] init];
    }
    return _emojiDisplayView;
}

- (TLImageExpressionDisplayView *)imageExpressionDisplayView
{
    if (_imageExpressionDisplayView == nil) {
        _imageExpressionDisplayView = [[TLImageExpressionDisplayView alloc] init];
    }
    return _imageExpressionDisplayView;
}

- (TLRecorderIndicatorView *)recorderIndicatorView
{
    if (_recorderIndicatorView == nil) {
        _recorderIndicatorView = [[TLRecorderIndicatorView alloc] init];
    }
    return _recorderIndicatorView;
}

@end
