---------------------------------------------------
--描述: 好友资料UI
--时间: 2012.4.16
--作者: fyl
---------------------------------------------------



FriendAttrUI = {}
local p = FriendAttrUI;

--bg tag
local ID_ROLEATTR_L_BG_CTRL_LIST_LEFT			    = 51;
local ID_ROLEATTR_L_BG_CTRL_LIST_NAME			    = 50;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_67			= 67;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_66			= 66;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_LIST_LEFT			= 51;
local ID_SM_JH_ROLEATTR_L_BG_CTRL_LIST_NAME			= 50;


--L
local ID_ROLEATTR_L_CTRL_EXP_ROLE					= 33;
local ID_ROLEATTR_L_CTRL_BUTTON_SHOES				= 62;
local ID_ROLEATTR_L_CTRL_BUTTON_DRESS				= 61;
local ID_ROLEATTR_L_CTRL_BUTTON_HELMET				= 60;
local ID_ROLEATTR_L_CTRL_BUTTON_AMULET				= 59;
local ID_ROLEATTR_L_CTRL_BUTTON_WEAPON				= 58;
local ID_ROLEATTR_L_CTRL_BUTTON_SOUL				= 57;
local ID_ROLEATTR_L_CTRL_TEXT_MAGIC					= 28;
local ID_ROLEATTR_L_CTRL_TEXT_SKILL					= 27;
local ID_ROLEATTR_L_CTRL_TEXT_ABILITY				= 24;
local ID_ROLEATTR_L_CTRL_TEXT_LIFE					= 22;
local ID_ROLEATTR_L_CTRL_TEXT_FORCE					= 20;
local ID_ROLEATTR_L_CTRL_TEXT_JOB					= 17;
local ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG			= 9;

--R
local ID_ROLEATTR_R_CTRL_BUTTON_95					= 96;
local ID_ROLEATTR_R_CTRL_TEXT_CRIT					= 138;
local ID_ROLEATTR_R_CTRL_TEXT_DODGE					= 135;
local ID_ROLEATTR_R_CTRL_TEXT_KILL					= 131;
local ID_ROLEATTR_R_CTRL_TEXT_WRECK					= 130;
local ID_ROLEATTR_R_CTRL_TEXT_HIT					= 129;
local ID_ROLEATTR_R_CTRL_TEXT_TENACITY				= 125;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK			= 124;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE			= 121;
local ID_ROLEATTR_R_CTRL_TEXT_STUNT_DEFENSE			= 120;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE		= 119;
local ID_ROLEATTR_R_CTRL_TEXT_STUNT_ATTACK			= 117;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK			= 116;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LIFE				= 109;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL			= 108;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_SKILL			= 105;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_JOB				= 104;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_NAME				= 103;
local ID_ROLEATTR_R_CTRL_TEXT_FIGHTING				= 137;
local ID_ROLEATTR_R_CTRL_TEXT_BLOCK					= 136;
local ID_ROLEATTR_R_CTRL_PICTURE_ROLE_ICON			= 99;


local TAG_LAYER_ATTR = 12345;				--属性界面层tag
-- 界面控件坐标定义
local winsize = GetWinSize();

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;


local friendId;
local friendName = "";
local TAG_EQUIP_LIST = {};--装备Tag列表
-----------------------
-----------------------

function p.LoadUI(nPlayerId,nPlayerName)
	friendId = nPlayerId;
	friendName = nPlayerName;
	p.InitEquipTag();
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load GiveFlowersUI failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.FriendAttr);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("SM_JH_RoleAttr_L_BG.ini", layer, p.OnUIEventScroll, 0, 0);
	
	
	local layerAttr = createNDUILayer();
	if not CheckP(layerAttr) then
		uiLoad:Free();
		layer:Free();
		return false;
	end
	layerAttr:Init();
	layerAttr:SetTag(TAG_LAYER_ATTR);
	layerAttr:SetFrameRect(CGRectMake(ATTR_OFFSET_X, ATTR_OFFSET_Y, RectUILayer.size.w / 2, RectUILayer.size.h));
	layer:AddChild(layerAttr);
	
	uiLoad:Load("RoleAttr_R.ini", layerAttr, p.OnUIEvent, 0, 0);
	
	uiLoad:Free();	
	
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
	p.RefreshBtnText();
	
	local beginView	= containter:GetBeginView(0);
	if CheckP(beginView) then
		p.ChangePetAttr(beginView:GetViewId());
	end
	
	if CheckP(petNameContainer) then
		petNameContainer:ShowViewByIndex(0);
	end
	
	return true;
end


function p.RefreshBtnText()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.FriendAttr);
	if nil == layer then
		return nil;
	end
   
    local btn = GetButton(layer,ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_66);
	local str ="";
	if FriendUI.IsExistFriend(friendId) then
		str= "删除好友";
	else
	    str= "加为好友";
	end		
	LogInfo(str)
	btn:SetTitle(str);
          
end


function p.GetEquipTag(nPos)
	if not CheckT(TAG_EQUIP_LIST) or not CheckN(nPos) then
	    LogInfo("  p.GetEquipTag  error")
		return 0;
	end
	return ConvertN(TAG_EQUIP_LIST[nPos]);
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

function p.GetDetailParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.FriendAttr, TAG_LAYER_ATTR});
	return layer;
end

