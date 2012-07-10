---------------------------------------------------
--描述: 玩家背包界面
--时间: 2012.3.2
--作者: jhzheng
---------------------------------------------------

PlayerUIBackBag = {}
local p = PlayerUIBackBag;

--bg tag
local ID_ROLEATTR_L_BG_CTRL_LIST_LEFT					= 51;
local ID_ROLEATTR_L_BG_CTRL_LIST_NAME					= 50;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_115					= 115;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_133					= 133;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_132					= 132;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG					= 200;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG2					= 151;

--属性主界面tag
local ID_ROLEATTR_L_CTRL_EXP_ROLE						= 33;
local ID_ROLEATTR_L_CTRL_BUTTON_SHOES					= 62;
local ID_ROLEATTR_L_CTRL_BUTTON_DRESS					= 61;
local ID_ROLEATTR_L_CTRL_BUTTON_HELMET				= 60;
local ID_ROLEATTR_L_CTRL_BUTTON_AMULET				= 59;
local ID_ROLEATTR_L_CTRL_BUTTON_WEAPON				= 58;
local ID_ROLEATTR_L_CTRL_BUTTON_SOUL					= 57;
local ID_ROLEATTR_L_CTRL_BUTTON_INHERIT				= 56;
local ID_ROLEATTR_L_CTRL_BUTTON_LEAVE					= 31;
local ID_ROLEATTR_L_CTRL_BUTTON_PILL					= 30;
local ID_ROLEATTR_L_CTRL_BUTTON_TRAIN					= 29;
local ID_ROLEATTR_L_CTRL_TEXT_MAGIC					= 28;
local ID_ROLEATTR_L_CTRL_TEXT_SKILL					= 27;
local ID_ROLEATTR_L_CTRL_TEXT_26						= 26;
local ID_ROLEATTR_L_CTRL_TEXT_25						= 25;
local ID_ROLEATTR_L_CTRL_TEXT_ABILITY					= 24;
local ID_ROLEATTR_L_CTRL_TEXT_23						= 23;
local ID_ROLEATTR_L_CTRL_TEXT_LIFE					= 22;
local ID_ROLEATTR_L_CTRL_TEXT_21						= 21;
local ID_ROLEATTR_L_CTRL_TEXT_FORCE					= 20;
local ID_ROLEATTR_L_CTRL_TEXT_19						= 19;
local ID_ROLEATTR_L_CTRL_TEXT_JOB						= 17;
local ID_ROLEATTR_L_CTRL_TEXT_16						= 16;
local ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG				= 9;

-- 右边界面tag
local ID_ROLEBAG_R_CTRL_LIST_PAGE					= 65;
local ID_ROLEBAG_R_CTRL_BUTTON_SHOP					= 113;
local ID_ROLEBAG_R_CTRL_HORIZON_LIST_M				= 680;
local ID_ROLEBAG_R_CTRL_BUTTON_CLOSE				= 225;
local ID_ROLEBAG_R_CTRL_BUTTON_STORAGE				= 50;
local ID_ROLEBAG_R_CTRL_BUTTON_TIDY					= 48;
local ID_ROLEBAG_R_CTRL_PICTURE_BG					= 226;


-- 格子界面tag
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_16				= 77;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_15				= 76;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_14				= 75;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_12				= 74;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_11				= 73;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_10				= 72;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_8				= 71;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_7				= 70;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_6				= 69;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_4				= 68;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_3				= 67;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_2				= 66;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_13				= 65;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_9				= 64;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_5				= 63;
local ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_1				= 62;


-- 常量宏
local MAX_BACK_BAG_NUM				= 3;
local MAX_GRID_NUM_PER_PAGE			= 16;


-- 界面控件tag定义
--local TAG_CONTAINER = 2;						--容器tag
local TAG_LAYER_GRID = 12345;					--属性格子层tag

local TAG_MOUSE	= 9999;							--鼠标图片tag
local TAG_BAG_LIST = {};						--背包tag列表
local TAG_EQUIP_LIST = {};						--装备tag列表
local TAG_ITEM_INFO_CONTAINER = 9997;			--物品信息与操作
local TAG_ITEM_INFO = 9998;						--物品信息与操作
local TAG_ITEM_INFO_ID = 9996;					--物品信息物品

--物品操作枚举
local ITEM_OPERATE_EQUIP = 600;					--穿装备
local ITEM_OPERATE_UNEQUIP = 601;				--脱装备
local ITEM_OPERATE_EQUIP_SEND = 602;			--发送到聊天
local ITEM_OPERATE_USE = 603;					--使用物品
local ITEM_OPERATE_DROP = 604;					--丢物品
local ITEM_OPERATE_OPEN = 605;					--合成


-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

--开通格子
local INIT_GRID_NUM		= 16;
local l_nOpenGridDlgId	= 0;
local l_nCurOpenGridNum = 0;

--往背包增加一个物品
function p.AddItem(idItem)
	--LogInfo("p.AddItem");
	if not CheckN(idItem) then
		return;
	end
	
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
		return;
	end
	local container		= p.GetBackBagContainer();
	if not CheckP(container) then
		LogInfo("p.AddItem not CheckP(container)");
		return;
	end
	local nCount = ConvertN(container:GetViewCount());
	if nCount <= 0 then
		LogInfo("p.AddItem nCount <= 0");
		return;
	end

	for	i=1, nCount do
		local sv = container:GetViewById(i);
		if not CheckP(sv) then
			LogInfo("not CheckP(sv) id[%d]", i);
			break;
		end
		for i, v in ipairs(TAG_BAG_LIST) do
			local itemButton = RecursiveItemBtn(sv, {v});
			if CheckP(itemButton) and 0 == itemButton:GetItemId() then
				itemButton:ChangeItem(idItem);
				break;
			end
		end 
	end
end

