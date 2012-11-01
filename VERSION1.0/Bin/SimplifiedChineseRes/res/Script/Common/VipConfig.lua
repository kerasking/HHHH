---------------------------------------------------
--描述: vip相关配置读取
--时间: 2012.4.15
--作者: wjl
---------------------------------------------------
VipConfig = {}
local f = VipConfig;

--白金培养等及
function f.getPlatinaTrainLevel()
	return 3;
end

--砖石培养等级
function f.getDiamondTrainLevel()
	return 5;
end

-- 至尊等级
function f.getImperialTrainLevel()
	return 6;
end

-- 培养的金币（2(加强)，3(白金)，4, 5）
function f.getTrainMoney(type)
	if (type == 2) then
		return 2;
	elseif (type == 3) then
		return 10;
	elseif (type == 4) then
		return 20;
	elseif (type == 5) then
		return 100;
	else 
		return 0;
	end
end

-- 重置副本vip 等级
function f.getResetEliteBoss()
	return 3;
end

