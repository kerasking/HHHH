---------------------------------------------------
--描述: 军团战战斗界面
--时间: 2012.10.24
--作者: qbw
---------------------------------------------------
SyndicateBattleUI = {}
local p = SyndicateBattleUI;

local ID_ARMYGROUPBATTLE_CTRL_BUTTON_70						= 100;
local ID_ARMYGROUPBATTLE_CTRL_BUTTON_68						= 70;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_73						= 90;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_72						= 80;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_112						= 112;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_111						= 111;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_110						= 110;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_109						= 109;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_108						= 108;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_107						= 107;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_106						= 106;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_105						= 105;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_104						= 104;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_103						= 103;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_102						= 102;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_101						= 101;
local ID_ARMYGROUPBATTLE_CTRL_LIST_DEFENCE					= 57;
local ID_ARMYGROUPBATTLE_CTRL_LIST_ATTACK					= 56;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_DEFENCE					= 54;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_ATTACK					= 53;
local ID_ARMYGROUPBATTLE_CTRL_BUTTON_51						= 51;
local ID_ARMYGROUPBATTLE_CTRL_BUTTON_26						= 27;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_BUFF						= 24;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_BONUS					= 22;
local ID_ARMYGROUPBATTLE_CTRL_BUTTON_INSPIRE2				= 28;
local ID_ARMYGROUPBATTLE_CTRL_BUTTON_INSPIRE1				= 18;
local ID_ARMYGROUPBATTLE_CTRL_TEXT_TITLE					= 3;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_99					= 99;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_98					= 98;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_97					= 97;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_96					= 96;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_95					= 95;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_94					= 94;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_93					= 93;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_92					= 92;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_91					= 91;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_89					= 89;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_88					= 88;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_87					= 87;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_86					= 86;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_85					= 85;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_84					= 84;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_83					= 83;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_82					= 82;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_81					= 81;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_79					= 79;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_78					= 78;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_77					= 77;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_76					= 76;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_75					= 75;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_74					= 74;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_73					= 73;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_72					= 72;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_71					= 71;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_69					= 69;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_68					= 68;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_67					= 67;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_66					= 66;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_65					= 65;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_64					= 64;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_63					= 63;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_62					= 62;
local ID_ARMYGROUPBATTLE_CTRL_PICTURE_61					= 61;
local ID_ARMYGROUPBATTLE_CTRL_BUTTON_158					= 158;

local g_nTopComboKill = 0;
local g_nWin = 0;
local g_nHonor = 0;
local g_nComboKill = 0;
local g_nLost = 0;
local g_EncourageLev = 0;
local g_Money = 0;
local g_Emoney = 0;
local g_Score = 0;
	
local winsize	= GetWinSize();
local scrollMainReport = nil;
local rankboardscore 	   = nil;
local rankboardstreak 	   = nil;

local tState = {
	InBattle = 1;
	WINOutBattle = 2;
	LOSEOutBattle = 3;
}

local bIfAutoJoinNextBattle = tState.LOSEOutBattle; 
local tBattleResult = {}


--[INDEX] ={玩家名字,玩家阵营(1 攻击,2 防御),玩家是否入场(1是 0否),玩家id}
local tPlayerList ={}
local g_nPlayerListHead = 1;
local g_nPlayerListBottom = 1;

local MAX_PLAYER_NUM_PER_PAGE = 8;
local MAX_REPORT_NUM_PER_PAGE = 4;

--玩家名字表
local tPlayerName = {}

local NameColor = {
	ATTLIST = ccc4(0,198,213,255),
	GREEN = ccc4(28,237,93,255),      --绿色
	YELLOW = ccc4(255, 255, 0, 255),
	DEFLIST = ccc4(248,66,0,255),
}

local g_Count = 0;
p.TimerTag = nil;

local tMainReport = {}
local tUserReport = {}

local nMainReportHead = 1;
local nMainReportBottom = 1;
local nMainReportMaxCount = 50;

local nUserReportHead = 1;
local nUserReportBottom = 1;
local nUserReportMaxCount = 50;

local tRankBoardScore ={}
local tRankBoardStreak = {}

--[[
local StateType = {
		ChaosBattleStateNotOpen = 0,	--未开启
		ChaosBattleStatePrepare = 1,	--准备
		ChaosBattleStateOpen = 2,	--开启
		ChaosBattleStateClosing = 3,	--准备关闭
		ChaosBattleStateComplete = 4,	--关闭
}--]]
p.ActivityState = 1;

local scrollResultReport = nil;

local g_AttArmyName = "军团";
local g_DefArmyName = "军团";

--重置所有数据
function p.ResetAllData()

	p.ActivityState = 1;
	tPlayerList ={}
	g_nPlayerListHead = 1;
	g_nPlayerListBottom = 1;
	
	tPlayerName = {}
	
	g_Count = 0;
	
	p.TimerTag = nil;

	tMainReport = {}
	tUserReport = {}
	
	nMainReportHead = 1;	
	nUserReportHead = 1;
	
	tRankBoardScore ={}
	tRankBoardStreak = {}
	
	LogInfo("qboy setbattle out ResetAllData");
	bIfAutoJoinNextBattle = tState.LOSEOutBattle;
end



