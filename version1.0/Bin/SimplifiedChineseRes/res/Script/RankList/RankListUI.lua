---------------------------------------------------
--描述: 名人堂界面
--时间: 2013.1.9
--作者: chh
---------------------------------------------------
RankListUI = {}
local p = RankListUI;

local TAG_CLOSE         = 3;
local TAG_RANK_LIST     = 19;

local TAG_LEVEL     = 13;
local TAG_REPUTE    = 14;
local TAG_STAR      = 15;
local TAG_STAGE     = 16;
local TAG_MONEY     = 17;
local TAG_MOUNT     = 18;

local TAG_LISTS = {
    TAG_LEVEL,TAG_REPUTE,TAG_STAR,TAG_STAGE,TAG_MONEY,TAG_MOUNT
}

local PLAYER_COLOR = {
    ccc4(251,165,46,255),
    ccc4(255,0,0,255),
}

local TAG_LIST_ITEMSIZE = 1;
local TAG_LIST_RANK     = 2;
local TAG_LIST_NAME     = 3;
local TAG_LIST_DESC     = 4;

local TAG_TIME  = 20;
local TIMETIMER = nil;

local nTimeSeconds = 0;
function p.RefreshTime(nTime)
    nTimeSeconds = nTime;
    if(TIMETIMER == nil) then
        TIMETIMER = RegisterTimer(p.TimeTimer,1, "RankListUI.TimeTimer");
    end
end

function p.TimeTimer()
    nTimeSeconds = nTimeSeconds - 1;
    
    local layer = p.GetLayer();
    if(layer == nil or nTimeSeconds<0) then
        UnRegisterTimer(TIMETIMER);
        TIMETIMER = nil;
    end
    
    if(layer) then
        local label = GetLabel(layer, TAG_TIME);
        if(label) then
            local m = nTimeSeconds / 60;
            local s = nTimeSeconds % 60;
            if(nTimeSeconds <= 0) then
                m = 0;
                s = 0;
                MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_REFRESHTIME);
                MsgRankList.SendGetListInfoMsg(p.RankType);
            end
            label:SetText(string.format("%d:%02d",m,s));
        end
    end
end



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
	layer:SetTag(NMAINSCENECHILDTAG.RankListUI );
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
    

-----------------初始化ui添加到 layer 层上----------------------------------

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("Ranklist/Ranklist_Main.ini", layer, p.OnUIEvent, 0, 0);
    
    MsgRankList.mUIListener = p.processNet;
    
    
    --发送获得等级排行消息
    MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_PET_LEVEL);
    MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_REFRESHTIME);
    p.RankType = MsgRankList.RANKING_ACT.ACT_PET_LEVEL;
    
    local btn = GetButton(layer,TAG_LISTS[1]);
    if(btn) then
        btn:TabSel(true);
        btn:SetFocus(true);
    end
    
    
-------------------------------初始化数据------------------------------------    

    local closeBtn=GetButton(layer,TAG_CLOSE);
    closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);

    return true;
end

p.RankType = 0;

-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEven1t[%d], event:%d", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    
        for i,v in ipairs(TAG_LISTS) do
            local btn = GetButton(p.GetLayer(),v);
            if(btn) then
                LogInfo("btn:[%d],v:[%d]",tag,v);
                if(tag == v) then
                    btn:TabSel(true);
                    btn:SetFocus(true);
                else
                    btn:TabSel(false);
                    btn:SetFocus(false);
                end
                
            end
        end
    
    
		if TAG_CLOSE == tag then                           
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.RankListUI);
        elseif (TAG_LEVEL == tag) then
            MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_PET_LEVEL);
            p.RankType = MsgRankList.RANKING_ACT.ACT_PET_LEVEL;
        elseif (TAG_REPUTE == tag) then
            MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_REPUTE);
            p.RankType = MsgRankList.RANKING_ACT.ACT_REPUTE;
        elseif (TAG_STAR == tag) then
            MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_SOPH);
            p.RankType = MsgRankList.RANKING_ACT.ACT_SOPH;
        elseif (TAG_STAGE == tag) then
            MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_STAGE);
            p.RankType = MsgRankList.RANKING_ACT.ACT_STAGE;
        elseif (TAG_MONEY == tag) then
            MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_MONEY);
            p.RankType = MsgRankList.RANKING_ACT.ACT_MONEY;
        elseif (TAG_MOUNT == tag) then
            MsgRankList.SendGetListInfoMsg(MsgRankList.RANKING_ACT.ACT_MOUNT_LEVEL);
            p.RankType = MsgRankList.RANKING_ACT.ACT_MOUNT_LEVEL;
        end
        
	end
	return true;
end

function p.freeData()
    MsgRankList.mUIListener = nil;
