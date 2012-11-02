---------------------------------------------------
--描述: 玩家状态UI
--时间: 2012.3.31
--作者: xxj
---------------------------------------------------
UserStateUI = {};
local p = UserStateUI;

--状态图标的大小
p.stateIconSize = 40;
--状态图标文件名
p.stateFileName = "/mix/mix_goods.png";

--状态类型
p.STATE_CONFIG_TYPE_NONE   = 0; 
p.STATE_CONFIG_GU_WU       = 1;     --一鼓作气
p.STATE_CONFIG_LIFE        = 2;     --生命
p.STATE_CONFIG_STAMINA     = 3;     --体力
p.STATE_CONFIG_SHAPESHIFT  = 4;     --变身
p.STATE_CONFIG_RIDING      = 5;     --座骑

--状态数据
p.SM_STATE_TYPEID     = 0;
p.SM_STATE_DATA       = 1;
p.SM_STATE_END_TIME  = 2;

--描述的字体大小
local fontSize = 16;
--描述文字的边距
local margin = 3 * ScaleFactor;
--buff信息和buff图标的距离
local distance = 5;
--倒计时标识
local nProcessTimeTag = 0;
--自定义tag
local btnTag = 998;
local timeLableTag = 999;
--保存的stateId;
p.nStateId = 0;
--UI坐标配置
--[[
local winsize	    = GetWinSize();
local rectX         = UserStateList.rectX;
local rectY         = UserStateList.rectY+UserStateList.BtnHeight+distance;
local Width			= UserStateList.rectW;
local labelWidth    = Width - margin*2;
local timeLableRect = nil;
]]
function p.LoadUI(stateId)
--[[
  LogInfo("UserStateUI.LoadUI(%d)",stateId);
  p.nStateId = stateId;
  local scene = GetSMGameScene();
  if not CheckP(scene) then
	LogInfo("scene is nil,UserStateUI LoadUI failed!");
	return;
  end   
  local container = createUIScrollContainer();
  if not CheckP(container) then
	LogInfo("container is nil,UserStateUI LoadUI failed!");
	return;
    ]]
  end
