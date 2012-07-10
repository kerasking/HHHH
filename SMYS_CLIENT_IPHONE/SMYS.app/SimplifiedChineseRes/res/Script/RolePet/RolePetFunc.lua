-------------------------------------------
---伙伴通用接口
---2012.3.16
---creator jhzheng
-------------------------------------------
local _G = _G;

RolePetFunc={}
local p=RolePetFunc;
local listPetLvlExp = {};

function p.GetPropDesc(nPetId, nIndex)
	local strRes	= "";
	if not CheckN(nPetId) or
		not CheckN(nIndex) then
		return strRes;
	end
	if not RolePet.IsExistPet(nPetId) then
		return strRes;
	end
	
	local nPetType = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);

	if nIndex == PET_ATTR.PET_ATTR_TYPE then
	--职业
		strRes	= ConvertS(GetDataBaseDataS("pet_config", nPetType, DB_PET_CONFIG.PRO_NAME));
	elseif nIndex == PET_ATTR.PET_ATTR_LEVEL then
	--等级
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	elseif nIndex == PET_ATTR.PET_ATTR_PHYSICAL then
	--武力
		strRes	= SafeN2S(RolePet.GetTotalPhy(nPetId));
	elseif nIndex == PET_ATTR.PET_ATTR_LIFE then
	--生命
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LIFE));
	elseif nIndex == PET_ATTR.PET_ATTR_SUPER_SKILL then
	--绝技
		strRes	= SafeN2S(RolePet.GetTotalSuperSkill(nPetId));
	elseif nIndex == PET_ATTR.PET_ATTR_SKILL then
	--技能
		local nSkillId = GetDataBaseDataN("pet_config", nPetType,DB_PET_CONFIG.SKILL);
		strRes	= GetDataBaseDataS("skill_config", nSkillId, DB_SKILL_CONFIG.NAME);
	elseif nIndex == PET_ATTR.PET_ATTR_MAGIC then
	--法术
		strRes	= SafeN2S(RolePet.GetTotalMagic(nPetId));
	elseif nIndex == PET_ATTR.PET_ATTR_NAME then
	--名字
		strRes	= ConvertS(RolePet.GetPetInfoS(nPetId, PET_ATTR.PET_ATTR_NAME));
	elseif nIndex == PET_ATTR.PET_ATTR_PHY_ATK then
	--普攻
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_PHY_ATK));
	elseif nIndex == PET_ATTR.PET_ATTR_PHY_DEF then
	--普防
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_PHY_DEF));
	elseif nIndex == PET_ATTR.PET_ATTR_MAGIC_ATK then
	--法攻
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK));
	elseif nIndex == PET_ATTR.PET_ATTR_MAGIC_DEF then
	--法防
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF));
	elseif nIndex == PET_ATTR.PET_ATTR_SKILL_ATK then
	--绝攻
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_SKILL_ATK));
	elseif nIndex == PET_ATTR.PET_ATTR_SKILL_DEF then
	--绝防
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_SKILL_DEF));
	elseif nIndex == PET_ATTR.PET_ATTR_DRITICAL then
	--暴击
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	elseif nIndex == PET_ATTR.PET_ATTR_TENACITY then
	--韧性
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	elseif nIndex == PET_ATTR.PET_ATTR_HITRATE then
	--命中
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	elseif nIndex == PET_ATTR.PET_ATTR_DODGE then
	--闪避
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	elseif nIndex == PET_ATTR.PET_ATTR_WRECK then
	--破击
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	elseif nIndex == PET_ATTR.PET_ATTR_BLOCK then
	--格档
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	elseif nIndex == PET_ATTR.PET_ATTR_HURT_ADD then
	--必杀
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	else 
		-- other .. todo
	end
	
	return strRes;
end

function p.IsMainPet(nPetId)
	if not CheckN(nPetId) then
		return false;
	end
	
	if 1 == ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_MAIN)) then
		return true;
	end
	
	return false;
end

function p.GetMainPetId(nRoleId)
	local idlist	= RolePetUser.GetPetListPlayer(nRoleId);
	if 0 == #idlist then
		return 0;
	end
	
	for i, v in ipairs(idlist) do
		if p.IsMainPet(v) then
			return v;
		end
	end
	
	return 0;
end

function p.GetNextLvlExp(nPetId)
	local nExp	= 0;
	
	if not CheckN(nPetId) or
		not RolePet.IsExistPet(nPetId) then
		return 0;
	end
	
	local nLvl = ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	
	if not listPetLvlExp[1] then
		p.LoadPetLvlExp();
	end
	return ConvertN(listPetLvlExp[nLvl+1]);
end

function p.LoadPetLvlExp()
	if listPetLvlExp[1] then
		return;
	end
	
	local idlist	= _G.GetDataBaseIdList("pet_levexp");
	if 0 >= #idlist then
		return;
	end

	for i, v in ipairs(idlist) do
		local nLvl	= _G.ConvertN(_G.GetDataBaseDataN("pet_levexp", v, DB_PET_LEVEXP.LEVEL));
		local nExp	= _G.ConvertN(_G.GetDataBaseDataN("pet_levexp", v, DB_PET_LEVEXP.EXP));
		listPetLvlExp[nLvl]	= nExp;
	end
end