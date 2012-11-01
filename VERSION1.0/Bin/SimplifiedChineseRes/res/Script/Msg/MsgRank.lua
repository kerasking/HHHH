---------------------------------------------------
--描述: 网络消息处理(军衔)
--时间: 2012.5.10
--作者: chh
---------------------------------------------------

MsgRank = {}
local p = MsgRank;
local _G = _G;

p.mUIListener = nil;

p.RankInfo = {
    LEVEL = 1,      --军衔等级
    PRESTIGE = 1,   --声望
};

--军衔升级
function p.sendRankUpgrade()
    ShowLoadBar();
	local netdata = createNDTransData(NMSG_Type._MSG_RANK_UPGRADE);
	if nil == netdata then
		return false;
	end
	SendMsg(netdata);
	netdata:Free();
	return true;
end

function p.receiveSendRankUpgradeResult(netdata)
    CloseLoadBar();
    LogInfo("p.receiveSendRankUpgradeResult");
    local status = netdata:ReadInt();
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_RANK_UPGRADE,status);
	end
end

--==声望
RegisterNetMsgHandler(NMSG_Type._MSG_RANK_UPGRADE, "p.receiveSendRankUpgradeResult", p.receiveSendRankUpgradeResult);
	