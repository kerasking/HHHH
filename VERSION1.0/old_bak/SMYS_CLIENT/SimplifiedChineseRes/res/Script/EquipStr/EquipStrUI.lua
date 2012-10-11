---------------------------------------------------
--描述: 装备UI
--时间: 2012.3.30
--作者: fyl
---------------------------------------------------
--bg
local ID_EQUIPSTR_CTRL_BUTTON_QUESTR				= 26;
local ID_EQUIPSTR_CTRL_BUTTON_LIST3				    = 25;
local ID_EQUIPSTR_CTRL_BUTTON_LIST2				    = 24;
local ID_EQUIPSTR_CTRL_BUTTON_LIST1				    = 23;
local ID_EQUIPSTR_CTRL_TEXT_LIST3					= 22;
local ID_EQUIPSTR_CTRL_TEXT_LIST2					= 21;
local ID_EQUIPSTR_CTRL_TEXT_LIST1					= 20;
local ID_EQUIPSTR_CTRL_LIST_EQUIP					= 19;
local ID_EQUIPSTR_CTRL_LIST_46					    = 46;
local ID_EQUIPSTR_CTRL_TEXT_72					    = 72;
local ID_EQUIPSTR_CTRL_TEXT_LEVEL_R2				= 65;
local ID_EQUIPSTR_CTRL_TEXT_STATE_R2				= 64;
local ID_EQUIPSTR_CTRL_TEXT_STATE_R1				= 63;
local ID_EQUIPSTR_CTRL_TEXT_LEVEL_R1				= 62;
local ID_EQUIPSTR_CTRL_TEXT_COST					= 338;
local ID_EQUIPSTR_CTRL_BUTTON_CLOSE				    = 336;
local ID_EQUIPSTR_CTRL_BUTTON_STRENGTHEN			= 335;
local ID_EQUIPSTR_CTRL_TEXT_NAME_R2			    	= 334;
local ID_EQUIPSTR_CTRL_OBJECT_BUTTON_R2				= 333;
local ID_EQUIPSTR_CTRL_TEXT_NAME_R1			     	= 331;
local ID_EQUIPSTR_CTRL_OBJECT_BUTTON_R1			    = 330;
local ID_EQUIPSTR_CTRL_TEXT_322					    = 322;
local ID_EQUIPSTR_CTRL_PICTURE_TITLE				= 73;
local ID_EQUIPSTR_CTRL_PICTURE_BG_RIGHT			    = 83;
local ID_EQUIPSTR_CTRL_PICTURE_BG					= 305;

--Equip_L
local ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_6			= 80;
local ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_5			= 79;
local ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_4			= 78;
local ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_3			= 77;
local ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_2			= 76;
local ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_1			= 75;
local ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_2				= 329;
local ID_EQUIPSTR_L_CTRL_TEXT_LV_6					= 327;
local ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_6				= 326;
local ID_EQUIPSTR_L_CTRL_TEXT_LV_4					= 325;
local ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_4				= 324;
local ID_EQUIPSTR_L_CTRL_TEXT_LV_2					= 323;
local ID_EQUIPSTR_L_CTRL_TEXT_322					= 322;
local ID_EQUIPSTR_L_CTRL_TEXT_LV_5					= 321;
local ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_5				= 320;
local ID_EQUIPSTR_L_CTRL_TEXT_LV_3					= 319;
local ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_3				= 318;
local ID_EQUIPSTR_L_CTRL_TEXT_LV_1					= 317;
local ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_1				= 316;
local ID_EQUIPSTR_L_CTRL_BUTTON_1					= 66;
local ID_EQUIPSTR_L_CTRL_BUTTON_3					= 68;
local ID_EQUIPSTR_L_CTRL_BUTTON_5					= 70;
local ID_EQUIPSTR_L_CTRL_BUTTON_2					= 67;
local ID_EQUIPSTR_L_CTRL_BUTTON_4					= 69;
local ID_EQUIPSTR_L_CTRL_BUTTON_6					= 71;
local ID_EQUIPSTR_L_CTRL_PICTURE_BG_LEFT			= 82;


EquipStrUI = {}
local p = EquipStrUI;

local TAG_EQUIP_PIC_LIST = {};			                --装备图片tag列表
local TAG_EQUIP_BTN_LIST = {};			                --装备按钮tag列表
local TAG_EQUIP_TEXT_LIST = {};			                --装备名称tag列表
local TAG_EQUIP_LV_TEXT_LIST = {};	                	--装备等级tag列表

--装备id列表
local currentEquipIdList = {};
--装备索引列表
local currentEquipIndexList = {};


--选中装备的id
local currentEquipId = 0;   
--选中装备的index                        
local currentEquipIndex = Item.POSITION_EQUIP_1;
  
local reqMoney;
local reqEMoney;
--当前装备试图id
local currentViewId = 0;

--是否可以强化
local enhanceEnable = true;

--已开通的强化队列数
local queneNum;

--强化队列倒计时秒数
local timeNum1 = 0 ;
local timeNum2 = 0 ;
local timeNum3 = 0 ;

--倒计时标识
local nProcessTimeTag1 = 0;
local nProcessTimeTag2 = 0;
local nProcessTimeTag3 = 0;

--当前队列
local currentQuene = 1;
local currentMin = 1; 
local nParam = 1;

local lastOsTime1 = 0; 
local lastOsTime2 = 0; 
local lastOsTime3 = 0; 

----------------------

--响应增加强化队列
function p.ResAddQuene()
	CommonDlg.ShowTipInfo("提示", "开启队列成功!", nil, 2);
	queneNum = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_QUEUE_COUNT);
	queneNum = queneNum + 1;
	LogInfo("增加成功，已开通强化队列数queneNum：%d",queneNum)
	
	if not enhanceEnable then
	    enhanceEnable = true;
		p.SetEquipStrBtnTitle("强化")
		currentQuene = queneNum;
	end
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end
		
	if queneNum == 2 then
		--显示强化队列2
		local equipStrQueneText2 = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST2);
		equipStrQueneText2:SetFontColor(ccc4(255,255,255,255));
		equipStrQueneText2:SetText("2:可强化")
	    local equipStrQueneBtn2 = GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_LIST2);
		equipStrQueneBtn2:SetVisible(true);
		equipStrQueneBtn2:SetLuaDelegate(p.OnUIEventClearQueneCD);
		
		local newStrQueneText = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST3);
		newStrQueneText:SetVisible(true);
	    newStrQueneText:SetText("开启更多队列");
	    newStrQueneText:SetFontColor(ccc4(0,0,255,255));

	elseif queneNum == 3 then
		--显示强化队列3   
		local equipStrQueneText3 = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST3);
		equipStrQueneText3:SetFontColor(ccc4(255,255,255,255));
		equipStrQueneText3:SetText("3:可强化")
		local equipStrQueneBtn3 = GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_LIST3);
		equipStrQueneBtn3:SetVisible(true);
		equipStrQueneBtn3:SetLuaDelegate(p.OnUIEventClearQueneCD);
			
		local btn = GetButton(layer, ID_EQUIPSTR_CTRL_BUTTON_QUESTR);
		btn:SetTitle("永久消除CD");   
	end	  
