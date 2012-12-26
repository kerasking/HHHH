---------------------------------------------------
--描述: 聊天界面
--时间: 2012.7.17
--作者: qbw

---------------------------------------------------

--===根据玩家名字加载私聊界面===-
-- ChatMainUI.LoadUIbyFriendName(friendName);

--===普通加载界面方式==========-
-- ChatMainUI.LoadUI()

---------------------------------------------------




local _G = _G;

ChatMainUI={}
local p=ChatMainUI;
local winsize	= GetWinSize();
local container	=nil;
local scroll	=nil;
local contentHight=0;
local ID_TALK_CTRL_INPUT_BUTTON_12 = 5;
local ID_TALK_CTRL_BUTTON_7 = 7;
local ID_CHAT_DOWN_CTRL_INPUT_BUTTON_ZONE = 4;

local ID_CHAT_DOWN_CTRL_VERTICAL_LIST_DLG_WORDS =13;
local ID_CHAT_DOWN_CTRL_BUTTON_ADD_FRIEND =12;
local ID_CHAT_DOWN_CTRL_BUTTON_FRIEND	=10;
local ID_CHAT_DOWN_CTRL_BUTTON_FLOWER	=11;
local ID_CHAT_DOWN_CTRL_BUTTON_FACE =9;
local ID_CHAT_DOWN_CTRL_BUTTON_ITEM =8;
local ID_TALK_BUTTON_AFFIRM =6;
local ID_CHAT_DOWN_CTRL_TEXT_CHANNEL=37;

local CHAT_INPUT_TEXT=0;
local CHAT_INPUT_FACE=1;
local CHAT_INPUT_ITEM=2;
local CHAT_INPUT_FRIEND=3;
local CHAT_INPUT_PRIVATE=4;


--新ui ini
local ID_TALK_LEFT_BUTTON_CLOSE						= 12;
local ID_TALK_CTRL_INPUT_BUTTON_12			= 13;
local ID_TALK_BUTTON_CLOSE					= 8;
local ID_TALK_BUTTON_AFFIRM					= 7;
local ID_TALK_BUTTON_TALK1					= 6;
local ID_TALK_BUTTON_7				= 90;

local ID_TALK_PICTURE_TALK_1					= 1;

--inputA ini
local ID_TALK_INPUT_A_CTRL_TEXT_CHANNEL				= 20;
local ID_TALK_INPUT_A_CTRL_INPUT_BUTTON_12			= 13;
local ID_TALK_INPUT_A_BUTTON_AFFIRM					= 7;
local ID_TALK_INPUT_A_CTRL_PICTURE_29					= 29;
local ID_TALK_INPUT_A_CTRL_PICTURE_28					= 28;
local ID_TALK_INPUT_A_CTRL_PICTURE_27					= 27;
local ID_TALK_INPUT_A_CTRL_PICTURE_26					= 26;
local ID_TALK_INPUT_A_CTRL_PICTURE_25					= 25;
local ID_TALK_INPUT_A_CTRL_PICTURE_24					= 24;
local ID_TALK_INPUT_A_CTRL_PICTURE_23					= 23;
local ID_TALK_INPUT_A_CTRL_PICTURE_22					= 22;
local ID_TALK_INPUT_A_CTRL_PICTURE_21					= 21;

--inputB ini
local ID_TALK_INPUT_B_CTRL_INPUT_BUTTON_22			= 30;
local ID_TALK_INPUT_B_CTRL_TEXT_CHANNEL				= 20;
local ID_TALK_INPUT_B_CTRL_INPUT_BUTTON_12			= 13;
local ID_TALK_INPUT_B_BUTTON_AFFIRM					= 7;
local ID_TALK_INPUT_B_CTRL_PICTURE_29					= 29;
local ID_TALK_INPUT_B_CTRL_PICTURE_28					= 28;
local ID_TALK_INPUT_B_CTRL_PICTURE_27					= 27;
local ID_TALK_INPUT_B_CTRL_PICTURE_26					= 26;
local ID_TALK_INPUT_B_CTRL_PICTURE_25					= 25;
local ID_TALK_INPUT_B_CTRL_PICTURE_24					= 24;
local ID_TALK_INPUT_B_CTRL_PICTURE_23					= 23;
local ID_TALK_INPUT_B_CTRL_PICTURE_22					= 22;
local ID_TALK_INPUT_B_CTRL_PICTURE_21					= 21;
local ID_TALK_INPUT_B_CTRL_PICTURE_39					= 39;
local ID_TALK_INPUT_B_CTRL_PICTURE_38					= 38;
local ID_TALK_INPUT_B_CTRL_PICTURE_37					= 37;
local ID_TALK_INPUT_B_CTRL_PICTURE_36					= 36;
local ID_TALK_INPUT_B_CTRL_PICTURE_35					= 35;
local ID_TALK_INPUT_B_CTRL_PICTURE_34					= 34;
local ID_TALK_INPUT_B_CTRL_PICTURE_33					= 33;
local ID_TALK_INPUT_B_CTRL_PICTURE_32					= 32;
local ID_TALK_INPUT_B_CTRL_PICTURE_31					= 31;