--加载每日签到主界面
function p.LoadUI()
	scrollResultReport = nil;
	 p.bIfComplete = false;
	local nRoleId =  GetPlayerId();
	local nLevNeed = 40;
	local mainpetid 	= RolePetUser.GetMainPetId(nRoleId);
	local nLevPlayer	= SafeS2N(RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL));

	
	
	
	p.ResetAllData();
	ArenaUI.isInChallenge = 6;
    LogInfo("qboy SyndicateBattle.LoadUI");
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    --------------------添加每日签到层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.SyndicateBattleUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChild(layer);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("ArmyGroupBattle/ArmyGroupBattle.ini", layer, p.OnUIEvent, 0, 0);

	
	--初始化列表
	local attContainer = p.GetAttContainer();
	if attContainer then
			local rectview = attContainer:GetFrameRect();
			if nil ~= rectview then
				local nWidth	= rectview.size.w*1.2;
				local nHeight	= rectview.size.h / MAX_PLAYER_NUM_PER_PAGE;
				attContainer:SetStyle(UIScrollStyle.Verical);
				attContainer:SetViewSize(CGSizeMake(nWidth, nHeight));
				attContainer:SetTopReserveDistance(rectview.size.h);
				attContainer:SetBottomReserveDistance(rectview.size.h);
				attContainer:EnableScrollBar(true);
			end
	end
		
	local defContainer = p.GetDefContainer();
	if defContainer then
			local rectview = defContainer:GetFrameRect();
			if nil ~= rectview then
				local nWidth	= rectview.size.w*1.2;
				local nHeight	= rectview.size.h / MAX_PLAYER_NUM_PER_PAGE;
				defContainer:SetStyle(UIScrollStyle.Verical);
				defContainer:SetViewSize(CGSizeMake(nWidth, nHeight));
				defContainer:SetTopReserveDistance(rectview.size.h);
				defContainer:SetBottomReserveDistance(rectview.size.h);
				defContainer:EnableScrollBar(true);
			end
	end		
	
	----------------------------战报容器---------------------------------------
	local rectX = winsize.w*0.3;
	local rectW	= winsize.w*0.4;
	local rect  = CGRectMake(rectX, winsize.h*0.23, rectW, winsize.h*0.5); 
	
	--全部战报
	scrollMainReport = createUIScrollViewContainer();
	if scrollMainReport == nil then
		LogInfo("scrollMainReport == nil,load ChatMainUI failed!");
		return;
	end
	scrollMainReport:Init();
	scrollMainReport:SetFrameRect(rect);
	layer:AddChild(scrollMainReport);
	
	local rectview = scrollMainReport:GetFrameRect();
	scrollMainReport:SetStyle(UIScrollStyle.Verical);
	scrollMainReport:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / MAX_REPORT_NUM_PER_PAGE));
	scrollMainReport:EnableScrollBar(true);
	scrollMainReport:SetVisible(true);
	
	---战况
	local uiLoad = createNDUILoad();
    if nil == uiLoad then
   	 return false;
    end
 	local Resultlayer = createNDUILayer();
	if Resultlayer == nil then
		return false;
	end
    
	Resultlayer:Init();
	Resultlayer:SetTag(8888); 
	layer:AddChild(Resultlayer);	
		
	uiLoad:Load("ArmyGroupBattle/ArmyGroupBattle_L_1.ini", Resultlayer, nil, 0, 0);	
	local rectlayer  = CGRectMake(rectX, winsize.h*0.23, rectW, winsize.h*0.5); 
	
	Resultlayer:SetFrameRect(rectlayer);
	
	scrollResultReport = createUIScrollViewContainer();
	if scrollResultReport == nil then
		LogInfo("scrollResultReport == nil,load ChatMainUI failed!");
		return;
	end
	
	
	scrollResultReport:Init();
	local rectSVC  = CGRectMake(rectX*1.1, winsize.h*0.27, rectW*0.9, winsize.h*0.45); 
	
	
	scrollResultReport:SetFrameRect(rectSVC);
	layer:AddChild(scrollResultReport);
	
	local rectview = scrollResultReport:GetFrameRect();
	scrollResultReport:SetStyle(UIScrollStyle.Verical);
	scrollResultReport:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 8));
	scrollResultReport:EnableScrollBar(true);
	scrollResultReport:SetVisible(false);
	Resultlayer:SetVisible(false);
	
	
	p.RefreshInfo();

	--屏蔽鼓舞功能
	local Moneybtn = RecursiveButton(layer, {ID_ARMYGROUPBATTLE_CTRL_BUTTON_INSPIRE1}); 
	local Emoneybtn = RecursiveButton(layer, {ID_ARMYGROUPBATTLE_CTRL_BUTTON_INSPIRE2}); 
	local labelBuffDesc = RecursiveLabel(layer, {22});
	local labelBuff = RecursiveLabel(layer, {24});
	labelBuffDesc:SetVisible(false);
	labelBuff:SetVisible(false);
	Moneybtn:SetVisible(false);
	Emoneybtn:SetVisible(false);

	--屏蔽自动参战
	--local labelAutoFight = RecursiveLabel(layer, {29});
	--local checkBoxAutoFight=RecursiveCheckBox(layer,{ID_ARMYGROUPBATTLE_CTRL_CHECK_BUTTON_31});
	--labelAutoFight:SetVisible(false);
	--checkBoxAutoFight:SetVisible(false);

	
	
	local btn1 = GetButton( layer, ID_ARMYGROUPBATTLE_CTRL_BUTTON_51 );  
	btn1:SetChecked( true );	
	
	
	return true;
end

function p.GetResultLayer()
	local layer = p.GetParent()
	
	if CheckP(layer) == false then
		LogInfo("qboy GetResultLayer layer nil"); 
	end
	
	local resultlayer = GetUiLayer(layer, 8888);
	
	return resultlayer;
end



--刷新数据
function p.RefreshInfo()
	p.refreshCamplist();--刷新玩家列表
	--刷新战报
	p.refreshPlayerCount();--刷新人数
 	p.refreshResultInfo();--刷新统计信息
end

local g_BattleEndTime = 0;
--设置活动结束时间
function p.SetBattleEndTime(nElapseTime)
	g_BattleEndTime = nElapseTime;
	p.updateBattleEndCount(g_BattleEndTime);
	
end

p.BattleEndTimerTag = nil;
--更新倒计时
function p.updateBattleEndCount(restCount)
	g_BattleEndTime = restCount;
		
	local CDlabel = p.GetBattleEndCDLabel();
	
	if CDlabel ~= nil then
		--LogInfo("qboy CDlabel nil:"); 
		if restCount <= 0 then
			if p.BattleEndTimerTag ~= nil then
				UnRegisterTimer(p.BattleEndTimerTag);
				p.BattleEndTimerTag = nil;
			end
		
			CDlabel:SetText("00:00:00");
		else
			CDlabel:SetText(FormatTime(restCount,1));
		end
	end
	
	
	if restCount > 0 then
		
		p.BattleEndTimerTag=RegisterTimer(p.BattleEndTimerTick,1, "SyndicateBattle.BattleEndTimerTick");
		LogInfo("qboy RegisterTimer TimerTick battleend"..p.BattleEndTimerTag); 
	end

end





function p.ProccessResultInfo(nWin,nEncorageLev)
	
	g_nWin = nWin;
	g_EncourageLev = nEncorageLev;
	
	p.refreshResultInfo();
end



function p.TimerTick(tag) 
	 --如果为开启ui则关闭计时器
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI) then
		UnRegisterTimer(tag);
		p.TimerTag = nil;
		return;
	end
	LogInfo("qboyCloseUI5");
	if tag == p.TimerTag then
		--如果没有在列表中 发送battleEnd
		--注销定时器
		LogInfo("qboyCloseUI4");
		if  p.IfIsInBattle() == false then
			LogInfo("qboyCloseUI3");
			if p.bIfComplete == false then
				if bIfAutoJoinNextBattle == tState.WINOutBattle then
					LogInfo("qboy1 MsgSyndicateBattle BattleEnd");
					MsgSyndicateBattle.BattleEnd();
					UnRegisterTimer(p.TimerTag);
					p.TimerTag = nil;
					LogInfo("qboy setbattle out TimerTick");
	
					bIfAutoJoinNextBattle = tState.LOSEOutBattle;
					return;
				end
			else
				LogInfo("qboyCloseUI2");
				UnRegisterTimer(p.TimerTag);
				p.TimerTag = nil;
				p.CloseUI();			
			end	
		end
	end
end


--	--刷新活动状态
--	MsgSyndicateBattle.SendSyndicateBattleOpenBoard();
local nRefreshCount = 30;

