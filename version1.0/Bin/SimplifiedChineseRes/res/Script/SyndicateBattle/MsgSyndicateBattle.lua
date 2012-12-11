---------------------
--军团战数据包处理 
--2012/10/19
---------------------
------------------------------接口说明--------------------------
--SignUp()  --报名
--GetBattleDetail(battleID) --获取对战详细信息 --battleID:对战ID
--Enter()   --进入一个对战
--Leave()   --离开对战
--------------------------------------------------------------

-------------------------------processor说明-------------------
--SignUpRet(ret) --报名返回
--GetBattleDetailRet(ret) --获取信息返回
--EnterRet() --进入对战返回
--LeaveRet() --离开对战返回
--Report({{idWin,idLose,winnerWinCount,loserWinCount}}) --战报更新
--BattleResult(winSynID,winSynName,loseSynID,loseSynName,{{id,winCount,repute,money}},{{id,winCount,repute,money}}) --战场结果
--CampList(isFirst,{{id,name}},{{id,name}}) --阵营列表
--ChangeCamp({},{id,name},{id,name},{}) --阵营列表改变
--CompleteBattle()                      --完成一场对战
--SignUpInfo({{id,level,contribute,name}})  --报名信息
--StepsInfo(stepType,{battleID,attSynID,defSynID,result}}) --活动阶段信息 --stepType=0:结果,1:八强,2:四强,3:半决赛,4:决赛 --result=-1:未定,0:输,1:赢
--------------------------------------------------------------

MsgSyndicateBattle = {}

local p = MsgSyndicateBattle;
SyndicateBattles = {}

local ActionType={
SignUp = 0,
GetBattleDetail = 1,
Enter = 2,
Leave = 3,
EndBattle = 4,
CloseUI = 5,
GetStepInfo = 6,
}

function p.GetStepInfo()
	local netdata = createNDTransData(NMSG_Type._MSG_SYNDICATEBATTLE_ACTION);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(ActionType.GetStepInfo);	    
	SendMsg(netdata);
	netdata:Free();
end

function p.CloseUI()
     p.SendAction(ActionType.CloseUI)
end


function p.BattleEnd()
     p.SendAction(ActionType.EndBattle)
end

function p.SignUp()
     p.SendAction(ActionType.SignUp)
end

function p.GetBattleDetail(battleID)
     p.SendAction(ActionType.GetBattleDetail,battleID)
end

function p.Enter(battleID)
	p.SendAction(ActionType.Enter,battleID)
end

function p.Leave()
     p.SendAction(ActionType.Leave)
end

function p.SendAction(nActionType,data)

	--LogInfo("qboy  Syndicate:SendAction 1");
	local netdata = createNDTransData(NMSG_Type._MSG_SYNDICATEBATTLE_ACTION);
	--LogInfo("qboy  Syndicate:SendAction 2");
	if nil == netdata then
		return false;
	end
	--LogInfo("qboy  Syndicate:SendAction 3");
	netdata:WriteByte(nActionType);	
	
	if data ~= nil then
		LogInfo("qboy  Syndicate:SendAction data:"..data);
		netdata:WriteInt(data)	
	end
    
	SendMsg(netdata);
	--LogInfo("qboy  Syndicate:SendAction 5");
	netdata:Free();
	--LogInfo("qboy  Syndicate:SendAction nActionType"..nActionType);
	ShowLoadBar();
	return true;
end


--[[
	local netdata = createNDTransData(NMSG_Type._MSG_CHAOSBATTLE_CAMPLIST);
	if nil == netdata then
		return false;
	end
	netdata:WriteByte(0);	
	SendMsg(netdata);
	netdata:Free();
	LogInfo("qboy  SendCampBattleGetCampList");
	ShowLoadBar();
]]
function p.ProcessActionRet(netdata)
    CloseLoadBar();
    LogInfo("qboy SyndicateBattle::ProcessActionRet")
    local action = netdata:ReadByte()
    local ret = netdata:ReadByte()
    LogInfo("qboy data:action="..action..",ret="..ret)
    if(action == ActionType.SignUp) then
        if(SyndicateBattle.SignUpRet ~= nil) then
            SyndicateBattle.SignUpRet(ret)
        end
    elseif(action == ActionType.GetBattleDetail) then
        if(SyndicateBattle.GetBattleDetailRet ~= nil) then
            SyndicateBattle.GetBattleDetalRet(ret)
        end
    --elseif(action == ActionType.Enter) then
        --if(SyndicateBattle.EnterRet ~= nil) then
           -- SyndicateBattleUI.LoadUI();
        --end
    elseif(action == ActionType.Leave) then
        if(SyndicateBattle.LeaveRet ~= nil) then
            SyndicateBattle.LeaveRet(ret)
        end
    end