--infolayer
local ID_TALK_LIST_CTRL_BUTTON_12					= 12;
local ID_TALK_LIST_CTRL_BUTTON_11					= 11;
local ID_TALK_LIST_CTRL_BUTTON_10					= 10;





p.currentChatInput=CHAT_INPUT_TEXT;

local TAG_ITEM_INFO_CONTAINER = 9997;			--物品信息与操作
local TAG_ITEM_INFO = 9998;						--物品信息与操作

local TAG_INPUTA = 9996;	--输入框a层
local TAG_INPUTB = 9995;	--输入框b层
local TAG_INFO 	 = 9994;	--说话人信息层

p.currentChatType=ChatType.CHAT_CHANNEL_ALL;

local text="";
local PMname = "";
local PMtext = "";


--根据玩家名字加载私聊界面
function p.LoadUIbyFriendName(friendName)
	p.LoadUI();
	p.SetInputLayer(0);
	p.SetCurrentChatType(ChatType.CHAT_CHANNEL_PRIVATE);
	ChatTopBarUI.RefreshWithButtonTag(5);
	
	local layer=p.GetParent();
	local edit = RecursivUIEdit(layer,{TAG_INPUTB,ID_TALK_INPUT_B_CTRL_INPUT_BUTTON_22});
	if CheckP(edit) then
		edit:SetText(friendName);
	end
	PMname = friendName; 	
end


function p.LoadUI()
    --如果已经打开则返回
	if IsUIShow(NMAINSCENECHILDTAG.ChatMainUI) then
		LogInfo("已经打开则返回");
		return;
	end
	
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
	
	layer:SetPopupDlgFlag( true );
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ChatMainUI);

	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h));
	--layer:SetBackgroundColor(ccc4(0,0,0,125));
	
	scene:AddChildZ(layer,5000);

	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("talk/talk.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();

	

	local rectX = winsize.w*0.05;
	local rectW	= winsize.w*0.95;

	local rect  = CGRectMake(rectX, winsize.h*0.12, rectW, winsize.h*0.75); 
	
	container = createUIScrollContainer();
	if container == nil then
		LogInfo("container == nil,load ChatMainUI failed!");
		return;
	end
	container:Init();
	container:SetFrameRect(rect);
	container:SetTopReserveDistance(winsize.h*0.6);
	container:SetBottomReserveDistance(winsize.h*0.6);
	--container:SetBackgroundColor(ccc4(255,0,0,125));
	layer:AddChild(container);
	
		
	local scrollrect = CGRectMake(0.0, 0.0, rectW, winsize.h*0.75);
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
	scroll:SetLuaDelegate(p.OnUIEventContainer);
	
	
    container:AddChild(scroll);
	container:EnableScrollBar(true);
	
	contentHight=0;
	
	ChatTopBarUI.LoadUI();
	ChatDataFunc.AddAllChatRecord(ChatType.CHAT_CHANNEL_ALL);
	container:ScrollToBottom();
	
	SetLabel(layer,ID_CHAT_DOWN_CTRL_TEXT_CHANNEL,GetTxtPri("CMUI_T1"));
	

	
	--=========加载聊天输入框=========---
	local layerInputA = createNDUILayer();
	if layerInputA == nil then
		LogInfo("scene = nil,2");
		return  false;
	end

	layerInputA:Init();
	layerInputA:SetTag(TAG_INPUTA);
	layerInputA:SetFrameRect(CGRectMake( 0, winsize.h*0.88, winsize.w, winsize.h*0.2));
	--layerInputA:SetBackgroundColor(ccc4(0,0,0,125));
	layer:AddChildZ(layerInputA,2);
	
	local uiLoad=createNDUILoad();
	uiLoad:Load("talk/talk_input_A.ini",layerInputA,p.OnUIEventInputA,0,0);
	uiLoad:Free();
	
	local edit = RecursivUIEdit(layerInputA,{ID_TALK_CTRL_INPUT_BUTTON_12});
	edit:SetMaxLength(32);
	
	local layerInputB = createNDUILayer();
	if layerInputB == nil then
		LogInfo("scene = nil,2");
		return  false;
	end


	--私聊对话框
	layerInputB:Init();
	layerInputB:SetTag(TAG_INPUTB);
	layerInputB:SetFrameRect(CGRectMake( 0, winsize.h*0.88, winsize.w, winsize.h*0.2));
	layer:AddChildZ(layerInputB,2);
	local uiLoad=createNDUILoad();
	uiLoad:Load("talk/talk_input_B.ini",layerInputB,p.OnUIEventInputB,0,0);
	uiLoad:Free();
	
	local edit = RecursivUIEdit(layer,{TAG_INPUTB,ID_TALK_INPUT_B_CTRL_INPUT_BUTTON_22});
	if CheckP(edit) then
		edit:SetText(PMname);
	end
	
	--显示普通聊天框
	p.SetInputLayer(1);
	
	
   	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_TALK_LEFT_BUTTON_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
	

end

--1显示普通聊天框 0显示私聊框
function p.SetInputLayer(n)
	local layer = p.GetParent();
 	local inputlayerA = RecursiveUILayer(layer, {TAG_INPUTA});
 	local inputlayerB = RecursiveUILayer(layer, {TAG_INPUTB});
 	
 	if not CheckP(inputlayerA) or  not CheckP(inputlayerB) then
 		LogInfo("inputlayer is nil");
 		return;
 	end
 	
 	
 	if n == 1 then
 		inputlayerB:SetVisible(false);
 		inputlayerA:SetVisible(true);
 	else
 		inputlayerA:SetVisible(false);
 		inputlayerB:SetVisible(true);
 	end
 	

end



function p.AppendText(str)
	local layer=p.GetParent()
	LogInfo("append text:"..str);
	text=text..str;
	local edit = RecursivUIEdit(layer,{ID_TALK_CTRL_INPUT_BUTTON_12});
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
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ChatMainUI);
	if nil == layer then
		return nil;
	end

	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end



