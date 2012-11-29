//
//  NdComPlatform+ApplicationPromotion.h
//  NdComPlatform_SNS
//
//  Created by xujianye on 12-5-24.
//  Copyright 2012 NetDragon WebSoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NdComPlatform.h"
#import "NdComPlatformAPIResponse+ApplicationPromotion.h"


@interface NdComPlatform(ApplicationPromotion)


/*!
 获取推广的软件信息列表
 @param maxDisplay 最多获取几个，如果 <= 0，则获取全部列表
 @param delegate 回调对象
 @result 请求成功返回正数，失败返回错误码
 */
- (int)NdGetAppPromotionList:(int)maxDisplay  delegate:(id)delegate;

/*!
 用户点击了推广列表中的某个软件
 @param appId 点击的那个软件
 @param delegate 回调对象
 @result 请求成功返回正数，失败返回错误码
 */
- (int)NdStartAppPromotion:(NSString*)appId  delegate:(id)delegate;

/*!
 获取在推广列表中得到的奖励信息
 @param delegate 回调对象
 @result 请求成功返回正数，失败返回错误码
 */
- (int)NdQueryAppPromotionAwardList:(id)delegate;

/*!
 在被推广的软件中激活了奖励
 @param delegate 回调对象
 @result 请求成功返回正数，失败返回错误码
 */
- (int)NdReachAppPromotionAwardCondition:(id)delegate;

@end


#pragma mark -
#pragma mark Application Promotion  delegate

@protocol NdComPlatformUIProtocol_ApplicationPromotion

/*!
 NdGetAppPromotionList的回调
 @param error		错误码
 @param totalCount	推广软件总数
 @param promotingApps	推广的软件列表（存放NdAppPromotion*）
 */
- (void)NdGetAppPromotionListDidFinish:(NSError*)error  totalCount:(int)totalCount promotingApps:(NSArray*)promotingApps;


/*!
 NdStartAppPromotion的回调
 @param error		错误码
 */
- (void)NdStartAppPromotionDidFinish:(NSError*)error;


/*!
 NdQueryAppPromotionAwardList的回调
 @param error		错误码
 @param awards		奖励信息（存放NdAppPromotionAward*）
 */
- (void)NdQueryAppPromotionAwardListDidFinish:(NSError *)error  awards:(NSArray*)awards;


/*!
 NdReachAppPromotionAwardCondition的回调
 @param error		错误码
 */
- (void)NdReachAppPromotionAwardConditionDidFinish:(NSError*)error;

@end