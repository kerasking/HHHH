---------------------------------------------------
--描述: 全局事件及事件数据结构定义
--时间: 2012.3.16
--作者: jhzheng
---------------------------------------------------

----------------------------------------游戏数据更新事件定义
local GAMEDATAEVENT_USER_BEGIN		= 1;
local GAMEDATAEVENT_PET_BEGIN		= 500;
local GAMEDATAEVENT_ITEM_BEGIN		= 1000;
local GAMEDATAEVENT_FRIEND_BEGIN	= 1500;
local GAMEDATAEVENT_BATTLE_BEGIN	= 2000;

GAMEDATAEVENT = 
{
	--用户相关
	USERATTR							= GAMEDATAEVENT_USER_BEGIN + 1,
    USERSTAGEATTR						= GAMEDATAEVENT_USER_BEGIN + 2,
	--伙伴相关
	PETINFO								= GAMEDATAEVENT_PET_BEGIN + 1,
	PETATTR								= GAMEDATAEVENT_PET_BEGIN + 2,
	--物品相关
	ITEMINFO							= GAMEDATAEVENT_ITEM_BEGIN + 1,
	ITEMATTR							= GAMEDATAEVENT_ITEM_BEGIN + 2,
	
	--好友相关
	FRIENDATTR							= GAMEDATAEVENT_FRIEND_BEGIN + 1,
    
    --战斗失败
	BATTLE_LOSE_INFO			= GAMEDATAEVENT_BATTLE_BEGIN + 1,
};

----------------------------------------用户数据
--USERATTR param
--[[用户属性更新
t = 
{
	[1]		= enum1,
	[2]		= val2,
	[3]		= enum2,
	[4]		= val3,
	...
};
--]]

----------------------------------------伙伴数据
--PETINFO param
--petid

--PETATTR param
--[[伙伴属性更新
t = 
{
	[1]		= petId,
	[2]		= enum1,
	[3]		= val2,
	[4]		= enum2,
	[5]		= val3,
	...
};
--]]
----------------------------------------物品数据
--ITEMINFO param
--itemid

--ITEMATTR param
--[[ 物品属性更新
t = 
{
	[1]		= enum1,
	[2]		= val2,
	[3]		= enum2,
	[4]		= val3,
	...
};
--]]
----------------------------------------好友数据
--FRIENDINFO param
--friendid

--FRIENDATTR param
--[[ 好友属性更新
t = 
{
	[1]		= enum1,
	[2]		= val2,
	[3]		= enum2,
	[4]		= val3,
	...
};
--]]

