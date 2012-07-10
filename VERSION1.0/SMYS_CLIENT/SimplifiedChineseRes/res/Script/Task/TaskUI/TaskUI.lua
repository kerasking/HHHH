---------------------------------------------------
--描述: 玩家任务UI
--时间: 2012.2.25
--作者: jhzheng
---------------------------------------------------
local p = TaskUI;

-- 任务详细tag
local ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE		= 28;
local ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT		= 23;
local ID_TASKLIST_D_CTRL_PICTURE_63					= 63;
local ID_TASKLIST_D_CTRL_TEXT_29						= 29;
local ID_TASKLIST_D_CTRL_TEXT_27						= 27;
local ID_TASKLIST_D_CTRL_UI_TEXT_NPC					= 40;
local ID_TASKLIST_D_CTRL_BUTTON_TASK_ABANDON			= 38;
local ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACK			= 37;
local ID_TASKLIST_D_CTRL_TEXT_GOODS					= 36;
local ID_TASKLIST_D_CTRL_TEXT_MONEY					= 35;
local ID_TASKLIST_D_CTRL_TEXT_34						= 34;
local ID_TASKLIST_D_CTRL_TEXT_33						= 33;
local ID_TASKLIST_D_CTRL_TEXT_EXP						= 32;
local ID_TASKLIST_D_CTRL_TEXT_12						= 12;
local ID_TASKLIST_D_CTRL_TEXT_11						= 11;
local ID_TASKLIST_D_CTRL_TEXT_TASK_NAME				= 9;
local ID_TASKLIST_D_CTRL_TEXT_8						= 8;
local ID_TASKLIST_D_CTRL_TEXT_TASK_INFO				= 6;
local ID_TASKLIST_D_CTRL_TEXT_5						= 5;
local ID_TASKLIST_D_CTRL_LIST_TASK					= 26;


-- 任务界面tag
local ID_TASKLIST_CTRL_CHECK_BUTTON_84			= 84;
local ID_TASKLIST_CTRL_BUTTON_CLOSE				= 123;
local ID_TASKLIST_CTRL_BUTTON_TASK_NOT			= 122;
local ID_TASKLIST_CTRL_BUTTON_TASK_ACC			= 121;
local ID_TASKLIST_CTRL_PICTURE_BG				= 120;



-- 自定义界面tag
local TAG_LAYER_ACCEPT							= 1000;
local TAG_LAYER_UNACCEPT						= 1001;
local TAG_LAYER_TASK_PROGRESS						= 1002;

-- 界面控件坐标定义
local winsize = GetWinSize();
local MAIN_OFFSET_X								= 0;
local MAIN_OFFSET_Y								= 0;
local TASK_NAME_FONT_SIZE							= 14;
local TASK_NAME_FONT_HEIGHT							= winsize.h * 0.04375

-- 配置数据
local MAX_TASK_NUM_PER_PAGE				= 6;

-- 本地变量定义
local nSelAcceptTaskId					= 0;			-- 已接任务当前选中的任务id
local nSelUnAcceptTaskId				= 0;			-- 可接任务当前选中的任务id

