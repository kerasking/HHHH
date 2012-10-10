---------------------------------------------------
--描述: 玩家物品合成界面
--时间: 2012.3.22
--作者: xxj
---------------------------------------------------

PlayerUICompose = {}
local p = PlayerUICompose;

--bg tag
local ID_ROLEATTR_L_BG_CTRL_LIST_LEFT					= 51;
local ID_ROLEATTR_L_BG_CTRL_LIST_NAME					= 50;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_115					= 115;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_133					= 133;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_132					= 132;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG					= 200;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG2					= 151;

-- 左边属性界面tag
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

--右边合成界面tag
local ID_WEAPONMIX_CTRL_TEXT_STUFF_NUM				= 32;
local ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF			= 27;
local ID_WEAPONMIX_CTRL_TEXT_NUM_6					= 56;
local ID_WEAPONMIX_CTRL_TEXT_NUM_5					= 55;
local ID_WEAPONMIX_CTRL_TEXT_NUM_4					= 54;
local ID_WEAPONMIX_CTRL_TEXT_NUM_3					= 53;
local ID_WEAPONMIX_CTRL_TEXT_NUM_2					= 52;
local ID_WEAPONMIX_CTRL_TEXT_NUM_1					= 51;
local ID_WEAPONMIX_CTRL_TEXT_INFO					= 50;
local ID_WEAPONMIX_CTRL_BUTTON_COMPOUND				= 337;
local ID_WEAPONMIX_CTRL_TEXT_1177					= 1177;
local ID_WEAPONMIX_CTRL_BUTTON_CLOSE				= 1167;
local ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_1		= 21;
local ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_2		= 23;
local ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_3		= 25;
local ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_4		= 22;
local ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_5		= 24;
local ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_6		= 26;
local ID_WEAPONMIX_CTRL_PICTURE_BG					= 1164;

-- 界面控件tag定义
local TAG_CONTAINER = 2;						--容器tag
local TAG_EQUIP_LIST = {};						--装备tag列表
local TAG_MATERIAL_IMG_LIST = {};				--合成材料图标tag列表
local TAG_MATERIAL_TEXT_LIST = {};				--合成材料完成度文本tag列表
local TAG_LAYER_COMPOSE = 12345;				--属性界面层tag


-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;

--合成id
local formulaID=0;

function p.LoadUI(itemID)
    LogInfo("PlayerUICompose.LoadUI(%d)", itemID);
	p.Init();
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load PlayerBackBag failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerUICompose);
	layer:SetFrameRect(RectUILayer);
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
	uiLoad:Load("RoleAttr_L_BG.ini", layer, nil, 0, 0);
	
	local layerCompose = createNDUILayer();
	if not CheckP(layerCompose) then
		layer:Free();
		return false;
	end
	layerCompose:Init();
	layerCompose:SetTag(TAG_LAYER_COMPOSE);
	layerCompose:SetFrameRect(CGRectMake(ATTR_OFFSET_X, ATTR_OFFSET_Y, RectUILayer.size.w / 2, RectUILayer.size.h));
	layer:AddChild(layerCompose);
	
	uiLoad:Load("WeaponMix.ini", layerCompose, p.OnUIEventRightPanel, 0, 0);
	uiLoad:Free();
	formulaID=Item.GetItemInfoN(itemID, Item.ITEM_TYPE);
	LogInfo("formulaID="..formulaID);	
	p.initComposeUI(layerCompose);
	
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
	
	if CheckP(petNameContainer) then
		petNameContainer:ShowViewByIndex(0);
	end
	
	return true;
end

function p.initComposeUI(layer)	
	local productItemType=GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.PRODUCT);
	LogInfo("productItemType="..productItemType);
	local itemBtn=GetItemButton(layer,ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF);
	if CheckP(itemBtn) then
	    itemBtn:ChangeItemType(productItemType);
	end		
	local itemInfoLabel=GetLabel(layer,ID_WEAPONMIX_CTRL_TEXT_INFO);	
	if CheckP(itemInfoLabel) then
		ItemUI.AttachItemND(itemInfoLabel,formulaID,RectUILayer.size.w / 3);	
	end
	local productNumLabel = GetLabel(layer,ID_WEAPONMIX_CTRL_TEXT_STUFF_NUM); 
	if CheckP(productNumLabel) then
		local productNum = GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.PRODUCT_NUM);
		if productNum > 1 then
		  productNumLabel:SetText(tostring(productNum));
		end
	end
		
	table.insert(TAG_MATERIAL_IMG_LIST, ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_1);
	table.insert(TAG_MATERIAL_IMG_LIST, ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_2);
	table.insert(TAG_MATERIAL_IMG_LIST, ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_3);
	table.insert(TAG_MATERIAL_IMG_LIST, ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_4);
	table.insert(TAG_MATERIAL_IMG_LIST, ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_5);
	table.insert(TAG_MATERIAL_IMG_LIST, ID_WEAPONMIX_CTRL_OBJECT_BUTTON_STUFF_6);	
	
	table.insert(TAG_MATERIAL_TEXT_LIST, ID_WEAPONMIX_CTRL_TEXT_NUM_1);
	table.insert(TAG_MATERIAL_TEXT_LIST, ID_WEAPONMIX_CTRL_TEXT_NUM_2);
	table.insert(TAG_MATERIAL_TEXT_LIST, ID_WEAPONMIX_CTRL_TEXT_NUM_3);
	table.insert(TAG_MATERIAL_TEXT_LIST, ID_WEAPONMIX_CTRL_TEXT_NUM_4);
	table.insert(TAG_MATERIAL_TEXT_LIST, ID_WEAPONMIX_CTRL_TEXT_NUM_5);
	table.insert(TAG_MATERIAL_TEXT_LIST, ID_WEAPONMIX_CTRL_TEXT_NUM_6);
		
	p.refreshMaterialUI(layer,DB_FORMULATYPE.MATERIAL1,DB_FORMULATYPE.NUM1,1);
	p.refreshMaterialUI(layer,DB_FORMULATYPE.MATERIAL2,DB_FORMULATYPE.NUM2,2);
	p.refreshMaterialUI(layer,DB_FORMULATYPE.MATERIAL3,DB_FORMULATYPE.NUM3,3);
	p.refreshMaterialUI(layer,DB_FORMULATYPE.MATERIAL4,DB_FORMULATYPE.NUM4,4);
	p.refreshMaterialUI(layer,DB_FORMULATYPE.MATERIAL5,DB_FORMULATYPE.NUM5,5);
	p.refreshMaterialUI(layer,DB_FORMULATYPE.MATERIAL6,DB_FORMULATYPE.NUM6,6);			
