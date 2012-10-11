---------------------------------------------------
--描述: 网络消息处理(邮件)消息处理及其逻辑
--时间: 2012.4.9
--作者: xxj
---------------------------------------------------

MsgUserEmail = {}
local p = MsgUserEmail;

p.SM_EMAIL_NAME = 0;

p.SM_EMAIL_LETTER_LOOK = 0;
p.SM_EMAIL_LETTER_DEL = 3;

--网络消息处理(玩家邮件更新)
function p.ProcessReceiedEmail(netdata) 
  LogInfo("p.ProcessReceiedEmail()");
  local m = netdata:ReadByte();  
  local btAction = BitwiseAnd(m,3);  
  local count = RightShift(m,2);
  LogInfo("m=[%d],btAction=[%d],count=[%d]",m,btAction,count);  
  local nRoleId = ConvertN(GetPlayerId());
  for i = 1,count do
    local emailId = netdata:ReadInt();
	local uSendTime = netdata:ReadInt();
	local btAttachState = netdata:ReadByte();
	local name = netdata:ReadUnicodeString();
	LogInfo("emailId="..emailId); 
	LogInfo("uSendTime="..uSendTime);
	LogInfo("btAttachState="..btAttachState);
	LogInfo("name="..name);
	SetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eUserEmail,emailId,p.SM_EMAIL_NAME,name);
  end
  if IsUIShow(NMAINSCENECHILDTAG.EmailList) then
    EmailList.refreshUserEmailList();
  end
end

--网络消息处理(玩家邮件邮件信息)
function p.ProcessEmailInfo(netdata)
  LogInfo("p.ProcessEmailInfo");
  CloseLoadBar();
  local emailId = netdata:ReadInt();
  local uFailTime = netdata:ReadInt();
  local btLetterInfo = netdata:ReadByte(); 
  
  local nRoleId = ConvertN(GetPlayerId());
  local userEmailIdList = p.GetUserEmailIdList(nRoleId);
  
  for i, v in ipairs(userEmailIdList) do
    if v == emailId then
	  local content = netdata:ReadUnicodeString();	  
	  LogInfo("emailId="..emailId);
	  LogInfo("uFailTime="..uFailTime);
	  LogInfo("btLetterInfo="..btLetterInfo);
	  LogInfo("content="..content);	  
	  p.DelEmail(nRoleId,emailId);
	  CommonDlg.ShowWithConfirm(content, nil)
	  if IsUIShow(NMAINSCENECHILDTAG.EmailList) then
        EmailList.refreshUserEmailList();
      end
	  break;
	end
  end
  
end

--邮件消息回复
function p.ProcessEmailRequest(netdata)
  LogInfo("p.ProcessEmailRequest");
  return;
end

--发送邮件消息
function p.SendLetterMsg(emailId,act)
  local netdata = createNDTransData(NMSG_Type._MSG_LETTER_REQUEST);
  if nil == netdata then
	LogInfo("发送邮件消息失败,内存不够");
	return false;
  end  
  netdata:WriteInt(emailId);
  netdata:WriteInt(act);
  SendMsg(netdata);
  netdata:Free();
  return true;
end

--查看邮件
function p.LookEmail(emailId)
  LogInfo("p.LookEmail(%d)",emailId);
  p.SendLetterMsg(emailId,p.SM_EMAIL_LETTER_LOOK);
  ShowLoadBar();
end

--删除邮件
function p.DelEmail(nRoleId,emailId)
  DelRoleSubGameDataById(NScriptData.eRole,nRoleId,NRoleData.eUserEmail,emailId);
  p.SendLetterMsg(emailId,p.SM_EMAIL_LETTER_DEL);
end

--忽略邮件（删除所有邮件）
function p.IgnoreEmail()
  local nRoleId = ConvertN(GetPlayerId());
  local userEmailIdList = p.GetUserEmailIdList(nRoleId);
  for i, v in ipairs(userEmailIdList) do
    p.DelEmail(nRoleId,v);
  end
  if IsUIShow(NMAINSCENECHILDTAG.EmailList) then
    EmailList.refreshUserEmailList();
  end
end

--获取玩家的邮件id列表
function p.GetUserEmailIdList(nRoleId)
  local emailIdList = GetGameDataIdList(NScriptData.eRole, nRoleId, NRoleData.eUserEmail);
  emailIdList = emailIdList or {};
  return emailIdList;
end

RegisterNetMsgHandler(NMSG_Type._MSG_RECEIED_LETTER, "p.ProcessReceiedEmail", p.ProcessReceiedEmail);
RegisterNetMsgHandler(NMSG_Type._MSG_LETTER_INFO, "p.ProcessEmailInfo", p.ProcessEmailInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_LETTER_REQUEST, "p.ProcessEmailRequest", p.ProcessEmailRequest);


	
	