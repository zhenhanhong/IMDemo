//
//  TLChatBaseViewController+ChatBar.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/17.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatBaseViewController+ChatBar.h"
#import "TLChatBaseViewController+Proxy.h"
#import "TLChatBaseViewController+MessageDisplayView.h"
#import "TLAudioRecorder.h"
#import "TLAudioPlayer.h"
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
@interface TLChatBaseViewController()
@property (strong, nonatomic) MQTTClient *client;
@property(strong, nonatomic) NSDictionary *resultDic;
@property(strong, nonatomic)SingleChartModel *mdoel;
@end
@implementation TLChatBaseViewController (ChatBar)

#pragma mark - # Public Methods
- (void)loadKeyboard
{
    [self.emojiKeyboard setKeyboardDelegate:self];
    [self.emojiKeyboard setDelegate:self];
    [self.moreKeyboard setKeyboardDelegate:self];
    [self.moreKeyboard setDelegate:self];
}

- (void)dismissKeyboard
{
    if (curStatus == TLChatBarStatusMore) {
        [self.moreKeyboard dismissWithAnimation:YES];
        curStatus = TLChatBarStatusInit;
    }
    else if (curStatus == TLChatBarStatusEmoji) {
        [self.emojiKeyboard dismissWithAnimation:YES];
        curStatus = TLChatBarStatusInit;
    }
    [self.chatBar resignFirstResponder];
}

//MARK: 系统键盘回调
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (curStatus != TLChatBarStatusKeyboard) {
        return;
    }
    [self.messageDisplayView scrollToBottomWithAnimation:YES];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self startSingleChat];
    if (curStatus != TLChatBarStatusKeyboard) {
        return;
    }
    if (lastStatus == TLChatBarStatusMore) {
        [self.moreKeyboard dismissWithAnimation:NO];
    }
    else if (lastStatus == TLChatBarStatusEmoji) {
        [self.emojiKeyboard dismissWithAnimation:NO];
    }
    [self.messageDisplayView scrollToBottomWithAnimation:YES];
}

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    if (curStatus != TLChatBarStatusKeyboard && lastStatus != TLChatBarStatusKeyboard) {
        return;
    }
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (lastStatus == TLChatBarStatusMore || lastStatus == TLChatBarStatusEmoji) {
        if (keyboardFrame.size.height <= HEIGHT_CHAT_KEYBOARD) {
            return;
        }
    }
    else if (curStatus == TLChatBarStatusEmoji || curStatus == TLChatBarStatusMore) {
        return;
    }
    [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).mas_offset(-keyboardFrame.size.height);
    }];
    [self.view layoutIfNeeded];
    [self.messageDisplayView scrollToBottomWithAnimation:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (curStatus != TLChatBarStatusKeyboard && lastStatus != TLChatBarStatusKeyboard) {
        return;
    }
    if (curStatus == TLChatBarStatusEmoji || curStatus == TLChatBarStatusMore) {
        return;
    }
    [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view);
    }];
    [self.view layoutIfNeeded];
}
//-(void)viewWillAppear:(BOOL)animated{
////    [self startSingleChat];
//}
#pragma mark - Delegate
//MARK: TLChatBarDelegate
// 发送文本消息
- (void)chatBar:(TLChatBar *)chatBar sendText:(NSString *)text
{

    
    NSDictionary *sendData = @{@"to_guid":@targetGuid,@"from_guid":@userGuid,@"senderUsername":userName,@"contentType":@"01",@"content":text};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dicToString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.client publishString:dicToString toTopic:@"/user/chat/123-topic" withQos:AtMostOnce retain:NO completionHandler:^(int mid) {
        
        NSLog(@"mid ==== %d",mid);
        TLTextMessage *message = [[TLTextMessage alloc] init];
        message.text = text;
        [self sendMessage:message];
        
        
    }];
    

    
