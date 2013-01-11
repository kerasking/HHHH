---------------------------------------------------
--描述: 军团战报名界面
--时间: 2012.10.24
--作者: qbw
---------------------------------------------------
SyndicateBattleSignUpUI = {}
local p = SyndicateBattleSignUpUI;


local ID_ARMYGROUPBATTLEAPPLY_CTRL_LIST_180						= 180;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_120						= 120;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_44						= 44;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_43						= 43;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_33						= 34;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_31						= 32;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_30						= 30;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_BUTTON_26					= 27;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_BUTTON_BATTLE				= 19;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_HURT					= 8;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_NAME					= 7;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_RANKING					= 6;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_TEXT_TITLE					= 3;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_89					= 89;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_88					= 88;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_87					= 87;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_86					= 86;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_85					= 85;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_84					= 84;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_83					= 83;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_82					= 82;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_81					= 81;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_79					= 79;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_78					= 78;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_77					= 77;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_76					= 76;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_75					= 75;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_74					= 74;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_73					= 73;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_72					= 72;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_71					= 71;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_69					= 69;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_68					= 68;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_67					= 67;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_66					= 66;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_65					= 65;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_64					= 64;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_63					= 63;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_62					= 62;
local ID_ARMYGROUPBATTLEAPPLY_CTRL_PICTURE_61					= 61;


local winsize	= GetWinSize();


--[INDEX] ={玩家名字,玩家阵营(1 攻击,2 防御),玩家是否入场(1是 0否),玩家id}
local signUpList ={}

local MAX_ARMY_NUM_PER_PAGE = 8;


local NameColor = {
	ATTLIST = ccc4(0,198,213,255),
	GREEN = ccc4(28,237,93,255),      --绿色
	YELLOW = ccc4(255, 255, 0, 255),
	DEFLIST = ccc4(248,66,0,255),
}

local g_Count = 0;
local g_ArmyLev = 0;

--重置所有数据
function p.ResetAllData()
	signUpList ={}
	g_ArmyLev= 0;
end



--加载主界面
function p.LoadUI(signUpList,nLeftTime,nArmyGroupLev)
	--SyndicateBattleUI.LoadUI();
--
	p.ResetAllData();
	g_ArmyLev = nArmyGroupLev;
	if IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleSignUpUI) then
		p.refreshArmylist(signUpList);--刷新军团列表
		p.updateSignUpEndCount(nLeftTime);
    	return true;	
	end
	
    --------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
     local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.SyndicateBattleSignUpUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.ActivityLayer);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("ArmyGroupBattle/ArmyGroupBattleApply.ini", layer, p.OnUIEvent, 0, 0);

	
	--初始化列表
	local ArmyContainer = p.GetArmyContainer();
	if ArmyContainer then
			local rectview = ArmyContainer:GetFrameRect();
			if nil ~= rectview then
				local nWidth	= rectview.size.w*1.2;
				local nHeight	= rectview.size.h / MAX_ARMY_NUM_PER_PAGE;
				ArmyContainer:SetStyle(UIScrollStyle.Verical);
				ArmyContainer:SetViewSize(CGSizeMake(nWidth, nHeight));
				ArmyContainer:SetTopReserveDistance(rectview.size.h);
				ArmyContainer:SetBottomReserveDistance(rectview.size.h);
				ArmyContainer:EnableScrollBar(true);
			end
	end

	p.refreshArmylist(signUpList);--刷新军团列表
	
	p.ShowTip();
	p.updateSignUpEndCount(nLeftTime);
    return true;
   --]] 
end







