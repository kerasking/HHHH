
local _G = _G;
setfenv(1, TASK);

SM_TASK_STATE =
{
	STATE_NONE					= 0,
	STATE_AVAILABLE				= 1,	-- 任务可接
	STATE_UNCOMPLETE			= 2,	-- 任务已接未完成
	STATE_COMPLETE				= 3,	-- 任务已接已完成
	STATE_NOT_AVAILABLE			= 4,	-- 任务未做不可接 (前置任务未完成,等级差5级以上)
	STATE_NUM_NOT_ALLOWED		= 5,	-- 任务已做不可接, 次数限制
	STATE_LV_NOT_ALLOWED		= 6,	-- 任务未做不可接, 等级限制在5级以内
	STATE_SUMMIT				= 7,	-- 任务已交
};

SM_TASK_CONTENT_TYPE  =
{
	NONE									= 0,
	MONSTER									= 1,
	ITEM									= 2,
	NPC										= 3,
	-- ...
};

SM_TASK_OPTION_ACTION =
{
	ACCEPT									= 10000,
	REJECT									= 10001,
};
