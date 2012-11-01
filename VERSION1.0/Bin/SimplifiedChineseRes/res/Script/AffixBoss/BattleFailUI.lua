---------------------------------------------------
--描述: 战斗失败界面
--时间: 2012.4.6
--作者: cl

---------------------------------------------------
local _G = _G;

BattleFailUI={}
local p=BattleFailUI;

local ID_BATTLEFAIL_CTRL_TEXT_AWARD	=	5;
--战斗回放
local ID_BATTLEFAIL_CTRL_BUTTON_PLAYBACK	=	83;
--退出副本
local ID_BATTLEFAIL_CTRL_BUTTON_COMFIRM	=	3;
--查看攻略
local ID_BATTLEFAIL_CTRL_BUTTON_22 = 4;
--切换技能
local ID_BATTLEFAIL_CTRL_BUTTON_17 = 17;
--再次战斗
local ID_BATTLEFAIL_CTRL_BUTTON_23 = 6;
--返回主城
local ID_BATTLEFAIL_CTRL_BUTTON_GOBACK = 8;

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load BattleFail failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BattleFail);
	local winsize = GetWinSize();
	layer:SetFrameRect(RectFullScreenUILayer);
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("BattleFailUI.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();

    --失败音效
    Music.PlayEffectSound(1093);
    
 	CommonDlgNew.ShowTipDlg("请强化装备或切换技能后再挑战!");   

end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BATTLEFAIL_CTRL_BUTTON_COMFIRM == tag then
            Music.StopMusic();
             LogInfo("+++++smqk++++++++++++++");
			local scene = GetSMGameScene();
            CloseBattle();
			--if scene~= nil then
			--	scene:RemoveChildByTag(NMAINSCENECHILDTAG.BattleFail,true);
			--end
            RemoveChildByTagNew(NMAINSCENECHILDTAG.BattleFail, true,true);
            --local mParentMap = 0;
            --mParentMap = NormalBossListUI.getParentMap();
            --LogInfo("+++++mParentMap[%d]++++++++++++++",mParentMap);
            --WorldMap(mParentMap);
            --++Guosen 2012.7.6//显示副本界面，从隐藏到显示，而不是开启……
            --NormalBossListUI.LoadUI(mParentMap);
			--local scene = GetSMGameScene();
			--local layer = GetUiLayer( scene, NMAINSCENECHILDTAG.AffixNormalBoss );
			--if ( nil ~= layer ) then
			--	layer:SetVisible( true );
			--end
			MsgAffixBoss.sendNmlLeave();
            WorldMap(NormalBossListUI.nCampaignID);  
			NormalBossListUI.Redisplay();
			return true;
		elseif ID_BATTLEFAIL_CTRL_BUTTON_GOBACK == tag then
	        --Music.StopMusic();
            CloseBattle();
            local scene = GetSMGameScene();
			--if scene ~= nil then
			--	scene:RemoveChildByTag(NMAINSCENECHILDTAG.BattleFail,true);
			--end
            RemoveChildByTagNew(NMAINSCENECHILDTAG.BattleFail, true,true);
            MsgAffixBoss.sendNmlLeave();
            NormalBossListUI.OnBtnBack();
            return true;
            
        elseif ID_BATTLEFAIL_CTRL_BUTTON_PLAYBACK== tag then
            LogInfo("+++++bushiba++++++++++++++");
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.BattleFail,true);
            end
            
			restartLastBattle();
			return true;
        elseif ID_BATTLEFAIL_CTRL_BUTTON_22 == tag then
            --[[local bossID = 0;
            bossID = NormalBossListUI.getBossID();
            LogInfo("bossID[%d]",bossID);
            local mParentMap = 0;
            mParentMap = NormalBossListUI.getParentMap();
            local lst, count = AffixBossFunc.findBossList(mParentMap, 0);
            local t = lst[bossID];
			--local round = GetCurrentMonsterRound();
            local round=0;
            LogInfo("===round[%d]======",round);
            _G.MsgDynMap.SendDynMapGuide(round,t.typeid);]]
            _G.MsgDynMap.SendDynMapGuide(0,NormalBossListUI.nChosenBattleID);
            LogInfo("BattleFailUI.lua NormalBossListUI.nChosenBattleID = %d",NormalBossListUI.nChosenBattleID);
           
        elseif ID_BATTLEFAIL_CTRL_BUTTON_17 == tag then
            MartialUI.LoadUI();
            
        elseif ID_BATTLEFAIL_CTRL_BUTTON_23 == tag then
            Music.StopMusic();
            local scene = GetSMGameScene();
            CloseBattle();
            if scene~= nil then
                scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
            end	
			MsgAffixBoss.sendNmlLeave();
			MsgAffixBoss.sendNmlEnter(NormalBossListUI.nChosenBattleID);
			return true;
        end
	end
end