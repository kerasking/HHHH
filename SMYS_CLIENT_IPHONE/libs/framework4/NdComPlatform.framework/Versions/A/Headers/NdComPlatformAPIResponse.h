//
//  NdComPlatformAPIResponse.h
//  NdComPlatform_SNS
//
//  Created by Sie Kensou on 10-10-8.
//  Copyright 2010 NetDragon WebSoft Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _ND_PHOTO_SIZE  {
	ND_PHOTO_SIZE_TINY = 0,		/**< 16 * 16像素		*/
	ND_PHOTO_SIZE_SMALL,		/**< 48 * 48像素		*/
	ND_PHOTO_SIZE_MIDDLE,		/**< 120*120像素		*/
	ND_PHOTO_SIZE_BIG,			/**< 200*200像素		*/
}   ND_PHOTO_SIZE_TYPE;

/**
 @brief 分页信息
 */
@interface NdPagination : NSObject
{
	int pageIndex;
	int pageSize;
}

@property (nonatomic, assign) int pageIndex;		/**< 要获取的第几页记录，从1开始*/
@property (nonatomic, assign) int pageSize;			/**< 每页记录的个数（5的倍数）*/

@end




/**
 @brief 按页获取信息列表
 */
@interface NdBasePageList : NSObject
{
	NdPagination	*pagination;
	int				totalCount;
	NSArray*		records;
}

@property (nonatomic, retain) NdPagination *pagination;		/**< 分页结构体 */
@property (nonatomic, assign) int			totalCount;		/**< 总个数 */
@property (nonatomic, retain) NSArray*		records;		/**< 根据具体接口存放对应的数据 */

@end




/**
 @brief 91豆支付信息
 @note 购买价格保留2位小数
 */
@interface NdBuyInfo : NSObject
{
	NSString *cooOrderSerial;
	NSString *productId;
	NSString *productName;
	float productPrice;			
	float productOrignalPrice;	
	unsigned int productCount;			
	NSString *payDescription;			
}

@property (nonatomic, retain) NSString *cooOrderSerial;				/**< 合作商的订单号，必须保证唯一，双方对账的唯一标记（用GUID生成，32位）*/
@property (nonatomic, retain) NSString *productId;					/**< 商品Id */
@property (nonatomic, retain) NSString *productName;				/**< 商品名字 */
@property (nonatomic, assign) float productPrice;					/**< 商品价格，两位小数 */
@property (nonatomic, assign) float productOrignalPrice;			/**< 商品原始价格，保留两位小数 */
@property (nonatomic, assign) unsigned int productCount;			/**< 购买商品个数 */
@property (nonatomic, retain) NSString *payDescription;				/**< 购买描述，可选，没有为空 */

- (BOOL)isValidBuyInfo;						/**<  判断支付信息是否有效 */
- (BOOL)isCostGreaterThanThreshold;			/**<  返回（价格>100万 || 数量> 1万） */

@end




/**
 @brief 购买记录
 */
@interface NdPayRecord : NSObject
{
	NSString	*cooOrderSerial;
	NSString	*buyTime;
	NSString	*productName;
	unsigned int	productCount;
	float		pay91Bean;
	//NSString	*status;
	NSString	*appName;
}

@property (nonatomic, retain) NSString *cooOrderSerial;		/**< 购买订单号 */
@property (nonatomic, retain) NSString *buyTime;			/**< 购买时间（yyyy-MM-dd HH:mm:ss) */
@property (nonatomic, retain) NSString *productName;		/**< 商品名称 */
@property (nonatomic, assign) unsigned int productCount;	/**< 购买商品个数 */
@property (nonatomic, assign) float		pay91Bean;			/**< 购买所消费91豆,保留2位小数 */
//@property (nonatomic, retain) NSString *status;			/**< 发货状态 */
@property (nonatomic, retain) NSString *appName;			/**< 应用软件名称 */

@end




/**
 @brief 代付请求结果信息
 */
@interface NdPayByOthersRequestResult : NSObject
{
	NSString *cooOrderSerial;
	NSString *requestUin;
	NSString *orderserial;
	BOOL	success;
}

@property(nonatomic,retain)	NSString *cooOrderSerial;		/**< 合作商的订单号 */
@property(nonatomic,retain) NSString *requestUin;			/**< 代付人的uin */
@property(nonatomic,retain) NSString *orderserial;			/**< 通用平台代付订单号 */
@property(nonatomic,assign) BOOL	 success;				/**< 请求是否发送成功 */

@end




/**
 @brief 代付订单信息
 */
@interface NdPayByOthersOrderStatus : NSObject
{
	NSString *requestUin;
	NSString *requestNickName;
	NSString *appId;
	NSString *appName;
	NSString *goodsId;
	NSString *goodsName;
	NSString *goodsPrice;
	NSString *goodsOriginalPrice;
	int		 goodsCount;
	NSString *createTime;
	NSString *orderStatus;
}

@property(nonatomic,retain) NSString *requestUin;			/**< 发起请求人的uin */
@property(nonatomic,retain) NSString *requestNickName;		/**< 发起请求人的昵称 */
@property(nonatomic,retain) NSString *appId;				/**< 应用id */
@property(nonatomic,retain) NSString *appName;				/**< 应用名称 */
@property(nonatomic,retain) NSString *goodsId;				/**< 商品id */
@property(nonatomic,retain) NSString *goodsName;			/**< 商品名称 */
@property(nonatomic,retain) NSString *goodsPrice;			/**< 商品价格（单位元，保留小数点两位） */
@property(nonatomic,retain) NSString *goodsOriginalPrice;	/**< 商品原价（单位元，保留小数点两位） */
@property(nonatomic,assign) int		 goodsCount;			/**< 购买商品个数 */
@property(nonatomic,retain) NSString *createTime;			/**< 订单生成时间 */
@property(nonatomic,retain) NSString *orderStatus;			/**< 订单状态 */