--从背包删除一个物品
function p.DelItem(idItem)
	--LogInfo("p.DelItem");
	if not CheckN(idItem) then
		return;
	end
	
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
		return;
	end
	local container		= p.GetBackBagContainer();
	if not CheckP(container) then
	end
	local nCount = ConvertN(container:GetViewCount());
	if nCount <= 0 then
		return;
	end
	
	LogInfo("bag page count[%d]", nCount);
	LogInfo("del item[%d]", idItem);
	
	for	i=1, nCount do
		local sv = container:GetViewById(i);
		if not CheckP(sv) then
			LogInfo("not CheckP(sv) id[%d]", i);
			break;
		end
		for i, v in ipairs(TAG_BAG_LIST) do
			local itemButton = RecursiveItemBtn(sv, {v});
			LogInfo("item tag[%d]id[%d]", v, itemButton:GetItemId());
		end 
	end
	
	for	i=1, nCount do
		local sv = container:GetViewById(i);
		if not CheckP(sv) then
			LogInfo("not CheckP(sv) id[%d]", i);
			break;
		end
		for i, v in ipairs(TAG_BAG_LIST) do
			local itemButton = RecursiveItemBtn(sv, {v});
			if CheckP(itemButton) and idItem == itemButton:GetItemId() then
				itemButton:ChangeItem(0);
			end
		end 
	end
end

--在指定位置显示装备
function p.AddEquip(idPet, idItem, nPostion)	
	--LogInfo("p.AddEquip");
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
		return;
	end
	
	if not CheckN(idPet) or
		not CheckN(idItem) or
		not CheckN(nPostion) then
		return;
	end
	
	local view = p.GetPetView(idPet);
	if not CheckP(view) then
		return;
	end
	
	local equipBtn = p.GetPetEquipBtnByPos(view, nPostion);
	if not CheckP(equipBtn) then
		return;
	end
	
	equipBtn:ChangeItem(idItem);
end

--从指定位置删除装备
function p.DelEquip(idPet, idItem, nPostion)
	--LogInfo("p.DelEquip");
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
		return;
	end
	
	if not CheckN(idPet) or
		not CheckN(nPostion) then
		return;
	end
	
	local view = p.GetPetView(idPet);
	if not CheckP(view) then
		return;
	end
	
	local equipBtn = p.GetPetEquipBtnByPos(view, nPostion);
	if not CheckP(equipBtn) then
		return;
	end
	
	if equipBtn:GetItemId() == idItem then
		equipBtn:ChangeItem(0);
	end
end

function p.LoadUI()
	p.Init();
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,load PlayerBackBag failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerBackBag);
	layer:SetFrameRect(RectUILayer);
	--layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scene:AddChild(layer);
	
	--[[
	local containter = createUIScrollViewContainer();
	if (nil == containter) then
		layer:Free();
		return false;
	end
	containter:Init();
	containter:SetStyle(UIScrollStyle.Horzontal);
	containter:SetFrameRect(CGRectMake(CONTAINTER_X, CONTAINTER_Y, CONTAINTER_W, CONTAINTER_H));
	containter:SetViewSize(CGSizeMake(CONTAINTER_W, CONTAINTER_H));
	containter:SetLeftReserveDistance(CONTAINTER_W);
	containter:SetRightReserveDistance(CONTAINTER_W);
	containter:SetTag(TAG_CONTAINER);
	layer:AddChild(containter);
	--]]
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("RoleAttr_L_BG.ini", layer, nil, 0, 0);
	
	local layerGrid = createNDUILayer();
	if not CheckP(layerGrid) then
		layer:Free();
		return false;
	end
	layerGrid:Init();
	layerGrid:SetTag(TAG_LAYER_GRID);
	layerGrid:SetFrameRect(CGRectMake(ATTR_OFFSET_X, ATTR_OFFSET_Y, RectUILayer.size.w / 2, RectUILayer.size.h));
	layer:AddChild(layerGrid);
	
	uiLoad:Load("RoleBag_R.ini", layerGrid, p.OnUIEventRightPanel, 0, 0);
	
	uiLoad:Free();
	
	p.LoadPageView();
	
	local containter = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	if not CheckP(containter) then
		layer:Free();
		return false;
	end
	containter:SetViewSize(containter:GetFrameRect().size);
	containter:SetLuaDelegate(p.OnUIEventViewChange);
	
	local petNameContainer = p.GetPetNameSVC();
	if CheckP(petNameContainer) then
		petNameContainer:SetCenterAdjust(true);
		local size		= petNameContainer:GetFrameRect().size;
		local viewsize	= CGSizeMake(size.w / 3, size.h)
		petNameContainer:SetLeftReserveDistance(size.w / 2 + viewsize.w / 2);
		petNameContainer:SetRightReserveDistance(size.w / 2 - viewsize.w / 2);
		petNameContainer:SetViewSize(viewsize);
		petNameContainer:SetLuaDelegate(p.OnUIEventViewChange);
	end
	
	p.RefreshContainer();
	p.UpdatePetAttr();
	--背包初始化
	p.LoadBackBagUI();
	p.RefreshBackBag();
	--p.SetBackBagPage(0);
	p.SetFocusOnPage(1);
	
	p.SetGridNum(GetPlayerId());
	
	if CheckP(petNameContainer) then
		petNameContainer:ShowViewByIndex(0);
	end
	
	--鼠标图片初始化
	local imgMouse	= createNDUIImage();
	imgMouse:Init();
	imgMouse:SetTag(TAG_MOUSE);
	layer:AddChildZ(imgMouse, 2);
	
	--物品信息层初始化
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
	
	return true;
end

--获取背包容器节点
function p.GetBackBagContainer()
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,LoadBackBag failed!");
		return nil;
	end
	local idlist = {};
	table.insert(idlist, NMAINSCENECHILDTAG.PlayerBackBag);
	table.insert(idlist, TAG_LAYER_GRID);
	table.insert(idlist, ID_ROLEBAG_R_CTRL_HORIZON_LIST_M);
	local containter = RecursiveSVC(scene, idlist);
	return containter;
end

--加载背包UI
function p.LoadBackBagUI()
	local container = p.GetBackBagContainer();
	if not container then
		LogInfo("p.LoadBackBagUI p.GetBackBagContainer == nil");
		return;
	end
	
	local rectview = container:GetFrameRect();
	if nil == rectview then
		LogInfo("p.LoadBackBagUI nil == rectview");
		return;
	end
	
	container:SetViewSize(rectview.size);
	
	for i=1, MAX_BACK_BAG_NUM do
		local view = createUIScrollView();
		if view == nil then
			LogInfo("p.LoadBackBagUI createUIScrollView failed");
			return;
		end
		view:Init(false);
		view:SetViewId(i);
		container:AddView(view);
		
		local uiLoad = createNDUILoad();
		if uiLoad ~= nil then
			uiLoad:Load("RoleBag_R_List.ini", view, p.OnUIEventBag, 0, 0);
			uiLoad:Free();
		end
	end
