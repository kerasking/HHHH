-------------------------------------------
---伙伴传承界面
---2012.3.9
---creator cl
-------------------------------------------
local _G = _G;

RoleInherit={}
local p=RoleInherit;

---tag
local ID_ROLEINHERIT_CTRL_PICTURE_ARROW_MID    = 65;
local ID_ROLEINHERIT_CTRL_HORIZON_LIST_RIGHT   = 549;
local ID_ROLEINHERIT_CTRL_HORIZON_LIST_LEFT    = 548;
local ID_ROLEINHERIT_CTRL_BUTTON_INHERIT_VIP   = 459;
local ID_ROLEINHERIT_CTRL_BUTTON_INHERIT    = 458;
local ID_ROLEINHERIT_CTRL_BUTTON_CLOSE     = 457;
local ID_ROLEINHERIT_CTRL_TEXT_455      = 455;
local ID_ROLEINHERIT_CTRL_PICTURE_BG     = 550;
local ID_ROLEINHERIT_CTRL_PICTURE_BG2     = 456;

local ID_ROLEINHERIT_M_CTRL_PICTURE_ROLE    = 92;
local ID_ROLEINHERIT_M_CTRL_PICTURE_R     = 91;
local ID_ROLEINHERIT_M_CTRL_PICTURE_L     = 90;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_12     = 1247;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_11     = 1246;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_10     = 1245;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_9     = 1243;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_8     = 1242;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_7     = 1241;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_6     = 1240;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_5     = 1239;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_4     = 1238;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_3     = 1237;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_2     = 1236;
local ID_ROLEINHERIT_M_CTRL_TEXT_L_1     = 1235;
local ID_ROLEINHERIT_M_CTRL_BUTTON_PILL_LIST   = 1234;
local ID_ROLEINHERIT_M_CTRL_TEXT_1233     = 1233;
local ID_ROLEINHERIT_M_CTRL_TEXT_1232     = 1232;
local ID_ROLEINHERIT_M_CTRL_TEXT_1231     = 1231;
local ID_ROLEINHERIT_M_CTRL_TEXT_1230     = 1230;
local ID_ROLEINHERIT_M_CTRL_TEXT_1229     = 1229;
local ID_ROLEINHERIT_M_CTRL_TEXT_1228     = 1228;
local ID_ROLEINHERIT_M_CTRL_TEXT_1227     = 1227;
local ID_ROLEINHERIT_M_CTRL_TEXT_ROLE_LEVEL    = 1223;
local ID_ROLEINHERIT_M_CTRL_TEXT_ROLE_NAME    = 1222;
local ID_ROLEINHERIT_M_CTRL_PICTURE_M     = 454;

local container_left_index=0;
local container_right_index=0;

local id_right=0;
local id_left=0;
local vip=0;

local inherit_dlg_id=0;

function p.Showing()
	local scene = GetSMGameScene();
	if scene == nil then
		return false;
	end
	
	local layer = scene:GetChild(NMAINSCENECHILDTAG.RoleInherit);
	if layer == nil then
		return false;
	end
	
	return true;
end

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load RoleInherit failed!");
		return;
	end
	container_left_index=0;
	container_right_index=0;
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.RoleInherit);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("RoleInherit.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	p.RefreshContainer();
end


function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RoleInherit);
	if nil == layer then
		return nil;
	end
	
	--local container = GetScrollViewContainer(layer, TAG_CONTAINER);
	return layer;
end

