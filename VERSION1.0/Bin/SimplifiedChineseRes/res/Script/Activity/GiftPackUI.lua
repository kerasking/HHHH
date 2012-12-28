---------------------------------------------------
--描述: 礼包界面
--时间: 2012.6.21
--作者: chh
---------------------------------------------------
GiftPackUI = {}
local p = GiftPackUI;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

local TAG_CLOSE         = 533;
local TAG_GIFT_LIST     = 101;

local TAG_LIST_IMG       = 102;
local TAG_LIST_NAME      = 103;
local TAG_LIST_DESC      = 104;
local TAG_LIST_TAKE      = 105;
local TAG_LIST_ITEMSIZE       = 5;


p.GiftBackList = {};    --礼包列表

p.GifeItemSize = CGSizeMake(260*ScaleFactor, 42*ScaleFactor);

function p.LoadUI()
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    

--------------------添加礼包层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerGiftBagUI );
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,1);
    

-----------------初始化ui添加到 layer 层上----------------------------------

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("giftbag.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
    
-------------------------------初始化数据------------------------------------    
    p.initData();
    
    p.RefreshUI();

    local closeBtn=GetButton(layer,TAG_CLOSE);
    closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);

    return true;
end



-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEven1t[%d], event:%d", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if TAG_CLOSE == tag then                           
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.PlayerGiftBagUI);
        elseif (TAG_LIST_TAKE == tag) then
        
            --判断背包是否已满
            if(ItemFunc.IsBagFull()) then
                return true;
            end
            
			local btn = ConverToButton(uiNode);
            local i = btn:GetParam1();
            if(not CheckN(i) or i<=0) then
                LogInfo("send open i param error!");
                return true;
            end
            
            
            local gid = p.GiftBackList[i].id;
            if(gid>0) then
                MsgActivityMix.SendGetGift(gid);
                ShowLoadBar();
            else
                LogInfo("send open gid param error!");
            end
            
        end
        
	end
	return true;
end


---------------------------关闭礼包窗口--------------------------------------
function p.freeData()
    MsgActivityMix.mUIListener = nil;
end


---------------------------初始化礼包窗口--------------------------------------
function p.initData()
    p.GiftBackList = MsgActivityMix.GetGiftBackLists();
    
	MsgActivityMix.mUIListener = p.processNet;
end