--频道颜色列表
p.ColorChannel = {}
	p.ColorChannel[ChatType.CHAT_CHANNEL_ALL]=ccc4(25,193,255,255)
	p.ColorChannel[ChatType.CHAT_CHANNEL_SYS]=ccc4(36,255,0,255)
	p.ColorChannel[ChatType.CHAT_CHANNEL_WORLD]=ccc4(237,240,0,255)
	p.ColorChannel[ChatType.CHAT_CHANNEL_FACTION]=ccc4(36,255,0,255)
	p.ColorChannel[ChatType.CHAT_CHANNEL_PRIVATE]=ccc4(255,0,252,255)


function p.AddChatText(speakerId,channel,speaker,text)
	LogInfo("main channel:%d,speaker:%s,text:%s",channel,speaker,text);
	
	if p.currentChatType==channel
		or p.currentChatType==ChatType.CHAT_CHANNEL_ALL then

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
		
		local color = p.ColorChannel[channel];
		chatText:SetContent(speakerId,channel,speaker,text,1,12,color);
		
		--chatText:SetContent(speakerId,channel,speaker,text,1,9,ccc4(0,0,255,255));
		
		
		--local rect  = CGRectMake(0, contentHight, winsize.w*0.85, chatText:GetContentHeight()); 
		local rect  = CGRectMake(0, contentHight, winsize.w*0.85, winsize.h*0.1); 
		chatText:SetFrameRect(rect);
		contentHight=contentHight+chatText:GetContentHeight();
		
		local scrollrect = CGRectMake(0.0, 0.0, winsize.w*0.85, contentHight);
		scroll:SetFrameRect(scrollrect);
		scroll:AddChild(chatText);
	end
	
	container:ScrollToBottom();
	return true;
end

function p.ClearInputStatus()
	local scene = GetSMGameScene();
	if scene~= nil then
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatFaceUI,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatItemUI,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatFriendUI,true);
	end

end

function p.ShowFaceUI()
	p.currentChatInput=CHAT_INPUT_FACE;

	local layer=p.GetParent();
	layer:SetFrameRect(CGRectMake(0,-(winsize.h*(0.5-0.14)),winsize.w,winsize.h*0.86));
	
	ChatFaceUI.LoadUI(ChatInputTarget.main_input);
