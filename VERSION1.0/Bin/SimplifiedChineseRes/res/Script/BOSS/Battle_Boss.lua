---------------------------------------------------
--描述: Boss战活动界面
--时间: 2012.9.17
--作者: chh
---------------------------------------------------


Battle_Boss = {}
local p = Battle_Boss;

local TAG_CLOSE = 27;   --关闭
local TAG_START_BATTLE      = 19;   --开始战斗
local TAG_SILVER_INSPIRE    = 18;   --银币鼓舞
local TAG_COIN_INSPIRE      = 28;   --金币鼓舞
local TAG_AUTO_BATTLE       = 31;   --自动战斗
local TAG_AUTO_BATTLE_TXT   = 29;   --自动战斗说明

local TIMER_GETINFO         = 5;    --定时获得boss数据的时间 单位: s

local TAG_BOSS_TYPE_NAME        = 3;        -- boss type id label
local TAG_BOSS_TYPE_ICON        = 5;        -- boss type icon pic


local TAG_BOSS_LIFE             = 4;        -- boss life progress
local TAG_FIGHTING_CAPACITY     = 24;       -- 玩家增加的战斗力 label
local TAG_COOLING_TIME          = 25;       -- 玩家死亡后的冷却时间 label
local TAG_BOSS_ENDTIME          = 32;       -- boss战结束时间
local TAG_HURT_LIFT             = 34;       -- 对boss造成的伤害
local TAG_RANK_LIST             = 17;       -- 排名 list
local TAG_RANK_SIZE             = 1;        -- 
local TAG_RANK_ORDER            = 2;        -- 排名
local TAG_RANK_NAME             = 3;        -- 玩家名称
local TAG_RANK_HURT             = 4;        -- 伤害



p.nActivityId           = nil;  -- 活动ID
p.nUpData               = nil;  -- 鼓舞星级
p.nTimerGetInfoID       = nil;  -- 定时获得数据
p.nTimerRefreshTimeID   = nil;  -- 刷新时间
p.nCDTime               = nil;  -- 复活CD时间
p.nLeftTime             = nil;  -- boss战剩余时间

function p.LoadUI( nActivityId )
    ArenaUI.isInChallenge = 3;
    p.nActivityId = nActivityId;
    
--------------------获得游戏主场景------------------------------------------
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
--------------------添加Boss战活动层（窗口）---------------------------------------
    local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BattleBossUI );
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,UILayerZOrder.ActivityLayer);
    

-----------------初始化ui添加到 layer 层上----------------------------------

    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("boss/Battle_Boss.ini", layer, p.OnUIEvent, 0, 0);
    
    
    MsgBossBattle.mUIListener = p.ProcessNet;
    
    p.nTimerRefreshTimeID   = RegisterTimer( p.TimerRefreshTimer, 1 );
    p.nTimerGetInfoID       = RegisterTimer( p.TimerGetInfoTimer, TIMER_GETINFO );
    
    MsgLogin.EnterBossBattle(p.nActivityId);
    
    --[[
    --隐藏自动战斗
    local pCheckAuto = RecursiveCheckBox( layer, {TAG_AUTO_BATTLE} );
    pCheckAuto:SetVisible( false );
    
    local lTxt = GetLabel( layer, TAG_AUTO_BATTLE_TXT );
    lTxt:SetVisible( false );
    ]]
    --[[
    --测试Beg
    p.RefreshUI( {nActivityId=1,nCurLife=320000,nLifeLimit=1000000,nLeftTime=1800,nCDTime=10,nDamage=40000,nUpData=60,nAmount=3,RankTable={{sName = "飞机场", nRank = 1, nDamage = 40000},{sName = "平畴呵护", nRank = 2, nDamage = 30000},{sName = "村女哇吧", nRank = 3, nDamage = 20000}}} );
    --测试End
    ]]
end