end

--响应永久消除强化CD
function p.ResEliminateCD()
    LogInfo("开通永久强化队列")
	queneNum = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_QUEUE_COUNT);
	LogInfo("已开通强化队列数queneNum：%d",queneNum)
    CommonDlg.ShowTipInfo("提示", "开通永久消除强化CD成功!", nil, 2);
	if nProcessTimeTag1 ~= 0 then
		UnRegisterTimer(nProcessTimeTag1);
	end
	if nProcessTimeTag2 ~= 0 then
		UnRegisterTimer(nProcessTimeTag2);
	end
	if nProcessTimeTag3 ~= 0 then
		UnRegisterTimer(nProcessTimeTag3);
	end	
	
	if not enhanceEnable then
	    enhanceEnable = true;
		p.SetEquipStrBtnTitle("强化")
	end
    p.setStrQueneButtonVisiable();
end

--响应清除强化队列时间
function p.ResClearTime(nParam)
	CommonDlg.ShowTipInfo("提示", "清除强化队列冷却时间成功!", nil, 2);
	if nParam  == 1 then
	    timeNum1 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
		lastOsTime1 = 0;
	elseif nParam == 2 then
	    timeNum2 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME2);
		lastOsTime2 = 0;
	elseif nParam == 3 then
	    timeNum3 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME3);
		lastOsTime3 = 0;	
	end
end

--强化队列i是否冷却中
function p.IsStrFree(num)
    if not CheckN(num) then
	    return false;
	end
	
	if num == 1 then 
	    if timeNum1 == 0 then
		    return true;
		else
		    return false;
		end
		
	elseif num == 2 then
		if timeNum1 == 0 then
		    return true;
		else
		    return false;
		end  
		 
	elseif num == 3 then
		if timeNum1 == 0 then
		    return true;
		else
		    return false;
		end
	 
	else
	    return false; 
	end		

end


--响应装备强化
function p.ResEquipStr()
    LogInfo("响应强化成功")
    CommonDlg.ShowTipInfo("提示", "强化成功!", nil, 2);
    local picTag,nameTextTag,lvTextTag,btnTag = p.GetEquipTag(currentEquipIndex);	
	local container  = p.GetPetParent();
	local currentView = container:GetBeginView();	
			
	if lvTextTag > 0 then
		local equipLv = Item.GetItemInfoN(currentEquipId, Item.ITEM_ADDITION);
		LogInfo("强化后装备等级：%d",equipLv+1);		
		SetLabel(currentView, lvTextTag, EquipStrFunc.GetLevelName(equipLv));
	end
	
    p.RefreshEquipRight();	
	
	if queneNum == 256 then
	    return;
	end	
			
	--local duplicateId = 901700000;
	--local timeNum = 0;
	--local duplicateId = AffixBossFunc.getNormalBossMaxId();
	--LogInfo("已完成的副本ID：%d",duplicateId);
	--if duplicateId < 901800000 then 
	--	timeNum = 60;
	--elseif duplicateId < 902700000 then
	--	timeNum = 180;
	--else
	--	timeNum = 300;
	--end
	
	LogInfo("当前使用的的强化队列:%d",currentQuene)
	if currentQuene == 1 then
	    timeNum1 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
		lastOsTime1 = timeNum1 + GetCurrentTime();
	    LogInfo("timeNum1:%d",timeNum1)
		nProcessTimeTag1 = RegisterTimer(p.OnProcessTimer1, 1); 
	elseif currentQuene == 2 then
			timeNum2 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME2);
			lastOsTime2 = timeNum2 + GetCurrentTime();
			LogInfo("timeNum2:%d",timeNum2)
			nProcessTimeTag2 = RegisterTimer(p.OnProcessTimer2, 1); 
	elseif currentQuene == 3 then
			timeNum3 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME3);
			lastOsTime3 = timeNum3 + GetCurrentTime();
			LogInfo("timeNum3:%d",timeNum3)
			nProcessTimeTag3 = RegisterTimer(p.OnProcessTimer3, 1); 

	end
		
	
	if queneNum == 1 then
		--强化队列只有1个，不可继续强化
	    enhanceEnable = false;
		currentQuene = -1;
	elseif queneNum == 2 or queneNum == 3 then
	        currentQuene  = -1 ;
	        for i = 1,queneNum do 
			     if p.IsStrFree(i) then
				     currentQuene = i ;
				     break;
				 end
			end
			if currentQuene == -1 then
				enhanceEnable = false;
			    local minTime = timeNum1;
				currentMin = 1;
				if timeNum2 < minTime then
				     minTime = timeNum2;
					 currentMin = 2;
				end
				if timeNum3 < minTime and queneNum == 3 then
				     minTime = timeNum3;
					 currentMin = 3;
				end
				LogInfo("currentMin:%d",currentMin)
			end   	
			LogInfo("下一个可以强化的队列:%d",currentQuene)
	
	end
end

function p.OnProcessTimer1(nTag)	
	if queneNum == 256 then
	    return;
	end
	local stage = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_STAGE);
	--LogInfo("玩家阶段stage:%d",stage)
	--stage = 21;
	
	if timeNum1 == 0 then
	    if not enhanceEnable then 
		    enhanceEnable = true;
			currentQuene = 1;
			p.SetEquipStrBtnTitle("强化");
		end 
	    if nProcessTimeTag1 ~= 0 then
          UnRegisterTimer(nProcessTimeTag1);
		end
		if queneNum == 2 or queneNum == 3 or stage >= 281 then 
		    p.SetEquipStrQueneInfo("1:可强化",ID_EQUIPSTR_CTRL_TEXT_LIST1);
		end	
		return;
	end
	
	local timeStr = p.calculateTime(timeNum1);
	if queneNum == 1 then
	    p.SetEquipStrBtnTitle("冷却时间"..timeStr);
	elseif currentMin == 1 and currentQuene == -1 then
		    p.SetEquipStrBtnTitle("冷却时间"..timeStr);
	end
	
	if queneNum > 1 or stage >= 281 then 
		local timeStr = "1:CD"..timeStr;
	    p.SetEquipStrQueneInfo(timeStr,ID_EQUIPSTR_CTRL_TEXT_LIST1);
	end	
	timeNum1 = timeNum1 - 1;
	LogInfo("timeNum1:%d",timeNum1)