function p.LoadUI()
	nSelAcceptTaskId	= 0;
	nSelUnAcceptTaskId	= 0;
	local scene = GetSMGameScene();
	--local director = DefaultDirector();
	--local scene = director:GetRunningScene();
	if nil == scene then
		LogInfo("scene == nil,load TaskUI failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerTask);
	layer:SetFrameRect(RectUILayer);
	--layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	scene:AddChild(layer);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("TaskList.ini", layer, p.OnMainUIEvent, MAIN_OFFSET_X, MAIN_OFFSET_Y);

	local btnAccept = GetButton(layer, ID_TASKLIST_CTRL_BUTTON_TASK_ACC);
	if nil == btnAccept then
		layer:Free();
		uiLoad:Free();
		return false;
	end

	local rectBtnAccept		= btnAccept:GetFrameRect();
	local nOffsetDetailX	= rectBtnAccept.origin.x;
	local nOffsetDetailY	= rectBtnAccept.origin.y + rectBtnAccept.size.h;
	local rectDetail		= CGRectMake(nOffsetDetailX, 
										nOffsetDetailY,
										RectUILayer.size.w - nOffsetDetailX * 2, 
										RectUILayer.size.h - nOffsetDetailY - winsize.h * 0.03125
							  );

	for i = 1, 2 do
		local layerDetail = createNDUILayer();
		if layerDetail == nil then
			layer:Free();
			uiLoad:Free();
			return false;
		end
		layerDetail:Init();
		if i == 1 then
	
			layerDetail:SetTag(TAG_LAYER_ACCEPT);
			uiLoad:Load("TaskList_D.ini", layerDetail, p.OnAcceptUIEvent, 0, 0);
			--任务进度层
			local pNode = GetUiNode(layerDetail, ID_TASKLIST_D_CTRL_UI_TEXT_NPC);
			if pNode then
				local rectProcess = pNode:GetFrameRect();
				local layerProcess = createNDUILayer();
				if nil ~= layerProcess then
					layerProcess:Init();
					layerProcess:SetTag(TAG_LAYER_TASK_PROGRESS);
					layerProcess:SetFrameRect(rectProcess);
					layerDetail:AddChild(layerProcess);
				end
			end
		elseif i == 2 then
			layerDetail:SetTag(TAG_LAYER_UNACCEPT);
			uiLoad:Load("TaskList_D.ini", layerDetail, p.OnUnAcceptUIEvent, 0, 0);
			layerDetail:RemoveChildByTag(ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACK, true);
		end
		local btnAbandon = GetButton(layerDetail, ID_TASKLIST_D_CTRL_BUTTON_TASK_ABANDON);
		if btnAbandon then
			if i == 1 then
				btnAbandon:SetTitle("放弃任务");
			elseif i == 2 then
				btnAbandon:SetTitle("接受任务");
			end
		end

		layerDetail:SetFrameRect(rectDetail);
		layer:AddChild(layerDetail);
		
		local bAccept;
		if i == 1 then
			bAccept = true;
		elseif i == 2 then
			bAccept = false;
		end
		local taskList = p.GetTaskList(bAccept);
		if taskList then
			local rectview = taskList:GetFrameRect();
			if nil ~= rectview then
				local nWidth	= rectview.size.w;
				local nHeight	= rectview.size.h / MAX_TASK_NUM_PER_PAGE;
				taskList:SetStyle(UIScrollStyle.Verical);
				taskList:SetViewSize(CGSizeMake(nWidth, nHeight));
				taskList:SetTopReserveDistance(rectview.size.h);
				taskList:SetBottomReserveDistance(rectview.size.h);
				taskList:EnableScrollBar(true);
			end
		end
	end
	
	-- 刷新已接任务列表
	p.RefreshTaskList(true);
	-- 刷新可接任务列表
	p.RefreshTaskList(false);
	-- 显示已接任务列表
	p.ShowAccept(true)
end

function p.NavigateNpc(nNpcId)
	if not CheckN(nNpcId) then
		return;
	end
	NPC.Navigate(nNpcId);
end

function p.OnMainUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnMainUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_TASKLIST_CTRL_BUTTON_CLOSE == tag then
			local scene = GetSMGameScene();
			--local director = DefaultDirector();
			--local scene = director:GetRunningScene();
			if scene ~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.PlayerTask, true);
				return true;
			end
		elseif ID_TASKLIST_CTRL_BUTTON_TASK_ACC == tag then
			p.ShowAccept(true);
		elseif ID_TASKLIST_CTRL_BUTTON_TASK_NOT == tag then
			p.ShowAccept(false);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
		local checkBox	= ConverToCheckBox(uiNode);
		if not CheckP(checkBox) then
			return true;
		end
		if tag == ID_TASKLIST_CTRL_CHECK_BUTTON_84 then
			if checkBox:IsSelect() then
				LogInfo("check box sel");
			else
				LogInfo("check box unsel");
			end
		end
	end
	return true;
