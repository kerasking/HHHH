---------------------------------------------------
--描述: 购买军令按钮
--时间: 2012.5.13
--作者: bowei qiu 
---------------------------------------------------

CheckOtherPlayerBtn = {}
local p = CheckOtherPlayerBtn;

--UI坐标配置
local winsize	= GetWinSize();
local btnw		= winsize.w * 0.083;
local btnh		= winsize.w * 0.083;
p.Rect			= CGRectMake((winsize.w - 2*btnw), 0, btnw, btnh);

local winsize = GetWinSize();
local RectUILayer = CGRectMake(0, 0, winsize.w , winsize.h);

local nOtherPlayerId = -1;

function p.LoadUI(param1)

	nOtherPlayerId = param1;
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("scene == nil,load CheckOtherPlayerBtn failed!");
		return;
	end

	--
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
	
	local layer	= createNDUILayer();
	if not CheckP(layer) then
		return;
	end
	
	layer:Init();
	layer:SetFrameRect(CGRectMake(winsize.w - btnw, winsize.h*0.72, btnw, btnh));
	layer:SetTag(NMAINSCENECHILDTAG.MilOrdersBtn);
	
	local btn	= CreateButton("button_look_normal.png","button_look_select.png","",CGRectMake(0, 0, 80, 80),12);
	
	local norPic = pool:AddPicture(GetSMImgPath("button_look.png"), false);
 	norPic:Cut(CGRectMake(0.0,0.0,74.0, 80.0 ));
	btn:SetImage(norPic);
	
	local selpic = pool:AddPicture(GetSMImgPath("button_look.png"), false);
 	selpic:Cut(CGRectMake(0.0,80.0,74.0, 80.0 ));
	btn:SetTouchDownImage(selpic);
	
	
	if not CheckP(btn) then
		layer:Free();
		return;
	end

	btn:SetLuaDelegate(p.OnUIEvent);
	layer:AddChild(btn);
	
	scene:AddChild(layer);

	return;
end

function p.OnUIEvent(uiNode, uiEventType, param)

	
	if nOtherPlayerId == -1 then
		return false;	
	end

		
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	
		if not _G.CheckN(nOtherPlayerId) then
			LogInfo("qbw:friend no param");
			return true;
		end
	
		local nFriendId = nOtherPlayerId;
		
		MsgFriend.SendFriendSel(nFriendId,"qbw:testid:"..nFriendId);
	end
	
	return true;
end
