---------------------------------------------------
--描述: 玩家背包界面
--时间: 2012.06.09
--作者: chh
---------------------------------------------------

--刷新当前武将装备
--PlayerUIBackBag.RefreshCurrentBack();

PlayerUIBackBag = {}
local p = PlayerUIBackBag;

--背包的位置和页（装备，材料，宝石，道具）
p.BagPos = {TYPE = nil, PAGE = nil, PRE_TYPE = nil,}

--bg tag
local ID_ROLEATTR_L_BG_CTRL_LIST_LEFT					= 51;
local ID_ROLEATTR_L_BG_CTRL_LIST_NAME					= 50;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_115					= 115;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_133					= 133;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_132					= 132;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG					= 200;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG2					= 151;


--属性主界面tag
local ID_ROLEATTR_L_CTRL_TEXT_HELP						= 100;
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
local ID_ROLEATTR_L_CTRL_TEXT_DEX					= 28;
local ID_ROLEATTR_L_CTRL_TEXT_MAGIC					= 29;
local ID_ROLEATTR_L_CTRL_TEXT_SKILL					= 27;
local ID_ROLEATTR_L_CTRL_TEXT_26						= 26;
local ID_ROLEATTR_L_CTRL_TEXT_25						= 25;
local ID_ROLEATTR_L_CTRL_TEXT_ABILITY					= 24;
local ID_ROLEATTR_L_CTRL_TEXT_23						= 23;
local ID_ROLEATTR_L_CTRL_TEXT_LIFE					= 22;
local ID_ROLEATTR_L_CTRL_TEXT_21						= 21;
local ID_ROLEATTR_L_CTRL_TEXT_FORCE					= 20;
local ID_ROLEATTR_L_CTRL_TEXT_19						= 19;
local ID_ROLEATTR_L_CTRL_TEXT_JOB						= 16;
--local ID_ROLEATTR_L_CTRL_TEXT_16						= 16;
local ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG				= 9;
local ID_ROLEATTR_L_CTRL_BUTTON_BAG					= 97;
local ID_ROLEATTR_L_CTRL_BUTTON_FIRE					= 98;
local ID_ROLEATTR_L_CTRL_TEXT_LEVEL						= 235;


local ID_ROLEATTR_R_CTRL_TEXT_SPEED						= 27;

local ID_BAG_CAPACITY                                   = 35;

-- 右边界面tag
local ID_ROLEBAG_R_CTRL_LIST_PAGE					= 65;

local ID_ROLEBAG_R_CTRL_HORIZON_LIST_M				= 680;
local ID_ROLEBAG_R_CTRL_BUTTON_CLOSE				= 225;

local ID_ROLEBAG_R_CTRL_PICTURE_BG					= 226;

local ID_ROLEBAG_R_CTRL_BUTTON_EQUIP				= 113;
local ID_ROLEBAG_R_CTRL_BUTTON_MATE					= 48;
local ID_ROLEBAG_R_CTRL_BUTTON_GEM                  = 50;
local ID_ROLEBAG_R_CTRL_BUTTON_PROP                 = 9;


p.TAG_BAG_BTNS = {};


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
local MAX_BACK_BAG_NUM				= 4;
local MAX_GRID_NUM_PER_PAGE			= 16;

local NUMBER_FILE = "/number/num_1.png";
local N_W = 42;
local N_H = 34;
local Numbers_Rect = {
    CGRectMake(N_W*0,0.0,N_W,N_H),
    CGRectMake(N_W*1,0.0,N_W,N_H),
    CGRectMake(N_W*2,0.0,N_W,N_H),
    CGRectMake(N_W*3,0.0,N_W,N_H),
    CGRectMake(N_W*4,0.0,N_W,N_H),
    CGRectMake(N_W*5,0.0,N_W,N_H),
    CGRectMake(N_W*6,0.0,N_W,N_H),
    CGRectMake(N_W*7,0.0,N_W,N_H),
    CGRectMake(N_W*8,0.0,N_W,N_H),
    CGRectMake(N_W*9,0.0,N_W,N_H),
};
local TAG_NUMBER_IMG = 156;



local TAG_BEGIN_ARROW   = 1411;
local TAG_END_ARROW     = 1412;

local TAG_BEGIN_ARROW2   = 10;
local TAG_END_ARROW2     = 9;

-- 界面控件tag定义
--local TAG_CONTAINER = 2;						--容器tag
local TAG_LAYER_GRID = 12345;					--属性格子层tag

local TAG_MOUSE	= 9999;							--鼠标图片tag
local TAG_BAG_LIST = {};						--背包tag列表
p.TAG_EQUIP_LIST = {};						--装备tag列表
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

