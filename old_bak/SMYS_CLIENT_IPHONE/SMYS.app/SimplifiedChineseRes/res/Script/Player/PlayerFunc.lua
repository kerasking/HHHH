
---------------------------------------------------
--描述: 玩家通用接口
--时间: 2012.3.8
--作者: jhzheng
---------------------------------------------------

PlayerFunc = {};
local p = PlayerFunc;

function p.GetJob(nPlayerId)
	if not CheckN(nPlayerId) then
		return PROFESSION_TYPE.NONE;
	end
	
	return GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_PROFESSION);
end

function p.GetJobDesc(nJob)
	if not CheckN(nJob) then
		return "";
	end
	
	if nJob == PROFESSION_TYPE.SWORD then
		return "剑圣";
	elseif nJob == PROFESSION_TYPE.CHIVALROUS then
		return "奇侠";
	elseif nJob == PROFESSION_TYPE.FIST then
		return "拳宗";
	elseif nJob == PROFESSION_TYPE.AXE then
		return "斧皇";
	elseif nJob == PROFESSION_TYPE.MAGIC then
		return "玄灵";
	end
	return "";
end

function p.GetAttrDesc(nPlayerId, nIndex)
	local strRes	= "";
	if not CheckN(nPlayerId) or
		not CheckN(nIndex) then
		LogInfo("PlayerFunc.GetAttrDesc invalid arg");
		return strRes;
	end
	if nIndex == USER_ATTR.USER_ATTR_NAME then
		strRes	= GetRoleBasicDataS(nPlayerId, USER_ATTR.USER_ATTR_NAME);
	elseif nIndex == USER_ATTR.USER_ATTR_PROFESSION then
		strRes	= p.GetJobDesc(p.GetJob(nPlayerId));
	elseif nIndex == USER_ATTR.USER_ATTR_LEVEL then
		strRes	= SafeN2S(GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_LEVEL));
	elseif nIndex == USER_ATTR.USER_ATTR_LIFE then
		strRes	= SafeN2S(GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_LIFE));
	end
	
	return strRes;
end

function p.GetBagGridNum(nPlayerId)
	if not CheckN(nPlayerId) then
		return 0;
	end
	
	return GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_PACKAGE_LIMIT);
end