
local _G = _G;
setfenv(1, TASK);

--游戏数据与DB数据接口
function GetDataBaseN(nTaskId, e)
	return _G.ConvertN(GetDataBaseDataN("task_type", nTaskId, e));
end

function GetDataBaseS(nTaskId, e)
	return _G.ConvertS(GetDataBaseDataS("task_type", nTaskId, e));
end

function GetGameDataN(nTaskId, e)
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	local nVal = _G.GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eTask, nTaskId, e);
	return nVal;
end

function GetGameDataS(nTaskId, e)
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	local szVal = _G.GetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eTask, nTaskId, e);
	return szVal;
end

function SetGameDataN(nTaskId, e, nVal)
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	_G.SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eTask, nTaskId, e, nVal);
end

function SetGameDataS(nTaskId, e, szVal)
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	_G.SetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eTask, nTaskId, e, szVal);
end

function DelGameData()
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	_G.DelRoleSubGameData(NScriptData.eRole, nRoleId, NRoleData.eTask);
end
function DelGameDataById(nTaskId)
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	_G.DelRoleSubGameDataById(NScriptData.eRole, nRoleId, NRoleData.eTask, nTaskId);
end
--游戏数据与DB数据接口 end

function ClearCanAcceptTasks()
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	_G.DelRoleSubGameData(NScriptData.eRole, nRoleId, NRoleData.eTaskCanAccept);
end

function AddCanAcceptTask(nTaskId)
	local nRoleId = _G.ConvertN(_G.GetPlayerId());
	_G.SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eTaskCanAccept, nTaskId, 0, nTaskId);
end

-- 创建任务
-- 用于服务端下发创建任务时调用
function CreateTask(nTaskId, nState, nData1, nData2, nData3, nData4, nData5, nData6)
	if not CheckN(nTaskId) then
		return;
	end
	
	if CheckTaskCanFinish(nTaskId) then
		LogInfo("CreateTask finish");
		nState = SM_TASK_STATE.STATE_COMPLETE;
	end
	
	SetGameDataN(nTaskId, TASK_DATA.ID, ConvertN(nTaskId));
	SetGameDataN(nTaskId, TASK_DATA.TASK_STATE, ConvertN(nState));
	SetGameDataN(nTaskId, TASK_DATA.DATA1, ConvertN(nData1));
	SetGameDataN(nTaskId, TASK_DATA.DATA2, ConvertN(nData2));
	SetGameDataN(nTaskId, TASK_DATA.DATA3, ConvertN(nData3));
	SetGameDataN(nTaskId, TASK_DATA.DATA4, ConvertN(nData4));
	SetGameDataN(nTaskId, TASK_DATA.DATA5, ConvertN(nData5));
	SetGameDataN(nTaskId, TASK_DATA.DATA6, ConvertN(nData6));
	_G.TaskUI.GenerateContent(nTaskId);
end

-- 删除任务
-- 用于服务端下发完成了某个任务时调用
function DelTaskData(nTaskId)
	if not CheckN(nTaskId) then
		return;
	end
	DelGameDataById(nTaskId);
	_G.TaskUI.DelContent(nTaskId);
end

-- 获取可接任务id列表
function GetCanAcceptTasks()
	local nRoleId	= _G.ConvertN(_G.GetPlayerId());
	local idlist	= _G.GetGameDataIdList(NScriptData.eRole, nRoleId, NRoleData.eTaskCanAccept);
	idlist			= idlist or {};
	return idlist;
end

-- 获取已接任务id列表(包括已接已完成与已接未完成)
function GetAcceptTasks()
	local nRoleId	= _G.ConvertN(_G.GetPlayerId());
	local idlist	= _G.GetGameDataIdList(NScriptData.eRole, nRoleId, NRoleData.eTask);
	idlist			= idlist or {};
	return idlist;
end

-- 获取已接已完成任务id列表
function GetCanCompleteTaskList()
	local idlistRes = {};
	local idlistAccipt		= GetAcceptTasks();
	for i, v in ipairs(idlistAccipt) do
		if GetTaskState(v) == SM_TASK_STATE.STATE_COMPLETE then
			table.insert(idlistRes, v);
		end
	end
	return idlistRes;