@end




/**
 @brief 购买记录列表
 @note  records 购买记录，存放的是NdPayRecord类型对象
 */
@interface NdPayRecordList : NdBasePageList {
}
@end




/**
 @brief 短信充值类
 */
@interface NdSMSRecharging : NSObject
{
	BOOL			enableRecharging;
	unsigned int	smsRatio;
	NSArray			*demonArray;
}

@property (nonatomic, assign) BOOL			enableRecharging;		/**< 是否运讯短信充值 */
@property (nonatomic, assign) unsigned int	smsRatio;				/**< 充值比率，百分比 */
@property (nonatomic, retain) NSArray		*demonArray;			/**< 可用的短信充值的面额列表 */
@end




/**
 @brief 充值卡充值类型信息
 */
@interface NdPayCardInfo : NSObject
{
	int				cardId;
	NSString		*cardName;
	NSArray			*demonArray;
	unsigned int	cardRatio;
}

@property (nonatomic, assign) int		cardId;				/**< 卡类型Id */
@property (nonatomic, retain) NSString	*cardName;			/**< 卡类型名称 */
@property (nonatomic, retain) NSArray	*demonArray;		/**< 卡支持的面值列表 */
@property (nonatomic, assign) unsigned int cardRatio;		/**< 充值比率，百分比 */

@end




/**
 @brief 充值卡充值
 */
@interface NdPayCardRecharging : NSObject
{
	BOOL			enableRecharging;
	NSArray			*payCardInfoArray;
}

@property (nonatomic, assign) BOOL		enableRecharging;		/**< 是否允许充值卡充值 */
@property (nonatomic, retain) NSArray	*payCardInfoArray;		/**< 充值卡信息数组，存放的是NdPayCardInfo类型*/

@end




/**
 @brief 支付宝充值信息
 */
@interface NdAliPayRecharging : NSObject 
{
	BOOL			enableRecharging;
	unsigned int	aliPayRatio;
}

@property (nonatomic, assign) BOOL			enableRecharging;	/**< 是否允许支付宝充值 */
@property (nonatomic, assign) unsigned int	aliPayRatio;		/**< 支付宝充值比率，百分比 */

@end




/**
 @brief 91网站充值信息
 */
@interface NdMPayRecharging : NSObject 
{
	BOOL			enableRecharging;
	NSString		*shop91Url;
}

@property (nonatomic, assign) BOOL		enableRecharging;		/**< 是否允许91网站充值，始终为YES */
@property (nonatomic, retain) NSString	*shop91Url;				/**< 91网站网址 */

@end




/**
 @brief 充值类型信息类
 */
@interface NdRechargingInfo : NSObject 
{
	NdAliPayRecharging	*aliPayRecharging;
	NdPayCardRecharging	*payCardRecharging;
	NdSMSRecharging		*smsRecharging;
	NdMPayRecharging	*mPayRecharging;
}

@property (nonatomic, retain) NdAliPayRecharging	*aliPayRecharging;		/**< 支付宝充值 */
@property (nonatomic, retain) NdPayCardRecharging	*payCardRecharging;		/**< 充值卡充值 */
@property (nonatomic, retain) NdSMSRecharging		*smsRecharging;			/**< 短信充值 */
@property (nonatomic, retain) NdMPayRecharging		*mPayRecharging;		/**< 91网站充值 */

@end




/**
 @brief 充值记录类
 */
@interface NdRechargingRecord : NSObject 
{
	NSString			*cooOrderSerial;
	NSString			*rechargingTime;
	NSString			*rechargingType;
	float				recharging91Bean;
}

@property (nonatomic, retain) NSString	*cooOrderSerial;			/**< 充值订单号（默认为空）*/
@property (nonatomic, retain) NSString	*rechargingTime;			/**< 充值时间（yyyy－MM－dd HH：mm：ss）*/
@property (nonatomic, retain) NSString	*rechargingType;			/**< 充值渠道 */
@property (nonatomic, assign) float		recharging91Bean;			/**< 充值91豆,保留2位小数*/

@end




/**
 @brief 充值记录列表
 @note  records 充值记录，存放的是NdRechargingRecord类型对象
 */
@interface NdRechargingRecordList : NdBasePageList {
}
@end




/**
 @brief 用户详细信息
 */
@interface NdUserInfo : NSObject<NSCoding> 
{
	NSString	*uin;
	NSString	*nickName;
	int			bornYear;
	int			bornMonth;
	int			bornDay;
	int			sex;
	NSString	*province;
	NSString	*city;
	NSString	*trueName;
	NSString	*point;
	NSString	*emotion;
	NSString	*checkSum;
}

- (void)copyDataFromUserInfo:(NdUserInfo*)info;		/**< 浅复制 */