local CONTAINTER_W = RectFullScreenUILayer.size.w / 2;
local CONTAINTER_H = RectFullScreenUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectFullScreenUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

--开通格子
local INIT_GRID_NUM		= 16;
local l_nOpenGridDlgId	= 0;
local l_nCurOpenGridNum = 0;

--往背包增加一个物品
function p.AddItem(idItem)
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
            
                local nItemType		= Item.GetItemInfoN(v, Item.ITEM_TYPE);
                local nType			= ItemFunc.GetBigType(nItemType);
                if (nType == p.BagPos.TYPE) then
                    itemButton:ChangeItem(idItem);
                    itemButton:SetFocus(true);
                end
                
				break;
			end
		end 
	end
    p.SetBagCapacity();
    
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
                itemButton:SetFocus(false);
			end
		end 
	end
    p.SetBagCapacity();
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

function p.LoadUI(tab,nPetId)
	p.Init();
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load PlayerBackBag failed!");
		return;
	end
	
    if(tab) then
        p.BagPos.TYPE = tab;
    end
    
    --==Begin(初始化左边背景)=================================================================
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerBackBag);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("RoleAttr_L_BG.ini", layer, nil, 0, 0);
    --==End(初始化左边背景)===================================================================
    
    
    SetArrow(p.GetLayer(),p.GetPetNameSVC(),1,TAG_BEGIN_ARROW2,TAG_END_ARROW2);
    
    
    
    
    --==(Begin)初始化右边背景=================================================================
	local layerGrid = createNDUILayer();
	if not CheckP(layerGrid) then
		layer:Free();
		return false;
	end
	layerGrid:Init();
	layerGrid:SetTag(TAG_LAYER_GRID);
	layerGrid:SetFrameRect(CGRectMake(ATTR_OFFSET_X, ATTR_OFFSET_Y, RectFullScreenUILayer.size.w / 2, RectFullScreenUILayer.size.h));
	layer:AddChild(layerGrid);
	
	uiLoad:Load("RoleBag_R.ini", layerGrid, p.OnUIEventRightPanel, 0, 0);
	
	uiLoad:Free();
    --==(End)初始化左边背景===================================================================
	
    
    
    
    
    
    ----==(Begin)初始化左边人物列表栏和人物装备栏======================================================
	----[[
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
		local viewsize	= CGSizeMake(size.w, size.h)
		petNameContainer:SetLeftReserveDistance(size.w / 2 + viewsize.w / 2);
		petNameContainer:SetRightReserveDistance(size.w / 2 - viewsize.w / 2);
		petNameContainer:SetViewSize(viewsize);
		petNameContainer:SetLuaDelegate(p.OnUIEventViewChange);
	end--]]
	

	--local leftview = PlayerUIAttr.InitLeftView(layer,p.OnUIEventViewChange);
	
	LogInfo("chh: uibag out");
	--==(End)初始化左边人物列表栏和人物装备栏======================================================
    
    
    
    
    
    
    
    --==初始化武将装备信息======================
	p.RefreshContainer();
    
    --==刷新升阶状态======================
    p.RefreshUpgradeStatu();
    
    --==初始化武将属性信息======================
	p.UpdatePetAttr();--
    
    
	
    
    
    --==填充背包物品=======
	p.RefreshBackBag();
    
    
    --==设置当前显示背包的页=======
	p.SetFocusOnPage(0);
	
    
    --==设置物品框的开放=======
	p.SetGridNum(GetPlayerId());
	
    
    
	if CheckP(petNameContainer) then
		petNameContainer:ShowViewByIndex(0);
	end
	
	--鼠标图片初始化
	local imgMouse	= createNDUIImage();
	imgMouse:Init();
	imgMouse:SetTag(TAG_MOUSE);
	layer:AddChildZ(imgMouse, 2);
	
    
    --三级窗口初始化
    BackLevelThreeWin.LoadUI(layer);
    
    
    --设置关闭音效
   	local closeBtn=GetButton(layerGrid,ID_ROLEBAG_R_CTRL_BUTTON_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	
    if(nPetId) then
        p.ShowPetInfo(nPetId);
    end
    
    p.refreshMoney();
	return true;
end


--物品更新事件
function p.GoodUpdateEvent(data)
    LogInfo("p.GoodUpdateEvent");
    if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
        return;
    end
    
    local idItem = data[3];
    local container = p.GetBackBagContainer();
	if not container then
		LogInfo("p.GoodUpdateEvent p.GetBackBagContainer == nil");
		return;
	end
    
    for i=1, MAX_BACK_BAG_NUM do
		local view = container:GetViewById(i);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag		= p.GetGridTag(j);
				local itemBtn	= _G.GetItemButton(view, nTag);
				if(itemBtn:GetItemId() == idItem) then
                    itemBtn:ChangeItem(idItem);
                    break;
                end
			end
		end
	end
    
    PlayerUIBackBag.RefreshCurrentBack();
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
    container:RemoveAllView();
    
	local rectview = container:GetFrameRect();
	if nil == rectview then
		LogInfo("p.LoadBackBagUI nil == rectview");
		return;
	end
	
	container:SetViewSize(rectview.size);
    container:ShowViewByIndex(0);
	
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
    
    LogInfo("container:[%d]",container:GetViewCount());
    
    SetArrow(p.GetGridLayer(),p.GetPageViewContainer(),1,TAG_BEGIN_ARROW,TAG_END_ARROW);
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
        LogInfo("param:[%d]",param);
		local containter	= ConverToSVC(uiNode);
		local nPetId		= 0;
		if CheckP(containter) and CheckN(param) then
			local beginView	= containter:GetView(param);
			if CheckP(beginView) then
				nPetId	= beginView:GetViewId()
				-- ???
				--if (RoleTrainUI.isInShow()) then
					--RoleTrainUI.LoadUI(beginView:GetViewId());
				--end
			end
		end
		
		if not nPetId or nPetId <= 0 then
			return;
		end
	
		if ID_ROLEATTR_L_BG_CTRL_LIST_LEFT == tag then
			containter	= p.GetPetNameSVC();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
            
            LogInfo("p.OnUIEventViewChange p.BagPos.PAGE:[%d]",p.BagPos.PAGE);
            
		elseif ID_ROLEATTR_L_BG_CTRL_LIST_NAME == tag then
			LogInfo("ID_ROLEATTR_L_BG_CTRL_LIST_NAME == tag");
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
            SetArrow(p.GetLayer(),p.GetPetNameSVC(),1,TAG_BEGIN_ARROW2,TAG_END_ARROW2);
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
				containter:ShowViewById(nPetId);
			end
			
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
		end
	end
	
	return true;
end

function p.OnUIEventRightPanel(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventRightPanel[%d] event[%d],inbegin[%d]", tag, uiEventType,NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_ROLEBAG_R_CTRL_BUTTON_CLOSE then
            p.freeData();
            CloseUI(NMAINSCENECHILDTAG.PlayerBackBag);
            
        elseif(tag == ID_ROLEBAG_R_CTRL_BUTTON_EQUIP) then
            if(Item.bTypeEquip ~= p.BagPos.TYPE) then
                p.ChangeBagByType(Item.bTypeEquip);
            end
        elseif(tag == ID_ROLEBAG_R_CTRL_BUTTON_MATE) then
            if(Item.bTypeMate ~= p.BagPos.TYPE) then
                p.ChangeBagByType(Item.bTypeMate);
            end
        elseif(tag == ID_ROLEBAG_R_CTRL_BUTTON_GEM) then
            if(Item.bTypeGem ~= p.BagPos.TYPE) then
                p.ChangeBagByType(Item.bTypeGem);
            end
        elseif(tag == ID_ROLEBAG_R_CTRL_BUTTON_PROP) then
            if(Item.bTypeProp ~= p.BagPos.TYPE) then
                p.ChangeBagByType(Item.bTypeProp);
            end
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if tag == ID_ROLEBAG_R_CTRL_HORIZON_LIST_M then
            local pageView =  p.GetBackBagContainer();
            local viewId = pageView:GetBeginIndex();
            p.SetFocusOnPage(viewId);
            SetArrow(p.GetGridLayer(),p.GetPageViewContainer(),1,TAG_BEGIN_ARROW,TAG_END_ARROW);
            
            p.BagPos.PAGE = param;
		end 
    
	end
	return true;
end

local flag = true;
function p.ChangeBagByType(ntype)
    p.BagPos.PRE_TYPE = p.BagPos.TYPE;
    p.BagPos.TYPE = ntype;
    p.BagPos.PAGE = 0;
    p.RefreshBackBag();
    
    LogInfo("p.ChangeBagByType p.BagPos.PAGE:[%d]",p.BagPos.PAGE);
end

function p.OnUIEvenPet(uiNode, uiEventType, param) 
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvenPet[%d],uiEventType:[%d]", tag,uiEventType);
	
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
          
            
        elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG then
            local nPetId = p.GetCurPetId();
            LogInfo("nPetId ss:[%d]",nPetId);
            CloseMainUI();
            PlayerUIAttr.LoadUI(nPetId);
            return true;
		end

		
		local equipBtn = ConverToEquipBtn(uiNode);
		if not CheckP(equipBtn) then
			LogInfo("点击装备 not CheckP(itemBtn) ");
			return true;
		end
		LogInfo("equip p.ChangeItemInfo[%d]", equipBtn:GetItemId());
		p.ChangeItemInfo(equipBtn:GetItemId(),true, false);
    
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE_CLICK then
        
        local equipBtn = ConverToItemButton(uiNode);
        LogInfo("equip p.ChangeItemInfo[%d]", equipBtn:GetItemId());
        if(p.BagPos.TYPE == Item.bTypeEquip or bEquip) then
            local nItemId = equipBtn:GetItemId();
            
            if(nItemId == 0) then
                return;
            end
            
            local nPetId = p.GetCurPetId();
            local isEquip = true;
            BackLevelThreeWin.EquipOperate(nItemId, nPetId, isEquip);
        end
    
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
            LogInfo("equip p.ChangeItemInfo[%d]", itemBtn:GetItemId());
            if(p.BagPos.TYPE == Item.bTypeEquip) then
                local nItemId = itemBtn:GetItemId();
                
                local nPetId = p.GetCurPetId();
                local isEquip = false;
                BackLevelThreeWin.EquipOperate(nItemId, nPetId, isEquip);
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
        p.ChangeItemInfo(itemBtn:GetItemId(), false);
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE_CLICK then
        
        local equipBtn = ConverToItemButton(uiNode);
        LogInfo("equip p.ChangeItemInfo[%d]", equipBtn:GetItemId());
        if(p.BagPos.TYPE == Item.bTypeEquip or bEquip) then
            local nItemId = equipBtn:GetItemId();
            if(nItemId == 0) then
                return;
            end
            local nPetId = p.GetCurPetId();
            local isEquip = false;
            BackLevelThreeWin.EquipOperate(nItemId, nPetId, isEquip);
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
			if nItemId > 0 and Item.IsExistItem(nItemId) then
                
                LogInfo("equip p.ChangeItemInfo[%d]", nItemId);
                if(p.BagPos.TYPE == Item.bTypeEquip) then
                    local nItemId = nItemId;
                    local nPetId = p.GetCurPetId();
                    local isEquip = true;
                    BackLevelThreeWin.EquipOperate(nItemId, nPetId, isEquip);
                end
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
			return true;
		end
		LogInfo("p.OnUIEventItemInfo[%d]", nItemId);
		if tag == ITEM_OPERATE_EQUIP then
		--穿装备
			local nPetId	= p.GetCurPetId();
			if not RolePet.IsExistPet(nPetId) then
				LogInfo("穿装备 p.OnUIEventItemInfo not RolePet.IsExistPet[%d]", nPetId);
				return true;
			end
			MsgItem.SendPackEquip(nItemId, nPetId);
			ShowLoadBar();
		elseif tag == ITEM_OPERATE_UNEQUIP then
		--脱装备
			local nPetId = uiNode:GetParam2();
			if not RolePet.IsExistPet(nPetId) then
				LogInfo("脱装 p.OnUIEventItemInfo not RolePet.IsExistPet[%d]", nPetId);
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

--[[
function p.OnUIEventClickPage(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventItemInfo[%d] event[%d]", tag, uiEventType);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag >=1 and tag <= MAX_BACK_BAG_NUM then
			local container		= p.GetBackBagContainer();
			if CheckP(container) then
				container:ShowViewById(tag);
			end 
		end
	end
	
	return true;
end
]]


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

    local container = p.GetPageViewContainer();
    if(container == nil) then
        LogInfo("container is nil!");
    end
    container:RemoveAllView();
	
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);

    for i=1, MAX_BACK_BAG_NUM do
        local view = createUIScrollView();
		if view == nil then
			LogInfo("p.LoadUI createUIScrollView failed");
			return;
		end
		view:Init(false);
		view:SetViewId(i);
		container:AddView(view);
        
        --初始化ui
        local uiLoad = createNDUILoad();
        if nil == uiLoad then
            layer:Free();
            return false;
        end
	
        uiLoad:Load("Number_Item.ini", view, nil, 0, 0);
        p.refreshNumberListItem(view,i);
        
        view:SetTouchEnabled(false);
    end

end

function p.refreshNumberListItem(view,i)
    local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
    local norpic = pool:AddPicture(GetSMImgPath(NUMBER_FILE), false);
    norpic:Cut(Numbers_Rect[i+1]);
    local img = GetImage(view, TAG_NUMBER_IMG);
    img:SetPicture(norpic);
end

function p.GetGridLayer()
    local scene = GetSMGameScene();	
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load p.LoadPageView failed!");
		return;
	end
    
    local layer	= RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerBackBag, TAG_LAYER_GRID});
    return layer;
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