end

-- 获取已接未完成任务id列表
function GetUnCompleteTaskList()
	local idlistRes = {};
	local idlistAccipt		= GetAcceptTasks();
	for i, v in ipairs(idlistAccipt) do
		LogInfo("task state[%d]", GetTaskState(v));
		if GetTaskState(v) == SM_TASK_STATE.STATE_UNCOMPLETE then
			table.insert(idlistRes, v);
		end
	end
	return idlistRes;
end

-- 过滤传入的任务id列表,返回可完成的任务id列表
function FilterTaskCanComplete(idlistTask)
	local idlistRes			= {};
	if not CheckT(idlistTask) then
		return idlistRes;
	end
	
	local idlistComplete		= GetCanCompleteTaskList();
	for i, v in ipairs(taskList) do
		for m, n in ipairs(idlistComplete) do
			if n == v then
				table.insert(idlistRes, v);
				break;
			end
		end
	end
end

function GetTaskState(nTaskId)
	return GetGameDataN(nTaskId, _G.TASK_DATA.TASK_STATE);
end

function GetTaskName(nTaskId)
	return GetDataBaseS(nTaskId, DB_TASK_TYPE.NAME);
end

function FinishTask(nTaskId)
	_G.MsgPlayerTask.SendCompleteTask(nTaskId);
end

function AcceptTask(nTaskId)
	_G.MsgPlayerTask.SendAcceptTask(nTaskId);
end

function DelTask(nTaskId)
	_G.MsgPlayerTask.SendDelTask(nTaskId);
end

--玩家背包是否已满
function IsBagFull()
	return _G.ItemFunc.IsBackBagFull();
end

--获取玩家物品数量
function GetItemNum(nItemType)
	return _G.ItemFunc.GetItemCount(nItemType);
end

--获取金钱数量
function GetMoneyNum()
	_G.GetRoleBasicDataN(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_MONEY);
end

--获取元宝数量
function GetEmoneyNum()
	_G.GetRoleBasicDataN(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_EMONEY);
end

-- 获取物品进度数据, 例如(3/5)
function GetTaskItemDataProgressStr(nTaskId, nItemType)
	local retStr = "";
	if not CheckN(nTaskId) or not CheckN(nItemType) then
		return retStr;
	end
	
	local bFinish			= GetTaskState(nTaskId) == SM_TASK_STATE.STATE_COMPLETE;

	-- chceck item
	local nItemType1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE1);
	local nItemTypeNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE1_NUM);
	local nItemType2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE2);
	local nItemTypeNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE2_NUM);
	local nItemType3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE3);
	local nItemTypeNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE3_NUM);
	
	if nItemType1 > 0 and nItemType == nItemType1 then
		if bFinish then
			retStr = retStr .. "(" .. SafeN2S(nItemTypeNum1) .. "/" .. SafeN2S(nItemTypeNum1) .. ")";
		else
			retStr = retStr .. "(" .. SafeN2S(GetItemNum(nItemType1)) .. "/" .. SafeN2S(nItemTypeNum1) .. ")";
		end
	end
	if nItemType2 > 0 and nItemType == nItemType2 then
		if bFinish then
			retStr = retStr .. "(" .. SafeN2S(nItemTypeNum2) .. "/" .. SafeN2S(nItemTypeNum2) .. ")";
		else
			retStr = retStr .. "(" .. SafeN2S(GetItemNum(nItemType2)) .. "/" .. SafeN2S(nItemTypeNum2) .. ")";
		end
	end
	if nItemType3 > 0 and nItemType == nItemType3 then
		if bFinish then
			retStr = retStr .. "(" .. SafeN2S(GetItemNum(nItemTypeNum3)) .. "/" .. SafeN2S(nItemTypeNum3) .. ")";
		else
			retStr = retStr .. "(" .. SafeN2S(GetItemNum(nItemType3)) .. "/" .. SafeN2S(nItemTypeNum3) .. ")";
		end
	end

	return retStr;
