---------------------------------------------------
--描述: 聊天频道栏界面
--时间: 2012.4.20
--作者: cl

---------------------------------------------------
local _G = _G;

ChatTopBarUI={}
local p=ChatTopBarUI;


local ID_CHAT_UP_CTRL_BUTTON_CLOSE = 5;
local ID_CHAT_UP_CTRL_BUTTON_PRIVATE  = 4;
local ID_CHAT_UP_CTRL_BUTTON_FACTION  = 3;
local ID_CHAT_UP_CTRL_BUTTON_WORLD	  = 2;
local ID_CHAT_UP_CTRL_BUTTON_TOTAL	  = 1;

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
	layer:SetFrameRect(CGRectMake(0, 0, winsize.w, winsize.h*0.1));
	--layer:SetBackgroundColor(ccc4(0,0,0,125));
	scene:AddChild(layer);
	--LogInfo("load chat ui");
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("SM_LT_Chat_Up.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
end

function p.CloseChatUI()
	LogInfo("close chat ui");
	local scene = GetSMGameScene();
	if scene~= nil then
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatMainBar,true);
		scene:RemoveChildByTag(NMAINSCENECHILDTAG.ChatMainUI,true);
	end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_CHAT_UP_CTRL_BUTTON_CLOSE == tag then
			p.CloseChatUI();
			return true;
		end
	end
end