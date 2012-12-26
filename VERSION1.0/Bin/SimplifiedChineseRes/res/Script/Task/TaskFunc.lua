
local _G = _G;
local TaskUI = _G.TaskUI;
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

function FinishTask_TEST(nTaskId)
	_G.MsgPlayerTask.SendCompleteTask_TEST(nTaskId);
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

--获取金币数量
function GetEmoneyNum()
	_G.GetRoleBasicDataN(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_EMONEY);
end


function GetTaskConfig(nTaskId)

	local nType1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1_LPARAM);
	local nTypeNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1_WPARAM);
	local nCondition1	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1);
		
	local nType2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2_LPARAM);
	local nTypeNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2_WPARAM);
	local nCondition2	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2);
		
	local nType3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3_LPARAM);
	local nTypeNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3_WPARAM);
	local nCondition3	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3);

	local nType4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4_LPARAM);
	local nTypeNum4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4_WPARAM);
	local nCondition4	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4);
	
	local tTaskConfig = {}
	
	tTaskConfig[1] = {nType1,nTypeNum1,nCondition1};
	tTaskConfig[2] = {nType2,nTypeNum2,nCondition2};
	tTaskConfig[3] = {nType3,nTypeNum3,nCondition3};
	tTaskConfig[4] = {nType4,nTypeNum4,nCondition4};
	
	return tTaskConfig;

end

--获取引导任务进度
function GetTaskGUIDEDataProgressStr(nTaskId, nGuideType)
	local retStr = "";
	if not CheckN(nTaskId) or not CheckN(nGuideType) then
		return retStr;
	end

	local bFinish			= GetTaskState(nTaskId) == SM_TASK_STATE.STATE_COMPLETE;
	local tTaskConfig =  GetTaskConfig(nTaskId);

	
	local nDataIndex = _G.TASK_DATA.DATA1;	
	for i=1,4 do
		local condition = tTaskConfig[i][3]; 
		
		if condition == _G.TASK_CONTIDTION_TYPE.GUIDE then
			local nType = tTaskConfig[i][1];
			local nGuideNum = tTaskConfig[i][2];
			
			
			if  nType == nGuideType then
				if  nGuideType == _G.TASK_GUIDE_PARAM.EXCHANGE_SKILL or 
					nGuideType == _G.TASK_GUIDE_PARAM.BUY_ITEM or 
					nGuideType == _G.TASK_GUIDE_PARAM.USE_ITEM then
					
					return "";				
				end
			
			
			
			
			
				if bFinish then
					retStr = retStr .. "(" .. SafeN2S(tTaskConfig[i][2]) .. "/" .. SafeN2S(tTaskConfig[i][2]) .. ")";
				else
					retStr = retStr .. "(" ..  GetGameDataN(nTaskId, nDataIndex) .. "/" .. SafeN2S(tTaskConfig[i][2]) .. ")";
				end
				return retStr;
			end
		end
		
		nDataIndex = nDataIndex + 1;
	end
	
	return "";
end
	
	
-- 获取物品进度数据, 例如(3/5)
function GetTaskItemDataProgressStr(nTaskId, nItemType)
	local retStr = "";
	if not CheckN(nTaskId) or not CheckN(nItemType) then
		return retStr;
	end
	
	local bFinish			= GetTaskState(nTaskId) == SM_TASK_STATE.STATE_COMPLETE;	
	local tTaskConfig =  GetTaskConfig(nTaskId);
	
	for i,v in ipairs(tTaskConfig) do
		
		if v[3] == _G.TASK_CONTIDTION_TYPE.ITEM then
			if v[1] > 0 and v[1] == nItemType then
				if bFinish then
					retStr = retStr .. "(" .. SafeN2S(v[2]) .. "/" .. SafeN2S(v[2]) .. ")";
				else
					retStr = retStr .. "(" .. SafeN2S(GetItemNum(nItemType)) .. "/" .. SafeN2S(v[2]) .. ")";
				end
			end
		end
	
	end


	return retStr;
end

