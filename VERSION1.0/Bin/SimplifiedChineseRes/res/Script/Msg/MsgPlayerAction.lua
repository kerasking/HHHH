
---------------------------------------------------
--描述: 玩家活动信息
--时间: 2012.8.31
--作者: tzq
---------------------------------------------------

MsgPlayerAction = {}
local p = MsgPlayerAction;

--玩家活动类型
p.PLAYER_ACTION_TYPE =
{
    BEGIN = 0,
    CHECK_IN = 1,             --登入签到
    ON_LINE = 2,                --在线签到
    FIRST_PAY = 3,             --首次充值
    ONCE_PAY = 4,             --单次充值  
    TOTAL_PAY = 5,           --累计充值
    DAILY_PAY = 7,            --每日充值  
    END = 8,
};

p.RechargeRewardActionType = 6;


--玩家活动状态(是否存在)
p.PLAYER_ACTION_STATION =
{
    {type = p.PLAYER_ACTION_TYPE.CHECK_IN,  IsExit = 0,},       --登入签到
    {type = p.PLAYER_ACTION_TYPE.ON_LINE,  IsExit = 0,},          --在线签到
    {type = p.PLAYER_ACTION_TYPE.FIRST_PAY,  IsExit = 0,},       --首次充值
    {type = p.PLAYER_ACTION_TYPE.ONCE_PAY,  IsExit = 0,},       --单次充值   
    {type = p.PLAYER_ACTION_TYPE.TOTAL_PAY,  IsExit = 0,},       --累计充值
    {type = p.PLAYER_ACTION_TYPE.VIP_PAY,  IsExit = 1,},       --vip充值  
    {type = p.PLAYER_ACTION_TYPE.DAILY_PAY,  IsExit = 0,},       --每日充值
};


--下发的数据类型   
p.EVENT_ACTION_TYPE =
{
    ACTION_INFO = 1;   --用户活动信息
    ACTION_DEL  = 2;   --要删除的活动信息
};


--玩家活动信息结构
p.StrActionInfo = { 
                                iDb_event_config_id = nil,        -- 数据库表event_config的id
                                iData1 = nil;                                --按字节处理
                                iData2 = nil;                                --按字节处理
                                iData3 = nil;                                --按字节处理
                                iBeginTime = nil;                        --距离1900年1月1日0点0分多少秒
     };

function p.ClearActionInfo()
    for i, v in pairs(p.PLAYER_ACTION_STATION) do
        v.IsExit = 0;   
    end 
end