end

function p.OnTaskDataUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	CloseUI(NMAINSCENECHILDTAG.PlayerTask);
	p.DealTaskData(nSelAcceptTaskId, tag);
	return true;
end

function p.OnAcceptTaskListUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnAcceptTaskListUIEvent[%d]", tag);
	p.RefreshTaskDetail(true, tag);
	return true;
end

function p.OnUnAcceptTaskListUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUnAcceptTaskListUIEvent[%d]", tag);
	p.RefreshTaskDetail(false, tag);
	return true;
end

function p.OnAcceptUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnAcceptUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT then
		-- 发布任务npc
			local nNpcId = TASK.GetTaskStartNpcId(nSelAcceptTaskId);
			CloseUI(NMAINSCENECHILDTAG.PlayerTask);
			-- 导航到npc
			p.NavigateNpc(nNpcId);
		elseif tag == ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE then
		-- 完成任务npc
			CloseUI(NMAINSCENECHILDTAG.PlayerTask);
			local nNpcId = TASK.GetTaskFinishNpcId(nSelAcceptTaskId);
			-- 导航到npc
			p.NavigateNpc(nNpcId);
		elseif tag == ID_TASKLIST_D_CTRL_BUTTON_TASK_ABANDON then
			--放弃任务
			if 0 >= nSelAcceptTaskId then
				return
			end
			TASK.DelTask(nSelAcceptTaskId);
			ShowLoadBar();
		elseif tag == ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACK then
			-- 任务追踪
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

function p.OnUnAcceptUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnAcceptUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if tag == ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT then
		-- 发布任务npc
			local nNpcId = TASK.GetTaskStartNpcId(nSelUnAcceptTaskId);
			CloseUI(NMAINSCENECHILDTAG.PlayerTask);
			-- 导航到npc
			p.NavigateNpc(nNpcId);
		elseif tag == ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE then
		-- 完成任务npc
			CloseUI(NMAINSCENECHILDTAG.PlayerTask);
			local nNpcId = TASK.GetTaskFinishNpcId(nSelUnAcceptTaskId);
			-- 导航到npc	
			p.NavigateNpc(nNpcId);
		elseif tag == ID_TASKLIST_D_CTRL_BUTTON_TASK_ABANDON then
		-- 接受任务
			if 0 >= nSelUnAcceptTaskId then
				return true;
			end
			TASK.AcceptTask(nSelUnAcceptTaskId);
			ShowLoadBar();
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end


-- 刷新任务列表
-- bAccept:是否是已接列表
function p.RefreshTaskList(bAccept)
	local taskList = p.GetTaskList(bAccept);
	if not taskList then
		return;
	end

	taskList:RemoveAllView();

	--获取任务列表
	local idlistAcceptTask;
	if bAccept then
		idlistAcceptTask = TASK.GetAcceptTasks();
	else
		idlistAcceptTask = TASK.GetCanAcceptTasks();
	end

	if 0 == table.getn(idlistAcceptTask) then
		p.RefreshTaskDetail(bAccept, 0);
		return;
	end

	for i, v in ipairs(idlistAcceptTask) do
		p.AddTask(bAccept, v);
	end
	
	p.RefreshTaskDetail(bAccept, idlistAcceptTask[1]);
end

