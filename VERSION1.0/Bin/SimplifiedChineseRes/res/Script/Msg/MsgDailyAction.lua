---------------------------------------------------
--描述: 每日活动相关消息
--时间: 2012.10.8
--作者: tzq
---------------------------------------------------

MsgDailyAction = {}
local p = MsgDailyAction;


p.tbActionListInfo = {};

--活动列表(服务器下发)     
function p.MsgReciveDailyAcionInfo(netdatas)
    
    LogInfo("actionlist recmsg begin");    

    local actionType = netdatas:ReadByte();  --1:add  2:update   1的话为清空后更新  2为更新
    local nAmount = netdatas:ReadByte();  --活动数量 
    
    if actionType == 1 then
        DailyAction.WorldActions = {};    --世界活动信息
        DailyAction.ClassActions = {};     --帮派活动信息  
    end
    
    for i, v in pairs(DailyAction.WorldActions) do
        LogInfo("begin i = %d  nId = %d, bStatus = %d", i, v.nId, v.bStatus); 
    end
    
    for i, v in pairs(DailyAction.ClassActions) do
        LogInfo("begin i = %d  nId = %d, bStatus = %d", i, v.nId, v.bStatus); 
    end
    
    LogInfo("recmsg actionType = %d, nAmount = %d", actionType, nAmount); 
    
    --获取所有要更新的信息
    for i = 1, nAmount do
        local record = {};
        local tbInfos = {};
        
        record.nId = netdatas:ReadInt();                      --玩家id
        record.bStatus = netdatas:ReadByte();          --状态 0:开启  3:结束
        
        local nGroup = GetDataBaseDataN("event_activity", record.nId, DB_EVENT_ACTIVITY.GROUP);    
        
        if nGroup == 1 then
            tbInfos = DailyAction.WorldActions;
        elseif  nGroup == 2 then
            tbInfos = DailyAction.ClassActions;
        end
        
        if actionType == 1 then
            table.insert(tbInfos, record);
        else
            local bHasFind = false;
            for j, v in pairs(tbInfos) do
                if record.nId == v.nId then
                    tbInfos[j] = record;
                    bHasFind = true;
                    break;
                end
            end
            
            if not bHasFind then
                table.insert(tbInfos, record);
            end
        end
        
        LogInfo("i = %d recmsg nId = %d, bStatus = %d, nGroup = %d", i, record.nId, record.bStatus, nGroup); 
    end
    
    for i, v in pairs(DailyAction.WorldActions) do
        LogInfo("end i = %d  nId = %d, bStatus = %d", i, v.nId, v.bStatus); 
    end
    
    for i, v in pairs(DailyAction.ClassActions) do
        LogInfo("end i = %d  nId = %d, bStatus = %d", i, v.nId, v.bStatus); 
    end
    
    table.sort(DailyAction.WorldActions, function(a,b) return a.nId < b.nId   end);
    table.sort(DailyAction.ClassActions, function(a,b) return a.nId < b.nId   end);    

    if IsUIShow(NMAINSCENECHILDTAG.DailyActionUI) then
        --刷新活动页面
        LogInfo("refresh BtnId = %d", DailyAction.CurFocusBtnId); 
        DailyAction.RefreshUI(DailyAction.CurFocusBtnId);
    end

    LogInfo("p.MsgGetPlayerActionInfo  end");    
end


--注册消息获取玩家活动信息
RegisterNetMsgHandler(NMSG_Type._MSG_PLAYER_ACTION_LIST,  "p.MsgReciveDailyAcionInfo", p.MsgReciveDailyAcionInfo);
