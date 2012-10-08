---------------------------------------------------
--描述: 处理BOSS战相关消息
--时间: 2012.3.16
--作者: cl
---------------------------------------------------

MsgBoss = {}
local p = MsgBoss;


function p.ProcessBossBattleInfo(netdata)
	local btFlag	= netdata:ReadByte();
	if not IsUIShow(NMAINSCENECHILDTAG.bossUI) then
		LogInfo("loadBossUI");
		bossUI.LoadUI();
		hideDynMapUI();
	end
	
	local life		= netdata:ReadInt();
	local lifeLimit	= netdata:ReadInt();
	local restTime = netdata:ReadInt();
	bossUI.SetRestTime(restTime);
	bossUI.SetBossLife(life,lifeLimit);
	
	local count = netdata:ReadByte();
	LogInfo("life:%d/%d,resttime:%d",life,lifeLimit,restTime);
	for i=1,count do
		local id=netdata:ReadInt();
		local rank = netdata:ReadShort();
		local damage = netdata:ReadInt();
		LogInfo("id:%d,rank:%d,damage:%d",id,rank,damage);
		local name = netdata:ReadUnicodeString();
		bossUI.SetRankInfo(rank,name,damage);
	end
	
	
end

function p.ProcessBossSelfInfo(netdata)
	if not IsUIShow(NMAINSCENECHILDTAG.bossUI) then
		LogInfo("loadBossUI");
		bossUI.LoadUI();
		hideDynMapUI();
	end
	
	local time = netdata:ReadInt();
	local x = netdata:ReadInt();
	local damage = netdata:ReadInt();
	
	local mapLayer=GetMapLayer();

	mapLayer:setStartRoadBlockTimer(time,x,-1);
	
	bossUI.SetSelfDamage(damage);
end

function p.QuitBossBattle()
	local netdata = createNDTransData(NMSG_Type._MSG_QUIT_BOSS_BATTLE);
	if nil == netdata then
		return false;
	end
	SendMsg(netdata);
	netdata:Free();
end

function p.SendReVive(action)
	LogInfo("revive:%d",action);
	local netdata = createNDTransData(NMSG_Type._MSG_BOSS_BATTLE);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(action);
	SendMsg(netdata);
	netdata:Free();
end


RegisterNetMsgHandler(NMSG_Type._MSG_BOSS_BATTLE_INFO, "p.ProcessBossBattleInfo", p.ProcessBossBattleInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_BOSS_SELF_INFO, "p.ProcessBossSelfInfo", p.ProcessBossSelfInfo);