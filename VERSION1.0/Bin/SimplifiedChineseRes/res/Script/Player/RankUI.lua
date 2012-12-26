

---------------------------------------------------
--描述: 军衔
--时间: 2012.5.09
--作者: chh
---------------------------------------------------
RankUI = {}
local p = RankUI;

local CONTAINTER_X  = 0;
local CONTAINTER_Y  = 0;

local RankItemSize = CGSizeMake(125*ScaleFactor, 30*ScaleFactor);

p.TagClose = 533;
p.TagUpgrade = 501;
p.TagRankList = 130;
p.TagRankItemPic = 100;
p.TagRankItemLabel = 200;
p.TagReputation     = 53;

p.TagTip = 73;

local RankListCount     = 8;
local TAG_BEGIN_ARROW   = 1411;
local TAG_END_ARROW     = 1412;

p.RankIds = {};

p.TITLE_TXT = {GetTxtPri("ViewRank"),GetTxtPri("UpdageRank")};

p.TagPropLabels = {
    TITLE   = 421,
    NAME    = 402,
    PRES    = 201,
    MONEY   = 202,
    TOT_PEOPLE = 203,
    CRU_PEOPLE = 204,
    FORCE      = 302,
    WIT        = 206,
    QUICK      = 207,
    LIFE      = 208,
    NNAME    = 422,
    NPRES    = 209,
    NMONEY   = 210,
    NTOT_PEOPLE = 211,
    NCRU_PEOPLE = 212,
    NFORCE      = 213,
    NWIT        = 214,
    NQUICK      = 215,
    NLIFE      = 216,
};

p.RandInfo  = {};            --军衔信息

function p.LoadUI()
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    

--------------------添加军衔层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.RankUI );
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
    

-----------------初始化ui添加到 layer 层上----------------------------------

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("Rank.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
    
    local animate = RecursivUISprite(layer,{p.TagTip});
    local szAniPath = NDPath_GetAnimationPath();
    animate:ChangeSprite(szAniPath.."jiantx03.spr");
    
    
    
-------------------------------初始化数据------------------------------------    
    p.initData(); 
    p.RefreshUI();
    
    if (p.RandInfo.LEVEL<#p.RankIds) then
        LogInfo("p.RandInfo.LEVEL+1:[%d]",p.RandInfo.LEVEL+1);
        p.RefreshNextRank(p.RandInfo.LEVEL+1);
    end
    
    p.TipUpgrade();
    
    --UI 修改
    --p.setArrow(layer,p.GetListContainer());
    	--设置关闭音效
   	local closeBtn=GetButton(layer,p.TagClose);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    return true;
end



-----------------------------UI层的事件处理---------------------------------
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	--LogInfo("p.OnUIEven1t[%d], event:%d", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then                           
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.RankUI);
        elseif (p.TagUpgrade == tag) then
			p.randUpgrade();
        end
        
    elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
        if p.TagRankList == tag then 
            
            local scene = GetSMGameScene();
            local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
            --p.setArrow(layer,p.GetListContainer());
        end
	end
	return true;
end

function p.setArrow(layer,pageView)
    --设置箭头   
    local larrow    = GetButton(layer,TAG_BEGIN_ARROW);
    local rarrow    = GetButton(layer,TAG_END_ARROW);
            
    local pageIndex = pageView:GetBeginIndex();
    local pageCount = pageView:GetViewCount();
    
    larrow:EnalbeGray(false);
    rarrow:EnalbeGray(false);
    if(pageIndex == 0) then
        larrow:EnalbeGray(true);
    end
    if(pageIndex >= pageCount-1-RankListCount) then
        rarrow:EnalbeGray(true);
    end
end

-----------------------------军衔列表项事件---------------------------------
function p.OnUIRankItemEvent(uiNode, uiEventType, param)
    uiNode = ConverToButton(uiNode);
    p.RefreshNextRank(uiNode:GetParam1());
	return true;
end

---------------------------升级军衔--------------------------------------
function p.randUpgrade()
    local requte = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL + 1,DB_RANK.REPUTE);
    if(p.RandInfo.PRESTIGE>=requte) then
        MsgRank.sendRankUpgrade();
    end
end


---------------------------关闭军衔窗口--------------------------------------
function p.freeData()
    MsgRank.mUIListener = nil;
    p.RankIds = nil;
end


---------------------------初始化军衔窗口--------------------------------------
function p.initData()
	p.initConst();
    
    p.initRankInfo();
    
    p.RankIds = GetDataBaseIdList("rank_config");
    
	MsgRank.mUIListener = p.processNet;
end

--初始化军衔信息
function p.initRankInfo()
    --p.RandInfo  = {LEVEL = 1, PRESTIGE = 4560,};
    p.RandInfo.LEVEL = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_RANK);
    LogInfo("1.level:[%d]",p.RandInfo.LEVEL);
    p.RandInfo.PRESTIGE = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_REPUTE);
    LogInfo("prestige:[%d]",p.RandInfo.PRESTIGE);
