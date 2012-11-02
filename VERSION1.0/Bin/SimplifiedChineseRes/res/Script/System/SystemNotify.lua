---------------------------------------------------
--描述: 系统通知
--时间: 2012.5.24
--作者: jhzheng
---------------------------------------------------

SystemNotify = {}
local p = SystemNotify;

local WORLD_NOTIFY_SHOW_TIME						= 5;

local mStrCurGameNewsTitle							= nil;
local mStrCurGameNewsContent						= nil;

local mTimerTagWorld								= 0;

---系统通知-世界公告 SM_SYS_WORLD.ini
local ID_SM_SYS_WORLD_CTRL_HYPER_TEXT_M				= 13;
local ID_SM_SYS_WORLD_CTRL_PICTURE_12					= 12;
local ID_SM_SYS_WORLD_CTRL_PICTURE_11					= 11;
local ID_SM_SYS_WORLD_CTRL_PICTURE_10					= 10;
local ID_SM_SYS_WORLD_CTRL_PICTURE_9					= 9;
local ID_SM_SYS_WORLD_CTRL_PICTURE_8					= 8;
local ID_SM_SYS_WORLD_CTRL_PICTURE_7					= 7;
local ID_SM_SYS_WORLD_CTRL_PICTURE_6					= 6;
local ID_SM_SYS_WORLD_CTRL_PICTURE_5					= 5;
local ID_SM_SYS_WORLD_CTRL_PICTURE_4					= 4;

---系统通知-游戏新闻标题 SM_SYS_NEWS.ini
local ID_SM_SYS_NEWS_CTRL_BUTTON_CLOSE					= 27;
local ID_SM_SYS_NEWS_CTRL_HYPER_TEXT_BUTTON_NEWS		= 26;
local ID_SM_SYS_NEWS_CTRL_PICTURE_24					= 24;
local ID_SM_SYS_NEWS_CTRL_PICTURE_12					= 12;
local ID_SM_SYS_NEWS_CTRL_PICTURE_11					= 11;
local ID_SM_SYS_NEWS_CTRL_PICTURE_10					= 10;
local ID_SM_SYS_NEWS_CTRL_PICTURE_9						= 9;
local ID_SM_SYS_NEWS_CTRL_PICTURE_8						= 8;
local ID_SM_SYS_NEWS_CTRL_PICTURE_7						= 7;
local ID_SM_SYS_NEWS_CTRL_PICTURE_6						= 6;
local ID_SM_SYS_NEWS_CTRL_PICTURE_5						= 5;
local ID_SM_SYS_NEWS_CTRL_PICTURE_4						= 4;


---系统通知-游戏新闻内容 SM_SYS_NM.ini
local ID_SM_SYS_NM_CTRL_HYPER_TEXT_TITLE			= 41;
local ID_SM_SYS_NM_CTRL_BUTTON_SURE					= 40;
local ID_SM_SYS_NM_CTRL_VERTICAL_LIST_NEWS			= 38;
local ID_SM_SYS_NM_CTRL_PICTURE_12					= 12;
local ID_SM_SYS_NM_CTRL_PICTURE_11					= 11;
local ID_SM_SYS_NM_CTRL_PICTURE_10					= 10;
local ID_SM_SYS_NM_CTRL_PICTURE_9					= 9;
local ID_SM_SYS_NM_CTRL_PICTURE_8					= 8;
local ID_SM_SYS_NM_CTRL_PICTURE_7					= 7;
local ID_SM_SYS_NM_CTRL_PICTURE_6					= 6;
local ID_SM_SYS_NM_CTRL_PICTURE_5					= 5;
local ID_SM_SYS_NM_CTRL_PICTURE_4					= 4;

---------------------------------------------------
--对外接口
function p.ShowWorldNotify(content)
	p.showUIWorld(content);
end

function p.ShowGameNews(title, content)
	p.refreshGameNews(title, content);