@property (nonatomic, retain) NSString *uin;		/**< 用户uin */
@property (nonatomic, retain) NSString *nickName;	/**< 昵称（1－20个字符，不可为空）*/
@property (nonatomic, assign) int bornYear;			/**< 出生年份，未知为空 */
@property (nonatomic, assign) int bornMonth;		/**< 出生月份，未知为空 */
@property (nonatomic, assign) int bornDay;			/**< 出生日，未知为空 */
@property (nonatomic, assign) int sex;				/**< 0＝未设置，1＝男，2＝女 */
@property (nonatomic, retain) NSString *province;	/**< 省份，未知为空 */
@property (nonatomic, retain) NSString *city;		/**< 城市，未知未空 */
@property (nonatomic, retain) NSString *trueName;	/**< 真实姓名（2－4个汉字），未知为空 */
@property (nonatomic, retain) NSString *point;		/**< 积分 */
@property (nonatomic, retain) NSString *emotion;	/**< 心情 */
@property (nonatomic, retain) NSString *checkSum;	/**< 好友头像的Md5值 */

@end




/**
 @brief 好友详细信息 
 */
@interface NdFriendRemarkUserInfo : NdUserInfo 
{
	NSString*	friendRemark;
	NSString*	updateTime;	
	NSString*	strTip_aux;	
}

@property (nonatomic, retain) NSString*	friendRemark;	/**< 好友备注 */
@property (nonatomic, retain) NSString*	updateTime;		/**< 好友最后更新标志 */
@property (nonatomic, retain) NSString*	strTip_aux;		/**< 搜索辅助标志 */

- (void)updateFriendContactName;						/**< 通用平台内部使用 */
- (void)updateRemarkToPinyinInitial;					/**< 通用平台内部使用 */
- (NSString*)friendName;								/**< 优先返回备注，如果没有备注，返回昵称 */

@end




#pragma mark NdPermission
/**
 @brief 添加好友权限定义值
 */
typedef enum _ND_FRIEND_AUTHORIZE_TYPE 
{
	ND_FRIEND_AUTHORIZE_TYPE_READ = -1,					/**< 读取 */
	ND_FRIEND_AUTHORIZE_TYPE_NEED_AUTHORIZE,			/**< 需要验证才能添加 */
	ND_FRIEND_AUTHORIZE_TYPE_EVERYONE_CAN_ADD,			/**< 允许任何人添加 */
	ND_FRIEND_AUTHORIZE_TYPE_NO_ONE_CAN_ADD,			/**< 不允许任何人添加 */
} ND_FRIEND_AUTHORIZE_TYPE;

/**
 @brief 是否启用支付密码权限定义值
 */
typedef enum _ND_PAY_AUTHORIZE_TYPE
{
	ND_PAY_AUTHORIZE_TYPE_READ = -1,					/**< 读取*/
	ND_PAY_AUTHORIZE_TYPE_CLOSE,						/**< 关闭 */
	ND_PAY_AUTHORIZE_TYPE_OPEN,							/**< 启用 */
}ND_PAY_AUTHORIZE_TYPE;

/**
 @brief 是否已经设置帐号登录密码权限定义值
 */
typedef enum _ND_ACCOUNTS_AUTHORIZE_TYPE
{
	ND_ACCOUNTS_AUTHORIZE_TYPE_READ = -1,					/**< 读取*/
	ND_ACCOUNTS_AUTHORIZE_TYPE_CLOSE,						/**< 未设置 */
	ND_ACCOUNTS_AUTHORIZE_TYPE_OPEN,						/**< 已设置 */
}ND_ACCOUNTS_AUTHORIZE_TYPE;


/**
 @brief 用户的添加好友权限信息
 */
@interface NdAddFriendPermission : NSObject 
{
	ND_FRIEND_AUTHORIZE_TYPE		canAddFriend;
	NSString*						uin;
}

@property (nonatomic, assign) ND_FRIEND_AUTHORIZE_TYPE canAddFriend;			/**< uin对应的权限 */	
@property (nonatomic, retain) NSString*		uin;								/**< 用户uin, 为空时代表自己 */	

@end

/**
 @brief 是否启用支付密码权限信息
 */
@interface NdPayPasswordPermission : NSObject 
{
	ND_PAY_AUTHORIZE_TYPE			canPayPassword;
	NSString*						uin;
}

@property (nonatomic, assign) ND_PAY_AUTHORIZE_TYPE canPayPassword;				/**< uin对应的权限 */	
@property (nonatomic, retain) NSString*		uin;								/**< 用户uin, 为空时代表自己 */	

@end

/**
 @brief 是否已经设置帐号登录密码权限信息
 */
@interface NdPasswordPermission : NSObject 
{
	ND_ACCOUNTS_AUTHORIZE_TYPE		canPassword;
	NSString*						uin;
}

@property (nonatomic, assign) ND_ACCOUNTS_AUTHORIZE_TYPE canPassword;			/**< uin对应的权限 */	
@property (nonatomic, retain) NSString*		uin;								/**< 用户uin, 为空时代表自己 */	

@end


/**
 @brief 用户的权限信息
 */
@interface NdPermission : NSObject
{
	NdAddFriendPermission*	addFriendPermission;	
	NdPayPasswordPermission* payPasswordPermission;
	NdPasswordPermission* passwordPermission;
}

@property (nonatomic, retain) NdAddFriendPermission*	addFriendPermission;	/**< 添加好友权限 */
@property (nonatomic, retain) NdPayPasswordPermission*	payPasswordPermission;	/**< 是否启用支付密码权限 */ 
@property (nonatomic, retain) NdPasswordPermission*	passwordPermission;			/**< 设置帐号登录密码权限 */

@end




/**
 @brief 用户基础信息
 */
