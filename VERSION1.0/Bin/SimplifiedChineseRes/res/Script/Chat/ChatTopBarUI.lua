---------------------------------------------------
--描述: 聊天频道栏界面
--时间: 2012.4.20
--作者: cl

---------------------------------------------------
local _G = _G;

ChatTopBarUI={};
local p=ChatTopBarUI;

p.btn_txt={GetTxtPri("CMUI_T1"),GetTxtPri("CMUI_T9"),GetTxtPri("CMUI_T10"),GetTxtPri("CMUI_T11"),};
p.BtnTag={1,2,3,4,};


--新ui ini

local ID_TALK_LEFT_BUTTON_TALK_SL					= 5;
local ID_TALK_LEFT_BUTTON_TALK_JT					= 4;
local ID_TALK_LEFT_BUTTON_TALK_SJ					= 3;
local ID_TALK_LEFT_BUTTON_TALK_ZH					= 2;


function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load chatTopUi failed!");
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
	layer:bringToTop();
	layer:SetTag(NMAINSCENECHILDTAG.ChatMainBar);
	local winsize = GetWinSize(); 
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w*0.8, winsize.h*0.1));
	--layer:SetBackgroundColor(ccc4(0,0,0,125));
	scene:AddChildZ(layer,5000);

	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("talk/talk_left.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	LogInfo("load tab ");
	p.RefreshWithButtonTag(ID_TALK_LEFT_BUTTON_TALK_ZH);
end

function p.CloseChatUI()
	LogInfo("close chat ui");
	local scene = GetSMGameScene();
	if scene~= nil then
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatMainBar,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatMainUI,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatFaceUI,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatItemUI,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatFriendUI,true);
	end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	
	ChatMainUI.SetInputLayer(1);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_TALK_LEFT_BUTTON_CLOSE == tag then
			p.CloseChatUI();
			
			return true;
		elseif ID_TALK_LEFT_BUTTON_TALK_SJ == tag then
			ChatMainUI.SetCurrentChatType(ChatType.CHAT_CHANNEL_WORLD);
			p.RefreshWithButtonTag(tag)
		elseif ID_TALK_LEFT_BUTTON_TALK_JT == tag then
			ChatMainUI.SetCurrentChatType(ChatType.CHAT_CHANNEL_FACTION);
			p.RefreshWithButtonTag(tag)
		elseif ID_TALK_LEFT_BUTTON_TALK_SL == tag then
			ChatMainUI.SetCurrentChatType(ChatType.CHAT_CHANNEL_PRIVATE);
			p.RefreshWithButtonTag(tag)
			ChatMainUI.SetInputLayer(0);
		elseif ID_TALK_LEFT_BUTTON_TALK_ZH == tag then
			ChatMainUI.SetCurrentChatType(ChatType.CHAT_CHANNEL_ALL);
			p.RefreshWithButtonTag(tag)
		end
		-- btn2:SetFocus(false);
		
	end
end


function p.RefreshWithButtonTag(nTag)

	local layer = p.GetParent();
	local worldbtn 	= GetButton( layer, ID_TALK_LEFT_BUTTON_TALK_SJ ); 
	local facbtn 	= GetButton( layer, ID_TALK_LEFT_BUTTON_TALK_JT ); 
	local pribtn 	= GetButton( layer, ID_TALK_LEFT_BUTTON_TALK_SL ); 
	local allbtn 	= GetButton( layer, ID_TALK_LEFT_BUTTON_TALK_ZH ); 
	
	worldbtn:SetChecked( false );
	facbtn:SetChecked( false );
	pribtn:SetChecked( false );
	allbtn:SetChecked( false );
		
	local selBtn 	= GetButton( layer, nTag ); 
		
	selBtn:SetChecked( true );

end


function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then   
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ChatMainBar);
	if nil == layer then
		return nil;
	end
	
	return layer;
end