function p.RefreshContainer()
	local layer = p.GetPetParent();
	if nil == layer then
		return nil;
	end
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local invited_idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil ~= invited_idTable then
		pet_num = table.getn(invited_idTable);
	end
	
	if pet_num == 1 then
		LogInfo("pet_num == 1");
		return;
	end
	
	local container_left = GetScrollViewContainer(layer,ID_ROLEINHERIT_CTRL_HORIZON_LIST_LEFT);
	if nil == container_left then
		LogInfo("nil == container_left");
		return;
	end
	container_left:SetStyle(UIScrollStyle.Horzontal);
	container_left:SetViewSize(CGSizeMake(RectUILayer.size.w/2, RectUILayer.size.h));

	
	local container_right = GetScrollViewContainer(layer,ID_ROLEINHERIT_CTRL_HORIZON_LIST_RIGHT);
	if nil == container_right then
		LogInfo("nil == container_right");
		return;
	end
	container_right:SetStyle(UIScrollStyle.Horzontal);
	container_right:SetViewSize(CGSizeMake(RectUILayer.size.w/2, RectUILayer.size.h));

	
	for i, v in ipairs(invited_idTable) do
		LogInfo("idlist,%d",v);
		
		--判断是否是玩家
		if v==nPlayerId then
			continue;
		end
		
		--判断是否已经传承过
		local impart = RolePet.GetPetInfoN(v,PET_ATTR.PET_ATTR_IMPART);
		
		if impart == 0 then
			local view = createUIScrollView();
			if view == nil then
				LogInfo("view == nil");
				continue;
			end
			view:Init(false);
			view:SetViewId(v);
			container_left:AddView(view);
			local uiLoad = createNDUILoad();
			if uiLoad ~= nil then
				uiLoad:Load("RoleInherit_M.ini",view,p.OnUIInheritUIEvent,0,0);
				uiLoad:Free();
			end
			p.updateAttr(view,v);
		end
		
		--判断是否已经被传承过
		local obtain = RolePet.GetPetInfoN(v,PET_ATTR.PET_ATTR_OBTAIN);
		
		if obtain == 0 then
			local view = createUIScrollView();
			if view == nil then
				LogInfo("view == nil");
				continue;
			end
			view:Init(false);
			view:SetViewId(v);
			container_right:AddView(view);
			local uiLoad = createNDUILoad();
			if uiLoad ~= nil then
				uiLoad:Load("RoleInherit_M.ini",view,p.OnUIInheritUIEvent,0,0);
				uiLoad:Free();
			end
			p.updateAttr(view,v);
		end
		
	end
	
	p.RefreshInheritAttr();
	
end

function p.updateAttr(view,petId)
	LogInfo("updateAttr:%d",petId);
	--名称
	local value=RolePet.GetPetInfoS(petId,PET_ATTR.PET_ATTR_NAME);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_ROLE_NAME,value);
	--等级
	value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_LEVEL);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_ROLE_LEVEL,"Lv"..SafeN2S(value));
	--基础武力
	value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_PHYSICAL);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_1,SafeN2S(value));
	--培养武力
	value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_PHY_FOSTER);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_2,SafeN2S(value));
	--丹药武力
	value=RolePet.GetMedicinePhy(petId);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_3,SafeN2S(value));
	--总武力
	value=RolePet.GetTotalPhy(petId);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_4,SafeN2S(value));
	
	--基础绝技
	value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_SUPER_SKILL);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_5,SafeN2S(value));
	--培养绝技
	value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_6,SafeN2S(value));
	--丹药绝技
	value=RolePet.GetMedicineSuperSkill(petId);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_7,SafeN2S(value));
	--总绝技
	value=RolePet.GetTotalSuperSkill(petId);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_8,SafeN2S(value));
	
	--基础法力
	value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_MAGIC);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_9,SafeN2S(value));
	--培养法力
	value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_MAGIC_FOSTER);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_10,SafeN2S(value));
	--丹药法力
	value=RolePet.GetMedicineMagic(petId);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_11,SafeN2S(value));
	--总法力
	value=RolePet.GetTotalMagic(petId);
	SetLabel(view,ID_ROLEINHERIT_M_CTRL_TEXT_L_12,SafeN2S(value));
end