@interface NdBaseUserInfo : NSObject 
{
	NSString *uin;
	NSString *nickName;
	NSString *checkSum;
	BOOL	  bMyFriend;
}

- (void)replaceNickNameWithFriendRemark;				/**< 如果是我的好友，把昵称替换为备注（有备注的情况） */

@property (nonatomic, retain) NSString *uin;			/**< 好友的uin */
@property (nonatomic, retain) NSString *nickName;		/**< 好友的昵称 */
@property (nonatomic, retain) NSString *checkSum;		/**< 好友头像的Md5值 */
@property (nonatomic, assign) BOOL		bMyFriend;		/**< 该用户是否是我的好友 */

@end




/**
 @brief 陌生人信息
 */
@interface NdStrangerUserInfo : NSObject 
{
	NdBaseUserInfo	*baseUserInfo;
	NSString		*province;
	NSString		*city;
	int				sex;
	int				age;
	int				onlineStatus;
}

@property (nonatomic, retain) NdBaseUserInfo *baseUserInfo;	/**< 基础信息 */
@property (nonatomic, retain) NSString *province;			/**< 省份 */
@property (nonatomic, retain) NSString *city;				/**< 城市 */
@property (nonatomic, assign) int sex;						/**< 0＝未设置，1＝男，2＝女 */
@property (nonatomic, assign) int age;						/**< 年龄 */
@property (nonatomic, assign) int onlineStatus;				/**< 在线状态，0＝未知，1＝在线，2＝离线 */

@end




/**
 @brief 陌生人信息列表
 @note  records 存放的是NdStrangerUserInfo类型对象
 */
@interface NdStrangerUserInfoList : NdBasePageList {
}

+ (NSArray *)createUserListArray:(NSString *)users;			/**< 通用平台内部使用 */
- (void)replaceNickNameWithFriendRemark;					/**< 把列表中的好友昵称换成好友备注 */

@end




/**
 @brief 好友信息
 */
@interface NdFriendUserInfo : NSObject 
{
	NdBaseUserInfo	*baseUserInfo;
	NSString		*point;
	NSString		*emotion;
	int				onlineStatus;
}

@property (nonatomic, retain) NdBaseUserInfo *baseUserInfo;		/**< 基础信息 */
@property (nonatomic, retain) NSString		 *point;			/**< 积分 */
@property (nonatomic, retain) NSString		 *emotion;			/**< 心情 */
@property (nonatomic, assign) int			 onlineStatus;		/**< 在线状态：0＝未知，1＝在线，2＝离线 */

@end




/**
 @brief 查找到的好友信息列表
 @note  records 存放的是NdFriendUserInfo类型对象
 */
@interface NdFriendUserInfoList : NdBasePageList {
}

+ (NSArray *)createFriendInfo:(NSString *)friends;		/**< 通用平台内部使用 */
- (void)replaceNickNameWithFriendRemark;				/**< 把列表中的好友昵称换成好友备注 */

@end




/**
 @brief 应用程序基础信息
 */
@interface NdBaseAppInfo : NSObject 
{
	int			appId;
	NSString	*appName;
	NSString	*checkSum;
}

@property (nonatomic, assign) int		appId;			/**< 应用程序Id */
@property (nonatomic, retain) NSString  *appName;		/**< 应用程序名称 */
@property (nonatomic, retain) NSString  *checkSum;		/**< 应用程序Icon的Md5值 */

@end




/**
 @brief 好友应用信息
 */
@interface NdFriendAppInfo : NSObject 
{
	NdBaseAppInfo	*baseAppInfo;
	int				grade;
	NSString		*description;
	NSString		*opinion;
}

@property (nonatomic, retain) NdBaseAppInfo *baseAppInfo;		/**< 应用程序基础信息 */
@property (nonatomic, assign) int grade;						/**< 应用评级 */
@property (nonatomic, retain) NSString *description;			/**< 应用简介 */
@property (nonatomic, retain) NSString *opinion;				/**< 好友对应用评价 */

@end




/**
 @brief 好友的应用信息列表
 @note  records 存放的是NdFriendAppInfo类型对象
 */
@interface NdFriendAppInfoList : NdBasePageList {
}
@end




/**
 @brief 高级查找参数
 */
@interface NdAdvanceSearch : NSObject 
{
	int ageBegin;
	int ageEnd;
	int sex;
	NSString *province;
	NSString *city;
}

@property (nonatomic, assign) int ageBegin;			/**< 若值为－1，则不使用该搜索条件 */
@property (nonatomic, assign) int ageEnd;			/**< 若值为－1，则不使用该搜索条件 */
@property (nonatomic, assign) int sex;				/**< 若值为－1，则不使用该搜索条件 , 0=未设置，1＝男，2＝女*/
@property (nonatomic, retain) NSString *province;	/**< 若值为nil，则不使用该搜索条件 */
@property (nonatomic, retain) NSString *city;		/**< 若值为nil，则不使用该搜索条件 */

@end




/**
 @brief 标签Item
 */
@interface NdMsgTagItem: NSObject 
{
	NSString *tagText;
	int		 tagCmd;
	NSArray	 *tagParam;
}

@property (nonatomic, retain) NSString	*tagText;	/**< 标签文本内容 */
@property (nonatomic, assign) int		tagCmd;		/**< 指令 */
@property (nonatomic, retain) NSArray	*tagParam;	/**< 指令参数列表 */

@end




/**
 @brief 消息内容
 */
