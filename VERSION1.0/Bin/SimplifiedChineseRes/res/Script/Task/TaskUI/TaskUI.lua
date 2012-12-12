---------------------------------------------------
--描述: 玩家任务UI
--时间: 2012.2.25
--作者: jhzheng
---------------------------------------------------
local p = TaskUI;

-- 任务详细tag
local ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE		= 24;
local ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT		= 23;
local ID_TASKLIST_D_CTRL_TEXT_29						= 29;
local ID_TASKLIST_D_CTRL_TEXT_27						= 27;
local ID_TASKLIST_D_CTRL_UI_TEXT_NPC					= 22;
local ID_TASKLIST_D_CTRL_BUTTON_TASK_ABANDON			= 30;
local ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACK			= 99;
local ID_TASKLIST_D_CTRL_TEXT_GOODS					= 36;
local ID_TASKLIST_D_CTRL_TEXT_MONEY					= 28;
local ID_TASKLIST_D_CTRL_TEXT_34						= 34;
local ID_TASKLIST_D_CTRL_TEXT_33						= 33;
local ID_TASKLIST_D_CTRL_TEXT_EXP						= 27;
local ID_TASKLIST_D_CTRL_TEXT_12						= 12;
local ID_TASKLIST_D_CTRL_TEXT_11						= 11;
local ID_TASKLIST_D_CTRL_TEXT_TASK_NAME				=15;
local ID_TASKLIST_D_CTRL_TEXT_8						= 8;
local ID_TASKLIST_D_CTRL_TEXT_TASK_INFO				= 21;
local ID_TASKLIST_D_CTRL_TEXT_5						= 5;
local ID_QUEST_CTRL_TEXT_23						= 32;
local ID_QUEST_CTRL_TEXT_22						= 31;
local ID_QUEST_CTRL_TEXT_134						= 134;

local ID_TASKLIST_D_CTRL_LIST_TASK					= 20;

local ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACKTASK		= 29;

--测试用 直接完成任务
local ID_TASKLIST_D_CTRL_BUTTON_TASK_FINISH			= 42;

-- 任务界面tag
local ID_TASKLIST_CTRL_CHECK_BUTTON_84			= 84;
local ID_TASKLIST_CTRL_BUTTON_CLOSE				= 5;
local ID_TASKLIST_CTRL_BUTTON_TASK_NOT			= 7;
local ID_TASKLIST_CTRL_BUTTON_TASK_ACC			= 6;
local ID_TASKLIST_CTRL_PICTURE_BG				= 120;
local ID_TASKLIST_CTRL_BUTTON_PGUP				= 37;
local ID_TASKLIST_CTRL_BUTTON_PAGEDOWN			= 39;
local ID_TASKLIST_CTRL_BUTTON_DOWN			= 13;



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
local bAcceptDetail =true ;--当前显示列表 true:Accept false:Unaccept