end

--内部接口
function p.OnDragItem(nItemId, posMove)
	LogInfo("p.OnDragItem item[%d], pos[%d][%d]", nItemId, posMove.x, posMove.y);
end

function p.OnDragItemComplete()
	LogInfo("p.OnDragItemComplete");
end

function p.GetPageByItemNode(uiNode)
	if not CheckP(uiNode) then
		return 0;
	end
	if not p.IsGridTag(uiNode:GetTag()) then
		return 0;
	end
	local sv = PRecursiveSV(uiNode, 1);
	if not CheckP(sv) then
		return 0;
	end
	return sv:GetViewId();
end

function p.GetPetIdByEquipNode(uiNode)
	if not CheckP(uiNode) then
		return -1;
	end
	if not p.IsEquipTag(uiNode:GetTag()) then
		return -1;
	end
	local sv = PRecursiveSV(uiNode, 1);
	if not CheckP(sv) then
		return -1;
	end
	return sv:GetViewId();
end 

-- Ui事件处理开始
function p.OnUIEventViewChange(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventViewChange[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		local containter	= ConverToSVC(uiNode);
		local nPetId		= 0;
		if CheckP(containter) and CheckN(param) then
			local beginView	= containter:GetView(param);
			if CheckP(beginView) then
				nPetId	= beginView:GetViewId()
				-- ???
				if (RoleTrainUI.isInShow()) then
					RoleTrainUI.LoadUI(beginView:GetViewId());
				end
			end
		end
		
		if not nPetId or nPetId <= 0 then
			return;
		end
	
		if ID_ROLEATTR_L_BG_CTRL_LIST_LEFT == tag then
			containter	= p.GetPetNameSVC();
			if CheckP(containter) then
				containter:ScrollViewById(nPetId);
			end
		elseif ID_ROLEATTR_L_BG_CTRL_LIST_NAME == tag then
			LogInfo("ID_ROLEATTR_L_BG_CTRL_LIST_NAME == tag");
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ScrollViewById(nPetId);
			end
		end

	end
end

function p.OnUIEventClickPetName(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local view	= PRecursiveSV(uiNode, 1);
		if CheckP(view) then
			local nPetId		= ConvertN(view:GetViewId())
			local containter	= p.GetPetNameSVC();
			if CheckP(containter) then
				containter:ScrollViewById(nPetId);
			end
			
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ScrollViewById(nPetId);
			end
		end
	end
	
	return true;
end

function p.OnUIEventRightPanel(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventRightPanel[%d] event[%d]", tag, uiEventType);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_ROLEBAG_R_CTRL_BUTTON_CLOSE then
			local scene = GetSMGameScene();
			if scene ~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.PlayerBackBag, true);
				return true;
			end
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if tag == ID_ROLEBAG_R_CTRL_HORIZON_LIST_M then
			--p.SetBackBagPage(param);
			if CheckN(param) then
				p.SetFocusOnPage(param + 1);
			end
		end 
	end
	return true;
end

function p.OnUIEvenPet(uiNode, uiEventType, param) 
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvenPet[%d]", tag);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ROLEATTR_L_CTRL_BUTTON_INHERIT == tag then
				if not IsUIShow(NMAINSCENECHILDTAG.RoleInherit) then
					CloseMainUI();
					RoleInherit.LoadUI();
				end
				return true;
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_LEAVE then
				local view = PRecursiveSV(uiNode, 1);
				if not CheckP(view) then
					LogInfo("p.OnUIEventScroll ot CheckP(view)");
					return true;
				end
				p.OnClickPetLeave(view:GetViewId());
				return true;
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_PILL then
		  if not IsUIShow(NMAINSCENECHILDTAG.PlayerUIPill) then
			local view = PRecursiveSV(uiNode, 1);
			local nPetId = view:GetViewId();
			if CheckP(view) then
			  CloseMainUI();
			  PlayerUIPill.LoadUI(nPetId);
			end
		  end
		  return true;		
		end

		
		local equipBtn = ConverToEquipBtn(uiNode);
		if not CheckP(equipBtn) then
			LogInfo("点击装备 not CheckP(itemBtn) ");
			return true;
		end
		LogInfo("equip p.ChangeItemInfo[%d]", equipBtn:GetItemId());
		p.ChangeItemInfo(equipBtn:GetItemId(), true);
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
		--装备往外拖
		if not p.IsEquipTag(tag) then
			LogInfo("装备往外拖 not p.IsEquipTag(tag)");
			return true;
		end
		if not CheckStruct(param) then
			LogInfo("装备往外拖 invalid param");
			return true;
		end
		
		local equipBtn = ConverToEquipBtn(uiNode);
		if not CheckP(equipBtn) then
			LogInfo("装备往外拖 not CheckP(equipBtn) ");
			return true;
		end
		
		p.OnDragItem(equipBtn:GetItemId(), param);
		local nItemId	= equipBtn:GetItemId();
		if CheckN(nItemId) and nItemId > 0 then --and not IsMouseHasSet() 
			p.SetMouse(equipBtn:GetImageCopy(), param);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
		--装备往外拖完成
		if not p.IsEquipTag(tag) then
			LogInfo("装备往外拖完成 not p.IsEquipTag(tag)");
			return true;
		end
		local equipBtn = ConverToEquipBtn(uiNode);
		if not CheckP(equipBtn) then
			LogInfo("装备往外拖完成 not CheckP(equipBtn) ");
			return true;
		end
		p.OnDragItemComplete();
		p.SetMouse(nil, SizeZero());
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
		--其它地方的物品拖到装备上
		if not p.IsEquipTag(tag) then
			LogInfo("它地方的物品拖到装备上 not p.IsEquipTag[%d]", tag);
			return true;
		end
		
		local equipBtn = ConverToEquipBtn(uiNode);
		if not CheckP(equipBtn) then
			LogInfo("其它地方的物品拖到装备上 not CheckP(equipBtn) ");
			return true;
		end
		if not CheckP(param) then
			LogInfo("其它地方的物品拖到装备上 invalid param ");
			return true;
		end
		local itemBtn = ConverToItemButton(param);
		local equipBtn = ConverToEquipBtn(param);
		if CheckP(itemBtn) and CheckP(equipBtn) then
		-- src 为装备
			LogInfo("scr 装备 拖到 装备上");
		elseif CheckP(itemBtn) and not CheckP(equipBtn) then
		-- src 为物品
			local pageNum	= ConvertN(p.GetPageByItemNode(param));
			local nPetId		= ConvertN(p.GetPetIdByEquipNode(uiNode));
			LogInfo("drag src 第[%d]页物品[%d], dst 宠物id[%d]tag[%d]", 
					pageNum, param:GetTag(), nPetId, uiNode:GetTag());
					
			local nItemId	= ConvertN(itemBtn:GetItemId());
			if nItemId > 0 and Item.IsExistItem(nItemId) and
				nPetId > 0 and RolePet.IsExistPet(nPetId) and ItemFunc.CanEquip(nItemId) then
				MsgItem.SendPackEquip(nItemId, nPetId);
				ShowLoadBar();
			end
		else
			LogInfo("非背包或装备的物品拖到装备上");
		end
	end
	
	return true;
end

function p.OnUIEventBag(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventBag[%d] event[%d]", tag, uiEventType);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local itemBtn = ConverToItemButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("点击物品 not CheckP(itemBtn) ");
		end
		LogInfo("p.ChangeItemInfo[%d]", itemBtn:GetItemId());
		if itemBtn:IsLock() then
			local pageNum		= ConvertN(p.GetPageByItemNode(itemBtn));
			local nGridIndex	= ConvertN(p.GetIndexByGridTag(tag));
			if nGridIndex > 0 and pageNum > 0 then
				local nOpenNum	= (pageNum - 1) * MAX_GRID_NUM_PER_PAGE + nGridIndex;
				
				if nOpenNum > INIT_GRID_NUM then
					local tip		= "购买" .. (nOpenNum - INIT_GRID_NUM) .. "格子需要" .. 2 * (nOpenNum - INIT_GRID_NUM) .. "元宝";
					l_nCurOpenGridNum	= nOpenNum;
					l_nOpenGridDlgId	= CommonDlg.ShowNoPrompt(tip, p.OnCommonDlg, true);
					--MsgPlayer.SendOpenBagGrid(nOpenNum);
				end
			end
		else
			p.ChangeItemInfo(itemBtn:GetItemId(), false);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
		--物品往外拖
		if not p.IsGridTag(tag) then
			LogInfo("物品往外拖 not p.IsGridTag(tag)");
			return true;
		end
		if not CheckStruct(param) then
			LogInfo("物品往外拖 invalid param");
			return true;
		end
		
		local itemBtn = ConverToItemButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("物品往外拖 not CheckP(itemBtn) ");
			return true;
		end
		p.OnDragItem(itemBtn:GetItemId(), param);
		local nItemId	= itemBtn:GetItemId();
		if CheckN(nItemId) and nItemId > 0 then -- and not IsMouseHasSet()
			p.SetMouse(itemBtn:GetImageCopy(), param);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
		--物品往外拖完成
		if not p.IsGridTag(tag) then
			LogInfo("物品往外拖完成 not p.IsGridTag(tag)");
			return true;
		end
		local itemBtn = ConverToItemButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("物品往外拖完成 not CheckP(itemBtn) ");
			return true;
		end
		p.OnDragItemComplete();
		p.SetMouse(nil, SizeZero());
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
		--其它地方的物品或装备拖到物品上
		if not p.IsGridTag(tag) then
			LogInfo("其它地方的物品或装备拖到物品上 not p.IsGridTag(tag)");
			return true;
		end
		
		local itemBtn = ConverToItemButton(param);
		local equipBtn = ConverToEquipBtn(param);
		if CheckP(itemBtn) and CheckP(equipBtn) then
		-- src 为装备
			local pageNum	= p.GetPageByItemNode(uiNode);
			local nPetId		= p.GetPetIdByEquipNode(equipBtn);
			LogInfo("scr petid[%d], 装备tag[%d] 拖到第[%d]页物品[%d]上",
					nPetId, equipBtn:GetTag(), pageNum, uiNode:GetTag());
			local nItemId	= ConvertN(itemBtn:GetItemId());
			if nItemId > 0 and Item.IsExistItem(nItemId) and
				RolePet.IsExistPet(nPetId) then
				MsgItem.SendUnPackEquip(nPetId, nItemId);
				ShowLoadBar();
			end
		elseif CheckP(itemBtn) and not CheckP(equipBtn) then
		-- src 为物品
			local srcPageNum	= p.GetPageByItemNode(param);
			local dstPageNum	= p.GetPageByItemNode(uiNode);
			LogInfo("scr第[%d]页物品[%d], 拖到scr第[%d]页物品[%d]上",
					srcPageNum, param:GetTag(), dstPageNum, uiNode:GetTag());
		else
			LogInfo("非其它地方的物品或装备拖到物品上");
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE_CLICK then
		LogInfo("双击....");
		local itemBtn = ConverToItemButton(uiNode);
		if not CheckP(itemBtn) then
			LogInfo("双击物品 not CheckP(itemBtn) ");
		end
		LogInfo("p.UseItem[%d]", itemBtn:GetItemId());
		p.UseItem(itemBtn:GetItemId());
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
			local nPetId	= p.GetCurPetId();
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

function p.OnClickPetLeave(nPetId)
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("p.OnPetLeave invalid petid");
		return;
	end
	
	if RolePetFunc.IsMainPet(nPetId) then
		--打开客栈
		if not IsUIShow(NMAINSCENECHILDTAG.RoleInvite) then
			CloseMainUI();
			RoleInvite.LoadUI();
		end
	else
		--发送离队消息
		LogInfo("call send pet[%d] leave", nPetId);
		MsgRolePet.SendPetLeaveAction(nPetId);
	end 
end

function p.OnUIEventClickPage(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventItemInfo[%d] event[%d]", tag, uiEventType);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag >=1 and tag <= MAX_BACK_BAG_NUM then
			local container		= p.GetBackBagContainer();
			if CheckP(container) then
				container:ScrollViewById(tag);
			end 
		end
	end
	
	return true;
end

function p.OnCommonDlg(nId, nEvent, param)
	if nId == l_nOpenGridDlgId then
		if nEvent == CommonDlg.EventOK and CheckN(l_nCurOpenGridNum) and l_nCurOpenGridNum > INIT_GRID_NUM then
			MsgPlayer.SendOpenBagGrid(l_nCurOpenGridNum);
		end
		
		l_nCurOpenGridNum = 0;
	end
end

-- Ui事件处理结束

function p.SetPetEnumN(pParent, nEnum, nTag, nRoleId, nPetId)
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("PlayerUIAttr SetPetEnumN invalid nPetId[%d]", nPetId);
		return;
	end
	local str = tostring(RolePet.GetPetInfoN(nPetId, nEnum));
	SetLabel(pParent, nTag, str);
end

function p.SetPetEnumS(pParent, nEnum, nTag, nRoleId, nPetId)
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("PlayerUIAttr SetPetEnumN invalid nPetId[%d]", nPetId);
		return;
	end
	LogInfo("名字%s", RolePet.GetPetInfoS(nPetId, nEnum));
	SetLabel(pParent, nTag, RolePet.GetPetInfoS(nPetId, nEnum));
end

function p.LoadPageView()
	local svc	= p.GetPageViewContainer();
	if not CheckP(svc) then
		return;
	end
	local svcSize	= svc:GetFrameRect().size;
	svc:SetViewSize(svcSize, svcSize.h);
		
	local view = createUIScrollView();
	if view == nil then
		LogInfo("p.LoadPageView createUIScrollView failed");
		return;
	end
	view:Init(false);
	svc:AddView(view);
	local pool = DefaultPicPool();
	if not CheckP then
		return;
	end
	
	for i=1, MAX_BACK_BAG_NUM do
		local picname = nil;
		if 1 == i then
			picname	= "page_1.png";
		elseif 2 == i then
			picname	= "page_2.png";
		elseif 3 == i then
			picname	= "page_3.png";
		end

		local btn	= _G.CreateButton("", picname, "", 
										CGRectMake(svcSize.w / 3 * (i - 1), 0, svcSize.w / 3, svcSize.h), 12,
										picname, true, "page_circle.png");
		if CheckP(btn) then
			btn:SetLuaDelegate(p.OnUIEventClickPage);
			btn:SetTag(i);
			view:AddChild(btn);
		end
	end
end

function p.GetPageViewContainer()
	local scene = GetSMGameScene();	
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load p.LoadPageView failed!");
		return;
	end
	
	local svc	= RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerBackBag, TAG_LAYER_GRID, ID_ROLEBAG_R_CTRL_LIST_PAGE});
	return svc;
end

function p.GetPageView()
	local svc	= p.GetPageViewContainer();
	if not CheckP(svc) then
		return nil;
	end
	
	local view = svc:GetView(0);
	return view;
end

function p.SetFocusOnPage(nPage)
	if not CheckN(nPage) or 
		nPage < 1 or 
		nPage > MAX_BACK_BAG_NUM then
		return;
	end
	
	local view	= p.GetPageView();
	if not CheckP(view) then
		return;
	end
	
	local btn = RecursiveButton(view, {nPage});
	if not CheckP(btn) then
		return;
	end
	
	view:SetFocus(btn);
end

function p.GetPetNameSVC()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	local svc = RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerBackBag, ID_ROLEATTR_L_BG_CTRL_LIST_NAME});
	return svc;
end

function p.ContainerAddPetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local strPetName = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	
	local container	= p.GetPetNameSVC();
	if not CheckP(container) then
		return;
	end
	
	local view = createUIScrollView();
	if not CheckP(view) then
		return;
	end
	view:Init(false);
	view:SetViewId(nPetId);
	container:AddView(view);
	
	local size	= view:GetFrameRect().size;
	local btn	= _G.CreateButton("", "", strPetName, CGRectMake(0, 0, size.w, size.h), 12);
	if CheckP(btn) then
		btn:SetLuaDelegate(p.OnUIEventClickPetName);
		view:AddChild(btn);
	end
end

function p.ContainerShowPetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local container	= p.GetPetNameSVC();
	if not CheckP(container) then
		return;
	end
	
	container:ShowViewById(nPetId);
end

function p.ContainerRemovePetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	local container	= p.GetPetNameSVC();
	if not CheckP(container) then
		return;
	end
	
	container:RemoveViewById(nPetId);
end

function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local taglist = {};
	table.insert(taglist, NMAINSCENECHILDTAG.PlayerBackBag);
	table.insert(taglist, ID_ROLEATTR_L_BG_CTRL_LIST_LEFT);

	local container = RecursiveSVC(scene, taglist);
	return container;
end

function p.GetPetView(nPetId)
	if not CheckN(nPetId) then
		return nil;
	end
	local parent	= p.GetPetParent();
	if not CheckP(parent) then
		return nil;
	end
	
	return parent:GetViewById(nPetId);
end

function p.GetCurPetView()
	local parent	= p.GetPetParent();
	if not CheckP(parent) then
		return nil;
	end
	
	return parent:GetBeginView(); 
end

function p.GetCurPetId()
	local view	= p.GetCurPetView();
	if not CheckP(view) then
		return 0;
	end
	
	return view:GetViewId();
end

function p.GetPetEquipBtnByPos(viewPet, nPostion)
	if not CheckN(nPostion) or not CheckP(viewPet) then
		return nil;
	end
	
	local nTag	= TAG_EQUIP_LIST[nPostion];
	if not CheckN(nTag) then
		return nil;
	end
	
	return _G.GetEquipButton(viewPet, nTag);
end

function p.RefreshContainer()
	local container = p.GetPetParent();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	
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
	
	LogInfo("p.RefreshContainer");
	LogInfoT(idTable);
	LogInfo("p.RefreshContainer");
	
	local rectview = container:GetFrameRect();
	if nil == rectview then
		LogInfo("nil == rectview");
		return;
	end
	for i, v in ipairs(idTable) do
		local view = createUIScrollView();
		if view == nil then
			LogInfo("view == nil");
			return;
		end
		view:Init(false);
		view:SetViewId(v);
		container:AddView(view);
		
		local uiLoad = createNDUILoad();
		if uiLoad ~= nil then
			uiLoad:Load("RoleAttr_L.ini", view, p.OnUIEvenPet, 0, 0);
			uiLoad:Free();
		else
			return;
		end
		
		--加上人物名字
		p.ContainerAddPetName(v);
		
		--设置离队标签
		local leaveBtn	= RecursiveButton(view, {ID_ROLEATTR_L_CTRL_BUTTON_LEAVE});
		if CheckP(leaveBtn) then
			p.SetPetLeaveText(leaveBtn, v);
		end
		
		--如果是人物去掉传承按钮
		if RolePetFunc.IsMainPet(v) then
			local inheritBtn	= RecursiveButton(view, {ID_ROLEATTR_L_CTRL_BUTTON_INHERIT});
			if CheckP(inheritBtn) then
				inheritBtn:RemoveFromParent(true);
			end
		end
		
		local pRoleForm = GetUiNode(view, ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG);
		if nil ~= pRoleForm then
			local rectForm	= pRoleForm:GetFrameRect();
			local roleNode = createUIRoleNode();
			if nil ~= roleNode then
				roleNode:Init();
				roleNode:SetFrameRect(CGRectMake(0, 0, rectForm.size.w, rectForm.size.h));
				roleNode:ChangeLookFace(RolePetFunc.GetLookFace(v));
				pRoleForm:AddChild(roleNode);
			end
		end
		
		--装备
		local idlist	= ItemPet.GetEquipItemList(nPlayerId, v);
		LogInfo("LogInfoT(idlist);");
		LogInfoT(idlist);
		for i, v in ipairs(idlist) do
			local nPos	= Item.GetItemInfoN(v, Item.ITEM_POSITION);
			local nTag	= p.GetEquipTag(nPos);
			if nTag > 0 then
				local equipBtn	= GetEquipButton(view, nTag);
				if CheckP(equipBtn) then
					equipBtn:ChangeItem(v);
				end
			end
		end
		
	end
end

function p.SetPetAttr(petView, nPetDataIndex, str)
	if not CheckP(petView) or
		not CheckN(nPetDataIndex) or
		not CheckS(str) then
		LogInfo("PlayerUIAttr.SetPetAttr invalid arg");
		return;
	end
	
	local nTag = 0;
	if nPetDataIndex == PET_ATTR.PET_ATTR_TYPE then
	--职业
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_JOB;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHYSICAL then
	--武力
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_LIFE then
	--生命
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_LIFE;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SUPER_SKILL then
	--绝技
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_ABILITY;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SKILL then
	--技能
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_SKILL;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC then
	--法术
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_MAGIC;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_NAME then
	--名字
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_PLAYER_NAME;
	end
	
	if nTag > 0 then
		SetLabel(petView, nTag, str);
	end
end

function p.UpdatePetAttrById(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local container = p.GetPetParent();
	if not CheckP(container) then
		return;
	end
	
	local nPlayerId = GetPlayerId();
	if not CheckN(nPlayerId) then
		return;
	end
	
	if not RolePetUser.IsExistPet(nPlayerId, nPetId) then
		return;
	end
	
	local view	= container:GetViewById(nPetId);
	if not CheckP(view) then
		return;
	end
	--名字
	--p.SetPetAttr(view, PET_ATTR.PET_ATTR_NAME, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	--职业
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_TYPE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));
	--武力
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHYSICAL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL));
	--生命
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LIFE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE));
	--绝技
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SUPER_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SUPER_SKILL));
	--技能
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));
	--法术
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC));
	
	local expUI	= RecursivUIExp(view, {ID_ROLEATTR_L_CTRL_EXP_ROLE});
	if CheckP(expUI) then
		expUI:SetProcess(ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_EXP)));
		expUI:SetTotal(ConvertN(RolePetFunc.GetNextLvlExp(nPetId)));
	end
