
local _G = _G;
setfenv(1, NPC);

function NPC_CLICK_12345(nNpcId)
	OpenNpcDlg(12345);
	SetTitle("天宫寻宝");
	SetContent("天宫活动xxx");
	AddOpt("报名", 1);
	AddOpt("进入", 2);
    return true;
end 

function NPC_CLICK_10099(nNpcId)
	LogInfo("NPC_CLICK_10099");
	local netdata = _G.createNDTransData(_G.NMSG_Type._MSG_NPC);
	if nil == netdata then
		LogInfo("NPC_CLICK_10099,内存不够");
		return false;
	end
	_G.LogInfo("NPC_CLICK_10099")
	netdata:WriteInt(nNpcId);
	netdata:WriteByte(0);
	netdata:WriteByte(0);
	netdata:WriteInt(123);
	--_G.SendMsg(netdata);
	netdata:Free();
	--_G.ShowLoadBar();
	if not _G.IsUIShow(_G.NMAINSCENECHILDTAG.AffixNormalBoss) then
		local mapId = getMapId(nNpcId);
		_G.NormalBossListUI.LoadUIByBossId(mapId);
	end
	return false;
end 

function NPC_CLICK_20099(nNpcId)
	return NPC_CLICK_10099(20099);
end

function NPC_CLICK_30099(nNpcId)
	return NPC_CLICK_10099(30099);
end

function NPC_CLICK_40099(nNpcId)
	return NPC_CLICK_10099(40099);
end

function NPC_CLICK_60099(nNpcId)
	return NPC_CLICK_10099(60099);
end

function NPC_CLICK_70099(nNpcId)
	return NPC_CLICK_10099(70099);
end   

function NPC_OPTION_12345(nNpcId, nAction)
	if 1 == nAction then
		-- 报名(发送报名消息)
		-- 其它检查...
		SendOpt(nNpcId, nAction);
	elseif 2 == nAction then
		-- 进入(发送进入消息 )
		-- 其它检查...
		SendOpt(nNpcId, nAction);
	end
	
	return true;
end