--获取玩家活动信息接口(服务器下发)     
function p.MsgGetPlayerActionInfo(netdatas)
    
    local nPreSerId, nCurSerId = Login_ServerUI.GetPreCurSerId();
    LogInfo("p.MsgGetPlayerActionInfo nPreSerId= %d, nCurSerId = %d begin", nPreSerId, nCurSerId);   
    if nPreSerId ~= nCurSerId then
        for i, v in pairs(p.PLAYER_ACTION_STATION) do
            v.IsExit = 0;   
        end 
        Login_ServerUI.SetPreCurSerId(nCurSerId, nCurSerId);
    end
    
    --活动的类型(例如 玩家活动信息 ,目前只有一种)
    local cActionType = netdatas:ReadByte();
    --活动的数量
    local cActionAmount = netdatas:ReadByte();
    LogInfo("p.MsgGetPlayerActionInfo cActionType = %d, cActionAmount = %d", cActionType, cActionAmount);    
    
    for i, v in pairs(p.PLAYER_ACTION_STATION) do
        LogInfo("action station = %d, before msg", v.IsExit);   
    end 
    
    for i = 1, cActionAmount do
        p.StrActionInfo = {};
        p.StrActionInfo.iDb_event_config_id = netdatas:ReadInt();
        p.StrActionInfo.iData1 = netdatas:ReadInt();            
        p.StrActionInfo.iData2 = netdatas:ReadInt(); 
        p.StrActionInfo.iData3 = netdatas:ReadInt();  
        p.StrActionInfo.iBeginTime = netdatas:ReadInt();      
        LogInfo("i = %d, idevent = %d, iData1 = %d, iData2 = %d, iData3 = %d, iBeginTime = %d", i, p.StrActionInfo.iDb_event_config_id, 
                        p.StrActionInfo.iData1, p.StrActionInfo.iData2, p.StrActionInfo.iData3, p.StrActionInfo.iBeginTime);

        local iType = GetDataBaseDataN("event_config", p.StrActionInfo.iDb_event_config_id, DB_EVENT_CONFIG.TYPE);
        if cActionType == p.EVENT_ACTION_TYPE.ACTION_INFO then   --要启用的活动
            if (p.PLAYER_ACTION_TYPE.CHECK_IN == iType) then   --登入签到
                DailyCheckInUI.SetUiInfo(p.StrActionInfo.iData1, p.StrActionInfo.iData2, p.StrActionInfo.iData3);
            elseif (p.PLAYER_ACTION_TYPE.ON_LINE == iType) then   --在线奖励
                OnlineCheckIn.ProccessNetMsg(p.StrActionInfo.iData1, p.StrActionInfo.iData2,p.StrActionInfo.iData3)
            elseif (p.PLAYER_ACTION_TYPE.FIRST_PAY == iType) then  --首次充值
                    RechargeReward.SetFirstRechargeInfo(p.StrActionInfo.iData1, p.StrActionInfo.iData2, p.StrActionInfo.iBeginTime);  
            elseif (p.PLAYER_ACTION_TYPE.ONCE_PAY == iType) then  --单次充值
                    RechargeReward.SetOnceRechargeInfo(p.StrActionInfo.iData2, p.StrActionInfo.iBeginTime);   
            elseif (p.PLAYER_ACTION_TYPE.TOTAL_PAY == iType) then  --累计充值
                    RechargeReward.SetTotalRechargeInfo(p.StrActionInfo.iData2, p.StrActionInfo.iBeginTime); 
            elseif (p.PLAYER_ACTION_TYPE.DAILY_PAY == iType) then  --每日充值
                    RechargeReward.SetDailyRechargeInfo(p.StrActionInfo.iData2, p.StrActionInfo.iBeginTime); 
           end
        end
        
        --更新用户是否存在这张表
        if iType > p.PLAYER_ACTION_TYPE.BEGIN  and iType < p.PLAYER_ACTION_TYPE.END then
            LogInfo("receive msg type = %d, action = %d", iType, cActionType);   
            if cActionType == p.EVENT_ACTION_TYPE.ACTION_INFO then  --下发活动信息
                p.PLAYER_ACTION_STATION[iType].IsExit = 1;
            else
                p.PLAYER_ACTION_STATION[iType].IsExit = 0;     --下发删除活动信息
            end
        end
    end
    
    for i, v in pairs(p.PLAYER_ACTION_STATION) do
        LogInfo("action station = %d, after msg", v.IsExit);   
    end 
    
    MainUI.RefreshFuncIsOpen();
    
    LogInfo("p.MsgGetPlayerActionInfo  end");    
end

function p.IsActionOpen(iType)
    LogInfo("function.IsActionOpen iType = %d", iType);   
    --登入签到是否显示判断
    if iType == p.PLAYER_ACTION_TYPE.CHECK_IN then
        if p.PLAYER_ACTION_STATION[iType].IsExit == 0 then
            LogInfo("11");   
            return false;
        else
            LogInfo("22");   
            return true;
        end
        
    elseif iType == p.PLAYER_ACTION_TYPE.ON_LINE then
        if p.PLAYER_ACTION_STATION[iType].IsExit == 0 then
            return false;
        else
            return true;
        end        

    elseif  iType == p.RechargeRewardActionType then
        if (p.PLAYER_ACTION_STATION[p.PLAYER_ACTION_TYPE.FIRST_PAY].IsExit == 1) 
           or  (p.PLAYER_ACTION_STATION[p.PLAYER_ACTION_TYPE.ONCE_PAY].IsExit == 1) 
           or  (p.PLAYER_ACTION_STATION[p.PLAYER_ACTION_TYPE.TOTAL_PAY].IsExit == 1)  
           or  (p.PLAYER_ACTION_STATION[p.PLAYER_ACTION_TYPE.DAILY_PAY].IsExit == 1)  then
            LogInfo("33");   
            return true;
        else
            LogInfo("44");   
            return false;
        end
    end
    
    LogInfo("55");   
    return false
end


function p.MsgPopDlg()


end


--注册消息获取玩家活动信息
RegisterNetMsgHandler(NMSG_Type._MSG_PLAYER_ACTION_INFO,  "p.MsgGetPlayerActionInfo", p.MsgGetPlayerActionInfo);

--注册收到系统消息弹出处理
--RegisterNetMsgHandler(NMSG_Type._MSG_TALK, "p.MsgPopDlg", p.MsgPopDlg);
