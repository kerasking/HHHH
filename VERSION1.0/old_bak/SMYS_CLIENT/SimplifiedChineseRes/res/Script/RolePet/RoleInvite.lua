-------------------------------------------
---伙伴邀请界面
---2012.3.6
---creator cl
-------------------------------------------
local _G = _G;

RoleInvite={}
local p=RoleInvite;

---tag
local ID_ROLEINVITE_CTRL_TEXT_INFO					= 63;
local ID_ROLEINVITE_CTRL_TEXT_VOICE					= 62;
local ID_ROLEINVITE_CTRL_TEXT_61						= 61;
local ID_ROLEINVITE_CTRL_BUTTON_CLOSE					= 38;
local ID_ROLEINVITE_CTRL_TEXT_37						= 37;
local ID_ROLEINVITE_CTRL_LIST_M						= 65;
local ID_ROLEINVITE_CTRL_PICTURE_66					= 66;
local ID_ROLEINVITE_CTRL_PICTURE_BG					= 36;

local CONTAINTER_W = RectUILayer.size.w;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

---tag invite
local ID_ROLEINVITE_M_INVITE_CTRL_PICTURE_RECOMMEND	= 40;
local ID_ROLEINVITE_M_INVITE_CTRL_BUTTON_INVITE     = 67;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_SEE      = 60;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_MONEY     = 59;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_58      = 58;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_MAGIC     = 57;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_ABILITY     = 56;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_FORCE     = 55;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_LIFE      = 54;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_52      = 52;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_51      = 51;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_50      = 50;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_49      = 49;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_SKILL     = 48;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_47      = 47;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_JOB      = 46;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_45      = 45;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_44      = 44;
local ID_ROLEINVITE_M_INVITE_CTRL_TEXT_43      = 43;
local ID_ROLEINVITE_M_INVITE_CTRL_PICTURE_ROLE     = 39;
local ID_ROLEINVITE_M_INVITE_CTRL_PICTURE_M_BG     = 42;

-- 界面控件tag定义
local TAG_CONTAINER = 2;			--容器tag

function p.Showing()
	local scene = GetSMGameScene();
	if scene == nil then
		return false;
	end
	
	local layer = scene:GetChild(NMAINSCENECHILDTAG.RoleInvite);
	if layer == nil then
		return false;
	end
	
	return true;
end

function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo("scene = nil,load RoleInvite failed!");
		return;
	end
	local layer = createNDUILayer();
	if layer == nil then
		LogInfo("scene = nil,2");
		return  false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.RoleInvite);
	layer:SetFrameRect(RectUILayer);
	layer:SetBackgroundColor(ccc4(125,125,125,125));
	scene:AddChild(layer);
	
	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo("scene = nil,4");
		return false;
	end
	uiLoad:Load("RoleInvite.ini",layer,p.OnUIEvent,0,0);
	uiLoad:Free();
	
	--local containter = createUIScrollViewContainer();
	local containter = GetScrollViewContainer(layer,ID_ROLEINVITE_CTRL_LIST_M);
	if (nil == containter) then
		layer:Free();
		LogInfo("scene = nil,3");
		return false;
	end
	--containter:Init();
	containter:SetStyle(UIScrollStyle.Horzontal);
	--containter:SetFrameRect(CGRectMake(CONTAINTER_X, CONTAINTER_Y, CONTAINTER_W, CONTAINTER_H));
	containter:SetViewSize(CGSizeMake(containter:GetFrameRect().size.w/3, containter:GetFrameRect().size.h));
	--containter:SetLeftReserveDistance(CONTAINTER_W);
	--containter:SetRightReserveDistance(CONTAINTER_W);
	--containter:SetTag(TAG_CONTAINER);
	--layer:AddChild(containter);
	
	p.RefreshContainer();

	return true;
end

function p.SendInviteAction()
	if not CheckN(nPetId) or not CheckN(nAction) then
		return false;
	end
	if nTaskId <= 0 then
		return false;
	end
	local netdata = createNDTransData(NMSG_Type._MSG_TASK_ACTION);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(nAction);
	netdata:WriteInt(nTaskId);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send task[%d] action[%d]", nTaskId, nAction);
	return true;
end

function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ROLEINVITE_CTRL_BUTTON_CLOSE == tag then
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.RoleInvite,true);
				return true;
			end
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

