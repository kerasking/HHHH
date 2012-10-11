---------------------------------------------------
--描述: 竞技场排行界面
--时间: 2012.3.22
--作者: cl

---------------------------------------------------
local _G = _G;

p.userId = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,};

ArenaRankUI={}
local p=ArenaRankUI;

local ID_ARENARANK_CTRL_VERTICAL_LIST_M		= 50;
local ID_ARENARANK_CTRL_BUTTON_CLOSE		= 49;
local ID_ARENARANK_CTRL_TEXT_94				= 94;
local ID_ARENARANK_CTRL_PICTURE_BG			= 23;

local ID_ARENARANK_M_CTRL_TEXT_FIGHT     = 89;
local ID_ARENARANK_M_CTRL_TEXT_LEVEL     = 84;
local ID_ARENARANK_M_CTRL_TEXT_PLAYER     = 79;
local ID_ARENARANK_M_CTRL_TEXT_76      = 76;
local ID_ARENARANK_M_CTRL_TEXT_75      = 75;
local ID_ARENARANK_M_CTRL_TEXT_72      = 72;

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ArenaRank);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load ArenaRankUI failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ArenaRank);
	local winsize = GetWinSize();
	layer:SetFrameRect( CGRectMake(winsize.w /4, winsize.h /10, winsize.w /2, winsize.h * 4 / 5));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("ArenaRank.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	--local containter = createUIScrollViewContainer();
	local containter = GetScrollViewContainer(layer,ID_ARENARANK_CTRL_VERTICAL_LIST_M);
	if (nil == containter) then
		layer:Free();
		LogInfo("scene = nil,3");
		return false;
	end
	--containter:Init();
	containter:SetStyle(UIScrollStyle.Verical);
	--containter:SetFrameRect(CGRectMake(CONTAINTER_X, CONTAINTER_Y, CONTAINTER_W, CONTAINTER_H));
	containter:SetViewSize(CGSizeMake(containter:GetFrameRect().size.w, containter:GetFrameRect().size.h/5));
	--containter:SetLeftReserveDistance(CONTAINTER_W);
	--containter:SetRightReserveDistance(CONTAINTER_W);
	--containter:SetTag(TAG_CONTAINER);
	--layer:AddChild(containter);
	

	return true;
end

function p.OnRankUIEvent(uiNode,uiEventType,param)
end

function p.SetRankInfo(rank,name,level,power,id)
	local layer = p.GetParent();
	if nil == layer then
		return nil;
	end
	
	
	local container = GetScrollViewContainer(layer,ID_ARENARANK_CTRL_VERTICAL_LIST_M);
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
	view:SetViewId(rank);
	container:AddView(view);
	local uiLoad = createNDUILoad();
	if uiLoad ~= nil then
		uiLoad:Load("ArenaRank_M.ini",view,p.OnRankUIEvent,0,0);
		uiLoad:Free();
	end
	
	SetLabel(view,ID_ARENARANK_M_CTRL_TEXT_PLAYER,SafeN2S(rank).." "..name);
	SetLabel(view,ID_ARENARANK_M_CTRL_TEXT_LEVEL,SafeN2S(level));
	SetLabel(view,ID_ARENARANK_M_CTRL_TEXT_FIGHT,SafeN2S(power));
	
end

function p.CleanContainer()
	local layer = p.GetParent();
	if nil == layer then
		return nil;
	end
	
	
	local container = GetScrollViewContainer(layer,ID_ARENARANK_CTRL_VERTICAL_LIST_M);
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	
	container:RemoveAllView();
end



function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ARENARANK_CTRL_BUTTON_CLOSE == tag then
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaRank,true);
				return true;
			end
		end
	end
end