
local _G = _G;
setfenv(1, NPC);

local mInNavigateState	= false;
local mNavigateMapId	= 0;
local mNavigateMapX		= 0;
local mNavigateMapY		= 0;

--游戏数据与DB数据接口
function GetDataBaseN(nNpcId, e)
	return _G.ConvertN(_G.GetDataBaseDataN("npc", nNpcId, e));
end

function GetDataBaseS(nNpcId, e)
	return _G.ConvertS(_G.GetDataBaseDataS("npc", nNpcId, e));
end

function GetGameDataN(nNpcId, e)
	local nVal = _G.GetGameDataN(NScriptData.eNpc, nNpcId, NRoleData.eBasic, 0, e);
	return nVal;
end

function GetGameDataS(nNpcId, e)
	local szVal = _G.GetGameDataS(NScriptData.eNpc, nNpcId, NRoleData.eBasic, 0, e);
	return szVal;
end

function SetGameDataN(nNpcId, e, nVal)
	_G.SetGameDataN(NScriptData.eNpc, nNpcId, NRoleData.eBasic, 0, e, nVal);
end

function SetGameDataS(nNpcId, e, szVal)
	_G.SetGameDataS(NScriptData.eNpc, nNpcId, NRoleData.eBasic, 0, e, szVal);
end

function DelGameData()
	_G.DelRoleGameData(NScriptData.eNpc);
end

function DelGameDataById(nNpcId)
	_G.DelRoleGameDataById(NScriptData.eNpc, nNpcId);
end
--游戏数据与DB数据接口 end

function GetNpcName(nNpcId)
	return GetDataBaseS(nNpcId, DB_NPC.NAME);
end

function GetNpcTaskList(nNpcId)
	local idList	= {};
	
	local nTask		= GetDataBaseN(nNpcId, DB_NPC.TASK0);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK1);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK2);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK3);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK4);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK5);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK6);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK7);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK8);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	nTask			= GetDataBaseN(nNpcId, DB_NPC.TASK9);
	if 0 < nTask then
		table.insert(idList, nTask);
	end
	
	return idList;
end

function SendOption(nNpcId, nAction)
	MsgNpc.SendOpt(nNpcId, nAction)
end

function getMapId(nNpcId)
	if not _G.CheckN(nNpcId) then
		return;
	end
	local nMapId	= GetDataBaseN(nNpcId, DB_NPC.MAPID);
	return nMapId;
end


function Navigate(nNpcId)
	if not _G.CheckN(nNpcId) then
		return;
	end
	local nMapId	= GetDataBaseN(nNpcId, DB_NPC.MAPID);
	local nX		= GetDataBaseN(nNpcId, DB_NPC.CELLX);
	local nY		= GetDataBaseN(nNpcId, DB_NPC.CELLY);
	LogInfo("nMapId[%d]nX[%d]nY[%d]", nMapId, nX, nY);
	
	if _G.CheckN(nMapId) and _G.CheckN(nX) and _G.CheckN(nY) then
		if nMapId == _G.GetMapId() then
			_G.NavigateTo(nMapId, nX, nY);
		else
			mInNavigateState	= true;
			mNavigateMapId		= nMapId;
			mNavigateMapX		= nX;
			mNavigateMapY		= nY;
			_G.WorldMapGoto(nMapId);
		end
	end
end

function OnEnterGameScene()
	_G.LogInfo("npc OnEnterGameScene");
	
	if mInNavigateState and 
		_G.CheckN(mNavigateMapId) and 
		_G.CheckN(mNavigateMapX) and 
		_G.CheckN(mNavigateMapY) then
		if mNavigateMapId == _G.GetMapId() then
			_G.NavigateTo(mNavigateMapId, mNavigateMapX, mNavigateMapY);
		end
	end
	
	mInNavigateState	= false;
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_GENERATE_GAMESCENE, "Npc.OnEnterGameScene", OnEnterGameScene);