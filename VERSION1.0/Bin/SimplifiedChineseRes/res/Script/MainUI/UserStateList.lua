---------------------------------------------------
--描述: 玩家状态buff列表
--时间: 2012.3.30
--作者: xxj
---------------------------------------------------

UserStateList = {}
local p = UserStateList;

--最多显示的状态数量
local maxStateShow = 5; 
--buff图标间的距离
local buffDistance = 5;

--UI坐标配置
local winsize   = GetWinSize();
p.rectX         = 0;
p.rectY         = winsize.h * 0.125;
p.BtnWidth		= winsize.h * 0.125;
p.BtnHeight		= p.BtnWidth;
p.rectW         = (p.BtnWidth+buffDistance) * maxStateShow; 

function p.LoadUI()	
  local scene = GetSMGameScene();
  if not CheckP(scene) then
	LogInfo("scene is nil,loadUserStateList failed!");
	return;
  end   
  local layer = createNDUILayer();
  if not CheckP(layer) then
    LogInfo("layer is nil,loadUserStateList failed!");
	return;
  end
  layer:Init();
  layer:SetTag(NMAINSCENECHILDTAG.UserStateList);
  scene:AddChild(layer);
  
  p.refreshUserStateList();			
  return;
end

function p.OnUIEvent(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then 
	 local scene = GetSMGameScene(); 
	 if CheckP(scene) then	   	
	 local userStateUI=GetUiNode(scene,NMAINSCENECHILDTAG.UserStateUI);
	 if CheckP(userStateUI) then
	    CloseUI(NMAINSCENECHILDTAG.UserStateUI);	
		if UserStateUI.GetStateId() ~= tag then
		  UserStateUI.LoadUI(tag);
		end 
	  else
		UserStateUI.LoadUI(tag);	
	  end	
	 end	  
  end
  return true;
end

function p.refreshUserStateList()
   LogInfo("p.refreshUserStateList()");
   local scene = GetSMGameScene();
   if not CheckP(scene) then
	 LogInfo("scene == nil,refreshUserStateList failed!");
    return;
   end    
   local container=GetUiNode(scene,NMAINSCENECHILDTAG.UserStateList);
   if not CheckP(container) then
     LogInfo("scene container nil,refreshUserStateList failed!");
   end
   container:RemoveAllChildren(true);
  
   local userIdList = p.GetUserStateIdList();
   local stateAmount = table.getn(userIdList);
   LogInfo("stateAmount="..stateAmount);
   if stateAmount > maxStateShow then
     stateAmount = maxStateShow;
   end
   LogInfo("showStateAmount="..stateAmount);
   local containerW = 0;
   local containerH = 0;
   if stateAmount > 0 then
     containerW = stateAmount * p.BtnWidth + (stateAmount - 1) * buffDistance;
     containerH = p.BtnHeight;
   end
   container:SetFrameRect(CGRectMake(p.rectX,p.rectY, containerW,containerH));
   for	i, v in ipairs(userIdList) do
	 if i <= stateAmount then
	   local btn = createNDUIButton();
	   if btn == nil then
	     LogInfo("btn[%d] == nil,load UserStateList failed!", i);
		 container:RemoveFromParent(true);
		 break;
	   end
	   btn:Init();
	   local rect = CGRectMake((i - 1) * (p.BtnWidth+buffDistance), 0, p.BtnWidth, p.BtnHeight);
	   btn:SetFrameRect(rect);
	   btn:SetTag(v);
	   btn:CloseFrame();
	   local pic = UserStateUI.GetStatePicByStateId(v);
	   if CheckP(pic) then
		  btn:SetBackgroundPicture(pic,nil);
	   else
		  LogInfo("getPic is failed:pic is nil");
	   end
	   btn:SetLuaDelegate(p.OnUIEvent);  
	   container:AddChild(btn);	
	 else
	   break;	
	 end
   end	
end

function p.GetUserStateIdList()
   local nRoleId = ConvertN(GetPlayerId());
   local stateIdList = GetGameDataIdList(NScriptData.eRole, nRoleId, NRoleData.eUserState);
   stateIdList = stateIdList or {};
   return stateIdList;
end

function p.GetDatasByType(nType)
  local allValue = 0;
  local userStateIdList = p.GetUserStateIdList(); 
  for i, v in ipairs(userStateIdList) do
    local type = UserStateUI.GetStateType(v);
	if type == nType then
	  local nRoleId = ConvertN(GetPlayerId());
	  local data = UserStateUI.GetStateDate(nRoleId,stateId); 
	  allValue = allValue + data;
	end
  end
  return allValue; 
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "UserStateList.LoadUI", p.LoadUI);
