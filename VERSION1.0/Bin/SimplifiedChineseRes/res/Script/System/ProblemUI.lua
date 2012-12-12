---------------------------------------------------
--描述: 提交问题界面
--时间: 2012.5.24
--作者: LLF
---------------------------------------------------

ProblemUI = {}
local p = ProblemUI

local ID_PROBLEM_CTRL_BUTTON_RECHARGE   = 11;  --提交问题
local ID_PROBLEM_CTRL_BUTTON_FIND       = 12;  --查看问题
local ID_PROBLEM_CTRL_BUTTON_121        = 121; --选中按钮
local ID_PROBLEM_CTRL_BUTTON_172        = 172;
local ID_PROBLEM_CTRL_BUTTON_173        = 173;
local ID_PROBLEM_CTRL_BUTTON_174        = 174;
local ID_PROBLEM_CTRL_BUTTON_27         = 27;   --确认 
local ID_PROBLEM_CTRL_BUTTON_952        = 952;  --取消
local ID_PROBLEM_CTRL_BUTTON_14         = 14;   --关闭
local ID_PROBLEM_CTRL_INPUT_BUTTON_1363 = 1363  --内容输入

local selCheckTag = 0; 
local nextCheckBox = 0;

p.sendContent = 
{
	text = "",
	strProblemType = "",
	strPlayerName = "",
	textContent = "";
	sendProType = 0;
	gm = GetTxtPri("GMPU_T1");
    gmTipsMsg = GetTxtPri("GMPU_T2");
}

local isSelBug = false;
local isSelTouSu = false;
local isSelAdjest = false;
local isSelOther = false;

local winsize = GetWinSize();

function p.InitSendContent()
	p.sendContent.text = ""
	p.sendContent.strProblemType = "";
	p.sendContent.strPlayerName = "";
	p.sendContent.textContent = "";
	p.sendContent.sendProType = 0;
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then   
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ProblemUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI()
	LogInfo("p.LoadUI")
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load ProblemUI failed!");
		return;
	end
	local layer = createUIScrollContainer(); --createNDUILayer(); 
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ProblemUI);
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	--layer:SetFrameRect(CGRectMake(winsize.w*0.08, winsize.h*0.08, winsize.w, winsize.h));
	_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ProblemUI);	
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	p.InitProblemType();
	p.sendContent.text = "";
	
	LogInfo("before SM_SYS_QA_CONTENT.ini")
	selCheckTag = 121;
	uiLoad:Load("SM_SYS_QA_CONTENT.ini",layer,p.OnUIEvent,0,0);
	p.InitBugSelStatus(layer)
	LogInfo("after SM_SYS_QA_CONTENT.ini")
	uiLoad:Free();
	
	p.SetBtnSelStatus(layer);
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag)

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local scene = GetSMGameScene();
		if ID_PROBLEM_CTRL_BUTTON_14 == tag or ID_PROBLEM_CTRL_BUTTON_952 == tag then
			p.InitProblemType();
			scene:RemoveChildByTag(NMAINSCENECHILDTAG.ProblemUI, true);
		elseif ID_PROBLEM_CTRL_BUTTON_FIND == tag then
			scene:RemoveChildByTag(NMAINSCENECHILDTAG.ProblemUI, true);
			LogInfo("ID_PROBLEM_CTRL_BUTTON_FIND")
			_G.MsgProFeedback.CheckProFeedback();
		elseif ID_PROBLEM_CTRL_BUTTON_27 == tag then
			p.SetSendContent(scene);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		local curCheck = ConverToCheckBox(uiNode);
		local layer = p.GetParent();
		if CheckP(curCheck) then
			local preCheck = RecursiveCheckBox(layer, {selCheckTag});
			if selCheckTag ~= tag then
				if CheckP(preCheck) then 
					preCheck:SetSelect(false);
				end
			end
			selCheckTag = tag;
		end
		p.SetContentTopSign(curCheck, tag);
		
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
		--用户按下键盘的返回键
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if ID_PROBLEM_CTRL_INPUT_BUTTON_1363 == tag then
			p.sendContent.text = edit:GetText();
                LogInfo("eidt text [%s]", p.sendContent.text);
			end
        end
		
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
	end
	
	return true;
end