function p.BattleEndTimerTick(tag)
	nRefreshCount = nRefreshCount - 1;
	if nRefreshCount <= 0 then
		nRefreshCount = 30;
		
		--刷新活动状态
		MsgSyndicateBattle.SendSyndicateBattleOpenBoard();
		
		UnRegisterTimer(tag);
		p.BattleEndTimerTag = nil;
		
	end
	
	
	--活动结束则自动关闭
	if p.ActivityState == 4 then
		p.QuitBattle();	
		UnRegisterTimer(tag);
		p.BattleEndTimerTag = nil;
		
	end
	

	 --如果为开启ui则关闭计时器
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI) then
		UnRegisterTimer(tag);
		p.BattleEndTimerTag = nil;
		return;
	end
	

	if tag == p.BattleEndTimerTag then
		g_BattleEndTime = g_BattleEndTime - 1;

		--刷新计数文字
		if g_BattleEndTime <= 0 then
			g_BattleEndTime = 0;
		end
		
		local CDLabel = p.GetBattleEndCDLabel();

		if CDLabel ~= nil then
			CDLabel:SetText(FormatTime(g_BattleEndTime,1));
		end
			
		if g_BattleEndTime <= 0 then
			LogInfo("qboy UnRegisterTimer1 :"); 
			UnRegisterTimer(p.BattleEndTimerTag);
			p.BattleEndTimerTag = nil;

			if CDLabel ~= nil then
				CDLabel:SetText("00:00:00");
			end
		end		
	end
end

function p.IsAutoFight()
	local layer=p.GetParent();
	local checkBox=RecursiveCheckBox(layer,{ID_ARMYGROUPBATTLE_CTRL_CHECK_BUTTON_31});
	
	if CheckP(checkBox) == false then
		return false;
	end

	local pCheckAuto = ConverToCheckBox( checkBox );
    if pCheckAuto:IsSelect() then
		return true;
    end	
	return false;
end


function p.AutoFight() 
	local layer=p.GetParent();
	local checkBox=RecursiveCheckBox(layer,{ID_ARMYGROUPBATTLE_CTRL_CHECK_BUTTON_31});
	
	if CheckP(checkBox) == false then
		return;
	end
	
	local pCheckAuto = ConverToCheckBox( checkBox );
    if pCheckAuto:IsSelect() then
        if p.IfIsInBattle() == false then
			p.JoinBattle();
		end
    end
	
end

--等待 当玩家被清除列表时才发送battleend
function p.updateCount(restCount)
	g_Count = restCount;
		
	local CDlabel = p.GetCDLabel();
	
	if CDlabel ~= nil then
		LogInfo("qboy CDlabel nil:"); 
		if restCount <= 0 then
			p.AutoFight();
			LogInfo("qboy99 111111:");
			
			--如果已经在战斗中则时轮空
			if p.IfIsInBattle() then
				LogInfo("qboy 已经在战斗中");
			else
				CDlabel:SetTitle("参战");
				CDlabel:SetChecked( false );		
			end
			
			

		elseif restCount <=30 then
			
			CDlabel:SetTitle(FormatTime(restCount,1));
			CDlabel:SetChecked( false );
		else
			CDlabel:SetTitle("战斗中...");
			CDlabel:SetChecked( true );
		end
	end
	
	if p.TimerTag ~= nil then
		LogInfo("qboy UnRegisterTimer2 :"); 
		UnRegisterTimer(p.TimerTag);
		p.TimerTag = nil;
	end
	
	if restCount > 0 then
		
		p.TimerTag=RegisterTimer(p.TimerTick,1, "SyndicateBattle.TimerTick");
		LogInfo("qboy RegisterTimer TimerTick"..p.TimerTag); 
		
	end

end


--刷新统计信息
function p.refreshResultInfo()
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI) then
		return;
	end
	
	local WinLabel 	=  RecursiveLabel(p.GetParent(),{102});
	--local EncourageLabel 	=  RecursiveLabel(p.GetParent(),{ID_ARMYGROUPBATTLE_CTRL_TEXT_BUFF});
	
	WinLabel:SetText(""..g_nWin);
	
	--[[
	if g_EncourageLev ~= 0 then
		EncourageLabel:SetText("鼓舞"..g_EncourageLev.."星")
	else
		EncourageLabel:SetText("无")
	end
	--]]
end

--刷新人数
function p.refreshPlayerCount()
	local nCountAtt = 0;
	local nCountDef = 0;
	for i=g_nPlayerListBottom,g_nPlayerListHead do
		if tPlayerList[i] ~= nil then
			if tPlayerList[i][2] == 1 then
				nCountAtt = nCountAtt+1;
			else
				nCountDef = nCountDef+1;
			end
		end	
	end


	local AttkLabel 	=  RecursiveLabel(p.GetParent(),{ID_ARMYGROUPBATTLE_CTRL_TEXT_ATTACK});
	local DefLabel 		=  RecursiveLabel(p.GetParent(),{ID_ARMYGROUPBATTLE_CTRL_TEXT_DEFENCE});

	AttkLabel:SetText(g_AttArmyName.."("..nCountAtt.."人)");
	DefLabel:SetText(g_DefArmyName.."("..nCountDef.."人)");
	
	
end

--清除列表
function p.ClearAllUser()
	LogInfo("qboy ClearAllUser");
	tBattleResult = {};
	g_nWin = 0;
	local attContainer = p.GetAttContainer();
	local defContainer = p.GetDefContainer();
	
	
	if not attContainer or not defContainer then
		return;
	end

	attContainer:RemoveAllView();
	defContainer:RemoveAllView();
		
	tPlayerList = {}
	
	g_nPlayerListBottom = 1;
	g_nPlayerListHead	= 1;
	
	
end

--刷新玩家列表
function p.refreshCamplist()
	
	local attContainer = p.GetAttContainer();
	local defContainer = p.GetDefContainer();
	
	
	if not attContainer or not defContainer then
		return;
	end

	attContainer:RemoveAllView();
	defContainer:RemoveAllView();
	
	local tTmplist = {}--tPlayerList;
	for i,v in pairs(tPlayerList) do
		tTmplist[i] = v;
	end
	
	
	--先加入未入场玩家
	for i = g_nPlayerListBottom,g_nPlayerListHead do
		--LogInfo("qboy refreshCamplist i:"..i);
		if tPlayerList[i] ~= nil then
			if tPlayerList[i][3] == 1 then
				if tPlayerList[i][2] == 1 then
					p.AddPlayer(attContainer, i);
				else
					p.AddPlayer(defContainer, i);
				end
				tTmplist[i] = nil;	
			end					
		end
			
	end	--]]
	
	
	for i,v in pairs(tTmplist) do		
		if tPlayerList[i][2] == 1 then
			p.AddPlayer(attContainer, i);
		else
			p.AddPlayer(defContainer, i);
		end
	end
end

