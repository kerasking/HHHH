---------------------------------------------------
--描述: 玩家邮件列表
--时间: 2012.4.9
--作者: xxj
---------------------------------------------------

EmailList = {}
local p = EmailList;

--最多显示的邮件数量
local maxEmailShow = 6; 
--邮件图标间的距离
local emailDistance = 5;
--邮件图标离底部按钮的距离
local distanceToBottom = 5;
--邮件图标路径
local emailIconFileName = "bg_copy_lock.png";
--忽略图标路径
local ignoreIconFileName= "bg_copy_normal.png";

--UI坐标配置
local winsize   = GetWinSize();
p.BtnWidth		= winsize.h * 0.125;
p.BtnHeight		= p.BtnWidth;
p.rectW         = (p.BtnWidth+emailDistance) * (maxEmailShow+1); 
p.rectX         = winsize.w - p.rectW;
p.rectY         = winsize.h - MainUIBottomSpeedBar.Height * 2-distanceToBottom-p.BtnHeight;

--自定义tag
local TAG_EMAIL_CONTAINER = 998;
local TAG_EMAIL_IGNORE = 999;


function p.LoadUI()	
  LogInfo("EmailList.LoadUI()");
  local scene = GetSMGameScene();
  if not CheckP(scene) then
	LogInfo("scene is nil,loadUserEmailList failed!");
	return;
  end   
  
  local layer = createNDUILayer();
  if not CheckP(layer) then
    LogInfo("layer is nil,loadUserEmailList failed!");
	return;
  end
  layer:Init();
  layer:SetTag(NMAINSCENECHILDTAG.EmailList);
  scene:AddChild(layer);
 
  p.refreshUserEmailList();			
  return;
end

function p.OnEmailEvent(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then 
	LogInfo("p.OnEmailEvent(%d)",tag);
	MsgUserEmail.LookEmail(tag);
  end
  return true;
end

function p.OnIgnoreEvent(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then 
	 LogInfo("p.OnIgnoreEvent()");
     MsgUserEmail.IgnoreEmail();
  end
  return true;
end

function p.refreshUserEmailList()
   LogInfo("p.refreshUserEmailList()");
   local scene = GetSMGameScene();
   if not CheckP(scene) then
	 LogInfo("scene == nil,refreshUserEmailList failed!");
    return;
   end    
   local container=GetUiNode(scene,NMAINSCENECHILDTAG.EmailList);
   if not CheckP(container) then
     LogInfo("scene container nil,refreshUserEmaILList failed!");
   end
   container:RemoveAllChildren(true);
   
   local nRoleId = ConvertN(GetPlayerId());
   local userEmailIdList = MsgUserEmail.GetUserEmailIdList(nRoleId);  
   local emailAmount = table.getn(userEmailIdList);
   local showEmailAmount = emailAmount;
   LogInfo("emailAmount="..emailAmount);
   if showEmailAmount > maxEmailShow then
     showEmailAmount = maxEmailShow;
   end
   LogInfo("showEmailAmount="..showEmailAmount);
   local containerW = 0;
   local containerH = 0;
   if showEmailAmount > 0 then
     containerW = showEmailAmount * p.BtnWidth + (showEmailAmount - 1) * emailDistance;
	 if emailAmount > maxEmailShow then
	   containerW = containerW + emailDistance + p.BtnWidth;
	 end
     containerH = p.BtnHeight;
   end
   container:SetFrameRect(CGRectMake(p.rectX,p.rectY, containerW,containerH));
   
   for i, v in ipairs(userEmailIdList) do
	 if i <= showEmailAmount then
	   local btn = createNDUIButton();
	   if CheckP(btn) then
		 btn:Init();
		 local rect = CGRectMake((i - 1) * (p.BtnWidth+emailDistance), 0, p.BtnWidth, p.BtnHeight);
		 btn:SetFrameRect(rect);
		 btn:SetTag(v);
		 btn:CloseFrame();	
		 local pic = p.GetPicByFileName(emailIconFileName);
		 if CheckP(pic) then
		   btn:SetBackgroundPicture(pic,nil);
		 else
		   LogInfo("getPic is failed:pic is nil");
		 end
		 btn:SetLuaDelegate(p.OnEmailEvent);  
		 container:AddChild(btn);	
	   end
	 else
	   break;
	 end	   
   end
   
   if emailAmount > maxEmailShow then
	 local btn = createNDUIButton();
	 if CheckP(btn) then	   
	   btn:Init();
	   local rect = CGRectMake(maxEmailShow * (p.BtnWidth+emailDistance), 0, p.BtnWidth, p.BtnHeight);
	   btn:SetFrameRect(rect);
	   btn:SetTag(TAG_EMAIL_IGNORE);
	   btn:CloseFrame();	
	   local pic = p.GetPicByFileName(ignoreIconFileName);
	   if CheckP(pic) then
		 btn:SetBackgroundPicture(pic,nil);
	   else
		 LogInfo("getPic is failed:pic is nil");
	   end
	   btn:SetLuaDelegate(p.OnIgnoreEvent);  
	   container:AddChild(btn);
	 end
   end
end 

function p.GetPicByFileName(fileName)
  local pool = DefaultPicPool();
  if CheckP(pool) then
    local pic = pool:AddPicture(GetSMImgPath(fileName), false);
    return pic;
  end
  return nil;
end

RegisterGlobalEventHandler(GLOBALEVENT.GE_GENERATE_GAMESCENE, "EmailList.LoadUI", p.LoadUI);