local winsize = GetWinSize();
local RectUILayer = CGRectMake(0, 0, winsize.w , winsize.h);

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
	--scene:AddChild(layer);
	scene:AddChildZ(layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("Quest_Bg.ini", layer, p.OnMainUIEvent, MAIN_OFFSET_X, MAIN_OFFSET_Y);

	local btnAccept = GetButton(layer, ID_TASKLIST_CTRL_BUTTON_TASK_ACC);
	if nil == btnAccept then
		layer:Free();
		uiLoad:Free();
		return false;
	end

	local rectBtnAccept		= btnAccept:GetFrameRect();
	local nOffsetDetailX	= rectBtnAccept.origin.x;
	local nOffsetDetailY	= rectBtnAccept.origin.y + rectBtnAccept.size.h;
	local rectDetail		= CGRectMake(0, 
										winsize.h*0.12,--75,
										RectUILayer.size.w, 
										RectUILayer.size.h
							  );--]]

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
			uiLoad:Load("QUEST.ini", layerDetail, p.OnAcceptUIEvent, 0, 0);
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
			uiLoad:Load("QUEST.ini", layerDetail, p.OnUnAcceptUIEvent, 0, 0);
			layerDetail:RemoveChildByTag(ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACK, true);
		end
		local btnAbandon = GetButton(layerDetail, ID_TASKLIST_D_CTRL_BUTTON_TASK_ABANDON);
		if btnAbandon then
			if i == 1 then
				btnAbandon:SetTitle("放弃任务");
			elseif i == 2 then
				--屏蔽自动接任务功能
				btnAbandon:SetVisible(false);
				--btnAbandon:SetTitle("接受任务");
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
		--
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
		end--]]
		
		
		-- 屏蔽测试按钮
		local btnTest = GetButton(layerDetail, ID_TASKLIST_D_CTRL_BUTTON_TASK_FINISH);
		btnTest:SetVisible(false);
		
	end
	

	--[[
	local pool = DefaultPool();
	local linePic  = pool:AddPicture(GetSMImgPath("mark_up.png"),true);
	--]]
	--[[
		local linePicImage = createNDUIImage();
		linePicImage:Init();
		linePicImage:SetTag(999);
		linePicImage:SetPicture(linePic,true);	
		--local sizeview		= view:GetFrameRect().size;
		linePicImage:SetFrameRect(CGRectMake(0, 0, 300 , 200));
		--layer:AddChildZ(linePicImage,10);
	
	--]]
	
	-- 刷新已接任务列表
	p.RefreshTaskList(true);
	-- 刷新可接任务列表
	p.RefreshTaskList(false);
	-- 显示已接任务列表
	p.ShowAccept(true)
    local pBtnAcc = GetButton( layer, ID_TASKLIST_CTRL_BUTTON_TASK_ACC );
    pBtnAcc:TabSel(true);    

	
	--刷新箭头按钮
	p.RefreshDownBtn(true);
	p.RefreshDownBtn(false);
	
	
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_TASKLIST_CTRL_BUTTON_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	
   	--增加选中光效
   	p.AddSelectEffect(true);
   	--增加选中光效
   	p.AddSelectEffect(false);
   		
end

function p.NavigateNpc(nNpcId)
	if not CheckN(nNpcId) then
		return;
	end
	NPC.Navigate(nNpcId);
end
---------------------------------------------------
-- 获得任务的UI层
function p.GetGuestUILayer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end

	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerTask);
	if nil == layer then
		return nil;
	end

	return layer;
end

function p.OnMainUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnMainUIEvent[%d]", tag);
    local pUILayer = p.GetGuestUILayer();
        
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_TASKLIST_CTRL_BUTTON_CLOSE == tag then
			--Music.PlayEffectSound(0)
			RemoveChildByTagNew(NMAINSCENECHILDTAG.PlayerTask, true,true);
			return true;
		elseif ID_TASKLIST_CTRL_BUTTON_TASK_ACC == tag then
			p.ShowAccept(true);
            local pBtnAcc = GetButton( pUILayer, ID_TASKLIST_CTRL_BUTTON_TASK_ACC );
            local pBtnNot = GetButton( pUILayer, ID_TASKLIST_CTRL_BUTTON_TASK_NOT );     
            pBtnAcc:TabSel(true);    
            pBtnNot:TabSel(false);   
                            
		elseif ID_TASKLIST_CTRL_BUTTON_TASK_NOT == tag then
			p.ShowAccept(false);
            local pBtnAcc = GetButton( pUILayer, ID_TASKLIST_CTRL_BUTTON_TASK_ACC );
            local pBtnNot = GetButton( pUILayer, ID_TASKLIST_CTRL_BUTTON_TASK_NOT );     
            pBtnAcc:TabSel(false);    
            pBtnNot:TabSel(true);   
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
	return true;

end

function p.DelSelectEffect(bAccept)
	local taskList = p.GetTaskList(bAccept);
	local nTaskId = nSelAcceptTaskId;
	
	if bAccept == false then
		nTaskId = nSelUnAcceptTaskId;
	end
	
	local pool = DefaultPicPool();
	
	if nTaskId == 0 then
		return;
	end
	
	local scrollView = taskList:GetViewById(nTaskId);
	
	local linePicImage =  RecursiveImage(scrollView, {999});
	
	if CheckP(linePicImage) == false then
		LogInfo("p.DelSelectEffect linePicImage nil:"..nTaskId);
		return;
	end
	
	--增加背景图
	local linePic  = pool:AddPicture(GetSMImgPath("General/texture/texture1.png"),true);
	linePicImage:SetPicture(linePic,true);
