
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


function GetNpcTaskList(nMatchNpcId)
	local idList	= {};
	local idNpcTask = _G.GetDataBaseIdList("task_npc");  
	--_G.LogInfoT(idNpcTask)
	
	for i,v  in ipairs(idNpcTask) do
		
		local nNpcId = _G.GetDataBaseDataN("task_npc",v,2);
		--LogInfo(nNpcId.."  "..nMatchNpcId)
		if nNpcId == nMatchNpcId then
			--LogInfo(nNpcId.."  "..nMatchNpcId.." ".._G.GetDataBaseDataN("task_npc",v,1))
 			table.insert(idList,_G.GetDataBaseDataN("task_npc",v,1));
		end
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
			_G.NavigateTo(nMapId, nX-1, nY+1);
		else
			mInNavigateState	= true;
			mNavigateMapId		= nMapId;
			mNavigateMapX		= nX-1;
			mNavigateMapY		= nY+1;
		
			--_G.WorldMapGoto(nMapId);
			
			_G.TaskUI.GotoPortal();						
			
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
			DelayNavigate()
			--_G.NavigateTo(mNavigateMapId, mNavigateMapX, mNavigateMapY);
			_G.LogInfo("npc OnEnterGameScene  reset state false");
			mInNavigateState	= false;
		end
	end
	
end

function OnMapSwitch()
	if mInNavigateState and 
		_G.CheckN(mNavigateMapId) and 
		_G.CheckN(mNavigateMapX) and 
		_G.CheckN(mNavigateMapY) then
		
		_G.WorldMapGoto(mNavigateMapId);
		return true;
	else	
		return false;
	end
end


--延迟寻路
mTimerTaskTag = nil;

function DelayNavigate()
	if (mTimerTaskTag) then
		_G.UnRegisterTimer(mTimerTaskTag);
		mTimerTaskTag = nil;
	end

	mTimerTaskTag = _G.RegisterTimer(NavigateFunc, 1);

end

function NavigateFunc()

	if (mTimerTaskTag) then
		_G.UnRegisterTimer(mTimerTaskTag);
		mTimerTaskTag = nil;
	end	
	_G.LogInfo("npc OnEnterGameScene delay navigate");
	_G.NavigateTo(mNavigateMapId, mNavigateMapX, mNavigateMapY);
	
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_GENERATE_GAMESCENE, "Npc.OnEnterGameScene", OnEnterGameScene);



