@interface NdMsgContent : NSObject
{
	NSString	*msgContent;
	NSArray		*parsedContent;
	NSString	*parsedMsgContent;
	NSArray		*parsedUins;
}

@property (nonatomic, retain) NSString *msgContent;					/**< 消息内容 */
@property (nonatomic, retain, readonly) NSArray *parsedContent;		/**< 解析后的内容数组 */
@property (nonatomic, retain, readonly) NSString *parsedMsgContent;	/**< 解析后，不带标签的消息内容 */
@property (nonatomic, retain, readonly) NSArray *parsedUins;		/**< 解析后的Uins数组*/

- (NSArray *)parse;	/**< 解析消息内容，返回解析后的标签列表，数组存放类型为NdMsgTagItem,失败返回nil */
- (NSArray *)parse_replayce:(BOOL)bReplayceNickByContactName; /**< 把parse解析出来的好友昵称替换为联系人名称 */

@end




/**
 @brief 用户消息
 */
@interface NdUserMsgInfo : NSObject 
{
	NSString		*msgId;
	NdBaseUserInfo	*baseUserInfo;
	NdMsgContent	*msgContent;
	NSString		*sendTime;
	int				newCount;
	BOOL			bRead;
}

@property (nonatomic, retain) NSString			*msgId;				/**< 用户消息id */
@property (nonatomic, retain) NdBaseUserInfo	*baseUserInfo;		/**< 用户基本信息 */
@property (nonatomic, retain) NdMsgContent		*msgContent;		/**< 消息内容 */
@property (nonatomic, retain) NSString			*sendTime;			/**< 发送时间 */
@property (nonatomic, assign) int				newCount;			/**< 该用户的新消息数 */
@property (nonatomic, assign) BOOL				bRead;				/**< 消息状态，0＝未读，1＝已读 */

@end




/**
 @brief 系统消息
 */
@interface NdSysMsgInfo : NSObject 
{
	NSString		*msgId;
	NdBaseAppInfo	*baseAppInfo;
	NdMsgContent	*msgContent;
	NSString		*sendTime;
	BOOL			bRead;
}

@property (nonatomic, retain) NSString		*msgId;				/**< 用户消息id */
@property (nonatomic, retain) NdBaseAppInfo	*baseAppInfo;		/**< 应用基本信息 */
@property (nonatomic, retain) NdMsgContent	*msgContent;		/**< 消息内容 */
@property (nonatomic, retain) NSString		*sendTime;			/**< 发送时间 */
@property (nonatomic, assign) BOOL			bRead;				/**< 消息状态，0＝未读，1＝已读 */

@end




#pragma mark NDCP_FANGLE_TYPE
/**
 @brief 消息类型定义
 */
typedef enum _NDCP_FANGLE_TYPE 
{
	NDCP_FANGLE_TYPE_ADD_FRIEND = 1,
	NDCP_FANGLE_TYPE_UPDATE_PHOTO = 2,
	NDCP_FANGLE_TYPE_UPDATE_EMOTION= 3,
	NDCP_FANGLE_TYPE_RECOMMEND_APP = 10001,
	NDCP_FANGLE_TYPE_RECOMMEND_SW = 10002,
	NDCP_FANGLE_TYPE_COMMENT_APP = 10003,
	NDCP_FANGLE_TYPE_COMMENT_SW = 10004 ,
	NDCP_FANGLE_TYPE_SCORING_APP = 10005 ,
	NDCP_FANGLE_TYPE_SCORING_SW = 10006 ,
	NDCP_FANGLE_TYPE_DOWNLOAD_APP = 10007 ,
	NDCP_FANGLE_TYPE_DOWNLOAD_SW = 10008 ,
	NDCP_FANGLE_TYPE_TOP_APP = 10009 ,
	NDCP_FANGLE_TYPE_GAME_ACTION = 10010 ,
} NDCP_FANGLE_TYPE;




/**
 @brief 新鲜事内容
 */
@interface NdFangleInfo : NSObject 
{
	NSString *msgId;
	NSString *friendUin;
	NSString *nickName;
	NDCP_FANGLE_TYPE msgtype;
	NdMsgContent *msgContent;
	NSString *sendTime;
}

- (void)replaceNickNameWithFriendRemark;					/**< 把好友昵称替换为备注 */

@property (nonatomic, retain)NSString		*msgId;			/**< 消息id */
@property (nonatomic, retain)NSString		*friendUin;		/**< 好友uin */
@property (nonatomic, retain)NSString		*nickName;		/**< 好友昵称 */
@property (nonatomic, assign)NDCP_FANGLE_TYPE msgtype;		/**< 消息类型 */
@property (nonatomic, retain)NdMsgContent	*msgContent;	/**< 消息内容 */
@property (nonatomic, retain)NSString		*sendTime;		/**< 发送时间 */

@end




/**
 @brief 简要消息
 */
@interface NdTinyMsgInfo : NSObject 
{
	NSString		*msgId;
	NSString		*senderUin;
	NdMsgContent	*msgContent;
	NSString		*sendTime;
	NDCP_FANGLE_TYPE	msgType;
}

@property (nonatomic, retain) NSString		*msgId;			/**< 消息Id */
@property (nonatomic, retain) NSString		*senderUin;		/**< 发送者Uin */
@property (nonatomic, retain) NdMsgContent	*msgContent;	/**< 消息内容 */
@property (nonatomic, retain) NSString		*sendTime;		/**< 发送时间 */
@property (nonatomic, assign) NDCP_FANGLE_TYPE	msgType;	/**< 消息类型 */