end

function p.AddSelectEffect(bAccept)
	local taskList = p.GetTaskList(bAccept);
	
	local nTaskId = nSelAcceptTaskId;
	
	if bAccept == false then
		nTaskId = nSelUnAcceptTaskId;
	end
	
	local pool = DefaultPicPool();
	
	if nTaskId == 0 then
		return;
	end
	LogInfo("p.AddSelectEffect GetViewById:"..nTaskId);
		
	local scrollView = taskList:GetViewById(nTaskId);
	
	local linePicImage =  RecursiveImage(scrollView, {999});
	
	if CheckP(linePicImage) == false then
		LogInfo("p.AddSelectEffect linePicImage nil:"..nTaskId);
		return;
	end
	--增加背景图
	local linePic  = pool:AddPicture(GetSMImgPath("General/texture/texture7.png"),true);
	linePicImage:SetPicture(linePic,true);
end


function p.OnAcceptTaskListUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnAcceptTaskListUIEvent[%d]", tag);
	--取消选中按钮状态
	p.DelSelectEffect(true)
	
	p.RefreshTaskDetail(true, tag);
	
	--添加选中状态
	p.AddSelectEffect(true);
	
	return true;
end

function p.OnUnAcceptTaskListUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUnAcceptTaskListUIEvent[%d]", tag);
	p.DelSelectEffect(false)
	
	p.RefreshTaskDetail(false, tag);
	
	p.AddSelectEffect(false);
	
	return true;
end




function p.RefreshDownBtn(bAccept)
		local scene = GetSMGameScene();
		local btnDown = nil;
		local tag = nil; 
		
		if bAccept then 
			tag = TAG_LAYER_ACCEPT;
		else
			tag = TAG_LAYER_UNACCEPT;
		end 
		

		btnDown = RecursiveUINode(scene,{NMAINSCENECHILDTAG.PlayerTask,tag,ID_TASKLIST_CTRL_BUTTON_DOWN}) 

		if btnDown == nil then
			LogInfo("qbw refreshbtn nil !!");
			return
		end
						

	if bAccept == false then
		LogInfo("false");
	else
		LogInfo("true");
	end
	
	local container = p.GetTaskList(bAccept);
	--container:ShowViewByIndex(0);
	local index = container:GetBeginIndex();
	--local nstyle = container:GetScrollStyle();
	--local viewsize = container:GetViewSize();
	local nViewCount = container:GetViewCount();
	--LogInfo("1111:"..index);
	if index + MAX_TASK_NUM_PER_PAGE < nViewCount then
		--index = index + MAX_TASK_NUM_PER_PAGE;
		--container:ShowViewByIndex(index);
		btnDown:SetVisible(true);
	else

		btnDown:SetVisible(false);
	end
	

end


function p.PageDown(bAccept)

	LogInfo("2222");
	
	if bAccept == false then
		LogInfo("false");
	else
		LogInfo("true");
	end
	
	local container = p.GetTaskList(bAccept);
	--container:ShowViewByIndex(0);
	local index = container:GetBeginIndex();
	local nViewCount = container:GetViewCount();
	
	if index + MAX_TASK_NUM_PER_PAGE < nViewCount - MAX_TASK_NUM_PER_PAGE then
		index = index + MAX_TASK_NUM_PER_PAGE;
		container:ShowViewByIndex(index);
		
	else
		LogInfo("1111");
		index = nViewCount - MAX_TASK_NUM_PER_PAGE;
		container:ShowViewByIndex(index);
		
	end
	local view = container:GetView(index);
	local nTaskId = view:GetViewId();
	p.RefreshTaskDetail(bAccept, nTaskId);
end