//    if ([self.partner chat_userType] == TLChatUserTypeUser) {
//        
//        TLTextMessage *message1 = [[TLTextMessage alloc] init];
//        message1.fromUser = self.partner;
//        message1.text = text;
//        [self receivedMessage:message1];
//        
//    }

}
#pragma mark 创建通道
//startSingleChat
-(void)startSingleChat{
    NSString *temp = [NSString stringWithFormat:@"http://%s/startSingleChat?source_username=%s&source_user_password=%s&target_username=%s&product_guid=4f454d8d-7dc9-4fd5-9a87-d15399f1ece4",DEV_MC_HOST,userGuid,passWord,targetGuid];
    [DataHandel GetDataWithURLstr:temp complete:^(id result) {
        if (result) {
            NSLog(@"%@",result);
            NSDictionary *dic = result;
            NSString *code = [dic objectForKey:@"code"];
            if (code.intValue == 200) {
                self.resultDic = [dic objectForKey:@"result"];
                self.mdoel = [SingleChartModel yy_modelWithDictionary:self.resultDic];
                [self connetChart];
            }
            
        }
    }];
}
-(void)sendImageMessage:(UIImage *)image{
    NSData *imageData = (UIImagePNGRepresentation(image) ? UIImagePNGRepresentation(image) :UIImageJPEGRepresentation(image, 0.5));
    NSString *imageName = [NSString stringWithFormat:@"%lf.jpg", [NSDate date].timeIntervalSince1970];
    NSString *imagePath = [NSFileManager pathUserChatImage:imageName];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    NSDictionary *sendData = @{@"to_guid":@targetGuid,@"from_guid":@userGuid,@"senderUsername":userName,@"contentType":@"02",@"imagePath":[NSString stringWithFormat:@"%@",imageName],@"sizewidth":[NSString stringWithFormat:@"%f",image.size.width],@"sizeheight":[NSString stringWithFormat:@"%f",image.size.height]};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dicToString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.client publishString:dicToString toTopic:@"/user/chat/123-topic" withQos:AtMostOnce retain:NO completionHandler:^(int mid) {
        
        NSLog(@"mid ==== %d",mid);
        TLImageMessage *message = [[TLImageMessage alloc] init];
        message.fromUser = self.user;
        message.ownerTyper = TLMessageOwnerTypeSelf;
        message.imagePath = imageName;
        message.imageSize = image.size;
        [self sendMessage:message];
        
    }];

}
-(void)connetChart{
    NSString *clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    if (!self.client) {
        self.client = [[MQTTClient alloc]initWithClientId:clientID];
    }
    
    NSString *mcAccessToken = @"123456";
    [self.client connectToHost:@DEV_MC_HOST andName:@userGuid andPassword:mcAccessToken completionHandler:^(MQTTConnectionReturnCode code) {
        if (code == ConnectionAccepted) {
            //订阅
            [self.client subscribe:@"/user/chat/123-topic" withCompletionHandler:^(NSArray *grantedQos) {
                NSLog(@"%@",grantedQos);
                
            }];
        }
    }];
    
    [self.client setMessageHandler:^(MQTTMessage* message)
     {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             //             //接收到消息，更新界面时需要切换回主线程
             NSDictionary *dic = message.payloadDic;
             NSLog(@"infor:"@"%@", dic);
             NSString *content = [dic objectForKey:@"content"];
             NSString *contentType = [dic objectForKey:@"contentType"];
//             NSString *senderUsername = [dic objectForKey:@"senderUsername"];
             if (contentType.intValue == 01) {
                 TLTextMessage *message = [[TLTextMessage alloc] init];
                 message.fromUser = self.partner;
                 message.text = content;
                 message.partnerType = TLPartnerTypeUser;
                 [self receivedMessage:message];
             }else if (contentType.intValue == 02){
                 TLImageMessage *message1 = [[TLImageMessage alloc] init];
                NSString *imagePath = [dic objectForKey:@"imagePath"];
                NSString *sizewidth = [dic objectForKey:@"sizewidth"];
                NSString *sizeheight = [dic objectForKey:@"sizeheight"];
                 message1.fromUser = self.partner;
                 message1.ownerTyper = TLMessageOwnerTypeFriend;
                 message1.imagePath = imagePath;
                 message1.imageSize = CGSizeMake(sizewidth.floatValue, sizeheight.floatValue);
                 [self receivedMessage:message1];
             }else if (contentType.intValue == 05){
                 NSString *url = [dic objectForKey:@"url"];
                 NSString *voicelength = [dic objectForKey:@"voicelength"];
                 TLVoiceMessage *message1 = [[TLVoiceMessage alloc] init];
                 message1.fromUser = self.partner;
                 message1.recFileName = url;
                 message1.time = voicelength.floatValue;
                 [self receivedMessage:message1];
                
             }

             
             
         });
     }];
    
    
    
    
}
#pragma mark 发送聊天信息
/*
 * to_guid
 * from_guid
 * version
 * senderUsername
 * contentType 文本消息: 01
 * content
 */
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


