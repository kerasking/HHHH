---------------------------------------------------
--描述: 剧情枚兴起定义
--时间: 2012.4.20
--作者: jhzheng
---------------------------------------------------
local p = Drama; 

p.SpriteTypePlayer				= 1;
p.SpriteTypeNpc					= 2;
p.SpriteTypeMonster				= 3;

p.DramType = 
{
	BATTLE_START = 1,
	BATTLE_END 	 = 2,
	TASK_START	 = 3,
	TASK_END 	 = 4,
}

--剧情播放表


--p.DramPlayFuncTable = {}

--p.DramPlayFuncTable[1]= {1,50002,900100000,0,p.MainDrama_6};
--p.DramPlayFuncTable[2]= {2,50002,900100000,0,p.MainDrama_7};



p.DramPlayFuncTable = {

	--1.注:		--2.注:		--3.注:		--4.注:		--5.注
	--剧情调用点	--任务id		--副本id		--播放过:1	--剧情调用
	--必需配置	--0表示无限				--无则:0		--函数,必需
	--1进入副本										--配置
	--2副本的怪
	--都打完,显示
	--宝箱前                                                
	--3接受任务
	--4完成任务
	
	
	 --测试用
   -- {3,			50001,			0,		0,		p.MainDrama_14};

	
	
	
	{3,			50001,		    0,	    0,		p.MainDrama_8};
	{2,			50004,		900300000,	    0,		p.MainDrama_9};
	{2,			50011,		900800000,	0,		p.MainDrama_10};
	{2,			50016,		901200000,  0,		p.MainDrama_11};
	{2,			50026,		902100000,  0,		p.MainDrama_12};
	{2,			50032,		902500000,  0,		p.MainDrama_13};
	{2,			50042,		903200000,  0,		p.MainDrama_14};
}
