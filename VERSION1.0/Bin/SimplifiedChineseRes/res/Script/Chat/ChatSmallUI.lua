---------------------------------------------------
--描述: 主界面聊天面板
--时间: 2012.4.20
--作者: cl

---------------------------------------------------
local _G = _G;

ChatSmallUI={}
local p=ChatSmallUI;
local winsize	= GetWinSize();
local container	=nil;
local scroll	=nil;
local contentHight=0;

local ID_SM_LT_CHAT_CTRL_BUTTON	=2;
local ID_SM_LT_CHAT_CTRL_LIST	=1;

local showSecondCount=3;
local showTimeTag=-1;

function p.OnDeConstruct()
	--ChatDataFunc.ClearChatRecord();
	if showTimeTag~=-1 then
		UnRegisterTimer(showTimeTag);
		showTimeTag=-1;
	end
end

function p.OnTimer(tag)
	if tag==showTimeTag then
		if showSecondCount==0 then
			if nil~=container then
				container:SetVisible(false);
			end
			UnRegisterTimer(showTimeTag);
			showTimeTag=-1;
		end
		
		if showSecondCount>0 then
			showSecondCount=showSecondCount-1;

		end
	end
end

function p.HidePanel()
	container:SetVisible(false);
end

function p.move(isBottom)
	local layer=p.GetParent();
	if nil~=layer then
		if isBottom then
			layer:SetFrameRect(CGRectMake(0, winsize.h*0.75-5*ScaleFactor, winsize.w*0.18, winsize.h*0.25));
		else
			layer:SetFrameRect(CGRectMake(0, winsize.h*0.75-50*ScaleFactor, winsize.w*0.18, winsize.h*0.25));
		end
	end
end

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load chatui failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ChatSmallUI);
	layer:SetFrameRect(CGRectMake(0, winsize.h*0.75-50*ScaleFactor, winsize.w*0.18, winsize.h*0.25));
	scene:AddChild(layer);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ChatSmallUI);

	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("SM_LT_CHAT_LEFT.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
		
	layer:SetDestroyNotify(p.OnDeConstruct);
	
	local list= GetScrollViewContainer(layer,ID_SM_LT_CHAT_CTRL_LIST);
	if list == nil then
		LogInfo("list == nil,load ChatSmallUI failed!");
		return;
	end
	
	local rect=list:GetFrameRect();
	
	container = createUIScrollContainer();
	if container == nil then
		LogInfo("container == nil,load ChatMainUI failed!");
		return;
	end
	container:Init();
	container:SetFrameRect(rect);
	container:SetTopReserveDistance(rect.size.h);
	container:SetBottomReserveDistance(rect.size.h);
	container:SetBackgroundColor(ccc4(0,0,0,125));
	layer:AddChild(container);
	
		
	scroll = createUIScroll();
	if (scroll == nil) then
		LogInfo("scroll == nil,load ChatMainUI failed!");
		container:RemoveFromParent(true);
		return;
	end
	scroll:Init(true);
	scroll:SetFrameRect(CGRectMake(0,0,rect.size.w,rect.size.h));
	scroll:SetScrollStyle(UIScrollStyle.Verical);
	--scroll:SetBackgroundColor(ccc4(0, 0, 255, 125));
	scroll:SetMovableViewer(container);
	scroll:SetContainer(container);
	container:AddChild(scroll);

	contentHight=0;
	ChatDataFunc.AddAllChatRecordSmall();
	container:ScrollToBottom();
	
	if showTimeTag==-1 then
		showTimeTag=RegisterTimer(p.OnTimer,1, "ChatSmallUI.LoadUI");
	end
	showSecondCount=3;

end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ChatSmallUI);
	if nil == layer then
		return nil;
	end

	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.AddChatText(speakerId,channel,speaker,text)
	local layer=p.GetParent();
	if nil==layer then
		return false;
	end

	LogInfo("small speaker:%s,text:%s",speaker,text);
	local chatText=createUIChatText();
	chatText:Init();
	chatText:SetContentWidth(winsize.w*0.41);
	chatText:SetContent(speakerId,channel,speaker,text,0,9);
	local rect  = CGRectMake(0, contentHight, winsize.w*0.41, chatText:GetContentHeight()); 
	chatText:SetFrameRect(rect);
	contentHight=contentHight+chatText:GetContentHeight();
	
	local rect=scroll:GetFrameRect();
	local scrollrect = CGRectMake(0.0, 0.0, rect.size.w, contentHight);
	scroll:SetFrameRect(scrollrect);
	scroll:AddChild(chatText);
	
	if not IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) then
		if showTimeTag==-1 then
			showTimeTag=RegisterTimer(p.OnTimer,1, "ChatSmallUI.AddChatText");
		end
		showSecondCount=3;
		if nil~=container then
			container:SetVisible(true);
		end
	end
	
	container:ScrollToBottom();
	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_LT_CHAT_CTRL_BUTTON then
			if not IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) then
				CloseMainUI();
				ChatMainUI.LoadUI();
			end	
		end
    end
	return true;
end


RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "ChatSmallUI.LoadUI", p.LoadUI);