function p.PageUp(bAccept)

	local container = p.GetTaskList(bAccept);
	--container:ShowViewByIndex(0);
	local index = container:GetBeginIndex();
	local nViewCount = container:GetViewCount();
	
	if index - MAX_TASK_NUM_PER_PAGE >= 0 then
		index = index - MAX_TASK_NUM_PER_PAGE;
		container:ShowViewByIndex(index);
	else
		index = 0;
		container:ShowViewByIndex(index);	
	end
	
	local view = container:GetView(index);
	local nTaskId = view:GetViewId();
	p.RefreshTaskDetail(bAccept, nTaskId);	
end

function p.FinishTaskTest(nSelAcceptTaskId)
	TASK.FinishTask_TEST(nSelAcceptTaskId);
	

end


function p.OnAcceptUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnAcceptUIEvent[%d]", tag);
	--LogInfo("uiEventType:  "..uiEventType.."  click:"..NUIEventType.TE_TOUCH_BTN_CLICK);
	
	LogInfo("qbw refreshbtn1");
	p.RefreshDownBtn(true);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		--LogInfo("qbw"..tag);
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
		elseif tag == ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACKTASK then	
		--自动寻路
			TASK.TrackTask(nSelAcceptTaskId);
		elseif ID_TASKLIST_CTRL_BUTTON_PAGEDOWN == tag then	
		
			p.PageDown(true);	
			return true;
		elseif ID_TASKLIST_CTRL_BUTTON_PGUP == tag then	
			
			p.PageUp(true);
			return true;	
		elseif ID_TASKLIST_D_CTRL_BUTTON_TASK_FINISH == tag then
			p.FinishTaskTest(nSelAcceptTaskId);						
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

