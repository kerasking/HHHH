---------------------------------------------------
--描述: 主界面练功
--时间: 2012.2.13
--作者: jhzheng
---------------------------------------------------

MainUIPractise = {}
local p = MainUIPractise;

-----------------Practise tag-------------------
local ID_SM_TY_PRACTICE_CTRL_BUTTON_18					= 18;
local ID_SM_TY_PRACTICE_CTRL_TEXT_17						= 17;
local ID_SM_TY_PRACTICE_CTRL_TEXT_16						= 16;
local ID_SM_TY_PRACTICE_CTRL_TEXT_15						= 15;
local ID_SM_TY_PRACTICE_CTRL_TEXT_14						= 14;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_13					= 13;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_12					= 12;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_11					= 11;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_10					= 10;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_9					= 9;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_8					= 8;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_7					= 7;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_6					= 6;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_5					= 5;
local ID_SM_TY_PRACTICE_CTRL_PICTURE_4					= 4;

-----------------PractiseTip tag-----------------
local ID_SM_TY_PHY_CTRL_BUTTON_16					= 17;
local ID_SM_TY_PHY_CTRL_BUTTON_18					= 18;
local ID_SM_TY_PHY_CTRL_TEXT_16						= 16;
local ID_SM_TY_PHY_CTRL_TEXT_15						= 15;
local ID_SM_TY_PHY_CTRL_TEXT_14						= 14;
local ID_SM_TY_PHY_CTRL_PICTURE_13					= 13;
local ID_SM_TY_PHY_CTRL_PICTURE_12					= 12;
local ID_SM_TY_PHY_CTRL_PICTURE_11					= 11;
local ID_SM_TY_PHY_CTRL_PICTURE_10					= 10;
local ID_SM_TY_PHY_CTRL_PICTURE_9					= 9;
local ID_SM_TY_PHY_CTRL_PICTURE_8					= 8;
local ID_SM_TY_PHY_CTRL_PICTURE_7					= 7;
local ID_SM_TY_PHY_CTRL_PICTURE_6					= 6;
local ID_SM_TY_PHY_CTRL_PICTURE_5					= 5;
local ID_SM_TY_PHY_CTRL_PICTURE_4					= 4;

--本地变量
local m_nCountDownTime			= 0;
local m_nCountDownTimeTag		= 0;
local m_bAutoPractise			= false;
local m_bMove					= false;

--N秒倒计时,自动练功(暂定30秒)
local m_nAutoPractiseTimeTag		= 0;
local AUTO_PRACTISE_TIME_COUNT		= 3;
local AUTO_PRACTISE_TIME_INTERVAL	= 10;
local m_nAutoPractiseTimeCount		= 0;

function p.Practise()
	if p.IsPlayerMove() then
		CommonDlg.ShowTipInfo("移动中无法自动练功", "系统稍后自动返回..");
		return;
	end
	
	--todo发送打坐练功(清剿,移动时不能练功)
	--tip 清剿不能自动练功, 移动中无法自动练功
	--if then
	--	CommonDlg.ShowTipInfo("清剿不能自动练功", "系统稍后自动返回..");
	--end
	MsgPractise.SendStart();
end

function p.ShowTip(bShow)
	if not CheckB(bShow) then
		return;
	end
	
	if bShow then
		local container = p.GetTipContainer();
		if not CheckP(container) then
			p.LoadUITip();
		end
	else
		CloseUI(NMAINSCENECHILDTAG.PractiseTip);
	end
end

function p.Show(bShow)
	if not CheckB(bShow) then
		return;
	end
	
	if bShow then
		local container = p.GetContainer();
		if not CheckP(container) then
			p.LoadUI();
		end
	else
		CloseUI(NMAINSCENECHILDTAG.Practise);
	end
end

function p.SetExp(nExp)
	if not CheckN(nExp) then
		return;
	end
	
	local container = p.GetContainer();
	if not CheckN(container) then
		return;
	end
	
	_G.SetLabel(container, ID_SM_TY_PRACTICE_CTRL_TEXT_15, "累计获得 " .. nExp .. "经验");
end

function p.SetBattleAtk(nBattleAtk)
	if not CheckN(nBattleAtk) then
		return;
	end
	
	local container = p.GetContainer();
	if not CheckN(container) then
		return;
	end
	
	_G.SetLabel(container, ID_SM_TY_PRACTICE_CTRL_TEXT_17, "队伍战力" .. nExp);
end

function p.SetTime(nSec)
	if not CheckN(nSec) then
		return;
	end
	
	m_nCountDownTime = nSec;
	p.RefrestTime();
end

function p.LoadUI()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogError("not CheckP(scene),load MainUIPractise failed!");
		return;
	end
	
	local container = createUIScrollContainer();
	if not CheckP(container) then
		LogError("not CheckP(container),load MainUIPractise alloc failed!");
		return;
	end
	
	local winsize	= GetWinSize();
	container:Init();
	container:SetTag(NMAINSCENECHILDTAG.Practise);
	container:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	scene:AddChild(container);
	
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		container:Free();
		return;
	end
	
	uiLoad:Load("SM_TY_PRACTICE.ini", container, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	
	m_nCountDownTimeTag	= _G.RegisterTimer(p.OnProcessTimer, 1);
	container:SetDestroyNotify(p.OnDeConstruct);
	m_bAutoPractise = true;
	
	p.SetBattleAtk(GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_BATTLE_VAL));
	
	p.AutoPracticeTimerStop();
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_TY_PRACTICE_CTRL_BUTTON_18 then
			p.Show(false);
			MsgPractise.SendStop();
		end
	end
	return true;
end

