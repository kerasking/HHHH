---------------------------------------------------
--描述: 玩家任务网络消息处理及其逻辑
--时间: 2012.3.16
--作者: jhzheng
---------------------------------------------------

----------------------------------------游戏数据更新事件定义
local GAMEDATAEVENT_USER_BEGIN		= 1;
local GAMEDATAEVENT_PET_BEGIN		= 500;
local GAMEDATAEVENT_ITEM_BEGIN		= 1000;

GAMEDATAEVENT = 
{
	--用户相关
	USERATTR							= GAMEDATAEVENT_USER_BEGIN + 1,
	--伙伴相关
	PETINFO								= GAMEDATAEVENT_PET_BEGIN + 1,
	PETATTR								= GAMEDATAEVENT_PET_BEGIN + 2,
	--物品相关
	ITEMINFO							= GAMEDATAEVENT_ITEM_BEGIN + 1,
	ITEMATTR							= GAMEDATAEVENT_ITEM_BEGIN + 2,
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
