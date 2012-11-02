---------------------------------------------------
--描述: 竞技场结束奖励界面
--时间: 2012.4.13
--作者: cl

---------------------------------------------------
local _G = _G;

RaidersLoad={}
local p=RaidersLoad;

local ID_FIGHTEVALUATE_CTRL_BUTTON_PLAYBACK =71;
local ID_FIGHTEVALUATE_CTRL_BUTTON_CONFIRM =10;
local ID_FIGHTEVALUATE_CTRL_TEXT_INFO =9;
local ID_FIGHTEVALUATE_CTRL_PICTURE_STATE = 8;
local ID_FIGHTEVALUATE_CTRL_PICTURE_7=7;
--NMAINSCENECHILDTAG.RaidersLoad=96890;

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load RaidersLoad failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.RaidersLoad);
    
	local winsize = GetWinSize();
	local ui_size=186*ScaleFactor;
	--layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	layer:SetFrameRect( RectFullScreenUILayer );--++Guosen 2012.7.6
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChildZ(layer,1);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.RaidersLoad);
		
        
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_FIGHT_RESULT.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
 
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RaidersLoad);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.OnUIEvent(uiNode,uiEventType,param)
    local tag = uiNode:GetTag();
    --LogInfo("p.OnUIEvent[%d]",tag);
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        if ID_FIGHTEVALUATE_CTRL_BUTTON_CONFIRM == tag then
            local scene = GetSMGameScene();
            CloseBattle();
            if scene~= nil then
            scene:RemoveChildByTag(NMAINSCENECHILDTAG.RaidersLoad,true);
            MsgAffixBoss.sendNmlLeave();
            --[[local mParentMap = 0;
            mParentMap = NormalBossListUI.getParentMap();
            LogInfo("+++++mParentMap[%d]++++++++++++++",mParentMap);
            WorldMap(mParentMap);
            --++Guosen 2012.7.6//显示副本界面，从隐藏到显示，而不是开启……
            NormalBossListUI.LoadUI(mParentMap);
			--local scene = GetSMGameScene();
			--local layer = GetUiLayer( scene, NMAINSCENECHILDTAG.AffixNormalBoss );
			--if ( nil ~= layer ) then
			--	layer:SetVisible( true );
			--end
			--]]
			--++Guosen 2012.7.20//
            WorldMap(NormalBossListUI.nCampaignID);  
			NormalBossListUI.Redisplay();
            return true;
        end



--[[
         LogInfo("p.OnUIEvent111111[%d]",tag);
            local scene = GetSMGameScene();
            CloseBattle();
        if scene~= nil then
            --local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.RaidersLoad);
            --layer:SetVisible(false);
            scene:RemoveChildByTag(NMAINSCENECHILDTAG.RaidersLoad,true);
            return true;
        end
]]
    elseif ID_FIGHTEVALUATE_CTRL_BUTTON_PLAYBACK == tag then
            LogInfo("p.OnUIEvent111111[%d]",tag);
            restartLastBattle();
        local scene = GetSMGameScene();
        if scene~= nil then
            --local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.RaidersLoad);
            --layer:SetVisible(false);
            scene:RemoveChildByTag(NMAINSCENECHILDTAG.RaidersLoad,true);
            return true;
            end
        end
    end
end