---------------------------------------------------
--描述: 聊天频道栏界面
--时间: 2012.4.20
--作者: cl

---------------------------------------------------
local _G = _G;

ChatTopBarUI={};
local p=ChatTopBarUI;

p.btn_txt={"综合","世界","军团","私聊",};
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
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.ChatMainBar);
	local winsize = GetWinSize(); 
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w*0.8, winsize.h*0.1));
	--layer:SetBackgroundColor(ccc4(0,0,0,125));
	scene:AddChildZ(layer,3);
	--_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ChatMainBar);
	--LogInfo("load chat ui");
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("talk/talk_left.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	LogInfo("load tab ");
	
	--[[local btn_tab=createUITabLogic();
	btn_tab:Init();
	local btnWidth=53*ScaleFactor;
	local btnHeight=23*ScaleFactor;
	local spacer=5*ScaleFactor;
	
	local tab_width=4*spacer+4*btnWidth;
	local tab_height=btnHeight;
	
	btn_tab:SetFrameRect(CGRectMake(0,0,tab_width,tab_height));

	local pool = DefaultPicPool();--]]
	
	--[[
	for	i, v in ipairs(p.BtnTag) do
		local btn = createNDUIButton();
		if btn == nil then
			LogInfo("btn[%d] == nil,load chatTopr failed!", i);
			container:RemoveFromParent(true);
			break;
		end
		btn:Init();
		local rect = CGRectMake(i * spacer + (i-1) * btnWidth, spacer, btnWidth, btnHeight);
		btn:SetFrameRect(rect);
		btn:SetTag(v);
		btn:CloseFrame();
		btn:SetTitle(p.btn_txt[i]);
		local pic_nor=pool:AddPicture(GetSMImgPath("UI/UI_IMG_FRAME_1.png"),false);
		local pic_sel=pool:AddPicture(GetSMImgPath("UI/UI_IMG_FRAME_1.png"),false);
		local pic_foc=pool:AddPicture(GetSMImgPath("UI/UI_IMG_FRAME_1.png"),false);
		pic_nor:Cut(CGRectMake(0,365,107,46));
		pic_sel:Cut(CGRectMake(0,410,107,46));
		pic_foc:Cut(CGRectMake(0,410,107,46));
		btn:SetBackgroundPicture(pic_nor,pic_sel,
									false, RectZero(), true);
		btn:SetFocusImage(pic_foc);
		btn:SetLuaDelegate(p.OnUIEvent);
		btn_tab:AddTab(btn,nil);
		layer:AddChild(btn);
	end
	--]]
	--layer:AddChild(btn_tab);
	--btn_tab:SelectWithIndex(0);
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
		elseif ID_TALK_LEFT_BUTTON_TALK_JT == tag then
			ChatMainUI.SetCurrentChatType(ChatType.CHAT_CHANNEL_FACTION);
		elseif ID_TALK_LEFT_BUTTON_TALK_SL == tag then
			ChatMainUI.SetCurrentChatType(ChatType.CHAT_CHANNEL_PRIVATE);
			ChatMainUI.SetInputLayer(0);
		elseif ID_TALK_LEFT_BUTTON_TALK_ZH == tag then
			ChatMainUI.SetCurrentChatType(ChatType.CHAT_CHANNEL_ALL);
		end
		-- btn2:SetFocus(false);
		
	end
end