end

function p.UpdatePetAttr()
	--获取玩家宠物id列表
	local nPlayerId = GetPlayerId();
	if not CheckN(nPlayerId) then
		return;
	end
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if not CheckT(idTable) then
		return;
	end

	for i, v in ipairs(idTable) do
		p.UpdatePetAttrById(v);
	end
end

function p.GetItemButton(nItemId)
	local container = p.GetBackBagContainer();
	if not container then
		LogInfo("p.GetItemButton p.GetBackBagContainer == nil");
		return nil;
	end
	
	for i=1, MAX_BACK_BAG_NUM do
		local view = container:GetView(i - 1);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag		= p.GetGridTag(j);
				local itemBtn	= _G.GetItemButton(view, nTag);
				if nil ~= itemBtn then
					if itemBtn:GetItemId() == nItemId then
						return itemBtn;
					end
				end
			end
		end
	end
	
	return nil;
end

function p.GetEmptyItemButton()
	local container = p.GetBackBagContainer();
	if not container then
		LogInfo("p.GetItemButton p.GetBackBagContainer == nil");
		return nil;
	end
	
	for i=1, MAX_BACK_BAG_NUM do
		local view = container:GetView(i - 1);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag		= p.GetGridTag(j);
				local itemBtn	= _G.GetItemButton(view, nTag);
				if nil ~= itemBtn then
					local nItemId	= itemBtn:GetItemId();
					nItemId			= nItemId or 0;
					if 0 == nItemId then
						return itemBtn;
					end
				end
			end
		end
	end
	
	return nil;
