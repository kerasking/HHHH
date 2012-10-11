---------------------------------------------------
--描述: 玩家练功网络消息处理及其逻辑
--时间: 2012.4.26
--作者: jhzheng
---------------------------------------------------

MsgPractise = {}
local p = MsgPractise;

local MSG_PRACTISE_ACT_BEGIN				= 0;
local MSG_PRACTISE_ACT_START				= 1; --开始练功
local MSG_PRACTISE_ACT_STOP					= 2; --练功结束
local MSG_PRACTISE_ACT_END					= 3;

--发送开始练功
function p.SendStart()
	p.SendAction(MSG_PRACTISE_ACT_START);
end

--发送停止练功
function p.SendStop()
	p.SendAction(MSG_PRACTISE_ACT_STOP);
end

function p.SendAction(nAction)
	if not CheckN(nAction) then
		return;
	end
	
	if nAction <= MSG_PRACTISE_ACT_BEGIN or 
		nAction >= MSG_PRACTISE_ACT_END then
		LogInfo("发送练功消息失败,action不对");
		return;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_PRACTISE_ACTION);
	if nil == netdata then
		LogError("发送练功消息失败,内存不够");
		return false;
	end
	netdata:WriteByte(nAction);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send Practise action[%d]", nAction);
	return true;
end

-- 网络消息处理(练功action)
function p.ProcessAction(netdata)
	local byAction				= netdata:ReadByte();
	
	if byAction == MSG_PRACTISE_ACT_START then
		local nRemainSecond			= netdata:ReadInt();
		local nAcquireExp			= netdata:ReadInt();
		MainUIPractise.Show(true);
		MainUIPractise.SetTime(nRemainSecond);
		MainUIPractise.SetExp(nAcquireExp);
	elseif byAction == MSG_PRACTISE_ACT_STOP then
		MainUIPractise.Show(false);
	end 
	
	return 1;
end


function p.ProcessAward(netdata)
	local nAcquireExp				= ConvertN(netdata:ReadInt());
	MainUIPractise.SetExp(nAcquireExp);
end

RegisterNetMsgHandler(NMSG_Type._MSG_PRACTISE_ACTION, "MsgPractise.ProcessAction", p.ProcessAction);

RegisterNetMsgHandler(NMSG_Type._MSG_PRACTISE_AWARD, "MsgPractise.ProcessAward", p.ProcessAward);