end

function p.ProcessReport(netdata)
    LogInfo("qboy SyndicateBattle::ProcessReport")
    local count = netdata:ReadShort()
    reportList = {} --idwin,idlose,winnerwincount,loserwincount,winname,losename
    for i=1,count do
        report = {}
        report.idWin = netdata:ReadInt()
        report.idLose = netdata:ReadInt()
        report.winnerWinCount = netdata:ReadShort()
        report.loserWinCount = netdata:ReadShort()
        report.Winname = netdata:ReadUnicodeString();
        report.Losename = netdata:ReadUnicodeString();
        --table.insert(reportList,report)
        SyndicateBattleUI.AddMainReport(report);
        LogInfo("qboy get a report:idwin="..report.idWin..",idLose="..report.idLose..",winnerWinCount="..report.winnerWinCount..",loserWinCount"..report.loserWinCount)
    end
    
    SyndicateBattleUI.RefreshBattleResult();    
end

function p.BattleResultReadUser(netdata)
    user = {}
    user.id = netdata:ReadInt()
    user.winCount = netdata:ReadShort()
    user.repute = netdata:ReadInt()
    user.money = netdata:ReadInt()
    user.name = netdata:ReadUnicodeString();
    return user
end

local g_IfNeedCleanData = true;
function p.ProcessBattleResult(netdata)

    LogInfo("qboy SyndicateBattle::ProcessBattleResult")
    local winSynID = netdata:ReadInt()
    local loseSynID = netdata:ReadInt()
    local winUserCount = netdata:ReadShort()
    local loseUserCount = netdata:ReadShort()
    local nIfIsEnd = netdata:ReadByte()
    local winSynName = netdata:ReadUnicodeString()
    local loseSynName = netdata:ReadUnicodeString()
    --local UserList = SyndicateBattleResultUI.GetResultTable()  --id,wincount,repute,money,name
    
    
    --如果是第一个包 则清空数据
    if g_IfNeedCleanData == true then
    	LogInfo("qboy g_IfNeedCleanData== true");
    	SyndicateBattleResultUI.UserList = {};
    end
    
    for i=1,winUserCount do
        user = p.BattleResultReadUser(netdata)
        user.bIfwin = true;
        user.ArmyName = winSynName;
        table.insert(SyndicateBattleResultUI.UserList,user)
        LogInfo("qboy BattleResult read a winuser:id="..user.id..",wincount="..user.winCount..",repute="..user.repute..",money="..user.money.." name="..user.name)
    end
    for i=1,loseUserCount do
        user = p.BattleResultReadUser(netdata)
        user.bIfwin = false;
        user.ArmyName = loseSynName;
        table.insert(SyndicateBattleResultUI.UserList,user)
        LogInfo("qboy BattleResult read a loseuser:id="..user.id..",wincount="..user.winCount..",repute="..user.repute..",money="..user.money.." name="..user.name)
    end
   
    
    --SyndicateBattleResultUI.ShowBattleResult(winSynID,winSynName,loseSynID,loseSynName,UserList)
    --如果是最后一个包则加载界面
    if nIfIsEnd == 1 then
    	g_IfNeedCleanData = true;
    	--SyndicateBattleResultUI.LoadBattleResult(winSynID,winSynName,loseSynID,loseSynName,UserList)
    	
    	SyndicateBattleResultUI.ShowBattleResult(winSynID,winSynName,loseSynID,loseSynName)
    else
    	g_IfNeedCleanData = false;
    	--SyndicateBattleResultUI.LoadBattleResult(winSynID,winSynName,loseSynID,loseSynName,UserList)
    end
end