end

function p.CloseItemInfo()
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,p.CloseItemInfo!");
		return;
	end
	local scrollContainer	= RecursiveScrollContainer(scene, {NMAINSCENECHILDTAG.PlayerBackBag, TAG_ITEM_INFO_CONTAINER});
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

function p.UseItem(nItemId)
	if not CheckN(nItemId) then
		LogInfo("PlayerBackBag.UseItem invalid arg");
		return;
	end
	
	local nItemType		= Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	local nType			= ItemFunc.GetType(nItemType);
	if nType == Item.TypeConsume then
		MsgItem.SendUseItem(nItemId);
		ShowLoadBar();
	end
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
	local scrollContainer	= RecursiveScrollContainer(scene, {NMAINSCENECHILDTAG.PlayerBackBag, TAG_ITEM_INFO_CONTAINER});
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
	
	if nType == Item.TypeEquip then
	--装备
		local nStartX	= nBtn1StartX;
		local nPetId	= p.GetCurPetId();
		if not bEquip then
			if nPetId > 0 then
				local equipBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "装备",
										CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
				if CheckP(equipBtn) then
					nStartX		= nBtn2StartX;
					equipBtn:SetTag(ITEM_OPERATE_EQUIP);
					equipBtn:SetParam1(nItemId);
					equipBtn:SetLuaDelegate(p.OnUIEventItemInfo);
					scroll:AddChild(equipBtn);
				end
			end
			
			local drogBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "丢弃",
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
				local unequipBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "卸下",
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
		
		local sendBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "展示",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(sendBtn) then
			sendBtn:SetTag(ITEM_OPERATE_EQUIP_SEND);
			sendBtn:SetParam1(nItemId);
			sendBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			scroll:AddChild(sendBtn);
			nHeight	= nHeight + nBtnH + 5 * ScaleFactor;
		end
	elseif nType == Item.TypeConsume and not bEquip then
	--使用
		local nStartX	= nBtn1StartX;
		local useBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "使用",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(useBtn) then
			useBtn:SetTag(ITEM_OPERATE_USE);
			useBtn:SetParam1(nItemId);
			useBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			scroll:AddChild(useBtn);
			nStartX		= nBtn2StartX;
		end
		
		local drogBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "丢弃",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(drogBtn) then
			drogBtn:SetTag(ITEM_OPERATE_DROP);
			drogBtn:SetParam1(nItemId);
			drogBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			scroll:AddChild(drogBtn);
			nHeight	= nHeight + nBtnH + 5 * ScaleFactor;
			nStartX	= nBtn1StartX;
		end
		
		local sendBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "展示",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(sendBtn) then
			sendBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			sendBtn:SetTag(ITEM_OPERATE_EQUIP_SEND);
			sendBtn:SetParam1(nItemId);
			scroll:AddChild(sendBtn);
			nHeight	= nHeight + nBtnH + 5 * ScaleFactor;
		end
	elseif nType == Item.TypeComposeRoll and not bEquip then
		--合成卷
		local nStartX	= nBtn1StartX;
		local openBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "打开",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(openBtn) then
			openBtn:SetTag(ITEM_OPERATE_OPEN);
			openBtn:SetParam1(nItemId);
			openBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			scroll:AddChild(openBtn);
			nStartX		= nBtn2StartX;
		end
		
		local drogBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "丢弃",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(drogBtn) then
			drogBtn:SetTag(ITEM_OPERATE_DROP);
			drogBtn:SetParam1(nItemId);
			drogBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			scroll:AddChild(drogBtn);
			nHeight	= nHeight + nBtnH + 5 * ScaleFactor;
			nStartX	= nBtn1StartX;
		end
		
		local sendBtn = CreateButton("btn/btn_b2_normal.png", "btn/btn_b2_select.png", "展示",
								CGRectMake(nStartX, nHeight, nBtnW, nBtnH), 12);
		if CheckP(sendBtn) then
			sendBtn:SetLuaDelegate(p.OnUIEventItemInfo);
			sendBtn:SetTag(ITEM_OPERATE_EQUIP_SEND);
			sendBtn:SetParam1(nItemId);
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
	local pic		= pool:AddPictureEx(GetSMImgPath("bg/bg_ver_black.png"), nWidthLimit, nHeightLimit, false); 
	if not CheckP(pic) then
		return;
	end
	scrollContainer:SetBackgroundImage(pic);