end
---------------------------------------------------
function p.OnUIEventGameNewsTitle(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventGameNewsTitle[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_SYS_NEWS_CTRL_BUTTON_CLOSE then
			CloseUI(NMAINSCENECHILDTAG.SystemNotifyGameNewsTitle);
		elseif tag == ID_SM_SYS_NEWS_CTRL_HYPER_TEXT_BUTTON_NEWS then
			CloseUI(NMAINSCENECHILDTAG.SystemNotifyGameNewsTitle);
			p.showUIGameNewsContent();
		end
	end
	return true;
end

function p.OnUIEventGameNewsContent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventGameNewsContent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_SYS_NM_CTRL_BUTTON_SURE then
			CloseUI(NMAINSCENECHILDTAG.SystemNotifyGameNewsContent);
			if CheckS(mStrCurGameNewsTitle) and CheckS(mStrCurGameNewsContent) then
				p.showUIGameNewsTitle();
			end
		end
	end
	return true;
end


function p.showUIWorld(str)
	if not CheckS(str) then
		return;
	end
	
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return;
	end
	
	local pScrollContainer		= nil;
	if not IsUIShow(NMAINSCENECHILDTAG.SystemNotifyWorld) then
		pScrollContainer		= CreateFullScrUI(NMAINSCENECHILDTAG.SystemNotifyWorld);
		if not CheckP(pScrollContainer) then
			uiLoad:Free();
			return;
		end
		pScrollContainer:SetDestroyNotify(p.onWorldNotifyDestroy);
		uiLoad:Load("SM_SYS_WORLD.ini", pScrollContainer, nil, 0, 0);
		uiLoad:Free();
	else
		pScrollContainer		= GetFulllScrUI(NMAINSCENECHILDTAG.SystemNotifyWorld);
	end
	
	if not CheckP(pScrollContainer) then
		return;
	end
	
	local pHyperLinkText		= RecursiveHyperText(pScrollContainer, {ID_SM_SYS_WORLD_CTRL_HYPER_TEXT_M});
	if CheckP(pHyperLinkText) then
		pHyperLinkText:SetLinkTextAlignment(UITextAlignment.Center);
		pHyperLinkText:EnableLine(false);
		pHyperLinkText:SetLinkText(str);
	end
	
	if CheckN(mTimerTagWorld) and 0 ~= mTimerTagWorld then
		_G.UnRegisterTimer(mTimerTagWorld);
	end
	mTimerTagWorld	= _G.RegisterTimer(p.OnProcessTimer, WORLD_NOTIFY_SHOW_TIME, "SystemNotify.showUIWorld");
end

function p.refreshGameNews(title, content)
	if not CheckS(title) or not CheckS(content) then
		return;
	end
	
	mStrCurGameNewsTitle		= title;
	mStrCurGameNewsContent		= content;
	
	if p.isUIGameNewsContentShowing() then
		return;
	end
	
	p.showUIGameNewsTitle();
end

function p.isUIGameNewsContentShowing()
	return IsUIShow(NMAINSCENECHILDTAG.SystemNotifyGameNewsContent);
end

function p.showUIGameNewsTitle()
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return;
	end
	
	local pScrollContainer		= nil;
	if not IsUIShow(NMAINSCENECHILDTAG.SystemNotifyGameNewsTitle) then
		pScrollContainer		= CreateFullScrUI(NMAINSCENECHILDTAG.SystemNotifyGameNewsTitle);
		if not CheckP(pScrollContainer) then
			uiLoad:Free();
			return;
		end
		uiLoad:Load("SM_SYS_NEWS.ini", pScrollContainer, p.OnUIEventGameNewsTitle, 0, 0);
		uiLoad:Free();
	end
	
	local pHyperLinkBtn			= RecursiveHyperBtn(pScrollContainer, {ID_SM_SYS_NEWS_CTRL_HYPER_TEXT_BUTTON_NEWS});
	if CheckP(pHyperLinkBtn) and CheckS(mStrCurGameNewsTitle) then
		pHyperLinkBtn:SetLinkTextAlignment(UITextAlignment.Center);
		pHyperLinkBtn:SetLinkText(mStrCurGameNewsTitle);
	end
end

function p.showUIGameNewsContent()
	if not CheckS(mStrCurGameNewsTitle) or not CheckS(mStrCurGameNewsContent) then
		return;
	end

	CloseUI(NMAINSCENECHILDTAG.SystemNotifyGameNewsContent);
	
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return;
	end
	
	local pScrollContainer			= CreateFullScrUI(NMAINSCENECHILDTAG.SystemNotifyGameNewsContent);
	if not CheckP(pScrollContainer) then
		uiLoad:Free();
		return;
	end
	pScrollContainer:SetDestroyNotify(p.onGameNewsContentDestroy);
	uiLoad:Load("SM_SYS_NM.ini", pScrollContainer, p.OnUIEventGameNewsContent, 0, 0);

	uiLoad:Free();
	
	local pLableTitle				= RecursiveHyperText(pScrollContainer, {ID_SM_SYS_NM_CTRL_HYPER_TEXT_TITLE});
	if CheckP(pLableTitle) then
		pLableTitle:EnableLine(false);
		pLableTitle:SetLinkText(mStrCurGameNewsTitle);
	end
	
	local pScrollContainerContent	= RecursiveScrollContainer(pScrollContainer, {ID_SM_SYS_NM_CTRL_VERTICAL_LIST_NEWS});
	if CheckP(pScrollContainerContent) and CheckS(mStrCurGameNewsContent) then
		
		--把竖表改成scrollcontainer
		local pNodeTag					= pScrollContainerContent:GetTag();
		local pNodeRect					= pScrollContainerContent:GetFrameRect();
		pScrollContainer:RemoveChildByTag(ID_SM_SYS_NM_CTRL_VERTICAL_LIST_NEWS, true);
		local pScrollContainerContent	= createUIScrollContainer();
		if not CheckP(pScrollContainerContent) then
			mStrCurGameNewsTitle	= nil;
			mStrCurGameNewsContent	= nil;
			return;
		end
		pScrollContainerContent:Init();
		pScrollContainerContent:SetFrameRect(pNodeRect);
		pScrollContainerContent:SetTag(pNodeTag);
		pScrollContainerContent:SetTopReserveDistance(pNodeRect.size.h);
		pScrollContainerContent:SetBottomReserveDistance(pNodeRect.size.h);
		pScrollContainer:AddChild(pScrollContainerContent);
		
		
		local rectContent			= pScrollContainerContent:GetFrameRect();
		local winsize				= GetWinSize();
		local pHyperLinkText		= CreateHyperlinkText(mStrCurGameNewsContent, 
										CGRectMake(0, 0, rectContent.size.w, winsize.h),
										12,
										ccc4(255, 255, 255, 255));
		local pScroll = createUIScroll();
		if CheckP(pScroll) and CheckP(pHyperLinkText) then
			pHyperLinkText:SetLinkTextAlignment(-1);
			pHyperLinkText:EnableLine(false);
			pHyperLinkText:SetLinkText(mStrCurGameNewsContent);
			pScroll:Init(true);
			
			local rectLink			= pHyperLinkText:GetFrameRect();
			pScroll:SetFrameRect(rectLink);
			pScroll:SetScrollStyle(UIScrollStyle.Verical);
			pScroll:SetMovableViewer(pScrollContainerContent);
			pScroll:SetContainer(pScrollContainerContent);
			pScroll:AddChild(pHyperLinkText);
			pScrollContainerContent:AddChild(pScroll);
		elseif CheckP(pHyperLinkText) then
			pHyperLinkText:Free();
		end
	end
	
	mStrCurGameNewsTitle	= nil;
	mStrCurGameNewsContent	= nil;
end

function p.onGameNewsContentDestroy()
	
end

function p.onWorldNotifyDestroy()
	if CheckN(mTimerTagWorld) and 0 ~= mTimerTagWorld then
		_G.UnRegisterTimer(mTimerTagWorld);
		mTimerTagWorld = 0;
	end
end

function p.OnProcessTimer(nTag)
	if CheckN(mTimerTagWorld) and nTag == mTimerTagWorld then
		CloseUI(NMAINSCENECHILDTAG.SystemNotifyWorld);
	end
end

function p.OnEnterGameScene()
	if CheckS(mStrCurGameNewsTitle) and CheckS(mStrCurGameNewsContent) then
		p.showUIGameNewsTitle();
	end
end

function p.OnQuitGame()
	mStrCurGameNewsTitle	= nil;
	mStrCurGameNewsContent	= nil;
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_GENERATE_GAMESCENE, "SystemNotify.OnEnterGameScene", p.OnEnterGameScene);
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_QUITGAME, "SystemNotify.OnQuitGame", p.OnQuitGame);
