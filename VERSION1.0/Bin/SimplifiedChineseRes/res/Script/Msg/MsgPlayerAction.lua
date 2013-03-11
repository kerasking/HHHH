
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
    VIP_CHECK_IN = 6,           --VIP簽到
    DAILY_PAY = 7,            --每日充值  
    DAILY_RETURN = 8,            --每日返還 
    ONLINE_RETURN = 9,            --在線返還     
    END = 10,
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
    {type = p.PLAYER_ACTION_TYPE.DAILY_RETURN,  IsExit = 0,},       --每日返還   
    {type = p.PLAYER_ACTION_TYPE.ONLINE_RETURN,  IsExit = 0,},       --在線返還    
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
    LogInfo("tzq p.MsgGetPlayerActionInfo nPreSerId= %d, nCurSerId = %d begin", nPreSerId, nCurSerId);   
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

        local iType = nil;
   
        if RechargeReward.GetIfNeedDown() then
			 for i,v in pairs(RechargeReward.EventConfig) do
				local id1 = v.Id;
				local id2 = p.StrActionInfo.iDb_event_config_id;
				
				if v.Id == p.StrActionInfo.iDb_event_config_id then
					iType = v.Type;
					break;
				end
			 end
			 
			 if iType == nil then
				return;
			 end
		else
			iType = GetDataBaseDataN("event_config", p.StrActionInfo.iDb_event_config_id, DB_EVENT_CONFIG.TYPE);
		end
		 
		 

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
           or  (p.PLAYER_ACTION_STATION[p.PLAYER_ACTION_TYPE.DAILY_PAY].IsExit == 1)  
           or  (p.PLAYER_ACTION_STATION[p.PLAYER_ACTION_TYPE.DAILY_RETURN].IsExit == 1)  
           or  (p.PLAYER_ACTION_STATION[p.PLAYER_ACTION_TYPE.ONLINE_RETURN].IsExit == 1) then
            return true;
        else
            return false;
        end
    end
    
    return false
end


function p.MsgPopDlg()


end



--修改充值活动数据由读取静态表数据修改为服务器下发---------------change 2013-2-16--by tzq

--下发的数据类型   
p.REV_ACTION_TYPE =
{
	ACTION_EVENTLIST_CONFIG_BEGIN = 1,		--活动配置
	ACTION_EVENTLIST_CONFIG = 2,	       --活动配置
	ACTION_EVENTLIST_AWARD_BEGIN = 3,		--活动奖励配置
	ACTION_EVENTLIST_AWARD = 4,				--活动奖励配置
};

--[[  
struct EventList
{
	OBJID idEventConfig;
	char szName[_MAX_NAMESIZE];
	UCHAR ucType;
	UCHAR ucUIGroup;
	UCHAR ucTimeType;
	DWORD dwBeginTime;
	DWORD dwEndTime;
	char szContent[_MAX_WORDSSIZE];
	char szBroadContent[_MAX_WORDSSIZE];
	USHORT usServer;
};
struct EventAward
{
	OBJID idAward;
	OBJID idEventConfig;
	UCHAR ucStage;
	DWORD dwStageCondition;
	OBJID idItemType;
	UCHAR ucAmount;
	DWORD dwEMoney;
	DWORD dwStamina;
	DWORD dwMoney;
	DWORD dwSoph;
	DWORD dwRepute;
	DWORD dwParam1;
	DWORD dwParam2;
	DWORD dwParam3;
};
]]
	
	
function p.MsgGetRechargeRewardInfo(netdatas)
 
    --数据的类型
    local cActionType = netdatas:ReadShort();
    --数据的数量
    local cActionAmount = netdatas:ReadByte();
    
    if cActionType == p.REV_ACTION_TYPE.ACTION_EVENTLIST_CONFIG_BEGIN then
		RechargeReward.EventConfig = {};   
    elseif cActionType == p.REV_ACTION_TYPE.ACTION_EVENTLIST_AWARD_BEGIN then
    	RechargeReward.EventReward = {};  
    end
    
    --处理congfig数据
    if cActionType == p.REV_ACTION_TYPE.ACTION_EVENTLIST_CONFIG_BEGIN or cActionType == p.REV_ACTION_TYPE.ACTION_EVENTLIST_CONFIG then
		for i = 1, cActionAmount do
			local Record = {};	
			Record.Id = netdatas:ReadInt();
			Record.Name = netdatas:ReadUnicodeString();
			Record.Type = netdatas:ReadByte();
			Record.Group = netdatas:ReadByte();
			Record.TimeType = netdatas:ReadByte();  
			Record.BeginTime = netdatas:ReadInt();   
			Record.EndTime = netdatas:ReadInt();
			Record.Content = netdatas:ReadUnicodeString();      
			Record.Broad = netdatas:ReadUnicodeString();   
			Record.Server = netdatas:ReadShort();
			Record.RightListTable = {}; 
			table.insert(RechargeReward.EventConfig, Record);    
		end
		
	--处理reward数据	
	elseif cActionType == p.REV_ACTION_TYPE.ACTION_EVENTLIST_AWARD_BEGIN or cActionType == p.REV_ACTION_TYPE.ACTION_EVENTLIST_AWARD then
		for i = 1, cActionAmount do
			local rightTable = {};  
			rightTable.Id = netdatas:ReadInt();
			rightTable.IdEventConfig = netdatas:ReadInt();
			rightTable.Stage = netdatas:ReadByte();                --阶段
			rightTable.StageCondition  = netdatas:ReadInt();   --阶段条件
			rightTable.ItemType = netdatas:ReadInt();        --奖励物品类型
			rightTable.ItemCount = netdatas:ReadByte();      --物品数
			rightTable.Emoney= netdatas:ReadInt();          --金币
			rightTable.Stamina = netdatas:ReadInt();        --奖励物品类型  --军令
			rightTable.Money = netdatas:ReadInt();          --奖励物品类型  --银币  
			rightTable.Soph = netdatas:ReadInt();           --奖励物品类型                --将魂
			rightTable.Repute = netdatas:ReadInt();          --声望 
			rightTable.Param1 = netdatas:ReadInt();  
			rightTable.Param2 = netdatas:ReadInt();  
			rightTable.Param3 = netdatas:ReadInt(); 
			table.insert(RechargeReward.EventReward, rightTable);   
		end
   end
end

--注册消息获取玩家活动信息
RegisterNetMsgHandler(NMSG_Type._MSG_PLAYER_ACTION_INFO,  "p.MsgGetPlayerActionInfo", p.MsgGetPlayerActionInfo);
--充值数据接收消息
RegisterNetMsgHandler(NMSG_Type._MSG_EVENT_LIST,  "p.MsgGetRechargeRewardInfo", p.MsgGetRechargeRewardInfo);
--change end