function p.ProcessCampList(netdata)
    LogInfo("qboy SyndicateBattle:ProcessCampList")
    local attCount = netdata:ReadShort()
    local defCount = netdata:ReadShort()
    local isFirst = netdata:ReadByte()--1清除列表
    
    if isFirst == 1 then
    	local attArmyName = netdata:ReadUnicodeString();
    	local defArmyName = netdata:ReadUnicodeString();
    	SyndicateBattleUI.SetArmyName(attArmyName,defArmyName);
    end
    
    local attCampUserList = {}  --id,name
    local defCampUserList = {}
    
    LogInfo("qboy CampList attCount:"..attCount.." defCount:"..defCount.." isFirst:"..isFirst);
    if isFirst == 1 then
     	LogInfo("qboy SyndicateBattleUI.ClearAllUser();");
    	SyndicateBattleUI.ClearAllUser();
    end
    
    for i=1,attCount do
        local user = {}
        user.id = netdata:ReadInt()
        user.name = netdata:ReadUnicodeString()
        --table.insert(attCampUserList,user)
        SyndicateBattleUI.AddPlayerToList(user.id,1,user.name);
        LogInfo("qboy CampList Add AttUser:id="..user.id..",name="..user.name)
    end
    for i=1,defCount do
        local user = {}
        user.id = netdata:ReadInt()
        user.name = netdata:ReadUnicodeString()
        --table.insert(defCampList,user)
        SyndicateBattleUI.AddPlayerToList(user.id,2,user.name);
        LogInfo("qboy CampList Add DefUser:id="..user.id..",name="..user.name)
    end
    
    SyndicateBattleUI.RefreshBattleResult();
end

function p.ProcessChangeCamp(netdata)
    LogInfo("qboy SyndicateBattle:ProcessChangeCamp")
    local delCount = netdata:ReadShort()
    local attCount = netdata:ReadShort()
    local defCount = netdata:ReadShort()
    local fightCount = netdata:ReadShort()
    local delList = {}
    local attList = {}
    local defList = {}
    local fightList = {}
    for i=1,delCount do
        SyndicateBattleUI.RemovePlayerFromList(netdata:ReadInt());
    end
    for i=1,attCount do
        local user = {}
        user.id = netdata:ReadInt()
        user.name = netdata:ReadUnicodeString()
        SyndicateBattleUI.AddPlayerToList(user.id,1,user.name);
    end
    for i=1,defCount do
        local user = {}
        user.id = netdata:ReadInt()
        user.name = netdata:ReadUnicodeString()
         SyndicateBattleUI.AddPlayerToList(user.id,2,user.name);
    end
    for i=1,fightCount do
        SyndicateBattleUI.EnterBattle(netdata:ReadInt());
    end
    
    SyndicateBattleUI.RefreshBattleResult();
end

function p.ProcessCompleteBattle(netdata)
    LogInfo("qboy SyndicateBattle:ProcessCompleteBattle")
    
    SyndicateBattleUI.CompleteBattle();
    
end


function p.ProcessSignUpInfo(netdata)
    --LogInfo("qboy SyndicateBattle:ProcessSignUpInfo count:"..count)
    local count = netdata:ReadShort()
    local nLeftTime = netdata:ReadInt()
    local nArmyGroupLev = netdata:ReadInt()
    
    LogInfo("qboy SyndicateBattle:ProcessSignUpInfo count:"..count.." nArmyGroupLev"..nArmyGroupLev)
    local signUpList = {}
    for i=1,count do
        local signUp = {}
        
       
       signUp.id = netdata:ReadInt()
       signUp.level = netdata:ReadShort()
       signUp.contribute = netdata:ReadInt()
       signUp.name = netdata:ReadUnicodeString()
       LogInfo("qboy SyndicateBattle:ProcessSignUpInfo [%d][%d][%d]:",signUp.id,signUp.level,signUp.contribute)
        
       table.insert(signUpList,signUp)
    end
    
    --LogInfo("qboy qqqqq11 n:"..table.getn(signUpList));
     
    if(SyndicateBattle.SignUpInfo ~= nil) then
        SyndicateBattle.SignUpInfo(signUpList,nLeftTime,nArmyGroupLev)
    end
end

