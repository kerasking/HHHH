---------------------------------------------------
--描述: 运送粮草相关消息
--时间: 2012.9.17
--作者: tzq
---------------------------------------------------

MsgTransport = {}
local p = MsgTransport;

--玩家活动类型
p.TransportActionType =
{
    BEGIN = 0,
    ENTER = 1,                --进入运送粮草页面
    LEAVE = 2,                 --离开运送粮草页面
    LOOT   = 3,                 --拦截粮草
    REMOVE_LOOT_TIME = 4, --清除拦截冷却时间
    QUICK_ARRIVE = 5, --快速到达
    TRNSPORT = 6,       --开始运粮
    REFRESH_CAR = 7,       --刷新粮车  
    CALL_CAR = 8,       --召唤最高级粮车   
    GW      = 9,
    TRANSPORT_COUNT = 10,   --运粮次数和拦截次数
    END = 11,
}; 

p.PlayerInfo = "显示玩家信息";

--transport 玩家列表数据结构
p.tbInfo =
{
    bStatus = 0,                       --玩家是否存在   0不存在 1:存在
    nPlayerId = 0,                     --玩家的id
    strPlayerName = "",           --玩家的名字
    nBeginTime = 0,                --开始运送的时间
    nGrain_config_id = 0,          --对应静态数据表grain_config 的id(运粮信息)
    nSucBeenLootedNum = 0,  --成功被拦截次数
    nLootOtherNum = 0,           --拦截别人的次数
    nPersentMorale = 0,           --当前加成的士气
};


--服务器每次下发的信息集合
p.UpdataInfoList = {};


--发送给服务端的消息结构
p.MsgSendTransportInfo = {actionType = p.TransportActionType.BEGIN,};


--运送粮草(服务器下发)      每次只是下发需要的信息，比如玩家列表只是每次更新的信息  不包括主角
function p.MsgReciveTransportInfo(netdatas)
    
    LogInfo("recmsg begin");    
    local tbInfoList = {};
    local nPlayerId = GetPlayerId();  

    local actionType = netdatas:ReadByte();  --1:add  2:update   1的话为清空后更新  2为更新
    LogInfo("recmsg actionType = %d", actionType); 
        
    --先清空旧的数据表结构
    if actionType == 1 then
        Transport.tbPlayerInfo = {};
        Transport.tbOtherUserInfo = {};
        
        if IsUIShow(NMAINSCENECHILDTAG.TransportUI) then --运粮页面
            Transport.SetButtonInit();
        end
    end
    
    local nInfoCount = netdatas:ReadInt();  --获取的数据条数
    LogInfo("recmsg nInfoCount = %d", nInfoCount); 
    
    --获取所有要更新的信息
    for i = 1, nInfoCount do
        p.tbInfo = {};
        
        p.tbInfo.nPlayerId = netdatas:ReadInt();                      --玩家id
        p.tbInfo.nCanLootCdTime = netdatas:ReadInt();        --下一次可拦截倒计时
        p.tbInfo.nCarArriveCdTime = netdatas:ReadInt();      --粮车到达倒计时
        p.tbInfo.nRefreshCarTime = netdatas:ReadInt();      --刷新粮车次数
        p.tbInfo.nLooterId1 = netdatas:ReadInt();      --拦截该粮车的人物id1    
        p.tbInfo.nLooterId2 = netdatas:ReadInt();      --拦截该粮车的人物id2           
        p.tbInfo.bStatus = netdatas:ReadByte();                     --是否在运粮 1是 其他不是
        p.tbInfo.nGrain_config_id = netdatas:ReadByte();    --对应 Grain_config表id
        p.tbInfo.nSucBeenLootedNum = netdatas:ReadByte();  --被成功拦截次数
        p.tbInfo.nLootOtherNum = netdatas:ReadByte();            --拦截别人次数
        p.tbInfo.nPersentMorale = netdatas:ReadByte();             --当前已提升的士气    
        p.tbInfo.nHasTransNum = netdatas:ReadByte();             --已经运送了多少次
        p.tbInfo.Level = netdatas:ReadByte();                              --玩家等级          
        p.tbInfo.param2 = netdatas:ReadByte();   
        p.tbInfo.strArmyGroup = netdatas:ReadUnicodeString();    --军团名称
        p.tbInfo.strPlayerName = netdatas:ReadUnicodeString();    --玩家的名字
        
        if p.tbInfo.strArmyGroup == "null" then
			p.tbInfo.strArmyGroup = GetTxtPri("TL_T8")
        end
        
        if p.tbInfo.nPlayerId == nPlayerId then
            Transport.tbPlayerInfo = p.tbInfo;
        end
        table.insert(tbInfoList, p.tbInfo);
    end
   
     LogInfo("OtherNum = %d", table.getn(tbInfoList));     
     

    --打印处log 以后可删除
    for i, v in pairs(tbInfoList) do 
            LogInfo("i = %d, nPlayerId = %d, Name = %s, LootTime = %d, CarTime = %d, nRefreshCarTime = %d, bStatus = %d, fig_id = %d, LootedNum = %d, Morale = %d, TransNum = %d, nLooterId1 = %d, nLooterId2 = %d", 
                        i, v.nPlayerId, v.strPlayerName, v.nCanLootCdTime, v.nCarArriveCdTime, v.nRefreshCarTime, v.bStatus, v.nGrain_config_id, v.nLootOtherNum, v.nPersentMorale, v.nHasTransNum, v.nLooterId1, v.nLooterId2);          
   end

    local v = Transport.tbPlayerInfo;
    LogInfo("user nPlayerId = %d, Name = %s, LootTime = %d, CarTime = %d, bStatus = %d, fig_id = %d, LootedNum = %d, Morale = %d, TransNum = %d", v.nPlayerId, v.strPlayerName, v.nCanLootCdTime, v.nCarArriveCdTime, v.bStatus, v.nGrain_config_id, v.nLootOtherNum, v.nPersentMorale, v.nHasTransNum); 
 
    Transport.SetTransportInfo(tbInfoList);
    
    --未打开运粮界面的话,打开
    if not IsUIShow(NMAINSCENECHILDTAG.TransportUI)  and actionType == 1 then
        CloseLoadBar();
		Transport.LoadUI();	
	end
    
    LogInfo("p.MsgGetPlayerActionInfo  end");    
