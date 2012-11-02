---------------------------------------------------
--描述: 主界面聊天表板面板
--时间: 2012.4.26
--作者: cl

---------------------------------------------------
local _G = _G;

ChatFaceUI={}
local p=ChatFaceUI;
local winsize	= GetWinSize();

local ID_CHAT_FACE_PICTURE=1;
local ID_CHAT_FACE_BUTTON=42;


p.currentInputTarget=ChatInputTarget.main_input;

function p.LoadUI(target)
	p.currentInputTarget=target;
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
	layer:SetTag(NMAINSCENECHILDTAG.ChatFaceUI);
	layer:SetFrameRect(CGRectMake(0, winsize.h*0.5, winsize.w, winsize.h*0.5));
	layer:SetBackgroundColor(ccc4(0,0,0,180));
	--scene:AddChild(layer);
	_G.AddChild(scene, layer, NMAINSCENECHILDTAG.ChatFaceUI);

	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("SM_LT_Chat_Face.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	p.ShowFace();
end

function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.ChatFaceUI);
	if nil == layer then
		return nil;
	end

	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.ShowFace()
	local layer=p.GetParent();
	if nil==layer then
		return;
	end
	local pool = DefaultPicPool();
	for i=ID_CHAT_FACE_PICTURE,ID_CHAT_FACE_PICTURE+36 do
		local bg=GetImage(layer,i);
		if CheckP(bg) then
			LogInfo("index:%d",i);
			local picture=pool:AddPicture(GetSMImgPath("sm_face.png"),false);
			local x=getIntPart((i-1)%6)*80;
			local y=getIntPart((i-1)/6)*80;
			picture:Cut(CGRectMake(x,y,80,80));
			bg:SetPicture(picture,true);
		end
	end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag>=ID_CHAT_FACE_BUTTON and
			tag<ID_CHAT_FACE_BUTTON+36 then
			local index=tag-ID_CHAT_FACE_BUTTON;
			local index_str="";
			if index<10 then
				index_str="0"..SafeN2S(index);
			else 
				index_str=SafeN2S(index);
			end
			if p.currentInputTarget==ChatInputTarget.main_input then
				ChatMainUI.AppendText("<f"..index_str);
			elseif p.currentInputTarget==ChatInputTarget.private_input then
				ChatPrivateUI.AppendText("<f"..index_str);
			end
		end
	end
end