function p.OnUnAcceptUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnAcceptUIEvent[%d]", tag);
	
	p.RefreshDownBtn(false);
		
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
			
			   	
   		--测试用
			--DoFile("Drama/define.lua");
		-------
			
			
			TASK.AcceptTask(nSelUnAcceptTaskId);
			ShowLoadBar();
		elseif tag == ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACKTASK then	
		--自动寻路
			local nNpcId = TASK.GetTaskStartNpcId(nSelUnAcceptTaskId);
			CloseUI(NMAINSCENECHILDTAG.PlayerTask);
			-- 导航到npc
			p.NavigateNpc(nNpcId);	
		elseif ID_TASKLIST_CTRL_BUTTON_PAGEDOWN == tag then	
		
			p.PageDown(false);	
			return true;
		elseif ID_TASKLIST_CTRL_BUTTON_PGUP == tag then	
			
			p.PageUp(false);
			return true;				

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


	--完成则加上标识
	local bFinish = false;
	if bAccept == true then
		bFinish = TASK.CheckTaskCanFinish(nTaskId);
	end
	
	if bFinish then
		taskName = taskName.."(完成)";	
	end
	
	
	local pool = DefaultPicPool();
	
	LogInfo("p.AddTask 1");
	local view = createUIScrollView();
	if view ~= nil then
		view:Init(false);
		view:SetViewId(nTaskId);
		
		--增加背景图
		local linePic  = pool:AddPicture(GetSMImgPath("General/texture/texture1.png"),true);
		local linePicImage = createNDUIImage();
		linePicImage:Init();
		linePicImage:SetTag(999);
		linePicImage:SetPicture(linePic,true);	
		local sizeview		= view:GetFrameRect().size;
		LogInfo("sizeview "..sizeview.w.."  "..sizeview.h);
		local width = taskList:GetFrameRect().size.w*0.9
		local Height = width*0.16;
		linePicImage:SetFrameRect(CGRectMake(width*0.05, Height*0.25, width , Height));
		view:AddChildZ(linePicImage,1);

		--增加个背景按钮
		local bgBtn = createNDUIButton();
		bgBtn:Init();
		bgBtn:SetTag(nTaskId);
		local sizeview		= view:GetFrameRect().size;
		local width = taskList:GetFrameRect().size.w*0.9
		local Height = width*0.16;
		bgBtn:SetFrameRect(CGRectMake(width*0.05, Height*0.25, width , Height));
		view:AddChildZ(bgBtn,1);
		if bAccept then
			bgBtn:SetLuaDelegate((p.OnAcceptTaskListUIEvent));
		else
			bgBtn:SetLuaDelegate((p.OnUnAcceptTaskListUIEvent));
		end
		
		
		
		LogInfo("p.AddTask AddChildZ 999 nTaskId:"..nTaskId);
		taskList:AddView(view);
		local sizeview		= view:GetFrameRect().size;
		
		local hyperlinkBtn = nil;
		if bFinish then
			 hyperlinkBtn	= CreateHyperlinkButton(taskName, 
						CGRectMake(width*0.2, 0, sizeview.w , sizeview.h),
						TASK_NAME_FONT_SIZE,
						ccc4(0, 255, 0, 255));
		else
			 hyperlinkBtn	= CreateHyperlinkButton(taskName, 
						CGRectMake(width*0.2, 0, sizeview.w , sizeview.h),
						TASK_NAME_FONT_SIZE,
						ccc4(255, 255, 0, 255));											
		end		
		
			
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
			
			--[[
			local linePic  = pool:AddPicture(GetSMImgPath("mark_up.png"),true);
			local linePicImage = createNDUIImage();
			linePicImage:Init();
			linePicImage:SetTag(999);
			linePicImage:SetPicture(linePic,true);	
			hyperlinkBtn:AddChild(linePicImage);
			--]]
			
			
			view:AddChildZ(hyperlinkBtn,2);
			
			--取消选中
			p.DelSelectEffect(bAccept);
			
			if taskList:GetViewCount() <= 1 then
				p.RefreshTaskDetail(bAccept, nTaskId);
			end
			
			--选中
			p.AddSelectEffect(bAccept);
		end
	end
	
	p.ShowAccept(false)
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
	
	p.ShowAccept(true)
	
	--显示选中光效
	p.AddSelectEffect(bAccept);

	
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


	--如果是引导任务且未完成 则不显示自动寻路按钮
	local TrackBtn  = GetButton(pNodeDetailParent, ID_TASKLIST_D_CTRL_BUTTON_TASK_TRACKTASK);
	TrackBtn:SetVisible(true);
	if bAccept == true then
		local nTaskType		= TASK.GetDataBaseN(nTaskId, DB_TASK_TYPE.TYPE);
		if nTaskType == TASK_TYPE.GUIDE then
			if TASK.CheckTaskCanFinish(nTaskId) then
				TrackBtn:SetVisible(true);
			else
				TrackBtn:SetVisible(false);
			end
		end
	end

	--无任务则不显示子界面

	p.SetTaskTitle(pNodeDetailParent, nTaskId);

	p.SetTaskContent(pNodeDetailParent, nTaskId);

	p.SetTaskPrize(pNodeDetailParent, nTaskId);

	p.SetTaskStartNpc(pNodeDetailParent, nTaskId);

	p.SetTaskFinishNpc(pNodeDetailParent, nTaskId);

LogInfo("qbw: process aa"..nTaskId)
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
	
	--LogInfo("设置任务内容:"..nTaskId);
	
	if nTaskId == 0 then
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_TASK_INFO, "");
	else
		LogInfo("设置任务内容:"..TASK.GetTaskDesc(nTaskId));
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_TASK_INFO, TASK.GetTaskDesc(nTaskId));
	end
end