function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.FriendAttr);
	if nil == layer then
		return nil;
	end
	
	local containter = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	return containter;
end

function p.GetPetNameSVC()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	local svc = RecursiveSVC(scene, {NMAINSCENECHILDTAG.FriendAttr, ID_ROLEATTR_L_BG_CTRL_LIST_NAME});
	return svc;
end


function p.RefreshContainer()
	local container = p.GetPetParent();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	
	local petNameContainer = p.GetPetNameSVC();
	if CheckP(petNameContainer) then
		petNameContainer:RemoveAllView();
	end
	
	if nil == friendId then
		LogInfo("nil == friendId");
		return;
	end
    LogInfo("查看好友资料，friendId[%d]",friendId)
	
	--获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(friendId);
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
	rectview.origin.x = 0;
	rectview.origin.y = 0;
	
	for i, v in ipairs(idTable) do
		local view = createUIScrollView();
		if view == nil then
			LogInfo("view == nil");
			continue;
		end
		view:Init(false);
		view:SetViewId(v);
		container:AddView(view);

		local uiLoad = createNDUILoad();
		if uiLoad ~= nil then
			uiLoad:Load("SM_JH_RoleAttr_L.ini", view, nil, 0, 0);
			uiLoad:Free();
		end
		
		--宠物名字
		p.ContainerAddPetName(v);
		
		local pRoleForm = GetUiNode(view, ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG);
		local rectForm	= pRoleForm:GetFrameRect();
		if nil ~= pRoleForm then
			local roleNode = createUIRoleNode();
			if nil ~= roleNode then
				roleNode:Init();
				roleNode:SetFrameRect(CGRectMake(0, 0, rectForm.size.w, rectForm.size.h));
				roleNode:ChangeLookFace(RolePetFunc.GetLookFace(v));
				pRoleForm:AddChild(roleNode);
			end
		end
		--宠物Attr
		p.UpdatePetAttrById(v);
		--宠物装备
		local idlist	= ItemPet.GetEquipItemList(friendId, v);
		LogInfo("pet装备id列表");
		LogInfoT(idlist);
		for i, v in ipairs(idlist) do
			local nPos	= Item.GetItemInfoN(v, Item.ITEM_POSITION);
			local nTag	= p.GetEquipTag(nPos);
			LogInfo("tag:[%d] position:[%d]",nTag,nPos)
			if nTag > 0 then
				local equipBtn	= GetEquipButton(view, nTag);
				if CheckP(equipBtn) then
				    LogInfo("aaa")
					equipBtn:ChangeItem(v);
				end
			end
		end
		
		
	end
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
		
	if not RolePetUser.IsExistPet(friendId, nPetId) then
		return;
	end
	
	local view	= container:GetViewById(nPetId);
	if not CheckP(view) then
		return;
	end
	--职业
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_TYPE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));
	--武力
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHYSICAL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL));
	--生命
	local strlife = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE) .. "/" .. RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE_LIMIT);
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LIFE, strlife);
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


function p.ChangePetAttr(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("not RolePet.IsExistPet[%d]", nPetId);
	end
	
	local layer = p.GetDetailParent();
	if not CheckP(layer) then
		return;
	end

	--姓名
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_NAME, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	--职业
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_JOB, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));
	--技能
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));
	--等级
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	--生命
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LIFE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE));
	--普攻
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_ATK));
	--普防
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_DEF));
	--绝攻
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_STUNT_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL_ATK));
	--绝防
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_STUNT_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL_DEF));
	--法攻
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK));
	--法防
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF));
	--暴击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_CRIT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DRITICAL));
	--韧性
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_TENACITY, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TENACITY));
	--命中
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_HIT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HITRATE));
	--闪避
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_DODGE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DODGE));
	--破击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_WRECK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_WRECK));
	--格档
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_BLOCK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_BLOCK));
	--必杀
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_KILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HURT_ADD));
	--战力
	--SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_FIGHTING, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));
end


---------------
--UI事件处理回调函数
---------------

function p.OnUIEvent(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local tag = uiNode:GetTag();
		if tag == ID_ROLEATTR_R_CTRL_BUTTON_95 then
			--关闭界面
			CloseUI(NMAINSCENECHILDTAG.FriendAttr);
	    end
	end	
	return true;
end

function p.OnUIEventScroll(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventScroll[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_67 then
		    --赠送鲜花 
			
			MsgFriend.SendOpenGiveFlower(friendId,friendName);
		    --判断今天是否赠送过了
		    --CommonDlg.ShowTipInfo("提示", "您今天已经赠送过鲜花了!", nil, 2); 
			
		elseif tag == ID_SM_JH_ROLEATTR_L_BG_CTRL_BUTTON_66 then
		        if FriendUI.IsExistFriend(friendId)  then
				    CommonDlg.ShowNoPrompt(string.format("确定删除好友%s吗？",friendName), p.OnCommonDlgDelFriend, true);
				else
				    FriendFunc.AddFriend(friendId,friendName); --加为好友 
				end	
		end
	end
	
	return true;
end


function p.OnUIEventClickPetName(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    --获取按钮所在的view
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
				p.ChangePetAttr(nPetId);
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



function p.OnCommonDlgDelFriend(nId, nEvent, param)
	if nEvent == CommonDlg.EventOK then
			MsgFriend.SendFriendDel(friendId,friendName);--删除好友         
	end
end	




