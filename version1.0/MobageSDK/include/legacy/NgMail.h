//
//  NgMail.h
//  Sample
//
//  Created by pan.zaofeng on 12-5-14.
//  Copyright 2011 DeNA. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface NgMail : NSObject<MFMailComposeViewControllerDelegate> {
}

+ (void) send_to:(NSString *)addr;

@end
