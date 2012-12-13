
local _G = _G;
setfenv(1, TASK);



--任务对话内容格式化
--[name] －》玩家名字
--
function TaskContentFormat(str)
	local result =  _G.string.gsub(str,"%[name%]","<cffff00".._G.GetRoleBasicDataS(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_NAME).."/e");
	return result;
end
 

-- 当玩家接某个任务时C++先调用具体的某个任务的处理方法，若没处理则调用本方法
function TASK_FUNCTION_COMMON(nTaskId)
	local nTaskState		= GetTaskState(nTaskId);
	LogInfo("npc[%d], nTaskState[%d]", nTaskId, nTaskState);
	if SM_TASK_STATE.STATE_NONE == nTaskState or 
		SM_TASK_STATE.STATE_AVAILABLE == nTaskState then
		-- 未接
		OpenTaskDlg(nTaskId);
		if TaskConfig[nTaskId] ~= nil and 
			_G.type(TaskConfig[nTaskId]["TASKCONTENT1"]) == "string" then
			
			
			SetContent(TaskContentFormat(TaskConfig[nTaskId]["TASKCONTENT1"]));
		else
			SetContent("");
		end
		
		--没有二级对话则显示奖励
		if TaskConfig[nTaskId]["TASKCONTENT2"] == nil then
			SetTaskAward(GetTaskPrize(nTaskId));
		end
		
		if TaskConfig[nTaskId]["TASKOPTION1"] ~= nil then
			local sopt1 = TaskContentFormat(TaskConfig[nTaskId]["TASKOPTION1"]);
			--AddOpt("<cffff00"..TaskConfig[nTaskId]["TASKOPTION1"].."/e", SM_TASK_OPTION_ACTION.TASKOPTION1);
			AddOpt("<cffff00"..sopt1.."/e", SM_TASK_OPTION_ACTION.TASKOPTION1);
		else
			LogInfo("TaskConfig 配置缺少TASKOPTION1 task:"..nTaskId);
		end	
		
		--AddOpt("<cffff00拒绝任务/e", SM_TASK_OPTION_ACTION.REJECT);
		return true;
		
	elseif SM_TASK_STATE.STATE_UNCOMPLETE == nTaskState then
		-- 任务已接未完成
		if TaskConfig[nTaskId] ~= nil then
			local title		= ""--TaskConfig[nTaskId][1];
			local content	= TaskContentFormat(TaskConfig[nTaskId]["NOTFINISH"]);
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
		OpenTaskDlg(nTaskId);
		
		local content	= TaskContentFormat(TaskConfig[nTaskId]["FINISHCONTENT"]);
		if content == nil then
			SetContent("");
		else
			SetContent(content);
		end
		
		
		SetTaskAward(GetTaskPrize(nTaskId));
		if TaskConfig[nTaskId]["FINISHOPTION"] ~= nil then
			--AddOpt("<cffff00"..TaskConfig[nTaskId]["FINISHOPTION"].."/e", SM_TASK_OPTION_ACTION.FINISH);
			local sOptFinish = TaskContentFormat(TaskConfig[nTaskId]["FINISHOPTION"]);
			AddOpt("<cffff00"..sOptFinish.."/e", SM_TASK_OPTION_ACTION.FINISH);
			
			
		else
			AddOpt(GetTxtPri("TASK_T1"), SM_TASK_OPTION_ACTION.FINISH);
		end
			
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
		--接收任务
		if SM_TASK_OPTION_ACTION.ACCEPT == nAction then
			AcceptTask(nTaskId);
			CloseDlg();
			return true;
		--拒绝任务	
		elseif SM_TASK_OPTION_ACTION.REJECT == nAction then
			CloseDlg();
			return true;	
		elseif SM_TASK_OPTION_ACTION.TASKOPTION1 == nAction then
			--CloseDlg();	
			OpenTaskDlg(nTaskId);
			if TaskConfig[nTaskId]["TASKCONTENT2"] ~= nil and 
			
				_G.type(TaskConfig[nTaskId]["TASKCONTENT2"]) == "string" then
				SetContent(TaskContentFormat(TaskConfig[nTaskId]["TASKCONTENT2"]));
				SetTaskAward(GetTaskPrize(nTaskId));
				AddOpt(GetTxtPri("TASK_T2"), SM_TASK_OPTION_ACTION.ACCEPT);
			else
				AcceptTask(nTaskId);
				CloseDlg();	
				return true;
			end
		

			
			return true;			
		
		end
	end

	--完成任务
	if SM_TASK_OPTION_ACTION.FINISH == nAction then
		FinishTask(nTaskId);
		CloseDlg();
		LogInfo("task Finish");
		
		--特殊任务奖励
		if 	tSpecialTaskPrizeFunc[nTaskId]~= nil then
            LogInfo("QBW:tSpecialTaskPrizeFunc");
			tSpecialTaskPrizeFunc[nTaskId]();
        else
            LogInfo("QBW:tSpecialTaskPrizeFunc nil");

		end
		
		--_G.SysChat("完成任务" .. GetTaskName(nTaskId));
		return true;
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
		local nMonster1			= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1_LPARAM);
		local nMonsterNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1_WPARAM);
		local nCondition1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1);
		if nCondition1 == _G.TASK_CONTIDTION_TYPE.MONSTER then
			if nMonster1 > 0 and nMonsterNum1 > 0 then
				if nMonster1 == param1 then
					local num = GetGameDataN(nTaskId, data);
					SetGameDataN(nTaskId, data, num + 1);
					TaskStateRefresh();
					--return;
				end
				data = data + 1;
			end
		end
		
		local nMonster2			= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2_LPARAM);
		local nMonsterNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2_WPARAM);
		local nCondition2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2);
		if nCondition2 == _G.TASK_CONTIDTION_TYPE.MONSTER then
			if nMonster2 > 0 and nMonsterNum2 > 0 then
				if nMonster2 == param1 then
					local num = GetGameDataN(nTaskId, data);
					SetGameDataN(nTaskId, data, num + 1);
					TaskStateRefresh();
					--return;
				end
				data = data + 1;
			end
		end
		
		
		local nMonster3			= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3_LPARAM);
		local nMonsterNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3_WPARAM);
		if nCondition3 == _G.TASK_CONTIDTION_TYPE.MONSTER then
			if nMonster3 > 0 and nMonsterNum3 > 0 then
				if nMonster3 == param1 then
					local num = GetGameDataN(nTaskId, data);
					SetGameDataN(nTaskId, data, num + 1);
					TaskStateRefresh();
					--return;
				end
				data = data + 1;
			end
		end
		
		local nMonster4			= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4_LPARAM);
		local nMonsterNum4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4_WPARAM);
		if nCondition4 == _G.TASK_CONTIDTION_TYPE.MONSTER then
			if nMonster4 > 0 and nMonsterNum4 > 0 then
				if nMonster4 == param1 then
					local num = GetGameDataN(nTaskId, data);
					SetGameDataN(nTaskId, data, num + 1);
					TaskStateRefresh();
					--return;
				end
				data = data + 1;
			end
		end	
	end
	

