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
    MsgLogin.LeaveInstanceBattle();
	local scene=GetSMGameScene();
	if scene == nil then
		return;
	end
    
	local layer = createNDUILayer();
	if layer == nil then
		return;
	end
    
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.BattleFail);
	local winsize = GetWinSize();
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,2);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return;
	end
	uiLoad:Load("BattleFailUI.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();

    --失败音效
    Music.PlayEffectSound(1093);
 	CommonDlgNew.ShowTipDlg(GetTxtPri("BFU_T1"));   
    GameDataEvent.OnEvent(GAMEDATAEVENT.BATTLE_LOSE_INFO, 0);
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
    
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
        if ID_BATTLEFAIL_CTRL_BUTTON_COMFIRM == tag then         --退出副本
            Music.StopMusic();
            CloseBattle();
            BattleUI_Title.CloseUI();--
            RemoveChildByTagNew(NMAINSCENECHILDTAG.BattleFail, true,true);
			MsgAffixBoss.sendNmlLeave();
            WorldMap(NormalBossListUI.nCampaignID);  
			NormalBossListUI.Redisplay();
			return true;
            
		elseif ID_BATTLEFAIL_CTRL_BUTTON_GOBACK == tag then   --返回主城
            CloseBattle();
            BattleUI_Title.CloseUI();--
            RemoveChildByTagNew(NMAINSCENECHILDTAG.BattleFail, true, true);
            MsgAffixBoss.sendNmlLeave();
            NormalBossListUI.OnBtnBack();
            return true;
            
        elseif ID_BATTLEFAIL_CTRL_BUTTON_PLAYBACK== tag then  --战斗回放
            LogInfo("+++++bushiba++++++++++++++");
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.BattleFail,true);
            end
            
			restartLastBattle();
			return true;
            
        elseif ID_BATTLEFAIL_CTRL_BUTTON_22 == tag then  --查看攻略
            --Music.StopMusic();
            --CloseBattle();
            --RemoveChildByTagNew(NMAINSCENECHILDTAG.BattleFail, true,true);
            
            _G.MsgDynMap.SendDynMapGuide(0,NormalBossListUI.nChosenBattleID);
            
        elseif ID_BATTLEFAIL_CTRL_BUTTON_17 == tag then  --切换技能
            MartialUI.LoadUI();
            
        elseif ID_BATTLEFAIL_CTRL_BUTTON_23 == tag then  --再次挑战
            Music.StopMusic();
            local scene = GetSMGameScene();
            CloseBattle();
            BattleUI_Title.CloseUI();--
            if scene~= nil then
                scene:RemoveChildByTag(NMAINSCENECHILDTAG.MonsterReward,true);
            end	
			MsgAffixBoss.sendNmlLeave();
			MsgAffixBoss.sendNmlEnter(NormalBossListUI.nChosenBattleID);
			return true;
        end
	end
end