end

function p.OnProcessTimer2(nTag)		
	if timeNum2 == 0 then
		if not enhanceEnable then 
		    enhanceEnable = true;
			currentQuene = 2;
			p.SetEquipStrBtnTitle("强化");
		end 
	    if nProcessTimeTag2 ~= 0 then
          UnRegisterTimer(nProcessTimeTag2);
		end
		p.SetEquipStrQueneInfo("2:可强化",ID_EQUIPSTR_CTRL_TEXT_LIST2);
		return;
	end
	
	local timeStr = p.calculateTime(timeNum2);
	if currentMin == 2 and currentQuene == -1 then
		p.SetEquipStrBtnTitle("冷却时间"..timeStr);
	end
	
	local timeStr = "2:CD"..timeStr;
	--LogInfo(timeStr);
	
	p.SetEquipStrQueneInfo(timeStr,ID_EQUIPSTR_CTRL_TEXT_LIST2);

	timeNum2 = timeNum2 - 1;	
	LogInfo("timeNum2:%d",timeNum2)
end

function p.OnProcessTimer3(nTag)	
	if timeNum3 == 0 then
		if not enhanceEnable then 
		    enhanceEnable = true;
			currentQuene = 3;
			p.SetEquipStrBtnTitle("强化");
		end 
	    if nProcessTimeTag3 ~= 0 then
          UnRegisterTimer(nProcessTimeTag3);
		end
		p.SetEquipStrQueneInfo("3:可强化",ID_EQUIPSTR_CTRL_TEXT_LIST3);
		return;
	end
	
	local timeStr = p.calculateTime(timeNum3);
	if currentMin == 3 and currentQuene == -1 then
		p.SetEquipStrBtnTitle("冷却时间"..timeStr);
	end
	
	local timeStr = "3:CD"..timeStr;
	--LogInfo(timeStr);
	
	p.SetEquipStrQueneInfo(timeStr,ID_EQUIPSTR_CTRL_TEXT_LIST3);
	timeNum3 = timeNum3 - 1;
	LogInfo("timeNum3:%d",timeNum3)
end


function p.SetEquipStrQueneInfo(title,textId)
	local scene = GetSMGameScene();
	if nil == scene then
		    return nil;
	end		
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end		
	
	--SetLabel(layer,textId,title);
	
	local equipStrQueneText = GetLabel(layer,textId);
	equipStrQueneText:SetText(title);
	equipStrQueneText:SetVisible(true);
	
end 


function p.SetEquipStrBtnTitle(title)
	local scene = GetSMGameScene();
	if nil == scene then
		    return nil;
	end		
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end		
	
	local equipStrBtn =  GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_STRENGTHEN);
	equipStrBtn:SetTitle(title);
	
end 



function p.calculateTime(timeNum)
  local timeStr = "";
    
  local time = math.floor(timeNum/60);
  timeStr = timeStr..string.format("%02d",time)..":";
  
  time=timeNum%60;
  timeStr =  timeStr..string.format("%02d",time);
  return timeStr;
end


function p.LoadUI()
	LogInfo("LoadUI");
    p.InitTag();
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load EquipmentUI failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.EquipStr);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("EquipStr.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	

	--设置强化按钮监听事件
	local equipStrBtn =  GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_STRENGTHEN);
	equipStrBtn:SetLuaDelegate(p.OnUIEventSelectEquipStrBtn);
	
	--左侧装备列表
    local container = RecursiveSVC(scene, { NMAINSCENECHILDTAG.EquipStr, ID_EQUIPSTR_CTRL_LIST_EQUIP});
	if not CheckP(container) then
		layer:Free();
		return false;
	end
	container:SetViewSize(container:GetFrameRect().size);
	container:SetLuaDelegate(p.OnUIEventViewChange);	
	
	--顶部角色名称
	local petNameContainer	= RecursiveSVC(scene, { NMAINSCENECHILDTAG.EquipStr, ID_EQUIPSTR_CTRL_LIST_46})
	if CheckP(petNameContainer) then
		petNameContainer:SetCenterAdjust(true);
		petNameContainer:SetViewSize(petNameContainer:GetFrameRect().size);
		local size		= petNameContainer:GetFrameRect().size;
		local viewsize	= CGSizeMake(size.w / 3, size.h);
		petNameContainer:SetLeftReserveDistance(size.w / 2 + viewsize.w / 2);
		petNameContainer:SetRightReserveDistance(size.w / 2 - viewsize.w / 2);
		petNameContainer:SetViewSize(viewsize);
		petNameContainer:SetLuaDelegate(p.OnUIEventViewChange);
	end
	
	p.RefreshContainer();
	
	return true;
end

function p.AddPetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
    LogInfo("增加角色名称");
	
	local scene = GetSMGameScene();
	if nil == scene then
	    LogInfo("scene is nil");
		return nil;
	end		
    local container = RecursiveSVC(scene, { NMAINSCENECHILDTAG.EquipStr, ID_EQUIPSTR_CTRL_LIST_46});
	
	if not CheckP(container) then
		LogInfo("petNameContainer is nil");
		return;
	end
	
	local view = createUIScrollView();
	if not CheckP(view) then
		return;
	end
	view:Init(false);
	view:SetViewId(nPetId);
	container:AddView(view);
	
	local strPetName = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	
	local size	= view:GetFrameRect().size;
	local btn	= _G.CreateButton("", "", strPetName, CGRectMake(0, 0, size.w, size.h), 15);
	if CheckP(btn) then
		btn:SetLuaDelegate(p.OnUIEventClickPetName);
		view:AddChild(btn);
		LogInfo(strPetName);
	end
end

