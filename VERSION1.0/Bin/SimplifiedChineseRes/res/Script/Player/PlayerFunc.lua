
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


--取得玩家属性(返回number)
function p.GetUserAttr(nPlayerId, nIndex)
	if not CheckN(nPlayerId) or
		not CheckN(nIndex) then
		return 0;
	end
	
	return GetRoleBasicDataN(nPlayerId, nIndex);
end

--设置玩家属性
function p.SetUserAttr(nPlayerId, nIndex, val)
	if not CheckN(nPlayerId) or
		not CheckN(nIndex) then
		return 0;
	end
	
	return SetRoleBasicDataN(nPlayerId, nIndex, val);
end



-- 取得体力
function p.GetStamina(playerId)
	local rtn;
	if CheckN(playerId) then
		rtn = GetRoleBasicDataN(playerId, USER_ATTR.USER_ATTR_STAMINA);
	end
	return rtn;
end

function p.GetUserTotalStamina()
	local playerId = GetPlayerId();
	local st = p.GetStamina(playerId);
	local st2 = UserStateList.GetDatasByType(UserStateUI.STATE_CONFIG_STAMINA);
	return st + st2;
end

-- 阶段
function p.GetPlayerStage()
	local playerId = GetPlayerId();
	local rtn;
	if CheckN(playerId) then
		rtn = GetRoleBasicDataN(playerId, USER_ATTR.USER_ATTR_STAGE);
	end
	return rtn;
end

--阵营 1:黄泉， 2：羽化
function p.GetPlayerCamp()
	local playerId = GetPlayerId();
	local rtn;
	if CheckN(playerId) then
		rtn = GetRoleBasicDataN(playerId, USER_ATTR.USER_ATTR_CAMP);
	end
	if rtn == 0 then
		rtn = 1;
	end
	return rtn;
end