function p.SetBtnSelStatus(layer)
	LogInfo("p.SetBtnSelStatus begin")
	local btnSelStatus = GetButton(layer, ID_PROBLEM_CTRL_BUTTON_RECHARGE);
	if not CheckP(btnSelStatus) then
		LogInfo("btnSelStatus is not exist!");
		layer:Free();
		return;
	end
	local btnUnSelStatus = GetButton(layer, ID_PROBLEM_CTRL_BUTTON_FIND)
	if not CheckP(btnUnSelStatus) then
		LogInfo("btnUnSelStatus is not exist!");
		layer:Free();
		return;
	end
	
	local chkTab = createUITabLogic();
	if not CheckP(chkTab) then
		layer:Free();
		return;
	end
	
	chkTab:Init();
	layer:AddChild(chkTab);

	chkTab:AddTab(btnSelStatus, nil);
	chkTab:AddTab(btnUnSelStatus, nil);
	
	chkTab:SelectWithIndex(0);
	LogInfo("p.SetBtnSelStatus end")	
end

function p.SetSendContent(scene)
	if nil == p.sendContent.text or string.len(p.sendContent.text) <= 0 then
		CommonDlg.ShowTipInfo(GetTxtPub("tip"), GetTxtPri("GMPU_T9"), nil, 2);
		return;
	else
		local strPlayerName = "";
		strPlayerName = GetRoleBasicDataS(ConvertN(GetPlayerId()), USER_ATTR.USER_ATTR_NAME) .. ":";
		LogInfo("name= %s", strPlayerName);
		local strProblemType = "";
		local textContent = "";
		local sendProType = 0;
		if isSelBug then
			LogInfo("isSelBug = true")
			strProblemType = GetTxtPri("GMPU_T4");
			sendProType = 0;
		elseif isSelTouSu then
			strProblemType = GetTxtPri("GMPU_T5");
			sendProType = 1;
		elseif isSelAdjest then
			strProblemType = GetTxtPri("GMPU_T6");
			sendProType = 2;
		elseif isSelOther then
			strProblemType = GetTxtPri("GMPU_T7");
			sendProType = 3;
		end
		
		textContent = strProblemType .. p.sendContent.text;
		LogInfo("textContent= %s", textContent)
		
		p.sendContent.strProblemType = strProblemType;
		p.sendContent.strPlayerName = strPlayerName;
		p.sendContent.textContent = textContent;
		p.sendContent.sendProType = sendProType;
		
		
		LogInfo("befor _G_Msg......")
		if false == _G.MsgProFeedback.SendProFeedback(sendProType, textContent) then
			CommonDlg.ShowTipInfo(GetTxtPub("tip"), GetTxtPri("GMPU_T8"), nil, 2);
			return
		end
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ProblemUI, true);
		LogInfo("after _G_Msg......")	
		
		--[[
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ProblemUI, true);
		CheckProblemUI.LoadUI();
		CheckProblemUI.AddTextContent(strPlayerName, textContent, p.sendContent.gm, p.sendContent.gmTipsMsg);
		--]]
	end
end

function p.SetContentTopSign(curCheck, tag)
	if ID_PROBLEM_CTRL_BUTTON_121 == tag then
		p.InitProblemType();
		if curCheck:IsSelect() then
			LogInfo("isSelBug")
			isSelBug = true;
		end
	elseif ID_PROBLEM_CTRL_BUTTON_172 == tag then
		p.InitProblemType();
		if curCheck:IsSelect() then
		LogInfo("isSelTouSu")
			isSelTouSu = true;
		end
	elseif ID_PROBLEM_CTRL_BUTTON_173 == tag then
		p.InitProblemType();
		if curCheck:IsSelect() then
		LogInfo("isSelAdjest")
			isSelAdjest= true;
		end
	elseif ID_PROBLEM_CTRL_BUTTON_174 == tag then
		p.InitProblemType();
		if curCheck:IsSelect() then
		LogInfo("isSelOther")
			isSelOther= true;
		end
	end
end

function p.InitProblemType()
	isSelTouSu = false;
	isSelBug = false;
	isSelAdjest = false;
	isSelOther = false;
end

function p.InitBugSelStatus(layer)
	local preCheck = RecursiveCheckBox(layer, {ID_PROBLEM_CTRL_BUTTON_121});
	if CheckP(preCheck) then 
		if false == preCheck:IsSelect() then
			preCheck:SetSelect(true);
			isSelBug = true;
		end
	end
end

--[[
function p.OnCommonDlgSure(nId, nEvent, param)
	if nEvent == CommonDlg.EventOK then
		if false == p.SureToUse() then
			CommonDlg.ShowTipInfo("提示", "发送内容不能为空！", nil, 2);
		else
			--消息发送
			
		end
	end
end--]]




