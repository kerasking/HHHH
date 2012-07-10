
local _G = _G;
setfenv(1, TASK);

-- 当玩家接某个任务时C++先调用具体的某个任务的处理方法，若没处理则调用本方法
function TASK_FUNCTION_COMMON(nTaskId)
	local nTaskState		= GetTaskState(nTaskId);
	LogInfo("npc[%d], nTaskState[%d]", nTaskId, nTaskState);
	if SM_TASK_STATE.STATE_NONE == nTaskState or 
		SM_TASK_STATE.STATE_AVAILABLE == nTaskState then
		-- 未接
		OpenTaskDlg(nTaskId);
		if TaskContentConfig[nTaskId] ~= nil and 
			_G.type(TaskContentConfig[nTaskId]) == "string" then
			SetContent(TaskContentConfig[nTaskId]);
		else
			SetContent("");
		end
		
		SetTaskAward(GetTaskPrize(nTaskId));
		AddOpt("<cffff00接受任务/e", SM_TASK_OPTION_ACTION.ACCEPT);
		--AddOpt("<cffff00拒绝任务/e", SM_TASK_OPTION_ACTION.REJECT);
		return true;
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == nTaskState then
		-- 任务已接未完成
		if TaskConfig[nTaskId] ~= nil then
			local title		= TaskConfig[nTaskId][1];
			local content	= TaskConfig[nTaskId][2];
			if nil ~= title and type(title) == "string" and
			   nil ~= content and type(content) == "string" then
				OpenTaskDlg(nTaskId);
				if "" ~= title then
					SetTitle(title);
				end
				SetContent(content);
				return true;
			end
		else
			CloseDlg();
		end
		return true;
	elseif SM_TASK_STATE.STATE_COMPLETE == nTaskState then
		-- 任务已接已完成
		LogInfo("task Finish");
		FinishTask(nTaskId);
		SysChat("完成任务" .. GetTaskName(nTaskId));
		CloseDlg();
		return true;
	end
	LogInfo("task not deal");
    return false;
end 

-- 当玩家点击任务界面选项时C++会先调用本函数,如果本函数不处理,则会调用具体的任务选项处理函数
function TASK_OPTION_COMMON(nTaskId, nAction)
	local nTaskState		= GetTaskState(nTaskId);
	LogInfo("click opt taskstate[%d] nAction[%d]", nTaskState, nAction);
	if SM_TASK_STATE.STATE_NONE == nTaskState then
		if SM_TASK_OPTION_ACTION.ACCEPT == nAction then
			AcceptTask(nTaskId);
			CloseDlg();
			return true;
		elseif SM_TASK_OPTION_ACTION.REJECT == nAction then
			CloseDlg();
			return true;
		end
	end

	return false;
end

-- param1 : nItemType
function TASK_ITEM_UPDATE(param1, param2, param3)
	--[[
	if not _G.CheckN(param1) then
		return;
	end--]]
	_G.LogInfo("TASK_ITEM_UPDATE");
	TaskStateRefresh();
end

-- param1 : nMonsterType
function TASK_KILL_MONSTER(param1, param2, param3)
	if not _G.CheckN(param1) then
		return;
	end
	
	LogInfo("kill monster[%d]", param1);
	
	local idAcceptTaskList = GetAcceptTasks();
	if 0 == table.getn(idAcceptTaskList) then
		return;
	end
	
	for i, v in ipairs(idAcceptTaskList) do
		local data		= _G.TASK_DATA.DATA1;
		local nTaskId	= v;
		local nMonster1			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER1);
		local nMonsterNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM1);
		if nMonster1 > 0 and nMonsterNum1 > 0 then
			if nMonster1 == param1 then
				local num = GetGameDataN(nTaskId, data);
				SetGameDataN(nTaskId, data, num + 1);
				TaskStateRefresh();
				return;
			end
			data = data + 1;
		end
		
		local nMonster2			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER2);
		local nMonsterNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM2);
		if nMonster2 > 0 and nMonsterNum2 > 0 then
			if nMonster2 == param1 then
				local num = GetGameDataN(nTaskId, data);
				SetGameDataN(nTaskId, data, num + 1);
				TaskStateRefresh();
				return;
			end
			data = data + 1;
		end
		
		local nMonster3			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER3);
		local nMonsterNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM3);
		if nMonster3 > 0 and nMonsterNum3 > 0 then
			if nMonster3 == param1 then
				local num = GetGameDataN(nTaskId, data);
				SetGameDataN(nTaskId, data, num + 1);
				TaskStateRefresh();
				return;
			end
			data = data + 1;
		end
		
		local nMonster4			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER4);
		local nMonsterNum4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM4);
		if nMonster4 > 0 and nMonsterNum4 > 0 then
			if nMonster4 == param1 then
				local num = GetGameDataN(nTaskId, data);
				SetGameDataN(nTaskId, data, num + 1);
				TaskStateRefresh();
				return;
			end
			data = data + 1;
		end
	end
end

_G.GlobalEvent.Register(_G.GLOBALEVENT.GE_ITEM_UPDATE, "TASK.TASK_ITEM_UPDATE", TASK_ITEM_UPDATE);
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_KILL_MONSTER, "TASK.TASK_KILL_MONSTER", TASK_KILL_MONSTER);
