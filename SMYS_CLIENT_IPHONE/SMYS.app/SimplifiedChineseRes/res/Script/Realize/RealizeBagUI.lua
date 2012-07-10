---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
RealizeBagUI = {}
local p = RealizeBagUI;

local ID_ROLEREALIZE_L_CTRL_BUTTON_ROLE					= 22;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M8				= 21;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M6				= 20;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M4				= 19;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M2				= 18;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M7				= 17;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M5				= 16;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M3				= 15;
local ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M1				= 14;
local ID_ROLEREALIZE_L_CTRL_LIST_NAME					= 504;
local ID_ROLEREALIZE_L_CTRL_TEXT_SHARD_NUM				= 159;
local ID_ROLEREALIZE_L_CTRL_PICTURE_SHARD				= 158;
local ID_ROLEREALIZE_L_CTRL_BUTTON_CHANGE				= 154;

local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_16				= 77;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_15				= 76;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_14				= 75;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_12				= 74;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_11				= 73;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_10				= 72;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_8				= 71;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_7				= 70;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_6				= 69;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_4				= 68;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_3				= 67;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_2				= 66;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_13				= 65;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_9				= 64;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_5				= 63;
local ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_1				= 62;

local TAG_ITEM_INFO_CONTAINER = 9997;			--物品信息与操作
local TAG_ITEM_INFO = 9998;					-- tip 弹出的信息框
local TAG_ITEM_INFO_ID = 9996;					--物品信息物品
local TAG_MOUSE	= 9999;							--鼠标图片tag

--物品操作枚举
local ITEM_OPERATE_EQUIP = 600;					--穿装备
local ITEM_OPERATE_UNEQUIP = 601;				--脱装备
local ITEM_OPERATE_EQUIP_SEND = 602;			--发送到聊天
local ITEM_OPERATE_USE = 603;					--使用物品
local ITEM_OPERATE_DROP = 604;					--丢物品
local ITEM_OPERATE_OPEN = 605;					--合成


p.TagUiLayer		= NMAINSCENECHILDTAG.RealizeBag;
p.TagClose			= 225;
p.TagLeftContainer	= 61;
p.TagRightContainer = 680;
p.TagGoShop			= 48;
p.TagMix			= 50;
p.TagPetItem	= {
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M1,
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M2,
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M3,
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M4,
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M5,
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M6,
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M7,
	ID_ROLEREALIZE_L_CTRL_EQUIP_BUTTON_M8,
}

p.TagBagItem =	{
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_1,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_2,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_3,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_4,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_5,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_6,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_7,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_8,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_9,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_10,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_11,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_12,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_13,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_14,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_15,
	ID_ROLEREALIZE_R_LIST_CTRL_OBJECT_BUTTON_16,
}



-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

-- 常量宏
local MAX_BACK_BAG_NUM				= 3;
local MAX_GRID_NUM_PER_PAGE			= 16;



p.DrageType = {
	Equip	= 1,
	BagItem = 2,
}

p.DrageState = {
	Out			= 1,
	Complement	= 2,
	In			= 3,
}

p.mDragSrc = {
	srcTag = 0,
	srcType = 0, -- 1:usertag, 2: stationtag
}

p.mDragDst = {
	srcTag = 0,
	srcType = 0,
}

p.mEquipList = {
}


p.mItemList = {
	
};

p.mCurrentPetId = nil;
p.mCurrentPage	= 1;

function p.IsOnShowing()
	if IsUIShow(p.TagUiLayer) then
		return true;
	else
		return false;
	end
end

