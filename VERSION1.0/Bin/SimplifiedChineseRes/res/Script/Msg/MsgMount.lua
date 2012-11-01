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
    pre_exp = nil;      --上一次经验
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
        PlayEffectAnimation.ShowAnimation( 3 );
        
        --提示属性增加
        local tempstr1,tempstr2,tempstr3,tempstr4,tempstr5,tempstr6,tempstr7,tempstr8,tempstr9,tempstr10;
        
        tempstr1 = GetDataBaseDataN("mount_config",p.RolePetInfo.star,DB_MOUNT.STR);
        tempstr2 = GetDataBaseDataN("mount_config",p.RolePetInfo.star,DB_MOUNT.AGI);
        tempstr3 = GetDataBaseDataN("mount_config",p.RolePetInfo.star,DB_MOUNT.INI);
        tempstr4 = GetDataBaseDataN("mount_config",p.RolePetInfo.star,DB_MOUNT.LIFE);
        tempstr5 = GetDataBaseDataN("mount_config",p.RolePetInfo.star,DB_MOUNT.SPEED);
        
        tempstr6 = GetDataBaseDataN("mount_config",star,DB_MOUNT.STR);
        tempstr7 = GetDataBaseDataN("mount_config",star,DB_MOUNT.AGI);
        tempstr8 = GetDataBaseDataN("mount_config",star,DB_MOUNT.INI);
        tempstr9 = GetDataBaseDataN("mount_config",star,DB_MOUNT.LIFE);
        tempstr10 = GetDataBaseDataN("mount_config",star,DB_MOUNT.SPEED);
        
        tempstr1 = tempstr6 - tempstr1;
        tempstr2 = tempstr7 - tempstr2;
        tempstr3 = tempstr8 - tempstr3;
        tempstr4 = tempstr9 - tempstr4;
        tempstr5 = tempstr10 - tempstr5;
        
        local tips = {};
        if(tempstr1>0) then
            table.insert(tips,{"力量 +"..tempstr1,FontColor.Text});
        end
        if(tempstr2>0) then
            table.insert(tips,{"敏捷 +"..tempstr2,FontColor.Text});
        end
        if(tempstr3>0) then
            table.insert(tips,{"智力 +"..tempstr3,FontColor.Text});
        end
        if(tempstr4>0) then
            table.insert(tips,{"生命 +"..tempstr4,FontColor.Text});
        end
        if(tempstr5>0) then
            table.insert(tips,{string.format("速度 +%d%s",tempstr5,"%"),FontColor.Text});
        end
        
        CommonDlgNew.ShowTipsDlg(tips);
        
        
        
        local nTrun1 = PetUI.GetTurn(p.RolePetInfo.star);
        local nTrun2 = PetUI.GetTurn(star);
        
        if(nTrun1 ~= nTrun2) then
            PetUI.OpenTutorial();
        end
        
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
    local m = {};
    LogInfo("p.receiveSendTrainResult");
    m.nTrainType = netdata:ReadInt();           --培养类型
    m.nBigCrit = netdata:ReadByte();            --大暴击次数
    m.nSmallCrit = netdata:ReadByte();          --小暴击次数
    m.nTrainExp = netdata:ReadInt();            --培养经验
    
    LogInfo("m.nTrainType:[%d],m.nBigCrit:[%d],m.nSmallCrit:[%d],m.nTrainExp:[%d],",m.nTrainType,m.nBigCrit,m.nSmallCrit,m.nTrainExp);
    
    
    if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_USER_CHANGE_MOUNT_UPGRUDE,m);
	end
    CloseLoadBar();
end


--==宠物
RegisterNetMsgHandler(NMSG_Type._MSG_MOUNT_INFO_LIST, "p.processMountInfo", p.processMountInfo);--获得坐骑信息
RegisterNetMsgHandler(NMSG_Type._MSG_USER_CHANGE_MOUNT_TYPE, "p.receiveSendIllsionResult", p.receiveSendIllsionResult);--幻化
RegisterNetMsgHandler(NMSG_Type._MSG_USER_CHANGE_MOUNT_STATUS, "p.receiveRideUpgradeResult", p.receiveRideUpgradeResult);--休息/骑
RegisterNetMsgHandler(NMSG_Type._MSG_USER_CHANGE_MOUNT_UPGRUDE, "p.receiveSendTrainResult", p.receiveSendTrainResult);--培养