function p.AddPlayerToList(nUserId,nCamp,sName)
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI) then
		SyndicateBattleUI.LoadUI();
		if IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleResultUI) then
			CloseUI(NMAINSCENECHILDTAG.SyndicateBattleResultUI);
		end
	end

	--储存战况
	LogInfo("qboy AddPlayerToList 储存战况 id:"..nUserId)
	if tBattleResult[nUserId] == nil then
		
		tBattleResult[nUserId] = {0,sName,0,nCamp}
		LogInfo("qboy AddPlayerToList 储存战况 tBattleResult[nUserId]:"..tBattleResult[nUserId][2])
	end
		
	--已有玩家则返回
	for i,v in pairs(tPlayerList) do
		if nUserId == v[4] then
			LogInfo("qboy AddPlayerToList 玩家已存在 id:"..nUserId)
			return;
		end
	end
	
	



	local attContainer = p.GetAttContainer();
	local defContainer = p.GetDefContainer();
	
	
	if not attContainer or not defContainer then
		return;
	end	
	

	
	tPlayerList[g_nPlayerListHead] = {sName,nCamp,0,nUserId};
	
	
	if nCamp == 1 then
		p.AddPlayer(attContainer, g_nPlayerListHead);
	else
		p.AddPlayer(defContainer, g_nPlayerListHead);
	end
	
	g_nPlayerListHead = g_nPlayerListHead+1;	
	--LogInfo("qboy AddPlayerToList tPlayerList[nUserId]:"..tPlayerList[nUserId][1].." "..tPlayerList[nUserId][2].." "..tPlayerList[nUserId][3]);
	
	
	--设置参战按钮
	if nUserId == GetPlayerId() then
		local CDLabel = p.GetCDLabel();

		if CDLabel ~= nil then
			CDLabel:SetTitle("等待战斗...");
			CDLabel:SetChecked( true );
		end
	end	


	p.refreshPlayerCount();--刷新人数
end

function p.RemovePlayerFromList(nUserId)
	LogInfo("qboy1 RemovePlayerFromList nUserId g_nPlayerListBottom :"..nUserId.." "..g_nPlayerListBottom.." "..g_nPlayerListHead );
	local nIndex = 0;
	for i = g_nPlayerListBottom ,g_nPlayerListHead   do 
		--LogInfo("qboy1 RemovePlayerFromList i:"..i.." nUserId:"..nUserId.." tPlayerList[i][4]:"..tPlayerList[i][4])
		if tPlayerList[i] ~= nil then
			if tPlayerList[i][4] == nUserId then
				nIndex = i;
				break;
			end
		end
	end
	--LogInfo("qboy1 RemovePlayerFromList nIndex:"..nIndex);
	
	if nIndex == 0 then
		LogInfo("qboy1 RemovePlayerFromList fail nIndex 0 nUserId:"..nUserId);	
		return;
	end
	
	
	
	if  tPlayerList[nIndex] == nil then
		return;
	end
	
	local attContainer = p.GetAttContainer();
	local defContainer = p.GetDefContainer();	
	if not attContainer or not defContainer then
		return;
	end
	
	local view = nil;
	if tPlayerList[nIndex][2] == 1 then
		attContainer:RemoveViewById(tPlayerList[nIndex][4]);
	else
		defContainer:RemoveViewById(tPlayerList[nIndex][4]);
	end
	LogInfo("qboy1 RemovePlayerFromList tPlayerList#"..#tPlayerList)
	table.remove(tPlayerList,nIndex);
	--tPlayerList[nIndex] = nil;
	--g_nPlayerListBottom = g_nPlayerListBottom +1;
	g_nPlayerListHead = #tPlayerList + 1;
	p.refreshPlayerCount();--刷新人数
end


function p.SetPlayerListBottom(nAdj)
	
	g_nPlayerListBottom = g_nPlayerListBottom +nAdj;
	
	if g_nPlayerListBottom >= g_nPlayerListHead then
		g_nPlayerListBottom = g_nPlayerListHead;
	end
	
end

function p.EnterBattle(nUserId)
	--LogInfo("qboy1 EnterBattle nUserId"..nUserId);	
	for i = 1 ,#tPlayerList  do 
		
		--LogInfo("qboy1 EnterBattle i:"..i);	
		if tPlayerList[i] ~= nil then
			if tPlayerList[i][4] == nUserId then
				tPlayerList[i][3] = 1;
				--变色
				--LogInfo("qboy1 EnterBattle nUserId:"..nUserId.." "..tPlayerList[i][1]);
				if tPlayerList[i][2]== 1 then
					p.ChangeColorByIndex(i,NameColor.ATTLIST);
				else
					p.ChangeColorByIndex(i,NameColor.DEFLIST);	
				end
				
				return;
			end
		end	
	end
	
	LogInfo("qboy1 EnterBattle 缺少玩家 nUserId"..nUserId);	
	for i = 1 ,#tPlayerList  do 
		
		LogInfo("qboy1 bianli name:"..tPlayerList[i][1].." "..tPlayerList[i][4])
		
	end
	
	
	
	
end

--向列表增加玩家
function p.AddPlayer(container, nIndex)
	--LogInfo("qboy AddPlayer nUserId:"..nUserId);	
	
	if not CheckP(container) or not CheckN(nIndex) then
		return;
	end

	local sUserName = tPlayerList[nIndex][1];
	if "" == sUserName then
		return;
	end

		
	local pool = DefaultPicPool();
	

	local view = createUIScrollView();
	if view ~= nil then
		view:Init(false);
		view:SetViewId(tPlayerList[nIndex][4]);
		
		--增加个背景按钮
		local bgBtn = createNDUIButton();
		bgBtn:Init();
		bgBtn:SetTag(tPlayerList[nIndex][4]);
		local sizeview		= view:GetFrameRect().size;
		local width = container:GetFrameRect().size.w*0.9
		local Height = width*0.16;
		bgBtn:SetFrameRect(CGRectMake(-width*0.2, 0, width*2 , Height*2));
		view:AddChildZ(bgBtn,1);
		bgBtn:SetLuaDelegate((p.OnCampListcontainerUIEvent));
		bgBtn:CloseFrame();

		container:AddView(view);
		local sizeview		= view:GetFrameRect().size;
		
		
--
		local hyperlinkBtn = nil;
		if tPlayerList[nIndex][3] == 1 then
			 
			 --[[hyperlinkBtn	= CreateHyperlinkButton("[待]"..sUserName, 
						CGRectMake(0, 0, sizeview.w , sizeview.h),
						12,
						NameColor.GREEN);--]]
						
			hyperlinkBtn   = CreateLabel("[待]"..sUserName,CGRectMake(0, 0, sizeview.w , sizeview.h),12,NameColor.GREEN);

		else
			 --[[hyperlinkBtn	= CreateHyperlinkButton("[待]"..sUserName, 
						CGRectMake(0, 0, sizeview.w , sizeview.h),
						12,
						NameColor.YELLOW);	--]]
			hyperlinkBtn   = CreateLabel("[待]"..sUserName,CGRectMake(0, 0, sizeview.w , sizeview.h),12,NameColor.YELLOW);									
		end		
		--]]
		
		

		
		
			
		if not hyperlinkBtn then
			container:RemoveViewById(tPlayerList[nIndex][4]);
		else
		
			hyperlinkBtn:SetTag(tPlayerList[nIndex][4]*100);
			--hyperlinkBtn:SetLuaDelegate((p.OnCampListcontainerUIEventLinkBtn));
			--hyperlinkBtn:EnableLine(false);	
			view:AddChildZ(hyperlinkBtn,2);
		end
	end
	
end



