---------------------------------------------------
--描述: 攻略界面
--时间: 2012.3.22
--作者: cl

---------------------------------------------------
local _G = _G;

DynMapGuide={}
local p=DynMapGuide;

local ID_DYNMAPGUIDE_CTRL_TEXT_NAME1 = 251;
local ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL1 = 252;

local ID_DYNMAPGUIDE_CTRL_TEXT_NAME2 = 253;
local ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL2 = 254;

local ID_DYNMAPGUIDE_CTRL_TEXT_NAME3 = 255;
local ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL3 = 256;

local ID_DYNMAPGUIDE_CTRL_TEXT_NAME4 = 257;
local ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL4 = 258;

local ID_DYNMAPGUIDE_CTRL_TEXT_NAME5 = 259;
local ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL5 = 260;

local ID_DYNMAPGUIDE_CTRL_BUTTON_QUIT = 250;

local ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE1 = 261;
local ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE2 = 262;
local ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE3 = 263;
local ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE4 = 264;
local ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE5 = 265;

p.battleId={0,0,0,0,0,}

function p.LoadUI()
    LogInfo("+++++++++++DynMapGuide.load++++++++++");
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load DynMapGuide failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:SetPopupDlgFlag(true);
	layer:Init();
	layer:bringToTop();
	layer:SetDebugName("Gonglue_layer");
	layer:SetTag(NMAINSCENECHILDTAG.DynMapGuide);
	local winsize = GetWinSize();
	--layer:SetFrameRect(RectUILayer);
	layer:SetFrameRect( RectFullScreenUILayer );--++Guosen 2012.7.6
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
    scene:AddChildZ(layer,80);

	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("DynMapGuide.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
end

function p.getUiLayer()
    local scene = GetSMGameScene();
    if not CheckP(scene) then
        return nil;
    end

    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DynMapGuide);
    if not CheckP(layer) then
        LogInfo("nil == layer")
        return nil;
    end

    return layer;
end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_DYNMAPGUIDE_CTRL_BUTTON_QUIT == tag then
            local layer = p.getUiLayer()
                layer:SetVisible(false);
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.DynMapGuide,true);
				return true;
			end
		elseif ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE1 == tag then
            LogInfo("BUTTON_GUIDE1");
			if p.battleId[1] ~= 0 then
               if IsUIShow(NMAINSCENECHILDTAG.BattleFail) then
                    CloseUI(NMAINSCENECHILDTAG.BattleFail);
                    MsgAffixBoss.sendNmlLeave();
               end
               ShowLoadBar();
				_G.MsgArena.SendWatchBattle(p.battleId[1]);
			end
		elseif ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE2 == tag then
            LogInfo("BUTTON_GUIDE2");
			if p.battleId[2] ~= 0 then
                if IsUIShow(NMAINSCENECHILDTAG.BattleFail) then
                    CloseUI(NMAINSCENECHILDTAG.BattleFail);
                    MsgAffixBoss.sendNmlLeave();
                end
                ShowLoadBar();
				_G.MsgArena.SendWatchBattle(p.battleId[2]);
			end
		elseif ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE3 == tag then
            LogInfo("BUTTON_GUIDE3");
			if p.battleId[3] ~= 0 then
                if IsUIShow(NMAINSCENECHILDTAG.BattleFail) then
                    CloseUI(NMAINSCENECHILDTAG.BattleFail);
                    MsgAffixBoss.sendNmlLeave();
                end
                ShowLoadBar();
				_G.MsgArena.SendWatchBattle(p.battleId[3]);
			end
		elseif ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE4 == tag then
            LogInfo("BUTTON_GUIDE4");
			if p.battleId[4] ~= 0 then
                if IsUIShow(NMAINSCENECHILDTAG.BattleFail) then
                    CloseUI(NMAINSCENECHILDTAG.BattleFail);
                    MsgAffixBoss.sendNmlLeave();
                end
                ShowLoadBar();
				_G.MsgArena.SendWatchBattle(p.battleId[4]);
			end
		elseif ID_DYNMAPGUIDE_CTRL_BUTTON_GUIDE5 == tag then
            LogInfo("BUTTON_GUIDE5");
			if p.battleId[5] ~= 0 then
                if IsUIShow(NMAINSCENECHILDTAG.BattleFail) then
                    CloseUI(NMAINSCENECHILDTAG.BattleFail);
                    MsgAffixBoss.sendNmlLeave();
                end
                ShowLoadBar();
				_G.MsgArena.SendWatchBattle(p.battleId[5]);
			end
		end
	end
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DynMapGuide);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.setContent(index,id,name,level)
	local text_tag;
	local level_tag;
	
	if index==1 then

		text_tag=ID_DYNMAPGUIDE_CTRL_TEXT_NAME1;
		level_tag=ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL1;
	elseif index == 2 then
		text_tag=ID_DYNMAPGUIDE_CTRL_TEXT_NAME2;
		level_tag=ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL2;
	elseif index == 3 then
		text_tag=ID_DYNMAPGUIDE_CTRL_TEXT_NAME3;
		level_tag=ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL3;
	elseif index == 4 then
		text_tag=ID_DYNMAPGUIDE_CTRL_TEXT_NAME4;
		level_tag=ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL4;
	elseif index == 5 then
		text_tag=ID_DYNMAPGUIDE_CTRL_TEXT_NAME5;
		level_tag=ID_DYNMAPGUIDE_CTRL_TEXT_LEVEL5;
	end
	
	p.battleId[index]=id;
	local layer=p.GetParent();
	
	SetLabel(layer,text_tag,name);
	SetLabel(layer,level_tag,GetTxtPub("levels")..SafeN2S(level));
end
	
	