end

---------------------------初始化常量--------------------------------------
function p.initConst()
    
end

function p.RefreshUI()
    p.RefreshCurrRank();
    p.RefreshRankList();
end

function p.RefreshCurrRank()
    LogInfo("2.level:[%d]",p.RandInfo.LEVEL);
    LogInfo("p.RefreshCurrRank");
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    local btn = GetButton(layer, p.TagUpgrade);
    --判断升级按钮是否可见
    local requte = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL + 1,DB_RANK.REPUTE);
    
    LogInfo("p.RandInfo.LEVEL:[%d],#p.RankIds:[%d]",p.RandInfo.LEVEL,#p.RankIds);
    
    if(p.RandInfo.PRESTIGE<requte or p.RandInfo.LEVEL>=#p.RankIds) then
        btn:EnalbeGray(true);
    else
        btn:EnalbeGray(false);
    end
    
    p.TipUpgrade();
    
    if(p.RandInfo.LEVEL == 0) then 
        return; 
    end
    
    
    local tempstr1,tempstr2,tempstr3,tempstr4,tempstr5,tempstr6,tempstr7,tempstr8,tempstr9;
    tempstr1,tempstr2,tempstr3,tempstr4,tempstr5,tempstr6,tempstr7,tempstr8,tempstr9 = "-";
    tempstr1 = GetDataBaseDataS("rank_config",p.RandInfo.LEVEL,DB_RANK.RANK_NAME);
    tempstr2 = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.REPUTE).."";
    tempstr3 = MoneyFormat(GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.MONEY));
    tempstr4 = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.MAX_OWN_PET)..GetTxtPub("Ming");
    tempstr5 = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.MAX_FIGHT_PET)..GetTxtPub("Ming");
    tempstr6 = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.STR).."";
    tempstr7 = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.INI).."";
    tempstr8 = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.AGI).."";
    tempstr9 = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL,DB_RANK.LIFE).."";
    
    LogInfo("p.TagPropLabels.NAME:[%d],tempstr1:[%s]",p.TagPropLabels.NAME,tempstr1);
    SetLabel(layer,p.TagPropLabels.NAME,tempstr1);
    SetLabel(layer,p.TagPropLabels.PRES,tempstr2);
    SetLabel(layer,p.TagPropLabels.MONEY,tempstr3);
    SetLabel(layer,p.TagPropLabels.TOT_PEOPLE,tempstr4);
    SetLabel(layer,p.TagPropLabels.CRU_PEOPLE,tempstr5);    
    SetLabel(layer,p.TagPropLabels.FORCE,tempstr6);
    SetLabel(layer,p.TagPropLabels.WIT,tempstr7);
    SetLabel(layer,p.TagPropLabels.QUICK,tempstr8);
    SetLabel(layer,p.TagPropLabels.LIFE,tempstr9);
    
    --添加声望
    local repute = GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_REPUTE);
    SetLabel(layer,p.TagReputation,repute.."");
end