function p.SetFocusOnPage(nPage)
	if not CheckN(nPage) or 
		nPage < 0 or 
		nPage > MAX_BACK_BAG_NUM then
		return;
	end
	
    local container	= p.GetPageViewContainer();
	if not CheckP(container) then
        LogInfo("container is nil!");
		return;
	end
    container:ShowViewByIndex(nPage);
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
	local btn	= _G.CreateButton("", "", strPetName, CGRectMake(0, 0, size.w, size.h), 15);
    
    local cColor = ItemPet.GetPetQuality(nPetId);
    btn:SetFontColor(cColor);
    
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
	
	local nTag	= p.TAG_EQUIP_LIST[nPostion];
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
    idTable = RolePet.OrderPets(idTable);
	
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
		
        LogInfo("petId:v[%d]",v);
        
		p.RefreshPetEquip(v);
		
	end
end

--刷新当前背包
function p.RefreshCurrentBack()
    LogInfo("p.RefreshCurrentBack");
    local layer = p.GetLayer();
    if(layer == nil) then
        return;
    end

    local nPetId = p.GetCurPetId();
    p.RefreshPetEquip(nPetId);
    p.RefreshBackBag();
    p.RefreshUpgradeStatu();
    p.SetBagCapacity();
end

function p.ShowPetInfo(nPetId)
    LogInfo("p.ShowPetInfo");
    local container = p.GetPetParent();
    if(container == nil) then
        LogInfo("p.RefreshPetEquip container is nil");
        return;
    end
    if(nPetId == nil) then
        LogInfo("p.RefreshPetEquip nPetId is nil");
        return;
    end
    LogInfo("nPetId_ff:[%d]",nPetId);
    container:ShowViewById(nPetId);
