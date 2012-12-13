---------------------------------------------------
--描述: 提交问题界面
--时间: 2012.7.11
--作者: QBW
---------------------------------------------------

GMProblemUI = {}
local p = GMProblemUI

local ID_PROBLEM_CTRL_BUTTON_RECHARGE   = 11;  --提交问题
local ID_PROBLEM_CTRL_BUTTON_FIND       = 12;  --查看问题
local ID_PROBLEM_CTRL_BUTTON_121        = 121; --选中按钮
local ID_PROBLEM_CTRL_BUTTON_172        = 172;
local ID_PROBLEM_CTRL_BUTTON_173        = 173;
local ID_PROBLEM_CTRL_BUTTON_174        = 174;
local ID_PROBLEM_CTRL_BUTTON_27         = 27;   --确认 
local ID_PROBLEM_CTRL_BUTTON_952        = 952;  --取消
local ID_GM_CTRL_BUTTON_14         = 14;   --关闭
local ID_GM_A_CTRL_INPUT_BUTTON_27 = 1363  --内容输入

--主界面
local ID_GM_CTRL_CHECK_BUTTON_17				= 17;
local ID_GM_CTRL_CHECK_BUTTON_16				= 16;
local ID_GM_CTRL_BUTTON_14					= 14;
local ID_GM_CTRL_PICTURE_2					= 2;
local ID_GM_CTRL_PICTURE_1					= 1;

--提交问题界面
local ID_GM_A_CTRL_INPUT_BUTTON_27			= 27;
local ID_GM_A_CTRL_TEXT_25					= 25;
local ID_GM_A_CTRL_TEXT_24					= 24;
local ID_GM_A_CTRL_TEXT_23					= 23;
local ID_GM_A_CTRL_TEXT_22					= 22;
local ID_GM_A_CTRL_TEXT_21					= 21;
local ID_GM_A_CTRL_TEXT_20					= 20;
local ID_GM_A_CTRL_CHECK_BUTTON_19			= 19;
local ID_GM_A_CTRL_CHECK_BUTTON_18			= 18;
local ID_GM_A_CTRL_CHECK_BUTTON_17			= 17;
local ID_GM_A_CTRL_CHECK_BUTTON_16			= 16;
local ID_GM_A_CTRL_BUTTON_15					= 15;
local ID_GM_A_CTRL_PICTURE_13					= 13;
local ID_GM_A_CTRL_PICTURE_12					= 12;
local ID_GM_A_CTRL_PICTURE_11					= 11;
local ID_GM_A_CTRL_PICTURE_10					= 10;
local ID_GM_A_CTRL_PICTURE_9					= 9;
local ID_GM_A_CTRL_PICTURE_8					= 8;
local ID_GM_A_CTRL_PICTURE_7					= 7;
local ID_GM_A_CTRL_PICTURE_6					= 6;
local ID_GM_A_CTRL_PICTURE_5					= 5;
local ID_GM_A_CTRL_PICTURE_4					= 4;
local ID_GM_A_CTRL_PICTURE_3					= 3;


--查看问题界面
local ID_GM_B_CTRL_TEXT_16					= 16;
local ID_GM_B_CTRL_PICTURE_13					= 13;
local ID_GM_B_CTRL_BUTTON_15					= 15;
local ID_GM_B_CTRL_PICTURE_12					= 12;

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


local sendlayertag = 999;
local checklayertag = 998;


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
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.GMProblemUI);
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI()
	LogInfo("p.LoadUI")
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load GMProblemUI failed!");
		return;
	end
	local layer = createNDUILayer(); --createUIScrollContainer(); --createNDUILayer(); 
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.GMProblemUI);
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h*0.1));
	--layer:SetFrameRect(CGRectMake(winsize.w*0.08, winsize.h*0.08, winsize.w, winsize.h));
	scene:AddChild(layer);	
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	p.InitProblemType();
	p.sendContent.text = "";
	
	selCheckTag = 121;

	uiLoad:Load("gm/gm.ini",layer,p.OnUIEvent,0,0);

	p.InitBugSelStatus(layer)

	uiLoad:Free();
	
	--p.SetBtnSelStatus(layer);
	
	p.GetSendGMLayer();
	
	
	
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_GM_CTRL_BUTTON_14);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
 
 	p.RefreshWithButtonTag( ID_GM_CTRL_CHECK_BUTTON_16 );

end