function p.ChangeColorByIndex(nIndex,Color)
--
	if  tPlayerList[nIndex] == nil then
		return false;
	end
	
	local sState = ""
	if Color == NameColor.YELLOW then
		sState = "[待]"
	else	
		sState = "[战]"
	end
	
	local attContainer = p.GetAttContainer();
	local defContainer = p.GetDefContainer();	
	if not attContainer or not defContainer then
		return;
	end	
	
	local view = nil;
	if tPlayerList[nIndex][2] == 1 then
		view = attContainer:GetViewById(tPlayerList[nIndex][4]);
	else
		view = defContainer:GetViewById(tPlayerList[nIndex][4]);
	end
	
	
	
	--local btn = RecursiveHyperBtn(view, {9999});	
	
	local sizeview		= view:GetFrameRect().size;
	
	--[[
	--去除原来的文字按钮
	view:RemoveChildByTag(tPlayerList[nIndex][4]*100, true);
	
	local hyperlinkBtn = nil;
	hyperlinkBtn	= CreateHyperlinkButton(sState..tPlayerList[nIndex][1], 
					CGRectMake(0, 0, sizeview.w , sizeview.h),
					12,
					Color);										

	hyperlinkBtn:SetTag(tPlayerList[nIndex][4]*100);
	--hyperlinkBtn:SetLuaDelegate((p.OnCampListcontainerUIEventLinkBtn));
	hyperlinkBtn:EnableLine(false);	
	view:AddChildZ(hyperlinkBtn,2);
	
	--]]

	local hyperlinkBtn = RecursiveLabel(view, {tPlayerList[nIndex][4]*100});	
	hyperlinkBtn:SetFontColor(Color);
	hyperlinkBtn:SetText(sState..tPlayerList[nIndex][1]);
	
	--LogInfo("qboy1 ENTER hyperlinkBtn NAME:"..tPlayerList[nIndex][1]);
	--btn:SetLinkTextColor(NameColor.RED);
end

--================================战报统计====================================----

--[[
        report.idWin = netdata:ReadInt()
        report.idLose = netdata:ReadInt()
        report.winnerWinCount = netdata:ReadShort()
        report.loserWinCount = netdata:ReadShort()
        report.Winname = netdata:ReadUnicodeString();
        report.Losename = netdata:ReadUnicodeString();
]]


function p.AddMainReport(report)
	local nIdWin = report.idWin
	local nIdLost = report.idLose
	local nWinCombo = report.winnerWinCount
	local nLoseCombo = report.loserWinCount
	local sWinName = report.Winname
	local sLostName = report.Losename
	tMainReport[nMainReportHead] ={nIdWin,nIdLost,nMoney,nRepute,nWinCombo,nLoseCombo}
	
	local str = "";
	local wincolor = nil;
	local losecolor = nil;
	if tBattleResult[nIdWin][4] == 1 then
		wincolor = "32abb3";
		losecolor = "b6440c";
	else
		wincolor = "b6440c";
		losecolor = "32abb3";	
	end
	
	
	if nIdWin == nIdLost then
		str = "<c"..wincolor.."【"..sWinName.."】此回合轮空,"
	else
		str = "<c"..wincolor.."【"..sWinName.."】/e击败了".."<c"..losecolor.."【"..sLostName.."】/e,"
	end
	
	
	
	if nWinCombo > 0 then
		str = str.."取得了"..nWinCombo.."<cfefc2a".."连胜,/e"
	end
	
	if nLoseCombo > 0 then
		str = str.."终结了<c"..losecolor.."【"..sLostName.."】/e的<cfefc2a"..nLoseCombo.."/e连胜,"
	end
	
	
	nMainReportHead = nMainReportHead + 1;
	if nMainReportHead - nMainReportBottom >= 10 then
		p.DelChatTextMain(nMainReportBottom);
		nMainReportBottom = nMainReportBottom + 1;	
	end
	
	p.AddChatTextMain(nMainReportHead,str);
	
	
	--战况统计
	p.UpdateBattleResult(nIdWin,nWinCombo,sWinName);
	if nIdWin ~= nIdLost then
		tBattleResult[nIdLost][3] = tBattleResult[nIdLost][3] + 1;
	end
end


function p.UpdateBattleResult(nUserId,nWinCount,sWinName)
	tBattleResult[nUserId][1] = nWinCount
	tBattleResult[nUserId][2] = sWinName
end

function p.RefreshBattleResult()
	
	local layer=p.GetParent();
	if nil==layer then
		return;
	end
	local resultlayer =  p.GetResultLayer();
	--local scrollResultReport = GetScrollViewContainer(resultlayer,2);
							  -- GetScrollViewContainer(Resultlayer, 2);	
	if CheckP(resultlayer) == false then
		LogInfo("qboy RefreshBattleResult resultlayer nil"); 
	else
		LogInfo("qboy RefreshBattleResult resultlayer true"); 
	end
	
	if CheckP(scrollResultReport) == false then
		LogInfo("qboy RefreshBattleResult scrollResultReport nil");
	
		return;
	else
		LogInfo("qboy RefreshBattleResult scrollResultReport true");
	
	end
	
	scrollResultReport:RemoveAllView();
	

		
	--按照赢的次数排行
	local tmp = {}
	local index = 1;
	for i,v in pairs(tBattleResult) do
		tmp[index] = {v[1],v[2],v[3],v[4],i};
		index = index +1;  
	end
	
	if #tmp >1 then
		for i=1,#tmp-1 do
			for j = 1, #tmp-i do
					if tmp[j][1]	 < tmp[j+1][1] then
						tmp[j],tmp[j+1] = tmp[j+1],tmp[j]
					end	
			end
		end	
	end	
	

	for i,v in pairs(tmp) do
		--LogInfo("qboy RefreshBattleResult nUserId"..nUserId);
					
		local nUserId = v[5];			
		local view = createUIScrollView();
		
		if view ~= nil then
			view:Init(false);
			view:SetViewId(nUserId);
			
			
			
			local uiLoad = createNDUILoad();
       		 if nil == uiLoad then
           		 return false;
       		 end
       		uiLoad:Load("ArmyGroupBattle/ArmyGroupBattle_L_2_L.ini", view, nil, 0, 0);
        	scrollResultReport:AddView(view);
			
			local sizeview		= view:GetFrameRect().size;
			
			
			local str = "";
			
			
			local pLabelName = RecursiveLabel(view, {3});
			local pLabelWinCount = RecursiveLabel(view, {4});
			local pLabelLoseCount = RecursiveLabel(view, {5});
			
			--LogInfo("qboy RefreshBattleResult sizeview"..sizeview.w.." "..sizeview.h);
			
			pLabelName:SetText(""..v[2]);
			pLabelWinCount:SetText(""..v[1]);
			pLabelLoseCount:SetText(""..v[3]);
			
			if v[4] == 1 then
				pLabelName:SetFontColor(NameColor.ATTLIST);	
				pLabelWinCount:SetFontColor(NameColor.ATTLIST);	
				pLabelLoseCount:SetFontColor(NameColor.ATTLIST);	
			else
				pLabelName:SetFontColor(NameColor.DEFLIST);
				pLabelWinCount:SetFontColor(NameColor.DEFLIST);	
				pLabelLoseCount:SetFontColor(NameColor.DEFLIST);
			end
		end
	end	