end

function p.MsgRecivePLayerInfo(netdatas)

    p.PlayerInfo = "";
    p.PlayerInfo = netdatas:ReadUnicodeString();  
        LogInfo("rec  p.PlayerInfo = %s", p.PlayerInfo);    
    if IsUIShow(NMAINSCENECHILDTAG.TransportUI) and not IsUIShow(NMAINSCENECHILDTAG.TransportPrepareUI) then
        Transport.SetPlayerInfo(p.PlayerInfo);
    end
end

--发送运送粮草相关消息给服务端
function p.MsgSendTransportInfo(actionType)  
    LogInfo("transport sendMsg begin   actionType = %d", actionType);    
	local netdata = createNDTransData(NMSG_Type._MSG_SEND_TRANSPORT);
    netdata:WriteByte(actionType);
	SendMsg(netdata);	
	netdata:Free();	
    LogInfo("transport sendMsg end");    
	return true;	
end

function p.MsgSendLootInfo(actionType, LootPlayerId)  
    LogInfo("transport sendMsg begin   actionType = %d, LootPlayerId = %d", actionType, LootPlayerId);    
	local netdata = createNDTransData(NMSG_Type._MSG_SEND_TRANSPORT);
    netdata:WriteByte(actionType);
    netdata:WriteInt(LootPlayerId);   
	SendMsg(netdata);	
	netdata:Free();	
    LogInfo("transport sendMsg end");    
	return true;	
end

p.TransportCount = {YLCount = 0, RJCount = 0,}
function p.GetTransportCount()
    return p.TransportCount;
end
--** chh 2012-1-5 **--
function p.MsgReciveTransportCount(netdatas)
    local nActionType = netdatas:ReadByte();    --操作
    if(nActionType == p.TransportActionType.TRANSPORT_COUNT) then
        p.TransportCount.YLCount  = netdatas:ReadInt();       --运粮次数
        p.TransportCount.RJCount  = netdatas:ReadInt();       --拦截次数
        LogInfo("p.TransportCount.YLCount:[%d],p.TransportCount.RJCount:[%d]",p.TransportCount.YLCount,p.TransportCount.RJCount);
    end
end
RegisterNetMsgHandler(NMSG_Type._MSG_SEND_TRANSPORT,  "p.MsgReciveTransportCount", p.MsgReciveTransportCount);


--注册消息获取玩家活动信息
RegisterNetMsgHandler(NMSG_Type._MSG_RECIVE_TRANSPORT,  "p.MsgReciveTransportInfo", p.MsgReciveTransportInfo);

--注册信息接收消息
RegisterNetMsgHandler(NMSG_Type._MSG_RECV_INFO,  "p.MsgRecivePLayerInfo", p.MsgRecivePLayerInfo);
