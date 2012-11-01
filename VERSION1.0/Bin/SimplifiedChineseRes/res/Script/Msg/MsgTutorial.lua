---------------------------------------------------
--描述: 网络消息处理()消息处理及其逻辑
--时间: 2012.5.16
--作者: chh
---------------------------------------------------

MsgTutorial = {};
local p = MsgTutorial;
local _G = _G;

p.mUIListener = nil;

p.mProgressInfo = {};

function p.getProgressInfo()
    return p.mProgressInfo;
end

--发送教程进度
function p.sendProgress(nStage)
    LogInfo("p.sendProgress: MSID:[%d]",NMSG_Type._MSG_UPGRADE_GUIDE_STAGE);
	local netdata = createNDTransData(NMSG_Type._MSG_UPGRADE_GUIDE_STAGE);
	if not CheckP(netdata) then
        LogInfo("p.sendProgress netdata fail!");
		return false;
	end
	
	netdata:WriteInt(nStage);
    SendMsg(netdata);
	netdata:Free();
	
	return true;
end

RegisterNetMsgHandler(NMSG_Type._MSG_UPGRADE_GUIDE_STAGE, "p.processProgressInfo", p.processProgressInfo);	