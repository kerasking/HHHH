---------------------------------------------------
--描述: 主界面世界地图按钮
--时间: 2012.2.13
--作者: jhzheng
---------------------------------------------------

MainUIWorldMapBtn = {}
local p = MainUIWorldMapBtn;

--UI坐标配置
local winsize	= GetWinSize();
local btnw		= winsize.w * 0.083;
local btnh		= winsize.w * 0.0625;
p.Rect			= CGRectMake((winsize.w - btnw), 0, btnw, btnh);

function p.LoadUI()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("scene == nil,load MainUIWorldMapBtn failed!");
		return;
	end
	
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
	
	local picBtn	= pool:AddPicture(GetSMImgPath("btn/btn_world.png"), false);
	local sizeBtn	= picBtn:GetSize();
	
	local layer	= createNDUILayer();
	if not CheckP(layer) then
		return;
	end
	layer:Init();
	layer:SetFrameRect(CGRectMake(winsize.w - sizeBtn.w, 0, sizeBtn.w, sizeBtn.h));
	layer:SetTag(NMAINSCENECHILDTAG.WorldMapBtn);
	
	local btn	= createNDUIButton();
	if not CheckP(btn) then
		layer:Free();
		return;
	end
	btn:Init();
	btn:CloseFrame();
	btn:SetBackgroundPicture(picBtn, pool:AddPicture(GetSMImgPath("btn/btn_world.png"), false),
									false, RectZero(), true);
	--btn:SetTitle("地图");
	btn:SetFrameRect(CGRectMake(0, 0, sizeBtn.w, sizeBtn.h));
	btn:SetLuaDelegate(p.OnUIEvent);
	layer:AddChild(btn);
	
	scene:AddChild(layer);
	
	return;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if IsUIShow(NMAINSCENECHILDTAG.WorldMap) then
			return true;
		end
		
		if CloseMainUI() then
			return true;
		end
		WorldMapGoto(0);
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

--RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "MainUIWorldMapBtn.LoadUI", p.LoadUI);