end

--刷新武将装备
function p.RefreshPetEquip(nPetId)
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    local container = p.GetPetParent();
    if(container == nil) then
        LogInfo("p.RefreshPetEquip container is nil");
        return;
    end
    local view = container:GetViewById(nPetId);
    if(view == nil) then
        LogInfo("p.RefreshPetEquip view is nil");
        return;
    end
    
    --装备
    local idlist	= ItemPet.GetEquipItemList(nPlayerId, nPetId);
    for i, v in ipairs(idlist) do
        local nPos	= Item.GetItemInfoN(v, Item.ITEM_POSITION);
        local nTag	= p.GetEquipTag(nPos);
        LogInfo("nPos:[%d],nTag[%d]",nPos,nTag);
        if nTag > 0 then
            local equipBtn	= GetEquipButton(view, nTag);
            if CheckP(equipBtn) then
                equipBtn:ChangeItem(v);
                
                --[[
                if(_G.ItemFunc.IfItemCanUpStep(v, nPetId)) then
                    
                    local nItemtype = Item.GetItemInfoN(v, Item.ITEM_TYPE);
                    if(PlayerEquipUpStepUI.IfUpStepMatrialEnough(nItemtype)) then
                        equipBtn:SetUpgrade(1);
                    else
                        equipBtn:SetUpgrade(2);
                    end
                    
                    if(i<=#idlist/2) then
                        equipBtn:SetUpgradeIconPos(1);
                    end
                else
                    equipBtn:SetUpgrade(0);
                end
                ]]
            end
        end
    end

end

--** 刷新升阶状态 **--
function p.RefreshUpgradeStatu()
    LogInfo("p.RefreshUpgradeStatu");
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    local container = p.GetPetParent();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
    local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    for i,nPetId in ipairs(idTable) do
        local view = container:GetViewById(nPetId);
        local idlist	= ItemPet.GetEquipItemList(nPlayerId, nPetId);
        
        for j,nItemId in ipairs(idlist) do
            local nPos	= Item.GetItemInfoN(nItemId, Item.ITEM_POSITION);
            local nTag	= p.GetEquipTag(nPos);
            local equipBtn	= GetEquipButton(view, nTag);
            if nTag > 0 then
                if CheckP(equipBtn) then
                    local bIsEquip = ItemFunc.IsAlertEquipItem(nItemId);
                    if(bIsEquip and _G.ItemFunc.IfItemCanUpStep(nItemId, nPetId)) then
                        local nItemtype = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
                        if(PlayerEquipUpStepUI.IfUpStepMatrialEnough(nItemtype)) then
                            equipBtn:SetUpgrade(1);
                        else
                            equipBtn:SetUpgrade(2);
                        end
                        if(nPos%10<=3) then
                            equipBtn:SetUpgradeIconPos(1);
                        end
                    else
                        equipBtn:SetUpgrade(0);
                    end
                    
                end
            end
        end
        local t = {};
        --清空无装备的状态
        table.insert(t,Item.POSITION_EQUIP_1);
        table.insert(t,Item.POSITION_EQUIP_2);
        table.insert(t,Item.POSITION_EQUIP_3);
        table.insert(t,Item.POSITION_EQUIP_4);
        table.insert(t,Item.POSITION_EQUIP_5);
        table.insert(t,Item.POSITION_EQUIP_6);
        
        for i,v in ipairs(t) do
            local nTag	= p.GetEquipTag(v);
            local equipBtn	= GetEquipButton(view, nTag);
            if(equipBtn:GetItemId()==0) then
                equipBtn:SetUpgrade(0);
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
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_LIFE then
	--生命
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_LIFE;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SUPER_SKILL then
	--绝技
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_ABILITY;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SKILL then
	--技能
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_SKILL;

	elseif nPetDataIndex == PET_ATTR.PET_ATTR_NAME then
	--名字
		--todo
		--nTag	= ID_ROLEATTR_L_CTRL_TEXT_PLAYER_NAME;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SPEED	then
	--速度
		nTag	= ID_ROLEATTR_R_CTRL_TEXT_SPEED;
        
    --[[    
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHYSICAL then
	--力量
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        
   	elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC then
	--智力
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_MAGIC;     
        
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_DEX	then
    --敏捷	
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_DEX;]]      
        
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHY_ATK then
	--物理攻击
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        SetLabel(petView, ID_ROLEATTR_L_CTRL_TEXT_19, "物理攻击");
        
   elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC_ATK then
	--策略攻击
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        SetLabel(petView, ID_ROLEATTR_L_CTRL_TEXT_19, "策略攻击"); 
    
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHY_DEF	then
    --物理防御
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_DEX;      
        
   	elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC_DEF then
	--策略防御
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_MAGIC;               
          
        
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_LEVEL	then
	--等级
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_LEVEL;	
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
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_NAME, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	--职业
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_TYPE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));
	--生命
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LIFE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE));
	--绝技
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SUPER_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));
	
	--速度
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SPEED, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SPEED));
	
    --获取职业类型 主要有  猛将: 1   射手: 2  军师: 3
    local nPetType = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
    local nActType = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.ATK_TYPE);
    if ( nActType == 3) then
           --策略攻击
        p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC_ATK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK)); 
    else
        --物理攻击
        p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHY_ATK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_ATK));
    end
    
    --物理防御
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHY_DEF, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_DEF));  
    
    --策略防御
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC_DEF, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF));
    
   --[[ 
    --力量
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHYSICAL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL));
    
    --法术
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC));
    
	--敏捷
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_DEX, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DEX));
	]]    
    
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LEVEL, "等级:"..RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	
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
    idTable = RolePet.OrderPets(idTable);
    
    
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

