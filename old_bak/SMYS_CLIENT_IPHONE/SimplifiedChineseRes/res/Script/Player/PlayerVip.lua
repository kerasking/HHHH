---------------------------------------------------
--描述: User vip相关读取
--时间: 2012.4.15
--作者: wjl
---------------------------------------------------
PlayerVip = {}
local f = PlayerVip;

function f.getVip()
	local playerId = GetPlayerId();
	return GetRoleBasicDataN(playerId, USER_ATTR.USER_ATTR_VIP_RANK);
end

--白金培养等及
function f.hasPlatinaTrain()
	return f.getVip() >= VipConfig.getPlatinaTrainLevel();
end

--砖石培养等级
function f.hasDiamondTrain()
	return f.getVip() >= VipConfig.getDiamondTrainLevel();
end

-- 至尊等级
function f.hasImperialTrain()
	return f.getVip() >= VipConfig.getImperialTrainLevel();
end

-- 重置副本
function f.hasResetEliteBoss()
	return f.getVip() >= VipConfig.getResetEliteBoss();
end