--刷新军团列表
function p.refreshArmylist(signUpList)
	LogInfo("qboy refreshArmylist signUpList N"..table.getn(signUpList));
	local ArmyContainer = p.GetArmyContainer();
	
	if not ArmyContainer then
		return;
	end

	ArmyContainer:RemoveAllView();

	local tTmpList ={}
	
	
	
	--排序
	for i=1,#signUpList-1 do
		for j = 1, #signUpList-i do
				if signUpList[j].contribute	 < signUpList[j+1].contribute then
					signUpList[j],signUpList[j+1] = signUpList[j+1],signUpList[j]
				end			
		end
	end
	
	local nUserID		= GetPlayerId();
	local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	
	--先加入未入场玩家
	for i ,v in pairs(signUpList) do
		p.AddArmy(ArmyContainer, v);	
		if v.id == nAGID then
			
			local layer = p.GetParent();
			local btn = RecursiveButton(layer, {19});
			btn:SetChecked( true );
			btn:SetTitle(GetTxtPri("SYN_D20"));	
		end		
	end	
	
	
	
end





	--[[
		signUp.id = netdata:ReadInt()
        signUp.level = netdata:ReadShort()
        signUp.contribute = netdata:ReadInt()
        signUp.name = netdata:ReadUnicodeString()
    --]]
    
--向列表增加玩家
function p.AddArmy(container, cell)
	--LogInfo("qboy AddArmy nUserId:"..nUserId);	
	
	if not CheckP(container) or not cell == nil then
		LogInfo("qboy AddArmy container or cell nil");
		return;
	end

	local sArmyName = cell.name;
	if "" == sArmyName then
		LogInfo("qboy AddArmy sArmyName nil");
		sArmyName = GetTxtPri("SYN_D21"); --return;
	end

		
	local pool = DefaultPicPool();
	

	local view = createUIScrollView();
	if view ~= nil then
		view:Init(false);
		view:SetViewId(cell.id );
		
		
		--初始化ui
       	 local uiLoad = createNDUILoad();
       	 if nil == uiLoad then
        	 return false;
       	 end
		uiLoad:Load("ArmyGroupBattle/ArmyGroupBattleApply_L.ini", view, nil, 0, 0);
		
		local sizeview		= view:GetFrameRect().size;
		local str = "";
		local pLabelName = RecursiveLabel(view, {3});
		local pLabelLev = RecursiveLabel(view, {4});
		local pLabelGX = RecursiveLabel(view, {5});

		pLabelName:SetText(""..sArmyName);
		pLabelLev:SetText(""..cell.level);
		pLabelGX:SetText(""..cell.contribute);	
				
		--[[增加个背景按钮
		local bgBtn = createNDUIButton();
		bgBtn:Init();
		bgBtn:SetTag(cell.id );
		local sizeview = view:GetFrameRect().size;
		local width = container:GetFrameRect().size.w*0.9
		local Height = width*0.16;
		bgBtn:SetFrameRect(CGRectMake(-width*0.2, 0, width*2 , Height*2));
		view:AddChildZ(bgBtn,1);
		--bgBtn:SetLuaDelegate((p.OnCampListcontainerUIEvent));
		bgBtn:CloseFrame();
		--]]
		
		container:AddView(view);
		
		--[[
		local sizeview		= view:GetFrameRect().size;
	
		local hyperlinkBtn = nil;
			
		hyperlinkBtn   = CreateLabel(sArmyName,CGRectMake(0, 0, sizeview.w , sizeview.h),12,NameColor.YELLOW);		
			
		if not hyperlinkBtn then
			container:RemoveViewById(cell.id);
		else
		
			hyperlinkBtn:SetTag(cell.id*100);
			view:AddChildZ(hyperlinkBtn,2);
		end
		--]]
	end
end










--===============================xxxxxxxx====================================----

local TipTxt ={
GetTxtPri("SYN_D1"), 
GetTxtPri("SYN_D2"), 
GetTxtPri("SYN_D3"), 
GetTxtPri("SYN_D4"),
GetTxtPri("SYN_D_NULL"),
GetTxtPri("SYN_D5"),
GetTxtPri("SYN_D6"),
GetTxtPri("SYN_D7"),
GetTxtPri("SYN_D_NULL"),
GetTxtPri("SYN_D8"),
GetTxtPri("SYN_D9"),
GetTxtPri("SYN_D_NULL"),
GetTxtPri("SYN_D10"),
GetTxtPri("SYN_D11"),
GetTxtPri("SYN_D_NULL"),
GetTxtPri("SYN_D12"),
GetTxtPri("SYN_D_NULL"),
GetTxtPri("SYN_D13"),
GetTxtPri("SYN_D14"),
GetTxtPri("SYN_D_NULL"),
GetTxtPri("SYN_D15"),
GetTxtPri("SYN_D16"),
GetTxtPri("SYN_D_NULL"),
GetTxtPri("SYN_D17"),
GetTxtPri("SYN_D18"),
GetTxtPri("SYN_D19"),
GetTxtPri("SYN_D_NULL"),
}