end


--强化装备
function TASK_UPGRADE_EQUIP()
	local GuideType = _G.TASK_GUIDE_PARAM.STRENGTHEN_EQUIP;
	GuideTaskDataRefresh(GuideType)
end

--GuideType 引导任务条件类型,	nParam:设置参数,如果nil则计数+1
function TASK_GUIDETASK_ACTION(GuideType,nParam)
	LogInfo("qbw99 TASK_GUIDETASK_ACTION:"..GuideType);
	--遍历所有已接任务
	local idAcceptTaskList = GetAcceptTasks();
	if 0 == table.getn(idAcceptTaskList) then
		return;
	end
	
	for i, v in ipairs(idAcceptTaskList) do	
		local tTaskConfig = GetTaskConfig(v);
		local data =  _G.TASK_DATA.DATA1;
		for j,w in ipairs(tTaskConfig) do
			if w[3] == _G.TASK_CONTIDTION_TYPE.GUIDE then
				if w[1] > 0 and w[1] == GuideType then
					
					if _G.TASK.IfTaskGuideProgressFinished(v,w[1]) == false then
						--任务条件未达成,则刷数据库
						--刷新数据
						LogInfo("qbw99 刷新数据 TASK_GUIDETASK_ACTION v:"..v);
						local num = GetGameDataN(v, data);
						if nParam == nil then
							SetGameDataN(v, data, num + 1);
							_G.MsgPlayerTask.SendTaskCondition(v,GuideType,num + 1); ----同步服务端数据
						else
							SetGameDataN(v, data,nParam);
							_G.MsgPlayerTask.SendTaskCondition(v,GuideType,nParam);	
						end
						TaskStateRefresh();						
					end

				end
			end	
			
			data = data + 1;
		end
	end	
end

function ClearUpKillMonster(nBossId)
	
	local nGenerateRuleID	= _G.GetDataBaseDataN( "mapzone", nBossId, _G.DB_MAPZONE.GENERATE_RULE_ID )
	local nMonsterType	= 0;
	
	
	for i=0,8 do
		nMonsterType	= _G.GetDataBaseDataN( "monster_generate", nGenerateRuleID, _G.DB_MONSTER_GENERATE.STATIONS1 + i )
		if ( nMonsterType ~= nil ) and ( nMonsterType > 0 ) then
			TASK_KILL_MONSTER(nMonsterType);
			LogInfo("TASK_KILL_MONSTER:"..nMonsterType);
		end
	end
end


_G.GlobalEvent.Register(_G.GLOBALEVENT.GE_ITEM_UPDATE, "TASK.TASK_ITEM_UPDATE", TASK_ITEM_UPDATE);
_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_KILL_MONSTER, "TASK.TASK_KILL_MONSTER", TASK_KILL_MONSTER);


--强化装备
_G.GlobalEvent.Register(_G.GLOBALEVENT.GE_GUIDETASK_ACTION, "TASK.TASK_GUIDETASK_ACTION", TASK_GUIDETASK_ACTION);

--使用物品