---------------------------初始化礼包信息-----------------------------------
function p.processNet(msgId, data)
	if (msgId == nil ) then
		LogInfo("MsgActivityMix processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_GIFTPACK_LIST then
        p.initData();
        p.RefreshUI();
    elseif(msgId == NMSG_Type._MSG_GET_GIFTPACK) then
        
        --p.ShowGetGiftInfo(data);                    --显示获得信息
        MsgActivityMix.DelGiftById(data);           --删除本地缓存数据
        p.initData();                               --刷新UI
        p.RefreshUI();
	end
end


--显示获得礼包内容的信息
function p.ShowGetGiftInfo(id)
    local gift = nil;
    for i=1,#p.GiftBackList do
        if(p.GiftBackList[i].id == id) then
            gift = p.GiftBackList[i];
            break;
        end
    end
    
    if(gift == nil) then
        LogInfo("p.ShowGetGiftInfo id:[%d] not data!",id);
        return;
    end
    
    local info = "";
    if(gift.type == 1 ) then
        if(not CheckN(gift.aux_param0) or
            not CheckN(gift.param1) or
            not CheckN(gift.param0)) then
            LogInfo("获得竞技场礼包参数错误。");
            return;
        end
        info = string.format(GetTxtPri("FF_JJPaiMing"),gift.aux_param0,gift.param1,gift.param0);
    elseif(gift.type == 2 ) then
        if(not CheckN(gift.aux_param0)) then
            LogInfo("获得军衔参数错误gift.aux_param0。");
            return;
        end
        local name = GetDataBaseDataS("rank_config",gift.aux_param0,DB_RANK.RANK_NAME);
        if(name == nil or not CheckN(gift.param0)) then
            LogInfo("获得军衔参数错误name and 。gift.param0");
            return;
        end
        info = string.format(GetTxtPri("FF_Rank"),name, gift.aux_param0, gift.param0);
    elseif(gift.type == 3 ) then
        
    elseif(gift.type == 4 ) then
        
    elseif(gift.type == 5 ) then
        --判断背包是否已满
        if(ItemFunc.IsBagFull()) then
            return false;
        end
        
        if(not CheckN(gift.aux_param0) or
            not CheckN(gift.param1) or
            not CheckN(gift.param0)) then
            LogInfo("获得通用礼包参数错误。");
            return;
        end
        
        info = GetTxtPri("CB2_T17")..":";
        if(gift.param0>0) then
            info = string.format(GetTxtPri("FF_YuanBao"),info,gift.param0);
        end
        
        if(gift.param0>0) then
            info = string.format(GetTxtPri("FF_TongQian"),info,gift.param1);
        end
        
        if(gift.aux_param0>0) then
            local name = GetDataBaseDataS("itemtype", gift.param1, DB_ITEMTYPE.NAME);
            if(CheckS(name)) then
                info = string.format("%s %s",info, name);
            end
        end
    end
    
    if(gift.type ~= 0) then
        CommonDlgNew.ShowYesDlg(info,nil,nil,3);
    end
end


--刷新礼包
function p.RefreshUI()
    local container = p.GetGiftListContainer();
    container:RemoveAllView();
    local rectview = container:GetFrameRect();
    --container:SetViewSize(p.GifeItemSize);
    
    for i, v in ipairs(p.GiftBackList) do
        p.CreateGiftItem(container,i);
	end
end

function p.CreateGiftItem(container,i)
        local view = createUIScrollView();
        
        view:Init(false);
        view:SetViewId(i);
        view:SetTag(i);
        view:SetMovableViewer(container);
        view:SetScrollViewer(container);
        view:SetContainer(container);
        

        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            return false;
        end
	
        uiLoad:Load("giftbag_L.ini", view, p.OnUIEvent, 0, 0);
           
        --实例化每一项
        p.RefreshGiftItem(view,i);
        container:AddView(view);
        uiLoad:Free();
end

function p.RefreshGiftItem(view,i)  
    if(not CheckN(i)) then
        LogInfo("p.RefreshGiftItem param error!");
        return;
    end
    
    local gift = p.GiftBackList[i];
    if(gift == nil) then
        LogInfo("p.RefreshGiftItem p.GiftBackList[%d] is nil!", i);
        return;
    end
    
    local pic = GetImage(view, TAG_LIST_IMG);
    pic:SetPicture(GetGiftPic(GetDataBaseDataN("giftpack_config",gift.type,DB_GIFTPACK_CONFIG.ICON)));
    
    SetLabel(view,TAG_LIST_NAME,GetDataBaseDataS("giftpack_config",gift.type,DB_GIFTPACK_CONFIG.NAME));
    
    local name = GetDataBaseDataS("rank_config",gift.aux_param0,DB_RANK.RANK_NAME);
    SetLabel(view,TAG_LIST_DESC,string.format(GetDataBaseDataS("giftpack_config",gift.type,DB_GIFTPACK_CONFIG.DESCRIBE),name,gift.param0));
    
    local btn = GetButton(view, TAG_LIST_TAKE);
    btn:SetParam1(i);
    
    
    --设置大小
    local pic = GetImage(view, TAG_LIST_ITEMSIZE);
    local container = p.GetGiftListContainer();
    container:SetViewSize(pic:GetFrameRect().size);
end

--获得礼包列表
function p.GetGiftListContainer()
	local layer = p.GetLayer()
	local container = GetScrollViewContainer(layer, TAG_GIFT_LIST);
	return container;
end

--获得当前窗口层
function p.GetLayer()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerGiftBagUI);
    return layer;
end
