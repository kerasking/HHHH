//
//  NdComPlatformAPIResponse+ApplicationPromotion.h
//  NdComPlatformInt
//
//  Created by xujianye on 12-5-22.
//  Copyright 2012 NetDragon WebSoft Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NdComPlatformAPIResponse.h"

/**
 @brief 推广软件列表中具体某个应用的推广信息
 */
@interface NdAppPromotion : NSObject
{
	NdBaseAppInfo*	promotedApp;
	NSString*	strAward;
	NSString*	strDesc;
	NSString*	strExt;
	int			nAwardsCount;
}

@property (nonatomic, retain) NdBaseAppInfo*	promotedApp;	/**< 被推广的应用信息 */

@property (nonatomic, retain) NSString*	strAward;			/**< 激活这个应用时可得到的奖品名称 */
@property (nonatomic, retain) NSString*	strDesc;			/**< 奖品描述 */
@property (nonatomic, assign) int		nAwardsCount;		/**< 奖品数量 */

@property (nonatomic, retain) NSString*	strExt;				/**< 扩展信息 */

@end




/**
 @brief 推广软件列表中具体某个应用被激活时，可以得到的奖励信息
 */
@interface NdAppPromotionAward : NSObject
{
	NdBaseAppInfo*	promotedApp;
	NSString*		strAward;
	int				nAwardsCount;
	NSString*		strNotice;
}

@property (nonatomic, retain) NdBaseAppInfo*	promotedApp;	/**< 被激活的应用信息 */
@property (nonatomic, retain) NSString*			strAward;		/**< 可得到的奖品名称 */
@property (nonatomic, assign) int				nAwardsCount;	/**< 可得到的奖品数量 */
@property (nonatomic, retain) NSString*			strNotice;		/**< 奖励通知文本提示 */

@end