end

function GetTaskMonsterDataProgressStr(nTaskId, nMonsterId)
	local retStr = "";
	if not CheckN(nTaskId) or not CheckN(nMonsterId) then
		return retStr;
	end
	
	local bFinish			= GetTaskState(nTaskId) == SM_TASK_STATE.STATE_COMPLETE;

	-- check monster
	local nMonster1			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER1);
	local nMonsterNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM1);
	local nMonster2			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER2);
	local nMonsterNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM2);
	local nMonster3			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER3);
	local nMonsterNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM3);
	local nMonster4			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER4);
	local nMonsterNum4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM4);

	local nDataIndex		= _G.TASK_DATA.DATA1;

	if nMonster1 > 0 and nMonsterNum1 > 0 then
		if nMonsterId == nMonster1 then
			if bFinish then
				retStr = retStr .. "(" .. SafeN2S(nMonsterNum1) .. "/" .. SafeN2S(nMonsterNum1) .. ")";
			else
				retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nMonsterNum1) .. ")";
			end
			return retStr;
		else
			nDataIndex	= nDataIndex + 1;
		end
	end
	if nMonster2 > 0 and nMonsterNum2 > 0 then
		if nMonsterId == nMonster1 then
			if bFinish then
				retStr = retStr .. "(" .. SafeN2S(nMonsterNum2) .. "/" .. SafeN2S(nMonsterNum2) .. ")";
			else
				retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nMonsterNum2) .. ")";
			end
			return retStr;
		else
			nDataIndex	= nDataIndex + 1;
		end
	end
	if nMonster3 > 0 and nMonsterNum3 > 0 then
		if nMonsterId == nMonster1 then
			if bFinish then
				retStr = retStr .. "(" .. SafeN2S(nMonsterNum3) .. "/" .. SafeN2S(nMonsterNum3) .. ")";
			else
				retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nMonsterNum3) .. ")";
			end
			return retStr;
		else
			nDataIndex	= nDataIndex + 1;
		end
	end
	if nMonster4 > 0 and nMonsterNum4 > 0 then
		if nMonsterId == nMonster1 then
			if bFinish then
				retStr = retStr .. "(" .. SafeN2S(nMonsterNum4) .. "/" .. SafeN2S(nMonsterNum4) .. ")";
			else
				retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nMonsterNum4) .. ")";
			end
			return retStr;
		else
			nDataIndex	= nDataIndex + 1;
		end
	end
	
	return retStr;
end

function CheckTaskCanFinish(nTaskId)
	-- chceck item
	local nItemType1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE1);
	local nItemTypeNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE1_NUM);
	local nItemType2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE2);
	local nItemTypeNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE2_NUM);
	local nItemType3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE3);
	local nItemTypeNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.DEL_ITEMTYPE3_NUM);
	
	if nItemType1 > 0 and GetItemNum(nItemType1) < nItemTypeNum1 then
		LogInfo("CheckTaskCanFinish item1 not reach%d/%d", GetItemNum(nItemType1), nItemTypeNum1 );
		return false;
	end
	if nItemType2 > 0 and GetItemNum(nItemType2) < nItemTypeNum2 then
		LogInfo("CheckTaskCanFinish item2 not reach%d/%d", GetItemNum(nItemType2), nItemTypeNum2 );
		return false;
	end
	if nItemType3 > 0 and GetItemNum(nItemType3) < nItemTypeNum3 then
		LogInfo("CheckTaskCanFinish item3 not reach%d/%d", GetItemNum(nItemType3), nItemTypeNum3 );
		return false;
	end
	
	-- check monster
	local nMonster1			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER1);
	local nMonsterNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM1);
	local nMonster2			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER2);
	local nMonsterNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM2);
	local nMonster3			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER3);
	local nMonsterNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM3);
	local nMonster4			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER4);
	local nMonsterNum4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM4);

	local data = _G.TASK_DATA.DATA1;
	if nMonster1 > 0 and GetGameDataN(nTaskId, data) < nMonsterNum1 then
		LogInfo("CheckTaskCanFinish nMonster1 not reach%d/%d", GetGameDataN(nTaskId, data), nMonsterNum1);
		return false;
	elseif nMonster1 > 0 then
		data = data + 1;
	end
	if nMonster2 > 0 and GetGameDataN(nTaskId, data) < nMonsterNum2 then
		LogInfo("CheckTaskCanFinish nMonster2 not reach%d/%d", GetGameDataN(nTaskId, data), nMonsterNum2);
		return false;
	elseif nMonster2 > 0 then
		data = data + 1;
	end
	if nMonster3 > 0 and GetGameDataN(nTaskId, data) < nMonsterNum3 then
		LogInfo("CheckTaskCanFinish nMonster3 not reach%d/%d", GetGameDataN(nTaskId, data), nMonsterNum3);
		return false;
	elseif nMonster3 > 0 then
		data = data + 1;
	end
	if nMonster4 > 0 and GetGameDataN(nTaskId, data) < nMonsterNum4 then
		LogInfo("CheckTaskCanFinish nMonster4 not reach%d/%d", GetGameDataN(nTaskId, data), nMonsterNum4);
		return false;
	end
	
	return true;
