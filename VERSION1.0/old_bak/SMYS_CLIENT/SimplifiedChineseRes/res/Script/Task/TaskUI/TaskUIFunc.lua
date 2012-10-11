local p = TaskUI;

local MONSTER_TASK_DATA =
{
	TYPE			= 1,
	ID				= 2,
	NAME			= 3,
	TRANS			= 4,
	DATA			= 5,
	NUM				= 6,
	MAPID			= 7,
	MAPNAME			= 8,
	MAPX			= 9,
	MAPY			= 10,
	TIP				= 11
};

local NPC_TASK_DATA =
{
	TYPE			= 1,
	ID				= 2,
	NAME			= 3,
	MAPID			= 4,
	MAPNAME			= 5,
	MAPX			= 6,
	MAPY			= 7,
	TIP				= 8
};

local mInGoToState			= false;
local mInGoToStateSwitch	= false;
local mGoToDynMapId			= 0;
local mGoToDestMapId		= 0;
local mPassWayIndex			= 0;

--进入切屏点的状态
local state                 = 0;

--获取任务数据进度字符串(例如:5/8)
function p.GetTaskDataProcessStr(nTaskId, nIndex)
	local retStr = "";
	local cellDatas = p.GetTaskConfigData(nTaskId, nIndex);
	if 0 == table.getn(cellDatas) then
		LogInfo("p.GetTaskDataProcessStr has not config[%d][%d]", nTaskId, nIndex);
		return retStr;
	end
	
	local nContenType = ConvertN(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_TYPE]);
	if nContenType == TASK.SM_TASK_CONTENT_TYPE.MONSTER then
		retStr = TASK.GetTaskMonsterDataProgressStr(nTaskId, cellDatas[TASK_CEL_DATA.SM_TASK_CELL_ID]);
	elseif nContenType == TASK.SM_TASK_CONTENT_TYPE.ITEM then
		retStr = TASK.GetTaskItemDataProgressStr(nTaskId, cellDatas[TASK_CEL_DATA.SM_TASK_CELL_ID]);
	elseif nContenType == TASK.SM_TASK_CONTENT_TYPE.NPC then
	end
	return retStr;
end

function p.GetTaskDataTip(nTaskId, nIndex)
	local cellDatas = p.GetTaskConfigData(nTaskId, nIndex);
	if not CheckT(cellDatas) or 0 == table.getn(cellDatas) then
		LogInfo("p.GetTaskDataTip null");
		return "";
	end
	
	return ConvertS(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_TIP]);
end

function p.DealTaskData(nTaskId, nIndex)
	local cellDatas = p.GetTaskConfigData(nTaskId, nIndex);
	if 0 == table.getn(cellDatas) then
		LogInfo("p.DealTaskData no data");
		return ;
	end
		
	local nId		= ConvertN(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_ID]);
	local nMapId	= ConvertN(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_MAP_ID]);
	--local nCurMapId	= ConvertN(_G.GetMapId());
	--local bTrans	= ConvertN(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_CAN_TRANS]);
	local nContenType = ConvertN(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_TYPE]);
	if nContenType == TASK.SM_TASK_CONTENT_TYPE.NPC then
		NPC.Navigate(nId);
		return;
	elseif nContenType == TASK.SM_TASK_CONTENT_TYPE.MONSTER or 
			nContenType == TASK.SM_TASK_CONTENT_TYPE.ITEM then
		--local nMapX	= ConvertN(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_MAP_X]);
		--local nMapY	= ConvertN(cellDatas[TASK_CEL_DATA.SM_TASK_CELL_MAP_Y]);
		p.GoToDynMap(nMapId);
	end
end

function p.GetTaskConfigData(nTaskId, nIndex)
	local cellDatas = {};
	if not CheckN(nTaskId) or not CheckN(nIndex) then
		LogInfo("p.GetTaskConfigData invalid arg");
		return cellDatas;
	end
	
	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_TYPE] = 
	GetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_TYPE);

	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_ID] = 
	GetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_ID);

	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_MAP_ID] =
	GetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_MAP_ID);

	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_MAP_X] = 
	GetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_MAP_X);

	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_MAP_Y] = 
	GetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_MAP_Y);

	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_NUM] = 
	GetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_NUM);

	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_CAN_TRANS] = 
	GetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_CAN_TRANS);

	cellDatas[TASK_CEL_DATA.SM_TASK_CELL_TIP] = 
	GetGameDataS(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_TIP);

	return cellDatas;
