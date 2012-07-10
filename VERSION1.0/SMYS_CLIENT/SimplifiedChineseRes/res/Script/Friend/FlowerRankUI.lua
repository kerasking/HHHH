---------------------------------------------------
--描述: 鲜花榜UI
--时间: 2012.4.17
--作者: fyl
---------------------------------------------------



FlowerRankUI = {}
local p = FlowerRankUI;

--rank
local ID_FLOWERS_LIST_CTRL_VERTICAL_LIST_8			= 8;
local ID_FLOWERS_LIST_CTRL_TEXT_7					= 7;
local ID_FLOWERS_LIST_CTRL_TEXT_6					= 6;
local ID_FLOWERS_LIST_CTRL_TEXT_5					= 5;
local ID_FLOWERS_LIST_CTRL_TEXT_FLOWERS_LIST		= 4;
local ID_FLOWERS_LIST_CTRL_BUTTON_CLOSE				= 3;
local ID_FLOWERS_LIST_CTRL_PICTURE_TITAL_BG			= 2;
local ID_FLOWERS_LIST_CTRL_PICTURE_BG				= 1;

--list
local ID_LIST_CTRL_TEXT_FLOWER_NUM			        = 3;
local ID_LIST_CTRL_TEXT_PLAYER				        = 2;
local ID_LIST_CTRL_TEXT_RANK					    = 1;


-----------------------
-----------------------

function p.LoadUI(datalist)
	playerId = id;

	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load GiveFlowersUI failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.FlowersRank);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("Flowers_Rank.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	
	--鲜花榜排名列表
    local container = RecursiveSVC(scene, { NMAINSCENECHILDTAG.FlowersRank, ID_FLOWERS_LIST_CTRL_VERTICAL_LIST_8});
	if not CheckP(container) then
		layer:Free();
		return false;
	end
	container:SetStyle(UIScrollStyle.Verical);
	container:SetViewSize(CGSizeMake(container:GetFrameRect().size.w, container:GetFrameRect().size.h/5));

	LogInfo("*******************")
	--datalist = { {"zhang",10011},{"heiheh",1000} }
	
	if #datalist > 0 then
	    for i = 1,#datalist do 
		     local data  = datalist[i];
			 LogInfoT(data)
			 p.SetRankInfo(i,data[1],data[2]);	
	    end
	end
	
end


function p.SetRankInfo(rank,name,flowerNum)	
	local container = p.GetRankContainer();
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
		uiLoad:Load("Flower_List.ini",view,nil,0,0);
		uiLoad:Free();
	end
	
	SetLabel(view,ID_LIST_CTRL_TEXT_RANK,SafeN2S(rank));
	SetLabel(view,ID_LIST_CTRL_TEXT_PLAYER,name);
	SetLabel(view,ID_LIST_CTRL_TEXT_FLOWER_NUM,SafeN2S(flowerNum));
	
end


function p.GetRankContainer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.FlowersRank);
	if nil == layer then
		return nil;
	end
	
	local containter = RecursiveSVC(layer, {ID_FLOWERS_LIST_CTRL_VERTICAL_LIST_8});
	
	return containter;
end



---------------
--UI事件处理回调函数
---------------
function p.OnUIEvent(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_FLOWERS_LIST_CTRL_BUTTON_CLOSE	 then
			--关闭界面
			CloseUI(NMAINSCENECHILDTAG.FlowersRank);
	    end
	end
	
	return 0;
end



function p.OnUIEventViewChange(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
	    local tag = uiNode:GetTag();
		LogInfo("p.OnUIEventViewChange[%d]", tag);	   
	end
	
	return true;
end