-- 增加任务
-- bAccept:是否是已接任务
-- nTaskId:任务id;
function p.AddTask(bAccept, nTaskId)
	if not CheckB(bAccept) or not CheckN(nTaskId) then
		return;
	end

	local taskName = TASK.GetTaskName(nTaskId);
	if "" == taskName then
		return;
	end

	local taskList = p.GetTaskList(bAccept);
	if not taskList then
		return;
	end

	local view = createUIScrollView();
	if view ~= nil then
		view:Init(false);
		view:SetViewId(nTaskId);
		taskList:AddView(view);
		local sizeview		= view:GetFrameRect().size;
		local hyperlinkBtn	= CreateHyperlinkButton(taskName, 
					CGRectMake(0, 0, sizeview.w , sizeview.h),
					TASK_NAME_FONT_SIZE,
					ccc4(255, 255, 0, 255));
		if not hyperlinkBtn then
			taskList:RemoveViewById(nTaskId);
		else
			hyperlinkBtn:SetTag(nTaskId);
			if bAccept then
				hyperlinkBtn:SetLuaDelegate((p.OnAcceptTaskListUIEvent));
			else
				hyperlinkBtn:SetLuaDelegate((p.OnUnAcceptTaskListUIEvent));
			end
			hyperlinkBtn:EnableLine(false);
			view:AddChild(hyperlinkBtn);
			if taskList:GetViewCount() <= 1 then
				p.RefreshTaskDetail(bAccept, nTaskId);
			end
		end
	end
	
	--taskList:SetVisible(taskList:IsVisibled());
end
-- 删除任务
function p.DelAcceptTask(bAccept,nTaskId)
	if not CheckB(bAccept) or not CheckN(nTaskId) then
		return;
	end
	local taskList = p.GetTaskList(bAccept);
	if not taskList then
		return;
	end
	taskList:RemoveViewById(nTaskId);

	if nTaskId == nSelUnAcceptTaskId or nTaskId == nSelAcceptTaskId then
		local viewTask = taskList:GetView(0);
		if viewTask then
			p.RefreshTaskDetail(bAccept, viewTask:GetViewId());
		else
			p.RefreshTaskDetail(bAccept, 0);
		end
	end
	
	--taskList:SetVisible(taskList:IsVisibled());
end
-- 刷新任务详细
-- bAccept:是否是已接任务
-- nTaskId:任务id;
function p.RefreshTaskDetail(bAccept, nTaskId)
	if not CheckB(bAccept) then
		LogInfo("p.RefreshTaskDetail not CheckB(bAccept)");
		return;
	end

	local pNodeDetailParent;
	if bAccept then
		pNodeDetailParent = p.GetAcceptDetailParent();
	else
		pNodeDetailParent = p.GetUnAcceptDetailParent();
	end


	p.SetTaskTitle(pNodeDetailParent, nTaskId);

	p.SetTaskContent(pNodeDetailParent, nTaskId);

	p.SetTaskPrize(pNodeDetailParent, nTaskId);

	p.SetTaskStartNpc(pNodeDetailParent, nTaskId);

	p.SetTaskFinishNpc(pNodeDetailParent, nTaskId);

	p.SetTaskProcess(pNodeDetailParent, nTaskId);

	--pNodeDetailParent:SetVisible(pNodeDetailParent:IsVisibled());

	if bAccept then
		nSelAcceptTaskId	= nTaskId;
	else
		nSelUnAcceptTaskId	= nTaskId;
	end
end

function p.SetTaskTitle(pParent, nTaskId)
	if not pParent or not CheckN(nTaskId) then
		LogInfo("p.SetTaskTitle invalid arg");
		return;
	end
	if nTaskId == 0 then
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_TASK_NAME, "");
	else
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_TASK_NAME, TASK.GetTaskName(nTaskId));
	end
end

function p.SetTaskContent(pParent, nTaskId)
	if not pParent or not CheckN(nTaskId) then
		return;
	end
	if nTaskId == 0 then
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_TASK_INFO, "");
	else
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_TASK_INFO, TASK.GetTaskDesc(nTaskId));
	end
end

function p.SetTaskPrize(pParent, nTaskId)
	if nTaskId == 0 then
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_MONEY, "");
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_EXP, "");
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_GOODS, "");
	else
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_MONEY, SafeN2S(TASK.GetTaskPrizeMoney(nTaskId)));
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_EXP, SafeN2S(TASK.GetTaskPrizeExp(nTaskId)));
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_GOODS, TASK.GetTaskPrizeItemStr(nTaskId));
	end
end

function p.SetTaskStartNpc(pParent, nTaskId)
	if nTaskId == 0 then
		SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT, "");
	else
		SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT, NPC.GetNpcName(TASK.GetTaskStartNpcId(nTaskId)));
	end
end