--=============查看问题ui事件==============--
function p.OnUIEventChk(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventChk[%d][%d]", tag,uiEventType)

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_GM_B_CTRL_BUTTON_15 == tag then
			--local scene = GetSMGameScene();
			--scene:RemoveChildByTag(NMAINSCENECHILDTAG.GMProblemUI, true);
            RemoveChildByTagNew(NMAINSCENECHILDTAG.GMProblemUI, true,true);
			--local layer = p.GetCheckGMLayer()
			--layer:RemoveFromParent(false);
			return true;
		end		
		
	end
end

--=============发送问题ui事件==============--
function p.OnUIEventSend(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventSend[%d][%d]", tag,uiEventType)

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local scene = GetSMGameScene();
		
		if ID_GM_A_CTRL_BUTTON_15 == tag then
			p.SetSendContent(scene);
		end

	elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		LogInfo("p.OnUIEventSend1")
		local curCheck = ConverToCheckBox(uiNode);
		local layer = p.GetSendGMLayer();--p.GetParent();
		if CheckP(curCheck) then
			LogInfo("p.OnUIEventSend2")
			local preCheck = RecursiveCheckBox(layer, {selCheckTag});
			if selCheckTag ~= tag then
				LogInfo("p.OnUIEventSend21 selCheckTag tag"..selCheckTag.." "..tag)
				if CheckP(preCheck) then 
					LogInfo("p.OnUIEventSend22")
					preCheck:SetSelect(false);
				end
			end
			LogInfo("p.OnUIEventSend3")
			selCheckTag = tag;
		end
		LogInfo("p.OnUIEventSend4")
		p.SetContentTopSign(curCheck, tag);
		

		
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
		--用户按下键盘的返回键
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if ID_GM_A_CTRL_INPUT_BUTTON_27 == tag then
			p.sendContent.text = edit:GetText();
                LogInfo("eidt text [%s]", p.sendContent.text);
			end
        end
		
	elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
	end
	
	return true;
end


--=============背景ui事件==============--
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d][%d]", tag,uiEventType)

	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local scene = GetSMGameScene();
		if ID_GM_CTRL_BUTTON_14 == tag or ID_PROBLEM_CTRL_BUTTON_952 == tag then
			--p.InitProblemType();
			--scene:RemoveChildByTag(NMAINSCENECHILDTAG.GMProblemUI, true);
            RemoveChildByTagNew(NMAINSCENECHILDTAG.GMProblemUI, true,true);
			
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
		
		if tag == ID_GM_CTRL_CHECK_BUTTON_16 then
			--提交问题
			local chklayer = p.GetCheckGMLayer();
			chklayer:SetVisible(false);
			
			local sendlayer = p.GetSendGMLayer();
			sendlayer:SetVisible(true);
			p.RefreshWithButtonTag( tag )
			
		elseif tag == ID_GM_CTRL_CHECK_BUTTON_17 then
			--查看问题回复
			local chklayer = p.GetCheckGMLayer();
			chklayer:SetVisible(true);
			
			local sendlayer = p.GetSendGMLayer();
			sendlayer:SetVisible(false);
			p.RefreshWithButtonTag( tag )
			
			--发送msg查看消息
			_G.MsgProFeedback.CheckProFeedback();
		end		
	end
	
	return true;
end


function p.RefreshWithButtonTag( nTag )

	local layer = p.GetParent();
	local btnSelStatus = RecursiveCheckBox(layer, {ID_GM_CTRL_CHECK_BUTTON_16});
	local btnUnSelStatus = RecursiveCheckBox(layer, {ID_GM_CTRL_CHECK_BUTTON_17});
	
	if CheckP(btnSelStatus) == false then
		LogInfo("p.RefreshWithButtonTag btnSelStatus nil")
	end

	if CheckP(btnUnSelStatus) == false then
		LogInfo("p.RefreshWithButtonTag btnUnSelStatus nil")
	end 
		
	if ( ID_GM_CTRL_CHECK_BUTTON_16 == nTag ) then
		btnSelStatus:SetSelect( true );
		btnUnSelStatus:SetSelect( false );
	elseif ( ID_GM_CTRL_CHECK_BUTTON_17 == nTag ) then
		btnSelStatus:SetSelect( false );
		btnUnSelStatus:SetSelect( true );
	end
end


function p.SetBtnSelStatus(layer)
	LogInfo("p.SetBtnSelStatus begin")
	local btnSelStatus = RecursiveCheckBox(layer, {ID_GM_CTRL_CHECK_BUTTON_16});-- GetButton(layer, ID_GM_CTRL_CHECK_BUTTON_16);
	if not CheckP(btnSelStatus) then
		LogInfo("btnSelStatus is not exist!");
		layer:Free();
		return;
	end
	local btnUnSelStatus = RecursiveCheckBox(layer, {ID_GM_CTRL_CHECK_BUTTON_17});-- GetButton(layer, ID_GM_CTRL_CHECK_BUTTON_17)
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
		CommonDlgNew.ShowYesDlg(GetTxtPri("GMPU_T3"));
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
			CommonDlgNew.ShowYesDlg(GetTxtPri("GMPU_T8"));
			return
		end
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.GMProblemUI, true);
		LogInfo("after _G_Msg......")	
		

	end
