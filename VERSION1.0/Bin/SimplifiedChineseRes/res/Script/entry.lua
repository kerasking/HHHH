--数据库数据加载
bgnTimeSlice("DBLoad.lua")
	DoFile("DBLoad.lua");
endTimeSlice("DBLoad.lua")

--common
bgnTimeSlice("Common/define.lua")
	DoFile("Common/define.lua");
endTimeSlice("Common/define.lua")
--登录清理数据
DoFile("LogInClearData.lua");

--通用对话框
bgnTimeSlice("CommonDlg/define.lua")
	DoFile("CommonDlg/define.lua");
endTimeSlice("CommonDlg/define.lua")

--消息处理
bgnTimeSlice("Msg/define.lua")
	DoFile("Msg/define.lua");
endTimeSlice("Msg/define.lua")

--主界面UI
bgnTimeSlice("MainUI/define.lua")
	DoFile("MainUI/define.lua");
endTimeSlice("MainUI/define.lua")

--玩家
bgnTimeSlice("Player/define.lua")
	DoFile("Player/define.lua");
endTimeSlice("Player/define.lua")

--Npc
bgnTimeSlice("Npc/define.lua")
	DoFile("Npc/define.lua");
endTimeSlice("Npc/define.lua")

--任务
bgnTimeSlice("Task/define.lua")
	DoFile("Task/define.lua");
endTimeSlice("Task/define.lua")

--奇术
bgnTimeSlice("Magic/define.lua")
	DoFile("Magic/define.lua");
endTimeSlice("Magic/define.lua")

--RolePet
bgnTimeSlice("RolePet/define.lua")
	DoFile("RolePet/define.lua");
endTimeSlice("RolePet/define.lua")

--物品
bgnTimeSlice("Item/define.lua")
	DoFile("Item/define.lua");
endTimeSlice("Item/define.lua")

--RolePet
bgnTimeSlice("RolePet/define.lua")
	DoFile("RolePet/define.lua");
endTimeSlice("RolePet/define.lua")

--悟道
bgnTimeSlice("Realize/define.lua")
	DoFile("Realize/define.lua");
endTimeSlice("Realize/define.lua")

--副本
bgnTimeSlice("AffixBoss/define.lua")
	DoFile("AffixBoss/define.lua");
endTimeSlice("AffixBoss/define.lua")

--BOSS战
bgnTimeSlice("BOSS/define.lua")
	DoFile("BOSS/define.lua");
endTimeSlice("BOSS/define.lua")

--排行榜
bgnTimeSlice("Arena/define.lua")
	DoFile("Arena/define.lua");
endTimeSlice("Arena/define.lua")

--登陆和角色创建
bgnTimeSlice("Login/define.lua")
	DoFile("Login/define.lua");
endTimeSlice("Login/define.lua")

--活动
bgnTimeSlice("Activity/define.lua")
	DoFile("Activity/define.lua");
endTimeSlice("Activity/define.lua")

--玩家状态
bgnTimeSlice("UserState/define.lua")
	DoFile("UserState/define.lua");
endTimeSlice("UserState/define.lua")

--强化
bgnTimeSlice("EquipStr/define.lua")
	DoFile("EquipStr/define.lua");
endTimeSlice("EquipStr/define.lua")

--好友
bgnTimeSlice("Friend/define.lua")
	DoFile("Friend/define.lua");
endTimeSlice("Friend/define.lua")

--聊天
--bgnTimeSlice("Chat/define.lua")
	--DoFile("Chat/define.lua");
--endTimeSlice("Chat/define.lua")

--剧情
bgnTimeSlice("Drama/define.lua")
	DoFile("Drama/define.lua");
endTimeSlice("Drama/define.lua")

--商店
bgnTimeSlice("Shop/define.lua")
	DoFile("Shop/define.lua");
endTimeSlice("Shop/define.lua")

--装备养成
bgnTimeSlice("Equip/define.lua")
	DoFile("Equip/define.lua");
endTimeSlice("Equip/define.lua")

--装备养成
bgnTimeSlice("HeroStar/define.lua")
	DoFile("HeroStar/define.lua");
endTimeSlice("HeroStar/define.lua")

--聊天
bgnTimeSlice("Chat/define.lua")
	DoFile("Chat/define.lua");
endTimeSlice("Chat/define.lua")

--系统
bgnTimeSlice("System/define.lua")
	DoFile("System/define.lua");
endTimeSlice("System/define.lua")

--新手引导
bgnTimeSlice("Tutorial/define.lua")
	DoFile("Tutorial/define.lua");
endTimeSlice("Tutorial/define.lua")

--音乐
bgnTimeSlice("Music/define.lua")
	DoFile("Music/define.lua");
endTimeSlice("Music/define.lua")

--军团
bgnTimeSlice("ArmyGroup/define.lua")
	DoFile("ArmyGroup/define.lua");
endTimeSlice("ArmyGroup/define.lua")

--军团战
bgnTimeSlice("SyndicateBattle/define.lua")
DoFile("SyndicateBattle/define.lua");
endTimeSlice("SyndicateBattle/define.lua")

--宴会
bgnTimeSlice("Banquet/define.lua")
DoFile("Banquet/define.lua");
endTimeSlice("Banquet/define.lua")

--幸运宝箱
DoFile("LuckyBox/define.lua");
--占星
DoFile("Destiny/define.lua");
--名人
DoFile("RankList/define.lua");
--古迹寻宝
DoFile("TreasureHunt/define.lua");
