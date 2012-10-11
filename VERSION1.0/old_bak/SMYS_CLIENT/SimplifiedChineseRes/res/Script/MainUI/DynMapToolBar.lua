---------------------------------------------------
--描述: 主界面右上部快捷栏
--时间: 2012.3.22
--作者: cl
---------------------------------------------------

DynMapToolBar = {}
local p = DynMapToolBar;

--UI坐标配置
local winsize	= GetWinSize();
local btnnum	= 2;
p.Width			= winsize.w;
p.Height		= winsize.h * 0.125;
p.Rect			= CGRectMake(0, p.Height, p.Width, p.Height);
p.Btninner		= 0;--winsize.w * (0.01);
p.BtnWidth		= p.Height*2;--(p.Width - (btnnum + 1) * p.Btninner) / btnnum;
p.BtnY			= p.Height * (0.1);
p.BtnHeight		= p.Height - p.BtnY * 2;

local LEAVE_DYNMAP=1;
local DYNMAP_GUIDE=2;

--滚动层配置
p.ScrollTag = 1;
local scroll;
--按钮配置
p.BtnTag = 
{
	101,
	102,
};

p.BtnText = 
{
	"离开副本",
	"查看攻略",

};



function p.GetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.DynMapToolBar);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end


function p.refreshBtns()
	local layer = p.GetParent();
	if nil==layer then
		return ;
	end
	local pool = DefaultPicPool();
	for	i, v in ipairs(p.BtnTag) do
		
		local btn = createNDUIButton();
		if btn == nil then
			LogInfo("btn[%d] == nil,load DynMapToolBar failed!", i);
			layer:RemoveFromParent(true);
			break;
		end
		btn:Init();
		local rect = CGRectMake(i * p.Btninner + (i - 1) * p.BtnWidth, p.BtnY, p.BtnWidth, p.BtnHeight);
		btn:SetFrameRect(rect);
		btn:SetTag(v);
		btn:CloseFrame();
		btn:SetTitle(p.BtnText[i]);
		btn:SetBackgroundPicture(pool:AddPicture(GetImgPathNew("bag_btn_normal.png"), false),
								pool:AddPicture(GetImgPathNew("bag_btn_click.png"), false),
								false, RectZero(), true);

		btn:SetLuaDelegate(p.OnUIEvent);
		layer:AddChild(btn);
	end
end

function p.LoadUI()
    if table.getn(p.BtnTag) ~= table.getn(p.BtnText) then
		LogInfo("table.getn,load DynMapToolBar failed!");
		return;
	end
	
	local scene = GetSMGameScene();
	if scene == nil then
		LogInfo("scene == nil,load DynMapToolBar failed!");
		return;
	end
	
	local layer	= createNDUILayer();
	if not CheckP(layer) then
		return;
	end
	layer:Init();
	layer:SetFrameRect(CGRectMake(winsize.w - btnnum*p.BtnWidth, 0, btnnum*p.BtnWidth, p.BtnHeight));
	layer:SetTag(NMAINSCENECHILDTAG.DynMapToolBar);
	
	scene:AddChild(layer);
	
	p.refreshBtns();

end


function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
		if CloseMainUI() then
			return true;
		end
		
		if p.BtnTag[1] == tag then
			_G.MsgDynMap.SendDynMapQuit();
		elseif p.BtnTag[2] == tag then
			local round=GetCurrentMonsterRound();
			_G.MsgDynMap.SendDynMapGuide(round);
		end

	end
	
	
	
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "DynMapToolBar.LoadUI", p.LoadUI);