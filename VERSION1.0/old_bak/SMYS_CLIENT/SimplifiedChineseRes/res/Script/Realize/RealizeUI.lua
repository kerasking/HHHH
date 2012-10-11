---------------------------------------------------
--描述: 悟道购买界面
--时间: 2012.3.10
--作者: wjl
---------------------------------------------------
RealizeUI = {}
local p = RealizeUI;

p.TagClose		= 912;
p.TagPickUpAll	= 916;
p.TagSaleAll	= 917;
p.TagBuyAll		= 902;
p.TagGoBag		= 918;

p.TagBuyList = {
	901,
	903,
	904,
	905,
	906,
}
p.TagSaleList = {
	935,
	939,
	936,
	940,
	937,
	941,
	938,
	942,
}

p.TagToolPic = {
	897,
	911,
	898,
	913,
	899,
	914,
	900,
	915,
}

p.TagToolTxt = {
	920,
	928,
	922,
	930,
	924,
	932,
	926,
	934,
}


p.mShowOrderSt		= 0; -- 0:为不显示，1:为显示
p.mCurrentOpenIndex	= -1; -- 当前启用的阵型id
p.mMatrixList		= nil;
p.mMatrixListCount	= 0;
p.mAutoBuy = false;

-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;



function p.LoadUI()
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,load PlayerAttr failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerRealize);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("Realize.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	uiLoad:Free();
	
	p.initData();
	p.RefreshUI();
	
	return true;
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		p.mAutoBuy = false; 
		if p.TagClose == tag then
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.PlayerRealize);
		elseif p.TagGoBag == tag then
			p.freeData();
			CloseUI(NMAINSCENECHILDTAG.PlayerRealize);
			RealizeBagUI.LoadUI();
		elseif (p.TagPickUpAll == tag ) then
			p.pickUpAll();
		elseif (p.TagSaleAll  == tag) then
			p.saleAll();
		elseif (p.TagBuyAll	 == tag) then
			p.buyAll();
		elseif (p.clickBuy(uiNode, tag)) then
		elseif (p.clickSale(uiNode, tag)) then
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

function p.pickUpAll()
	MsgRealize.sendPickUpAll();
	--local ids = MsgRealize.getRealizeIdList();
	--MsgRealize.sendRealizeMerge(ids[1], ids[2]);
end

function p.saleAll() 
	MsgRealize.sendSaleAll();
end

function p.buyAll()
	--MsgRealize.sendRealizeBuyALL();
	p.mAutoBuy = true;
	p.autoBuy();
end

function p.clickBuy(node, tag)
	p.mAutoBuy = false;
	local index = -1;
	
	for i = 1, #p.TagBuyList do 
		if (p.TagBuyList[i] == tag) then
			index = i;
		end
	end
	
	if (index < 1) then
		return false;
	else
		MsgRealize.sendRealizeBuy(index);
		return true;
	end
end

function p.autoBuy()
	if p.mAutoBuy  then
		local ids = MsgRealize.getRealizeIdList();
		if (ids and # ids >= 8) then
			p.mAutoBuy = false;
			return;
		end
		
		local index = 1;
		local ids = MsgRealize.getNpcIdList();
	
		for i = 1, #ids do 
			if (ids[i] > index) then
				index = ids[i];
			end
		end

		MsgRealize.sendRealizeBuy(index);
	end
end

function p.clickSale(node, tag) 
	local index = -1;
	
	for i = 1, #p.TagSaleList do
		if (p.TagSaleList[i] == tag) then
			index = i;
		end
	end
	
	if (index < 1) then
		return false;
	else
		local ids = MsgRealize.getRealizeIdList();
		if (ids and CheckN(ids[index]) ) then
			MsgRealize.sendSale(index-1); -- 服务端index 以0开始
			return true;
		else 
			LogInfo("RealizeUI ids is null");
		end
	end
	return false;
end

function p.OnUIEventScroll(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventScroll[%d]", tag);
	return true;
end

function p.RefreshUI()
	p.RefreshGoodsInfos();
	p.RefreshNpc();
end

function p.RefreshGoodsInfos()
	local scene = GetSMGameScene();	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerRealize);
	if nil == layer then
		return nil;
	end
	
	local ids = MsgRealize.getRealizeIdList();
	
	for i = 1 , #p.TagToolTxt do
		local txt = GetLabel(layer, p.TagToolTxt[i]);
		local bt = GetButton(layer, p.TagSaleList[i]);
		if (ids and ids[i]) then
			txt:SetVisible(true);
			local name = ItemFunc.GetName(ids[i]);
			txt:SetFontColor(RealizeFunc.getColorByQut(ItemFunc.GetQuality(ids[i])));
			txt:SetText(name);
			bt:SetVisible(true);
		else
			txt:SetVisible(false);
			bt:SetVisible(false);
		end
	end
end

function p.RefreshNpc()
	local scene = GetSMGameScene();	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerRealize);
	if nil == layer then
		return nil;
	end
	
	local ids = MsgRealize.getNpcIdList();
	
	for k, v in pairs(ids) do
		if (p.TagBuyList[i]) then
		local txt = GetButton(layer, p.TagBuyList[i]);
			if (ids and ids[v]) then
				if CheckP(txt) then
					txt:EnalbeGray(false);
				end
			elseif CheckP(txt) then
				txt:EnalbeGray(true);
			end
		end
	end
	
	local first = GetButton(layer, p.TagBuyList[1]);
	if CheckP(first) then
		first:EnalbeGray(false);
	end
	
	--[[
	for i = 1 ,#p.TagBuyList do
		
		if (ids and ids[i]) then
			txt:SetVisible(true);
			--txt:SetText(i);
		else
			txt:SetVisible(false);
		end
	end
	]]--
	
end

function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	--LogInfo(string.format("processNet%d" , msgId));
	if msgId == NMSG_Type._MSG_REALIZE_LIST or msgId == NMSG_Type._MSG_REALIZE_PICKUP_ALL 
		or msgId == NMSG_Type._MSG_REALIZE_SALE_ALL 
		or msgId == NMSG_Type._MSG_REALIZE_BUY then
		p.RefreshGoodsInfos();
		if (p.mAutoBuy and msgId == NMSG_Type._MSG_REALIZE_BUY) then
			p.autoBuy();
		end
	elseif msgId == NMSG_Type._MSG_REALIZE_OPEN then
		p.RefreshNpc();
	end
end

function p.initData()
	p.mAutoBuy = false;
	local lst, count = MsgMagic.getRoleMatrixList();
	p.mMatrixList = lst;
	p.mMatrixListCount = count;
	MsgRealize.mUIListener = p.processNet;
end

function p.freeData()
	MsgMagic.mUIListener = nil;
	p.mAutoBuy = false;
end