end

function p.SetTaskCellData(nTaskId, celldatas, nIndex)
	if nil == celldatas and 0 == table.getn(celldatas) then
		LogInfo("p.SetTaskCellData invalid index1");
		return;
	end

	if not CheckN(nTaskId) or not CheckN(nIndex) then
		LogInfo("p.SetTaskCellData invalid index2");
		return;
	end

	local strtype = celldatas[1];
	if type(strtype) ~= "string" then
		return;
	end
	
	local nType			= TASK.SM_TASK_CONTENT_TYPE.NONE;
	local nId			= nil;
	local nMapId		= nil;
	local nMapX			= nil;
	local nMapY			= nil;
	local nNum			= nil;
	local bCanTrans		= nil;
	local strTip		= nil;
	if "mon" == strtype or "item" == strtype then
		if "mon" == strtype then
			nType		= TASK.SM_TASK_CONTENT_TYPE.MONSTER;
		else
			nType		= TASK.SM_TASK_CONTENT_TYPE.ITEM;
		end
		nId				= celldatas[MONSTER_TASK_DATA.ID];
		bCanTrans		= celldatas[MONSTER_TASK_DATA.TRANS];
		nNum			= celldatas[MONSTER_TASK_DATA.NUM];
		nMapId			= celldatas[MONSTER_TASK_DATA.MAPID];
		nMapX			= celldatas[MONSTER_TASK_DATA.MAPX];
		nMapY			= celldatas[MONSTER_TASK_DATA.MAPY];
		strTip			= celldatas[MONSTER_TASK_DATA.TIP];
	elseif "npc" == strtype then
		nType			= TASK.SM_TASK_CONTENT_TYPE.NPC;
		nId				= celldatas[NPC_TASK_DATA.ID];
		nMapId			= celldatas[NPC_TASK_DATA.MAPID];
		nMapX			= celldatas[NPC_TASK_DATA.MAPX];
		nMapY			= celldatas[NPC_TASK_DATA.MAPY];
		strTip			= celldatas[NPC_TASK_DATA.TIP];
	end
	
	if TASK.SM_TASK_CONTENT_TYPE.NONE == nType or nil == nId or nil == nMapId then
		LogInfo("SET TASK CONFIG invalid taskid[%d]", nTaskId);
		return;
	end
	
	strTip			= strTip or "";
	
	SetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_TYPE, ConvertN(nType));
	SetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_ID, SafeS2N(nId));
	SetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_MAP_ID, SafeS2N(nMapId));
	SetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_MAP_X, SafeS2N(nMapX));
	SetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_MAP_Y, SafeS2N(nMapY));
	SetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_NUM, SafeS2N(nNum));
	SetGameDataN(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_CAN_TRANS, SafeS2N(bCanTrans));
	SetGameDataS(NScriptData.eTaskConfig, nTaskId, NRoleData.ePet, nIndex, TASK_CEL_DATA.SM_TASK_CELL_TIP, strTip);
	
	LogInfo("[%d],[%d],[%d],[%d]",
			nTaskId, SafeS2N(nMapId), SafeS2N(nMapX), SafeS2N(nMapY));
end

function p.GenerateContent(nTaskId)
	local strContent = GetDataBaseDataS("task_type", nTaskId, DB_TASK_TYPE.CONTENT);
	if nil == strContent or "" == strContent then
		LogInfo("p.GenerateContent content null");
		return false;
	end
	
	local cells = TASK.GetTaskContent(strContent);
	if nil == cells or 0 == table.getn(cells) then
		LogInfo("p.GenerateContent[%s] cells null", strContent);
		return false;
	end

	for i, v in ipairs(cells) do
		local strCelldata = string.gsub(v, "%[?]?", "");
		local celldatas = TASK.GetTaskContentCell(strCelldata);
		p.SetTaskCellData(nTaskId, celldatas, i - 1);
	end
	
	return true;
end