end

function p.RefreshBackBag()
	local container = p.GetBackBagContainer();
	if not container then
		LogInfo("p.RefreshBackBag p.GetBackBagContainer == nil");
		return;
	end
	
	local nPlayerId		= ConvertN(GetPlayerId());
	local nGridNum		= ConvertN(PlayerFunc.GetBagGridNum(nPlayerId));
	
	local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
	local nSize			= table.getn(idlistItem);
	
	LogInfo("p.RefreshBackBag");
	LogInfo("size[%d]", nSize);
	LogInfoT(idlistItem);
	LogInfo("p.RefreshBackBag");
	
	for i=1, MAX_BACK_BAG_NUM do
		local view = container:GetViewById(i);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag		= p.GetGridTag(j);
				local itemBtn	= _G.GetItemButton(view, nTag);
				if nil ~= itemBtn then
					local nItemId	= 0;
					local nIndex	= (i - 1) * MAX_GRID_NUM_PER_PAGE + j;
					
					if nIndex <= nSize then
						nItemId		= idlistItem[nIndex];
					end
					--LogInfo("index[%d], item[%d]", nIndex, nItemId);
					nItemId			= nItemId or 0;
					if nIndex <= nGridNum then
						itemBtn:ChangeItem(nItemId);
					end
				else
					LogError("p.RefreshBackBag item button tag[%d][%d] error", j, nTag);
				end
			end
		end
	end