--[[
  container:Init();
  container:SetTag(NMAINSCENECHILDTAG.UserStateUI);
  container:SetLeftReserveDistance(0);
  container:SetRightReserveDistance(10);
  container:SetDestroyNotify(p.OnDeConstruct);
  scene:AddChild(container);  
  
  local nRoleId = ConvertN(GetPlayerId());
  local typeId = p.GetStateTypeId(nRoleId,stateId);
  local data = p.GetStateDate(nRoleId,stateId);  
  local endTime = p.GetStateEndTime(nRoleId,stateId);
  local name = p.GetStateName(typeId);
  local type = p.GetStateType(typeId);
  
  local nResHeight = margin;
  ItemUI.AddColorLabel(container, name, fontSize, margin,nResHeight, labelWidth);
  nResHeight = nResHeight + 20 * ScaleFactor;
  
  local dataDec = nil;   
  if type == p.STATE_CONFIG_GU_WU then
    dataDec = "<c00ff00所有攻击力＋"..data.."%/e";
  elseif type == p.STATE_CONFIG_LIFE then
    dataDec = "<c00ff00剩余"..data.."点生命,在非战斗时可自动帮玩家恢复损耗的血量/e";
  elseif type == p.STATE_CONFIG_STAMINA then
    dataDec = "<c00ff00额外体力："..data.."/e";
  end
  if CheckS(dataDec) then
    ItemUI.AddColorLabel(container, dataDec, fontSize, margin,nResHeight, labelWidth);
	local size = GetHyperLinkTextSize(dataDec,fontSize, labelWidth);
	nResHeight = nResHeight + size.h;
  end
  
  local descript = nil;
  if type == p.STATE_CONFIG_GU_WU 
     or type == p.STATE_CONFIG_STAMINA 
	 or type == p.STATE_CONFIG_SHAPESHIFT
	 or type == p.STATE_CONFIG_RIDING then
	 descript = "<c00ff00" .. p.GetStateDescript(typeId) .. "/e";
  end
  if CheckS(descript) then
     ItemUI.AddColorLabel(container, descript, fontSize, margin,nResHeight, labelWidth);
	 local size = GetHyperLinkTextSize(descript,fontSize, labelWidth);
	 nResHeight = nResHeight + size.h;	 
  end
  
  if type == p.STATE_CONFIG_SHAPESHIFT then
    timeLableRect = CGRectMake(margin, nResHeight, labelWidth, 20 * ScaleFactor);
	nProcessTimeTag = RegisterTimer(p.OnProcessTimer, 1);   
    p.refreshTimeLable();	
	nResHeight	= nResHeight + 20 * ScaleFactor;
  end
  nResHeight = nResHeight + margin;
  local pool = DefaultPicPool();
  if CheckP(pool) then
	local pic = pool:AddPictureEx(GetSMImgPath("bg/bg_ver_black.png"), labelWidth, nResHeight, false); 
    if CheckP(pic) then
	  container:SetBackgroundImage(pic);
    end
  end 	
  container:SetFrameRect(CGRectMake(rectX,rectY,Width,nResHeight));  
  local btn = createNDUIButton();
  if CheckP(btn) then
    btn:Init();
    btn:SetFrameRect(CGRectMake(0,0,Width,nResHeight));
	btn:SetTag(btnTag);
	btn:SetLuaDelegate(p.OnUIEvent);  
	container:AddChild(btn);
  end
  
end

function p.OnUIEvent(uiNode, uiEventType, param)
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then 
	local scene = GetSMGameScene(); 
	if CheckP(scene) then
	  CloseUI(NMAINSCENECHILDTAG.UserStateUI);
	end
  end
  return true;
end

function p.refreshTimeLable()
  local scene = GetSMGameScene();
  if CheckP(scene) then
    local container=GetUiNode(scene,NMAINSCENECHILDTAG.UserStateUI);
	if CheckP(container) then
	   local timeLable=GetUiNode(container,timeLableTag);
	   if CheckP(timeLable) then
	     container:RemoveChildByTag(timeLableTag,true);
	   end
	   if CheckP(timeLableRect) then	   
	     local nRoleId = ConvertN(GetPlayerId());
         local endTime = p.GetStateEndTime(nRoleId,p.nStateId);	   
		 local curTime = GetCurrentTime();    
         local timeStr = "剩余时间:"..p.calculateTime(endTime-curTime); 
		 timeLable = CreateColorLabel(timeStr,fontSize,labelWidth);		 
		 if CheckP(timeLable) then
		   timeLable:SetFrameRect(timeLableRect);
		   timeLable:SetTag(timeLableTag);
		   container:AddChild(timeLable);		  	
		 end			 	 	
	   end
	end
  end   
end

function p.OnProcessTimer(nTag)
  p.refreshTimeLable();
end

function p.OnDeConstruct()
  if nProcessTimeTag ~= 0 then
    UnRegisterTimer(nProcessTimeTag);
  end
end

function p.calculateTime(timeNum)
  local timeStr = "";
  if timeNum < 0 then
	  timeNum = 0;
  end	
  local time = math.floor(timeNum/ 3600);
  if time > 0 then
	timeStr = timeStr..time.."小时";
  end
  time = math.floor((timeNum%3600) /60);
  if time > 0 then
	timeStr = timeStr..time.."分钟";
  end
  time=timeNum%60;
  timeStr = timeStr..time.."秒";
  return timeStr;
end

function p.GetStateId()
  return p.nStateId;
end 

--删除状态
function p.DelStateData(stateId)
   local nRoleId = ConvertN(GetPlayerId());
   DelRoleSubGameDataById(NScriptData.eRole,nRoleId,NRoleData.eUserState,stateId);
end

--根据typeId得到状态的inconindex
function p.GetStateconIndexByTypeId(typeId)
   return GetDataBaseDataN("user_state_config",typeId,DB_USER_STATE_TYPE.ICONINDEX);
end

--根据状态id获得inconindex
function p.GetStateIconIdexById(nRoleId,stateId)
   return p.GetStateconIndexByTypeId(GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eUserState,stateId,p.SM_STATE_TYPEID));
end

--根据状态id获得状态图标
function p.GetStatePicByStateId(stateId)
   local nRoleId = ConvertN(GetPlayerId());
   return p.GetStatePicByIconIndex(p.GetStateIconIdexById(nRoleId,stateId));
end

--根据iconindex获得状态图标
function p.GetStatePicByIconIndex(iconIndex)
  local pool = DefaultPicPool();
  if CheckP(pool) then
    local pic = pool:AddPicture(GetSMImgPath(p.stateFileName), false);
	if CheckP(pic) then
	  pic:Cut(CGRectMake((iconIndex % 100 - 1)*p.stateIconSize,
	                     (_G.getIntPart(iconIndex / 100) - 1)*p.stateIconSize,
						 p.stateIconSize,p.stateIconSize));
	  return pic;
	end 
  end
  return nil;
end

function p.GetStateTypeId(nRoleId,stateId)
  return GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eUserState,stateId,p.SM_STATE_TYPEID);
end

function p.GetStateDate(nRoleId,stateId)
   return GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eUserState,stateId,p.SM_STATE_DATA);
end

function p.GetStateEndTime(nRoleId,stateId)
   return GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eUserState,stateId,p.SM_STATE_END_TIME);
end

function p.GetStateName(typeId)
   return GetDataBaseDataS("user_state_config",typeId,DB_USER_STATE_TYPE.NAME);
end

function p.GetStateDescript(typeId)
   return GetDataBaseDataS("user_state_config",typeId,DB_USER_STATE_TYPE.DESCRIPT);
end

function p.GetStateType(typeId)
   return GetDataBaseDataN("user_state_config",typeId,DB_USER_STATE_TYPE.TYPE);
end

--更新状态
function p.SetUserState(stateId,typeId,data,spaceTime)
   local nRoleId = ConvertN(GetPlayerId());
   local endTime = GetCurrentTime() + spaceTime;
   p.SetSateTypeId(nRoleId,stateId,typeId)
   p.SetSateData(nRoleId,stateId,data)
   p.SetSateEndTime(nRoleId,stateId,endTime)
end

function p.SetSateTypeId(nRoleId,stateId,typeId)
   SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eUserState,stateId,p.SM_STATE_TYPEID,typeId);
end

function p.SetSateData(nRoleId,stateId,data)
   SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eUserState,stateId,p.SM_STATE_DATA,data);
end

function p.SetSateEndTime(nRoleId,stateId,endTime)
   SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eUserState,stateId,p.SM_STATE_END_TIME,endTime);
end
]]