function p.isUpgradeBtnVisible()
    local requte = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL + 1,DB_RANK.REPUTE);
     if(p.RandInfo.PRESTIGE>=requte and p.RandInfo.LEVEL < #p.RankIds) then
        return true;
    else
        return false;
    end
end

function p.RefreshNextRank(level)
    LogInfo("3.level:[%d]",p.RandInfo.LEVEL);
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    
    if(p.RandInfo.LEVEL+1==level) then
        SetLabel(layer,p.TagPropLabels.TITLE,p.TITLE_TXT[2]);
    else
        SetLabel(layer,p.TagPropLabels.TITLE,p.TITLE_TXT[1]);
    end
    
    local tempstr1,tempstr2,tempstr3,tempstr4,tempstr5,tempstr6,tempstr7,tempstr8,tempstr9;
    tempstr1,tempstr2,tempstr3,tempstr4,tempstr5,tempstr6,tempstr7,tempstr8,tempstr9 = "-";
    LogInfo("level:[%d],#p.RankIds:[%d]",level,#p.RankIds);
    if(level<=#p.RankIds) then
        tempstr1 = GetDataBaseDataS("rank_config",level,DB_RANK.RANK_NAME);
        tempstr2 = GetDataBaseDataN("rank_config",level,DB_RANK.REPUTE).."";
        tempstr3 = MoneyFormat(GetDataBaseDataN("rank_config",level,DB_RANK.MONEY));
        tempstr4 = GetDataBaseDataN("rank_config",level,DB_RANK.MAX_OWN_PET)..GetTxtPub("Ming");
        tempstr5 = GetDataBaseDataN("rank_config",level,DB_RANK.MAX_FIGHT_PET)..GetTxtPub("Ming");
        tempstr6 = GetDataBaseDataN("rank_config",level,DB_RANK.STR).."";
        tempstr7 = GetDataBaseDataN("rank_config",level,DB_RANK.INI).."";
        tempstr8 = GetDataBaseDataN("rank_config",level,DB_RANK.AGI).."";
        tempstr9 = GetDataBaseDataN("rank_config",level,DB_RANK.LIFE).."";
    end
    
    SetLabel(layer,p.TagPropLabels.NNAME,tempstr1);
    SetLabel(layer,p.TagPropLabels.NPRES,tempstr2);
    SetLabel(layer,p.TagPropLabels.NMONEY,tempstr3);
    SetLabel(layer,p.TagPropLabels.NTOT_PEOPLE,tempstr4);
    SetLabel(layer,p.TagPropLabels.NCRU_PEOPLE,tempstr5);    
    SetLabel(layer,p.TagPropLabels.NFORCE,tempstr6);
    SetLabel(layer,p.TagPropLabels.NWIT,tempstr7);
    SetLabel(layer,p.TagPropLabels.NQUICK,tempstr8);
    SetLabel(layer,p.TagPropLabels.NLIFE,tempstr9);
    
    p.SelectRankItem(level);
end

--选中军衔项
function p.SelectRankItem(level)
    local container = p.GetListContainer();
    for i, v in ipairs(p.RankIds) do
        LogInfo("i:[%d],v:[%d]",i,v);
        local view = container:GetViewById(v);
        if(view == nil) then
            LogInfo("p.SelectRankItem view:[%d] is nil",i);
        else
            LogInfo("p.SelectRankItem view:[%d]",i);
            local btn = GetButton(view, p.TagRankItemLabel);
            if(btn == nil) then
                LogInfo("p.SelectRankItem btn:[%d] is nil",i);
                return;
            end
            if(v == level) then
                btn:SetFocus(true);
                btn:TabSel(true);
            else
                btn:SetFocus(false);
                btn:TabSel(false);
            end
        end
	end
end

function p.RefreshRankList()
    local container = p.GetListContainer();
    container:RemoveAllView();
    --container:EnableScrollBar(true);
    local rectview = container:GetFrameRect();
    --container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
    
    --container:SetViewSize(RankItemSize);
    
    for i, v in ipairs(p.RankIds) do
        if(i~=1) then
            p.CreateRankItem(container,v);
        end
	end
    
    p.SetRankShowPosition(p.RandInfo.LEVEL);
end


function p.SetRankShowPosition(nLevel)
    local container = p.GetListContainer();
    local offset = 3;
    --定位
    local lv = nLevel+1-offset;
    if(lv<2) then
        LogInfo("chh_min");
        lv = 2;
    end
    
    LogInfo("lv:[%d],#p.RankIds:[%d]",lv,#p.RankIds);
    if(lv>=#p.RankIds-RankListCount+1) then
        LogInfo("chh_max");
        lv =#p.RankIds-RankListCount+1;
    end
    
    container:ShowViewById(lv);
end

function p.CreateRankItem(container,i)
    local view = createUIScrollView();
    
    view:Init(false);
    view:SetScrollStyle(UIScrollStyle.Verical);
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

    uiLoad:Load("Rank_R.ini", view, p.OnUIRankItemEvent, 0, 0);
       
    --实例化每一项
    p.RefreshRankItem(view,i);
    
    container:AddView(view);
    uiLoad:Free();
end

function p.RefreshRankItem(view,num)  
    local btn = GetButton(view, p.TagRankItemLabel);
    btn:SetTitle(GetDataBaseDataS("rank_config",num,DB_RANK.RANK_NAME));
    btn:SetParam1(num);
    if(num<=p.RandInfo.LEVEL) then
        btn:SetFontColor(ccc4(0,255,0,255));
    end
    
    local container = p.GetListContainer();
    container:SetViewSize(btn:GetFrameRect().size);
end

function p.GetListContainer()
	local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
	local container = GetScrollViewContainer(layer, p.TagRankList);
	return container;
end

function p.processNet(msgId, data)
	if (msgId == nil ) then
		LogInfo("magmount processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_USERINFO then
        --p.initRankInfo();
        --p.RefreshCurrRank();
    elseif(msgId == NMSG_Type._MSG_RANK_UPGRADE) then
        --[[
        --军衔升级光效
        PlayEffectAnimation.ShowAnimation( 1 );
        Music.PlayEffectSound(Music.SoundEffect.RANK_UP);
        ]]
        
        local idUser = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_ID);
        SetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_RANK, data);
        
        p.initRankInfo();
        p.RefreshCurrRank();
        local container = p.GetListContainer();
        --container:ShowViewById(p.RandInfo.LEVEL+1);
        p.SetRankShowPosition(p.RandInfo.LEVEL);
        
        local view = container:GetViewById(p.RandInfo.LEVEL);
        if(view) then
            local btn = GetButton(view, p.TagRankItemLabel);
            btn:SetFontColor(ccc4(0,255,0,255));
        end
        
        p.RefreshNextRank(p.RandInfo.LEVEL+1);
	end
end

--提示升级军衔
function p.TipUpgrade()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    local animate = RecursivUISprite(layer,{p.TagTip});
    animate:SetVisible(p.IsUpgrade());
end

--判断军衔是否可升级
function p.IsUpgrade()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RankUI);
    local animate = RecursivUISprite(layer,{p.TagTip});
    
    local RankIds = GetDataBaseIdList("rank_config");
    local requte = GetDataBaseDataN("rank_config",p.RandInfo.LEVEL + 1,DB_RANK.REPUTE);
    if(p.RandInfo.PRESTIGE<requte or p.RandInfo.LEVEL>=#RankIds) then
        return false;
    else
        return true;
    end
end
--提示升级

function p.RankUpTip()
	--是否已经开启功能
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
    --军衔权限判断
    if(nPlayerStage<StageFunc.Rank) then
        return;
    end

	--是否满足升级条件
	local ranklev = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_RANK);
    local requteNeed = GetDataBaseDataN("rank_config",ranklev + 1,DB_RANK.REPUTE);
    local requte = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_REPUTE);
   
    local RankIds = GetDataBaseIdList("rank_config");
    if(ranklev<#RankIds and requte>=requteNeed) then
    
        --光效
        local topbar = MainUI.GetTopBar();
		local btn    =  RecursiveButton(topbar,{21});
		
		if btn == nil then
			LogInfo("RankUpTip 1")
			return;
		end
		
        local pSpriteNode = ConverToSprite( GetUiNode( btn, 99 ) );
    	if ( pSpriteNode ~= nil ) then
    		return;
    	end  

		local pSpriteNode	= createUISpriteNode();
		local btnrect = btn:GetFrameRect();
		local btnWidth =btnrect.size.w;
		local btnHeight = btnrect.size.h;

		pSpriteNode:Init();
		pSpriteNode:SetFrameRect( CGRectMake(-btnWidth*0.15,0,btnWidth,btnHeight) );
		local szAniPath		= NDPath_GetAnimationPath();
		local szSprFile		= "gongn01.spr";
		pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
		pSpriteNode:SetTag(99);
	
		--加到星星node上
    	btn:AddChild( pSpriteNode );
    	p.EffectSprite = pSpriteNode;
    	
    	return;
    end
    
    --移除光效
    p.RemoveEffect();
end

function p.RemoveEffect()
	if p.EffectSprite == nil then
		return;
	end
    
    local effectspr = p.EffectSprite;
	effectspr:RemoveFromParent( true );
    p.EffectSprite	= nil;	
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "RankUI.RankUpTip", p.RankUpTip);
GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"RankUI.RankUpTip",p.RankUpTip);


