function p.UnLoadUI( nActivityId )
    MsgLogin.LeaveBossBattle();

    p.FreeData();
    CloseUI(NMAINSCENECHILDTAG.BattleBossUI);
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d],uiEventType:[%d],e:[%d]", tag,uiEventType,NUIEventType.TE_TOUCH_CHECK_CLICK);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if tag == TAG_CLOSE then
           p.UnLoadUI( p.nActivityId );
        elseif tag == TAG_SILVER_INSPIRE then       --银币鼓舞
            --CommonDlgNew.ShowYesDlg("暂不开放", nil, nil, 2);
            
            
            local nCount = MsgBossBattle.GetBossBattleMaxEncourageCount();
            
            if(p.nUpData<nCount) then
                if( p.bIsTip ) then
                    p.SendSilverGuWu();
                else
                    local nRequestCoin = MsgBossBattle.GetBossBattleSilverCount();
                    CommonDlgNew.ShowNotHintDlg(string.format(GetTxtPri("BB2_T1"),nRequestCoin), p.SilverGuwuConfirmCallBack);
                end
            else
                CommonDlgNew.ShowYesDlg(GetTxtPri("BB2_T2"), nil, nil, 2);
            end
            
            
        elseif tag == TAG_COIN_INSPIRE then         --金币鼓舞
            --CommonDlgNew.ShowYesDlg("暂不开放", nil, nil, 2);
            
            local nCount = MsgBossBattle.GetBossBattleMaxEncourageCount();
            if(p.nUpData<nCount) then
                
                if( p.bIsTip ) then
                    p.SendCoinGuWu();
                else
                    local nRequestCoin = MsgBossBattle.GetBossBattleCoinCount();
                    CommonDlgNew.ShowNotHintDlg(string.format(GetTxtPri("BB2_T3"),nRequestCoin), p.CoinGuwuConfirmCallBack);
                end
            else
                CommonDlgNew.ShowYesDlg(GetTxtPri("BB2_T2"), nil, nil, 2);
            end
            
        elseif tag == TAG_START_BATTLE then         --开始战斗
            p.StartBattle();
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
        if tag == TAG_AUTO_BATTLE then          --自动战斗
            local pCheckAuto = ConverToCheckBox( uiNode );
            if pCheckAuto:IsSelect() then
                
                local bFightAuto = GetVipIsOpen(DB_VIP_CONFIG.FIGHT_AUTO);
                if( not bFightAuto ) then
                    pCheckAuto:SetSelect( false );
                    
                    CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("BB2_T4"),GetGetVipLevel_FIGHT_AUTO()), nil, nil, 2);
                end
            end
        end
    end
    return true;
end

p.bIsTip = nil;

function p.CoinGuwuConfirmCallBack( nEventType, param, val )
    LogInfo("p.CoinGuwuConfirmCallBack");
    if(nEventType == CommonDlgNew.BtnOk) then
        p.SendCoinGuWu();
        p.bIsTip = val;
    elseif(nEventType == CommonDlgNew.BtnNo) then
        p.bIsTip = val;
    end
end

function p.SilverGuwuConfirmCallBack( nEventType, param, val )
    LogInfo("p.SilverGuwuConfirmCallBack");
    if(nEventType == CommonDlgNew.BtnOk) then
        p.SendSilverGuWu();
        p.bIsTip = val;
    elseif(nEventType == CommonDlgNew.BtnNo) then
        p.bIsTip = val;
    end
end

