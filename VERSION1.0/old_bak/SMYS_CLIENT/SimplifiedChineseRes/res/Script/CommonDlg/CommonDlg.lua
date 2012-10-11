
---------------------------------------------------
--描述: 通用对话框
--时间: 2012.4.10
--作者: jhzheng
---------------------------------------------------

---------------------------------说明----------------------------
----事件回调原型-----
--function (nId, nEvent, param)

---带有不再提示的消息二次确认框------弹出窗口表现案2.1
--function CommonDlg.ShowNoPrompt(tip, callback, bHideNoPrompt)

---普通消息二次确定框------弹出窗口表现案2.2
--function p.ShowWithPic(tip, callback, pic)

---消息确认框------弹出窗口表现案2.3
--function p.ShowWithConfirm(tip, callback)

---消息提示框------弹出窗口表现案3.1
--function p.ShowTipOk(title, content, callback, timeout)

---消息提示框------弹出窗口表现案3.2
--function p.ShowTipInfo(title, content, callback, timeout)

----------------------------------------------------------------

CommonDlg = {};
local p = CommonDlg;

local winsize = GetWinSize();

p.EventBegin					= 0;
p.EventOK						= 1; --确定
p.EvnetClose					= 2; --关闭
p.EventCheck					= 3; --勾选
p.EventEnd						= 4;

---事件回调列表
local tCallBackList = {};

---关闭一个对话框
function p.CloseOneDlg()
	local bSucess, nId = p.GetTopDlgId();
	if not bSucess then
		LogInfo(" p.CloseOneDlg not bSucess");
		return false;
	end
	
	if not p.CloseDlg(nId) then
		LogInfo("p.CloseOneDlg not p.CloseDlg[%d]", nId);
		return false;
	end
	
	return true;
end

---带有不再提示的消息二次确认框------弹出窗口表现案2.1
local ID_NO_PROMPT_CTRL_TEXT_NO_PROMPT				= 147;
local ID_NO_PROMPT_CTRL_CHECK_BUTTON_NO_PROMPT		= 146;
local ID_NO_PROMPT_CTRL_BUTTON_CLOSE				= 7;
local ID_NO_PROMPT_CTRL_BUTTON_CANCEL				= 182;
local ID_NO_PROMPT_CTRL_BUTTON_CONFIRM				= 181;
local ID_NO_PROMPT_CTRL_TEXT_INFO					= 180;
local ID_NO_PROMPT_CTRL_PICTURE_BG					= 179;

local RectUILayerNoPrompt = CGRectMake((winsize.w - 300 * ScaleFactor) / 2, (winsize.h - 138 * ScaleFactor) / 2, 300 * ScaleFactor, 138 * ScaleFactor);

function p.ShowNoPrompt(tip, callback, bHideNoPrompt)
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlg.ShowNoPrompt failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:Init();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectUILayerNoPrompt);
	scene:AddChildZ(layer, 10000);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("No_Prompt.ini", layer, p.OnUIEventNoPrompt, 0, 0);
	uiLoad:Free();
	
	tCallBackList[nTag] = callback;
	
	local lb = RecursiveLabel(scene, {nTag, ID_NO_PROMPT_CTRL_TEXT_INFO});

	if CheckP(lb) then
		if not CheckS(tip) then
			lb:SetText("");
		else
			lb:SetText(tip);
		end
	end
	
	if bHideNoPrompt then
		local checkbox = RecursiveCheckBox(scene, {nTag, ID_NO_PROMPT_CTRL_CHECK_BUTTON_NO_PROMPT});
		if CheckP(checkbox) then
			checkbox:SetVisible(false);
		end
	end
	
	return nTag;
end

