---------------------------------------------------
--描述: 处理竞技场相关消息
--时间: 2012.3.21
--作者: cl
---------------------------------------------------

MsgArena = {}
local p = MsgArena;

local MSG_SPORTS_ACT_QUERY=1;
local MSG_SPORTS_ACT_QUERY_FRONT=2;
local MSG_SPORTS_ACT_CHALLENGE=3;
local MSG_SPORTS_ACT_CLEAR_TIME = 4;
local MSG_SPORTS_ACT_ADD_NUM = 5;

function p.ProcessArenaInfo(netdatas)
	local rank=netdatas:ReadInt();
	local restCount=netdatas:ReadByte();
	local cdTime=netdatas:ReadInt();
	local awardTime=netdatas:ReadInt();
	local awardMoney=netdatas:ReadInt();
	local awardRepute=netdatas:ReadInt();
	
	local userCount=netdatas:ReadByte();
	local reportCount=netdatas:ReadByte();
	
	local name=netdatas:ReadUnicodeString();
	
	if not IsUIShow(NMAINSCENECHILDTAG.Arena) then
				ArenaUI.LoadUI();
	end
	
	ArenaUI.SetAwardInfo(awardTime,awardMoney,awardRepute);
	
	ArenaUI.SetSelfInfo(rank,restCount,cdTime,name);
	
	ArenaUI.CleanChallengeList();
	for	i=1, userCount do
		local id=netdatas:ReadInt();
		local lookface=netdatas:ReadInt();
		local level=netdatas:ReadShort();
		local rank=netdatas:ReadInt();
		local user_name=netdatas:ReadUnicodeString();
		LogInfo("%d,rank:%d"..user_name,i,rank)
		ArenaUI.SetChallengeList(i,id,user_name,level,rank);
	end
	
	ArenaUI.CleanReport()
	for i=1, reportCount do
		local id_user=netdatas:ReadInt();
		local id_battle=netdatas:ReadInt();
		local time=netdatas:ReadInt();
		local rankChange=netdatas:ReadInt();
		local win=netdatas:ReadByte();--0为失败，1为胜利
		local battle_type=netdatas:ReadByte();--0为被挑战方，非0为挑战方
		local user_name=netdatas:ReadUnicodeString();
		LogInfo("showReport:%d",id_battle);
		ArenaUI.SetReportInfo(i,user_name,battle_type,win,time,rankChange,id_battle);
	end
	

end


function p.ProcessArenaRankInfo(netdatas)
	if not IsUIShow(NMAINSCENECHILDTAG.ArenaRank) then
		ArenaRankUI.LoadUI();
	end
	local flag = netdatas:ReadByte();
	local count = netdatas:ReadByte();
	--count=4;
	for i=1,count do
		LogInfo("ArenaRank:%d",i);
		local id = netdatas:ReadInt();
		local level = netdatas:ReadShort();
		local rank = netdatas:ReadInt();
		local power = netdatas:ReadInt();
		local name = netdatas:ReadUnicodeString();
		--LogInfo(name..":%d,%d,%d,%d",id,level,rank,power);
		ArenaRankUI.SetRankInfo(rank,name,level,power,id);
	end
end

function p.SendOpenArena()
	local netdata = createNDTransData(NMSG_Type._MSG_SPORTS);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(MSG_SPORTS_ACT_QUERY);
	netdata:WriteInt(0);
	SendMsg(netdata);
	netdata:Free();
end

function p.SendChallenge(rank)
	local netdata = createNDTransData(NMSG_Type._MSG_SPORTS);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(MSG_SPORTS_ACT_CHALLENGE);
	netdata:WriteInt(rank);
	SendMsg(netdata);
	netdata:Free();
end

function p.SendFrontRank()
	local netdata = createNDTransData(NMSG_Type._MSG_SPORTS);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(MSG_SPORTS_ACT_QUERY_FRONT);
	netdata:WriteInt(0);
	SendMsg(netdata);
	netdata:Free();
end

function p.SendClearTime()
	local netdata = createNDTransData(NMSG_Type._MSG_SPORTS);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(MSG_SPORTS_ACT_CLEAR_TIME);
	netdata:WriteInt(0);
	SendMsg(netdata);
	netdata:Free();
end

function p.SendAddTime()
	local netdata = createNDTransData(NMSG_Type._MSG_SPORTS);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(MSG_SPORTS_ACT_ADD_NUM);
	netdata:WriteInt(0);
	SendMsg(netdata);
	netdata:Free();
end

function p.SendWatchBattle(battle_id)
	LogInfo("watchBattle:%d",battle_id);
	local netdata = createNDTransData(NMSG_Type._MSG_SPORTS_WATCH_BATTLE);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(battle_id);
	SendMsg(netdata);
	netdata:Free();
end

function p.ProcessArenaUpdate(netdatas)
 local action = netdatas:ReadByte();
 if action == MSG_SPORTS_ACT_CLEAR_TIME then
	if IsUIShow(NMAINSCENECHILDTAG.Arena) then
		local time=netdatas:ReadInt();
		--LogInfo("updateTime:%d",time);
		ArenaUI.updateTime(time);
	end
 elseif action == MSG_SPORTS_ACT_ADD_NUM then
	if IsUIShow(NMAINSCENECHILDTAG.Arena) then
		ArenaUI.updateCount(netdatas:ReadByte());
	end
 end
end

RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS,"p.ProcessArenaUpdate",p.ProcessArenaUpdate);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_INFO, "p.ProcessArenaInfo", p.ProcessArenaInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_FRONT_INFO, "p.ProcessArenaRankInfo", p.ProcessArenaRankInfo);