--发送金币鼓舞
function p.SendCoinGuWu()
    local nRequestCoin = MsgBossBattle.GetBossBattleCoinCount();
    if( p.EMoneyNotEnough(nRequestCoin) == false ) then
        return;
    end
    
    local nBossTypeId = GetDataBaseDataN("event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.BOSS_TYPE_ID);
    MsgBossBattle.BossBattleCoinEncourage( nBossTypeId );
end

--发送银币鼓舞
function p.SendSilverGuWu()
    local nRequestCoin = MsgBossBattle.GetBossBattleSilverCount();
    if( p.MoneyNotEnough(nRequestCoin) == false ) then
        return;
    end
    
    local nBossTypeId = GetDataBaseDataN("event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.BOSS_TYPE_ID);
    MsgBossBattle.BossBattleSilverEncourage( nBossTypeId );
end

--银币不足
function p.MoneyNotEnough(m)
    local nPlayerId     = GetPlayerId();
    local money         = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
    
    if(money<m) then
        CommonDlgNew.ShowYesDlg(GetTxtPub("TongQianBuZhu"), nil, nil, 2);
        return false;
    end
    return true;
end

--金币不足
function p.EMoneyNotEnough(em)
    local nPlayerId     = GetPlayerId();
    local emoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
    if(emoney<em) then
        CommonDlgNew.ShowYesDlg(GetTxtPub("JinBiBuZhu"), nil, nil, 2);
        return false;
    end
    return true;
end




p.nDlgId = nil;

--开始战斗
function p.StartBattle()
    
    local btnBattle = GetButton( p.GetCurrLayer(), TAG_START_BATTLE );
            
    if(btnBattle:GetTitle() == GetTxtPri("BB_T1")) then
        local nBossTypeId = GetDataBaseDataN("event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.BOSS_TYPE_ID);
        MsgBossBattle.StartBattle( nBossTypeId );
    else
        p.nDlgId = CommonDlgNew.ShowYesOrNoDlg(GetTxtPri("BB_T3"), p.ReviveCallback);
    end

end

function p.ReviveCallback(nEventType, param)
    p.nDlgId = nil;
    if(CommonDlgNew.BtnOk == nEventType) then
        
        local nPlayerId     = GetPlayerId();
        local gmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
        if(10>gmoney) then
            CommonDlgNew.ShowYesDlg(GetTxtPub("JinBiBuZhu"));
            return;
        end
        
        --金币复活战斗
        local nBossTypeId = GetDataBaseDataN("event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.BOSS_TYPE_ID);
        MsgBossBattle.Revive( nBossTypeId );
    end
end

--退出释放数据
function p.FreeData()
    p.nActivityId   = nil;
    p.nUpData       = nil;
    p.nCDTime       = nil;
    p.nLeftTime     = nil;
    p.nDlgId        = nil;
    p.nBossTotalLife = nil;
    MsgBossBattle.mUIListener = nil;
    
    if p.nTimerRefreshTimeID then
        UnRegisterTimer( p.nTimerRefreshTimeID );
        p.nTimerRefreshTimeID = nil;
    end
    
    if p.nTimerGetInfoID then
        UnRegisterTimer( p.nTimerGetInfoID );
        p.nTimerGetInfoID = nil;
    end
end

function p.ProcessNet(msgId, data)
	if (msgId == nil ) then
		LogInfo("MsgBossBattle processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_BOSS_BATTLE_INFO then
        p.RefreshUI( data );
	end
end

p.nBossTotalLife = nil;
--刷新UI
function p.RefreshUI( data )
    LogInfo("Battle_Boss.RefreshUI");
    
    p.nBossTotalLife = data.nLifeLimit;
    
    local layer = p.GetCurrLayer();
    if( layer == nil ) then
        LogInfo("Battle_Boss.RefreshUI layer is nil!");
        return;
    end
    
    -- 数据
    local nBossTypeName = ConvertS( GetDataBaseDataS( "event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.NAME ) );
    local nBossTypeIcon = GetDataBaseDataN( "event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.NAME );
    
    -- 控件
    local picBossTypeIcon   = GetImage( layer, TAG_BOSS_TYPE_ICON );
    local expCurrLift       = RecursivUIExp( layer, {TAG_BOSS_LIFE} );
    local container         = p.GetListContainer();
    
    -- 控件赋值
    SetLabel( layer, TAG_BOSS_TYPE_NAME, nBossTypeName );
    SetLabel( layer, TAG_FIGHTING_CAPACITY, data.nUpData..GetTxtPri("BB2_T5") );
    SetLabel( layer, TAG_COOLING_TIME, string.format("%d%s",data.nCDTime,GetTxtPub("second")) );
    SetLabel( layer, TAG_BOSS_ENDTIME, FormatTime( data.nLeftTime, 0 ) );
    SetLabel( layer, TAG_HURT_LIFT, data.nDamage.."" );
    picBossTypeIcon:SetPicture( GetBossTypePic( p.nActivityId ) );
    expCurrLift:SetProcess( data.nCurLife ); expCurrLift:SetTotal( data.nLifeLimit );
    
    
    --排名刷新

    --container:RemoveAllView();
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview);
    container:EnableScrollBar(true);

    
    local RankTable = data.RankTable;
    for i,v in ipairs( RankTable ) do
        v.nRank = i;
        p.CreateRankItem(container,v);
    end
    
    --设置数据
    p.nCDTime   = data.nCDTime;
    p.nLeftTime = data.nLeftTime;
    p.nUpData   = data.nUpData;
end


function p.CreateRankItem(container, v)

    local uiLoad = nil;
    local view = container:GetViewById(v.nRank);

    if( view == nil ) then
        
        view = createUIScrollView();
        view:Init( false );
        view:SetScrollStyle( UIScrollStyle.Verical );
        view:SetViewId( v.nRank );
        view:SetTag( v.nRank );
        view:SetMovableViewer( container );
        view:SetScrollViewer( container );
        view:SetContainer( container );
        
        --初始化ui
        uiLoad = createNDUILoad();
        if nil == uiLoad then
            return false;
        end

        uiLoad:Load("boss/Battle_Boss_L.ini", view, nil, 0, 0);

        LogInfo("v.nRank true:[%d]",v.nRank);
    else
        LogInfo("v.nRank false:[%d]",v.nRank);
    end
    
    --实例化每一项
    p.RefreshRankItem( view, v );
    
    if( uiLoad ) then
        container:AddView( view );

        uiLoad:Free();
    end
end

function p.RefreshRankItem( view, v )  
    if( view == nil ) then
        LogInfo("p.RefreshRankItem view is nil!");
        return;
    end
    SetLabel( view, TAG_RANK_ORDER, v.nRank.."" );
    SetLabel( view, TAG_RANK_NAME, v.sName );
    --SetLabel( view, TAG_RANK_HURT, string.format("%d(%d\%)",v.nDamage,v.nDamage/p.nBossTotalLife));
    SetLabel( view, TAG_RANK_HURT, v.nDamage.."");

    local pic   = GetImage( view, TAG_RANK_SIZE );
    if( pic ) then
        local container = p.GetListContainer();
        container:SetViewSize(pic:GetFrameRect().size);
    end
end


--定时刷新时间
function p.TimerRefreshTimer()
    p.RefreshCdTime();
    p.RefreshLeftTime();
end

--刷新CD时间
function p.RefreshCdTime()
    local layer = p.GetCurrLayer();
    if( layer == nil ) then
        LogInfo("p.TimerRefreshTimer layer is nil!");

        p.FreeData();

        return;
    end
    p.nCDTime   = p.nCDTime - 1;
    
    local btnBattle = GetButton( layer, TAG_START_BATTLE );
    
    if( p.nCDTime and p.nCDTime<0 ) then
        p.nCDTime = 0;  --可战斗显示
        
        --自动战斗
        local pCheckAuto = RecursiveCheckBox( layer, {TAG_AUTO_BATTLE} );
        if ( pCheckAuto:IsSelect() and layer:IsVisibled() ) then
        
            if p.nDlgId then
                CommonDlgNew.CloseDlg( p.nDlgId, CommonDlgNew.BtnNo );
            end
        
            local nBossTypeId = GetDataBaseDataN("event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.BOSS_TYPE_ID);
            MsgBossBattle.StartBattle( nBossTypeId );
        end
        
        btnBattle:SetTitle(GetTxtPri("BB_T1"));
    else    --消费金币可战斗显示
        btnBattle:SetTitle(GetTxtPri("BB_T2"));
    end
    
    SetLabel( p.GetCurrLayer(), TAG_COOLING_TIME, string.format("%d%s",p.nCDTime,GetTxtPub("second")) );
end

--刷新结束时间
function p.RefreshLeftTime()
    local layer = p.GetCurrLayer();
    if( layer == nil ) then
        LogInfo("p.TimerRefreshTimer layer is nil!");

        p.FreeData();

        return;
    end
    p.nLeftTime = p.nLeftTime - 1;
    
    if( p.nLeftTime and p.nLeftTime<0 ) then
        p.nLeftTime = 0;    --boss剩余时间为0,boss战结束
    end
    
    SetLabel( p.GetCurrLayer(), TAG_BOSS_ENDTIME, FormatTime( p.nLeftTime, 0 ) );
end

--定时获得数据
function p.TimerGetInfoTimer()
    local layer = p.GetCurrLayer();
    if( layer == nil ) then
        LogInfo("p.TimerRefreshTimer layer is nil!");

        p.FreeData();

        return;
    end
    
    local nBossTypeId = GetDataBaseDataN("event_activity", p.nActivityId, DB_EVENT_ACTIVITY_CONFIG.BOSS_TYPE_ID);
    MsgBossBattle.GetBossInfo( nBossTypeId );
end


--获得boss战斗层
function p.GetCurrLayer()
    local scene = GetSMGameScene();
	if nil == scene then
        LogInfo("p.GetCurrLayer scene is nil!");
		return nil;
	end
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.BattleBossUI);
	if nil == layer then
        LogInfo("p.GetCurrLayer layer is nil!");
		return nil;
	end
    return layer;
end

--排名容器
function p.GetListContainer()
	local layer = p.GetCurrLayer();
    if nil == layer then
        LogInfo("p.GetListContainer layer is nil!");
		return nil;
	end
	local container = GetScrollViewContainer(layer, TAG_RANK_LIST);
	return container;
end