--[[     
1.军团战每周六22:00开战，需要玩家所在军团等级达到3级
	2.报名时间为每周日0:00至周六21:00，   由军团长或副军团长进行报名（报名者需缴纳20W银币报名费用)
3.本周累计贡献前16的军团可以晋级军团战
4.军团战开战后需要玩家在军团战界面点击【参加战斗】进入战斗队列

战斗奖励:
1.每轮战斗结束,战胜方/战败方都可以获得相应的声望,银币奖励
2.玩家每击杀一名对方成员可以获得声望,银币奖励
3.决出冠亚军后，奖励将发至对应军团的战利品仓库，军团长可以通过战利品分配功能将战利品分配给军团成员
]]

local Tiptag = 9998;
--显示提示信息
function p.ShowTip()

  	local bglayer=p.GetParent();

	
	
	----------------------------容器---------------------------------------
	local rectX = winsize.w*0.05;
	local rectW	= winsize.w*0.43;
	local rect  = CGRectMake(rectX, winsize.h*0.28, rectW, winsize.h*0.55); 
	

	tipcontainer = createUIScrollViewContainer();
	if tipcontainer == nil then
		LogInfo("tipcontainer == nil,load ui failed!");
		return;
	end
	tipcontainer:Init();
	tipcontainer:SetFrameRect(rect);
	bglayer:AddChild(tipcontainer);
	
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
			
			LogInfo("tzq  tag1111");
			
			--[[
		  	pLabelTips = _G.CreateColorLabel( TipTxt[nIndex], 11, nWidthLimit );
			pLabelTips:SetFrameRect(CGRectMake(0, 0, nWidthLimit, 20 * ScaleFactor));
			]]
			pLabelTips = _G.CreateLabel( TipTxt[nIndex], CGRectMake(0, 0, nWidthLimit, 20 * ScaleFactor), 11, ccc4(255,255,255,255) );
			
			view:AddChild(pLabelTips);

		end
	end	
end


	
-----------------------------获取父层layer---------------------------------
function p.GetParent()

	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.SyndicateBattleSignUpUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end


-----------------------------获取军团列表---------------------------------
function p.GetArmyContainer()
	local layer = p.GetParent();
	local container = GetScrollViewContainer(layer, ID_ARMYGROUPBATTLEAPPLY_CTRL_LIST_180);  	
	return container;
end



function p.CloseUI()
	if p.ActivityState == 3 then
		CloseUI(NMAINSCENECHILDTAG.SyndicateBattleSignUpUI);	
		return;
	end

	if bIfAutoJoinNextBattle == tState.InBattle   then
		CommonDlgNew.ShowYesDlg(GetTxtPri("SYN_D22"));
	else
		CloseUI(NMAINSCENECHILDTAG.SyndicateBattleSignUpUI);		
	end
end