//MARK: - 录音相关
- (void)chatBarStartRecording:(TLChatBar *)chatBar
{
    // 先停止播放
    if ([TLAudioPlayer sharedAudioPlayer].isPlaying) {
        [[TLAudioPlayer sharedAudioPlayer] stopPlayingAudio];
    }
    
    [self.recorderIndicatorView setStatus:TLRecorderStatusRecording];
    [self.messageDisplayView addSubview:self.recorderIndicatorView];
    [self.recorderIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(150, 150));
    }];
    
    __block NSInteger time_count = 0;
    TLVoiceMessage *message = [[TLVoiceMessage alloc] init];
    message.ownerTyper = TLMessageOwnerTypeSelf;
    message.userID = [TLUserHelper sharedHelper].userID;
    message.fromUser = (id<TLChatUserProtocol>)[TLUserHelper sharedHelper].user;
    message.msgStatus = TLVoiceMessageStatusRecording;
    message.date = [NSDate date];
    [[TLAudioRecorder sharedRecorder] startRecordingWithVolumeChangedBlock:^(CGFloat volume) {
        time_count ++;
        if (time_count == 2) {
            [self addToShowMessage:message];
        }
        [self.recorderIndicatorView setVolume:volume];
    } completeBlock:^(NSString *filePath, CGFloat time) {
        if (time < 1.0) {
            [self.recorderIndicatorView setStatus:TLRecorderStatusTooShort];
            return;
        }
        [self.recorderIndicatorView removeFromSuperview];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString *fileName = [NSString stringWithFormat:@"%.0lf.caf", [NSDate date].timeIntervalSince1970 * 1000];
            NSString *path = [NSFileManager pathUserChatVoice:fileName];
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:path error:&error];
            if (error) {
//                DDLogError(@"录音文件出错: %@", error);
                return;
            }
            NSDictionary *sendData = @{@"to_guid":@targetGuid,@"from_guid":@userGuid,@"senderUsername":userName,@"contentType":@"05",@"url":fileName,@"voicelength":[NSString stringWithFormat:@"%f",time]};
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:nil];
            NSString *dicToString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [self.client publishString:dicToString toTopic:@"/user/chat/123-topic" withQos:AtMostOnce retain:NO completionHandler:^(int mid) {
                
                NSLog(@"mid ==== %d",mid);
       

                
                
            }];
            TLVoiceMessage *message = [[TLVoiceMessage alloc] init];
            message.recFileName = fileName;
            message.time = time;
            message.msgStatus = TLVoiceMessageStatusNormal;
            [message resetMessageFrame];
            [self sendMessage:message];
            


        }
    } cancelBlock:^{
        [self.messageDisplayView deleteMessage:message];
        [self.recorderIndicatorView removeFromSuperview];
    }];
}

- (void)chatBarWillCancelRecording:(TLChatBar *)chatBar cancel:(BOOL)cancel
{
    [self.recorderIndicatorView setStatus:cancel ? TLRecorderStatusWillCancel : TLRecorderStatusRecording];
}

- (void)chatBarFinishedRecoding:(TLChatBar *)chatBar
{
    [[TLAudioRecorder sharedRecorder] stopRecording];
}

- (void)chatBarDidCancelRecording:(TLChatBar *)chatBar
{
    [[TLAudioRecorder sharedRecorder] cancelRecording];
}

//MARK: - chatBar状态切换
- (void)chatBar:(TLChatBar *)chatBar changeStatusFrom:(TLChatBarStatus)fromStatus to:(TLChatBarStatus)toStatus
{
    if (curStatus == toStatus) {
        return;
    }
    lastStatus = fromStatus;
    curStatus = toStatus;
    if (toStatus == TLChatBarStatusInit) {
        if (fromStatus == TLChatBarStatusMore) {
            [self.moreKeyboard dismissWithAnimation:YES];
        }
        else if (fromStatus == TLChatBarStatusEmoji) {
            [self.emojiKeyboard dismissWithAnimation:YES];
        }
    }
    else if (toStatus == TLChatBarStatusVoice) {
        if (fromStatus == TLChatBarStatusMore) {
            [self.moreKeyboard dismissWithAnimation:YES];
        }
        else if (fromStatus == TLChatBarStatusEmoji) {
            [self.emojiKeyboard dismissWithAnimation:YES];
        }
    }
    else if (toStatus == TLChatBarStatusEmoji) {
        [self.emojiKeyboard showInView:self.view withAnimation:YES];
    }
    else if (toStatus == TLChatBarStatusMore) {
        [self.moreKeyboard showInView:self.view withAnimation:YES];
    }
}