function p.ShowImpartDlg(v)
	vip=v;
	local layer = p.GetPetParent();
	if nil == layer then
		return nil;
	end
	
	local container_left = GetScrollViewContainer(layer,ID_ROLEINHERIT_CTRL_HORIZON_LIST_LEFT);
	if nil == container_left then
		LogInfo("nil == container_left");
		return;
	end
	
	local container_right = GetScrollViewContainer(layer,ID_ROLEINHERIT_CTRL_HORIZON_LIST_RIGHT);
	if nil == container_right then
		LogInfo("nil == container_right");
		return;
	end
	
	local view_left=ConverToSV(container_left:GetView(container_left_index));
	local view_right=ConverToSV(container_right:GetView(container_right_index));
	
	id_left=0;
	id_right=0;
	
	if nil ~= view_left then
		id_left=view_left:GetViewId();
	end
	
	if nil ~= view_right then
		id_right=view_right:GetViewId();
	end

	if id_left == 0 or id_right == 0 or id_left == id_right then
		return;
	end
	LogInfo("SendImpart:%d,%d",id_left,id_right);
	
	local left_name=RolePet.GetPetInfoS(id_left,PET_ATTR.PET_ATTR_NAME);
	local left_level=RolePet.GetPetInfoN(id_left,PET_ATTR.PET_ATTR_LEVEL);
	
	local right_name=RolePet.GetPetInfoS(id_right,PET_ATTR.PET_ATTR_NAME);
	local right_level=RolePet.GetPetInfoN(id_right,PET_ATTR.PET_ATTR_LEVEL);
	
	inherit_dlg_id=CommonDlg.ShowNoPrompt("是否确定进"..left_name.."（等级"..SafeN2S(left_level).."）对"..right_name.."（等级"..SafeN2S(right_level).."）的传承？", p.onCommonDlg, true);
end

function p.onCommonDlg(nId, nEvent, param)
	if nId == inherit_dlg_id then
		if nEvent == CommonDlg.EventOK then
			_G.MsgRolePet.SendImpartPet(id_left,id_right,vip);
		end
	end
end


function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ROLEINHERIT_CTRL_BUTTON_CLOSE == tag then
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.RoleInherit,true);
				return true;
			end
		elseif ID_ROLEINHERIT_CTRL_BUTTON_INHERIT then
			p.ShowImpartDlg(0);
		elseif ID_ROLEINHERIT_CTRL_BUTTON_INHERIT_VIP then
			p.ShowImpartDlg(1);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	
	elseif uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		if tag == ID_ROLEINHERIT_CTRL_HORIZON_LIST_LEFT then
			container_left_index=param;
		elseif tag == ID_ROLEINHERIT_CTRL_HORIZON_LIST_RIGHT then
			container_right_index=param;
		end
		p.RefreshInheritAttr();
	end
	return true;
end