end

--设置背包格子数
function p.SetGridNum(nPlayerId)
	if not CheckN(nPlayerId) then
		return;
	end
	local nGridNum	= PlayerFunc.GetBagGridNum(nPlayerId);
	if not CheckN(nGridNum) then
		return;
	end
	
	LogInfo("Player[%d]GridNum[%d]", nPlayerId, nGridNum);
	
	local container = p.GetBackBagContainer();
	if not container then
		LogInfo("p.SetGridNum p.GetBackBagContainer == nil");
		return;
	end
	
	for i=1, MAX_BACK_BAG_NUM do
		local view = container:GetViewById(i);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag		= p.GetGridTag(j);
				local itemBtn	= _G.GetItemButton(view, nTag);
				if nil ~= itemBtn then
					local nIndex	= (i - 1) * MAX_GRID_NUM_PER_PAGE + j;
					itemBtn:SetLock(nIndex > nGridNum);
				else
					LogError("p.SetGridNum item button tag[%d][%d] error", j, nTag);
				end
			end
		end
	end
end
--[[
function p.SetBackBagPage(nCurPage)
	if not CheckN(nCurPage) then
		LogInfo("p.SetBackBagPage invalid arg");
		return;
	end
	
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,p.SetBackBagPage failed!");
		return;
	end
	local idlist = {};
	table.insert(idlist, NMAINSCENECHILDTAG.PlayerBackBag);
	table.insert(idlist, TAG_LAYER_GRID);
	table.insert(idlist, ID_ROLEBAG_R_CTRL_TEXT_PAGE);
	local lb = RecursiveLabel(scene, idlist);
	if not lb then
		LogInfo("lb == nil,p.SetBackBagPage failed!");
		return;
	end
	local text = (nCurPage + 1) .. "/" .. MAX_BACK_BAG_NUM;
	lb:SetText(text);
end
--]]
function p.SetPetLeaveText(btn, nPetId)
	if not CheckP(btn) then
		LogInfo("p.SetPetLeaveText invalid btn");
		return;
	end
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("p.SetPetLeaveText invalid petid");
		return;
	end
	
	if RolePetFunc.IsMainPet(nPetId) then
		btn:SetTitle("伙伴");
	else
		btn:SetTitle("离队");
	end