end


function p.processNet(msgId, data)
	if (msgId == nil ) then
		LogInfo("RankListUI processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_RANKING then
        p.RefreshUI(data);
	end
end


--刷新礼包
function p.RefreshUI( pRankList )
    local container = p.GetRankListContainer();
    container:RemoveAllView();
    container:EnableScrollBar(true);
    
    for i,v in ipairs(pRankList) do
        p.CreateRankItem(v);
	end
end

function p.CreateRankItem(v)
    local container = p.GetRankListContainer();
    local view = createUIScrollView();
    
    view:Init(false);
    view:SetViewId(v.nRank);
    view:SetTag(v.nRank);
    view:SetMovableViewer(container);
    view:SetScrollViewer(container);
    view:SetContainer(container);
    

    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        return false;
    end

    uiLoad:Load("Ranklist/Ranklist_L.ini", view, nil, 0, 0);
       
    --实例化每一项
    p.RefreshRankItem(view,v);
    container:AddView(view);
    uiLoad:Free();
end

local STAR_DES = {
    GetTxtPri("RLUI_T1"),
    GetTxtPri("RLUI_T2"),
    GetTxtPri("RLUI_T3"),
    GetTxtPri("RLUI_T4"),
    GetTxtPri("RLUI_T5"),
}

function p.RefreshRankItem(view,v)
    local desc = "";
    if(MsgRankList.Action == MsgRankList.RANKING_ACT.ACT_PET_LEVEL) then
        desc = string.format("%d%s",v.nNum,GetTxtPub("Level"));
    elseif(MsgRankList.Action == MsgRankList.RANKING_ACT.ACT_REPUTE) then
        desc = string.format("%s:%d",GetTxtPub("ShenWan"),v.nNum);
    elseif(MsgRankList.Action == MsgRankList.RANKING_ACT.ACT_SOPH) then
        --desc = string.format("%s%d%s %s:%d",STAR_DES[v.nNum],v.nStar,GetTxtPri("BB2_T5"),GetTxtPub("JianHun"),v.nSoph);
        desc = string.format("%s%d%s",STAR_DES[v.nNum],v.nStar,GetTxtPri("BB2_T5"),GetTxtPub("JianHun"));
    elseif(MsgRankList.Action == MsgRankList.RANKING_ACT.ACT_STAGE) then
        local nTaskId = 50000+math.floor(v.nNum/10);
        local nTitle = GetDataBaseDataS("task_type", nTaskId, DB_TASK_TYPE.NAME);
        desc = string.format("%s",nTitle);
        
    elseif(MsgRankList.Action == MsgRankList.RANKING_ACT.ACT_MONEY) then
        desc = string.format("%s:%d",GetTxtPub("coin"),v.nNum);
    elseif(MsgRankList.Action == MsgRankList.RANKING_ACT.ACT_MOUNT_LEVEL) then
        desc = string.format(GetTxtPri("RLUI_TURN"),p.GetTurn(v.nNum),p.GetStar(v.nNum));
    end
    
    local l_rank = SetLabel(view, TAG_LIST_RANK, string.format("%d",v.nRank));
    
    local sName 		= GetRoleBasicDataS(GetPlayerId(),USER_ATTR.USER_ATTR_NAME);
    local l_name = SetLabel(view, TAG_LIST_NAME, v.sName);
    local l_desc = SetLabel(view, TAG_LIST_DESC, desc);
    if(v.sName == sName) then
        l_rank:SetFontColor(PLAYER_COLOR[2]);
        l_name:SetFontColor(PLAYER_COLOR[2]);
        l_desc:SetFontColor(PLAYER_COLOR[2]);
    else
        l_rank:SetFontColor(PLAYER_COLOR[1]);
        l_name:SetFontColor(PLAYER_COLOR[1]);
        l_desc:SetFontColor(PLAYER_COLOR[1]);
    end
    
    
    
    --设置大小
    local pic = GetImage(view, TAG_LIST_ITEMSIZE);
    local container = p.GetRankListContainer();
    container:SetViewSize(pic:GetFrameRect().size);
end

--获得转数
function p.GetTurn(star)
    if(star==0) then
        return 0;
    end
    local starS = math.ceil(star/10) - 1;
    return starS;
end

--获得星级
function p.GetStar(star)
    if(star == 0) then
        return 0;
    end
    
    local starG = star%10;
    if(starG==0) then
        starG = 10; 
    end
    return starG;
end

--获得礼包列表
function p.GetRankListContainer()
	local layer = p.GetLayer()
	local container = GetScrollViewContainer(layer, TAG_RANK_LIST);
	return container;
end

--获得当前窗口层
function p.GetLayer()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankListUI);
    return layer;
end