function p.LoadUI()
	
	local scene = GetSMGameScene();	
	
	if not CheckP(scene) then
		LogInfo("scene == nil,load PlayerAttr failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return false;
	end
	layer:Init();
	layer:SetTag(p.TagUiLayer);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("RoleRealize_R.ini", layer, p.OnUIEvent, CONTAINTER_X, CONTAINTER_Y);
	
	uiLoad:Free();
	
	p.initData();
	p.initSubUI();
	
	--鼠标图片初始化
	local imgMouse	= createNDUIImage();
	imgMouse:Init();
	imgMouse:SetTag(TAG_MOUSE);
	layer:AddChildZ(imgMouse, 2);
	
	p.initItemInfoDlg();
	
	return true;
end

--物品信息层初始化
function p.initItemInfoDlg()
	local layer = p.getUiLayer();
	local containerItem = createUIScrollContainer();
	if containerItem == nil then
		return;
	end
	containerItem:Init();
	containerItem:SetTag(TAG_ITEM_INFO_CONTAINER);
	containerItem:SetFrameRect(RectZero());
	layer:AddChildZ(containerItem, 1);
	
	local scroll = createUIScroll();
	if (scroll == nil) then
		containerItem:RemoveFromParent(true);
		return;
	end
	scroll:Init(false);
	scroll:SetFrameRect(RectZero());
	scroll:SetScrollStyle(UIScrollStyle.Verical);
	scroll:SetTag(TAG_ITEM_INFO);
	scroll:SetMovableViewer(containerItem);
	scroll:SetContainer(containerItem);
	containerItem:AddChild(scroll);
end



function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.freeData();
			CloseUI(p.TagUiLayer);
		elseif (p.TagGoShop == tag ) then
			p.freeData();
			CloseUI(p.TagUiLayer);
			RealizeUI.LoadUI();
		elseif (p.TagMix == tag) then
			local nPlayerId = GetPlayerId();
			local idlistItem	= ItemUser.GetDaoFaItemList(nPlayerId);
			MsgRealize.sendMergeAll(idlistItem);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		
		if tag == p.TagRightContainer then
			--p.SetBackBagPage(param);
			if CheckN(param) then
				LogInfo("page:%d", param + 1);
				p.mCurrentPage = (param + 1);
				-- p.SetFocusOnPage(param + 1);
			end
		end 
	end
	return true;
end

function p.OnUIItemEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("点击物品 not CheckP(itemBtn) %d ", uiEventType);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local itemBtn = ConverToItemButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("点击物品 not CheckP(itemBtn) ");
			return true;
		end
		if itemBtn:IsLock() then
			local pageNum		= p.mCurrentPage or 1;
			local id, nGridIndex	= p.getIdByViewTag(tag,p.DrageType.BagItem);
			if nGridIndex > 0 and pageNum > 0 then
				local nOpenNum = (pageNum - 1) * MAX_GRID_NUM_PER_PAGE + nGridIndex;
				MsgPlayer.SendOpenBagGrid(nOpenNum);
			end
		else
			p.ChangeItemInfo(itemBtn:GetItemId(), false);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
		--物品往外拖
		local isable = false;
		if p.isEquipTag(tag) then
			LogInfo("物品往外拖  p.isEquipTag(tag)");
			isable = true;
			p.mDragSrc.srcTag = tag;
			p.mDragSrc.srcType = p.DrageType.Equip;
		elseif p.isBagItemTag(tag) then
			isable = true;
			p.mDragSrc.srcTag = tag;
			p.mDragSrc.srcType = p.DrageType.BagItem;
		end
		
		if (not isable) then
			return true;
		end
		
		if not CheckStruct(param) then
			LogInfo("物品往外拖 invalid param");
			return true;
		end
		
		local itemBtn = ConverToButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("物品往外拖 not CheckP(itemBtn) ");
			return true;
		end
		
		p.SetMouse(itemBtn:GetImageCopy(), param);
		p.OnDragItemListener(p.mDragSrc,nil, p.DrageState.Out, param);
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
		--物品往外拖完成
		if not p.isEquipTag(tag) then 
			LogInfo("物品往外拖完成 not p.isEquipTag(tag)");
			--return true;
		end
		local itemBtn = ConverToButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("物品往外拖完成 not CheckP(itemBtn) ");
			--return true;
		end
		p.OnDragItemListener(p.mDragSrc,nil, p.DrageState.Complement, param);
		p.SetMouse(nil, SizeZero());
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
		local isable = false;
		if p.isEquipTag(tag) then
			LogInfo("物品 p.isEquipTag(%d)", tag);
			isable = true;
			p.mDragDst.srcTag = tag;
			p.mDragDst.srcType = p.DrageType.Equip;
		elseif p.isBagItemTag(tag) then
			isable = true;
			p.mDragDst.srcTag = tag;
			p.mDragDst.srcType = p.DrageType.BagItem;
		end
		
		if (not isable) then
			return true;
		end
		
		local itemBtn = ConverToButton(param);
		
		if CheckP(itemBtn)then
			p.OnDragItemListener(p.mDragSrc,p.mDragDst, p.DrageState.In, param);
		end
	end
	return true;
end

function p.OnUIEventItemInfo(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventItemInfo[%d] event[%d]", tag, uiEventType);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local nItemId	= uiNode:GetParam1();
		if not Item.IsExistItem(nItemId) then
			LogInfo("p.OnUIEventItemInfo not Item.IsExistItem[%d]", nItemId);
			p.CloseItemInfo();
			return true;
		end
		LogInfo("p.OnUIEventItemInfo[%d]", nItemId);
		if tag == ITEM_OPERATE_EQUIP then
		--穿装备
			local nPetId	= p.mCurrentPetId;
			if not RolePet.IsExistPet(nPetId) then
				LogInfo("穿装备 p.OnUIEventItemInfo not RolePet.IsExistPet[%d]", nPetId);
				p.CloseItemInfo();
				return true;
			end
			MsgItem.SendPackEquip(nItemId, nPetId);
			ShowLoadBar();
		elseif tag == ITEM_OPERATE_UNEQUIP then
		--脱装备
			local nPetId = uiNode:GetParam2();
			if not RolePet.IsExistPet(nPetId) then
				LogInfo("脱装 p.OnUIEventItemInfo not RolePet.IsExistPet[%d]", nPetId);
				p.CloseItemInfo();
				return true;
			end
			MsgItem.SendUnPackEquip(nPetId, nItemId);
			ShowLoadBar();
		elseif tag == ITEM_OPERATE_EQUIP_SEND then
		--发送到聊天
			--TODO
		elseif tag == ITEM_OPERATE_USE then
		--使用物品
			MsgItem.SendUseItem(nItemId);
			ShowLoadBar();
		elseif tag == ITEM_OPERATE_DROP then
		--丢物品
			MsgItem.SendDelItem(nItemId);
			ShowLoadBar();
		elseif tag == ITEM_OPERATE_OPEN then
			if not IsUIShow(NMAINSCENECHILDTAG.PlayerUICompose) then
				CloseMainUI();
				LogInfo("he cheng[%d]", nItemId);
				PlayerUICompose.LoadUI(nItemId);
			end
		else
			LogInfo("p.OnUIEventItemInfo Item[%d]invalid Operate[%d]", nItemId, tag);
		end
	end
	
	p.CloseItemInfo();
	
	return true;
end

function p.CloseItemInfo()
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,p.CloseItemInfo!");
		return;
	end
	local scrollContainer	= RecursiveScrollContainer(scene, { p.TagUiLayer, TAG_ITEM_INFO_CONTAINER});
	if not CheckP(scrollContainer) then
		LogInfo("not CheckP(scrollContainer)");
		return;
	end
	local scroll			= RecursiveScroll(scrollContainer, {TAG_ITEM_INFO});
	if not CheckP(scroll) then
		LogInfo("not CheckP(scroll)");
		return;
	end
	scroll:RemoveAllChildren(true);
	scrollContainer:SetFrameRect(RectZero());
	scroll:SetFrameRect(RectZero());
end


function p.OnUIEventViewChange(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventViewChange[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if TAG_CONTAINER == tag then
			local containter	= ConverToSVC(uiNode);
			if CheckP(containter) and CheckN(param) then
				local beginView	= containter:GetView(param);
				if CheckP(beginView) then
					p.mCurrentPetId = beginView:GetViewId();
					p.refreshCurrentPage();
				end
			end
		end
	end
end

function p.initSubUI()
	p.refreshLeftContainer();
	p.initRightContainer();
	p.refreshRightContainer();
end

function p.refreshLeftContainer()
	local container = p.getContainerById(p.TagLeftContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	--获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
		LogInfo("nil == idTable");
		return;
	end
	
	--local lst, count = MsgMagic.getRoleMatrixList();
	--p.mMatrixList = lst;
	--p.mCurrentPage = 1;
	
	
	for i, v in pairs(idTable) do
	
	local view = createUIScrollView();
	
	if not CheckP(view) then
		LogInfo("view == nil");
		return;
	end
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Horzontal);
	view:SetViewId(v);
	view:SetMovableViewer(container);
	view:SetScrollViewer(container);
	view:SetContainer(container);
	container:AddView(view);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("RoleRealize_L.ini", view, p.OnUIItemEvent, 0, 0);
	uiLoad:Free();
	
	--道法
	local idlist	= ItemPet.GetDaoFaItemList(nPlayerId, v);
	LogInfo("LogInfoT(idlist);");
	for j, k in pairs(idlist) do
		LogInfo("LogInfoT(idlist1);");
		local nPos	= Item.GetItemInfoN(k, Item.ITEM_POSITION);
		local itemBt	= GetEquipButton(view, p.TagPetItem[nPos]);
		if CheckP(equipBtn) then
				LogInfo("LogInfoT(idlist2);");
			equipBtn:ChangeItem(k);
		end
	end
	
	LogInfo("LogInfoT(idlist3);");
	
   end
end

function p.initRightContainer()
	local container = p.getContainerById(p.TagRightContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	
	container:RemoveAllView();
	local rectview = container:GetFrameRect();
	container:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h));
	p.mCurrentPage = 1;
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	
 for i = 1, MAX_BACK_BAG_NUM do
	
	local view = createUIScrollView();
	if not CheckP(view) then
		LogInfo("view == nil");
		return;
	end
	view:Init(false);
	view:SetScrollStyle(UIScrollStyle.Horzontal);
	view:SetViewId(i);
	--view:SetMovableViewer(container);
	--view:SetScrollViewer(container);
	--view:SetContainer(container);
	container:AddView(view);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		return false;
	end
	
	uiLoad:Load("RoleRealize_R_List.ini", view, p.OnUIItemEvent, 0, 0);
	uiLoad:Free();
	
   end
end


function p.refreshRightContainer()
	local container = p.getContainerById(p.TagRightContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local idlistItem	= p.mItemList; --ItemUser.GetDaoFaItemList(nPlayerId);
	local nGridNum		= ConvertN(GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_DAO_BAG));
	
	for i=1, MAX_BACK_BAG_NUM do
		local view = container:GetViewById(i);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag		= p.TagBagItem[j];
				local itemBtn	= _G.GetItemButton(view, nTag);
				if nil ~= itemBtn then
					local nItemId	= 0;
					local nIndex	= (i - 1) * MAX_GRID_NUM_PER_PAGE + j;
					
					nItemId		= idlistItem[nIndex];
					
					nItemId			= nItemId or 0;
					if nIndex <= nGridNum then
						itemBtn:ChangeItem(nItemId);
					else 
						itemBtn:SetLock(true);
					end
				else
					LogError("p.RefreshBackBag item button tag[%d][%d] error", j, nTag);
				end
			end
		end
	 end
end

function p.refreshCurrentPage()
	p.refreshCurrentLeftPage();
	p.refreshCurrentRightPage();
end

function p.refreshCurrentLeftPage()
	--p.mEquipList = ItemPet.GetDaoFaItemList(nPlayerId, p.mCurrentPetId);
	local container = p.getContainerById(p.TagLeftContainer);
	if not CheckP(container) then
		LogInfo("nil == container");
		return;
	end
	
	local scView = container:GetViewById(p.mCurrentPetId);
	
	--道法
	local idlist	= p.mEquipList;--ItemPet.GetDaoFaItemList(nPlayerId, v);
	LogInfo("LogInfoT(idlist) cur[%d];" ,#idlist);
	LogInfoT(idlist);
	for j, k in pairs(p.TagPetItem) do
		LogInfo("LogInfoT(idlist1);j%d", j);
		local nPos	= j; --Item.GetItemInfoN(k, Item.ITEM_POSITION);
		local itemBt	= GetEquipButton(scView, k);
		local v = p.mEquipList[j]
		v = v or 0
		if CheckP(itemBt) then
				LogInfo("LogInfoT(idlist2);");
			itemBt:ChangeItem(v);
		else 
		  LogInfo("LogInfoT(idlist2) not");
		end
	end
	
end

function p.refreshCurrentRightPage()
	p.refreshRightContainer();
end


function p.getContainerById(nId)
	local layer = p.getUiLayer();
	local container = GetScrollViewContainer(layer, nId);
	return container;
	
end

function p.getUiLayer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		return nil;
	end
	
	local layer = GetUiLayer(scene, p.TagUiLayer);
	if not CheckP(layer) then
		LogInfo("nil == layer")
		return nil;
	end
	
	return layer;
end


function p.clickButton(node) 
	
end

function p.ChangeItemInfo(nItemId, bEquip)
	if not CheckN(nItemId) or 
		not CheckB(bEquip) then
		LogInfo("p.ChangeItemInfo invalid arg");
		return;
	end
	
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,p.ChangeItemInfo!");
		return;
	end
	local scrollContainer	= RecursiveScrollContainer(scene, {p.TagUiLayer, TAG_ITEM_INFO_CONTAINER});
	--local scrollContainer	= p.getContainerById(TAG_ITEM_INFO_CONTAINER);
	if not CheckP(scrollContainer) then
		LogInfo("not CheckP(scrollContainer)");
		return;
	end
	local scroll			= RecursiveScroll(scrollContainer, {TAG_ITEM_INFO});
	if not CheckP(scroll) then
		LogInfo("not CheckP(scroll)");
		return;
	end
	
	scroll:RemoveAllChildren(true);
	LogInfo("scroll:RemoveAllChildren();");
	local nWidthLimit		= RectUILayer.size.w / 3;
	local nBGStartX			= RectUILayer.size.w / 6;
	local nBGStartY			= 0;
	local nHeightLimit		= RectUILayer.size.h;
	local nHeight			= ItemUI.AttachItemInfo(scroll, nItemId, nWidthLimit);
	if nHeight <= 0 then
		scrollContainer:SetFrameRect(RectZero());
		scroll:SetFrameRect(RectZero());
		return;
	end
	
	if bEquip then
		nBGStartX	= RectUILayer.size.w / 2;
	end
	
	local itemBtn	= createUIItemButton();
	if CheckP(itemBtn) then
		itemBtn:Init();
		local x = nWidthLimit - (40 + 5) * ScaleFactor;
		local y = 5 * ScaleFactor;
		local w = 40 * ScaleFactor;
		itemBtn:SetFrameRect(CGRectMake(x, y, w, w));
		itemBtn:ChangeItem(nItemId);
		itemBtn:SetTag(TAG_ITEM_INFO_ID);
		scroll:AddChild(itemBtn);
	end
	
	-- 附加操作
	local nItemType		= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	local nType			= ItemFunc.GetType(nItemType);
	local nBtnW			= 40 * ScaleFactor;
	local nBtnInterval	= 10 * ScaleFactor;
	local nBtnH			= 30 * ScaleFactor;
	local nBtn1StartX	= (nWidthLimit - nBtnW * 2 - nBtnInterval) / 2;
	local nBtn2StartX	= nBtn1StartX + nBtnW + nBtnInterval;
	
	LogInfo("nItemType %d, nType%d", nItemType,nType);
	
	if nType == Item.TypeDaoFa then
	--装备
		local nStartX	= nBtn1StartX;
		local nPetId	= p.mCurrentPetId
		if not bEquip then
			if nPetId > 0 then
				local equipBtn = CreateButton("btn_normal.png", "btn_select.png", "装备",
										CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
				if CheckP(equipBtn) then
					nStartX		= nBtn2StartX;
					equipBtn:SetTag(ITEM_OPERATE_EQUIP);
					equipBtn:SetParam1(nItemId);
					equipBtn:SetLuaDelegate(p.OnUIEventItemInfo);
					scroll:AddChild(equipBtn);
				end
			end
			
			local drogBtn = CreateButton("btn_normal.png", "btn_select.png", "丢弃",
									CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
			if CheckP(drogBtn) then
				nStartX	= nBtn1StartX;
				drogBtn:SetTag(ITEM_OPERATE_DROP);
				drogBtn:SetParam1(nItemId);
				drogBtn:SetLuaDelegate(p.OnUIEventItemInfo);
				scroll:AddChild(drogBtn);
				nHeight	= nHeight + nBtnH + 5 * ScaleFactor;
			end
		else
			if nPetId > 0 then
				local unequipBtn = CreateButton("btn_normal.png", "btn_select.png", "卸下",
										CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
				if CheckP(unequipBtn) then
					nStartX		= nBtn2StartX;
					unequipBtn:SetTag(ITEM_OPERATE_UNEQUIP);
					unequipBtn:SetParam1(nItemId);
					unequipBtn:SetParam2(nPetId);
					unequipBtn:SetLuaDelegate(p.OnUIEventItemInfo);
					scroll:AddChild(unequipBtn);
				end
			end
		end
		
		local sendBtn = CreateButton("btn_normal.png", "btn_select.png", "展示",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(sendBtn) then
			sendBtn:SetTag(ITEM_OPERATE_EQUIP_SEND);
			sendBtn:SetParam1(nItemId);
			sendBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			scroll:AddChild(sendBtn);
			nHeight	= nHeight + nBtnH + 5 * ScaleFactor;
		end
		
	end
	
	if nHeight < 45 * ScaleFactor then
		nHeight = 45 * ScaleFactor;
	end
	
	scroll:SetFrameRect(CGRectMake(0, 0, nWidthLimit, nHeight));
	if nHeight < nHeightLimit then
		nBGStartY		= (nHeightLimit - nHeight) / 2;
		nHeightLimit	= nHeight;
	end
	scrollContainer:SetFrameRect(CGRectMake(nBGStartX, nBGStartY, nWidthLimit, nHeightLimit));
	scrollContainer:SetTopReserveDistance(nHeightLimit);
	scrollContainer:SetBottomReserveDistance(nHeightLimit);
	
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end 
	local pic		= pool:AddPictureEx(GetSMImgPath("btn_disable.png"), nWidthLimit, nHeightLimit, false); 
	if not CheckP(pic) then
		return;
	end
	scrollContainer:SetBackgroundImage(pic);
end


function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	
	if msgId == NMSG_Type._MSG_REALIZE_MERGE or msgId == NMSG_Type._MSG_REALIZE_MERGE_ALL then
		p.refreshCurrentPage();
	end
	
	CloseLoadBar();
end

function p.initData()
	local nPlayerId = GetPlayerId();
	local petIds = RolePetUser.GetPetListPlayer(nPlayerId);
	
	if (not p.mCurrentPetId ) or (not RolePet.IsExistPet(p.mCurrentPetId)) then
		p.mCurrentPetId = petIds[1];
	end
	
	p.mEquipList = ItemPet.GetDaoFaItemList(nPlayerId, p.mCurrentPetId);
	p.mItemList = ItemUser.GetDaoFaItemList(nPlayerId);
	MsgRealize.mUIListener = p.processNet;
end

function p.freeData()
	MsgRealize.mUIListener = nil;
end


function p.SetMouse(pic, moveTouch)
	LogInfo("SetMouse");
	if not CheckStruct(moveTouch) then
		LogInfo("SetMouse invalid arg");
		return;
	end
	
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		return;
	end
	
	local idlist = {};
	local imgMouse = RecursiveImage(scene, {p.TagUiLayer, TAG_MOUSE});
	if not CheckP(imgMouse) then
		LogInfo("not CheckP(imgMouse)");
		return;
	end
	
	imgMouse:SetPicture(pic, true);
	
	if CheckP(pic) then
		local size		= pic:GetSize();
		local nMoveX	= moveTouch.x - size.w / 2 - RectUILayer.origin.x;
		local nMoveY	= moveTouch.y - size.h / 2 - RectUILayer.origin.y;
		imgMouse:SetFrameRect(CGRectMake(nMoveX, nMoveY, size.w, size.h));
	else
		LogInfo("imgMouse:SetFrameRect(RectZero)");
		imgMouse:SetFrameRect(RectZero());
	end
end



-- state: 1 start, 2 drager out, 3 drager in
function p.OnDragItemListener(dragerSrc , dragerDst, state, param)
	if (dragerSrc == nil or state == nil or state == 0) then
		return;
	end
	
	if (state == p.DrageState.Out and dragerSrc.srcType == p.DrageType.Equip) then
		
	elseif (state == p.DrageState.Complement) then
		-- p.DrageSrcType
		--local bt = p.getBt(dragerSrc.srcTag);
		--if (bt) then
		--	bt:SetVisible(false);
		--end
		p.SetMouse(nil, SizeZero());
	elseif (state == p.DrageState.In)  then
		if (dragerSrc and dragerDst and p.mItemList) then
			--if (not (dragerSrc.srcType == p.DrageType.Equip and dragerDst.srcType ==  p.DrageType.Equip) ) then
				local srcId, srcIndex = p.getIdByViewTag(dragerSrc.srcTag, dragerSrc.srcType);
				local dstId, dstIndex = p.getIdByViewTag(dragerDst.srcTag, dragerDst.srcType);
				LogInfo("srcIndex:%d, dstIndex:%d", srcIndex, dstIndex);
			
				if (srcId and dstId and dstId > 0 and srcId > 0) then
					if (dragerSrc.srcType == p.DrageType.Equip) then
						p.mEquipList[srcIndex] = 0;  
					elseif (dragerSrc.srcType == p.DrageType.BagItem) then
						local si = ((p.mCurrentPage or 1) - 1) * MAX_GRID_NUM_PER_PAGE + srcIndex;
						p.mItemList[si] = 0;
					end
					MsgRealize.sendRealizeMerge(srcId, dstId); -- 合成
				else
					if (dragerSrc.srcType == p.DrageType.Equip) then
						p.mEquipList[srcIndex] = dstId;
					end
					if (dragerDst.srcType == p.DrageType.Equip) then
						p.mEquipList[dstIndex] = srcId;  
					end
					if (dragerSrc.srcType == p.DrageType.BagItem) then
						local si = ((p.mCurrentPage or 1) - 1) * MAX_GRID_NUM_PER_PAGE + srcIndex  ;
						p.mItemList[si] = dstId;
					end
					if (dragerDst.srcType == p.DrageType.BagItem) then 
						local si = ((p.mCurrentPage or 1) - 1) * MAX_GRID_NUM_PER_PAGE + dstIndex;
						p.mItemList[si] = srcId;
					end
					
					if (dragerDst.srcType == p.DrageType.Equip and dragerSrc.srcType == p.DrageType.BagItem and srcId and srcId > 0 and p.mCurrentPetId) then
						MsgItem.SendPackEquip(srcId, p.mCurrentPetId);
					elseif (dragerDst.srcType == p.DrageType.BagItem and dragerSrc.srcType == p.DrageType.Equip and srcId and srcId > 0 and p.mCurrentPetId) then
						MsgItem.SendUnPackEquip(srcId, p.mCurrentPetId);
					end
				end
				
				p.refreshCurrentPage();
			-- end
		end
	end
		
end

function p.isEquipTag(nTag)
	--if not CheckT(TAG_BAG_LIST) or 0 == table.getn(TAG_BAG_LIST) then
	--	return false;
	--end
	
	for i, v in pairs(p.TagPetItem) do
		if v == nTag then
			return true
		end
	end
	
	return false;
end

function p.isBagItemTag(nTag)
	for i, v in pairs(p.TagBagItem) do
		if v == nTag then
			--p.mItemList[i]
			--if (p.isLeveEnable(p.mCurrentMatrix.type,i, p.mCurrentMatrix.level)) then			
				return true
			--end
		end
	end
	
	return false;
end

function p.getIdByViewTag(nTag, tagType)
	local rtn = nil;
	if (tagType == p.DrageType.Equip ) then
	for i = 1, #p.TagPetItem do 
		if (p.TagPetItem[i] == nTag ) then
			rtn = p.mEquipList[i];
			return rtn, i;
		end
	end
	elseif (tagType == p.DrageType.BagItem) then
	 for i = 1, #p.TagBagItem do 
		if (p.TagBagItem[i] == nTag and p.mItemList) then
			rtn = p.mItemList[i]; --p.mStationList[i];
			return rtn, i;
		end
	 end
	end
	
	return rtn, 0;
end