--检测对应引导任务是否完成
function IfTaskGuideProgressFinished(nTaskId,nGuideType)
	local tTaskConfig = GetTaskConfig(nTaskId)

	local nDataIndex = _G.TASK_DATA.DATA1;	
	for i=1,4 do
		local condition = tTaskConfig[i][3];
		
		if condition == _G.TASK_CONTIDTION_TYPE.GUIDE then
			local nType = tTaskConfig[i][1];
			local nNum = tTaskConfig[i][2];
			
			if  nType == nGuideType then
				

				--特殊类型（使用物品,购买物品,切换技能） 判断id是否相同
				if  nGuideType == _G.TASK_GUIDE_PARAM.EXCHANGE_SKILL or 
					nGuideType == _G.TASK_GUIDE_PARAM.BUY_ITEM or 
					nGuideType == _G.TASK_GUIDE_PARAM.USE_ITEM then
					
					if GetGameDataN(nTaskId, nDataIndex) == nNum then
						return true;
					else
						return false;	
					end
				end					
				
				
				--其他类型 判断次数是否足够
				if nType > 0 and GetGameDataN(nTaskId, nDataIndex) < nNum then
					return false;
				else
					return true;	
				end
			end
		end
		
		nDataIndex = nDataIndex + 1;
	end
			
	return true;	
	
end



--检测对应怪物任务是否完成
function IfTaskMonsterProgressFinished(nTaskId, nMonsterId)
	local tTaskConfig = GetTaskConfig(nTaskId)
	

		
	local nDataIndex = _G.TASK_DATA.DATA1;	
	for i=1,4 do
		local condition = tTaskConfig[i][3]; 
		
		if condition == _G.TASK_CONTIDTION_TYPE.MONSTER then
			local nMonsterType = tTaskConfig[i][1];
			local nMonsterTypeNum = tTaskConfig[i][2];
			
			if  nMonsterType == nMonsterId then
				if nMonsterType > 0 and GetGameDataN(nTaskId, nDataIndex) < nMonsterTypeNum then
					return false;
				else
					return true;	
				end
			end
		end
		
		nDataIndex = nDataIndex + 1;
	end
			
	return true;	
	
end

--检测对应收集物品任务是否完成
function IfTaskItemProgressFinished(nTaskId, nItemId)


	local tTaskConfig = GetTaskConfig(nTaskId)

		
	for i=1,4 do
		local condition = tTaskConfig[i][3]; 
		
		if condition == _G.TASK_CONTIDTION_TYPE.ITEM then
			local nItemType = tTaskConfig[i][1];
			local nItemTypeNum = tTaskConfig[i][2];
			
			if  nItemType == nItemId then
				if nItemType > 0 and GetItemNum(nItemType) < nItemTypeNum then
					LogInfo("IfTaskItemProgressFinished  not reach%d/%d", GetItemNum(nItemType), nItemTypeNum );
					return false;
				else
					return true;	
				end
			end
		end
	end
			
	return true;
end

function GetTaskMonsterDataProgressStr(nTaskId, nMonsterId)
	local retStr = "";
	if not CheckN(nTaskId) or not CheckN(nMonsterId) then
		return retStr;
	end
	
	local bFinish			= GetTaskState(nTaskId) == SM_TASK_STATE.STATE_COMPLETE;

	--[[ check monster
	local nMonster1			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER1);
	local nMonsterNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM1);
	local nMonster2			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER2);
	local nMonsterNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM2);
	local nMonster3			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER3);
	local nMonsterNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM3);
	local nMonster4			= GetDataBaseN(nTaskId, DB_TASK_TYPE.MONSTER4);
	local nMonsterNum4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.MON_NUM4);
