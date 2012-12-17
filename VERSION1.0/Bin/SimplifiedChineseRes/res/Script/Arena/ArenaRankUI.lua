---------------------------------------------------
--描述: 竞技场排行界面
--时间: 2012.3.22
--作者: cl

---------------------------------------------------
local _G = _G;



ArenaRankUI={}
local p=ArenaRankUI;

p.userInfo = {};

local ID_ARENARANK_CTRL_VERTICAL_LIST_M		= 50;
local ID_ARENARANK_CTRL_BUTTON_CLOSE		= 49;
local ID_ARENARANK_CTRL_TEXT_94				= 94;
local ID_ARENARANK_CTRL_PICTURE_BG			= 23;

local ID_ARENARANK_M_CTRL_TEXT_FIGHT     = 89;
local ID_ARENARANK_M_CTRL_TEXT_LEVEL     = 84;
local ID_ARENARANK_M_CTRL_TEXT_PLAYER     = 79;
local ID_ARENARANK_M_CTRL_TEXT_5     = 5;

local ID_ARENARANK_M_CTRL_TEXT_76      = 76;
local ID_ARENARANK_M_CTRL_TEXT_75      = 75;
local ID_ARENARANK_M_CTRL_TEXT_72      = 72;
local ID_ARENARANK_M_CTRL_BUTTON_WATCH	=4;


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
    LogInfo("+++++++++++scene = nil,load ArenaRankUI+++++++");
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
	layer:SetFrameRect( CGRectMake(0, 0, winsize.w, winsize.h));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ArenaRank);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_JJ_RANK.ini",layer,p.OnUIEvent,0,0);
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
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ARENARANK_M_CTRL_BUTTON_WATCH == tag then
            LogInfo("ID_ARENARANK_M_CTRL_BUTTON_WATCH");
			local view=PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				return true;
			end
			local rank=view:GetViewId();
			local id=p.userInfo[rank][1];
			local name=p.userInfo[rank][2];
			MsgFriend.SendFriendSel(id,name,nil);
		end
	end
end

function p.SetRankInfo(rank,name,level,power,id)
	local layer = p.GetParent();
	if nil == layer then
		return nil;
	end
	p.userInfo[rank]={id,name};
	
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
		uiLoad:Load("SM_JJ_M.ini",view,p.OnRankUIEvent,0,0);
		uiLoad:Free();
	end
    
    SetLabel(view,ID_ARENARANK_M_CTRL_TEXT_5,SafeN2S(rank));
	SetLabel(view,ID_ARENARANK_M_CTRL_TEXT_PLAYER, name);
	SetLabel(view,ID_ARENARANK_M_CTRL_TEXT_LEVEL,SafeN2S(level));

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