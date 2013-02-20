-----------------------------
--处理聊天信息
--cl
-----------------------------


MsgChat={}
local p=MsgChat;


function p.ProcessTalkInfo(netdatas)
	LogInfo("receive_talk");
    LogInfo("receive p.ProcessTalkInfo");
    
	netdatas:ReadByte();
	local channel = netdatas:ReadByte();
	netdatas:ReadInt();
	netdatas:ReadByte();
	local count=netdatas:ReadByte()+1;
	
	local speaker="";
	local text="";
	local nProId=nil;
	for i=1,count do
		if i==1 then
			text=netdatas:ReadUnicodeString();
		elseif i==2 then
			speaker=netdatas:ReadUnicodeString();
		elseif i==3 then
			nProId =netdatas:ReadInt();
		end
	end
    
    LogInfo("channel = %d, text = %s", channel, text);
    if channel == 17 then
        CommonDlgNew.ShowYesDlg(text,nil,nil,3);
        return;
    end
    if channel == 22 then
        --CommonScrollDlg.ShowTipDlg({text,ccc4(242,101,34,255)});
        channel = 5;
    end
    CloseLoadBar();
    
	local speakerID=netdatas:ReadInt();
	--LogInfo("receive_talk,channel:%d,speaker:%s,text:%s speakerID:%d nProId:%d",channel,speaker,text,speakerID,nProId);--nProId==nil??
	if string.len(speaker)<=0 then
		return;
	end
	
	if string.find(speaker,"SYSTEM")~=nil then
		speaker=GetTxtPri("CMUI_T4");
	end

	if string.find(speaker,GetTxtPub("system"))~=nil then
		speaker=GetTxtPri("CMUI_T4");
	end
		
	ChatDataFunc.AddChatRecord(speakerID,channel,0,speaker,text);
	
end

function p.SendPrivateTalk(tid,name,text)
	local netdata = createNDTransData(NMSG_Type._MSG_TALK);
	local time=GetCurrentTime();
	netdata:WriteByte(0);
	netdata:WriteByte(1);
	netdata:WriteInt(time);
	netdata:WriteByte(0);
	netdata:WriteByte(2);
	netdata:WriteStr(text);
	netdata:WriteStr(name);
	if nil == netdata then
		return false;
	end
	SendMsg(netdata);
	netdata:Free();
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local playername = GetRoleBasicDataS(nPlayerId,USER_ATTR.USER_ATTR_NAME);
	
	ChatDataFunc.AddChatRecord(nPlayerId,1,tid,string.format(GetTxtPri("MC_T1"),playername,name),text);
end

function p.SendTalkMsg(channel,text)
	LogInfo("p.sendtalk2");
	local netdata = createNDTransData(NMSG_Type._MSG_TALK);
	local time=GetCurrentTime();
	netdata:WriteByte(0);
	netdata:WriteByte(channel);
	netdata:WriteInt(time);
	netdata:WriteByte(0);
	netdata:WriteByte(2);
	netdata:WriteStr(text);
	netdata:WriteStr("word");
	if nil == netdata then
		return false;
	end
	SendMsg(netdata);
	netdata:Free();
	LogInfo("p.sendtalk3");
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	local name = GetRoleBasicDataS(nPlayerId,USER_ATTR.USER_ATTR_NAME);
	
	ChatDataFunc.AddChatRecord(nPlayerId,channel,0,name,text);
end


RegisterNetMsgHandler(NMSG_Type._MSG_TALK,"p.ProcessTalkInfo",p.ProcessTalkInfo);