function p.OnTipUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnTipUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_TY_PHY_CTRL_BUTTON_18 then
			p.ShowTip(false);
		elseif tag == ID_SM_TY_PHY_CTRL_BUTTON_16 then
			p.Practise();
		end
	end
	return true;
end

-------------------------------------------
function p.RefrestTime()
	if not CheckN(m_nCountDownTime) then
		return;
	end
	
	if m_nCountDownTime < 0 then
		m_nCountDownTime	= 0;
	end
	
	local strTime = FormatTime(m_nCountDownTime, 1);
	if not CheckS(strTime) then
		return;
	end
	
	_G.SetLabel(container, ID_SM_TY_PRACTICE_CTRL_TEXT_16, "练功时间" .. strTime);
end

function p.GetTipContainer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("scene == nil,p.GetTipContainer failed!");
		return nil;
	end
	
	local container = RecursiveScrollContainer(scene, {NMAINSCENECHILDTAG.PractiseTip});
	return container;
end

function p.GetContainer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("scene == nil,p.GetContainer failed!");
		return nil;
	end
	
	local container = RecursiveScrollContainer(scene, {NMAINSCENECHILDTAG.Practise});
	return container;
end

function p.LoadUITip()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogError("not CheckP(scene),load p.LoadUITip failed!");
		return;
	end
	
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return;
	end
	
	local containerTip = createUIScrollContainer();
	if not CheckP(containerTip) then
		LogError("not CheckP(containerTip),LoadUITip alloc failed!");
		uiLoad:Free();
		return;
	end
	
	local winsize	= GetWinSize();
	containerTip:Init();
	containerTip:SetTag(NMAINSCENECHILDTAG.PractiseTip);
	containerTip:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	scene:AddChild(containerTip);
	
	uiLoad:Load("SM_TY_PHY.ini", containerTip, p.OnTipUIEvent, 0, 0);
	
	uiLoad:Free();
end

function p.CancelPractise()
	if m_bAutoPractise then
		p.Show(false);
	end
end

function p.AutoPracticeTimerStart()
	_G.UnRegisterTimer(m_nAutoPractiseTimeTag);
	m_nAutoPractiseTimeTag = _G.RegisterTimer(p.OnProcessTimerAutoPractise, AUTO_PRACTISE_TIME_INTERVAL);
	m_nAutoPractiseTimeCount = 0;
end

function p.AutoPracticeTimerStop()
	_G.UnRegisterTimer(m_nAutoPractiseTimeTag);
	m_nAutoPractiseTimeCount = 0;
end

--------定时器--------------
function p.OnProcessTimer(nTag)
	if not CheckN(m_nCountDownTimeTag) or
		not CheckN(nTag) or
		nTag ~= m_nCountDownTimeTag then
		return;
	end
	
	if not CheckN(m_nCountDownTime) then
		m_nCountDownTime = m_nCountDownTime - 1;
		return;
	end
	
	p.RefrestTime();
end

function p.OnProcessTimerAutoPractise(nTag)
	if not CheckN(m_nAutoPractiseTimeTag) or
		not CheckN(nTag) or
		nTag ~= m_nAutoPractiseTimeTag then
		return;
	end
	
	if not CheckN(m_nAutoPractiseTimeCount) then
		return;
	end
	
	m_nAutoPractiseTimeCount = m_nAutoPractiseTimeCount + 1;
	
	LogInfo("自动练功计数[%d]", m_nAutoPractiseTimeCount);
	
	if (m_nAutoPractiseTimeCount >= AUTO_PRACTISE_TIME_COUNT) then
		--自动练功时间到
		LogInfo("自动练功倒计时到了");
		p.Practise();
		m_nAutoPractiseTimeCount = 0;
	end
end

function p.OnDeConstruct()
	_G.UnRegisterTimer(m_nCountDownTimeTag);
	m_bAutoPractise = false;
	
	p.AutoPracticeTimerStart();
end

-----------打断练功------------------
-- todo 非清剿状态离线

function p.IsPlayerMove()
	return m_bMove;
end

function p.OnMove()
	p.CancelPractise();
	m_bMove = true;
	
	m_nAutoPractiseTimeCount = 0;
end

function p.OnMoveEnd()
	m_bMove = false;
end

function p.EnterGame()
	p.AutoPracticeTimerStart();
end

function p.QuitGame()
	p.AutoPracticeTimerStop();
end

--进入游戏
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_GENERATE_GAMESCENE, "MainUIPractise.EnterGame", p.EnterGame);

--退出游戏
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_QUITGAME, "MainUIPractise.QuitGame", p.QuitGame);

--玩家移动
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_ONMOVE, "MainUIPractise.OnMove", p.OnMove);
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_ONMOVE_END, "MainUIPractise.OnMoveEnd", p.OnMoveEnd);

----------练功提醒---------------
function p.GameDataUserInfoRefresh(datalist)
	if not CheckT(datalist) then
		LogError("p.GameDataUserInfoRefresh invalid arg");
		return;
	end
	
	for i=1, #datalist, 2 do
		local nEnum = datalist[i];
		local nVal	= datalist[i+1];
		if nEnum and nEnum == USER_ATTR.USER_ATTR_STAMINA then
			if CheckN(nVal) and 0 == nVal then
				local container = p.GetContainer();
				if not CheckP(container) then
					p.ShowTip(true);
				end
			end
		elseif nEnum == USER_ATTR.USER_ATTR_BATTLE_VAL then
			if CheckN(nVal) then
				p.SetBattleAtk(nVal);
			end
		end
	end
end
GameDataEvent.Register(GAMEDATAEVENT.USERATTR, "MainUIPractise.GameDataUserInfoRefresh", p.GameDataUserInfoRefresh);