function p.AddBagToPetNameContainer()
	local scene = GetSMGameScene();
	if nil == scene then
	    LogInfo("scene is nil");
		return nil;
	end		
    local container = RecursiveSVC(scene, { NMAINSCENECHILDTAG.EquipStr, ID_EQUIPSTR_CTRL_LIST_46});
	
	if not CheckP(container) then
		return;
	end
	
	local view = createUIScrollView();
	if not CheckP(view) then
		return;
	end
	view:Init(false);
	--用viewId=0表示背包
	view:SetViewId(0);
	container:AddView(view);
	
	local size	= view:GetFrameRect().size;
	local btn	= _G.CreateButton("", "", "背包", CGRectMake(0, 0, size.w, size.h), 15);
	if CheckP(btn) then
		view:AddChild(btn);
		btn:SetLuaDelegate(p.OnUIEventClickPetName);
	end
end 

function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end
	
	local containter = RecursiveSVC(layer, {ID_EQUIPSTR_CTRL_LIST_EQUIP});
	
	return containter;
end

function p.GetPetNameContainer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end
	
	local containter = RecursiveSVC(layer, {ID_EQUIPSTR_CTRL_LIST_46});
	
	return containter;
end


function p.RefreshContainer()
	local container = p.GetPetParent();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	--获取玩家伙伴id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
		LogInfo("nil == idTable");
		return;
	end
	
	LogInfo("p.RefreshContainer,伙伴id列表 playerIdList:");
	LogInfoT(idTable);
    
	--遍历伙伴
	for i, v in ipairs(idTable) do
	    --顶部角色名称
		p.AddPetName(v);
	
		local view = createUIScrollView();
		if view == nil then
			LogInfo("view == nil");
			continue;
		end
		view:Init(false);
		view:SetViewId(v);
		container:AddView(view);

		local uiLoad = createNDUILoad();
		if uiLoad ~= nil then
			uiLoad:Load("EquipStr_L.ini", view, p.OnUIEventScroll, 0, 0);
			uiLoad:Free();
		end
		
		--装备
		local equipIdList = ItemPet.GetEquipItemList(nPlayerId, v);
	    LogInfo("p.RefreshContainer,装备id列表 equipIdList：");
		LogInfoT(equipIdList);
		
		local equipIndex = Item.POSITION_EQUIP_1;
		--遍历装备
		for i, v in ipairs(equipIdList) do
			p.AddEquipViewContent(view,equipIndex,v);	
			equipIndex = equipIndex + 1;   	
		end
		
		--设置控件隐藏
        p.setEquipItemVisiable(view,equipIndex);		
	end   
	
	
	--添加背包装备至列表
	p.AddBagToPetNameContainer();
	
	local view = createUIScrollView();
	if view == nil then
		LogInfo("Create Bag view == nil");
	end
	view:Init(false);
	view:SetViewId(0);
	container:AddView(view);

	local uiLoad = createNDUILoad();
	if uiLoad ~= nil then
		uiLoad:Load("EquipStr_L.ini", view, p.OnUIEventScroll, 0, 0);
		uiLoad:Free();
	end
	
	LogInfo("背包中物品")
	local itemIdList = ItemUser.GetBagItemList(GetPlayerId());
	if itemIdList ~= nil then
	    LogInfoT(itemIdList);
	end
	equipIndex = Item.POSITION_EQUIP_1;
	--local count = 0;
	
	for i,v in ipairs(itemIdList) do
	  if equipIndex - Item.POSITION_EQUIP_1 >= 6 then
	      break;
	  end
	  if  ItemFunc.CanEquip(v) then   --装备类物品
		   p.AddEquipViewContent(view,equipIndex,v);
		   equipIndex = equipIndex + 1;  
	  end

	end
	
	--设置控件隐藏
    p.setEquipItemVisiable(view,equipIndex);
	
	--设置强化队列
	p.setStrQuene();

end

function p.setStrQuene()
	p.setStrQueneButtonVisiable();
	
	--服务器下发的（0/1/2/255）对应玩家开通了(1/2/3/永久)强化队列
	queneNum = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_QUEUE_COUNT);
	queneNum = queneNum + 1;
	LogInfo("已开通强化队列数queneNum：%d",queneNum)
	
	--读取三个强化队列的冷却时间
	--第一次打开强化面板，读取服务端下发的数据
	if lastOsTime1 == 0 then		
		timeNum1 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1);
		lastOsTime1 = GetCurrentTime() + timeNum1;
	else
		timeNum1 = lastOsTime1 - GetCurrentTime();	 
	end	
	
	if lastOsTime2 == 0 then		
		timeNum2 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME2);
		lastOsTime2 = GetCurrentTime() + timeNum2;
	else
		timeNum2 = lastOsTime2 - GetCurrentTime();	 
	end	
	
	if lastOsTime3 == 0 then		
		timeNum3 = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME3);
		lastOsTime3 = GetCurrentTime() + timeNum3;
	else
		timeNum3 = lastOsTime3 - GetCurrentTime();	 
	end	

    --设置左侧三个强化队列的文字信息
	if queneNum == 1 then
		p.IntroNewEquipStrQuene(ID_EQUIPSTR_CTRL_TEXT_LIST2,ID_EQUIPSTR_CTRL_BUTTON_LIST2); 
	elseif queneNum == 2 then
			p.IntroNewEquipStrQuene(ID_EQUIPSTR_CTRL_TEXT_LIST3,ID_EQUIPSTR_CTRL_BUTTON_LIST3); 
	elseif queneNum == 3 then
			--显示三个强化队列信息
			p.ShowThreeStrQuene();
	elseif queneNum == 256 then		
			--永久清除强化cd 
			return;
	end	
	
	--强化是否处于冷却中
	p.SetCanEnhance();
	if not enhanceEnable then
		p.SetEquipStrBtnTitle("冷却时间:".. p.calculateTime(p.GetMinTime()) );
    end
end




function p.setStrQueneButtonVisiable()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end

    local btnList = {ID_EQUIPSTR_CTRL_BUTTON_LIST1, ID_EQUIPSTR_CTRL_BUTTON_LIST2, ID_EQUIPSTR_CTRL_BUTTON_LIST3,ID_EQUIPSTR_CTRL_BUTTON_QUESTR};
	for i,v in ipairs(btnList) do
		local btn = GetButton(layer, v);
		if CheckP(btn) then
			btn:SetVisible(false);
		end
	end
	
	local equipStrQueneText = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST1);
	equipStrQueneText:SetVisible(false);
	
	local equipStrQueneText2 = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST2);
	equipStrQueneText2:SetVisible(false);
	
	local equipStrQueneText3 = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST3);
	equipStrQueneText3:SetVisible(false);
	
end

