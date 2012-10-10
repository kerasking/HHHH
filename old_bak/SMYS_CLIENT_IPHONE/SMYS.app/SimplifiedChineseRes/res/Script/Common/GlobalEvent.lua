---------------------------------------------------
--描述: 脚本全局事件
--时间: 2012.3.5
--作者: jhzheng
---------------------------------------------------

GlobalEvent = {};
local p = GlobalEvent;

p.EventTable = {};

function p.Register(nEvent, sTip, func)
	if not CheckN(nEvent) or not CheckFunc(func) then
		LogInfo("GlobalEvent.Register[%d] invalid arg", nEvent);
		return;
	end
	
	if not p.EventTable[nEvent] then
		p.EventTable[nEvent] = {};
	end
	
	for i, v in ipairs(p.EventTable[nEvent]) do
		if v == func then
			LogInfo("GlobalEvent.Register[%d] repeat", nEvent);
			return;
		end
	end
	
	table.insert(p.EventTable[nEvent], func);
	
	if CheckS(sTip) then
		LogInfo("script Register GlobalEvent [%s] sucess!", sTip);
	end
end

function p.UnRegister(nEvent, func)
	if not CheckN(nEvent) or CheckFunc(func) then
		LogInfo("GlobalEvent.UnRegister[%d] invalid arg", nEvent);
		return;
	end
	
	if not p.EventTable[nEvent] then
		LogInfo("GlobalEvent.UnRegister[%d] failed", nEvent);
		return;
	end
	
	for i, v in ipairs(p.EventTable[nEvent]) do
		if v == func then
			p.EventTable[nEvent][i] = nil;
			break;
		end
	end
end

function p.OnEvent(nEvent, nParam1, nParam2, nParam3)
	if not CheckN(nEvent) then
		return;
	end
	
	if not p.EventTable[nEvent] then
		return;
	end
	
	for i, v in pairs(p.EventTable[nEvent]) do
		v(nParam1, nParam2, nParam3);
	end
end