end

function IsMouseHasSet()
	local scene = GetSMGameScene();	
	--local scene = director:GetRunningScene();
	if scene == nil then
		LogInfo("scene == nil,IsMouseHasSet!");
		return;
	end
	local imgMouse = RecursiveImage(scene, {NMAINSCENECHILDTAG.PlayerBackBag, TAG_MOUSE});
	if not CheckP(imgMouse) then
		return true;
	end
	
	local rect	= imgMouse:GetFrameRect();
	
	if rect.size.w < 1 or rect.size.h < 1 then
		return false;
	end
	
	return true;
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
	local imgMouse = RecursiveImage(scene, {NMAINSCENECHILDTAG.PlayerBackBag, TAG_MOUSE});
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

function p.GetGridTag(i)
	if not CheckT(TAG_BAG_LIST) or 0 == table.getn(TAG_BAG_LIST) then
		return 0;
	end
	
	if i <= table.getn(TAG_BAG_LIST) then
		return TAG_BAG_LIST[i];
	end
	
	return 0;
end

function p.GetIndexByGridTag(nTag)
	if not CheckT(TAG_BAG_LIST) or 0 == table.getn(TAG_BAG_LIST) then
		return 0;
	end
	
	for i, v in ipairs(TAG_BAG_LIST) do
		if v == nTag then
			return i;
		end
	end
	
	return 0;
end

function p.IsGridTag(nTag)
	if not CheckT(TAG_BAG_LIST) or 0 == table.getn(TAG_BAG_LIST) then
		return false;
	end
	
	for i, v in ipairs(TAG_BAG_LIST) do
		if v == nTag then
			return true;
		end
	end
	
	return false;
end

function p.Init()
	p.InitGridTag();
	p.InitEquipTag();
end

function p.InitGridTag()
	if not CheckT(TAG_BAG_LIST) or 0 ~= table.getn(TAG_BAG_LIST) then
		return;
	end 
	
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_1);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_2);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_3);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_4);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_5);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_6);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_7);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_8);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_9);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_10);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_11);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_12);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_13);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_14);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_15);
	table.insert(TAG_BAG_LIST, ID_ROLEBAG_R_LIST_CTRL_OBJECT_BUTTON_16);
end

function p.InitEquipTag()
	if not CheckT(TAG_EQUIP_LIST) or TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] then
		return;
	end 
	
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] = ID_ROLEATTR_L_CTRL_BUTTON_SOUL;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_2] = ID_ROLEATTR_L_CTRL_BUTTON_WEAPON;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_3] = ID_ROLEATTR_L_CTRL_BUTTON_AMULET;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_4] = ID_ROLEATTR_L_CTRL_BUTTON_HELMET;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_5] = ID_ROLEATTR_L_CTRL_BUTTON_DRESS;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_6] = ID_ROLEATTR_L_CTRL_BUTTON_SHOES;
end

function p.IsEquipTag(nTag)
	if not CheckT(TAG_EQUIP_LIST) or not CheckN(nTag) then
		return false;
	end
	
	for k, v in pairs(TAG_EQUIP_LIST) do
		if v == nTag then
			return true;
		end
	end
	
	return false;
end

function p.GetEquipTag(nPos)
	if not CheckT(TAG_EQUIP_LIST) or not CheckN(nPos) then
		return 0;
	end
	return ConvertN(TAG_EQUIP_LIST[nPos]);
end

function p.GameDataPetInfoRefresh(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
		return;
	end
	p.UpdatePetAttrById(nPetId);
end

function p.GameDataPetAttrRefresh(datalist)
	if not CheckT(datalist) then
		return;
	end
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
		return;
	end
	local nPetId	= datalist[1];
	if not CheckN(nPetId) then
		LogError("PlayerUIBackBag.GameDataPetAttrRefresh data invalid!");
		return;
	end
	p.UpdatePetAttrById(nPetId);
	for i=2, #datalist, 2 do
		if datalist[i] and datalist[i] == PET_ATTR.PET_ATTR_POSITION then
			local container = p.GetPetParent();
			if not CheckP(container) then
				return;
			end 
			if RolePet.IsInPlayer(nPetId) then
				--增加伙伴
				local view = createUIScrollView();
				if CheckP(view) then
					view:Init(false);
					view:SetViewId(nPetId);
					container:AddView(view);
				end
				p.ContainerAddPetName(nPetId);
			else
				--伙伴离队
				container:RemoveViewById(nPetId);
				p.ContainerRemovePetName(nPetId);
			end
		end
	end
end

function p.GameDataUserInfoRefresh(datalist)
	if not CheckT(datalist) then
		LogError("p.GameDataUserInfoRefresh invalid arg");
		return;
	end
	
	for i=1, #datalist, 2 do
		if datalist[i] and datalist[i] == USER_ATTR.USER_ATTR_PACKAGE_LIMIT then
			p.SetGridNum(GetPlayerId());
		end
	end
end

GameDataEvent.Register(GAMEDATAEVENT.PETINFO, "PlayerUIBackBag.GameDataPetInfoRefresh", p.GameDataPetInfoRefresh);
GameDataEvent.Register(GAMEDATAEVENT.PETATTR, "PlayerUIBackBag.GameDataPetAttrRefresh", p.GameDataPetAttrRefresh);
GameDataEvent.Register(GAMEDATAEVENT.USERATTR, "PlayerUIBackBag.GameDataUserInfoRefresh", p.GameDataUserInfoRefresh);