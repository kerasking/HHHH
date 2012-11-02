---------------------------------------------------
--描述: 私聊面板
--时间: 2012.4.20
--作者: cl

---------------------------------------------------
local _G = _G;

ChatPrivateUI={}
local p=ChatPrivateUI;
local winsize	= GetWinSize();
local container	=nil;
local scroll	=nil;
local contentHight=0;
local text="";

local ID_SM_LT_SL_CTRL_INPUT_BUTTON	=26;
local ID_SM_LT_SL_CTRL_BUTTON_CLOSE	=18;
local ID_SM_LT_SL_CTRL_BUTTON_ADD	=24;
local ID_SM_LT_SL_CTRL_BUTTON_BAG	=23;
local ID_SM_LT_SL_CTRL_BUTTON_FLOWER	=22;
local ID_SM_LT_SL_CTRL_BUTTON_WATCH	=25;
local ID_SM_LT_SL_CTRL_BUTTON_FACE	=21;
local ID_SM_LT_SL_CTRL_BUTTON_SEND	=27;
local ID_SM_LT_SL_CTRL_HYPER_TEXT_TITLE=20;

local currentPlayerId=0;
local currentPlayerName="";

local CHAT_INPUT_TEXT=0;
local CHAT_INPUT_FACE=1;
local CHAT_INPUT_ITEM=2;
local CHAT_INPUT_FRIEND=3;
local CHAT_INPUT_PRIVATE=4;
p.currentChatInput=CHAT_INPUT_TEXT;

local width=0;
local height=0;

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
	layer:SetTag(NMAINSCENECHILDTAG.ChatPrivateUI);
	width=winsize.w*0.5;
	height=winsize.h*0.46;
	layer:SetFrameRect(CGRectMake(winsize.w*0.25, winsize.h*0.25, width, height));
	--layer:SetBackgroundColor(ccc4(255,0,0,125));
	scene:AddChild(layer);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ChatPrivateUI);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("SM_LT_SL.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	local rectX = width*0.03;
	local rectW	= width*0.94;

	local rect  = CGRectMake(rectX, height*0.38, rectW, height*0.42); 
	
	container = createUIScrollContainer();
	if container == nil then
		LogInfo("container == nil,load ChatMainUI failed!");
		return;
	end
	container:Init();
	container:SetFrameRect(rect);
	container:SetTopReserveDistance(height*0.42);
	container:SetBottomReserveDistance(height*0.42);
	container:SetBackgroundColor(ccc4(0,0,0,125));
	layer:AddChild(container);
	
		
	local scrollrect = CGRectMake(0.0, 0.0, rectW, height*0.42);
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
	

end

function p.ClearInputStatus()
	local scene = GetSMGameScene();
	if scene~= nil then
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatFaceUI,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatItemUI,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatFriendUI,true);
	end

end

function p.AddChatText(speakerId,channel,targetId,speaker,text)
	LogInfo("pri,speaker:%s,text:%s",speaker,text);
	if channel~=ChatType.CHAT_CHANNEL_PRIVATE then
		return;
	end
	
	if speakerId~=currentPlayerId and targetId~=currentPlayerId then
		return;
	end
	
	local layer=p.GetParent();
	if nil==layer then
		return false;
	end
	if nil == scroll then
		return false;
	end
	local chatText=createUIChatText();
	chatText:Init();
	chatText:SetContentWidth(width*0.95);
	chatText:SetContent(speakerId,channel,speaker,text,1,9);
	local rect  = CGRectMake(0, contentHight, width*0.95, chatText:GetContentHeight()); 
	chatText:SetFrameRect(rect);
	contentHight=contentHight+chatText:GetContentHeight();
	
	local scrollrect = CGRectMake(0.0, 0.0, width*0.95, contentHight);
	scroll:SetFrameRect(scrollrect);
	scroll:AddChild(chatText);
	
	
	container:ScrollToBottom();
	return true;
end

