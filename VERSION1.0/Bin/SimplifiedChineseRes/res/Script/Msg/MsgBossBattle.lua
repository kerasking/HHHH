---------------------------------------------------
--描述: 网络消息处理(buff)消息处理及其逻辑
--时间: 2012.3.30
--作者: chh
---------------------------------------------------

MsgBossBattle = {}
local p = MsgBossBattle;

p.mUIListener = nil;

--测试，C++发后删除
p.TempMaxLift = 0;
p.TempCurLift = 0;

local ACTION_OPERATE = {
    LOGINSIGN       = 1,        -- 登陆签到
    ONLINE          = 2,        -- 在线领取
    ANSWER          = 3,        -- 签到应答
    RESET           = 4,        -- 重置
    FIRST_RECHARGE  = 5,        -- 首次充值
    ONCE_RECHARGE   = 6,        -- 单次充值
    TOTAL_RECHARGE  = 7,        -- 累计充值
    EVERYDAY_RECHARGE   = 8,    -- 每日充值
    ACTIVITY_QUEST  = 9,        -- 请求活动是否开启
    ACTIVITY_ANSWER = 10,       -- 活动状态响应
};

ACTIVITY_STATUS = {
    NONE        = 0,    --活动未开始
    START       = 1,    --活动已开始
    END         = 2,    --活动结束
};

ACTIVITY_TYPE = {
    BOSS    = 1,    --boss战
    GRAIN   = 2,    --运粮
    CHAOS   = 3,    --大乱斗
};

local BOSS_BATTLE_ACT = {
    ACT_NONE            = 0,        -- 
    REQUEST_BOSSINFO    = 1,        -- 请求下发BOSS战信息
    FIGHT               = 2,        -- 开始战斗
    ACT_REBORN          = 3,        -- 复活
    ACT_REBORN_OK       = 4,        -- 复活成功
    ACT_REBORN_FAIL     = 5,        -- 复活失败
    --[[
    AUTO_OPEN           = 6,        -- 自动战斗开启
    AUTO_CLOSE          = 7,        -- 自动战斗关闭
    ]]
};

-- 打开活动
-- 参数
--    nActivityId:活动ID
-- 返回:无
function p.OpenBossBattle( nActivityId )
    --[[
    --测试Beg
    Battle_Boss.LoadUI( 1 );
    if(true) then
        return;
    end
    --测试End
    ]]
    
    if not CheckN( nActivityId ) then
            LogInfo("MsgBossBattle.OpenBossBattle 参数错误！");
            return false;
    end
    
    LogInfo( "MsgBossBattle.OpenBossBattle[%d]" , nActivityId );
    
    local netdata = createNDTransData(NMSG_Type._MSG_PLAYER_ACTION_OPERATE);
    if nil == netdata then
        LogInfo("发送删除状态消息,内存不够");
        return false;
    end
    netdata:WriteByte( ACTION_OPERATE.ACTIVITY_QUEST );     --Action
    netdata:WriteByte( nActivityId );                       --活动ID
    netdata:WriteByte( 0 );
    SendMsg( netdata );
    netdata:Free();
    ShowLoadBar();
    return true; 
end

p.nTimerId = nil;

--处理活动反馈信息
function p.ProcessActivity( netdata )
    LogInfo( "MsgBossBattle.ProcessActivity" );
    
    local nAction           = netdata:ReadByte();   -- ACTION_OPERATE
    local nActivityId       = netdata:ReadInt();   -- 活动ID
    local nActivityStatus   = netdata:ReadInt();   -- 活动状态
    
    LogInfo( "MsgBossBattle.ProcessActivity nAction:[%d],nActivityId:[%d],nActivityStatus:[%d]", nAction, nActivityId, nActivityStatus );
    
    if nAction == ACTION_OPERATE.ACTIVITY_ANSWER then
        if nActivityStatus == ACTIVITY_STATUS.NONE then
            CommonDlgNew.ShowYesDlg( "活动还未开启" );
        elseif nActivityStatus == ACTIVITY_STATUS.START then
            
            local nType = GetDataBaseDataN("event_activity", nActivityId, DB_EVENT_ACTIVITY_CONFIG.TYPE);
            if ACTIVITY_TYPE.BOSS == nType then
                Battle_Boss.LoadUI( nActivityId );
            elseif ACTIVITY_TYPE.GRAIN == nType then    --运粮
            	
            elseif ACTIVITY_TYPE.CHAOS == nType then    --大乱斗
            	CampBattle.LoadUI();
            end
            
        elseif nActivityStatus == ACTIVITY_STATUS.END then
            if( p.nTimerId ) then
                UnRegisterTimer( p.nTimerId );
                p.nTimerId = nil;
            end
            p.nTimerId = RegisterTimer( p.TimerCloseActivityWin, 1/24 );
        end
    end
    CloseLoadBar();
    return true;
end

