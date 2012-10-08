---------------------------------------------------
--描述: 聊天界面
--时间: 2012.4.20
--作者: cl

---------------------------------------------------
local _G = _G;

ChatMainUI={}
local p=ChatMainUI;
local winsize	= GetWinSize();
local container	=nil;
local scroll	=nil;
local contentHight=0;
local ID_CHAT_DOWN_CTRL_INPUT_BUTTON_DLG = 5;
local ID_CHAT_DOWN_CTRL_INPUT_BUTTON_ZONE = 4;

local ID_CHAT_DOWN_CTRL_VERTICAL_LIST_DLG_WORDS =13;
local ID_CHAT_DOWN_CTRL_BUTTON_ADD_FRIEND =12;
local ID_CHAT_DOWN_CTRL_BUTTON_FRIEND	=10;
local ID_CHAT_DOWN_CTRL_BUTTON_FLOWER	=11;
local ID_CHAT_DOWN_CTRL_BUTTON_FACE =9;
local ID_CHAT_DOWN_CTRL_BUTTON_ITEM =8;
local ID_CHAT_DOWN_CTRL_BUTTON_SEMD =6;

local text="";

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load chatui failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	--LogInfo("get layer");
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ChatMainUI);

	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h*0.86));
	layer:SetBackgroundColor(ccc4(0,0,0,125));
	scene:AddChild(layer);
	--LogInfo("load chat ui");
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_LT_Chat_Down.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	container = createUIScrollContainer();
	if container == nil then
		LogInfo("container == nil,load ChatMainUI failed!");
		return;
	end
	

	local rectX = winsize.w*0.03;
	local rectW	= winsize.w*0.85;

	local rect  = CGRectMake(rectX, winsize.h*0.11, rectW, winsize.h*0.6); 
	container:Init();
	container:SetFrameRect(rect);
	container:SetTopReserveDistance(winsize.h*0.6);
	container:SetBottomReserveDistance(winsize.h*0.6);
	--container:SetBackgroundColor(ccc4(255,0,0,125));
	layer:AddChild(container);
	
		
	local scrollrect = CGRectMake(0.0, 0.0, rectW, winsize.h*0.6);
	scroll = createUIScroll();
	if (scroll == nil) then
		LogInfo("scroll == nil,load ChatMainUI failed!");
		container:RemoveFromParent(true);
		return;
	end
	scroll:Init(true);
	scroll:SetFrameRect(scrollrect);
	scroll:SetScrollStyle(UIScrollStyle.Verical);
	--scroll:SetBackgroundColor(ccc4(0, 0, 255, 125));
	scroll:SetMovableViewer(container);
	scroll:SetContainer(container);
	container:AddChild(scroll);
	
	
	contentHight=0;
	
	ChatTopBarUI.LoadUI();
	ChatDataFunc.AddAllChatRecord();
end



function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ChatMainUI);
	if nil == layer then
		return nil;
	end

	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.AddChatText(id,channel,speaker,text)
	LogInfo("speaker:%s,text:%s",speaker,text);
	local layer=p.GetParent();
	if nil==layer then
		return false;
	end
	if nil == scroll then
		return false;
	end
	local chatText=createUIChatText();
	chatText:Init();
	chatText:SetContentWidth(winsize.w*0.85);
	chatText:SetContent(id,channel,speaker,text);
	local rect  = CGRectMake(0, contentHight, winsize.w*0.85, chatText:GetContentHeight()); 
	chatText:SetFrameRect(rect);
	contentHight=contentHight+chatText:GetContentHeight();
	
	local scrollrect = CGRectMake(0.0, 0.0, winsize.w*0.85, contentHight);
	scroll:SetFrameRect(scrollrect);
	scroll:AddChild(chatText);
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_CHAT_DOWN_CTRL_BUTTON_SEMD then
			_G.MsgChat.SendTalkMsg(text);
			local layer=p.GetParent();
			if nil==layer then
				return true;
			end
			local edit = RecursivUIEdit(layer,{ID_CHAT_DOWN_CTRL_INPUT_BUTTON_DLG});
			if CheckP(edit) then
				edit:SetText("");
			end
		end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
    -- 用户按下键盘的返回键
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if tag == ID_CHAT_DOWN_CTRL_INPUT_BUTTON_DLG then
				text = edit:GetText();
                LogInfo("eidt text [%s]", text);
            elseif tag == ID_CHAT_DOWN_CTRL_INPUT_BUTTON_ZONE then
                LogInfo("eidt text [%s]", edit:GetText());
            end 
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
		
    end
	return true;
end