- (void)chatBar:(TLChatBar *)chatBar didChangeTextViewHeight:(CGFloat)height
{
    [self.messageDisplayView scrollToBottomWithAnimation:NO];
}

//MARK: TLKeyboardDelegate
- (void)chatKeyboardWillShow:(id)keyboard animated:(BOOL)animated
{
    [self.messageDisplayView scrollToBottomWithAnimation:YES];
}

- (void)chatKeyboardDidShow:(id)keyboard animated:(BOOL)animated
{
    if (curStatus == TLChatBarStatusMore && lastStatus == TLChatBarStatusEmoji) {
        [self.emojiKeyboard dismissWithAnimation:NO];
    }
    else if (curStatus == TLChatBarStatusEmoji && lastStatus == TLChatBarStatusMore) {
        [self.moreKeyboard dismissWithAnimation:NO];
    }
    [self.messageDisplayView scrollToBottomWithAnimation:YES];
}

- (void)chatKeyboard:(id)keyboard didChangeHeight:(CGFloat)height
{
    [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).mas_offset(-height);
    }];
    [self.view layoutIfNeeded];
    [self.messageDisplayView scrollToBottomWithAnimation:YES];
}

//MARK: TLEmojiKeyboardDelegate
- (void)emojiKeyboard:(TLEmojiKeyboard *)emojiKB didSelectedEmojiItem:(TLEmoji *)emoji
{
    if (emoji.type == TLEmojiTypeEmoji || emoji.type == TLEmojiTypeFace) {
        [self.chatBar addEmojiString:emoji.emojiName];
    }
    else {
        TLExpressionMessage *message = [[TLExpressionMessage alloc] init];
        message.emoji = emoji;
        [self sendMessage:message];
        if ([self.partner chat_userType] == TLChatUserTypeUser) {
            TLExpressionMessage *message1 = [[TLExpressionMessage alloc] init];
            message1.fromUser = self.partner;
            message1.emoji = emoji;;
            [self receivedMessage:message1];
        }
        else {
            for (id<TLChatUserProtocol> user in [self.partner groupMembers]) {
                TLExpressionMessage *message1 = [[TLExpressionMessage alloc] init];
                message1.friendID = [user chat_userID];
                message1.fromUser = user;
                message1.emoji = emoji;
                [self receivedMessage:message1];
            }
        }
    }
}

- (void)emojiKeyboardSendButtonDown
{
    [self.chatBar sendCurrentText];
}

- (void)emojiKeyboardDeleteButtonDown
{
    [self.chatBar deleteLastCharacter];
}

- (void)emojiKeyboard:(TLEmojiKeyboard *)emojiKB didTouchEmojiItem:(TLEmoji *)emoji atRect:(CGRect)rect
{
    if (emoji.type == TLEmojiTypeEmoji || emoji.type == TLEmojiTypeFace) {
        if (self.emojiDisplayView.superview == nil) {
            [self.emojiKeyboard addSubview:self.emojiDisplayView];
        }
        [self.emojiDisplayView displayEmoji:emoji atRect:rect];
    }
    else {
        if (self.imageExpressionDisplayView.superview == nil) {
            [self.emojiKeyboard addSubview:self.imageExpressionDisplayView];
        }
        [self.imageExpressionDisplayView displayEmoji:emoji atRect:rect];
    }
}

- (void)emojiKeyboardCancelTouchEmojiItem:(TLEmojiKeyboard *)emojiKB
{
    if (self.emojiDisplayView.superview != nil) {
        [self.emojiDisplayView removeFromSuperview];
    }
    else if (self.imageExpressionDisplayView.superview != nil) {
        [self.imageExpressionDisplayView removeFromSuperview];
    }
}

- (void)emojiKeyboard:(TLEmojiKeyboard *)emojiKB selectedEmojiGroupType:(TLEmojiType)type
{
    if (type == TLEmojiTypeEmoji || type == TLEmojiTypeFace) {
        [self.chatBar setActivity:YES];
    }
    else {
        [self.chatBar setActivity:NO];
    }
}

- (BOOL)chatInputViewHasText
{
    return self.chatBar.curText.length == 0 ? NO : YES;
}

#pragma mark - # Getter
- (TLEmojiKeyboard *)emojiKeyboard
{
    return [TLEmojiKeyboard keyboard];
}

- (TLMoreKeyboard *)moreKeyboard
{
    return [TLMoreKeyboard keyboard];
}


@end
