-------------------------------------------
---伙伴通用接口
---2012.3.16
---creator jhzheng
-------------------------------------------
local _G = _G;

RolePetFunc={}
local p=RolePetFunc;
local listPetLvlExp = {};

function p.GetLookFace(nPetId)
	if not RolePet.IsExistPet(nPetId) then
		return 0;
	end
	
	local nPetType = ConvertN(RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE));
	
	return ConvertN(GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.LOCKFACE));
end

function p.GetPropDesc(nPetId, nIndex)
	--LogInfo("rolepetfunc: 1");
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
	elseif nIndex == PET_ATTR.PET_ATTR_DEX then
	--敏捷
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_DEX));		
	elseif nIndex == PET_ATTR.PET_ATTR_SPEED then
	--速度
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_SPEED));
	elseif nIndex == PET_ATTR.PET_ATTR_LEVEL then
	--等级
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	elseif nIndex == PET_ATTR.PET_ATTR_PHYSICAL then
	--武力
		strRes	= SafeN2S(RolePet.GetTotalPhy(nPetId));
	elseif nIndex == PET_ATTR.PET_ATTR_LIFE then
	--生命
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LIFE));
	elseif nIndex == PET_ATTR.PET_ATTR_LIFE_LIMIT then
	--生命上限
		strRes	= SafeN2S(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_LIFE_LIMIT));
	elseif nIndex == PET_ATTR.PET_ATTR_SUPER_SKILL then
	--绝技
		strRes	= SafeN2S(RolePet.GetTotalSuperSkill(nPetId));
	elseif nIndex == PET_ATTR.PET_ATTR_SKILL then
	--技能
		--** chh 2012-07-21 **--
        local nSkillId = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_SKILL);
        --local nSkillId = GetDataBaseDataN("pet_config", nPetType,DB_PET_CONFIG.SKILL);
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
	elseif nIndex == PET_ATTR.PET_ATTR_TEST then
		-- other .. todo
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";
	elseif nIndex == PET_ATTR.PET_ATTR_HELP then
		local nVal	= RolePet.GetPetInfoN(nPetId, nIndex);
		strRes	= tostring(GetNumDot(nVal / 10, 1)) .. "%";		
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
	--return ConvertN(listPetLvlExp[nLvl+1]);
    return ConvertN(listPetLvlExp[nLvl]);
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



---------------------------------------------------
--++Guoen 2012.7.19
-- 获得可重置次数值
function p.GetResetNumber( nCampaignID )
	local nPlayerVIPLv	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
    
	if ( GetGetVipLevel_ELITE_MAP_RESET_NUM()<=0 ) then
		return 0;
	end
    
    
	local nResetCount	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_INSTANCING_RESET_COUNT );	--已重置次数

    nResetCount = ConvertReset(nResetCount, nCampaignID);
    
    
    local nResetLimit   = GetVipVal(DB_VIP_CONFIG.ELITE_MAP_RESET_NUM);
    --[[
    local nResetLimit	= 1;	-- 限制的重置次數( 3~4:1, 5~xxx:2 )
	if ( nPlayerVIPLv > 5 ) then
		nResetLimit		= 2;
	end
    ]]
    
	local nResetNumber	= nResetLimit - nResetCount;
	if ( nResetNumber < 0 ) then
		nResetNumber	= 0;
	end
	return nResetNumber;
end




--** chh 2012-07-31 **--
function p.GetJobDesc(nJob)
    LogInfo("nJob:[%d]",nJob);
	if not CheckN(nJob) then
		return "";
	end
	if nJob == PROFESSION_TYPE.SWORD then
		return '猛将';
	elseif nJob == PROFESSION_TYPE.CHIVALROUS then
		return '射手';
	elseif nJob == PROFESSION_TYPE.FIST then
		return '军师';
	elseif nJob == PROFESSION_TYPE.AXE then
		return '守将';
	end
	return '不限';
end


function p.GetStandDesc(nStand)
    if not CheckN(nStand) then
		return "";
	end
    
    if nStand == STAND_TYPE.FIR then
		return GetTxtPub("Fir");
	elseif nStand == STAND_TYPE.SEC then
		return GetTxtPub("Sec");
	elseif nStand == STAND_TYPE.THIRD then
		return GetTxtPub("Third");
	end
    
    return "";
end