@end




/**
 @brief 详细系统消息
 */
@interface NdDetailSysMsgInfo : NSObject 
{
	NSString		*msgId;
	NdMsgContent	*msgTitle;
	NdMsgContent	*msgContent;
}

@property (nonatomic, retain) NSString		*msgId;			/**< 消息id */
@property (nonatomic, retain) NdMsgContent	*msgTitle;		/**< 消息标题 */
@property (nonatomic, retain) NdMsgContent	*msgContent;	/**< 消息内容 */

@end




/**
 @brief 动态消息
 */
@interface NdActivityMsgInfo : NSObject 
{
	NdUserMsgInfo	*userMsgInfo;
	int				type;
}

@property (nonatomic, retain) NdUserMsgInfo *userMsgInfo;	/**< 用户消息 */
@property (nonatomic, assign) int type;						/**< 动态类型，1＝评论应用，2＝更新头像，3＝更新心情，4＝新增好友，5＝下载应用，6＝推荐应用 */

@end




/**
 @brief 所有好友动态列表
 @note  records 存放的是NdActivityMsgInfo类型对象
 */
@interface NdAllFriendActivityMsgList : NdBasePageList 
{
	int		newMsgCount;
	int		newSysMsgCount;
}

@property (nonatomic, assign) int newMsgCount;		/**< 用户新消息数 */
@property (nonatomic, assign) int newSysMsgCount;	/**< 系统新消息数 */

- (void)replaceNickNameWithFriendRemark;			/**< 把好友列表中的昵称替换为好友备注 */

@end




/**
 @brief 单个好友动态列表
 @note  records 存放的是NdTinyActivityMsgInfo类型对象
 */
@interface NdOneFriendActivityMsgList : NdBasePageList {
}
@end




/**
 @brief 指定动态类型的动态列表
 @note  records 存放的是NdTinyActivityMsgInfo类型对象
 */
@interface NdOneTypeActivityMsgList : NdBasePageList {
}
@end




/**
 @brief 所有好友最新消息列表
 @note  records 存放的是NdUserMsgInfo类型对象
 */
@interface NdAllFriendMsgList : NdBasePageList {
}

- (void)replaceNickNameWithFriendRemark;	/**< 把好友列表中的昵称替换为好友备注 */

@end




/**
 @brief 单个好友消息列表
 @note  records 存放的是NdTinyMsgInfo类型对象
 */
@interface NdOneFriendMsgList : NdBasePageList {
}
@end




/**
 @brief 所有系统消息列表
 @note  records 存放的是NdSysMsgInfo类型对象
 */
@interface NdAllSysMsgList : NdBasePageList {
}
@end




/**
 @brief 简要动态消息
*/
@interface NdTinyActivityMsgInfo : NSObject 
{
	NSString		*msgId;
	NdMsgContent	*msgContent;
	NSString		*sendTime;
}

@property (nonatomic, retain) NSString *msgId;			/**< 消息id */
@property (nonatomic, retain) NdMsgContent *msgContent;	/**< 消息内容 */
@property (nonatomic, retain) NSString  *sendTime;		/**< 发送时间 */

@end




/**
 @brief 我的基础信息
 */
@interface NdMyBaseInfo : NSObject 
{
	NSString *uin;
	NSString *nickName;
	NSString *checkSum;
}

@property (nonatomic, retain) NSString *uin;			/**< 自己的uin */
@property (nonatomic, retain) NSString *nickName;		/**< 自己的昵称 */
@property (nonatomic, retain) NSString *checkSum;		/**< 自己的头像的checkSum */

@end




/**
 @brief 我的用户信息
 */
@interface NdMyUserInfo : NSObject 
{
	NdMyBaseInfo *baseInfo;
}

@property (nonatomic, retain) NdMyBaseInfo *baseInfo;	/**< 基础信息 */

@end




/**
 @brief 排行榜榜单信息
 */
@interface NdLeaderBoardInfo : NSObject 
{
	NSString*	leaderBoardId;					
	NSString*	leaderBoardName;				
	NSString*	description;					
	NSString*	checksum;						
}

@property (nonatomic, retain) NSString*	leaderBoardId;		/**< 排行榜编号 */
@property (nonatomic, retain) NSString*	leaderBoardName;	/**< 排行榜名称 */
@property (nonatomic, retain) NSString*	description;		/**< 排行榜描述 */
@property (nonatomic, retain) NSString*	checksum;			/**< 排行榜图校验码 */

@end




/**
 @brief 排行榜榜单列表
 @note  records 存放的是NdLeaderBoardInfo类型对象
 */
@interface NdLeaderBoardInfoList : NdBasePageList {
}
@end




/**
 @brief 提交排行榜分数信息
 */
@interface NdSendLeaderBoardInfo : NSObject 
{
	int		nLeaderBoardId;					
	int		nCurrentScore;					
	int		nHighScore;						
	int		nLowScore;						
	NSString*	displayText;				
}

@property (nonatomic, assign) int		nLeaderBoardId;		/**< 排行榜编号 */
@property (nonatomic, assign) int		nCurrentScore;		/**< 当前分值 */
@property (nonatomic, assign) int		nHighScore;			/**< 最高分 */
@property (nonatomic, assign) int		nLowScore;			/**< 最低分 */
@property (nonatomic, retain) NSString*	displayText;		/**< 显示替换字符 */

@end