function p.IntroNewEquipStrQuene(queneTextId,queneButtonId) 
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end
	
	local stage = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_STAGE);
	LogInfo("玩家阶段stage:%d",stage)

    --玩家stage到达281开启更多强化队列功能
	if stage >= 281 or queneNum == 2 then
		--显示强化队列1
	    local equipStrQueneText = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST1);	
		equipStrQueneText:SetVisible(true);				 
		if timeNum1 > 0 then
			--队列1未冷却
			LogInfo("队列1剩余时间：%d",timeNum1)
			nProcessTimeTag1 = RegisterTimer(p.OnProcessTimer1, 1); 
		else
			timeNum1 = 0;
			equipStrQueneText:SetText("1:可强化");
		end
		local equipStrQueneBtn = GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_LIST1);
		equipStrQueneBtn:SetVisible(true);
		equipStrQueneBtn:SetLuaDelegate(p.OnUIEventClearQueneCD);
		
		--显示引导开通更多队列的text
		local newStrQueneText = GetLabel(layer,queneTextId);
		newStrQueneText:SetVisible(true);
	    newStrQueneText:SetText("开启更多队列");
	    newStrQueneText:SetFontColor(ccc4(0,0,255,255));
					
	    --显示增加强化队列按钮
	    local btn = GetButton(layer, ID_EQUIPSTR_CTRL_BUTTON_QUESTR);
	    btn:SetVisible(true);
	    btn:SetLuaDelegate(p.OnUIEventAddEquipStrQuene); 	  
	end
	
	if queneNum == 2 then
		--显示强化队列2
		local equipStrQueneText2 = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST2);
		equipStrQueneText2:SetVisible(true);
		if timeNum2 > 0 then
			--队列2未冷却
			nProcessTimeTag2 = RegisterTimer(p.OnProcessTimer2, 1); 
		else
			timeNum2 = 0;
			equipStrQueneText2:SetText("2:可强化");
		end		
	    local equipStrQueneBtn2 = GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_LIST2);
		equipStrQueneBtn2:SetVisible(true);
		equipStrQueneBtn2:SetLuaDelegate(p.OnUIEventClearQueneCD);
	end
		
end

--显示三个强化队列
function p.ShowThreeStrQuene() 
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end
	
	--显示强化队列1	
	local equipStrQueneText = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST1);
	equipStrQueneText:SetVisible(true);
	if timeNum1 > 0 then
		--队列1未冷却
		nProcessTimeTag1 = RegisterTimer(p.OnProcessTimer1, 1); 
	else
		timeNum1 = 0;
		equipStrQueneText:SetText("1:可强化");
	end
	local equipStrQueneBtn = GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_LIST1);
	equipStrQueneBtn:SetVisible(true);
	equipStrQueneBtn:SetLuaDelegate(p.OnUIEventClearQueneCD);
	
	--显示强化队列2
	local equipStrQueneText2 = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST2);
	equipStrQueneText2:SetVisible(true);
	if timeNum2 > 0 then
		--队列2未冷却
		nProcessTimeTag2 = RegisterTimer(p.OnProcessTimer2, 1); 
	else
		timeNum2 = 0;
		equipStrQueneText2:SetText("2:可强化");
	end
	local equipStrQueneBtn2 = GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_LIST2);
	equipStrQueneBtn2:SetVisible(true);
	equipStrQueneBtn2:SetLuaDelegate(p.OnUIEventClearQueneCD);
	
	--显示强化队列3
	local equipStrQueneText3 = GetLabel(layer,ID_EQUIPSTR_CTRL_TEXT_LIST3);
	equipStrQueneText3:SetVisible(true);
	if timeNum3 > 0 then
		--队列3未冷却
		nProcessTimeTag3 = RegisterTimer(p.OnProcessTimer3, 1); 
	else
		timeNum3 = 0;
		equipStrQueneText3:SetText("3:可强化");
	end
	local equipStrQueneBtn3 = GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_LIST3);
	equipStrQueneBtn3:SetVisible(true);
	equipStrQueneBtn3:SetLuaDelegate(p.OnUIEventClearQueneCD);

	--显示永久消除CD按钮
	local btn = GetButton(layer, ID_EQUIPSTR_CTRL_BUTTON_QUESTR);
	btn:SetVisible(true);
	btn:SetLuaDelegate(p.OnUIEventAddEquipStrQuene); 	
	btn:SetTitle("永久消除CD");   
end

--设置当前能否进行强化
function p.SetCanEnhance() 
    if queneNum == 256 then
	    return;
	end
   
    local minTime = timeNum1;
	currentMin = 1 ;
	currentQuene = -1;
	enhanceEnable = false ;
	
	for i = 1,queneNum  do
	     if p.IsStrFree(i) then
	         LogInfo("强化队列%d is Free",i)
	     end
	
	     if not p.IsStrFree(i) then
		     if i == 2 and timeNum2 < minTime then
			     minTime = timeNum2;		
				 currentMin = 2;	
			 elseif i == 3 and timeNum3 < minTime then
			     minTime = timeNum3;
				 currentMin = 3 ;
			 end
		 else
		 	 enhanceEnable = true;
			 currentQuene = i;
			 break;
 		 end
	end

    LogInfo("当前可以进行装备强化的队列currentQuene:%d",currentQuene);
   
end

function  p.GetMinTime() 
    local minTime ;
	if currentMin == 1 then
		minTime = timeNum1;
	elseif currentMin == 2 then
		minTime = timeNum2;
	elseif currentMin == 3 then
		minTime = timeNum3;
	end
	return minTime;
end




--设置装备控件隐藏
function p.setEquipItemVisiable(view,equipIndex)
	for i= Item.POSITION_EQUIP_6,equipIndex,-1 do
		local nTag,nameTextTag,lvTextTag,btnTag = p.GetEquipTag(i);	
		if btnTag > 0 then
			local btn = GetButton(view, btnTag);
			if CheckP(btn) then
				btn:SetVisible(false);
			end
		end
	end	

end


