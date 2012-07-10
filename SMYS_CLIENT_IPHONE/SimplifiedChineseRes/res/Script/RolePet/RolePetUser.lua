---------------------------------------------------
--描述: 玩家宠物
--时间: 2012.3.9
--作者: cl

---------------------------------------------------
RolePetUser = {};
local p = RolePetUser;


function p.AddPet(nRoleId, nPetId)
	if	not CheckN(nRoleId) or
		not CheckN(nPetId) then
		return;
	end 
	
	_G.AddRoleDataId(NScriptData.eRole, nRoleId, NRoleData.ePet, 0, 0, nPetId);
end

function p.DelPet(nRoleId, nPetId)
	if	not CheckN(nRoleId) or
		not CheckN(nPetId) then
		return;
	end
	
	_G.DelRoleDataId(NScriptData.eRole, nRoleId, NRoleData.ePet, 0, 0, nPetId);
end

function p.IsExistPet(nRoleId, nPetId)
	if	not CheckN(nRoleId) or
		not CheckN(nPetId) then
		return false;
	end
	local idlist	= p.GetPetList(nRoleId);
	for i, v in ipairs(idlist) do
		if v == nPetId then
			return true;
		end
	end
	return false;
end

function p.GetPetList(nRoleId)
	local idlist = {};
	if	not CheckN(nRoleId) then
		return idlist;
	end
	
	
	idlist = _G.GetRoleDataIdTable(NScriptData.eRole, nRoleId, NRoleData.ePet, 0, 0);
	if not CheckT(idlist) then
		idlist	= {};
	end
	return idlist;
end

function p.GetPetListPlayer(nRoleId)
	local idlist = p.GetPetList(nRoleId);
	local retlist	= {};
	for i, v in ipairs(idlist) do
		if RolePet.IsInPlayer(v) then
			table.insert(retlist, v);
		end
	end
	return retlist;
end