--]]
	local nType1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1_LPARAM);
	local nTypeNum1		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1_WPARAM);
	local nCondition1	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_1);
		
	local nType2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2_LPARAM);
	local nTypeNum2		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2_WPARAM);
	local nCondition2	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_2);
		
	local nType3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3_LPARAM);
	local nTypeNum3		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3_WPARAM);
	local nCondition3	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_3);

	local nType4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4_LPARAM);
	local nTypeNum4		= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4_WPARAM);
	local nCondition4	= GetDataBaseN(nTaskId, DB_TASK_TYPE.CONDITION_4);


	local nDataIndex		= _G.TASK_DATA.DATA1;

	if nCondition1 == _G.TASK_CONTIDTION_TYPE.MONSTER then
		if nType1 > 0 and nTypeNum1 > 0 then
			if nMonsterId == nType1 then
				if bFinish then
					retStr = retStr .. "(" .. SafeN2S(nTypeNum1) .. "/" .. SafeN2S(nTypeNum1) .. ")";
				else
					retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nTypeNum1) .. ")";
				end
				return retStr;
			else
				nDataIndex	= nDataIndex + 1;
			end
		end
	end
	
	if nCondition2 == _G.TASK_CONTIDTION_TYPE.MONSTER then	
		if nType2 > 0 and nTypeNum2 > 0 then
			if nMonsterId == nType2 then
				if bFinish then
					retStr = retStr .. "(" .. SafeN2S(nTypeNum2) .. "/" .. SafeN2S(nTypeNum2) .. ")";
				else
					retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nTypeNum2) .. ")";
				end
				return retStr;
			else
				nDataIndex	= nDataIndex + 1;
			end
		end
	end
	
	if nCondition3 == _G.TASK_CONTIDTION_TYPE.MONSTER then	
		if nType3 > 0 and nTypeNum3 > 0 then
			if nMonsterId == nType3 then
				if bFinish then
					retStr = retStr .. "(" .. SafeN2S(nTypeNum3) .. "/" .. SafeN2S(nTypeNum3) .. ")";
				else
					retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nTypeNum3) .. ")";
				end
				return retStr;
			else
				nDataIndex	= nDataIndex + 1;
			end
		end
	end
	
	if nCondition4 == _G.TASK_CONTIDTION_TYPE.MONSTER then			
		if nType4 > 0 and nTypeNum4 > 0 then
			if nMonsterId == nType4 then
				if bFinish then
					retStr = retStr .. "(" .. SafeN2S(nTypeNum4) .. "/" .. SafeN2S(nTypeNum4) .. ")";
				else
					retStr = retStr .. "(" .. SafeN2S(GetGameDataN(nTaskId, nDataIndex)) .. "/" .. SafeN2S(nTypeNum4) .. ")";
				end
				return retStr;
			else
				nDataIndex	= nDataIndex + 1;
			end
		end
	end
	
	return retStr;
end

function CheckTaskCanFinish(nTaskId)
	-- chceck item

	local tTaskConfig = GetTaskConfig(nTaskId);

	
	
	
	for i=1,4 do
		
		local condition = tTaskConfig[i][3]; 
		
		if condition == _G.TASK_CONTIDTION_TYPE.ITEM then
			
			local nItemType = tTaskConfig[i][1];
			local nItemTypeNum = tTaskConfig[i][2];
			if nItemType > 0 and GetItemNum(nItemType) < nItemTypeNum then
				LogInfo("CheckTaskCanFinish item1 not reach%d/%d", GetItemNum(nItemType), nItemTypeNum );
				return false;
			end
			
		elseif condition == _G.TASK_CONTIDTION_TYPE.MONSTER then
			local data = _G.TASK_DATA.DATA1 + i - 1;
			local nMonster		 = tTaskConfig[i][1];
			local nMonsterNum 	 = tTaskConfig[i][2];
			if nMonster > 0 and GetGameDataN(nTaskId, data) < nMonsterNum then
				LogInfo("CheckTaskCanFinish nMonster1 not reach%d/%d", GetGameDataN(nTaskId, data), nMonsterNum);
				return false;
			end
		elseif condition == _G.TASK_CONTIDTION_TYPE.GUIDE then
			local data = _G.TASK_DATA.DATA1 + i - 1;
			local nGuideType		= tTaskConfig[i][1];
			local nGuideNum 	 	= tTaskConfig[i][2];
			LogInfo("CheckTaskCanFinish guide nGuideType"..nGuideType.." nGuideNum"..nGuideNum);
			LogInfo("CheckTaskCanFinish guide  GetGameDataN(nTaskId, data)"..GetGameDataN(nTaskId, data));
			
			
			--升级任务做特殊处理
			if nGuideType == _G.TASK_GUIDE_PARAM.STRENGTHEN_PET then
				if 	nGuideNum >  GetGameDataN(nTaskId, data)  then
					return false;
				end	
			else
				if 	nGuideNum ~=  GetGameDataN(nTaskId, data)  then
					return false
				end			
			end

			

		end
	end
	LogInfo("CheckTaskCanFinish return true:"..nTaskId);
			

	return true;
end

--刷新任务状态
function TaskStateRefresh()
	LogInfo("TaskStateRefresh");
	
	local idAcceptTaskList = GetAcceptTasks();
	if 0 == table.getn(idAcceptTaskList) then
		--主界面任务提示刷新
        
		if  _G.IsUIShow(_G.NMAINSCENECHILDTAG.MainUITop) then
			_G.MainUI.RefreshTaskPic();
		end
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
	
	--主界面任务提示刷新
	if  _G.IsUIShow(_G.NMAINSCENECHILDTAG.MainUITop) then
		_G.MainUI.RefreshTaskPic();
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
	_G.LogInfoT(taskcontent);
		
	for	i, v in ipairs(taskcontent) do
        if i%2 ~= 0 then
            desc = desc .. v;
        end
		
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