function p.AddEquipViewContent(view,equipIndex,equipId)
    local picTag,nameTextTag,lvTextTag,btnTag = p.GetEquipTag(equipIndex);	
	if picTag > 0 then
		local equipBtn	= GetItemButton(view, picTag);
		if CheckP(equipBtn) then
			equipBtn:ChangeItem(equipId);
		end
	end
			
	if nameTextTag > 0 then
		local type =Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
		local equipName = ItemFunc.GetName(type);
		--LogInfo("装备名称：");
		LogInfo(equipName);
		SetLabel(view, nameTextTag, equipName);
	end
			
	if lvTextTag > 0 then
		local equipLv = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION);
		--LogInfo("装备等级：");
		SetLabel(view, lvTextTag, EquipStrFunc.GetLevelName(equipLv));
	end
			
	if btnTag > 0 then
		local btn = GetButton(view,btnTag);
		btn:SetLuaDelegate(p.OnUIEventSelectEquipBtn);
		local viewId = view:GetViewId();
		currentEquipIdList[10 * viewId +btnTag] = equipId;
		currentEquipIndexList[10 * viewId +btnTag] = equipIndex;
	end 
			
end

function p.InitTag()
	if not CheckT(TAG_EQUIP_PIC_LIST) or not CheckT(TAG_EQUIP_LV_TEXT_LIST) or 
	   not CheckT(TAG_EQUIP_BTN_LIST) or not CheckT(TAG_EQUIP_TEXT_LIST) or 
	    TAG_EQUIP_PIC_LIST[Item.POSITION_EQUIP_1] then
		return;
	end 
	
	TAG_EQUIP_PIC_LIST[Item.POSITION_EQUIP_1] = ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_1;
	TAG_EQUIP_PIC_LIST[Item.POSITION_EQUIP_2] = ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_2;
	TAG_EQUIP_PIC_LIST[Item.POSITION_EQUIP_3] = ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_3;
	TAG_EQUIP_PIC_LIST[Item.POSITION_EQUIP_4] = ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_4;
	TAG_EQUIP_PIC_LIST[Item.POSITION_EQUIP_5] = ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_5;
	TAG_EQUIP_PIC_LIST[Item.POSITION_EQUIP_6] = ID_EQUIPSTR_L_CTRL_OBJECT_BUTTON_6;
	
	TAG_EQUIP_LV_TEXT_LIST[Item.POSITION_EQUIP_1] = ID_EQUIPSTR_L_CTRL_TEXT_LV_1;
	TAG_EQUIP_LV_TEXT_LIST[Item.POSITION_EQUIP_2] = ID_EQUIPSTR_L_CTRL_TEXT_LV_2;
	TAG_EQUIP_LV_TEXT_LIST[Item.POSITION_EQUIP_3] = ID_EQUIPSTR_L_CTRL_TEXT_LV_3;
    TAG_EQUIP_LV_TEXT_LIST[Item.POSITION_EQUIP_4] = ID_EQUIPSTR_L_CTRL_TEXT_LV_4;
    TAG_EQUIP_LV_TEXT_LIST[Item.POSITION_EQUIP_5] = ID_EQUIPSTR_L_CTRL_TEXT_LV_5;
    TAG_EQUIP_LV_TEXT_LIST[Item.POSITION_EQUIP_6] = ID_EQUIPSTR_L_CTRL_TEXT_LV_6;
	
	TAG_EQUIP_TEXT_LIST[Item.POSITION_EQUIP_1] = ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_1;
	TAG_EQUIP_TEXT_LIST[Item.POSITION_EQUIP_2] = ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_2;
	TAG_EQUIP_TEXT_LIST[Item.POSITION_EQUIP_3] = ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_3;
    TAG_EQUIP_TEXT_LIST[Item.POSITION_EQUIP_4] = ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_4;
    TAG_EQUIP_TEXT_LIST[Item.POSITION_EQUIP_5] = ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_5;
    TAG_EQUIP_TEXT_LIST[Item.POSITION_EQUIP_6] = ID_EQUIPSTR_L_CTRL_TEXT_EQUIP_6;
	
    TAG_EQUIP_BTN_LIST[Item.POSITION_EQUIP_1] = ID_EQUIPSTR_L_CTRL_BUTTON_1;
	TAG_EQUIP_BTN_LIST[Item.POSITION_EQUIP_2] = ID_EQUIPSTR_L_CTRL_BUTTON_2;
	TAG_EQUIP_BTN_LIST[Item.POSITION_EQUIP_3] = ID_EQUIPSTR_L_CTRL_BUTTON_3;
	TAG_EQUIP_BTN_LIST[Item.POSITION_EQUIP_4] = ID_EQUIPSTR_L_CTRL_BUTTON_4;
	TAG_EQUIP_BTN_LIST[Item.POSITION_EQUIP_5] = ID_EQUIPSTR_L_CTRL_BUTTON_5;
	TAG_EQUIP_BTN_LIST[Item.POSITION_EQUIP_6] = ID_EQUIPSTR_L_CTRL_BUTTON_6;
	

end


function p.GetEquipTag(index)
	if not CheckT(TAG_EQUIP_PIC_LIST)  or not CheckT(TAG_EQUIP_LV_TEXT_LIST)  or 
	   not CheckT(TAG_EQUIP_BTN_LIST)  or not CheckT(TAG_EQUIP_TEXT_LIST)  or
	   not CheckN(index) then
		
		return 0;
	end
	
	return ConvertN(TAG_EQUIP_PIC_LIST[index]),ConvertN(TAG_EQUIP_TEXT_LIST[index]),ConvertN(TAG_EQUIP_LV_TEXT_LIST[index]),ConvertN(TAG_EQUIP_BTN_LIST[index]);
end


function p.GetStateText(equipLv,itemTypeId)
	local state = "" ;
	local attr_type_1,attr_value_1,attr_grow_1,
	      attr_type_2,attr_value_2,attr_grow_2,
		  attr_type_3,attr_value_3,attr_grow_3 =ItemFunc.GetAttrTypeAndValueAndGrow(itemTypeId);

	if attr_type_1 >0 then
		 local attr_typename_1 = ItemFunc.GetAttrTypeDesc(attr_type_1); 
		 state = string.format("%s %d+%d\n",attr_typename_1,attr_value_1,attr_grow_1 * equipLv);
	end
	
	if attr_type_2 >0 then
		 local attr_typename_2 = ItemFunc.GetAttrTypeDesc(attr_type_2); 
		 state = state..string.format("%s %d+%d\n",attr_typename_2,attr_value_2,attr_grow_2 * equipLv);
	end
	
	if attr_type_3 >0 then
		 local attr_typename_3 = ItemFunc.GetAttrTypeDesc(attr_type_3); 
		 state = state..string.format("%s %d+%d",attr_typename_3,attr_value_3,attr_grow_3 * equipLv);
	end

	--LogInfo(state);
	return state;
end