/**
 @brief 排行榜中用户信息
 */
@interface NdUserInfoOfLeaderBoard : NSObject 
{
	NSString*	uin;								
	NSString*	nickName;							
	NSString*	checksumOfUserIcon;					
	NSString*	score;								
	NSString*	userRank;							
	NSString*	dateCommited;						
	NSString*	displayText;						
}

- (void)replaceNickNameWithFriendRemark;					/**< 把好友的昵称替换为好友备注 */

@property (nonatomic, retain) NSString*	uin;				/**< 用户编号 */
@property (nonatomic, retain) NSString*	nickName;			/**< 用户昵称 */
@property (nonatomic, retain) NSString*	checksumOfUserIcon;	/**< 用户头像图标校验码 */
@property (nonatomic, retain) NSString*	score;				/**< 分值 */
@property (nonatomic, retain) NSString*	userRank;			/**< 排名 */
@property (nonatomic, retain) NSString*	dateCommited;		/**< 用户提交排行数据时间 */
@property (nonatomic, retain) NSString*	displayText;		/**< 显示替换字符 */

@end




/**
 @brief 排行榜中用户信息列表
 @note  records 存放的是NdUserInfoOfLeaderBoard类型对象
 */
@interface NdUserInfoOfLeaderBoardList : NdBasePageList  
{
	NdUserInfoOfLeaderBoard*	myself;
	NSString*					strShareText;
}

@property (nonatomic, retain)	NdUserInfoOfLeaderBoard*	myself;		/**< 返回请求者在排行榜中的信息 */
@property (nonatomic, retain)   NSString*		strShareText;	/**< 当前用户排行榜分享信息，SDK内部使用 */

- (void)replaceNickNameWithFriendRemark;				/**< 把列表中好友的昵称替换为好友备注 */

@end




/**
 @brief 成就榜信息
 */
@interface NdAchievementInfo : NSObject  
{
	NSString*	achievementId;						
	NSString*	achievementName;					
	NSString*	description;						
	NSString*	displayText;						
	NSString*	dateUnlock;							
	NSString*	checksum;							
	NSString*	currentValue;						
	NSString*	completValue;						
	BOOL		isUnLock;							
}

@property (nonatomic, retain) NSString*	achievementId;		/**< 成就编号 */
@property (nonatomic, retain) NSString*	achievementName;	/**< 成就名称 */
@property (nonatomic, retain) NSString*	description;		/**< 成就描述 */
@property (nonatomic, retain) NSString*	displayText;		/**< 成就描述，用来替换分值显示的文本 */
@property (nonatomic, retain) NSString*	dateUnlock;			/**< 成就解锁时间 */
@property (nonatomic, retain) NSString*	checksum;			/**< 成就图标校验码*/
@property (nonatomic, retain) NSString*	currentValue;		/**< 当前达成的进度，提交解锁的分值 */
@property (nonatomic, retain) NSString*	completValue;		/**< 完成的总数值，完成解锁所需的分值（由后台定义是否支持）*/
@property (nonatomic, assign) BOOL		isUnLock;			/**< 当前用户是否解锁 */

@end




/**
 @brief 成就榜信息列表
 @note  records 存放的是NdAchievementInfo类型对象
 */
@interface NdAchievementInfoList : NdBasePageList  {
}
@end




/**
 @brief 解锁成就榜信息
 */
@interface NdAchievementInfoCommited : NSObject 
{
	NSString*	achievementId;							
	NSString*	currentValue;							
	NSString*	displayText;							
}	

@property (nonatomic, retain) NSString*	achievementId;	/**< 成就编号 */
@property (nonatomic, retain) NSString*	currentValue;	/**< 当前解锁的分值（0不传），如果后台有定义解锁所需的分值，该值用来判断解锁进度 */
@property (nonatomic, retain) NSString*	displayText;	/**< 替代分值显示的文本，可以为空 */

@end




/**
 @brief 解锁成就榜信息列表，用于批量解锁
 @note  records 存放的是NdAchievementInfoCommited类型对象
 */
@interface NdAchievementInfoCommitedList : NdBasePageList  {
}
@end




/**
 @brief 应用模块启用信息
 */
@interface NdModule : NSObject	
{
	int		moduleId;
	BOOL	isEnabled;
}

@property (nonatomic, assign) int		moduleId;		/**< 模块id，1＝排行榜，2＝成就榜 */
@property (nonatomic, assign) BOOL		isEnabled;		/**< 0＝未启用，1＝启用 */

@end




/**
 @brief 应用模块启用信息列表
 */
@interface NdModuleList : NSObject 
{
	NSArray*	arrModule;
}

@property (nonatomic, retain)	NSArray*	arrModule;	/**< 存放NdModule* 对象 */

- (BOOL)isEnabledAchievement;		/**< 判断成就榜是否启用 */
- (BOOL)isEnabledLeaderBoard;		/**< 判断排行榜是否启用 */

@end




/**
 @brief 获取应用分享信息及其在资源中心的url地址
 */
@interface NdSharedMessageInfo : NSObject 
{
	NSString*	strAppInfo;
	NSString*	strAppUrl;
	NSString*	strTime;
}

@property (nonatomic, retain) NSString*	strAppInfo;	/**< 分享的信息 */
@property (nonatomic, retain) NSString*	strAppUrl;	/**< 应用在资源中心的页面地址 */
@property (nonatomic, retain) NSString*	strTime;	/**< 当前时间 */

@end




