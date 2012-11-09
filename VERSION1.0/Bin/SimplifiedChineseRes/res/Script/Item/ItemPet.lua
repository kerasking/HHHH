---------------------------------------------------
--描述: 宠物装备物品(玩家也是只宠物)
--时间: 2012.3.1
--作者: jhzheng
--注:   这里的物品都是归属于宠物身上的物品(Item.OWNER_TYPE_PET)
---------------------------------------------------

ItemPet = {};
local p = ItemPet;

local eEquipItem					= 1;	--宠物装备物品
local eDaoFaItem					= 1;	--宠物道法物品

--宠物装备(Item.POSITION_EQUIP_1 ~ Item.POSITION_EQUIP_6)
function p.AddEquipItem(nRoleId, nPetId, nItemId)
	p.AddItem(nRoleId, nPetId, nItemId, eEquipItem);
end

function p.DelEquipItem(nRoleId, nPetId, nItemId)
	p.DelItem(nRoleId, nPetId, nItemId, eEquipItem);
end

function p.GetEquipItemList(nRoleId, nPetId)
	return p.GetItemList(nRoleId, nPetId, eEquipItem);
end

--宠物道法(Item.POSITION_DAO_FA_1 ~ Item.POSITION_DAO_FA_8)
function p.AddDaoFaItem(nRoleId, nPetId, nItemId)
	p.AddItem(nRoleId, nPetId, nItemId, eDaoFaItem);
end

function p.DelDaoFaItem(nRoleId, nPetId, nItemId)
	p.DelItem(nRoleId, nPetId, nItemId, eDaoFaItem);
end

function p.GetDaoFaItemList(nRoleId, nPetId)
	return p.GetItemList(nRoleId, nPetId, eDaoFaItem);
end

--内部接口
function p.AddItem(nRoleId, nPetId, nItemId, e)
	if	not CheckN(nRoleId) or
		not CheckN(nPetId) or
		not CheckN(nItemId) or
		not CheckN(e) then
		return;
	end
	
	if not RolePetUser.IsExistPet(nRoleId, nPetId) then
		LogInfo("ItemPet p.AddItem[%d][%d] failed", nRoleId, nPetId);
		return;
	end
	
	_G.AddRoleDataId(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, e, nItemId);
end

function p.DelItem(nRoleId, nPetId, nItemId, e)
	if	not CheckN(nRoleId) or
		not CheckN(nPetId) or
		not CheckN(nItemId) or 
		not CheckN(e) then
		return;
	end
	
	if not RolePetUser.IsExistPet(nRoleId, nPetId) then
		LogInfo("ItemPet p.DelItem[%d][%d] failed", nRoleId, nPetId);
		return;
	end
	
	_G.DelRoleDataId(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, e, nItemId);
end

function p.GetItemList(nRoleId, nPetId, e)
	local idlist = {};
	if	not CheckN(nRoleId) or
		not CheckN(nPetId) or
		not CheckN(e) then
		return idlist;
	end
	
	if not RolePetUser.IsExistPet(nRoleId, nPetId) then
		LogInfo("ItemPet p.GetItemList[%d][%d] failed", nRoleId, nPetId);
		return;
	end
    
	idlist = _G.GetRoleDataIdTable(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, e);
	return idlist;
end

--获得武将品质
function p.GetPetQualityCCC4(nPetTypeId)
    return GetDataBaseDataN("pet_config", nPetTypeId, DB_PET_CONFIG.QUALITY);
end

--** 获得武将颜色 **--
function p.GetPetQuality(nPetId)
    LogInfo("ItemPet.GetPetQuality");
    local bIsMainPet = RolePetFunc.IsMainPet(nPetId);
    local cColor4;
    local nQuality;
    if(bIsMainPet) then
        --nQuality = GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_AUTO_EXERCISE);
        nQuality = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_QUALITY);
        LogInfo("chh_p.GetPetQuality nQuality:[%d]",nQuality);
    else
        local nPetTypeId = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
        nQuality = p.GetPetQualityCCC4(nPetTypeId);
    end
    
    LogInfo("ItemPet.GetPetQuality nQuality:[%d]",nQuality);
    cColor4 = p.GetQuality(nQuality);
    return cColor4;
end

function p.GetPetConfigQuality(nPetTypeId)
    local nQuality = p.GetPetQualityCCC4(nPetTypeId);
    local cColor4 = p.GetQuality(nQuality);
    return cColor4;
end

function p.SetLabelColor(label, nPetId) 
    if(label == nil) then
        LogInfo("p.SetLabelColor label is nil!");
        return;
    end
    label:SetFontColor(p.GetPetQuality(nPetId));
end

function p.SetLabelByQuality(label, nQuality)
    if(label == nil) then
        LogInfo("p.SetLabelByQuality label is nil!");
        return;
    end
    local cColor4 = p.GetQuality(nQuality);
    label:SetFontColor(cColor4);
end


function p.GetQuality(nQuality)
    local cColor4 = ItemColor[nQuality];
    if(cColor4 == nil) then
        cColor4 = ItemColor[0];
    end
    return cColor4;
end