function p.ChangeItemInfo(nItemId, bEquip, bIsDouble)
    
    if not CheckN(nItemId) or 
		not CheckB(bEquip) then
		LogInfo("p.ChangeItemInfo invalid arg");
		return;
	end
    
    if(not CheckB(bIsDouble)) then
        bIsDouble = false;
    end
    
    local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,p.ChangeItemInfo!");
		return;
	end
    
    
    --判断是否弹出框
    if(nItemId == 0) then
        return true;
    end
	
    if(p.BagPos.TYPE == Item.bTypeEquip or bEquip) then
    
        if(bIsDouble) then
            BackLevelThreeWin.EquipOperate(nItemId, p.GetCurPetId(), bEquip);
        else
            BackLevelThreeWin.ShowUIEquip(nItemId, p.GetCurPetId(), bEquip);
        end
        
    elseif(p.BagPos.TYPE == Item.bTypeMate) then
        BackLevelThreeWin.ShowUIMate(nItemId);
    elseif(p.BagPos.TYPE == Item.bTypeGem) then
        BackLevelThreeWin.ShowUIGem(nItemId);
    elseif(p.BagPos.TYPE == Item.bTypeProp) then
        BackLevelThreeWin.ShowUIProp(nItemId, p.GetCurPetId());
    end