function p.OnUIEventNoPrompt(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventNoPrompt[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlg.OnUIEventNoPrompt dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_NO_PROMPT_CTRL_BUTTON_CLOSE == tag then
			p.CloseDlg(nDlgId);
		elseif ID_NO_PROMPT_CTRL_BUTTON_CONFIRM == tag then
			p.OnDlgEvent(nDlgId, p.EventOK);
			p.CloseDlg(nDlgId);
		elseif ID_NO_PROMPT_CTRL_BUTTON_CANCEL == tag then
			p.CloseDlg(nDlgId);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		local checkBox	= ConverToCheckBox(uiNode);
		if not CheckP(checkBox) then
			return true;
		end
		if tag == ID_NO_PROMPT_CTRL_CHECK_BUTTON_NO_PROMPT then
			p.OnDlgEvent(nDlgId, p.EventCheck, checkBox:IsSelect());
		end
	end
	
	return true;
end

---普通消息二次确定框------弹出窗口表现案2.2
local ID_A_CTRL_BUTTON_CANCEL				= 21;
local ID_A_CTRL_BUTTON_CONFIRM				= 20;
local ID_A_CTRL_TEXT_INFO					= 19;
local ID_A_CTRL_PICTURE_ICON				= 18;
local ID_A_CTRL_BUTTON_CLOSE				= 17;
local ID_A_CTRL_PICTURE_BG					= 16;


local RectUILayerPicture = CGRectMake((winsize.w - 259 * ScaleFactor) / 2, (winsize.h - 160 * ScaleFactor) / 2, 259 * ScaleFactor, 160 * ScaleFactor);

function p.ShowWithPic(tip, callback, pic)
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlg.ShowWithPic failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:Init();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectUILayerPicture);
	scene:AddChildZ(layer, 10000);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("RestSuggest.ini", layer, p.OnUIEventPic, 0, 0);
	uiLoad:Free();
	
	tCallBackList[nTag] = callback;
	
	local lb = RecursiveLabel(scene, {nTag, ID_A_CTRL_TEXT_INFO});

	if CheckP(lb) then
		if not CheckS(tip) then
			lb:SetText("");
		else
			lb:SetText(tip);
		end
	end
	
	local img = RecursiveImage(scene, {nTag, ID_A_CTRL_PICTURE_ICON});

	if CheckP(img) and CheckP(pic) then
		img:SetPicture(pic);
	end
	
	return nTag;
end

function p.OnUIEventPic(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventPic[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlg.OnUIEventPic dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_A_CTRL_BUTTON_CLOSE == tag then
			p.CloseDlg(nDlgId);
		elseif ID_A_CTRL_BUTTON_CONFIRM == tag then
			p.OnDlgEvent(nDlgId, p.EventOK);
			p.CloseDlg(nDlgId);
		elseif ID_A_CTRL_BUTTON_CANCEL == tag then
			p.CloseDlg(nDlgId);
		end
	end
	
	return true;
end

---消息确认框------弹出窗口表现案2.3
local ID_COPYSUGGEST_CTRL_BUTTON_CONFIRM				= 15;
local ID_COPYSUGGEST_CTRL_BUTTON_CLOSE					= 14;
local ID_COPYSUGGEST_CTRL_TEXT_INFO						= 13;
local ID_COPYSUGGEST_CTRL_PICTURE_BG					= 12;


local RectUILayerConfirm = CGRectMake((winsize.w - 300 * ScaleFactor) / 2, (winsize.h - 138 * ScaleFactor) / 2, 300 * ScaleFactor, 138 * ScaleFactor);

function p.ShowWithConfirm(tip, callback)
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlg.ShowWithConfirm failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:Init();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectUILayerConfirm);
	scene:AddChildZ(layer, 10000);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("CopySuggest.ini", layer, p.OnUIEventConfirm, 0, 0);
	uiLoad:Free();
	
	tCallBackList[nTag] = callback;
	
	local lb = RecursiveLabel(scene, {nTag, ID_COPYSUGGEST_CTRL_TEXT_INFO});

	if CheckP(lb) then
		if not CheckS(tip) then
			lb:SetText("");
		else
			lb:SetText(tip);
		end
	end

	return nTag;
end

function p.OnUIEventConfirm(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventConfirm[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlg.OnUIEventConfirm dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_COPYSUGGEST_CTRL_BUTTON_CLOSE == tag then
			p.CloseDlg(nDlgId);
		elseif ID_COPYSUGGEST_CTRL_BUTTON_CONFIRM == tag then
			p.OnDlgEvent(nDlgId, p.EventOK);
			p.CloseDlg(nDlgId);
		end
	end
	
	return true;
end

---消息提示框------弹出窗口表现案3.1
local tTimeTag2DlgId = {};

local ID_POP_GET_CTRL_BUTTON_CLOSE					= 6;
local ID_POP_GET_CTRL_TEXT_INFO						= 5;
local ID_POP_GET_CTRL_TEXT_NAME						= 4;
local ID_POP_GET_CTRL_PICTURE_ICON					= 3;
local ID_POP_GET_CTRL_PICTURE_2						= 2;

local RectUILayerTipOk = CGRectMake((winsize.w - 182 * ScaleFactor) / 2, (winsize.h - 112 * ScaleFactor) / 2, 182 * ScaleFactor, 112 * ScaleFactor);

function p.ShowTipOk(title, content, callback, timeout)
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlg.ShowTipOk failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:Init();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectUILayerTipOk);
	scene:AddChildZ(layer, 10000);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("Pop_Get.ini", layer, p.OnUIEventTipOk, 0, 0);
	uiLoad:Free();
	
	tCallBackList[nTag] = callback;
	
	local lb = RecursiveLabel(scene, {nTag, ID_POP_GET_CTRL_TEXT_NAME});

	if CheckP(lb) then
		if not CheckS(title) then
			lb:SetText("");
		else
			lb:SetText(title);
		end
	end
	
	lb = RecursiveLabel(scene, {nTag, ID_POP_GET_CTRL_TEXT_INFO});

	if CheckP(lb) then
		if not CheckS(content) then
			lb:SetText("");
		else
			lb:SetText(content);
		end
	end
	
	local nTimeOut = 2;
	if CheckN(timeout) and 0 < timeout then
		nTimeOut = timeout;
	end
	
	local nTimeTag	= _G.RegisterTimer(p.OnProcessTimer, nTimeOut);
	
	if CheckN(nTimeTag) then
		tTimeTag2DlgId[nTimeTag] = nTag;
	end
	
	return nTag;
end

function p.OnUIEventTipOk(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventTipOk[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlg.OnUIEventTipOk dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_POP_GET_CTRL_BUTTON_CLOSE == tag then
			p.CloseDlg(nDlgId);
		end
	end
	
	return true;
end

---消息提示框------弹出窗口表现案3.2
local ID_POP_GET_CTRL_BUTTON_CLOSE					= 6;
local ID_POP_GET_CTRL_TEXT_INFO						= 5;
local ID_POP_GET_CTRL_TEXT_NAME						= 4;
local ID_POP_GET_CTRL_PICTURE_ICON					= 3;
local ID_POP_GET_CTRL_PICTURE_2						= 2;

local RectUILayerTipInfo = CGRectMake((winsize.w - 182 * ScaleFactor) / 2, (winsize.h - 112 * ScaleFactor) / 2, 182 * ScaleFactor, 112 * ScaleFactor);

function p.ShowTipInfo(title, content, callback, timeout)
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load CommonDlg.ShowTipInfo failed!");
		return 0;
	end
	
	local bSucess, nTag = p.GenerateDlgId();
	
	if not bSucess then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:Init();
	layer:SetTag(nTag);
	layer:SetFrameRect(RectUILayerTipInfo);
	scene:AddChildZ(layer, 10000);
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("Pop_VIP.ini", layer, p.OnUIEventTipInfo, 0, 0);
	uiLoad:Free();
	
	tCallBackList[nTag] = callback;
	
	local lb = RecursiveLabel(scene, {nTag, ID_POP_GET_CTRL_TEXT_NAME});

	if CheckP(lb) then
		if not CheckS(title) then
			lb:SetText("");
		else
			lb:SetText(title);
		end
	end
	
	lb = RecursiveLabel(scene, {nTag, ID_POP_GET_CTRL_TEXT_INFO});

	if CheckP(lb) then
		if not CheckS(content) then
			lb:SetText("");
		else
			lb:SetText(content);
		end
	end
	
	local nTimeOut = 2;
	if CheckN(timeout) and 0 < timeout then
		nTimeOut = timeout;
	end
	
	local nTimeTag	= _G.RegisterTimer(p.OnProcessTimer, nTimeOut);
	
	if CheckN(nTimeTag) then
		tTimeTag2DlgId[nTimeTag] = nTag;
	end
	
	return nTag;
end

function p.OnUIEventTipInfo(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventTipInfo[%d]", tag);
	
	local bSucess, nDlgId = p.GetDlgIdByChildNode(uiNode);
	if not bSucess then
		LogError("CommonDlg.OnUIEventTipInfo dlg id error");
		return true;
	end
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_POP_GET_CTRL_BUTTON_CLOSE == tag then
			p.CloseDlg(nDlgId);
		end
	end
	
	return true;
end

-----定时器回调-----
function p.OnProcessTimer(nTag)
	LogInfo("p.OnProcessTimer[%d]", nTag)
	if CheckT(tTimeTag2DlgId) and CheckN(tTimeTag2DlgId[nTag]) then
		p.CloseDlg(tTimeTag2DlgId[nTag]);
	end
	
	_G.UnRegisterTimer(nTag);
end

function p.GetDlgIdByChildNode(child)
	if not CheckP(child) then
		return false, 0;
	end
	
	local dlg = PRecursiveUILayer(child, 1);
	if not CheckP(dlg) then
		return false, 0;
	end
	
	local nTag = dlg:GetTag();
	
	if not p.CheckDlgId(nTag) then
		return false, 0;
	end
	
	return true, nTag;
end

--处理对话框事件
function p.OnDlgEvent(nDlgId, nEventType, param)
	if not CheckN(nEventType) or nEventType <= p.EventBegin or nEventType >= p.EventEnd then
		return;
	end
	if p.CheckDlgId(nDlgId) and CheckFunc(tCallBackList[nDlgId]) then
		tCallBackList[nDlgId](nDlgId, nEventType, param);
	end
end

----对话框销毁-------
function p.CloseDlg(nDlgId)
	if not p.CheckDlgId(nDlgId) then
		return false;
	end
	
	local scene = GetSMGameScene();
	if CheckP(scene) then
		scene:RemoveChildByTag(nDlgId, true);
		return true;
	end
	
	return false;
end

function p.OnDeConstruct(node, bClearUp)
	if CheckP(node) and CheckB(bClearUp) and bClearUp then
		local nTag = node:GetTag();
		if p.CheckDlgId(nTag) and CheckFunc(tCallBackList[nTag]) then
				tCallBackList[nTag](nTag, p.EvnetClose);
				tCallBackList[nTag] = nil;
		end
		
		p.ReturnDlgId(nTag);
		
		for i, v in pairs(tTimeTag2DlgId) do
			if v == nTag then
				_G.UnRegisterTimer(i);
			end
		end
	end 
end

----对话框id生成------
local tIdGen = {};
local nCurId = NMAINSCENECHILDTAG.CommonDlg;
local nMaxId = 65535;
local tIdCur = {};
function p.GenerateDlgId()
	for i=NMAINSCENECHILDTAG.CommonDlg, nMaxId do
		if nil == tIdGen[i] then
			tIdGen[i]	= true;
			if i == nCurId then
				nCurId		= nCurId + 1;
			end
			tIdCur[#tIdCur+1] = i;
			return true, i;
		end
	end
	LogError("对话框id生成 error");
	return false, 0;
end

function p.ReturnDlgId(nId)
	if not p.CheckDlgId(nId) then
		return;
	end
	
	local find = 0;
	for i, v in ipairs(tIdCur) do
		if v == nId then
			find = i;
		end
	end
	
	if find > 0 then
		for i=find, #tIdCur - 1 do 
			tIdCur[find] = tIdCur[find+1];
		end
		tIdCur[#tIdCur] = nil;
	end
	
	tIdGen[nId] = nil;
end

function p.CheckDlgId(nId)
	if not CheckN(nId) or nId < NMAINSCENECHILDTAG.CommonDlg or nId > nMaxId then
		return false;
	end
	
	return true;
end

function p.GetTopDlgId()
	if #tIdCur > 0 and CheckN(tIdCur[#tIdCur]) then
		return true, tIdCur[#tIdCur];
	end
	return false, 0;
end