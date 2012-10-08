---------------------------------------------------
--描述: 统一宠物信息保存与获取
--时间: 2012.3.9
--作者: cl
---------------------------------------------------
local p = RolePet;
local POSITION_PLAYER	= 0;
local POSITION_DROPED	= 1;

function p.IsExistPet(nPetId)
	if not CheckN(nPetId) then
		LogInfo("p.IsExistPet invalid arg");
		return false;
	end
	local nPetId = RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_ID);
	if nPetId <= 0 then
		return false;
	end
	return true;
end

function p.IsInPlayer(nPetId)
	local nPos	= ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_POSITION));
	if nPos == POSITION_PLAYER then
		return true;
	end
	return false;
end

function p.SetPetInfoN(nPetId, nIndex, val)
	if	not CheckN(nPetId) or
		not CheckN(nIndex) or 
		not CheckN(val) then
		return;
	end
	_G.SetGameDataN(NScriptData.ePetInfo, nPetId, NRoleData.eBasic, 0, nIndex, val);
end

function p.SetPetInfoS(nPetId, nIndex, val)
	if	not CheckN(nPetId) or
		not CheckN(nIndex) or 
		not CheckS(val) then
		return;
	end
	_G.SetGameDataS(NScriptData.ePetInfo, nPetId, NRoleData.eBasic, 0, nIndex, val);
end

function p.GetPetInfoS(nPetId, nIndex)
	if	not CheckN(nPetId) or
		not CheckN(nIndex) then
		return "";
	end
	return _G.GetGameDataS(NScriptData.ePetInfo, nPetId, NRoleData.eBasic, 0, nIndex);
end

function p.GetPetInfoN(nPetId, nIndex)
	if	not CheckN(nPetId) or
		not CheckN(nIndex) then
		return 0;
	end
	return _G.GetGameDataN(NScriptData.ePetInfo, nPetId, NRoleData.eBasic, 0, nIndex);
end

function p.CountMedicineResult(v1,v2,v3,v4,v5,v6)
	local result=0;
	if v1>0 and v1<3 then
		result=result + 10*(v1+1)/2;
	end
	
	if v2>0 and v2<4 then
		result=result + (15+15-((v2-1)*5))*(v2)/2;
	end
	
	if v3>0 and v3<5 then
		result=result + (20+20-((v3-1)*5))*(v3)/2;
	end
	
	if v4>0 and v4<6 then
		result=result + (25+25-((v4-1)*5))*(v4)/2;
	end
	
	if v5>0 and v5<7 then
		result=result + (30+30-((v5-1)*5))*(v5)/2;
	end
	
	if v6>0 and v6<8 then
		result=result + (35+35-((v6-1)*5))*(v6)/2;
	end	
	return result;
end

function p.GetInheritMedPhy(nPetId)
	local v1=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR1)/2);
	local v2=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR2)/2);
	local v3=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR3)/2);
	local v4=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR4)/2);
	local v5=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR5)/2);
	local v6=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR6)/2);
	
	return p.CountMedicineResult(v1,v2,v3,v4,v5,v6);
end

function p.GetMedicinePhy(nPetId)
	local v1=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR1);
	local v2=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR2);
	local v3=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR3);
	local v4=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR4);
	local v5=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR5);
	local v6=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_ELIXIR6);
	
	return p.CountMedicineResult(v1,v2,v3,v4,v5,v6);
end

function p.GetTotalPhy(nPetId)
	return p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHYSICAL)+p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_PHY_FOSTER)+p.GetMedicinePhy(nPetId);
end

function p.GetInheritMedSuperSkill(nPetId)
	local v1=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR1)/2);
	local v2=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR2)/2);
	local v3=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR3)/2);
	local v4=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR4)/2);
	local v5=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR5)/2);
	local v6=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR6)/2);
		
	return p.CountMedicineResult(v1,v2,v3,v4,v5,v6);
end

function p.GetMedicineSuperSkill(nPetId)
	local v1=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR1);
	local v2=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR2);
	local v3=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR3);
	local v4=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR4);
	local v5=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR5);
	local v6=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_ELIXIR6);
		
	return p.CountMedicineResult(v1,v2,v3,v4,v5,v6);
end

function p.GetTotalSuperSkill(nPetId)
	return p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL)+p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER)+p.GetMedicineSuperSkill(nPetId);
end

function p.GetInheritMedMagic(nPetId)
	local v1=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR1)/2);
	local v2=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR2)/2);
	local v3=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR3)/2);
	local v4=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR4)/2);
	local v5=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR5)/2);
	local v6=getIntPart(p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR6)/2);
	
	return p.CountMedicineResult(v1,v2,v3,v4,v5,v6);
end

function p.GetMedicineMagic(nPetId)
	local v1=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR1);
	local v2=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR2);
	local v3=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR3);
	local v4=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR4);
	local v5=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR5);
	local v6=p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_ELIXIR6);
	
	return p.CountMedicineResult(v1,v2,v3,v4,v5,v6);
end

function p.GetTotalMagic(nPetId)
	return p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC)+p.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_MAGIC_FOSTER)+p.GetMedicineMagic(nPetId);
end



function p.DelPetInfo(nPetId)
	if	not CheckN(nPetId) then
		return;
	end
	
	_G.DelRoleGameDataById(NScriptData.ePetInfo, nPetId);
end

function p.LogOutPet(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	_G.DumpGameData(NScriptData.ePetInfo, nPetId, NRoleData.eBasic, 0);
end