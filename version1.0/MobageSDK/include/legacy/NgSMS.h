//
//  NgSMS.h
//  webgame
//
//  Created by pan.zaofeng on 12-5-14.
//  Copyright 2011 DeNA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface NgSMS : NSObject<MFMessageComposeViewControllerDelegate> {

}

+ (void) Send : (NSString *)message to : (NSString *) addr;
+ (void) Send : (NSString *)uri;

@end