function p.DelContent(nTaskId)
	if not CheckN(nTaskId) then
		return;
	end
	
	_G.DelRoleGameDataById(NScriptData.eTaskConfig, nTaskId);
end

function p.GoToDynMap(nMapId,nState)
	if not CheckN(nMapId) then
		return;
	end
	if CheckN(nState) then
	    state = nState;
	end
	
	
	local nGotoMap	= 0;
	if not AffixBossFunc.IsDynMap(nMapId) then
		LogInfo("GoToDynMap id[%d] not dynmap", nMapId);
	else
		--获取去该副本的nDesMapId, passwayindex
		LogInfo("p.GoToDynMap DynMap[%d]", nMapId);
		local nDesMapId, nPassWayIndex	= AffixBossFunc.GetDynMapPassWay(nMapId);
		LogInfo("p.GoToDynMap nDesMapId[%d], nPassWayIndex[%d]", nDesMapId, nPassWayIndex);
		
		if nDesMapId == _G.GetMapId() then
			--在当前地图
			local nCellX, nCellY	= AffixBossFunc.GetMapPortal(nDesMapId, nPassWayIndex);
			if CheckN(nCellX) and CheckN(nCellY) and 0 ~= nCellX and 0 ~= nCellY then
				mInGoToState		= false;
				mInGoToStateSwitch	= true;
				mPassWayIndex		= nPassWayIndex;
				mGoToDynMapId		= nMapId;
				_G.NavigateTo(nDesMapId, nCellX, nCellY);
			end
			return;
		end
		
		if CheckN(nDesMapId) and CheckN(nPassWayIndex) and 0 < nDesMapId then
			mInGoToState		= true;
			mInGoToStateSwitch	= false;
			mGoToDynMapId		= nMapId;
			mGoToDestMapId		= nDesMapId;
			mPassWayIndex		= nPassWayIndex;
			WorldMapGoto(nDesMapId);
			LogInfo("TaskUI WorldMapGoto[%d]", nMapId);
		end
	end
end

function p.OnEnterGameScene()
	_G.LogInfo("TaskUI OnEnterGameScene");
	
	local nCurMapId			= ConvertN(_G.GetMapId());

	if mInGoToState and mGoToDestMapId == nCurMapId and _G.CheckN(mPassWayIndex) then
		local nCellX, nCellY	= AffixBossFunc.GetMapPortal(nCurMapId, mPassWayIndex);
		LogInfo("p.OnEnterGameScene nCurMapId[%d][%d]nCellX[%d]nCellY[%d]", nCurMapId, mPassWayIndex, nCellX, nCellY);
		if CheckN(nCellX) and CheckN(nCellY) and 0 ~= nCellX and 0 ~= nCellY then
			_G.NavigateTo(nCurMapId, nCellX, nCellY);
			mInGoToStateSwitch	= true;
		end
	end
	
	if not mInGoToState then
		mInGoToStateSwitch	= false;
	end
	
	mInGoToState	= false;
	state = 0;
end

function p.OnMapSwitch(nSwitchIndex)
	_G.LogInfo("TaskUI OnMapSwitch");
	
	if not CheckN(nSwitchIndex) then
		return;
	end
	
	if mInGoToStateSwitch and (not mInGoToState) and  nSwitchIndex == mPassWayIndex then
		if not IsUIShow(NMAINSCENECHILDTAG.AffixNormalBoss) then
			_G.LogInfo("task goto dyn map[%d]", mGoToDynMapId);
			_G.CloseMainUI();
			NormalBossListUI.LoadUIByBossId(mGoToDynMapId);
		end
	else
		if not IsUIShow(NMAINSCENECHILDTAG.AffixNormalBoss) then
		   _G.CloseMainUI();
		   if state == 1 then
		      NormalBossListUI.LoadUIByBossId(mGoToDynMapId,1);
		   else
		      NormalBossListUI.LoadUIBySwitch(_G.GetMapId(), nSwitchIndex); 
		   end
		end
	end
	state = 0;
	
	mInGoToState		= false;
	mInGoToStateSwitch	= false;
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_GENERATE_GAMESCENE, "TaskUI.OnEnterGameScene", p.OnEnterGameScene);
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_SWITCH, "TaskUI.OnMapSwitch", p.OnMapSwitch);