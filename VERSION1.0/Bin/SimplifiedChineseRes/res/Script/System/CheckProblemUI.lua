---------------------------------------------------
--描述: 检查问题界面
--时间: 2012.5.24
--作者: LLF
---------------------------------------------------

CheckProblemUI = {}
local p = CheckProblemUI

local ID_CHKPROBLEM_CTRL_BUTTON_27        = 27;   --关闭
local ID_CHKPROBLEM_CTRL_BUTTON_14        = 14;   --退出
local ID_CHKPROBLEM_CTRL_BUTTON_11        = 11;   --提交问题
local ID_CHKPROBLEM_CTRL_BUTTON_12        = 12;   --查看问题
local ID_CHKPROBLEM_CTRL_VERTICAL_LIST_79 = 79;

local ID_CTRL_HYPER_TEXT_104 = 104;
local ID_CTRL_HYPER_TEXT_103 = 103;
local ID_CTRL_HYPER_TEXT_105 = 105;
local ID_CTRL_HYPER_TEXT_106 = 106;

--新ini
local ID_GM_B_CTRL_TEXT_16					= 16;
local ID_GM_B_CTRL_PICTURE_13					= 13;
local ID_GM_B_CTRL_BUTTON_15					= 15;
local ID_GM_B_CTRL_PICTURE_12					= 12;

local winsize = GetWinSize();
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

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then   
		return nil;
	end
	
	local layer = GetUiLayer(scene, {NMAINSCENECHILDTAG.GMProblemUI,998});
	if nil == layer then
		return nil;
	end
	
	return layer;
end

function p.LoadUI()
	LogInfo("p.LoadUI")
	
	local layer = createUIScrollContainer();--createNDUILayer(); 
	
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	
	layer:Init();
	
	layer:SetTag(998);
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	--layer:SetFrameRect(CGRectMake(winsize.w*0.08, winsize.h*0.08, winsize.w, winsize.h)); --[[0, 0, winsize.w, 254*ScaleFactor--]]
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.CheckProblemUI);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	p.InitProblemVal();

	uiLoad:Load("gm/gm_B.ini",layer,p.OnUIEvent,0,0);

	uiLoad:Free();
	
	p.SetBtnSelStatus(layer);
	
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
	return layer;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local scene = GetSMGameScene();
		if ID_CHKPROBLEM_CTRL_BUTTON_27 == tag or ID_CHKPROBLEM_CTRL_BUTTON_14 == tag then
			
            RemoveChildByTagNew(NMAINSCENECHILDTAG.CheckProblemUI, true,true);
		elseif ID_CHKPROBLEM_CTRL_BUTTON_11 == tag then
			scene:RemoveChildByTag(NMAINSCENECHILDTAG.CheckProblemUI, true);
			ProblemUI.LoadUI();
		end
	end
	
	return true;
end

function p.SetBtnSelStatus(layer)
	LogInfo("p.SetBtnSelStatus begin")
	local btnSelStatus = GetButton(layer, ID_CHKPROBLEM_CTRL_BUTTON_12);
	if not CheckP(btnSelStatus) then
		LogInfo("btnSelStatus is not exist!");
		layer:Free();
		return;
	end
	local btnUnSelStatus = GetButton(layer, ID_CHKPROBLEM_CTRL_BUTTON_11)
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
	
	local rect  = CGRectMake(0, contentHight, 330*ScaleFactor, textSize.h); 
	strText:SetFrameRect(rect);
	--strText:SetTextAlignment(UITextAlignment.Left);
	strText:SetFontColor(ccc4(colorNum,255,0,255));
	strText:SetText(data);
	contentHight = textSize.h + contentHight;
	LogInfo("contentHight: %d", contentHight)
	local scrollrect = CGRectMake(0.0, 0.0, 330*ScaleFactor, contentHight);
	scroll:SetFrameRect(scrollrect);
	--scroll:SetBackgroundColor(ccc4(255,255,0,255));
	scroll:AddChild(strText);
	
	container:ScrollToBottom();
end

function p.AddTextContent(strPlayerName, text, gm, gmTipsMsg)
	
	local layer = p.GetParent();
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




