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


--** chh 2012-07-11 **--
p.areaPkCount = 0;

--获得竞技场剩余次数
function p.GetArenaPKCount()
    return p.areaPkCount;
end

--获得竞技场PK次数
function p.ProcessArenaPKCount(netdatas)
    p.areaPkCount = netdatas:ReadShort();
    LogInfo("p.ProcessArenaPKCount p.areaPkCount:[%d]",p.areaPkCount);
end



function p.ProcessArenaInfo(netdatas)
	local rank=netdatas:ReadInt();
    --LogInfo("+++++++++++++++rank[%d]+++++++++++++++++",rank);
	local restCount=netdatas:ReadByte();
    --LogInfo("+++++++++++++++restCount[%d]+++++++++++++++++",restCount);
	local addedCount=netdatas:ReadShort();
    LogInfo("+++++++++++++++addedCount[%d]+++++++++++++++++",addedCount);
	local cdTime=netdatas:ReadInt();
    LogInfo("+++++++++++++++cdTime[%d]+++++++++++++++++",cdTime);
	local awardTime=netdatas:ReadInt();
    --LogInfo("+++++++++++++++awardTime[%d]+++++++++++++++++",awardTime);
	local awardMoney=netdatas:ReadInt();
    --LogInfo("+++++++++++++++awardMoney[%d]+++++++++++++++++",awardMoney);
	local awardRepute=netdatas:ReadInt();
    --LogInfo("+++++++++++++++awardRepute[%d]+++++++++++++++++",awardRepute);
    local winCount=netdatas:ReadInt();
    --LogInfo("+++++++++++++++winCount[%d]+++++++++++++++++",winCount);
	local userCount=netdatas:ReadByte();
    --LogInfo("+++++++++++++++userCount[%d]+++++++++++++++++",userCount);
	local reportCount=netdatas:ReadByte();
   --LogInfo("+++++++++++++++reportCount[%d]+++++++++++++++++",reportCount);
	local name=netdatas:ReadUnicodeString();
    --LogInfo("+++++++++++++++name[%s]+++++++++++++++++",name);
    
    --成功进入竞技场战斗
    if cdTime == 180 then
    	--引导任务事件触发
		GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.SPORT);
    end
        
	if not IsUIShow(NMAINSCENECHILDTAG.Arena) then
		ArenaUI.LoadUI();		
	end
	
    ArenaUI.RefreshUI();
	ArenaUI.SetAwardInfo(awardTime,awardMoney,awardRepute);
	
	ArenaUI.SetSelfInfo(rank,restCount,addedCount,cdTime,winCount);
	
	ArenaUI.CleanChallengeList();
    LogInfo("p.ProcessArenaInfo %d",userCount);
    
	for i=1, userCount do
		local id=netdatas:ReadInt();
        LogInfo("+++++++++++++++id[%d]+++++++++++++++++",id);
		local lookface=netdatas:ReadInt();
        --LogInfo("+++++++++++++++lookface[%d]+++++++++++++++++",lookface);
		local level=netdatas:ReadShort();
        LogInfo("+++++++++++++++level[%d]+++++++++++++++++",level);
		local rank=netdatas:ReadInt();
        --LogInfo("+++++++++++++++rank[%d]+++++++++++++++++",rank);
		local user_name=netdatas:ReadUnicodeString();
        --LogInfo("+++++++++++++++user_name[%s]+++++++++++++++++",rank);
		--LogInfo("%d,rank:%d"..user_name,i,rank)
        LogInfo("p.ProcessArenaInfo %s",user_name);
		ArenaUI.SetChallengeList(i,id,user_name,level,rank,lookface);
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
    
    ArenaUI.SetButtonVisible(reportCount);
    

    
end


function p.ProcessArenaRankInfo(netdatas)
     LogInfo("+++++++++++++++p.ProcessArenaRankInfop.ProcessArenaRankInfo+++++++++++++++++")
        ArenaRankUI.LoadUI();

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
		LogInfo(name..":%d,%d,%d,%d",id,level,rank,power);
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
  LogInfo("+++++++++++++++p.ProcessArenaUpdatep.ProcessArenaUpdate+++++++++++++++++")
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



RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_COUNT,"p.ProcessArenaPKCount",p.ProcessArenaPKCount);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS,"p.ProcessArenaUpdate",p.ProcessArenaUpdate);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_INFO, "p.ProcessArenaInfo", p.ProcessArenaInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_FRONT_INFO, "p.ProcessArenaRankInfo", p.ProcessArenaRankInfo);