---------------------------------------------------
--描述: 在主城查看其它玩家UI
--时间: 2012.10.17
--作者: chh
---------------------------------------------------


MainPlayerListUI = {}
local p = MainPlayerListUI;

local TAG_CONTAINER     = 2;    --列表容器
local TAG_BG_PIC        = 4;    --列表项大小
local TAG_NAME          = 2;    --玩家名字
local TAG_LEVEL         = 3;    --玩家等级


p.tFriendData = nil;

function p.LoadUI( tFriendData )
    p.tFriendData = tFriendData;
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load UI failed!");
		return;
	end
    
    if( tFriendData == nil ) then
        LogInfo("MainPlayerListUI.LoadUI tFriendData is nil!");
        return;
    end
    
    --已存在就销毁
    local layer = GetUiLayer( scene, NMAINSCENECHILDTAG.MainPlayerListUI );
    if( layer == nil ) then
        local layer = createNDUILayer();
        if layer == nil then
            return false;
        end
        layer:Init();
        layer:SetTag(NMAINSCENECHILDTAG.MainPlayerListUI);
        scene:AddChildZ(layer,1);

        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            layer:Free();
            return false;
        end

        --bg
        uiLoad:Load("MainPlayerList.ini", layer, nil, 0, 0);
        uiLoad:Free();
        
        local winsize = GetWinSize(); 
        local container =  p.GetListContainer();
        container:EnableScrollBar(true);
        
        local sz = container:GetFrameRect().size;
        local ControlBtn = MainUIBottomSpeedBar.GetBottomMsgBtnLayer();
        layer:SetFrameRect( CGRectMake( winsize.w - sz.w, MainUIBottomSpeedBar.BtnSayRect.origin.y - sz.h, sz.w, sz.h ) );
        
    end
	
    p.RefreshUI( tFriendData );
end

function p.RefreshUI( tFriendData )
    local container = p.GetListContainer();
	if nil == container then
		return;
	end
    container:RemoveAllView();
    
    for i, v in ipairs(tFriendData) do
		local view = createUIScrollView();
        
        if view == nil then
            return;
        end
        view:Init(false);
        view:SetScrollStyle(UIScrollStyle.Horzontal);
        view:SetViewId(v.Id);
        view:SetTag(v.Id);
        view:SetMovableViewer(container);
        view:SetScrollViewer(container);
        view:SetContainer(container);
        
        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            return false;
        end
        uiLoad:Load("MainPlayerList_M.ini", view, p.OnItemEvent, 0, 0);
		
        p.refreshItem(v,view);
        container:AddView(view);
        uiLoad:Free();
	end
end

function p.OnItemEvent(uiNode, uiEventType, param) 
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if TAG_BG_PIC == tag then
            local btn = ConverToButton(uiNode);
            
            for i,v in ipairs(p.tFriendData) do
                if( v.Id == btn:GetParam1() ) then
                    MsgFriend.SendFriendSel(btn:GetParam1(),v.Name);
                    break;
                end
            end
            
            
            
        end
	end
	return true;
end

function p.refreshItem(v, view)
    LogInfo("MainPlayerListUI.refreshItem");
    
    local btn = GetButton(view, TAG_BG_PIC);
    local l_name = GetLabel(view, TAG_NAME);
    local l_level = GetLabel(view, TAG_LEVEL);
    
    btn:SetParam1(v.Id);
    l_name:SetText(v.Name);
    l_level:SetText(v.Level.."");
    
    local l_name = SetLabel(view,TAG_NAME,v.Name);
    ItemPet.SetLabelByQuality(l_name, v.Quality);
    
    
     --设置窗口项的大小
    local container = p.GetListContainer();
    container:SetViewSize(btn:GetFrameRect().size);
end

function p.FreeData()
    p.tFriendData = nil;
end

function p.Close()
    p.FreeData();
    CloseUI(NMAINSCENECHILDTAG.MainPlayerListUI);
end


function p.GetMainLayer()
    local scene = GetSMGameScene();
    if(scene == nil) then
        LogInfo("MainPlayerListUI.GetMainLayer scene is nil");
        return nil;
    end
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.MainPlayerListUI);
    return layer;
end

function p.GetListContainer()
    local layer = p.GetMainLayer();
    if( layer == nil ) then
        LogInfo("MainPlayerListUI.GetListContainer layer is nil");
        return nil;
    end
	local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return container;
end


