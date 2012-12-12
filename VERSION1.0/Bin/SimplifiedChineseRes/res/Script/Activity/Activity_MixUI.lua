---------------------------------------------------
--描述: 活动界面
--时间: 2012.3.23
--作者: cl

---------------------------------------------------
local _G = _G;

Activity_MixUI={}
local p=Activity_MixUI;

local ID_ACTIVITYFIXED_CTRL_VERTICAL_LIST_M		= 416;
local ID_ACTIVITYFIXED_CTRL_BUTTON_CLOSE		= 18;

local ID_ACTIVITYFIXED_M_CTRL_BUTTON_REPLACER   = 123;
local ID_ACTIVITYFIXED_M_CTRL_BUTTON_JOIN		= 122;
local ID_ACTIVITYFIXED_M_CTRL_TEXT_STATE		= 41;
local ID_ACTIVITYFIXED_M_CTRL_TEXT_REWARD		= 37;
local ID_ACTIVITYFIXED_M_CTRL_TEXT_NAME			=26
local ID_ACTIVITYFIXED_M_CTRL_HYPER_TEXT_STATE	= 9;
local ID_ACTIVITYFIXED_M_CTRL_PICTURE_M			= 20;
local ID_ACTIVITYFIXED_M_CTRL_PICTURE_BG		= 124;

local ACTIVITY_CLOSE =0;
local ACTIVITY_OPEN =1;
local ACTIVITY_OVER =2;

local BOSS_ACTIVITY=2;--boss战活动
local FB_ACTIVITY=1;--多人副本活动

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ActivityMix);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load ActivityMix failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ActivityMix);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("ActivityFixed.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	
	--local containter = createUIScrollViewContainer();
	local containter = GetScrollViewContainer(layer,ID_ACTIVITYFIXED_CTRL_VERTICAL_LIST_M);
	if (nil == containter) then
		layer:Free();
		LogInfo("scene = nil,3");
		return false;
	end
	--containter:Init();
	containter:SetStyle(UIScrollStyle.Verical);
	--containter:SetFrameRect(CGRectMake(CONTAINTER_X, CONTAINTER_Y, CONTAINTER_W, CONTAINTER_H));
	containter:SetViewSize(CGSizeMake(containter:GetFrameRect().size.w, containter:GetFrameRect().size.h/4));
	--containter:SetLeftReserveDistance(CONTAINTER_W);
	--containter:SetRightReserveDistance(CONTAINTER_W);
	--containter:SetTag(TAG_CONTAINER);
	--layer:AddChild(containter);
	
	
	--p.AddActivity(1,1,0,0,1);
	--p.AddActivity(2,1,0,1,0);
	--p.AddActivity(3,2,100,2,1);
	--p.AddActivity(4,2,100,0,0,0);
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_ACTIVITYFIXED_CTRL_BUTTON_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   
end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ACTIVITYFIXED_CTRL_BUTTON_CLOSE == tag then
			--local scene = GetSMGameScene();
			--scene:RemoveChildByTag(NMAINSCENECHILDTAG.ActivityMix,true);
            RemoveChildByTagNew(NMAINSCENECHILDTAG.ActivityMix, true,true);
			return true;
		end
	end
end

function p.OnActivityUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ACTIVITYFIXED_M_CTRL_BUTTON_JOIN == tag then
			local view=PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				return;
			end
			local id=view:GetViewId();
			_G.MsgActivityMix.SendStartBossFight(id);
			
			--local scene = GetSMGameScene();
			--scene:RemoveChildByTag(NMAINSCENECHILDTAG.ActivityMix,true);
            RemoveChildByTagNew(NMAINSCENECHILDTAG.ActivityMix, true,true);
			return true;
		elseif ID_ACTIVITYFIXED_M_CTRL_BUTTON_REPLACER ==tag then
			
		end
	end
end

function p.AddActivity(id,type,param,status,isAgent)
	local layer = p.GetParent();
	if nil == layer then
		return nil;
	end
		
	local container = GetScrollViewContainer(layer,ID_ACTIVITYFIXED_CTRL_VERTICAL_LIST_M);
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	
	
	local view = createUIScrollView();
	if view == nil then
		LogInfo("view == nil");
		return;
	end
	
	view:Init(false);
	view:SetViewId(id);
	container:AddView(view);
	local uiLoad = createNDUILoad();
	if uiLoad ~= nil then
		uiLoad:Load("ActivityFixed_M.ini",view,p.OnActivityUIEvent,0,0);
		uiLoad:Free();
	end
	
	local name=GetDataBaseDataS("daily_activity",id,DB_DAILY_ACTIVITY.NAME);
	if type == BOSS_ACTIVITY then
		name = name .. " "..SafeN2S(param) .. GetTxtPub("Level");
	end

	SetLabel(view,ID_ACTIVITYFIXED_M_CTRL_TEXT_NAME,name);
	
	local desc=GetDataBaseDataS("daily_activity",id,DB_DAILY_ACTIVITY.DESC);
	local desc1=GetDataBaseDataS("daily_activity",id,DB_DAILY_ACTIVITY.DESC1);
	local linkText = GetHyperLinkText(view,ID_ACTIVITYFIXED_M_CTRL_HYPER_TEXT_STATE);
	if CheckP(linkText) then
		linkText:EnableLine(false);
		linkText:SetLinkText(desc .. "\n" .. desc1);
	end
	--SetHyperlinkText(view,ID_ACTIVITYFIXED_M_CTRL_HYPER_TEXT_STATE,desc);

	local join_button=GetButton(view,ID_ACTIVITYFIXED_M_CTRL_BUTTON_JOIN);
	if CheckP(join_button) then
		join_button:SetVisible(false);
	end
	
	local replacer_button = GetButton(view,ID_ACTIVITYFIXED_M_CTRL_BUTTON_REPLACER);
	if CheckP(replacer_button) then
		replacer_button:SetVisible(false);
	end
	
	if status == ACTIVITY_CLOSE then
		SetLabel(view,ID_ACTIVITYFIXED_M_CTRL_TEXT_STATE,GetTxtPri("AM_NotOpen"));
	elseif status == ACTIVITY_OVER then
		SetLabel(view,ID_ACTIVITYFIXED_M_CTRL_TEXT_STATE,GetTxtPri("AM_AlertEnd"));
	else
		GetButton(view,ID_ACTIVITYFIXED_M_CTRL_BUTTON_JOIN):SetVisible(true);
	end

	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end

	local vipLevel = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
	if vipLevel < 5 then
		local button=GetButton(view,ID_ACTIVITYFIXED_M_CTRL_BUTTON_REPLACER);
		if CheckP(button) then
			button:SetVisible(false);
		end
	end
	
end