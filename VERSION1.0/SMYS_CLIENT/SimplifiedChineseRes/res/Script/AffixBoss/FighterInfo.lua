---------------------------------------------------
--描述: 战斗信息UI
--时间: 2012.3.30
--作者: cl

---------------------------------------------------
local _G = _G;

FighterInfo = {};
local p = FighterInfo;

local ID_SM_ZDBX_ROLE_STATE_CTRL_BUTTON_CLOSE	=	5;
local ID_SM_ZDBX_ROLE_STATE_CTRL_TEXT_SKILL_NAME	=	11;
local ID_SM_ZDBX_ROLE_STATE_CTRL_TEXT_ROLE_NAME		=	2;
local ID_SM_ZDBX_ROLE_STATE_CTRL_EXP_BLOOD			=14;
local ID_SM_ZDBX_ROLE_STATE_CTRL_EXP_MOMENTUM		= 15;

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.FighterInfo);
	if nil == layer then
		return nil;
	end

	return layer;
end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_SM_ZDBX_ROLE_STATE_CTRL_BUTTON_CLOSE == tag then
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.FighterInfo,true);
				return true;
			end
		end
	end
end

function p.LoadUI(x,y)
	LogInfo("load fighterInfo");
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load FighterInfo failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.FighterInfo);
	local winsize = GetWinSize();
	if (x+winsize.w/2)>winsize.w then
		x=x-winsize.w/2;
	end
	
	if (y+winsize.h*0.4)>winsize.h then
		y=y-winsize.h*0.4;
	end
	
	layer:SetFrameRect( CGRectMake(x, y, winsize.w /2, winsize.h * 0.4));
	--layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_ZDBX_ROLE_STATE.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
end

function p.CloseFighterInfo()
	local scene = GetSMGameScene();
	if scene~= nil then
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.FighterInfo,true);
		return true;
	end
end

function p.UpdateHp(hp,maxHp)
	local layer=p.GetParent();
	if nil==layer then
		return false;
	end
	local lifeBar = RecursivUIExp(layer, {ID_SM_ZDBX_ROLE_STATE_CTRL_EXP_BLOOD} );
	if CheckP(lifeBar) then
		--LogInfo("setBossHP:%d/%d",currentlife,totalLife);
		lifeBar:SetProcess(hp);
		-- todo
		lifeBar:SetTotal(maxHp);
	else
		LogInfo("lifeBar not find");
	end
end

function p.UpdateMp(mp,maxMp)
	local layer=p.GetParent();
	if nil==layer then
		return false;
	end
	local manaBar = RecursivUIExp(layer, {ID_SM_ZDBX_ROLE_STATE_CTRL_EXP_MOMENTUM} );
	if CheckP(manaBar) then
		--LogInfo("setBossHP:%d/%d",currentlife,totalLife);
		manaBar:SetProcess(mp);
		-- todo
		manaBar:SetTotal(maxMp);
	else
		LogInfo("manaBar not find");
	end
end

function p.SetFighterInfo(name,skillName)
	local layer=p.GetParent();
	if nil==layer then
		return false;
	end
	--local skillName=GetDataBaseDataS("skill_config",skillId,DB_SKILL_CONFIG.NAME);
	SetLabel(layer,ID_SM_ZDBX_ROLE_STATE_CTRL_TEXT_ROLE_NAME,name);
	SetLabel(layer,ID_SM_ZDBX_ROLE_STATE_CTRL_TEXT_SKILL_NAME,skillName);
	return true;
end