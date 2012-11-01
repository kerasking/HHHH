---------------------------------------------------
--描述: 网络消息处理(buff)消息处理及其逻辑
--时间: 2012.3.30
--作者: xxj
---------------------------------------------------

MsgUserState = {}
local p = MsgUserState;

--发送删除状态的消息
function p.SendDelState(stateId)
  LogInfo("p.SendDelState[%d]",stateId);
  local netdata = createNDTransData(NMSG_Type._MSG_USER_STATE_CHG);
  if nil == netdata then
		LogInfo("发送删除状态消息,内存不够");
		return false;
  end
  netdata:WriteInt(stateId);  
  SendMsg(netdata);
  netdata:Free();
  return true;  
end

-- 网络消息处理(玩家状态更新)
function p.ProcessUserState(netdata) 
  local amount=netdata:ReadByte();
  LogInfo("p.ProcessUserState amount="..amount);
  for i = 1,amount do
    local stateId = netdata:ReadInt();
    local typeId = netdata:ReadInt();
    local spaceTime = netdata:ReadInt();
    local data = netdata:ReadInt();
	LogInfo("stateId=[%d] typeId=[%d] spaceTime=[%d] data=[%d]",stateId,typeId,spaceTime,data);
    UserStateUI.SetUserState(stateId,typeId,data,spaceTime);
  end
  p.refreshUserStateUI();
  CloseLoadBar();
end

-- 网络消息处理(删除状态)
function p.ProcessDelUserState(netdata) 
  local stateId=netdata:ReadInt();
  LogInfo("p.ProcessDelUserState[%d]",stateId);
  UserStateUI.DelStateData(stateId);
  p.refreshUserStateUI();
  local scene = GetSMGameScene();
  if CheckP(scene) then	
    local userStateUI=GetUiNode(scene,NMAINSCENECHILDTAG.UserStateUI);
	if CheckP(userStateUI) then
	  if UserStateUI.GetStateId() == stateId then
	    CloseUI(NMAINSCENECHILDTAG.UserStateUI);
	  end
	end
  end  
end

function p.refreshUserStateUI()
  if IsUIShow(NMAINSCENECHILDTAG.UserStateList) then
    UserStateList.refreshUserStateList();
  end
end


--RegisterNetMsgHandler(NMSG_Type._MSG_USER_STATE, "p.ProcessUserState", p.ProcessUserState);
--RegisterNetMsgHandler(NMSG_Type._MSG_USER_STATE_CHG, "p.ProcessDelUserState", p.ProcessDelUserState);


	
	