end



function p.DelChatTextMain(nIndex)
	if nil == scrollMainReport then
		return false;
	end
	
	scrollMainReport:RemoveViewById(nIndex);	
end



function p.AddChatTextMain(nIndex,str)
	local layer=p.GetParent();
	if nil==layer then
		return false;
	end
	if nil == scrollMainReport then
		return false;
	end
	
	local rectview		= scrollMainReport:GetFrameRect();
	local nWidthLimit = rectview.size.w*0.9;

	local view = createUIScrollView();
	if view ~= nil then
		view:Init(false);
		view:SetViewId(nIndex);

		scrollMainReport:AddView(view);
		local sizeview		= view:GetFrameRect().size;
		
		local pLabelTips = _G.CreateColorLabel( str, 11, nWidthLimit );
		pLabelTips:SetFrameRect(CGRectMake(0, 0, nWidthLimit, 20 * ScaleFactor));
		view:AddChild(pLabelTips);
		--scrollMainReport:ShowViewById(nIndex  );
		--
		if nMainReportHead - nMainReportBottom >= MAX_REPORT_NUM_PER_PAGE then
			scrollMainReport:ShowViewById(nIndex - MAX_REPORT_NUM_PER_PAGE+1  );	
		else
			scrollMainReport:ShowViewById(nMainReportBottom+1);	
		end--
	end
	
	return true;
end







--===============================xxxxxxxx====================================----

local TipTxt ={
"战斗规则:",
"1.军团战分为8强赛、4强赛、半决赛和决","赛，一共4轮",
"",
"2.每轮战斗开始，军团成员自行点击【参","加战斗】进入等待队列，1分30秒等待时","间过后，系统将开始配对战斗（未进入","等待界面的成员将无法参加战斗）",
"",
"3.配对战对手由系统随机分配",
"",
"4.战斗胜利者获得胜利奖励，连胜次数+1","，不回复HP，继续等待系统匹配（轮空","不记录连胜）",
"",
"5.战斗失败者获得战败奖励，退出战斗队","列，等待比赛结束",
"",
"6.连胜5场的军团成员、被击败的军团成员","将退出战斗队列 (中途掉线的玩家视为被","击败)",
"",
}
--[[


1.军团战分为8强赛、4强赛、半决赛和决赛，一共4轮
2.每轮战斗开始，军团成员自行点击【参加战斗】进入等待队列，1分30秒等待时间过后，系统将开始配对战斗（未进入等待界面的成员将无法参加战斗）
3.配对战对手由系统随机分配
4.战斗胜利者获得胜利奖励，连胜次数+1，不回复HP，继续等待系统匹配（轮空不记录连胜）
5.战斗失败者获得战败奖励，退出战斗队列，等待比赛结束
6.连胜5场的军团成员、被击败的军团成员将退出战斗队列 (中途掉线的玩家视为被击败)
]]

local Tiptag = 9998;
--显示提示信息
function p.ShowTip()

  	local bglayer=p.GetParent();
    
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(Tiptag);
	layer:SetFrameRect(RectFullScreenUILayer);
	bglayer:AddChildZ(layer,2);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("scuffle/scuffle_L_3.ini", layer, p.OnUIEventTip, 0, 0);
	local titlelabel = RecursiveLabel(layer, {3});
	titlelabel:SetText("军团战规则");
	
	----------------------------容器---------------------------------------
	local rectX = winsize.w*0.25;
	local rectW	= winsize.w*0.52;
	local rect  = CGRectMake(rectX, winsize.h*0.15, rectW, winsize.h*0.75); 
	

	tipcontainer = createUIScrollViewContainer();
	if tipcontainer == nil then
		LogInfo("tipcontainer == nil,load ui failed!");
		return;
	end
	tipcontainer:Init();
	tipcontainer:SetFrameRect(rect);
	layer:AddChild(tipcontainer);
	
	local rectview = tipcontainer:GetFrameRect();
	tipcontainer:SetStyle(UIScrollStyle.Verical);
	tipcontainer:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 10));
	tipcontainer:EnableScrollBar(true);
	
	
	
	local rectview		= tipcontainer:GetFrameRect();
	local nWidthLimit = rectview.size.w;
	
	for nIndex=1,#TipTxt do
	
		local view = createUIScrollView();

		if view ~= nil then
			view:Init(false);
			view:SetViewId(nIndex);
		
			tipcontainer:AddView(view);
			local sizeview		= view:GetFrameRect().size;
			local str = "";
			local pLabelTips = nil;
			local pLabelScore = nil;
			
			
		  	pLabelTips = _G.CreateColorLabel( TipTxt[nIndex], 13, nWidthLimit );
			pLabelTips:SetFrameRect(CGRectMake(0, 0, nWidthLimit, 20 * ScaleFactor));
	
			view:AddChild(pLabelTips);

		end
	end	
end







--===============================排行榜====================================----

function p.AddPlayerToScoreBoard(sName,nId,nScore)
	tRankBoardScore[#tRankBoardScore+1] = {sName,nId,nScore}
end

function p.AddPlayerToStreakBoard(sName,nId,nScore)
	LogInfo("qboy1 AddPlayerToStreakBoard "..nId.." "..sName);
	tRankBoardStreak[#tRankBoardStreak+1] = {sName,nId,nScore}
end

function p.ResetBoardTable()
	tRankBoardScore = {};
	tRankBoardStreak = {};
end

function p.RefreshBoard()
	if rankboardscore == nil or rankboardstreak == nil then
		return;
	end
	
	if CheckP(rankboardscore) == false or CheckP(rankboardstreak) == false then
		return;
	end
	
	rankboardscore:RemoveAllView();
	rankboardstreak:RemoveAllView();
	
	local rectview		= rankboardscore:GetFrameRect();
	local nWidthLimit = rectview.size.w;
	
	for nIndex=0,#tRankBoardScore do
		local view = createUIScrollView();

		if view ~= nil then
			view:Init(false);
			view:SetViewId(nIndex);
		
			
			--初始化ui
       		 local uiLoad = createNDUILoad();
       		 if nil == uiLoad then
           		 return false;
       		 end
			uiLoad:Load("scuffle/scuffle_L_2_L.ini", view, nil, 0, 0);
        	
			rankboardscore:AddView(view);
			
			local sizeview		= view:GetFrameRect().size;
			local str = "";
			local pLabelRank = RecursiveLabel(view, {3});
			local pLabelName = RecursiveLabel(view, {4});
			local pLabelScore = RecursiveLabel(view, {5});
			
			
			if nIndex == 0 then
				local i = 1;
			else
				pLabelRank:SetText(""..nIndex);
				pLabelName:SetText(""..tRankBoardScore[nIndex][1]);
				pLabelScore:SetText(""..tRankBoardScore[nIndex][3]);

			end
			
		end
	end
	
	--local rectview		= rankboardstreak:GetFrameRect();

	for nIndex=0,#tRankBoardStreak do
		--LogInfo("qboy1 tRankBoardStreak "..tRankBoardStreak[nIndex][1]);
		local view = createUIScrollView();

		if view ~= nil then
			view:Init(false);
			view:SetViewId(nIndex);
		
			--初始化ui
       		 local uiLoad = createNDUILoad();
       		 if nil == uiLoad then
           		 return false;
       		 end
			uiLoad:Load("scuffle/scuffle_L_2_L.ini", view, nil, 0, 0);
		
			rankboardstreak:AddView(view);
			local sizeview		= view:GetFrameRect().size;
			
			local str = "";
			local pLabelRank = RecursiveLabel(view, {3});
			local pLabelName = RecursiveLabel(view, {4});
			local pLabelScore = RecursiveLabel(view, {5});

			if nIndex == 0 then
				pLabelScore:SetText("连胜");
			else
				pLabelRank:SetText(""..nIndex);
				pLabelName:SetText(""..tRankBoardStreak[nIndex][1]);
				pLabelScore:SetText(""..tRankBoardStreak[nIndex][3]);
			end			
		end
	end	
	--]]
	
	