function p.TimerCloseActivityWin()
    LogInfo("p.TimerCloseActivityWin");
    local layer = Battle_Boss.GetCurrLayer();
    if( layer ) then
        LogInfo("p.TimerCloseActivityWin layer != nil!");
        if( layer:IsVisibled() ) then
            LogInfo("p.TimerCloseActivityWin layer destory!");
            CommonDlgNew.ShowYesDlg( "活动已结束1" );
            Battle_Boss.UnLoadUI( 0 );
        end
    else
        LogInfo("p.TimerCloseActivityWin layer == nil!");
        if( p.nTimerId ) then
            UnRegisterTimer( p.nTimerId );
            p.nTimerId = nil;
        end
    end
    
end


--Boss战信息
function p.ProcessBossBattleInfo( netdata )
    LogInfo( "MsgBossBattle.ProcessBossBattleInfo" );
    
    local m = {};
    m.nActivityId   = netdata:ReadInt();    --活动ID
    --m.nBossTypeId   = netdata:ReadInt();    --BOSS类型
    m.nCurLife      = netdata:ReadInt();    --BOSS当前血量
    m.nLifeLimit    = netdata:ReadInt();    --BOSS最大血量
    m.nLeftTime     = netdata:ReadInt();    --BOSS战剩余时间（单位：秒）
    m.nCDTime       = netdata:ReadInt();    --剩余冷却时间（单位：秒）
    m.nDamage       = netdata:ReadInt();    --伤害
    m.nUpData       = netdata:ReadByte();    --战力提升值
    --m.nAuto         = netdata:ReadByte();   --自动战斗状态(0:未开启, 1:开启)
    local nAmount   = netdata:ReadByte();   --排名前N玩家数据个数
    
    
    LogInfo( "m.nActivityId:[%d],m.nCurLife:[%d],m.nLifeLimit:[%d],m.nLeftTime:[%d],m.nCDTime:[%d],m.nDamage:[%d],m.nUpData:[%d],nAmount:[%d]",m.nActivityId,m.nCurLife,m.nLifeLimit,m.nLeftTime,m.nCDTime,m.nDamage,m.nUpData,nAmount );
    
    m.RankTable = {};
    for i=1,nAmount do
        local rt = {};
        rt.sName   = netdata:ReadUnicodeString();   --玩家名称
        rt.nRank   = netdata:ReadByte();            --排名
        rt.nDamage = netdata:ReadInt();             --伤害
        
        LogInfo( "rt.sName:[%s],rt.nRank:[%d],rt.nDamage:[%d]",rt.sName,rt.nRank,rt.nDamage );
        
        table.insert( m.RankTable, rt );
    end
    
    if(p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_BOSS_BATTLE_INFO, m );
	end
    CloseLoadBar();
    
    p.TempMaxLift = m.nLifeLimit;
    p.TempCurLift = m.nCurLife;
    
    return true;
end

-- 获得boss信息
function p.GetBossInfo( nBossTypeId )
    p.OperateBossBattle( BOSS_BATTLE_ACT.REQUEST_BOSSINFO, nBossTypeId );
end

-- 开始战斗
function p.StartBattle( nBossTypeId )
    p.OperateBossBattle( BOSS_BATTLE_ACT.FIGHT, nBossTypeId );
    ShowLoadBar();
end

-- 复活
function p.Revive( nBossTypeId )
    p.OperateBossBattle( BOSS_BATTLE_ACT.ACT_REBORN, nBossTypeId );
    ShowLoadBar();
end

--[[
-- 关闭自动战斗
function p.OpenAutoBattle( nBossTypeId )
    p.OperateBossBattle( BOSS_BATTLE_ACT.AUTO_OPEN, nBossTypeId );
    --ShowLoadBar();
end

-- 开始自动战斗
function p.CloseAutoBattle( nBossTypeId )
    p.OperateBossBattle( BOSS_BATTLE_ACT.AUTO_CLOSE, nBossTypeId );
    --ShowLoadBar();
end
]]

--Boss战操作
function p.OperateBossBattle( nAction, nBossTypeId )
    if not CheckN( nAction ) 
        or not CheckN( nBossTypeId ) then
            LogInfo("MsgBossBattle.OperateBossBattle 参数错误！");
            return false;
    end

    LogInfo( "MsgBossBattle.OperateBossBattle nAction:[%d], nBossTypeId:[%d]" , nAction, nBossTypeId );
    
    local netdata = createNDTransData(NMSG_Type._MSG_BOSS_BATTLE);
    if nil == netdata then
        LogInfo("发送删除状态消息,内存不够");
        return false;
    end
    netdata:WriteByte( nAction );     --Action
    netdata:WriteInt( nBossTypeId );
    SendMsg( netdata );
    netdata:Free();
    return true; 
end



RegisterNetMsgHandler(NMSG_Type._MSG_PLAYER_ACTION_OPERATE, "MsgBossBattle.ProcessActivity", p.ProcessActivity);
RegisterNetMsgHandler(NMSG_Type._MSG_BOSS_BATTLE_INFO, "MsgBossBattle.ProcessBossBattleInfo", p.ProcessBossBattleInfo);