end

function p.RefreshBackBag()
    LogInfo("p.RefreshBackBag");
	local container = p.GetBackBagContainer();
	if not container then
		LogInfo("p.RefreshBackBag p.GetBackBagContainer == nil");
		return;
	end
	
    
    local scene = GetSMGameScene();	
    local rlayer	= RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerBackBag, TAG_LAYER_GRID});
    for i,v in pairs(p.TAG_BAG_BTNS) do
        LogInfo("btn tag:[%d]",v);
        local btn = GetButton(rlayer, v);
        --btn:EnalbeGray(false);
        btn:TabSel(false);
        btn:SetChecked(false);
        if(p.BagPos.TYPE ~= nil and i == p.BagPos.TYPE) then
            --btn:EnalbeGray(true);
            btn:TabSel(true);
            btn:SetChecked(true);
        end
    end
    
	local nPlayerId		= ConvertN(GetPlayerId());
	local nGridNum		= ConvertN(PlayerFunc.GetBagGridNum(nPlayerId));
	
	local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
	local nSize			= table.getn(idlistItem);
	
    
    local idTypeListItem = {};
    for i, v in ipairs(idlistItem) do
        
        local nItemType		= Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nType			= ItemFunc.GetBigType(nItemType);
        
        LogInfo("nType:[%d],p.BagPos.TYPE:[%d]",nType,p.BagPos.TYPE);
        
        if (nType == p.BagPos.TYPE) then
            table.insert(idTypeListItem,v);
        end
    end
    
    LogInfo("idTypeListItem:#[%d]",#idTypeListItem);
    
    idTypeListItem = Item.OrderItems(idTypeListItem);
    
    local tSize			= table.getn(idTypeListItem);
    
    MAX_BACK_BAG_NUM = tSize / MAX_GRID_NUM_PER_PAGE;
    if(tSize == 0) then
        MAX_BACK_BAG_NUM = 1;
    elseif(tSize % MAX_GRID_NUM_PER_PAGE ~= 0) then
        MAX_BACK_BAG_NUM = MAX_BACK_BAG_NUM + 1;
    end
    
    
    --刷新表格
    --==初始化分页栏======================
	p.LoadPageView();
    
    --==初始化背包UI最大为4页，每页16格物品框=======
	p.LoadBackBagUI();
    
    for i=1, MAX_BACK_BAG_NUM do
		local view = container:GetViewById(i);
		if nil ~= view then
			for j=1, MAX_GRID_NUM_PER_PAGE do
				local nTag		= p.GetGridTag(j);
				local itemBtn	= _G.GetItemButton(view, nTag);
				if nil ~= itemBtn then
					local nItemId	= 0;
					local nIndex	= (i - 1) * MAX_GRID_NUM_PER_PAGE + j;
					if nIndex <= tSize then
						nItemId		= idTypeListItem[nIndex];
					end
					nItemId			= nItemId or 0;
                    LogInfo("nItemId:[%d]",nItemId);
                    if nIndex <= nGridNum then
                        itemBtn:ChangeItem(nItemId);
                        
                        if(nItemId == 0) then
                            itemBtn:SetFocus(false);
                        else
                            itemBtn:SetFocus(true);
                        end
                        
                    else
                        itemBtn:ChangeItem(0);
                        itemBtn:SetFocus(false);
                    end
                    
				else
					LogError("p.RefreshBackBag item button tag[%d][%d] error", j, nTag);
				end
			end
		end
	end
    
    LogInfo("p.BagPos.TYPE:[%d],p.BagPos.PRE_TYPE:[%d],p.BagPos.PAGE:[%d]",p.BagPos.TYPE,p.BagPos.PRE_TYPE,p.BagPos.PAGE);
    
    if (p.BagPos.TYPE ~= p.BagPos.PRE_TYPE) then
        container:ShowViewByIndex(p.BagPos.PAGE);
    end
    
    p.SetBagCapacity();
end

--显示背包容量
function p.SetBagCapacity()
    LogInfo("PlayerUIBackBag.SetBagCapacity");
    if not IsUIShow(NMAINSCENECHILDTAG.PlayerBackBag) then
        return;
    end

    local scene     = GetSMGameScene();	
    local rlayer	= RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerBackBag,TAG_LAYER_GRID});
    
    local nPlayerId		= ConvertN(GetPlayerId());
	local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
    
    --容量
    local txt = string.format("%d/%d",#idlistItem,ItemFunc.getBackBagCapability());
    SetLabel(rlayer,ID_BAG_CAPACITY,txt);
    LogInfo("txt:%s",txt);
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
		local nMoveX	= moveTouch.x - size.w / 2 - RectFullScreenUILayer.origin.x;
		local nMoveY	= moveTouch.y - size.h / 2 - RectFullScreenUILayer.origin.y;
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
    p.BagPos = {TYPE = nil, PAGE = nil, PRE_TYPE = nil,};
	p.InitGridTag();
	p.InitEquipTag();
    p.InitData();
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
	if not CheckT(p.TAG_EQUIP_LIST) or p.TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] then
		return;
	end 
	
	p.TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] = ID_ROLEATTR_L_CTRL_BUTTON_SOUL;
	p.TAG_EQUIP_LIST[Item.POSITION_EQUIP_2] = ID_ROLEATTR_L_CTRL_BUTTON_WEAPON;
	p.TAG_EQUIP_LIST[Item.POSITION_EQUIP_3] = ID_ROLEATTR_L_CTRL_BUTTON_AMULET;
	p.TAG_EQUIP_LIST[Item.POSITION_EQUIP_4] = ID_ROLEATTR_L_CTRL_BUTTON_HELMET;
	p.TAG_EQUIP_LIST[Item.POSITION_EQUIP_5] = ID_ROLEATTR_L_CTRL_BUTTON_DRESS;
	p.TAG_EQUIP_LIST[Item.POSITION_EQUIP_6] = ID_ROLEATTR_L_CTRL_BUTTON_SHOES;