--获取任务奖励军衔
function GetTaskPrizeRepute(nTaskId)
	return ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_REPUTE));
end
--获取任务奖励将魂
function GetTaskPrizeSoul(nTaskId)
	return ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_HONOUR));
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
	
	local repute				= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_REPUTE));
	local soul					= ConvertN(GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_HONOUR));
	
	local strAward = "";
	if nExp > 0 then
		--strAward = strAward .. "<cffff00经验: /e" .. "<cffffff" .. tostring(nExp) .. "/e";
        strAward = _G.string.format("%s<cffff00%s: /e<cffffff%d",strAward,_G.GetTxtPub("exp"),nExp);
	end
	
	if nMoney > 0 then
		--strAward = strAward .. "<cffff00银币: /e" .. "<cffffff" .. tostring(nMoney) .. "/e";
        strAward = _G.string.format("%s<cffff00%s: /e<cffffff%d",strAward,_G.GetTxtPub("coin"),nMoney);
	end
	
	if repute > 0 then
		--strAward = strAward .. "<cffff00声望: /e" .. "<cffffff" .. tostring(repute) .. "/e";
        strAward = _G.string.format("%s<cffff00%s: /e<cffffff%d",strAward,_G.GetTxtPub("ShenWan"),repute);
	end
	
	if soul > 0 then
		--strAward = strAward .. "<cffff00将魂: /e" .. "<cffffff" .. tostring(soul) .. "/e";
        strAward = _G.string.format("%s<cffff00%s: /e<cffffff%d",strAward,_G.GetTxtPub("JianHun"),soul);
	end	
	
	local tAwardItem = {}
	tAwardItem[1] = {AWARD_ITEMTYPE1,AWARD_ITEMTYPE1_NUM};
	tAwardItem[2] = {AWARD_ITEMTYPE2,AWARD_ITEMTYPE2_NUM};
	tAwardItem[3] = {AWARD_ITEMTYPE3,AWARD_ITEMTYPE3_NUM};
	
	for i=1,3 do
		if tAwardItem[i][1]~=0 and  tAwardItem[i][2]~=0 then
			strAward = strAward .. "  <cffff00"..GetDataBaseDataS("itemtype", tAwardItem[i][1], _G.DB_ITEMTYPE.NAME).." /e X" .. "<cffffff" .. tAwardItem[i][2] .. "/e";
		end
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
    
    --LogInfo("strContent:"..strContent)
    
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
        LogInfo("strCelldata:")
        LogInfo("strCelldata:"..strCelldata)
        LogInfo("strContent:"..strContent)

        
		local celldatas		= GetTaskContentCell(strCelldata);
		local name = nil;
		local text = nil;
		if nil ~= celldatas and 3 <= _G.table.getn(celldatas) then
			name = celldatas[3];
           -- name = nil;
            LogInfo("strContent v:"..v)
            
			--local m, n = _G.string.find(strContent, "%b" .. v);
			local m, n = _G.string.find(strContent, "%b[]"); 
			
			LogInfo("strContent m:"..m.." n"..n)
			if nil ~= m then
				endIndex = m - 1;
				text = _G.string.sub(strContent, startIndex, endIndex);
				startIndex = n + 1;
                 LogInfo("strContent text:"..text)
			else
                 LogInfo("strContent name nil")
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
        
               LogInfo("celldatas str:"..str)
 
        
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


TASKTYPE =
{
	MAIN_TASK = 5,
}

--判断是否接收过任务
function IfTaskExist(nTaskid)
	local tlist = GetAcceptTasks();
	
	for i,taskid in ipairs(tlist) do	
		if taskid == nTaskid then
			return true;
		end
	end
	
	return false;
end


--获取已接主线任务id 无则返回nil
function GetMainTaskId()
	--获取已接任务列表
	local tlist = GetAcceptTasks();
	
	for i,taskid in ipairs(tlist) do	
		local tasktype =_G.math.floor(taskid/10000);
		if tasktype == TASKTYPE.MAIN_TASK then
			return taskid;
		end
	end
	
	return nil;
end