#pragma mark -
#pragma mark  ------------ Third Platform ------------
/**
 @brief 第三方好友信息
 */
@interface Nd3rdFriendUserInfo : NSObject 
{
	NSString*	strFriendId;
	NSString*	strNickName;
	NSString*	strIconUrl;
	BOOL		isInvited;
}

@property (nonatomic, retain) NSString*	strFriendId;	/**< 好友id */
@property (nonatomic, retain) NSString*	strNickName;	/**< 好友昵称 */
@property (nonatomic, retain) NSString*	strIconUrl;		/**< 好友头像地址 */
@property (nonatomic, assign) BOOL		isInvited;		/**< 是否已经邀请过该好友 */

@end




/**
 @brief 第三方好友信息列表
 @note  records 存放的是Nd3rdFriendUserInfo类型对象
 */
@interface Nd3rdFriendUserInfoList : NdBasePageList  {
}
@end




/**
 @brief 第三方平台信息
 */
@interface Nd3rdPlatformInfo : NSObject 
{
	int			platformId;
	int			clientLoginType;
	NSString	*platformName;
	NSString	*checkSum;
}

@property (nonatomic, assign) int		platformId;		/**< 平台id */
@property (nonatomic, assign) int		clientLoginType;/**< 1＝客户端登录，2＝oauth登录 */
@property (nonatomic, retain) NSString *platformName;	/**< 平台名称 */
@property (nonatomic, retain) NSString *checkSum;		/**< 平台图标校验码 */

- (BOOL)isClientLoginType;

@end




/**
 @brief 第三方账号信息
 */
@interface Nd3rdAccountInfo : NSObject 
{
	BOOL		authorized;
	int			platformId;
	NSString*	str3rdAccount;
}

@property (nonatomic, assign) BOOL			authorized;			/**< 是否已授权，为NO时需要用户登录授权后才能使用该平台的功能，如发消息到该平台 */
@property (nonatomic, assign) int			platformId;			/**< 第三方平台id */
@property (nonatomic, retain) NSString*		str3rdAccount;		/**< 第三方账号 */

@end

/**
 @brief 第三方平台配置信息，用于授权
 */
@interface NdThirdPlatformConfig : NSObject
{
	NSString *authorizeURL;
	NSString *callBackURL;
}

@property (nonatomic, retain) NSString *authorizeURL;
@property (nonatomic, retain) NSString *callBackURL;

@end


@interface NdImageInfo : NSObject
{
	BOOL		bScreenShot;
	UIImage*	imgCustomed;
	NSString*	strImgFile;
}

@property (nonatomic, readonly) BOOL		bScreenShot;		/**< 是否指定为当前屏幕图像，是为YES，否则NO */
@property (nonatomic, readonly) UIImage*	imgCustomed;		/**< 指定的内存图像 */
@property (nonatomic, readonly) NSString*	strImgFile;			/**< 指定的图片文件名 */

+ (id)imageInfoWithScreenShot;						/**< 使用当前屏幕的图像 */
+ (id)imageInfoWithImage:(UIImage*)image;			/**< 使用指定的image */
+ (id)imageInfoWithFile:(NSString*)file;			/**< 使用指定的图片文件 */

@end


#pragma mark -
#pragma mark  ------------ Custom Event ------------

/**
 @brief 自定义事件数据发送规则
 */
typedef enum _ND_EVENT_SEND_TYPE
{
	ND_EVENT_SEND_NONE = 0,			/**< 不发送 */
	ND_EVENT_SEND_LAUNCH = 1,		/**< 启动时发送 */
	ND_EVENT_SEND_REALTIME = 2,		/**< 实时发送	 */
	ND_EVENT_SEND_EACHDAY = 3,		/**< 每天发送	 */
	ND_EVENT_SEND_EACHWEEK = 4		/**< 每周发送	 */
}
ND_EVENT_SEND_TYPE;

/**
 @brief 自定义事件
 */
@interface NdAppCustomEvent : NSObject
{
	NSDate		*eventDate;
	NSString	*eventId;
	NSString	*eventAction;
	NSString	*eventLabel;
	NSInteger	eventCount;
}

@property (nonatomic,retain) NSDate *eventDate;				/**< 事件时间 由SDK内部提供 */
@property (nonatomic,retain) NSString *eventId;				/**< 事件标识符 后台配置，1－99为预留ID */
@property (nonatomic,retain) NSString *eventAction;			/**< 事件触发源 15个字符以内的数字或字母 */
@property (nonatomic,retain) NSString *eventLabel;			/**< 事件标签 15个字符以内的数字或字母 */
@property (nonatomic,assign) NSInteger eventCount;			/**< 事件触发次数（由调用者累加） */

- (BOOL)isValidEvent;
- (NSString*)eventDescription;

@end
/**
 @brief 版本升级信息
 */
@interface appUpdateInfo : NSObject
{
	int updateType;
	NSString *newVersion;
	unsigned long softSize;
	NSString *updateUrl;
	NSString *resourceId;
}

@property (nonatomic,assign) int updateType;		/**< 更新类型，0＝版本一致，无须更新，1＝需要强制更新，2＝不需要强制更新 */
@property (nonatomic,retain) NSString *newVersion;	/**< 新版本号名称 */
@property (nonatomic,assign) unsigned long softSize;/**< 软件大小 */
@property (nonatomic,retain) NSString *updateUrl;	/**< 新版本下载url */
@property (nonatomic,retain) NSString *resourceId;	/**< 软件资源id */

@end