function p.RefreshEquipRight()
	local equipId = currentEquipId;
	
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	if nil == layer then
		return nil;
	end
	
	local equipBeforeBtn = GetItemButton(layer,ID_EQUIPSTR_CTRL_OBJECT_BUTTON_R1);
	if CheckP(equipBeforeBtn) then
	    equipBeforeBtn:ChangeItem(equipId);
	end
	
	local itemTypeId =Item.GetItemInfoN(equipId, Item.ITEM_TYPE);		
	local equipName = ItemFunc.GetName(itemTypeId);
	local equipLv = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION);
	local state = p.GetStateText(equipLv,itemTypeId);
	LogInfo("name: %s Lv:%d state:%s",equipName,equipLv+1,state)
	
	SetLabel(layer, ID_EQUIPSTR_CTRL_TEXT_NAME_R1, equipName);
	SetLabel(layer, ID_EQUIPSTR_CTRL_TEXT_LEVEL_R1, EquipStrFunc.GetLevelName(equipLv));
	SetLabel(layer, ID_EQUIPSTR_CTRL_TEXT_STATE_R1, state);
	
	local equipAfterBtn = GetItemButton(layer,ID_EQUIPSTR_CTRL_OBJECT_BUTTON_R2);	
	if CheckP(equipAfterBtn) then
		equipAfterBtn:ChangeItem(equipId);
	end
	
	state = p.GetStateText(equipLv+1,itemTypeId);
	reqMoney = EquipStrFunc.GetReqMoney(itemTypeId,equipLv);
	state = state..string.format("消耗铜钱 %d",reqMoney);
	LogInfo(state);
	SetLabel(layer, ID_EQUIPSTR_CTRL_TEXT_NAME_R2, equipName);
	SetLabel(layer, ID_EQUIPSTR_CTRL_TEXT_LEVEL_R2, EquipStrFunc.GetLevelName(equipLv+1));
	SetLabel(layer, ID_EQUIPSTR_CTRL_TEXT_STATE_R2, state);
	
	local money = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_MONEY);
	LogInfo("选中装备时，玩家身上铜钱:%d",money);
	local equipStrBtn =  GetButton(layer,ID_EQUIPSTR_CTRL_BUTTON_STRENGTHEN);
	if money < reqMoney then
		equipStrBtn:SetTitle("铜钱不足！");
		equipStrBtn:SetFontColor(ccc4(255,0,0,255));
		enhanceEnable = false;
	elseif queneNum == 256 or currentQuene ~= -1 then
			enhanceEnable = true;
			equipStrBtn:SetFontColor(ccc4(255,255,255,255));
			equipStrBtn:SetTitle("强化");
	end
end		


--事件处理回调函数
function p.OnUIEventSelectEquipBtn(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventSelectEquipBtn[%d]", tag);
	
	local container  = p.GetPetParent();
	local currentView = container:GetBeginView();
	local viewId = currentView:GetViewId();
	currentEquipId = currentEquipIdList[tag + 10 * viewId];
	currentEquipIndex= currentEquipIndexList[tag + 10 * viewId];
	LogInfo("equipId:%d,equipIndex:%d",currentEquipId,currentEquipIndex);
	
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then  		
	    local equipId = currentEquipId;
	
	    local scene = GetSMGameScene();
	    if nil == scene then
		    return nil;
	    end
	
	    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.EquipStr);
	    if nil == layer then
		   return nil;
	    end
	
	   p.RefreshEquipRight();
	 
	end
end


function p.OnUIEventSelectEquipStrBtn(uiNode, uiEventType, param)			
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventSelectEquipStrBtn: %d", tag);
	
	local btn = ConverToButton(uiNode);
	local title = btn:GetTitle();
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK  then  	
		if enhanceEnable then
			 if currentEquipId == 0 then
	             CommonDlg.ShowTipInfo("提示", "请先选择装备!", nil, 2);	
		         return;
	          end		
			  			
			 local enhanceFlag = EquipStrFunc.CanEquipStr(currentViewId,currentEquipId);
			 LogInfo ("标志：%d",enhanceFlag)
			 if  enhanceFlag ==1 then
		         MsgEquipStr.SendEquipStrAction(currentEquipId,currentQuene);				 
			 elseif enhanceFlag ==-1 then
			     --装备等级上限,装备等级不能超过自身等级
				 CommonDlg.ShowTipInfo("提示", "强化等级上限，无法继续强化!", nil, 2);				 
			 end
			 
		else
			local money = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_MONEY);
          	if money >= reqMoney then
			    --弹出花费元宝清除冷却时间的对话框
				local timeNum = 0;
			    if queneNum == 1 then
			        timeNum = timeNum1;
				elseif queneNum == 2 or queneNum == 3 then
			            timeNum = p.GetMinTime();
			     end
								
				reqEMoney = timeNum / 60;
	            if timeNum % 60 ~= 0 then
		            reqEMoney = reqEMoney + 1;
	            end	
			
			    nParam = currentMin;
                CommonDlg.ShowNoPrompt(string.format("你愿意花费%d元宝清除cd吗？",reqEMoney), p.OnCommonDlgClearStrQueneTime , true);
			end	
		end
	end	
end

	
function p.OnCommonDlgClearStrQueneTime(nId, nEvent, param)
	if nEvent == CommonDlg.EventOK then
	    local eMoney = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY);
		if eMoney < reqEMoney then
		    CommonDlg.ShowTipInfo("提示", "元宝不足!", nil, 2);
	    else
           MsgEquipStr.SendClearStrQueneTimeAction(nParam);
		end   
	end
end	

function p.OnCommonDlgEliminateCD(nId, nEvent, param)
    if nEvent == CommonDlg.EventOK then
	    local eMoney = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY); 
	    local vipLevel = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
		if vipLevel <4 then
			CommonDlg.ShowTipInfo("提示", "VIP4以上玩家可开启!", nil, 2);
			return;
		end					

        LogInfo("永久消除cd需要元宝:%d,玩家身上元宝：%d",reqEMoney,eMoney)		
	
	    if eMoney < reqEMoney then
		    CommonDlg.ShowTipInfo("提示", "元宝不足!", nil, 2);
		else
			MsgEquipStr.SendEliminateUpdateCDAction();
		end
    end
end	

