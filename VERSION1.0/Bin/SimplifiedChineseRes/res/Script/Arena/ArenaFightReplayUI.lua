---------------------------------------------------
--描述: 竞技场查看以及副本攻略结果界面
--时间: 2012.7.23
--作者: tzq

---------------------------------------------------
local _G = _G;

ArenaFightReplayUI={}
local p=ArenaFightReplayUI;

local ID_FIGHTREPLAY_CTRL_BUTTON_PLAYBACK = 71;       --回放
local ID_FIGHTREPLAY_CTRL_BUTTON_OUT             = 10;       --退出


function p.LoadUI()
	local scene=GetSMGameScene();
    --LogInfo("ArenaFightReplayUI begin");
	if scene == nil then
		LogInfo("scene = nil,load ArenaFightReplayUI failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
    LogInfo("ArenaFightReplayUI begin  layer:Init");
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ArenaFightReplayUI);
    
	local winsize = GetWinSize();
	local ui_size=186*ScaleFactor;
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	scene:AddChildZ(layer,1);

    LogInfo("ArenaFightReplayUI begin  uiLoad=createNDUILoad()");
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_FIGHT_REPLAY.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
    LogInfo("ArenaFightReplayUI end");
end


function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ArenaFightReplayUI);
	if nil == layer then
		return nil;
	end

	return layer;
end


function p.OnUIEvent(uiNode,uiEventType,param)
    local tag = uiNode:GetTag();
    --LogInfo("p.OnUIEvent[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if ID_FIGHTREPLAY_CTRL_BUTTON_OUT == tag then
            LogInfo("p.OnUIEvent111111[%d]",tag);
            local scene = GetSMGameScene();
            CloseBattle();
            BattleUI_Title.CloseUI();--
            --WorldMap(NormalBossListUI.nCampaignID);  
            --LogInfo("NormalBossListUI.nCampaignID111111  = %d", NormalBossListUI.nCampaignID);
            NormalBossListUI.RedisplayWorldMap();
			NormalBossListUI.Redisplay();
            if scene~= nil then
                scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaFightReplayUI,true);
                
                if ArenaUI.isInChallenge == 7 then
                --斗地主
                	Slave.EndBattleNotify();
                end
                
                
                
                return true;
            end
        elseif ID_FIGHTREPLAY_CTRL_BUTTON_PLAYBACK == tag then
            LogInfo("p.OnUIEvent111111[%d]",tag);
            restartLastBattle();
            local scene = GetSMGameScene();
            if scene~= nil then
                scene:RemoveChildByTag(NMAINSCENECHILDTAG.ArenaFightReplayUI,true);
                return true;
            end
        end
    end
end