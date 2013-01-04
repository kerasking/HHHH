//
//  GameActivityFeeds.h
//  MyNativeTest
//
//  Created by panzaofeng on 9/27/12.
//
//

#import <Foundation/Foundation.h>

#import "MBGError.h"

@interface ActivityFeed : NSObject
{
    NSString *title;
    NSString *content;
    NSString *imageUrl;
    NSString *linkText;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *linkText;

@end

@interface GameActivityFeeds : NSObject
{
    
}

+ (GameActivityFeeds*) shareInstance;

-(void)openActivityFeeds:(ActivityFeed *)feed;
-(void)openActivityFeedsWithoutUI:(ActivityFeed *)feed onSuccess:(void (^)())successCB onError:(void (^)(MBGError *))errorCB;

@end