function p.ProcessStepsInfo(netdata)
    LogInfo("qboy SyndicateBattle:ProcessStepsInfo")
    local count = netdata:ReadShort()
    local nTimeLeft = netdata:ReadInt();
    local nBattleEndTime = netdata:ReadInt();
    
    local ntype = netdata:ReadInt()
    LogInfo("qboy SyndicateBattle:ProcessStepsInfo count ntype nTimeLeft nBattleEndTime:"..count.." "..ntype.." "..nTimeLeft.." "..nBattleEndTime)
    local stepList = {}
    for i=1,count do
        local step = {}
        step.battleID = netdata:ReadInt()
        step.attSynID = netdata:ReadInt()
        step.defSynID = netdata:ReadInt()
        step.result = netdata:ReadInt()
    	step.Attname = netdata:ReadUnicodeString();
        step.Defname = netdata:ReadUnicodeString();
      
    	LogInfo("qboy SyndicateBattle step :"..step.battleID.." "..step.attSynID.." "..step.defSynID.." "..step.Attname.." "..step.Defname.." result:"..step.result)
    
        table.insert(stepList,step)
    	
    end
    
    SyndicateBattleResultUI.LoadResultData(ntype,stepList,nTimeLeft,nBattleEndTime);  
    
end


--==玩家信息===--
function  p.ProcessSyndicateBattlePlayerInfo(netdata)
	
	--local nComboKill = netdata:ReadShort();
	local nWin = netdata:ReadInt();
	--local nLost = netdata:ReadShort();
	--local nCDTime = netdata:ReadShort();
	local nEncorageLev = netdata:ReadInt();
	--local nTopComboKill = netdata:ReadShort(); 
	--local nRepute = netdata:ReadShort();
	--local nScore = netdata:ReadShort();
	--local nMoney = netdata:ReadInt();
	--local nGold = netdata:ReadInt();
	SyndicateBattleUI.ProccessResultInfo(nWin,nEncorageLev);
	LogInfo("qboy ProcessSyndicateBattlePlayerInfo nWin:"..nWin.." nEncorageLev:"..nEncorageLev);
	
	
end




RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_STEPS_INFO, "p.ProcessStepsInfo", p.ProcessStepsInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_SIGNUP_INFO, "p.ProcessSignUpInfo", p.ProcessSignUpInfo);
RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_ACTION_RET, "p.ProcessActionRet", p.ProcessActionRet);
RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_CHANGE_CAMP, "p.ProcessChangeCamp", p.ProcessChangeCamp);
RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_CAMP_LIST, "p.ProcessCampList", p.ProcessCampList);
RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_REPORT, "p.ProcessReport", p.ProcessReport);
RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_BATTLE_RESULT, "p.ProcessBattleResult", p.ProcessBattleResult);

RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_BATTLE_OVER, "p.ProcessCompleteBattle", p.ProcessCompleteBattle);
RegisterNetMsgHandler(NMSG_Type._MSG_SYNDICATEBATTLE_PLAYERINFO, "p.ProcessSyndicateBattlePlayerInfo", p.ProcessSyndicateBattlePlayerInfo);




--[[
    _MSG_SYNDICATEBATTLE_ACTION         = _MSG_GENERAL+8100,    --军团战动作
    _MSG_SYNDICATEBATTLE_ACTION_RET     = _MSG_GENERAL+8101,    --军团战动作返回
    _MSG_SYNDICATEBATTLE_SIGNUP_INFO    = _MSG_GENERAL+8102,    --军团战报名信息
    _MSG_SYNDICATEBATTLE_STEPS_INFO     = _MSG_GENERAL+8103,    --各个阶段战况
    _MSG_SYNDICATEBATTLE_BATTLE_RESULT  = _MSG_GENERAL+8104,    --具体对战结果
    _MSG_SYNDICATEBATTLE_CAMP_LIST      = _MSG_GENERAL+8105,    --阵营列表
    _MSG_SYNDICATEBATTLE_CHANGE_CAMP    = _MSG_GENERAL+8106,    --阵营列表改变
    _MSG_SYNDICATEBATTLE_BATTLE_OVER    = _MSG_GENERAL+8107,    --一场对战结束
    _MSG_SYNDICATEBATTLE_REPORT         = _MSG_GENERAL+8108,    --对战战报
--]]

