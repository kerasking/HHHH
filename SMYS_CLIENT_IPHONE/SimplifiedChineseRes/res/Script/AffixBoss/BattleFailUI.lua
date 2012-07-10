---------------------------------------------------
--描述: 战斗失败界面
--时间: 2012.4.6
--作者: cl

---------------------------------------------------
local _G = _G;

BattleFailUI={}
local p=BattleFailUI;

local ID_BATTLEFAIL_CTRL_TEXT_AWARD	=	5;
local ID_BATTLEFAIL_CTRL_BUTTON_PLAYBACK	=	4;
local ID_BATTLEFAIL_CTRL_BUTTON_COMFIRM	=	3;

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
	layer:SetFrameRect( CGRectMake(winsize.w /4, winsize.h * 5/16, winsize.w /2, winsize.h * 3 / 8));
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
end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_BATTLEFAIL_CTRL_BUTTON_COMFIRM == tag then
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.BattleFail,true);
				return true;
			end
		elseif ID_BATTLEFAIL_CTRL_BUTTON_PLAYBACK == tag then
			restartLastBattle();
		end
	end
end