-----------------------------背景层事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)

    local tag = uiNode:GetTag();
    LogInfo("qboy p.OnUIEvent hit tag = %d", tag);
    --
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        --p.CloseInfoLayer();
        --关闭按钮      
        if ID_ARMYGROUPBATTLEAPPLY_CTRL_BUTTON_26 == tag then    
                    
			CloseUI(NMAINSCENECHILDTAG.SyndicateBattleSignUpUI);		
			return true;
		--报名	
		elseif tag == ID_ARMYGROUPBATTLEAPPLY_CTRL_BUTTON_BATTLE then
			--[[非军团长
			if  p.ActivityState == 3 then
				CommonDlgNew.ShowYesDlg("您已退出，请重新打开界面！");
				return;
			end
			--]]	
			local nUserID		= GetPlayerId();
			local nAGID			= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	
			if nAGID == nil then
				CommonDlgNew.ShowTipDlg(GetTxtPri("SYN_D23")); 
				return true;
			end	
			
			--军团职位
			local nArmyPosition =MsgArmyGroup.GetUserArmyGroupPosition( nUserID )
			if  nArmyPosition == 1 then
				CommonDlgNew.ShowTipDlg(GetTxtPri("SYN_D24")); 
				return true;				
			end
			
			--军团等级
			if g_ArmyLev < 3 then
				CommonDlgNew.ShowTipDlg(GetTxtPri("SYN_D25")); 
				return true;
			end
			
			
			
			
			
			
			--金钱不足返回提示
  			local nNeedMoney 		= 200000;
			if  PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_MONEY) < nNeedMoney  then
				 CommonDlgNew.ShowTipDlg(GetTxtPri("SYN_D26")); 
				return true;
			end
			--]]
					
			MsgSyndicateBattle.SignUp();
			return true;
        end
           
    end
    
	return true;
end




--=======================报名倒计时========================---
local g_SignUpEndTime = 0;
--设置活动结束时间
function p.SetSignUpEndTime(nElapseTime)
	g_SignUpEndTime = nElapseTime;
	p.updateSignUpEndCount(g_SignUpEndTime);
	
end

p.SignUpEndTimerTag = nil;
--更新倒计时
function p.updateSignUpEndCount(restCount)
	g_SignUpEndTime = restCount;
		
	local CDlabel = p.GetSignUpEndCDLabel();
	
	if CDlabel ~= nil then
		--LogInfo("qboy CDlabel nil:"); 
		if restCount <= 0 then
			if p.SignUpEndTimerTag ~= nil then
				UnRegisterTimer(p.SignUpEndTimerTag);
				p.SignUpEndTimerTag = nil;
			end
		
			CDlabel:SetText("00:00:00");
		else
			CDlabel:SetText(FormatTime(restCount,1));
		end
	end
	
	
	if restCount > 0 then
		
		p.SignUpEndTimerTag=RegisterTimer(p.SignUpEndTimerTick,1, "SyndicateBattleSignUpUI.SignUpEndTimerTick");
		LogInfo("qboy RegisterTimer TimerTick SignUpEnd"..p.SignUpEndTimerTag); 
	end

end


--	--刷新活动状态
--	MsgCampBattle.SendCampBattleOpenBoard();
local nRefreshCount = 30;

function p.SignUpEndTimerTick(tag)
	--nRefreshCount = nRefreshCount - 1;
	--if nRefreshCount <= 0 then
	--	nRefreshCount = 30;
		
		--刷新活动状态
	--	MsgCampBattle.SendCampBattleOpenBoard();
		
	--	UnRegisterTimer(tag);
	---	p.SignUpEndTimerTag = nil;
		
	--end	

	 --如果为开启ui则关闭计时器
	if not IsUIShow(NMAINSCENECHILDTAG.SyndicateBattleSignUpUI) then
		UnRegisterTimer(tag);
		p.SignUpEndTimerTag = nil;
		return;
	end
	

	if tag == p.SignUpEndTimerTag then
		g_SignUpEndTime = g_SignUpEndTime - 1;
		
		--刷新计数文字
		if g_SignUpEndTime <= 0 then
			g_SignUpEndTime = 0;
		end
		
		local CDLabel = p.GetSignUpEndCDLabel();

		if CDLabel ~= nil then
			CDLabel:SetText(FormatTime(g_SignUpEndTime,1));
		end
			
		if g_SignUpEndTime <= 0 then
			LogInfo("qboy UnRegisterTimer1 :"); 
			UnRegisterTimer(p.SignUpEndTimerTag);
			p.SignUpEndTimerTag = nil;

			if CDLabel ~= nil then
				CDLabel:SetText("00:00:00");
			end
		end		
	end
end


function p.GetSignUpEndCDLabel()
	local layer = p.GetParent();
	local label = RecursiveLabel(layer, {32});
	return label;	
end