function p.SetTaskPrize(pParent, nTaskId)
	if nTaskId == 0 then
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_MONEY, "");
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_EXP, "");
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_GOODS, "");
		SetLabel(pParent, ID_QUEST_CTRL_TEXT_22, "");
		SetLabel(pParent, ID_QUEST_CTRL_TEXT_23, "");
		SetLabel(pParent, ID_QUEST_CTRL_TEXT_134, "");
	else
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_MONEY, SafeN2S(TASK.GetTaskPrizeMoney(nTaskId)));
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_EXP, SafeN2S(TASK.GetTaskPrizeExp(nTaskId)));
		SetLabel(pParent, ID_TASKLIST_D_CTRL_TEXT_GOODS, TASK.GetTaskPrizeItemStr(nTaskId));
		
		if TASK.GetTaskPrizeRepute(nTaskId) ~= 0 then
		
			SetLabel(pParent, ID_QUEST_CTRL_TEXT_22, "声望 "..SafeN2S(TASK.GetTaskPrizeRepute(nTaskId)) );
		else
			SetLabel(pParent, ID_QUEST_CTRL_TEXT_22, "");
		end
	
		if TASK.GetTaskPrizeSoul(nTaskId) ~= 0 then
		
			SetLabel(pParent, ID_QUEST_CTRL_TEXT_23, "将魂 "..SafeN2S(TASK.GetTaskPrizeSoul(nTaskId)) );
	
		else
			SetLabel(pParent, ID_QUEST_CTRL_TEXT_23, "");
		end
		local AWARD_ITEMTYPE1		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1));
		local AWARD_ITEMTYPE1_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1_NUM));
		local AWARD_ITEMTYPE2		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2));
		local AWARD_ITEMTYPE2_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2_NUM));
		local AWARD_ITEMTYPE3		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3));
		local AWARD_ITEMTYPE3_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3_NUM));
		
		local tAwardItem = {}
		tAwardItem[1] = {AWARD_ITEMTYPE1,AWARD_ITEMTYPE1_NUM};
		tAwardItem[2] = {AWARD_ITEMTYPE2,AWARD_ITEMTYPE2_NUM};
		tAwardItem[3] = {AWARD_ITEMTYPE3,AWARD_ITEMTYPE3_NUM};
		local strAward = "";
		for i=1,3 do
			if tAwardItem[i][1]~=0 and  tAwardItem[i][2]~=0 then
				strAward = strAward .. TASK.GetDataBaseDataS("itemtype", tAwardItem[i][1], DB_ITEMTYPE.NAME) .. " X" .. tAwardItem[i][2] .. "\n";
			end
		end
		
		SetLabel(pParent, ID_QUEST_CTRL_TEXT_134, strAward);
	end
end

function p.GetTaskPrizeContent(nTaskId)
	local exp = SafeN2S(TASK.GetTaskPrizeExp(nTaskId));
	local coin = SafeN2S(TASK.GetTaskPrizeMoney(nTaskId));
	local repute = SafeN2S(TASK.GetTaskPrizeRepute(nTaskId));
	local soul =SafeN2S(TASK.GetTaskPrizeSoul(nTaskId));
	local s = "获得任务奖励 经验:"..exp.."  银币:"..coin;
	
	local AWARD_ITEMTYPE1		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1));
	local AWARD_ITEMTYPE1_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1_NUM));
	local AWARD_ITEMTYPE2		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2));
	local AWARD_ITEMTYPE2_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2_NUM));
	local AWARD_ITEMTYPE3		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3));
	local AWARD_ITEMTYPE3_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3_NUM));
	
	local tAwardItem = {}
	tAwardItem[1] = {AWARD_ITEMTYPE1,AWARD_ITEMTYPE1_NUM};
	tAwardItem[2] = {AWARD_ITEMTYPE2,AWARD_ITEMTYPE2_NUM};
	tAwardItem[3] = {AWARD_ITEMTYPE3,AWARD_ITEMTYPE3_NUM};
	
	if repute ~= "0" then
		s = s.." 声望:"..repute;
	end

	if soul ~= "0" then
		s = s.." 将魂:"..soul;
	end		
	
	local strAward = "";
	for i=1,3 do
		if tAwardItem[i][1]~=0 and  tAwardItem[i][2]~=0 then
			LogInfo("itemtype i"..i)
			LogInfo("itemtype"..tAwardItem[i][1].." "..tAwardItem[i][2])
			strAward = strAward..TASK.GetDataBaseDataS("itemtype", tAwardItem[i][1], DB_ITEMTYPE.NAME).."  X" .. tAwardItem[i][2];
		end
	end	
	
	s = s..strAward;
	return s;
end