--获取下一主线任务id
function GetNextMainTaskId()
	--获取可接任务列表
	local tlist = GetCanAcceptTasks();
	for i,taskid in ipairs(tlist) do	
		local tasktype = _G.math.floor(taskid/10000);
		if tasktype == TASKTYPE.MAIN_TASK then
			return taskid;
		end
	end
	
	return nil;
end

--追踪任务
function TrackTask(nTaskId)
	local  processlist = GenerateContentTable(nTaskId)
	LogInfo("QBW taskid:"..nTaskId);
	if 0 == table.getn(processlist) then
		return;
	end
	
	local nIndex = 0;
	for i,v in ipairs(processlist) do
		
		if i%2 ==0 then
			
			local cellDatas = _G.TaskUI.GetTaskConfigData(nTaskId,nIndex);
			
			local nContenType = ConvertN(cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_TYPE]);
			--LogInfo("QBW1  "..nContenType.." "..TASK.SM_TASK_CONTENT_TYPE.MONSTER);
			
			if nContenType == SM_TASK_CONTENT_TYPE.MONSTER then
			
			
			--打怪任务
				local nMonsterId = cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_ID];
				
			 	 if IfTaskMonsterProgressFinished(nTaskId, nMonsterId) ==false then
			 	 
			 	 	LogInfo("QBW4");
			 	 	local taskData = _G.TaskUI.GetTaskDataProcessStr(nTaskId,nIndex);
			 	 	_G.CloseUI(_G.NMAINSCENECHILDTAG.PlayerTask);
			 	 	LogInfo("QBW5");
			 	 	_G.TaskUI.DealTaskData(nTaskId,nIndex)
			 	 	return;
			 	 else
			 	 	nIndex = nIndex + 1;
			 	 	
			 	 end
			 	 
			 	 
			elseif 	nContenType == SM_TASK_CONTENT_TYPE.ITEM then
			--收集任务
			LogInfo("QBW2");
				local nItemId = cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_ID];
				
				LogInfo("QBW3 "..nItemId);
				if IfTaskItemProgressFinished(nTaskId, nItemId) == false then
					LogInfo("QBW311");
					local taskData = _G.TaskUI.GetTaskDataProcessStr(nTaskId,nIndex);
			 	 	_G.CloseUI(_G.NMAINSCENECHILDTAG.PlayerTask);
			 	 	_G.TaskUI.DealTaskData(nTaskId,nIndex)
			 	 	return;
				else
					nIndex = nIndex + 1;
				end
					
			
				
			end
			
		else
			
			local z =1;
		end
		
	end	
	
	--交任务
	local nNpcId = GetTaskFinishNpcId(nTaskId);
	_G.CloseUI(_G.NMAINSCENECHILDTAG.PlayerTask);
	-- 导航到npc
	_G.TaskUI.NavigateNpc(nNpcId);		


end




--获取对应任务下一步目标类型,及id 没接则返回nil
function GetNextTaskTargetType(nTaskId)
	local  processlist = GenerateContentTable(nTaskId)
	if 0 == table.getn(processlist) then
		return nil;
	end
	
	local nIndex = 0;
	for i,v in ipairs(processlist) do
		
		if i%2 ==0 then
			
			local cellDatas = _G.TaskUI.GetTaskConfigData(nTaskId,nIndex);
			
			local nContenType = ConvertN(cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_TYPE]);
		
			if nContenType == SM_TASK_CONTENT_TYPE.MONSTER then
			--打怪任务
				LogInfo("QBW5");
				local nMonsterId = cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_ID];
				local nMapId = cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_MAP_ID];
			 	 if IfTaskMonsterProgressFinished(nTaskId, nMonsterId) ==false then
			 	 	return nContenType,nMapId;
			 	 else
			 	 	nIndex = nIndex + 1;
			 	 end
			 	 
			 	 
			elseif 	nContenType == SM_TASK_CONTENT_TYPE.ITEM then
			--收集任务
				LogInfo("QBW6");
				local nItemId = cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_ID];
				local nMapId = cellDatas[_G.TASK_CEL_DATA.SM_TASK_CELL_MAP_ID];
			 	
				if IfTaskItemProgressFinished(nTaskId, nItemId) == false then
					return nContenType,nMapId;
				else
					nIndex = nIndex + 1;
				end
			end
		else
			
			local z =1;
		end
		
	end	
	
	--交任务
	LogInfo("QBW7");
	local nNpcId = GetTaskFinishNpcId(nTaskId);
	return SM_TASK_CONTENT_TYPE.NPC,nNpcId;
	
end
