end

function p.refreshMaterialUI(layer,material,num,index)
    local materialItemType = GetDataBaseDataN("formulatype",formulaID,material);
	if materialItemType ~= 0 then
	  local materialBtn=GetItemButton(layer,TAG_MATERIAL_IMG_LIST[index]);
	  if CheckP(materialBtn) then
		materialBtn:ChangeItemType(materialItemType);
		local materialLabel = GetLabel(layer,TAG_MATERIAL_TEXT_LIST[index]);
		if CheckP(materialLabel) then
		  local owerNum = ItemFunc.GetItemCount(materialItemType);
		  local needNum = GetDataBaseDataN("formulatype",formulaID,num);
		  if CheckN(owerNum) and CheckN(needNum) then
		    if owerNum > needNum then
			  owerNum = needNum;
			end
			if owerNum >= needNum then
			  materialLabel:SetFontColor(ccc4(0, 255, 0, 255));
			end
			materialLabel:SetText(owerNum.."/"..needNum);		  
		  end
	    end	
	  end
	end
end

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
			return true;
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
	
	return true;
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
   LogInfo("p.OnUIEventRightPanel[%d]", tag);
   if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
      if ID_WEAPONMIX_CTRL_BUTTON_CLOSE == tag then 
		 CloseUI(NMAINSCENECHILDTAG.PlayerUICompose);
		 return true; 
	  elseif ID_WEAPONMIX_CTRL_BUTTON_COMPOUND == tag then 
		 MsgCompose.SendComposeAction(formulaID)
		 return true; 
	  end 	
	  for i, v in ipairs(TAG_MATERIAL_IMG_LIST) do
		if v == tag then
		   local itemBtn = ConverToItemButton(uiNode);
		   if CheckP(itemBtn) then
		      local materialItemType = ConvertN(itemBtn:GetItemType());
			  if materialItemType ~= 0 then
			    local mapID=GetDataBaseDataN("itemtype",materialItemType,DB_ITEMTYPE.ORIGIN_MAP); 
				if mapID ~= 0 then 
		          CloseUI(NMAINSCENECHILDTAG.PlayerUICompose);
		          TaskUI.GoToDynMap(mapID,1);
				end		  
			  end
	       end		
		   return true;
		end
	  end
   end  
   return true; 
end

function p.OnUIEvenPet(uiNode, uiEventType, param) 
    local tag = uiNode:GetTag();
    LogInfo("p.OnUIEventScroll[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ROLEATTR_L_CTRL_BUTTON_INHERIT == tag then
				if not IsUIShow(NMAINSCENECHILDTAG.RoleInherit) then
					CloseMainUI();
					RoleInherit.LoadUI();
				end
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_LEAVE then
				local view = PRecursiveSV(uiNode, 1);
				if not CheckP(view) then
					LogInfo("p.OnUIEventScroll ot CheckP(view)");
					return true;
				end
				p.OnClickPetLeave(view:GetViewId());
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_TRAIN then
			local view = PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				LogInfo("p.OnUIEventScroll ot CheckP(view)");
				return true;
			end
			local nPetId = view:GetViewId();
			RoleTrainUI.LoadUI(nPetId);
		end
	end
	
	return true;
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

function p.GetDetailParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerUICompose, TAG_LAYER_COMPOSE});
	return layer;
end

function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end

	local containter = RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerUICompose, ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	return containter;
end

function p.GetPetNameSVC()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	local svc = RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerUICompose, ID_ROLEATTR_L_BG_CTRL_LIST_NAME});
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
				roleNode:ChangeLookFace(GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_LOOKFACE));
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
		--nTag	= ID_ROLEATTR_L_CTRL_TEXT_PLAYER_NAME;
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

function p.Init()
	p.InitEquipTag();
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

function p.GameDataPetAttrRefresh(datalist)
	if not CheckT(datalist) then
		return;
	end
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerUICompose) then
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

GameDataEvent.Register(GAMEDATAEVENT.PETATTR, "PlayerUIBackBag.GameDataPetAttrRefresh", p.GameDataPetAttrRefresh);