function p.SetTaskFinishNpc(pParent, nTaskId)
	if nTaskId == 0 then
		SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE, "");
	else
		SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE, NPC.GetNpcName(TASK.GetTaskFinishNpcId(nTaskId)));
	end
end

function p.SetTaskProcess(pParent, nTaskId)
	if not pParent or not CheckN(nTaskId) then
		LogInfo("not pParent or not CheckN(nTaskId)");
		return;
	end
	local layerProcess = GetUiLayer(pParent, TAG_LAYER_TASK_PROGRESS);
	if not layerProcess then
		LogInfo("not layerProcess");
		return
	end
	layerProcess:RemoveAllChildren(true);
	
	if nTaskId == 0 then
		return;
	end
	
	local processlist = TASK.GenerateContentTable(nTaskId);
	if 0 == table.getn(processlist) then
		return;
	end
	
	local x = 0;
	local y = 0;
	local nData = 0;
	local nIndex = 0;
	for i, v in ipairs(processlist) do
		local size;
		if i % 2 == 0 then
			local taskData	= p.GetTaskDataProcessStr(nTaskId, nIndex);
			local text		= v .. taskData;
			local color		= ccc4(255, 0, 0, 255);
			size			= GetHyperLinkTextSize(ConvertS(text), 14, layerProcess:GetFrameRect().size.w);
			local rect		= CGRectMake(x, y, size.w, size.h);
			local hyperlinkbtn	= CreateHyperlinkButton(text, rect, 14, color);
			hyperlinkbtn:SetTag(nIndex);
			hyperlinkbtn:SetLuaDelegate(p.OnTaskDataUIEvent);
			layerProcess:AddChild(hyperlinkbtn);
			nIndex			= nIndex + 1;
		else
			local tip		= ConvertS(p.GetTaskDataTip(nTaskId, nIndex));
			size			= GetStringSize(ConvertS(tip), 14);
			local rect		= CGRectMake(x, y, size.w, size.h);
			
			if "" ~= tip then
				local color		= ccc4(255, 255, 0, 255);
				local lable		= CreateLabel(tip, rect, 14, color);
				layerProcess:AddChild(lable);
			end
		end
		
		if i % 2 == 0 then
			x	= 0;
			y	= y + size.h + GetWinSize().h * 0.025;
		else
			x = x + size.w;
		end
	end
end


-- 显示已接或未接任务列表
function p.ShowAccept(bAccept)
	if not CheckB(bAccept) then
		return;
	end

	local pNodeAccept		= p.GetAcceptDetailParent();
	local pNodeUnAccept		= p.GetUnAcceptDetailParent();
	
	if  pNodeAccept then
		pNodeAccept:SetVisible(bAccept);
	end
	
	if  pNodeUnAccept then
		pNodeUnAccept:SetVisible(not bAccept);
	end
end

-- 获取已接任务详细父节点
function p.GetAcceptDetailParent()
	local pParent = GetUI(NMAINSCENECHILDTAG.PlayerTask);
	if not pParent then
		return nil;
	end
	
	local layer = GetUiLayer(pParent, TAG_LAYER_ACCEPT);
	return layer;
end

-- 获取未接任务详细父节点
function p.GetUnAcceptDetailParent()
	local pParent =  GetUI(NMAINSCENECHILDTAG.PlayerTask);
	if not pParent then
		return nil;
	end
	
	local layer = GetUiLayer(pParent, TAG_LAYER_UNACCEPT);
	return layer;
end

-- 获取任务列表UI
-- bAccept: 是否是已接任务列表
function p.GetTaskList(bAccept)
	if nil == bAccept or type(bAccept) ~= "boolean" then
		return nil;
	end
	local pDetailParent;
	if not bAccept then
		pDetailParent = p.GetUnAcceptDetailParent();
	else
		pDetailParent = p.GetAcceptDetailParent();
	end
	if not pDetailParent then
		return nil;
	end
	return GetScrollViewContainer(pDetailParent, ID_TASKLIST_D_CTRL_LIST_TASK);
end

