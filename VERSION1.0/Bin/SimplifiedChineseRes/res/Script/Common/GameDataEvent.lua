---------------------------------------------------
--描述: 脚本游戏数据事件处理
--时间: 2012.3.16
--作者: jhzheng
---------------------------------------------------

GameDataEvent = {};
local p = GameDataEvent;

p.EventTable = {};

function p.Register(nEvent, sTip, func)
	if not CheckN(nEvent) or not CheckFunc(func) then
		LogInfo("GameDataEvent.Register[%d] invalid arg", nEvent);
		return;
	end
	
	if not p.EventTable[nEvent] then
		p.EventTable[nEvent] = {};
	end
	
	for i, v in ipairs(p.EventTable[nEvent]) do
		if v == func then
			LogInfo("GameDataEvent.Register[%d] repeat", nEvent);
			return;
		end
	end
	
	table.insert(p.EventTable[nEvent], func);
	
	if CheckS(sTip) then
		LogInfo("script Register GameDataEvent [%s] sucess!", sTip);
	end
end

function p.UnRegister(nEvent, func)
	if not CheckN(nEvent) or CheckFunc(func) then
		LogInfo("GameDataEvent.UnRegister[%d] invalid arg", nEvent);
		return;
	end
	
	if not p.EventTable[nEvent] then
		LogInfo("GameDataEvent.UnRegister[%d] failed", nEvent);
		return;
	end
	
	for i, v in ipairs(p.EventTable[nEvent]) do
		if v == func then
			p.EventTable[nEvent][i] = nil;
			break;
		end
	end
end

function p.OnEvent(nEvent, param)
	if not CheckN(nEvent) then
		LogError("GameDataEvent.OnEvent invalid arg");
		return;
	end
	
	if not p.EventTable[nEvent] then
		LogInfo("GameDataEvent.OnEvent[%d] no func", nEvent);
		return;
	end
	
	for i, v in pairs(GAMEDATAEVENT) do
		if v == nEvent and CheckS(i) then
			LogInfo("GameDataEvent.OnEvent[%s]", i);
			break;
		end
	end
	
	for i, v in pairs(p.EventTable[nEvent]) do
		v(param);
	end
end