---------------------------------------------------
--描述: 玩家属性UI
--时间: 2012.2.1
--作者: jhzheng
---------------------------------------------------

PlayerUIAttr = {}
local p = PlayerUIAttr;

local ui_tag_close = 100;

function p.LoadUI()
	local scene = Scene();
	if scene == nil then
		return false;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end

	local btnClose = createNDUIButton();
	if btnClose == nil then
		layer:Free();
		return false;
	end

	--初始化ui
	local rectLayer = CGRectMake(0, 0, 480, 320);
	layer:Init();
	layer:SetFrameRect(rectLayer);
	LogInfo("ready for scene:AddChild(layer);");
	scene:AddChild(layer);
	
	local rectBtn = CGRectMake(100, 100, 120, 220);
	btnClose:Init();
	btnClose:SetFrameRect(rectBtn);
	btnClose:SetTitle("this is a text");
	btnClose:SetLuaDelegate(p.OnUIEvent);
	btnClose:SetTag(ui_tag_close);
	LogInfo("ready for layer:AddChild(btnClose);");
	layer:AddChild(btnClose);

	local testNode = GetButton(layer, ui_tag_close);
	LogInfo("local testNode = layer:GetChild(ui_tag_close); [%d]", testNode:GetTag());
	local testRect = testNode:GetFrameRect();
	LogInfo("x=[%f], y=[%f], w=[%f], h=[%f]", testRect.origin.x, testRect.origin.y, testRect.size.w, testRect.size.h);
	
	local director = DefaultDirector();
	director:PushScene(scene, false);

	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEvent_Type.TE_TOUCH_BTN_CLICK then
		if ui_tag_close == tag then
			local director = DefaultDirector();
			if director ~= nil then
				director:PopScene(true);
			end
		end
	elseif uiEventType == NUIEvent_Type.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end