end

function p.ShowItemUI()
	p.currentChatInput=CHAT_INPUT_ITEM;
	ChatItemUI.LoadUI(ChatInputTarget.main_input);
	
	local layer=p.GetParent();
	layer:SetFrameRect(CGRectMake(0,-(winsize.h*(0.48-0.14)),winsize.w,winsize.h*0.86));
	

end

function p.ShowChatItemInfo(nItemId)
	if not CheckN(nItemId) then
		LogInfo("nItemId invalid arg");
		return false;
	end
	
	if not Item.IsExistItem(nItemId) then
		LogInfo("p.AttachItemInfo not Item.IsExistItem[%d]", nItemId);
		--本地没有物品信息，需要查询
		MsgItem.SendQueryItem(nItemId);
		return;
	end

	ItemInfoUI.LoadUI();
	ItemInfoUI.ShowItemInfo(nItemId);
end

function p.SetCurrentChatType(type)
	p.CloseInfoLayer();
	
	currentChatType=type;
	if nil~=scroll then
		scroll:RemoveAllChildren(true);
	end
	contentHight=0;
	ChatDataFunc.AddAllChatRecord(type);
	
	local layer=p.GetParent();
	if nil== layer then
		return;
	end
	
	local layer = p.GetParent();
 	local inputlayerA = RecursiveUILayer(layer, {TAG_INPUTA});
 	local inputlayerB = RecursiveUILayer(layer, {TAG_INPUTB});
	
	if type==ChatType.CHAT_CHANNEL_ALL then
		SetLabel(inputlayerA,ID_TALK_INPUT_A_CTRL_TEXT_CHANNEL,GetTxtPri("CMUI_T2"));
	elseif type==ChatType.CHAT_CHANNEL_WORLD then
		SetLabel(inputlayerA,ID_TALK_INPUT_A_CTRL_TEXT_CHANNEL,GetTxtPri("CMUI_T2"));
	elseif type==ChatType.CHAT_CHANNEL_FACTION then
		SetLabel(inputlayerA,ID_TALK_INPUT_A_CTRL_TEXT_CHANNEL,GetTxtPri("CMUI_T3"));
	elseif type==ChatType.CHAT_CHANNEL_PRIVATE then
		--SetLabel(layer,ID_CHAT_DOWN_CTRL_TEXT_CHANNEL,GetTxtPri("CMUI_T1"));
	end
end

function p.CloseChatUI()
	LogInfo("close chat ui");
	local scene = GetSMGameScene();
	if scene~= nil then
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatMainBar,true);
		RemoveChildByTagNew(NMAINSCENECHILDTAG.ChatMainUI,true,true);
		
	end
end



