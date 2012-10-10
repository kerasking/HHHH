
local _G = _G;
setfenv(1, NPC);

-- 当玩家点击某个npc时,C++会先调用具体的npc点击处理方法,
-- 若没处理则c++则调用本方法,若有处理c++还会调用AttachTask以增加任务选项
function NPC_CLICK_COMMON(nNpcId)
	local config = NpcConfig[nNpcId];
	if not _G.CheckT(config) then
		LogInfo("npc[%d] not config", nNpcId);
		config = {};
	end
	
	local nSize		= table.getn(config);
	local title		= config[1] or "";
	local content	= config[2] or "";
	
	if "" == title then
		title = _G.ConvertS(GetNpcName(nNpcId));
	end
	
	OpenNpcDlg(nNpcId);
	SetTitle(title);
	SetContent(content);
	
	-- 选项
	for i=3, nSize, 2 do
		local strOption = config[i];
		local nAction = config[i+1];
		
		if not _G.CheckS(strOption) or not _G.CheckN(nAction) then
			LogInfo("NpcConfig param invalid");
			break;
		end
		if nil == strOption or nil == nAction then
			break;
		end
		
		AddOpt(strOption, nAction);
	end
	
	AttachTask(nNpcId);
	
    return true;
end 

function AttachTask(nNpcId)
	local nOptCnt	= _G.GetOptCount();
	if nOptCnt >= MAX_CHAT_OPTION_NUM then
		return;
	end
	
	local nTaskOpt	= MAX_CHAT_OPTION_NUM - nOptCnt;
	
	local idlistComplete		= _G.TASK.GetCanCompleteTaskList();
	local idlistUnComplete		= _G.TASK.GetUnCompleteTaskList();
	local idlistCanAccept		= _G.TASK.GetCanAcceptTasks();

	LogInfo("finish task");
	_G.LogInfoT(idlistComplete);
	LogInfo("un finish task");
	_G.LogInfoT(idlistUnComplete);
	LogInfo("can accept task");
	_G.LogInfoT(idlistCanAccept);
	LogInfo("attach task");

	
	
	--任务列表
	local idlistNpc = GetNpcTaskList(nNpcId);
	
	if not _G.CheckT(idlistNpc) then
		LogInfo("npc[%d] has not tasks", nNpcId);
		return;
	end
	_G.LogInfoT(idlistNpc);
	for m, n in ipairs(idlistComplete) do
		local nFinishTaskNpcId = _G.TASK.GetTaskFinishNpcId(n);
		LogInfo("task[%d], judge complete finish[%d], curnpc[%d]", n, nFinishTaskNpcId, nNpcId);
		if nFinishTaskNpcId == nNpcId then
			local taskname		= _G.ConvertS(_G.TASK.GetTaskName(n));
			taskname = "<cffff00" .. taskname .. "/e" .. "<cffffff(完成)/e";
			AddOpt(taskname, n);
			nTaskOpt = nTaskOpt - 1;
		end
	end

	
	for i, v in ipairs(idlistNpc) do
		if 0 == nTaskOpt then
			return;
		end

		for m, n in ipairs(idlistCanAccept) do
			if n == v then
				local taskname		= _G.ConvertS(_G.TASK.GetTaskName(v));
				taskname = "<cffff00" .. taskname .. "/e" .. "<cffffff(可接)/e";
				LogInfo("可接[%d]", n);
				AddOpt(taskname, n);
				nTaskOpt = nTaskOpt - 1;
			end
		end
	end
	
	for i, v in ipairs(idlistNpc) do
		if 0 == nTaskOpt then
			return;
		end

		for m, n in ipairs(idlistUnComplete) do
			if n == v then
				local taskname		= _G.ConvertS(_G.TASK.GetTaskName(v));
				taskname = "<cffff00" .. taskname .. "/e" .. "<cffffff(已接)/e";
				AddOpt(taskname, n);
				nTaskOpt = nTaskOpt - 1;
			end
		end
	end
end

-- 当点击npc界面选项时该脚本会先被调用然后再调具体某个npc选项的处理方法
function NPC_OPTION_COMMON(nNpcId, nAction)
	if type(nAction) ~= "number" or type(nNpcId) ~= "number" then
		LogInfo("NPC_OPTION_COMMON invalid");
		return false;
	end
	
	local idlistNpc	= GetNpcTaskList(nNpcId);

	--可接任务
	for	i, v in ipairs(idlistNpc) do
		if nAction == v then
			_G.OnDealTask(nAction);
			return true;
		end
	end
	
	--已接任务
	local idlistAcceptTask = _G.TASK.GetAcceptTasks();
	for i, v in ipairs(idlistAcceptTask) do
		if nAction == v then
			_G.OnDealTask(nAction);
			return true;
		end
	end
	
	local func = NpcOptionFunc[nAction];
	
	if nil == func or type(func) ~= "function" then
		LogInfo("NPC_OPTION_COMMON no func");
		return false;
	end

	func();
	
	CloseDlg();

	return true;
end