end

function p.SetContentTopSign(curCheck, tag)
	if ID_GM_A_CTRL_CHECK_BUTTON_16 == tag then
		p.InitProblemType();
		if curCheck:IsSelect() then
			LogInfo("isSelBug")
			isSelBug = true;
		end
	elseif ID_GM_A_CTRL_CHECK_BUTTON_17 == tag then
		p.InitProblemType();
		if curCheck:IsSelect() then
		LogInfo("isSelTouSu")
			isSelTouSu = true;
		end
	elseif ID_GM_A_CTRL_CHECK_BUTTON_18 == tag then
		p.InitProblemType();
		if curCheck:IsSelect() then
		LogInfo("isSelAdjest")
			isSelAdjest= true;
		end
	elseif ID_GM_A_CTRL_CHECK_BUTTON_19 == tag then
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
	else
		LogInfo("InitBugSelStatus precheck nil");	
	end
end


function p.GetSendGMLayer()
	local sendlayer = RecursiveUILayer(p.GetParent(), {sendlayertag});	
	if CheckP(sendlayer) then 
		return sendlayer;
	else
		local bglayer = p.GetParent();
		local layer = createNDUILayer(); 
		if layer == nil then
			LogInfo("GetSendGMLayer layer = nil,2");
			return  false;
		end
		layer:Init();
		layer:SetTag(sendlayertag);
		layer:SetFrameRect(CGRectMake(0, winsize.h*0.11, winsize.w, winsize.h));
		bglayer:AddChild(layer);	
	
		local uiLoad=createNDUILoad();
		if nil == uiLoad then
			layer:Free();
			return false;
		end
		p.sendContent.text = "";
	
		uiLoad:Load("gm/gm_A.ini",layer,p.OnUIEventSend,0,0);
		uiLoad:Free();
		
		
		--默认选中bug
		selCheckTag = ID_GM_A_CTRL_CHECK_BUTTON_16;
		local curCheck = RecursiveCheckBox(layer, {selCheckTag});
		curCheck:SetSelect(true);
		p.SetContentTopSign(curCheck, selCheckTag);
	
		return 	layer;
	end
	
end



--=============查看gm反馈==============--


local container = nil;
local scroll = nil;
local contentHight = 0;

PROVAL = 
{
	strPlayerName, 
	text, 
	gm, 
	gmTipsMsg,
}


function p.GetCheckGMLayer()
	local checklayer = RecursiveUILayer(p.GetParent(), {checklayertag});		

	if CheckP(checklayer) then 
		return checklayer;
	else
		local bglayer = p.GetParent();
		local layer = createUIScrollContainer(); 
		if layer == nil then
			LogInfo("GetSendGMLayer layer = nil,2");
			return  false;
		end
		layer:Init();
		layer:SetTag(checklayertag);
		layer:SetFrameRect(CGRectMake(0, winsize.h*0.107, winsize.w, winsize.h));
		bglayer:AddChild(layer);	
	
		local uiLoad=createNDUILoad();
		if nil == uiLoad then
			layer:Free();
			return false;
		end
		
		uiLoad:Load("gm/gm_B.ini",layer,p.OnUIEventChk,0,0);
		uiLoad:Free();
		
		
		container = createUIScrollContainer();
		if (nil == container) then
			LogInfo("scene = nil,3");
			return;
		end
	
		local rect  = CGRectMake(69*ScaleFactor, 35*ScaleFactor, 330*ScaleFactor, 182*ScaleFactor);
		container:Init();
		container:SetFrameRect(rect);
		container:SetTopReserveDistance(winsize.h*0.6);
		container:SetBottomReserveDistance(winsize.h*0.6);
		--container:SetBackgroundColor(ccc4(0,255,0,255));
		layer:AddChild(container);
		
		local scrollrect = CGRectMake(0.0, 0.0, 330*ScaleFactor, 182*ScaleFactor);
		scroll = createUIScroll();
		if (scroll == nil) then
			LogInfo("scroll == nil,load ChatMainUI failed!");
			container:RemoveFromParent(true);
			return;
		end
		scroll:Init(true);
		scroll:SetFrameRect(scrollrect);
		scroll:SetScrollStyle(UIScrollStyle.Verical);
		scroll:SetMovableViewer(container);
		scroll:SetContainer(container);
		container:AddChild(scroll);		
		
		
		--[[test
		local chatText=createUIChatText();
		chatText:Init();
		chatText:SetContentWidth(winsize.w*0.3);
		chatText:SetContent(1,1,"aaa","asdasdasd",1,8);
		local rect  = CGRectMake(0, 30, winsize.w*0.3, winsize.h*0.1); 
		chatText:SetFrameRect(rect);
		local scrollrect = CGRectMake(0.0, 0.0, winsize.w*0.3, 30);
	
		scroll:AddChild(chatText);
		--]]	
		return 	layer;
	end	