--普通输入框
function p.OnUIEventInputA(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventInputA[%d][%d]", tag,uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_TALK_INPUT_A_BUTTON_AFFIRM then
			if nil==text or
				string.len(text)<=0 then
				return true;
			end
			text=ChatDataFunc.ParseItemInfo(text);
			if currentChatType==ChatType.CHAT_CHANNEL_PRIVATE then
				LogInfo("p.sendtalk");
				_G.MsgChat.SendTalkMsg(ChatDataFunc.GetChannelByChatType(ChatType.CHAT_CHANNEL_WORLD),text);
			elseif currentChatType==ChatType.CHAT_CHANNEL_FACTION then
				--未开放军团聊天
				local nPlayerId = GetPlayerId();
				local name = GetRoleBasicDataS(nPlayerId,USER_ATTR.USER_ATTR_NAME);
				
				if MsgArmyGroup.GetUserArmyGroupID(nPlayerId) == nil then
					--无军团则提示
					ChatDataFunc.AddChatRecord(nPlayerId,ChatDataFunc.GetChannelByChatType(currentChatType),0,GetTxtPub("system"),GetTxtPri("MCUI2_T1"));
				else
					_G.MsgChat.SendTalkMsg(ChatDataFunc.GetChannelByChatType(currentChatType),text);
				end
				

			else
				_G.MsgChat.SendTalkMsg(ChatDataFunc.GetChannelByChatType(currentChatType),text);
			end
			text="";
			local layer=p.GetParent();
			if nil==layer then
				return true;
			end
			local edit = RecursivUIEdit(layer,{TAG_INPUTA,ID_TALK_INPUT_A_CTRL_INPUT_BUTTON_12});
			if CheckP(edit) then
				edit:SetText("");
			end
		
			p.ClearInputStatus();
			
			local layer=p.GetParent();
			layer:SetFrameRect(CGRectMake(0,0,winsize.w,winsize.h));
			
			p.currentChatInput=CHAT_INPUT_TEXT;	
			
			return true;	
	
		end
   elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
    -- 用户按下键盘的返回键
    LogInfo("eidt finish");
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if tag == ID_TALK_INPUT_A_CTRL_INPUT_BUTTON_12 then
				text = edit:GetText();
                LogInfo("eidt text [%s]", text);
            end 
        else
        	   LogInfo("eidt text nil"); 
        end
        
        return true;
   elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
   
   		return true;        
   elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_RETURN then

		return true;   
	end
	
	
end

--私聊输入框
function p.OnUIEventInputB(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventInputB[%d][%d]", tag,uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_TALK_INPUT_B_BUTTON_AFFIRM then
			if nil==PMtext or
				string.len(PMtext)<=0 then
				return true;
			end
			PMtext=ChatDataFunc.ParseItemInfo(PMtext);
			if currentChatType==ChatType.CHAT_CHANNEL_PRIVATE then
				LogInfo("p.sendtalk name:"..PMname.." content"..PMtext);
				--_G.MsgChat.SendTalkMsg(ChatDataFunc.GetChannelByChatType(ChatType.CHAT_CHANNEL_WORLD),PMtext);
				
				if PMname == nil or PMname == "" then
					 CommonDlgNew.ShowYesDlg(GetTxtPri("CMUI_T6"));
					 return;
				end
				
				_G.MsgChat.SendPrivateTalk(currentPlayerId,PMname,PMtext);
				
			else
				_G.MsgChat.SendTalkMsg(ChatDataFunc.GetChannelByChatType(currentChatType),PMtext);
			end
			PMtext="";
			local layer=p.GetParent();
			if nil==layer then
				return true;
			end
			local edit = RecursivUIEdit(layer,{TAG_INPUTB,ID_TALK_INPUT_B_CTRL_INPUT_BUTTON_12});
			if CheckP(edit) then
				edit:SetText("");
			end
		
			p.ClearInputStatus();
			
			local layer=p.GetParent();
			layer:SetFrameRect(CGRectMake(0,0,winsize.w,winsize.h));
			
			p.currentChatInput=CHAT_INPUT_TEXT;	
			
			return true;	
	
		end
   elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
    -- 用户按下键盘的返回键
    LogInfo("eidt finish");
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if tag == ID_TALK_INPUT_B_CTRL_INPUT_BUTTON_12 then
				PMtext = edit:GetText();
                LogInfo("eidt PMtext [%s]", PMtext);
            elseif tag == ID_TALK_INPUT_B_CTRL_INPUT_BUTTON_22 then
            
                PMname = edit:GetText();
                LogInfo("PMname  [%s]", PMname);
            end 
        else
        	   LogInfo("eidt PMtext nil"); 
        end
        
        return true;
   elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_TEXT_CHANGE then
   
   		return true;        
   elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_RETURN then

		return true;   
	end
	
	
end


function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
		LogInfo("qboy 1");
		--if tag == ID_TALK_BUTTON_AFFIRM then
			--[[
			LogInfo("qboy 2");
			if nil==text or
				string.len(text)<=0 then
				return;
			end
			text=ChatDataFunc.ParseItemInfo(text);
			if currentChatType==ChatType.CHAT_CHANNEL_PRIVATE then
				LogInfo("p.sendtalk");
				_G.MsgChat.SendTalkMsg(ChatDataFunc.GetChannelByChatType(ChatType.CHAT_CHANNEL_WORLD),text);
			else
				_G.MsgChat.SendTalkMsg(ChatDataFunc.GetChannelByChatType(currentChatType),text);
			end
			text="";
			local layer=p.GetParent();
			if nil==layer then
				return true;
			end
			local edit = RecursivUIEdit(layer,{ID_TALK_CTRL_INPUT_BUTTON_12});
			if CheckP(edit) then
				edit:SetText("");
			end
		
			p.ClearInputStatus();
			
			local layer=p.GetParent();
			layer:SetFrameRect(CGRectMake(0,0,winsize.w,winsize.h));
			
			p.currentChatInput=CHAT_INPUT_TEXT;
			--]]
		if tag==ID_CHAT_DOWN_CTRL_BUTTON_FACE then
			LogInfo("qboy 2");
			if p.currentChatInput==CHAT_INPUT_TEXT then
				LogInfo("showface");
				p.ShowFaceUI();
			elseif p.currentChatInput==CHAT_INPUT_FACE then
				LogInfo("hideface");
				p.ClearInputStatus();
				
				local layer=p.GetParent();
				layer:SetFrameRect(CGRectMake(0,0,winsize.w,winsize.h*0.86));
				
				p.currentChatInput=CHAT_INPUT_TEXT;
			else
				p.ClearInputStatus();
				p.ShowFaceUI();
			end
		elseif tag==ID_CHAT_DOWN_CTRL_BUTTON_ITEM then
			LogInfo("qboy 3");
			if p.currentChatInput==CHAT_INPUT_TEXT then
				LogInfo("showItem");
				p.ShowItemUI();
			elseif p.currentChatInput==CHAT_INPUT_ITEM then
				LogInfo("hideitem");
				p.ClearInputStatus();
				
				local layer=p.GetParent();
				layer:SetFrameRect(CGRectMake(0,0,winsize.w,winsize.h*0.86));
				
				p.currentChatInput=CHAT_INPUT_TEXT;
			else
				p.ClearInputStatus();
				p.ShowItemUI();
			end
		elseif tag==ID_TALK_CTRL_BUTTON_7 then
			--关闭信息层
			LogInfo("qboy 4");
			LogInfo("qboy 关闭信息层");
			p.CloseInfoLayer()

			--ChatPrivateUI.LoadUI();
			--ChatPrivateUI.SetChatPlayer(0,"XXX");
		elseif tag == ID_TALK_LEFT_BUTTON_CLOSE then
			LogInfo("qboy 5");
			p.CloseChatUI();
			return true;
		elseif tag == ID_TALK_BUTTON_7 then
			LogInfo("qboy 6");
			local layer=p.GetParent();
			local infolayer = RecursiveUILayer(layer, {TAG_INFO});
 	
 			if  CheckP(infolayer)  then
  				p.CloseInfoLayer();
 				return true;				
 			else
 				return false;
			end
			
		end
    elseif uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH then
    -- 用户按下键盘的返回键
        local edit = ConverToEdit(uiNode);
        if CheckP(edit) then
            if tag == ID_TALK_CTRL_INPUT_BUTTON_12 then
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

local nCheckPlayerId = 0;
local sCheckPlayerName = "";

function p.OnUIEventInfoList(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventInfoList[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
		if tag == ID_TALK_LIST_CTRL_BUTTON_10 then
			--私聊
			p.CloseChatUI();
			p.LoadUIbyFriendName(sCheckPlayerName);
			p.CloseInfoLayer();
		elseif tag == ID_TALK_LIST_CTRL_BUTTON_11 then
			--查看资料
			CheckOtherPlayerBtn.LoadUI(nCheckPlayerId);
			MsgFriend.SendFriendSel(nCheckPlayerId,sCheckPlayerName);
            p.CloseInfoLayer();
		elseif tag == ID_TALK_LIST_CTRL_BUTTON_12 then
			--加好友
			if FriendFunc.IsExistFriend(nCheckPlayerId)  then
				CommonDlgNew.ShowYesDlg(GetTxtPri("CMUI_T7"));
			else
				FriendFunc.AddFriend(nCheckPlayerId,sCheckPlayerName); --加为好友 
			end
            p.CloseInfoLayer();
		end
				
	
		return true;
	end
end

function p.OpenInfoList(nUserId,sUserName)
	 nCheckPlayerId = nUserId;
	 sCheckPlayerName = sUserName;	
	local bglayer = p.GetParent();	
	
	
	--关闭之前界面
	bglayer:RemoveChildByTag(TAG_INFO,true);

	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("OpenInfoList layer= nil");
		return  false;
	end

	layer:Init();
	layer:SetTag(TAG_INFO);

	layer:SetFrameRect(CGRectMake(400, 230, 160, 180));
	--layer:SetBackgroundColor(ccc4(0,0,0,125));

	bglayer:AddChildZ(layer,2);

	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("OpenInfoList uiLoad = nil,4");
		return false;
	end
	
	uiLoad:Load("talk/talk_list.ini",layer,p.OnUIEventInfoList,0,0);
	uiLoad:Free();
end

function p.CloseInfoLayer()
	local bglayer = p.GetParent();	
	bglayer:RemoveChildByTag(TAG_INFO,true);
end


function p.OnUIEventContainer(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventContainer[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		LogInfo("p.OnUIEventContainer click");
		p.CloseInfoLayer();
	end
	return true;
end

















