function p.AppendText(str)
	local layer=p.GetParent()
	LogInfo("append text:"..str);
	text=text..str;
	local edit = RecursivUIEdit(layer,{ID_SM_LT_SL_CTRL_INPUT_BUTTON});
	if CheckP(edit) then
		LogInfo("edit settext:"..text);
		edit:SetText(text);
	end
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ChatPrivateUI);
	if nil == layer then
		return nil;
	end

	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.SetChatPlayer(playerID,playerName)
	currentPlayerId=playerID;
	currentPlayerName=playerName;
	
	local layer=p.GetParent();
	if nil==layer then
		return;
	end
	
	--设置标题
	local label=GetHyperLinkText(layer, ID_SM_LT_SL_CTRL_HYPER_TEXT_TITLE);
	
	if CheckP(label) then
		label:EnableLine(false);
		label:SetLinkText("正在与<cff0000"..playerName.."/e聊天");
	end
	if nil~=scroll then
		scroll:RemoveAllChildren(true);
	end
	
	--初始化聊天内容
	contentHight=0;
	ChatDataFunc.AddAllChatRecordPrivate(playerID);
	
	--判断是否好友
	local isFriend=FriendFunc.IsExistFriend(playerID);
	if isFriend then
		local button=GetButton(layer, ID_SM_LT_SL_CTRL_BUTTON_ADD);
		if CheckP(button) then
			button:EnalbeGray(true);
		end
	end
end

function p.ShowFaceUI()
	p.currentChatInput=CHAT_INPUT_FACE;

	local layer=p.GetParent();
	local rect=layer:GetFrameRect();
	layer:SetFrameRect(CGRectMake(rect.origin.x,0,rect.size.w,rect.size.h));
	
	ChatFaceUI.LoadUI(ChatInputTarget.private_input);
end

function p.ShowItemUI()
	p.currentChatInput=CHAT_INPUT_ITEM;
	ChatItemUI.LoadUI(ChatInputTarget.private_input);
	
	local layer=p.GetParent();
	local rect=layer:GetFrameRect();
	layer:SetFrameRect(CGRectMake(rect.origin.x,0,rect.size.w,rect.size.h));
	

end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_LT_SL_CTRL_BUTTON_CLOSE then
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatPrivateUI,true);
			end
			p.ClearInputStatus();
			p.currentChatInput=CHAT_INPUT_TEXT;
		elseif tag == ID_SM_LT_SL_CTRL_BUTTON_FLOWER then
			MsgFriend.SendOpenGiveFlower(currentPlayerId,currentPlayerName,nil);
		elseif tag == ID_SM_LT_SL_CTRL_BUTTON_ADD then
			FriendFunc.AddFriend(currentPlayerId);
		elseif tag == ID_SM_LT_SL_CTRL_BUTTON_WATCH then
			MsgFriend.SendFriendSel(currentPlayerId,currentPlayerName,nil);
		elseif tag == ID_SM_LT_SL_CTRL_BUTTON_FACE then
			if p.currentChatInput==CHAT_INPUT_TEXT then
				LogInfo("showface");
				p.ShowFaceUI();
			elseif p.currentChatInput==CHAT_INPUT_FACE then
				LogInfo("hideface");
				p.ClearInputStatus();
				
				local layer=p.GetParent();
				layer:SetFrameRect(CGRectMake(winsize.w*0.25, winsize.h*0.25, width, height));
				
				p.currentChatInput=CHAT_INPUT_TEXT;
			else
				p.ClearInputStatus();
				p.ShowFaceUI();
			end
		elseif tag == ID_SM_LT_SL_CTRL_BUTTON_BAG then
			if p.currentChatInput==CHAT_INPUT_TEXT then
				LogInfo("showItem");
				p.ShowItemUI();
			elseif p.currentChatInput==CHAT_INPUT_ITEM then
				LogInfo("hideitem");
				p.ClearInputStatus();
				
				local layer=p.GetParent();
				layer:SetFrameRect(CGRectMake(winsize.w*0.25, winsize.h*0.25, width, height));
				
				p.currentChatInput=CHAT_INPUT_TEXT;
			else
				p.ClearInputStatus();
				p.ShowItemUI();
			end
		elseif tag == ID_SM_LT_SL_CTRL_BUTTON_SEND then
			if nil==text or
				string.len(text)<=0 then
				return true;
			end
			text=ChatDataFunc.ParseItemInfo(text);
			_G.MsgChat.SendPrivateTalk(currentPlayerId,currentPlayerName,text);
			text="";
			local layer=p.GetParent();
			if nil==layer then
				return true;
			end
			local edit = RecursivUIEdit(layer,{ID_SM_LT_SL_CTRL_INPUT_BUTTON});
			if CheckP(edit) then
				edit:SetText("");
			end
		
			p.ClearInputStatus();
			
			local layer=p.GetParent();
			layer:SetFrameRect(CGRectMake(winsize.w*0.25, winsize.h*0.25, width, height));
			
			p.currentChatInput=CHAT_INPUT_TEXT;
		end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
    -- 用户按下键盘的返回键
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if tag == ID_SM_LT_SL_CTRL_INPUT_BUTTON then
				text = edit:GetText();
                LogInfo("eidt text [%s]", text);
			end 
        end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
		
    end
	return true;
end