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
local MSG_SPORTS_ACT_REPOR = 6;

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
	local restCount=netdatas:ReadByte();
	local addedCount=netdatas:ReadShort();
	local cdTime=netdatas:ReadInt();
	local awardTime=netdatas:ReadInt();
	netdatas:ReadInt();
	netdatas:ReadInt();
    local winCount=netdatas:ReadInt();
	local userCount=netdatas:ReadByte();
	local reportCount=netdatas:ReadByte();
    if(userCount>0) then
        --成功进入竞技场战斗
        if cdTime == 180 then
            --引导任务事件触发
            GlobalEvent.OnEvent(GLOBALEVENT.GE_GUIDETASK_ACTION,TASK_GUIDE_PARAM.SPORT);
        end
        
        if not IsUIShow(NMAINSCENECHILDTAG.Arena) then
            CloseLoadBar();
            ArenaUI.LoadUI();		
        end
        
        ArenaUI.RefreshUI();
        ArenaUI.SetTimerNum(awardTime);
        ArenaUI.SetSelfInfo(rank,restCount,addedCount,cdTime,winCount);
	end
    
    LogInfo("p.ProcessArenaInfo %d",userCount);
    
    local lst = {};
	for i=1, userCount do
        local obj = {};
        obj.index=i;
		obj.id=netdatas:ReadInt();
		obj.lookfaceID=netdatas:ReadInt();
		obj.level=netdatas:ReadShort();
		obj.rank=netdatas:ReadInt();
		obj.name=netdatas:ReadUnicodeString();
        table.insert(lst,obj);
		--ArenaUI.SetChallengeList(i,id,user_name,level,rank,lookface);
	end

    if(userCount>0) then
        ArenaUI.CleanChallengeList();
        ArenaUI.RefreshRankList(lst);
    end
    
    local report_lst = {};
    LogInfo("reportCount:[%d]",reportCount);
	for i=1, reportCount do
        local report = {};
		report.id_user=netdatas:ReadInt();
		report.id_battle=netdatas:ReadInt();
		report.time=netdatas:ReadInt();
		report.rankChange=netdatas:ReadInt();
		report.win=netdatas:ReadByte();--0为失败，1为胜利
		report.battle_type=netdatas:ReadByte();--0为被挑战方，非0为挑战方
		LogInfo("report.id_user:[%d],report.id_battle:[%d],report.time:[%d],report.rankChange:[%d],report.win:[%d],report.battle_type:[%d]",report.id_user,report.id_battle,report.time,report.rankChange,report.win,report.battle_type);
        report.user_name=netdatas:ReadUnicodeString();
        table.insert(report_lst,report);
		--ArenaUI.SetReportInfo(i,user_name,battle_type,win,time,rankChange,id_battle);
	end
    ArenaUI.RefreshRefresh( report_lst );
    
    --前一争夺战
    
end


function p.ProcessRecord(netdatas)
    LogInfo("p.ProcessRecord");
    local report_lst = {};
    local nCount=netdatas:ReadByte();
    LogInfo("p.ProcessRecord:nCount:[%d]",nCount);
    for i=1, nCount do
        local report = {};
		report.id_battle=netdatas:ReadInt();
		report.time=netdatas:ReadInt();
        netdatas:ReadByte();
        report.user_name1=netdatas:ReadUnicodeString();
        report.user_name2=netdatas:ReadUnicodeString();
        table.insert(report_lst,report);
	end
    ArenaUI.RefreshRecord( report_lst );
end

function p.ProcessArenaRankInfo(netdatas)
     LogInfo("+++++++++++++++p.ProcessArenaRankInfop.ProcessArenaRankInfo+++++++++++++++++")
    if not IsUIShow(NMAINSCENECHILDTAG.ArenaRank) then   
        ArenaRankUI.LoadUI();
    end

	local flag = netdatas:ReadByte();
	local count = netdatas:ReadByte();
	--count=4;
	for i=1, count do
		LogInfo("ArenaRank:%d",i);
		local id = netdatas:ReadInt();
		local level = netdatas:ReadShort();
		local rank = netdatas:ReadInt();
		local power = netdatas:ReadInt();
		local name = netdatas:ReadUnicodeString();
		LogInfo("count = %d, name = %s, id = %d, level = %d, rank = %d, power = %d",count, name, id,level,rank,power);
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

--打开我的战报
function p.SendOpenReport()
	local netdata = createNDTransData(NMSG_Type._MSG_SPORTS);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(MSG_SPORTS_ACT_REPOR);
	netdata:WriteInt(0);
	SendMsg(netdata);
    ShowLoadBar();
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
 elseif action == MSG_SPORTS_ACT_REPOR then
	if IsUIShow(NMAINSCENECHILDTAG.Arena) then
		ArenaUI.OpenReport();
        CloseLoadBar();
	end
 end
end



RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_COUNT,"p.ProcessArenaPKCount",p.ProcessArenaPKCount);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS,"p.ProcessArenaUpdate",p.ProcessArenaUpdate);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_INFO, "p.ProcessArenaInfo", p.ProcessArenaInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_FRONT_INFO, "p.ProcessArenaRankInfo", p.ProcessArenaRankInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_SPORTS_FRONT_RECORD, "p.ProcessRecord", p.ProcessRecord);
