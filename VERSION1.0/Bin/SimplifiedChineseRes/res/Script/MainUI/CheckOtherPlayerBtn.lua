---------------------------------------------------
--描述: 购买军令按钮
--时间: 2012.5.13
--作者: bowei qiu 
---------------------------------------------------

CheckOtherPlayerBtn = {}
local p = CheckOtherPlayerBtn;

--UI坐标配置
local winsize	= GetWinSize();
local btnw		= 32*ScaleFactor;
local btnh		= 40*ScaleFactor;
p.LayerRect = CGRectMake(winsize.w-btnw*1.5, winsize.h-btnh-40*ScaleFactor, btnw, btnh); 


local nOtherPlayerId = -1;

function p.LoadUI(param1)

	nOtherPlayerId = param1;
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		LogInfo("scene == nil,load CheckOtherPlayerBtn failed!");
		return;
	end
    
    local layer = GetUiLayer(scene,NMAINSCENECHILDTAG.MilOrdersBtn);
    if(layer) then
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
	layer:SetFrameRect(p.LayerRect);
	layer:SetTag(NMAINSCENECHILDTAG.MilOrdersBtn);
	
	local btn	= CreateButton("button_look.png","button_look.png","",CGRectMake(0, 0, btnw, btnh),12);
	
	local norPic = pool:AddPicture(GetSMImgPath("button_look.png"), false);
 	norPic:Cut(CGRectMake(0.0, 0.0, btnw, btnh));
	btn:SetImage(norPic);
	
	local selpic = pool:AddPicture(GetSMImgPath("button_look.png"), false);
 	selpic:Cut(CGRectMake(0.0, btnh, btnw, btnh));
	btn:SetTouchDownImage(selpic);
	
	
	if not CheckP(btn) then
		layer:Free();
		return;
	end

	btn:SetLuaDelegate(p.OnUIEvent);
	layer:AddChild(btn);
	
	scene:AddChild(layer);
    
    --** chh 2012-08-08 **--
    --设置隐藏偏移
    if(MainUIBottomSpeedBar.ShowHideState == 1) then
        MainUIBottomSpeedBar.findSetOffset(1, MainUIBottomSpeedBar.ShowHideHeight);
    end
    
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
		
		--chh 2012-07-17
		--MsgFriend.SendFriendSel(nFriendId,"qbw:testid:"..nFriendId);
        MsgFriend.SendSeeOtherPlayerList();
    end
	
	return true;
end