function p.OnInviteUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnInviteUIEven[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ROLEINVITE_M_INVITE_CTRL_BUTTON_INVITE == tag then
			local view=PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				return true;
			end
			local id=view:GetViewId();
			--LogInfo("petId:%d",id);
			_G.MsgRolePet.SendBuyPet(id);

		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

function p.OnInviteBackUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnInviteBackUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ROLEINVITE_M_INVITE_CTRL_BUTTON_INVITE == tag then
			local view=PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				return true;
			end
			local id=view:GetViewId();
			_G.MsgRolePet.SendBuyBackPet(id);
			LogInfo("petId:%d",id);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

function p.GetReputeLevel(repute)
	if repute < 2000 then
		return 1;
	elseif repute < 5000 then
		return 2;
	elseif repute < 20000 then
		return 3;
	elseif repute < 60000 then
		return 4;
	elseif repute < 100000 then
		return 5;
	elseif repute < 150000 then
		return 6;
	elseif repute < 200000 then
		return 7;
	elseif repute < 260000 then
		return 8;
	elseif repute < 320000 then
		return 9;
	elseif repute < 400000 then
		return 10;
	elseif repute >= 400000 then
		return 11;
	end
	return 0;
end

function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RoleInvite);
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
	
	
	local container = GetScrollViewContainer(layer,ID_ROLEINVITE_CTRL_LIST_M);
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
	
	--设置我的声望
	local repute = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_REPUTE);
	local repute_lev=p.GetReputeLevel(repute);
	SetLabel(layer,ID_ROLEINVITE_CTRL_TEXT_VOICE,SafeN2S(repute).."(Lv"..SafeN2S(repute_lev)..")");
	
	--获得我当前的stage
	local stage = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_STAGE);
	
	
	--获得招募列表
	local idList=GetDataBaseIdList("pet_config");
	if nil == idList then
		LogInfo("nil == idList");
		return;
	end
	
	--获取当前已招募的列表
	local invited_idTable = RolePetUser.GetPetList(nPlayerId);
	local inTeam_idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	local pet_num = 1;
	if nil ~= invited_idTable then
		pet_num = table.getn(inTeam_idTable);
	end
	
	--显示招募上限
	local pet_limit = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_PET_LIMIT);
	SetLabel(layer,ID_ROLEINVITE_CTRL_TEXT_INFO,"队伍人数上限："..SafeN2S(pet_num).."/"..SafeN2S(pet_limit).."，人数上限随着剧情发展而增加");
	for i, v in ipairs(idList) do
		
		LogInfo("idlist,%d",v);
		
		--筛选出不可招募的伙伴
		local value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.CAN_CALL);
		--LogInfo("%d",value);
		if 0==value then
			continue;
		end
		
		--筛选出声望不足无法查看的伙伴
		value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.REPUTE_LEV)-1;
		if repute_lev < value then
			--LogInfo("%d,%d",repute_lev,value);
			continue;
		end
		
		--判断已招募和招募过的伙伴
		local position=2;
		local petId=0;
		
		if nil ~= invited_idTable then
			for ii,vv in ipairs(invited_idTable) do
				--DumpGameData(NScriptData.eRole, nPlayerId, NRoleData.ePet, vv);
				local type=RolePet.GetPetInfoN(vv,PET_ATTR.PET_ATTR_TYPE);
				LogInfo("id=%d,type=%d",vv,type);
				if v == type then
					position=RolePet.GetPetInfoN(vv,PET_ATTR.PET_ATTR_POSITION);
					petId=vv;
					break;
				end
			end
		end
		
		--已招募的伙伴不显示
		if position == 0 then
			continue;
		end
		
		--判断玩家当前的游戏进度是否可以开启这个伙伴
		local need_stage = GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.NEED_STAGE);
		LogInfo("stage:%d/%d",stage,need_stage);
		if stage < need_stage then
			continue;
		end
		
		local view = createUIScrollView();
		if view == nil then
			--LogInfo("view == nil");
			continue;
		end
		view:Init(false);
		--LogInfo("viewSize:%d ",container:GetViewSize().w);
		local nOffsetX	= (container:GetViewSize().w - 140 * ScaleFactor) / 2;
		local can_call=true;
		if position == 2 then --从未招募过的伙伴显示
		
			
			view:SetViewId(v);
			container:AddView(view);
			local uiLoad = createNDUILoad();
			if uiLoad ~= nil then
				uiLoad:Load("RoleInvite_M_invite.ini",view,p.OnInviteUIEvent,nOffsetX,0);
				uiLoad:Free();
			end
			
			--名称
			local value=GetDataBaseDataS("pet_config",v,DB_PET_CONFIG.NAME);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_43,value);
			--等级
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_44,"Lv1");
			--职业
			value=GetDataBaseDataS("pet_config",v,DB_PET_CONFIG.PRO_NAME);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_JOB,value);
			--技能
			local id=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.SKILL);
			value=GetDataBaseDataS("skill_config",id,DB_SKILL_CONFIG.NAME);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_SKILL,value);
			--血量
			value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.INIT_LIFE);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_LIFE,SafeN2S(value));
			--武力
			value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.INIT_PHYSICAL);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_FORCE,SafeN2S(value));
			--绝技
			value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.INIT_SUPER_SKILL);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_ABILITY,SafeN2S(value));
			--法力
			value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.INIT_MAGIC);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_MAGIC,SafeN2S(value));
			--金钱需求
			value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.MONEY);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_MONEY,"花费"..SafeN2S(value));
			local money=GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY);
			if money < value then
				local label=GetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_MONEY);
				if CheckP(label) then
					local color=ccc4(255,0,0,255);
					label:SetFontColor(color);
					can_call=false;
				end
			end
			--声望需求
			value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.REPUTE);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_SEE,"需要声望"..SafeN2S(value));
			if repute < value then
				local label=GetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_SEE);
				if CheckP(label) then
					local color=ccc4(255,0,0,255);
					label:SetFontColor(color);
					can_call=false;
				end
			end
			
			if pet_num >= pet_limit then
				can_call = false;
			end
			
			if not can_call then
				local button=GetButton(view,ID_ROLEINVITE_M_INVITE_CTRL_BUTTON_INVITE);
				if CheckP(button) then
					button:EnalbeGray(true);
				end
			end
			
			value=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.RECOMMEND);
			if value == 0 then
				local node=GetUiNode(view,ID_ROLEINVITE_M_INVITE_CTRL_PICTURE_RECOMMEND);
				if CheckP(node) then
					node:SetVisible(false);
				end
			end
			
		elseif position == 1 then --已招募过的伙伴显示
			view:SetViewId(petId);
			container:AddView(view);
			local uiLoad = createNDUILoad();
			if uiLoad ~= nil then
				uiLoad:Load("RoleInvite_M_Rejoin.ini",view,p.OnInviteBackUIEvent,nOffsetX,0);
				uiLoad:Free();
			end
			--名称
			local value=GetDataBaseDataS("pet_config",v,DB_PET_CONFIG.NAME);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_43,value);
			--等级
			value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_LEVEL);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_44,"Lv"..SafeN2S(value));
			--职业
			value=GetDataBaseDataS("pet_config",v,DB_PET_CONFIG.PRO_NAME);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_JOB,value);
			--技能
			local id=GetDataBaseDataN("pet_config",v,DB_PET_CONFIG.SKILL);
			value=GetDataBaseDataS("skill_config",id,DB_SKILL_CONFIG.NAME);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_SKILL,value);
			--血量
			value=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_LIFE);
			local value2=RolePet.GetPetInfoN(petId,PET_ATTR.PET_ATTR_LIFE_LIMIT);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_LIFE,SafeN2S(value).."/"..SafeN2S(value2));
			--武力
			value=RolePet.GetTotalPhy(petId);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_FORCE,SafeN2S(value));
			--绝技
			value=RolePet.GetTotalSuperSkill(petId);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_ABILITY,SafeN2S(value));
			--法力
			value=RolePet.GetTotalMagic(petId);
			SetLabel(view,ID_ROLEINVITE_M_INVITE_CTRL_TEXT_MAGIC,SafeN2S(value));
			
			
			if pet_num >= pet_limit then
				can_call = false;
			end
			
			if not can_call then
				local button=GetButton(view,ID_ROLEINVITE_M_INVITE_CTRL_BUTTON_INVITE);
				if CheckP(button) then
					button:EnalbeGray(true);
				end
			end
		end

	end
	
end