function p.OnCommonDlgAddQuene(nId, nEvent, param)
    if nEvent == CommonDlg.EventOK then
	    LogInfo("AddEquip")
		local eMoney = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY); 
	    local vipLevel = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);

		if vipLevel <2 then
			CommonDlg.ShowTipInfo("提示", "VIP2以上玩家可开启!", nil, 2);
			return;
		end	
	   
		LogInfo("增加队列需要元宝:%d,玩家身上元宝：%d",reqEMoney,eMoney)		
	  
	    if eMoney < reqEMoney then
		    CommonDlg.ShowTipInfo("提示", "元宝不足!", nil, 2);
		else
	        MsgEquipStr.SendAddEquipStrQueneAction();
	    end
    end
end	


function p.OnUIEvent(uiNode, uiEventType, param)
  	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_EQUIPSTR_CTRL_BUTTON_CLOSE == tag then
		    --关闭界面
		    if nProcessTimeTag1 ~= 0 then
		        UnRegisterTimer(nProcessTimeTag1);
		    end
	        if nProcessTimeTag2 ~= 0 then
				UnRegisterTimer(nProcessTimeTag2);
		    end
		    if nProcessTimeTag3 ~= 0 then
		        UnRegisterTimer(nProcessTimeTag3);
	        end	
			CloseUI(NMAINSCENECHILDTAG.EquipStr);
		end
	end
	return true;
end

function p.OnUIEventViewChange(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
	    local tag = uiNode:GetTag();
		LogInfo("p.OnUIEventViewChange[%d]", tag);
	   
		local containter	= ConverToSVC(uiNode);
		local nPetId		= 0;
		if CheckP(containter) and CheckN(param) then
			local beginView	= containter:GetView(param);
			if CheckP(beginView) then
				nPetId	= beginView:GetViewId();
				LogInfo("beginView")
				LogInfo("nPetId:%d",nPetId);
			end
		end

		if not nPetId then
			return true;
		end
	
		if ID_EQUIPSTR_CTRL_LIST_EQUIP == tag then
			local petNameContainter = p.GetPetNameContainer();
	
			if CheckP(petNameContainter) then
				petNameContainter:ScrollViewById(nPetId);
			end
		end
		
		if ID_EQUIPSTR_CTRL_LIST_46 == tag then
			containter	= p.GetPetParent();
			if CheckP(containter) then
				containter:ScrollViewById(nPetId);
		    end		
		end

	end
	
	return true;
end

function p.OnUIEventAddEquipStrQuene(uiNode, uiEventType, param)
						    	
	local eMoney = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY); 
	local vipLevel = PlayerFunc.GetUserAttr(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
	LogInfo("vip等级%d",vipLevel)
	if not CheckN(vipLevel) then
	    vipLevel = 0;
	end
				
	--弹出花费元宝开通强化队列的对话框
	if queneNum == 1 then
		reqEMoney = 100;
	elseif queneNum == 2 then	
		   reqEMoney = 200;
	elseif	queneNum == 3 then				
			reqEMoney = 500;	
	end

	if queneNum == 3 then
		CommonDlg.ShowNoPrompt(string.format("你愿意花费%d元宝永久清除强化cd吗？",reqEMoney), p.OnCommonDlgEliminateCD , true);
	else
		CommonDlg.ShowNoPrompt(string.format("你愿意花费%d元宝增加强化队列吗？",reqEMoney), p.OnCommonDlgAddQuene, true);	
	end	

end

function p.OnUIEventClearQueneCD(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    
		local tag = uiNode:GetTag();
		LogInfo("p.p.OnUIEventClearQueneCD[%d]", tag);
		local need = false ;
		
		local timeNum;
		if tag == ID_EQUIPSTR_CTRL_BUTTON_LIST1 then
		    nParam = 1;
		    timeNum = timeNum1;
			if timeNum1 ~= 0 then
			    need = true;
			end
		elseif tag == ID_EQUIPSTR_CTRL_BUTTON_LIST2 then
		        nParam = 2;
		        timeNum = timeNum2;
			    if timeNum2 ~= 0 then
			        need = true;
			    end
		elseif tag == ID_EQUIPSTR_CTRL_BUTTON_LIST3 then
		        nParam = 3;
		        timeNum = timeNum3;	
				if timeNum3 ~= 0 then
			        need = true;
			    end	
		end
		
		if need then
			--弹出花费元宝清除冷却时间的对话框
	        reqEMoney = timeNum / 60;
	        if timeNum % 60 ~= 0 then
		        reqEMoney = reqEMoney + 1;
	        end	
            CommonDlg.ShowNoPrompt(string.format("你愿意花费%d元宝清除cd吗？",reqEMoney), p.OnCommonDlgClearStrQueneTime , true);
		end
	end					
end

function p.OnUIEventClickPetName(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    --获取按钮所在的view
		local view	= PRecursiveSV(uiNode, 1);
		if CheckP(view) then
			local nPetId		= ConvertN(view:GetViewId())
			local containter	= p.GetPetNameContainer();
			if CheckP(containter) then
				containter:ScrollViewById(nPetId);
			end
			
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ScrollViewById(nPetId);
			end
		end
	end
	
	return true;
end


function p.GameDataUserInfoRefresh(datalist)
	if not CheckT(datalist) then
		LogError("p.GameDataUserInfoRefresh invalid arg");
		return;
	end
	
	for i=1, #datalist, 2 do
		if datalist[i] and datalist[i] == USER_ATTR.USER_ATTR_EQUIP_QUEUE_COUNT then
			if datalist[i+1] == 1 or datalist[i+1] ==2 then
			    --响应增加强化队列
			    p.ResAddQuene();
				return;
			elseif 	datalist[i+1] == -1 then
                    --响应永久消除强化CD
                    p.ResEliminateCD();
					queneNum = 256;
					return;
			end		
		elseif datalist[i] and datalist[i] == USER_ATTR.USER_ATTR_MONEY then
				LogInfo("玩家铜钱数更新为：%d",datalist[i+1])
		elseif datalist[i] and datalist[i] == USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME1 and datalist[i+1] == 0  then
		        --清除队列1冷却时间
                p.ResClearTime(1);
				return;
		elseif datalist[i] and datalist[i] == USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME2 and datalist[i+1] == 0  then
		       --清除队列2冷却时间
               p.ResClearTime(2);
			   return;
		elseif datalist[i] and datalist[i] == USER_ATTR.USER_ATTR_EQUIP_UPGRADE_TIME3 and datalist[i+1] == 0  then
		       --清除队列3冷却时间
               p.ResClearTime(3);
			   return;
			   
		end
	end
end





GameDataEvent.Register(GAMEDATAEVENT.USERATTR, "p.GameDataUserInfoRefresh", p.GameDataUserInfoRefresh);