end

--刷新任务状态
function TaskStateRefresh()
	LogInfo("TaskStateRefresh");
	local idAcceptTaskList = GetAcceptTasks();
	if 0 == table.getn(idAcceptTaskList) then
		LogInfo("0 == table.getn(idAcceptTaskList)");
		return;
	end
	
	for i, v in ipairs(idAcceptTaskList) do
		local finishState	= GetGameDataN(v, _G.TASK_DATA.TASK_STATE);
		local bFinish		= CheckTaskCanFinish(v);
		if finishState == SM_TASK_STATE.STATE_COMPLETE and not bFinish then
			--任务完成了,更新后状态又变成未完成
			LogInfo("任务完成了,更新后状态又变成未完成");
			SetGameDataN(v, _G.TASK_DATA.TASK_STATE, SM_TASK_STATE.STATE_UNCOMPLETE);
		elseif finishState ~= SM_TASK_STATE.STATE_COMPLETE and bFinish then
			--任务未完成,更新后状态变成完成
			LogInfo("任务未完成,更新后状态变成完成");
			SetGameDataN(v, _G.TASK_DATA.TASK_STATE, SM_TASK_STATE.STATE_COMPLETE);
		end
	end
end

--获取任务内容
function GetTaskDesc(nTaskId)
	local desc			= "";
	local taskcontent	= GenerateContentTable(nTaskId);
	if not CheckT(taskcontent) then
		LogInfo("GetTaskDesc ret nil");
		return desc;
	end
	
	for	i, v in ipairs(taskcontent) do
		desc = desc .. v;
	end
	return desc;
end

--获取任务奖励金钱
function GetTaskPrizeMoney(nTaskId)
	return ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_MONEY));
end
--获取任务奖励经验
function GetTaskPrizeExp(nTaskId)
	return ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_EXP));
end
--获取任务奖励物品
function GetTaskPrizeItemStr(nTaskId)
	local str	= "";
	local flag = GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEM_FLAG);
	if flag == 3 then
		--按职业给物品
		local nItemType = 0;
		local job = _G.PlayerFunc.GetJob(ConvertN(_G.GetPlayerId()));
		if job == _G.PROFESSION_TYPE.SWORD then
			nItemType = ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1));
		elseif job == _G.PROFESSION_TYPE.CHIVALROUS then
			nItemType = ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2));
		elseif job == _G.PROFESSION_TYPE.FIST then
			nItemType = ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3));
		end
		if nItemType > 0 then
			str	= _G.ItemFunc.GetName(nItemType);
		end
	else
		--直接给物品
		local nItemType = ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1));
		if nItemType > 0 then
			str	= str .. _G.ItemFunc.GetName(nItemType);
		end
		
		nItemType = ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2));
		if nItemType > 0 then
			str	= str .. _G.ItemFunc.GetName(nItemType);
		end
		
		nItemType = ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3));
		if nItemType > 0 then
			str	= str .. _G.ItemFunc.GetName(nItemType);
		end
	end
	return str;