function p.RefreshInheritAttr()
	local layer = p.GetPetParent();
	if nil == layer then
		return nil;
	end
	
	local container_left = GetScrollViewContainer(layer,ID_ROLEINHERIT_CTRL_HORIZON_LIST_LEFT);
	if nil == container_left then
		LogInfo("nil == container_left");
		return;
	end
	
	local container_right = GetScrollViewContainer(layer,ID_ROLEINHERIT_CTRL_HORIZON_LIST_RIGHT);
	if nil == container_right then
		LogInfo("nil == container_right");
		return;
	end
	
	LogInfo("Li %d,Ri %d",container_left_index,container_right_index);
	
	local view_left=ConverToSV(container_left:GetView(container_left_index));
	local view_right=ConverToSV(container_right:GetView(container_right_index));
	
	local id_left=0;
	local id_right=0;
	
	if nil ~= view_left then
		id_left=view_left:GetViewId();
	end
	
	if nil ~= view_right then
		id_right=view_right:GetViewId();
	end
	
	p.updateAttr(view_right,id_right);
		
	LogInfo("L %d,R %d",id_left,id_right);
	
	local button1=GetButton(layer,ID_ROLEINHERIT_CTRL_BUTTON_INHERIT);
	local button2=GetButton(layer,ID_ROLEINHERIT_CTRL_BUTTON_INHERIT_VIP);
	
	if id_left == 0 or id_right == 0 or id_left == id_right then
		LogInfo("can not inherit:%d,%d",id_left,id_right);
		button1:EnalbeGray(true);
		button2:EnalbeGray(true);
		return;
	end
	button1:EnalbeGray(false);
	button2:EnalbeGray(false);
		
	--处理等级
	local new_level=RolePet.GetPetInfoN(id_left,PET_ATTR.PET_ATTR_LEVEL)/2;
	local old_level=RolePet.GetPetInfoN(id_right,PET_ATTR.PET_ATTR_LEVEL);
	if new_level>old_level then
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_ROLE_LEVEL,"Lv"..SafeN2S(old_level).."(Lv"..SafeN2S(new_level)..")");
	end
	
	local add=0;
	
	--处理培养武力
	local new_foster=RolePet.GetPetInfoN(id_left,PET_ATTR.PET_ATTR_PHY_FOSTER)/2;
	local old_foster=RolePet.GetPetInfoN(id_right,PET_ATTR.PET_ATTR_PHY_FOSTER);
	if new_foster>old_foster then
		add=add+(new_foster-old_foster);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_2,SafeN2S(old_foster).."(+"..SafeN2S(new_foster-old_foster)..")");
	end
	
	--处理丹药武力
	local new_medicine=RolePet.GetInheritMedPhy(id_left);
	local old_medicine=RolePet.GetMedicinePhy(id_right);
	if new_medicine>old_medicine then
		--LogInfo("new:%d,old:%d",new_medicine,old_medicine);
		add=add+(new_medicine-old_medicine);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_3,SafeN2S(old_medicine).."(+"..SafeN2S(new_medicine-old_medicine)..")");
		--LogInfo("add:%d",add);
	end
	
	--处理总武力
	if add > 0 then
		local old_total=RolePet.GetTotalPhy(id_right);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_4,SafeN2S(old_total).."(+"..SafeN2S(add)..")");
	end
	-------------------------------------------
	add=0;
	
	--处理培养绝技
	local new_foster=RolePet.GetPetInfoN(id_left,PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER)/2;
	local old_foster=RolePet.GetPetInfoN(id_right,PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER);
	if new_foster>old_foster then
		add=add+(new_foster-old_foster);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_6,SafeN2S(old_foster).."(+"..SafeN2S(new_foster-old_foster)..")");
	end
	
	--处理丹药绝技
	local new_medicine=RolePet.GetInheritMedSuperSkill(id_left);
	local old_medicine=RolePet.GetMedicineSuperSkill(id_right);
	if new_medicine>old_medicine then
		add=add+(new_medicine-old_medicine);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_7,SafeN2S(old_medicine).."(+"..SafeN2S(new_medicine-old_medicine)..")");
	end
	
	--处理总绝技
	if add > 0 then
		local old_total=RolePet.GetTotalSuperSkill(id_right);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_8,SafeN2S(old_total).."(+"..SafeN2S(add)..")");
	end
	--------------------------------------------
	add=0;
	
	--处理培养法力
	local new_foster=RolePet.GetPetInfoN(id_left,PET_ATTR.PET_ATTR_MAGIC_FOSTER)/2;
	local old_foster=RolePet.GetPetInfoN(id_right,PET_ATTR.PET_ATTR_MAGIC_FOSTER);
	if new_foster>old_foster then
		add=add+(new_foster-old_foster);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_10,SafeN2S(old_foster).."(+"..SafeN2S(new_foster-old_foster)..")");
	end
	
	--处理丹药法力
	local new_medicine=RolePet.GetInheritMedMagic(id_left);
	local old_medicine=RolePet.GetMedicineMagic(id_right);
	if new_medicine>old_medicine then
		add=add+(new_medicine-old_medicine);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_11,SafeN2S(old_medicine).."(+"..SafeN2S(new_medicine-old_medicine)..")");
	end
	
	--处理总法力
	if add > 0 then
		local old_total=RolePet.GetTotalMagic(id_right);
		SetLabel(view_right,ID_ROLEINHERIT_M_CTRL_TEXT_L_12,SafeN2S(old_total).."(+"..SafeN2S(add)..")");
	end
end

function p.OnUIInheritEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUInheritIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		LogInfo("scroll_event");
	end
	
	return true;
end