end

function p.InitData()
    if(p.BagPos.TYPE == nil) then
        p.BagPos.TYPE = Item.bTypeEquip;
        p.BagPos.PRE_TYPE = Item.bTypeEquip;
    end
    if(p.BagPos.PAGE == nil) then
        p.BagPos.PAGE = 0;
        LogInfo("p.InitData p.BagPos.PAGE:[%d]",p.BagPos.PAGE);
    end
    
    p.TAG_BAG_BTNS = {
        [Item.bTypeEquip]=ID_ROLEBAG_R_CTRL_BUTTON_EQUIP,
        [Item.bTypeGem]=ID_ROLEBAG_R_CTRL_BUTTON_GEM,
        [Item.bTypeMate]=ID_ROLEBAG_R_CTRL_BUTTON_MATE,
        [Item.bTypeProp]=ID_ROLEBAG_R_CTRL_BUTTON_PROP,
    };
    
    MsgCompose.mUIListener = p.processNet;
end

function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	if msgId == NMSG_Type._MSG_START_FORMULA_DATA then
		p.RefreshBackBag();
	end
	CloseLoadBar();
end

function p.freeData()
    MsgCompose.mUIListener    = nil;
    p.TAG_BAG_BTNS = nil;
    BackLevelThreeWin.DestoryLayer();