end
--获取任务发布npcId
function GetTaskStartNpcId(nTaskId)
	return ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.NPC));
end
--获取任务结束npcId
function GetTaskFinishNpcId(nTaskId)
	return ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.FINISH_NPC));
end

function GetTaskPrize(nTaskId)
	local nExp					= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_EXP));
	local nMoney				= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_MONEY));
	local AWARD_ITEMTYPE1		= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1));
	local AWARD_ITEMTYPE1_NUM	= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1_NUM));
	local AWARD_ITEMTYPE2		= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2));
	local AWARD_ITEMTYPE2_NUM	= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2_NUM));
	local AWARD_ITEMTYPE3		= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3));
	local AWARD_ITEMTYPE3_NUM	= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3_NUM));
	
	local strAward = "";
	if nExp > 0 then
		strAward = strAward .. "<cffff00经验: /e" .. "<cffffff" .. tostring(nExp) .. "/e";
	end
	
	if nMoney > 0 then
		strAward = strAward .. "<cffff00金钱: /e" .. "<cffffff" .. tostring(nMoney) .. "/e";
	end
	
	return strAward;
end

--生成任务内容表
function GenerateContentTable(nTaskId)
	local textTable = {};
	local strContent = _G.GetDataBaseDataS("task_type", nTaskId, DB_TASK_TYPE.CONTENT);
	if nil == strContent or "" == strContent then
		LogInfo("GenerateContentTable strContent invalid");
		return textTable;
	end
	local textTable = {};
	local cells = GetTaskContent(strContent);
	if nil == cells or 0 == _G.table.getn(cells) then
		_G.table.insert(textTable, strContent);
		return textTable;
	end
	
	local nContentLen = _G.string.len(strContent);
	local startIndex = 1;
	local endIndex = nContentLen;
	
	for i, v in ipairs(cells) do
		if startIndex > nContentLen then
			break;
		end
		local strCelldata	= _G.string.gsub(v, "%[?]?", "");
		local celldatas		= GetTaskContentCell(strCelldata);
		local name = nil;
		local text = nil;
		if nil ~= celldatas and 3 <= _G.table.getn(celldatas) then
			name = celldatas[3];
			local m, n = _G.string.find(strContent, "%b" .. v);
			if nil ~= m then
				endIndex = m - 1;
				text = _G.string.sub(strContent, startIndex, endIndex);
				startIndex = n + 1;
			else
				name = nil;
				startIndex = nContentLen + 1;
			end
		else
			text = _G.string.sub(strContent, startIndex, endIndex);
			startIndex = nContentLen + 1;	
		end
		
		endIndex = nContentLen;

		if nil ~= text then
			_G.table.insert(textTable, text);
		end
		
		if nil == name then
			break;
		end
	
		_G.table.insert(textTable, name);
	end

	if startIndex <= nContentLen then
		local str = _G.string.sub(strContent, startIndex, endIndex);
		if nil ~= str then
			_G.table.insert(textTable, str);
		end
	end

	return textTable;
end

function GetTaskContent(strContent)
	local cells = {};
	_G.string.gsub(strContent, "%[.-]", 
		function (cell) 
			_G.table.insert(cells, cell) 
		end 
	);
	return cells;
end

function GetTaskContentCell(strCelldata)
	local celldatas = {};
	if not CheckS(strCelldata) then
		return celldatas;
	end
	
	local index = 1;
	local nLen = _G.string.len(strCelldata);
	while  true do
		local i, j = _G.string.find(strCelldata, " ", index);
		if nil == i then
			break;
		end
		local str = _G.string.sub(strCelldata, index, j - 1);
		if nil == str or "" == str then
			return nil;
		end
		_G.table.insert(celldatas, str);
		index = j + 1;
	end
	
	if index <= nLen then
		local str = _G.string.sub(strCelldata, index, nLen);
		if CheckS(str) then
			_G.table.insert(celldatas, str);
		end
	end
	
	return celldatas;
end