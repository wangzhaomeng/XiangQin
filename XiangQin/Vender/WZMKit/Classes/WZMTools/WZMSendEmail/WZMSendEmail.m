//
//  WZMSendEmail.m
//  WZMKit
//
//  Created by WangZhaomeng on 2018/2/8.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import "WZMSendEmail.h"
#import "WZMLogPrinter.h"
#import "NSString+wzmcate.h"
#import "WZMDefined.h"

@implementation WZMSendEmail

- (void)send {
    if ([MFMailComposeViewController canSendMail]) {
        NSMutableString *mailUrl = [[NSMutableString alloc] init];
        [mailUrl appendFormat:@"mailto:%@?", self.recipients];
        [mailUrl appendFormat:@"&subject=%@",self.subject];
        [mailUrl appendFormat:@"&body=%@",self.body];
        
        NSURL *URL = [NSURL URLWithString:mailUrl];
        if (URL == nil) {
            URL = [NSURL URLWithString:[mailUrl wzm_getURLEncoded]];
        }
#if WZM_APP
        [[UIApplication sharedApplication]openURL:URL];
#endif
    }
}

@end

@implementation UIViewController (WZMSendEmail)

- (void)sendEmail:(WZMSendEmail *)email {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        [mailCompose setMailComposeDelegate:self];
        [mailCompose setSubject:email.subject];
        [mailCompose setToRecipients:[email.recipients componentsSeparatedByString:@","]];
        //非HTML格式
        [mailCompose setMessageBody:email.body isHTML:NO];
        //HTML格式
        //[mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
        [self presentViewController:mailCompose animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled: {
            WZMLog(@"用户取消编辑");
        }
            break;
        case MFMailComposeResultSaved: {
            WZMLog(@"用户保存邮件");
        }
            break;
        case MFMailComposeResultSent: {
            WZMLog(@"用户点击发送");
        }
            break;
        case MFMailComposeResultFailed: {
            WZMLog(@"用户尝试保存或发送邮件失败: %@", [error localizedDescription]);
        }break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