end

function p.IsEquipTag(nTag)
	if not CheckT(p.TAG_EQUIP_LIST) or not CheckN(nTag) then
		return false;
	end
	
	for k, v in pairs(p.TAG_EQUIP_LIST) do
		if v == nTag then
			return true;
		end
	end
	
	return false;
end

function p.GetEquipTag(nPos)
	if not CheckT(p.TAG_EQUIP_LIST) or not CheckN(nPos) then
		return 0;
	end
	return ConvertN(p.TAG_EQUIP_LIST[nPos]);
end

function p.GetLayer()
    local scene     = GetSMGameScene();	
    if(scene == nil) then
        LogInfo("p.GetLayer scene is nil!");
        return;
    end
    
    local layer	= RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerBackBag});
    if(layer == nil) then
        LogInfo("p.GetLayer layer is nil!");
        return;
    end
    
    return layer;
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
    
    p.refreshMoney();
end



local TAG_E_TMONEY      = 243;  --
local TAG_E_TEMONEY     = 242;  --
--刷新金钱
function p.refreshMoney()
    LogInfo("p.refreshMoney BEGIN");
    local nPlayerId     = GetPlayerId();
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerBackBag);
    if(layer == nil) then
        return;
    end
    
    local nmoney        = MoneyFormat(GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY));
    local ngmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY).."";
    
    _G.SetLabel(layer, TAG_E_TMONEY, nmoney);
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
end

GameDataEvent.Register(GAMEDATAEVENT.ITEMATTR,"p.GoodUpdateEvent",p.GoodUpdateEvent);

GameDataEvent.Register(GAMEDATAEVENT.USERATTR, "PlayerUIBackBag.GameDataUserInfoRefresh", p.GameDataUserInfoRefresh);
GameDataEvent.Register(GAMEDATAEVENT.PETINFO, "PlayerUIBackBag.GameDataPetInfoRefresh", p.GameDataPetInfoRefresh);
GameDataEvent.Register(GAMEDATAEVENT.PETATTR, "PlayerUIBackBag.GameDataPetAttrRefresh", p.GameDataPetAttrRefresh);

GameDataEvent.Register(GAMEDATAEVENT.ITEMINFO,"PlayerUIBackBag.RefreshCurrentBack",p.RefreshCurrentBack);


