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