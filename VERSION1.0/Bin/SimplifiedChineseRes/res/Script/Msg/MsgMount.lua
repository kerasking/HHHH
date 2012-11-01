---------------------------------------------------
--描述: 网络消息处理(奇术:阵法，功法)消息处理及其逻辑
--时间: 2012.3.1
--作者: wjl
---------------------------------------------------

MsgMount = {}
local p = MsgMount;
local _G = _G;

p.mUIListener = nil;


p.RolePetInfo = {   
    pre_exp = nil;        --上一次经验
    exp     = 0,        --经验
    star    = 0,        --星级
    ride    = 0,        --0.休息 1.骑
    illusionId = 0,     --幻化等级
};

--==宠物
function p.getMountInfo()
    return p.RolePetInfo;
end

function p.changeMount()
    --++Guosen 2012.7.15
	local nRideStatus	= p.RolePetInfo.ride;
	local nMountType	= p.RolePetInfo.illusionId;
	PlayerRideMount( nRideStatus, nMountType );
end

--==宠物信息
function p.processMountInfo(netdata)
    CloseLoadBar();
    
    local nExp           = netdata:ReadInt();
    if(p.RolePetInfo.pre_exp) then
        p.RolePetInfo.pre_exp = p.RolePetInfo.exp;
    else
        p.RolePetInfo.pre_exp = nExp;
    end
    p.RolePetInfo.exp = nExp;
    
    local star          = netdata:ReadByte();
    p.RolePetInfo.ride          = netdata:ReadByte();
    p.RolePetInfo.illusionId    = netdata:ReadByte();
    
    if(p.RolePetInfo.star>0 and p.RolePetInfo.star ~= star) then
        --坐骑升级光效
        PlayEffectAnimation.ShowAnimation( 3 )
    end
    
    p.RolePetInfo.star = star;
    
    LogInfo("exp:[%d],star:[%d],ride:[%d],illusionId:[%d]",p.RolePetInfo.exp,p.RolePetInfo.star,p.RolePetInfo.ride,p.RolePetInfo.illusionId);
    
    p.changeMount();
    
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_MOUNT_INFO_LIST,p.RolePetInfo);
	end
    
	return 1;
end

--幻化
function p.sendIllsion(level)
    
	if not CheckN(level) then
		return false;
	end
    
    LogInfo("p.sendIllsion send level[%d] ", level);
    ShowLoadBar();
    
	local netdata = createNDTransData(NMSG_Type._MSG_USER_CHANGE_MOUNT_TYPE);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(level);
	SendMsg(netdata);
	netdata:Free();
	return true;
end


--幻化回调
function p.receiveSendIllsionResult(netdata)
    LogInfo("p.receiveSendIllsionResult");
    local nIllusionId = netdata:ReadInt();
    p.RolePetInfo.illusionId = nIllusionId;
    
    p.changeMount();
    
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_USER_CHANGE_MOUNT_TYPE,p.RolePetInfo.illusionId);
	end
    CloseLoadBar();
end



--骑乘
function p.sendRideUpgrade(status)
    if not CheckN(status) then
		return false;
	end
    ShowLoadBar();
	local netdata = createNDTransData(NMSG_Type._MSG_USER_CHANGE_MOUNT_STATUS);
	if nil == netdata then
		return false;
	end
    netdata:WriteByte(status);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send status[%d] ", status);
    
	return true;
end

--骑乘回调
function p.receiveRideUpgradeResult(netdata)
    LogInfo("p.receiveRideUpgradeResult");
    local nRide = netdata:ReadByte();
    p.RolePetInfo.ride = nRide;
    
	LogInfo("receive nRide[%d] ", nRide);
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_USER_CHANGE_MOUNT_STATUS,p.RolePetInfo.ride);
	end
    
    p.changeMount();
    
    CloseLoadBar();
end



--培养
function p.sendTrain(tp)
	if not CheckN(tp) then
		return false;
	end
    --ShowLoadBar();
	local netdata = createNDTransData(NMSG_Type._MSG_USER_CHANGE_MOUNT_UPGRUDE);
	if nil == netdata then
		return false;
	end
    
    netdata:WriteByte(tp);
	SendMsg(netdata);
	netdata:Free();
	return true;
end

function p.receiveSendTrainResult(netdata)
    LogInfo("p.receiveSendTrainResult");
    local status = netdata:ReadInt();       --培养类型
    local status = netdata:ReadByte();      --0无 1.暴击
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_USER_CHANGE_MOUNT_UPGRUDE,status);
	end
    CloseLoadBar();
end


--==宠物
RegisterNetMsgHandler(NMSG_Type._MSG_MOUNT_INFO_LIST, "p.processMountInfo", p.processMountInfo);--获得坐骑信息
RegisterNetMsgHandler(NMSG_Type._MSG_USER_CHANGE_MOUNT_TYPE, "p.receiveSendIllsionResult", p.receiveSendIllsionResult);--幻化
RegisterNetMsgHandler(NMSG_Type._MSG_USER_CHANGE_MOUNT_STATUS, "p.receiveRideUpgradeResult", p.receiveRideUpgradeResult);--休息/骑
RegisterNetMsgHandler(NMSG_Type._MSG_USER_CHANGE_MOUNT_UPGRUDE, "p.receiveSendTrainResult", p.receiveSendTrainResult);--培养










