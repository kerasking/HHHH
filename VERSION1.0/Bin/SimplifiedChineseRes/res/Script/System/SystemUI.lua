---------------------------------------------------
--描述: 系统界面
--时间: 2012.5.24
--作者: LLF
---------------------------------------------------

SystemUI = {}
local p = SystemUI

local ID_SYSSET_CTRL_BUTTON_474  = 474;
local ID_SYSSET_CTRL_BUTTON_467  = 467;
local ID_SYSSET_CTRL_BUTTON_468  = 468;
local ID_SYSSET_CTRL_BUTTON_469  = 469;
local ID_SYSSET_CTRL_BUTTON_470  = 470;
local ID_SYSSET_CTRL_BUTTON_471  = 471;  --账号管理
local ID_SYSSET_CTRL_BUTTON_472  = 472;  --金币充值
local ID_SYSSET_CTRL_BUTTON_473  = 473;  --问题反馈

local SYSTEM_BG_MUSIC_KEY = "SYSTEM_BG_MUSIC"
local SYSTEM_EF_SOUND_KEY = "SYSTEM_EF_SOUND"
local SYSTEM_SHOW_OTHER_KEY = "SYSTEM_SHOW_OTHER"
local SYSTEM_SHOW_NAME_KEY = "SYSTEM_SHOW_NAME"

local winsize = GetWinSize();

local isBackMusic = false;
local isGameMusic = false;
local isHidePlayer = false;
local isShowPlayerName = false;

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then   
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.SystemUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI()
	LogInfo("p.LoadUI")
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load SystemUI failed!");
		return;
	end
	local layer = createUIScrollContainer(); 
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.SystemUI);
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	_G.AddChild(scene, layer, NMAINSCENECHILDTAG.SystemUI);

	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	LogInfo("before SM_SYS_SET")
	uiLoad:Load("SM_SYS_SET.ini",layer,p.OnUIEvent,0,0);
	LogInfo("after SM_SYS_SET")
	uiLoad:Free();
	
	p.refreshSystemSetBtn()
end

function p.refreshSystemSetBtn()
	local layer=p.GetParent();
	if nil==layer then
		return;
	end
	
	--背景音乐
	local btn=GetButton(layer,ID_SYSSET_CTRL_BUTTON_467);
	if CheckP(btn) then
		if GetSystemSetB(SYSTEM_BG_MUSIC_KEY,true) then
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T1"));
			isBackMusic=true;
		else
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T2"));
			isBackMusic=false;
		end
	end
	
	--游戏音效
	btn=GetButton(layer,ID_SYSSET_CTRL_BUTTON_468);
	if CheckP(btn) then
		if GetSystemSetB(SYSTEM_EF_SOUND_KEY,true) then
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T1"));
			isGameMusic=true;
		else
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T2"));
			isGameMusic=false;
		end
	end
	
	--隐藏玩家
	btn=GetButton(layer,ID_SYSSET_CTRL_BUTTON_469);
	if CheckP(btn) then
		if GetSystemSetB(SYSTEM_SHOW_OTHER_KEY,true) then
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T2"));
			isHidePlayer=false;
		else
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T1"));
			isHidePlayer=true;
		end
	end
	
	--显示名字
	btn=GetButton(layer,ID_SYSSET_CTRL_BUTTON_470);
	if CheckP(btn) then
		if GetSystemSetB(SYSTEM_SHOW_NAME_KEY,true) then
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T1"));
			isShowPlayerName=true;
		else
			p.InitShowStartOrCloseBtn(btn, GetTxtPri("SUI_T2"));
			isShowPlayerName=false;
		end
	end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	PrintLog("Entry p.OnUIEvent");
	LogInfo("p.OnUIEvent[%d]", tag)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local scene = GetSMGameScene();
		if ID_SYSSET_CTRL_BUTTON_474 == tag then
			scene:RemoveChildByTag(NMAINSCENECHILDTAG.SystemUI, true);
		elseif ID_SYSSET_CTRL_BUTTON_467 == tag then   --背景音乐
			if false == isBackMusic then
				SetSystemSetB(SYSTEM_BG_MUSIC_KEY,true);
				PrintLog("StartBGMusic");
				StartBGMusic();
				p.SetInitStartBtnStatus(uiNode, true);
				isBackMusic = true;
			else
				SetSystemSetB(SYSTEM_BG_MUSIC_KEY,false);
				PrintLog("StartBGMusic");
				StopBGMusic();
				p.SetInitStartBtnStatus(uiNode, false);
				isBackMusic = false;
			end
		elseif ID_SYSSET_CTRL_BUTTON_468 == tag then   --游戏音效
			if false == isGameMusic then
				SetSystemSetB(SYSTEM_EF_SOUND_KEY,true);
				p.SetInitStartBtnStatus(uiNode, true);
				isGameMusic = true;
			else
				SetSystemSetB(SYSTEM_EF_SOUND_KEY,false);
				p.SetInitStartBtnStatus(uiNode, false);
				isGameMusic = false;
			end
		elseif ID_SYSSET_CTRL_BUTTON_469 == tag then   --隐藏玩家
			if false == isHidePlayer then
				SetSystemSetB(SYSTEM_SHOW_OTHER_KEY,false);
				ShowOtherRole(false);
				p.SetInitStartBtnStatus(uiNode, true);
				isHidePlayer = true;
			else
				SetSystemSetB(SYSTEM_SHOW_OTHER_KEY,true);			
				ShowOtherRole(true);
				p.SetInitStartBtnStatus(uiNode, false);
				isHidePlayer = false;
			end
		elseif ID_SYSSET_CTRL_BUTTON_470 == tag then   --显示名字
			if false == isShowPlayerName then
				SetSystemSetB(SYSTEM_SHOW_NAME_KEY,true);	
				ShowRoleName(true);
				p.SetInitStartBtnStatus(uiNode, true);
				isShowPlayerName = true;
			else
				SetSystemSetB(SYSTEM_SHOW_NAME_KEY,false);
				ShowRoleName(false);
				p.SetInitStartBtnStatus(uiNode, false);
				isShowPlayerName = false;
			end
		elseif ID_SYSSET_CTRL_BUTTON_473 == tag then  --问题反馈
			--scene:RemoveChildByTag(NMAINSCENECHILDTAG.SystemUI, true);
			if not IsUIShow(NMAINSCENECHILDTAG.ProblemUI) then
		        ProblemUI.LoadUI();
			end
		elseif ID_SYSSET_CTRL_BUTTON_471 == tag then  --账号管理
			--scene:RemoveChildByTag(NMAINSCENECHILDTAG.SystemUI, true);
			if not IsUIShow(NMAINSCENECHILDTAG.AccountManUI) then
		        AccountManUI.LoadUI();
			end
			
		elseif ID_SYSSET_CTRL_BUTTON_472 == tag then  --金币充值
			MainHeadUI.OpenRechargeUI();
		end
	end
	
	return true
end

function p.SetInitStartBtnStatus(uiNode, isBtnClick)
	if false == isBtnClick then
		p.InitShowStartOrCloseBtn(uiNode, GetTxtPri("SUI_T2"));
	elseif true == isBtnClick then
		p.InitShowStartOrCloseBtn(uiNode, GetTxtPri("SUI_T1"));
	end
end

function p.InitShowStartOrCloseBtn(uiNode, strBtName)
	local button = ConverToButton(uiNode);
	if CheckP(button) then
		button:SetTitle(strBtName)
	end
end