end



--============================xxxxxxxx====================================----

function p.GetBattleEndCDLabel()
	local layer = p.GetParent();
	local label = RecursiveLabel(layer, {ID_ARMYGROUPBATTLE_CTRL_TEXT_72});
	return label;
end

function p.GetDescLabel()
	local layer = p.GetParent();
	local label = RecursiveLabel(layer, {ID_ARMYGROUPBATTLE_CTRL_TEXT_73});
	return label;
end




function p.GetCDLabel()
	local layer = p.GetParent();
	local btn = RecursiveButton(layer, {19});
	return btn;
end

	
-----------------------------获取父层layer---------------------------------
function p.GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.SyndicateBattleUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

-----------------------------获取进攻列表---------------------------------
function p.GetAttContainer()
	local layer = p.GetParent();
	local container = GetScrollViewContainer(layer, ID_ARMYGROUPBATTLE_CTRL_LIST_ATTACK);  	
	return container;
end

-----------------------------获取防守列表---------------------------------
function p.GetDefContainer()
	local layer = p.GetParent();
	local container = GetScrollViewContainer(layer, ID_ARMYGROUPBATTLE_CTRL_LIST_DEFENCE);  	
	return container;
end

-----------------------------获取战报统计容器-----------------------------
function p.GetMainReportContainer()
	return scrollMainReport;
end


--退出战斗
function p.QuitBattle()
	MsgSyndicateBattle.Leave();
end

--参加战斗
function p.JoinBattle()
	if  p.ActivityState ~= 3 then
		MsgSyndicateBattle.SendSyndicateBattleSignUpAction();
	end
end

--检测是否在战斗列表
function p.IfIsInBattle()
	local nPlayerid = GetPlayerId();
	for i =g_nPlayerListBottom ,g_nPlayerListHead  do
		if tPlayerList[i] ~= nil then
			if tPlayerList[i][4] == nPlayerid then
				return true;
			end
		end	
	end
	return false;
end

--检测玩家是否在enter 列表
function p.IfReadyForBattle()
	local nPlayerid = GetPlayerId();
	for i =g_nPlayerListBottom ,g_nPlayerListHead  do
		if tPlayerList[i] ~= nil then
			if tPlayerList[i][4] == nPlayerid then
				if tPlayerList[i][3] == 1 then
					return true;
				else
					return false;	
				end
			end
		end	
	end
	return false;
end


function p.OnUIEventTip(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    	if 533 == tag then  
    		local layer = p.GetParent();          	
			layer:RemoveChildByTag(9998, true);
			return true;
    	end
	end
end

function p.CloseUI()
	--if p.ActivityState == 3 then
		--CloseUI(NMAINSCENECHILDTAG.SyndicateBattleUI);	
		--return;
	--end
	LogInfo("qboyCloseUI");
	
	--CloseUI(NMAINSCENECHILDTAG.SyndicateBattleUI);
	
	--
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleResultUI) then
		if IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleUI) then
			CloseUI(NMAINSCENECHILDTAG.SyndicateBattleUI);
		end	
		SyndicateBattleResultUI.LoadUI();
	end--]]
end
	
	
--设置选定状态
function p.SetButtonChecked(uiNode)
	local layer = p.GetParent(); 
	
	--local btn1 = GetButton( layer, ID_ARMYGROUPBATTLE_CTRL_BUTTON_50 );  
	local btn2 = GetButton( layer, ID_ARMYGROUPBATTLE_CTRL_BUTTON_51 );  
	--local btn3 = GetButton( layer, ID_ARMYGROUPBATTLE_CTRL_BUTTON_52 );  
	local btn4 = GetButton( layer, 100 );  
	
	--btn1:SetChecked( false );
	btn2:SetChecked( false );
	--btn3:SetChecked( false );	
	btn4:SetChecked( false );	
	
	local btn = ConverToButton(uiNode);
	btn:SetChecked( true );
end			

function p.CloseSyndicateBattleUI(nId, param)
	--[[进入战斗时禁止退出
	if p.IfReadyForBattle() then
		CommonDlgNew.ShowYesDlg("战斗中无法退出！");
		return;
	end
--]]
    if ( CommonDlgNew.BtnOk == nId ) then
		p.QuitBattle();
		p.CloseUI();
	end
end



-----------------------------背景层事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEvent hit tag = %d", tag);
    --
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        p.CloseInfoLayer();
        --关闭按钮      
        if ID_ARMYGROUPBATTLE_CTRL_BUTTON_26 == tag then    
                    
			
			if  p.bIfComplete == false and SyndicateBattleResultUI.GetEnterEndTime() <= 0 then
				CommonDlgNew.ShowYesOrNoDlg("退出后将会无法再次加入这场战斗，确定退出吗？", p.CloseSyndicateBattleUI, true );			
			else
				p.QuitBattle();
				p.CloseUI();			
			end
			
			
			return true;
		--参战/退出	
		elseif tag == ID_ARMYGROUPBATTLE_CTRL_BUTTON_BATTLE then
			if  p.ActivityState == 3 then
				CommonDlgNew.ShowYesDlg("您已退出，请重新打开界面！");
				return;
			end

			if p.IfIsInBattle() then
				LogInfo("qboy 已经在战斗中");
			else
				LogInfo("qboy sign up战斗 ");
				--cd未冷却
				if g_Count > 0 then
					CommonDlgNew.ShowYesOrNoDlg( "是否花费2金币清除冷却时间", p.ClearCDTime, true );
					return true;
				end
				
				
				p.JoinBattle();
			end
			return true;
		--银币鼓舞
		elseif tag == ID_ARMYGROUPBATTLE_CTRL_BUTTON_INSPIRE1 then
			MsgSyndicateBattle.SendSyndicateBattleSilverEncourageAction();
			return true;
		--金币鼓舞	
		elseif tag == ID_ARMYGROUPBATTLE_CTRL_BUTTON_INSPIRE2 then
			MsgSyndicateBattle.SendSyndicateBattleGoldEncourageAction();
			return true;
		elseif tag == ID_ARMYGROUPBATTLE_CTRL_BUTTON_51 then
			scrollMainReport:SetVisible(true);
			local resultlayer =  p.GetResultLayer();
			resultlayer:SetVisible(false);
			scrollResultReport:SetVisible(false);
			p.SetButtonChecked(uiNode);
		elseif tag == 100 then
			--MsgSyndicateBattle.SendSyndicateBattleGetRankAction(); 
			scrollMainReport:SetVisible(false);
			scrollResultReport:SetVisible(true);
			local resultlayer =  p.GetResultLayer();
			resultlayer:SetVisible(true);
			p.SetButtonChecked(uiNode);	
        elseif tag == 70 then
        	p.ShowTip();
        	
		elseif tag == 158 then
			p.CloseInfoLayer();        	
        end
        
    elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
    	 p.CloseInfoLayer();
         if tag == ID_ARMYGROUPBATTLE_CTRL_CHECK_BUTTON_31 then          --自动战斗
            local pCheckAuto = ConverToCheckBox( uiNode );
            if pCheckAuto:IsSelect() then
            	LogInfo("qboy check1 ");
                if p.IfIsInBattle() == false then
					p.JoinBattle();
				end	
            end
            return true;
        end       
           
    end
    --]]
	return true;