function p.GetTaskPrizeContentTable(nTaskId)
	local tContent = {}
	tContent[1] =""
	tContent[2] =""
	tContent[3] =""
	tContent[4] =""
	tContent[5] =""
	
	tContent[6] =""
	tContent[7] =""	
	
	local exp = SafeN2S(TASK.GetTaskPrizeExp(nTaskId));
	local coin = SafeN2S(TASK.GetTaskPrizeMoney(nTaskId));
	local repute = SafeN2S(TASK.GetTaskPrizeRepute(nTaskId));
	local soul =SafeN2S(TASK.GetTaskPrizeSoul(nTaskId));
	
	tContent[1] ="获得经验:"..exp;
	tContent[2] ="获得银币:"..coin;
	
	
	
	local AWARD_ITEMTYPE1		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1));
	local AWARD_ITEMTYPE1_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE1_NUM));
	local AWARD_ITEMTYPE2		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2));
	local AWARD_ITEMTYPE2_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE2_NUM));
	local AWARD_ITEMTYPE3		= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3));
	local AWARD_ITEMTYPE3_NUM	= ConvertN(TASK.GetDataBaseN(nTaskId, _G.DB_TASK_TYPE.AWARD_ITEMTYPE3_NUM));
	
	local tAwardItem = {}
	tAwardItem[1] = {AWARD_ITEMTYPE1,AWARD_ITEMTYPE1_NUM};
	tAwardItem[2] = {AWARD_ITEMTYPE2,AWARD_ITEMTYPE2_NUM};
	tAwardItem[3] = {AWARD_ITEMTYPE3,AWARD_ITEMTYPE3_NUM};
	
	if repute ~= "0" then
		tContent[6] ="获得声望:"..repute;
	end

	if soul ~= "0" then
		tContent[7] ="获得将魂:"..soul;	
	end		
	
	for i=1,3 do
		if tAwardItem[i][1]~=0 and  tAwardItem[i][2]~=0 then
			tContent[2+i] ="获得 "..TASK.GetDataBaseDataS("itemtype", tAwardItem[i][1], DB_ITEMTYPE.NAME).."  X" .. tAwardItem[i][2];
		end
	end	

	return tContent;
end










function p.SetTaskStartNpc(pParent, nTaskId)
	--LogInfo("qbw: start npc"..nTaskId)
	--LogInfo("qbw: start npc name"..NPC.GetNpcName(TASK.GetTaskStartNpcId(nTaskId)));
	if nTaskId == 0 then
		SetLabel(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT, "");
		--SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT, "");
	else
		SetLabel(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT, NPC.GetNpcName(TASK.GetTaskStartNpcId(nTaskId)));
		--SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_ACCEPT, NPC.GetNpcName(TASK.GetTaskStartNpcId(nTaskId)));
	end
end

function p.SetTaskFinishNpc(pParent, nTaskId)
	if nTaskId == 0 then
		SetLabel(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE, "");
		
		--SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE, "");
	else
		SetLabel(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE, NPC.GetNpcName(TASK.GetTaskFinishNpcId(nTaskId)));
		
		--SetHyperlinkButtn(pParent, ID_TASKLIST_D_CTRL_HYPER_TEXT_BUTTON_GIVE, NPC.GetNpcName(TASK.GetTaskFinishNpcId(nTaskId)));
	end
end

function p.SetTaskProcess(pParent, nTaskId)
	LogInfo("qbw: process bb")
	if not pParent or not CheckN(nTaskId) then
		LogInfo("qbw not pParent or not CheckN(nTaskId)");
		return;
	end
	local layerProcess = GetUiLayer(pParent, TAG_LAYER_TASK_PROGRESS);
	if not layerProcess then
		LogInfo("qbw not layerProcess");
		return;
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
			
			--local  lable = createNDUILabel();
			--lable:Init();
			--lable:SetText(text);
			
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
	LogInfo("qbw: process3")
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
	
	bAcceptDetail = bAccept;

	--如果没有任务则隐藏
	local taskList = p.GetTaskList(bAccept);
	if not taskList then
		return;
	end
	
    if taskList:GetViewCount() <= 0 then
		pNodeAccept:SetVisible(false);
		pNodeUnAccept:SetVisible(false);
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