end

function p.ResetContent()
	if CheckP(scroll) then
		scroll:RemoveFromParent(true);
	end
	
	local rect  = CGRectMake(69*ScaleFactor, 35*ScaleFactor, 330*ScaleFactor, 182*ScaleFactor);
	local scrollrect = CGRectMake(0.0, 0.0, 330*ScaleFactor, 182*ScaleFactor);
	scroll = createUIScroll();

	scroll:Init(true);
	scroll:SetFrameRect(scrollrect);
	scroll:SetScrollStyle(UIScrollStyle.Verical);
	scroll:SetMovableViewer(container);
	scroll:SetContainer(container);
	container:AddChild(scroll);				
end

function p.ShowPlayerName(strPlayerName)
	p.CreateText(strPlayerName, 192)
end

function p.ShowPlayerProblem(text)
	p.CreateText(text, 0)
end

function p.ShowGMName(gm)
	p.CreateText(gm, 255)
end

function p.ShowGMReply(gmTipsMsg)
	p.CreateText(gmTipsMsg, 168)
end

function p.ShowLineSignOver()
	local line = "-----------------------------------------";
	 p.CreateText(line, 168);
end

function p.CreateText(data, colorNum)
	local strText=createNDUILabel();
	local textSize = GetMutiLineStringSize(data, 10, 330*ScaleFactor);
	if nil == textSize then LogInfo("nil == textSize") return false end
	strText:Init();
	
	local rect  = CGRectMake(0, contentHight, 330*ScaleFactor, textSize.h*ScaleFactor*1.2); 
	strText:SetFrameRect(rect);
	--strText:SetTextAlignment(UITextAlignment.Left);
	strText:SetFontColor(ccc4(colorNum,255,0,255));
	strText:SetText(data);
	contentHight = textSize.h*ScaleFactor*1.2 + contentHight;
	LogInfo("contentHight: %d", contentHight)
	local scrollrect = CGRectMake(0.0, 0.0, 330*ScaleFactor, contentHight);
	scroll:SetFrameRect(scrollrect);
	--scroll:SetBackgroundColor(ccc4(255,255,0,255));
	scroll:AddChild(strText);
	
	container:ScrollToBottom();
end


--1 sendlayer  0 checklayer
function p.ShowLayer(nLayer)
	local sendlayer = p.GetSendGMLayer();
	local checklayer = p.GetCheckGMLayer();
	
	if nLayer == 1 then
		checklayer:SetVisible(false);
		sendlayer:SetVisible(true);	
	else
		checklayer:SetVisible(true);
		sendlayer:SetVisible(false);			
	end
end

function p.AddTextContent(strPlayerName, text, gm, gmTipsMsg)
	
	local layer =p.GetCheckGMLayer();-- p.GetParent();
	

	
	if nil == layer then
		return false;
	end
	
	if nil == scroll then
		return false;
	end
	
	--contentHight = 0;
	p.ShowPlayerName(strPlayerName);     --显示玩家
	p.ShowPlayerProblem(text);           --显示玩家问题
	p.ShowGMName(gm);	                 --管理员
	p.ShowGMReply(gmTipsMsg);            --管理员消息
	p.ShowLineSignOver();                --一个问题结束的标志 
	
	return true;
end

function p.InitProblemVal()
	PROVAL.strPlayerName = "";
	PROVAL.text = "";
	PROVAL.gm = "";
	PROVAL.gmTipsMsg = "";
end