end



--阵营列表按钮点击事件
function p.OnCampListcontainerUIEvent(uiNode, uiEventType, param)
	local nUserId = uiNode:GetTag();
    --LogInfo("qboy p.OnCampListcontainerUIEvent hit tag = %d", nIndex);
	
    --LogInfo("qboy p.OnCampListcontainerUIEvent hit tag = %d", nIndex);
	local nPlayerid = GetPlayerId();
	local sName = tPlayerName[nUserId];
	
	if nUserId == nPlayerid then
		return true;
	else
		p.OpenInfoList(nUserId,sName);
		return true;
	end
	
end

--阵营列表link文字按钮点击事件
function p.OnCampListcontainerUIEventLinkBtn(uiNode, uiEventType, param)
	
	local nUserId = uiNode:GetTag()/100;
    --LogInfo("qboy p.OnCampListcontainerUIEvent hit tag = %d", nIndex);
	local nPlayerid = GetPlayerId();
	local sName = tPlayerName[nUserId];
	
	if nUserId == nPlayerid then
		return true;
	else
		p.OpenInfoList(nUserId,sName);
		return true;
	end
	
end


--===========================玩家信息层===========================-
local TAG_INFO = 12345;
local nCheckPlayerId = 0;
local sCheckPlayerName = "";
local ID_TALK_LIST_CTRL_BUTTON_10 = 10;
local ID_TALK_LIST_CTRL_BUTTON_11 = 11;
local ID_TALK_LIST_CTRL_BUTTON_12 = 12;

function p.OnUIEventInfoList(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventInfoList[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
		if tag == ID_TALK_LIST_CTRL_BUTTON_10 then
			--私聊
			--p.CloseChatUI();
			ChatMainUI.LoadUIbyFriendName(sCheckPlayerName);
			
		elseif tag == ID_TALK_LIST_CTRL_BUTTON_11 then
			--查看资料
			--CheckOtherPlayerBtn.LoadUI(nCheckPlayerId);
			MsgFriend.SendFriendSel(nCheckPlayerId,sCheckPlayerName);
		elseif tag == ID_TALK_LIST_CTRL_BUTTON_12 then
			--加好友
			if FriendFunc.IsExistFriend(nCheckPlayerId)  then
				CommonDlgNew.ShowYesDlg("该玩家已经是您的好友！");
			else
				FriendFunc.AddFriend(nCheckPlayerId,sCheckPlayerName); --加为好友 
			end
		end
				
		p.CloseInfoLayer();
		return true;
	end
end

function p.OpenInfoList(nUserId,sUserName)
	 nCheckPlayerId = nUserId;
	 sCheckPlayerName = sUserName;	
	local bglayer = p.GetParent();
	
	
	--关闭之前界面
	bglayer:RemoveChildByTag(TAG_INFO,true);

	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("OpenInfoList layer= nil");
		return  false;
	end

	layer:Init();
	layer:SetTag(TAG_INFO);

	layer:SetFrameRect(CGRectMake(400, 230, 160, 180));

	bglayer:AddChildZ(layer,2);

	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("OpenInfoList uiLoad = nil,4");
		return false;
	end
	
	uiLoad:Load("talk/talk_list.ini",layer,p.OnUIEventInfoList,0,0);
	uiLoad:Free();
end

function p.CloseInfoLayer()
	local bglayer = p.GetParent();	
	bglayer:RemoveChildByTag(TAG_INFO,true);
end

function p.ClearCDTime(nId, param)
    if ( CommonDlgNew.BtnOk == nId ) then
		local nPlayerId = GetPlayerId();
    	local emoney = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);           
               
    	if emoney < 2 then
			CommonDlgNew.ShowYesDlg("抱歉，您的金币不足！");
			return;
		end
	
		MsgSyndicateBattle.SendSyndicateBattleResetCDAction();
	end	
end

--设置下一场自动参加（获胜玩家调用）
			
--[[		local tState = {
	InBattle = 1;
	WINOutBattle = 2;
	LOSEOutBattle = 3;
}
--]]	
p.bIfComplete = false;

function p.AutoJoinNextBattle()
	LogInfo("qboy setbattle out AutoJoinNextBattle");
	
	bIfAutoJoinNextBattle = tState.WINOutBattle;

	if p.TimerTag ~= nil then
		LogInfo("qboy UnRegisterTimer2 :"); 
		UnRegisterTimer(p.TimerTag);
		p.TimerTag = nil;
	end
	
	
	p.TimerTag=RegisterTimer(p.TimerTick,1, "SyndicateBattleUI.TimerTick");
	LogInfo("qboy RegisterTimer TimerTick"..p.TimerTag); 
	
end

--[[
	if bIfAutoJoinNextBattle == tState.InBattle   then
		CommonDlgNew.ShowYesDlg("已退出，战斗结束后请关闭活动界面！");
		--设置战斗后关闭
	end	
]]

function p.FailInBattle()
	LogInfo("qboy setbattle out FailInBattle");
	
	bIfAutoJoinNextBattle = tState.LOSEOutBattle;
	--MsgSyndicateBattle.BattleEnd();
	
	if p.TimerTag ~= nil then
		LogInfo("qboy UnRegisterTimer2 :"); 
		UnRegisterTimer(p.TimerTag);
		p.TimerTag = nil;
	end
		
	p.TimerTag=RegisterTimer(p.TimerTick,1, "SyndicateBattleUI.TimerTick");
end


function p.SetBattle()
	LogInfo("qboy SetBattle "); 
	bIfAutoJoinNextBattle = tState.InBattle;
end


function  p.CompleteBattle()
	p.bIfComplete = true;
	if bIfAutoJoinNextBattle ~= tState.InBattle then
		LogInfo("qboy CompleteBattle close ui"); 
		p.CloseUI();
	end	
end



function p.SetArmyName(attArmyName,defArmyName)
	g_AttArmyName = attArmyName;
	g_DefArmyName = defArmyName;
end




