---------------------------------------------------
--描述: 名人堂消息处理
--时间: 2013.1.9
--作者: CHH
---------------------------------------------------

MsgRankList = {}
local p = MsgRankList;

local PACKAGE_CONTINUE  = 0;
local PACKAGE_BEGIN     = 1;
local PACKAGE_END       = 2;
local PACKAGE_SINGLE    = 3;

p.mUIListener = nil;

p.RankLists = {};


p.RANKING_ACT = {
    ACT_NONE        = 0,
    ACT_PET_LEVEL   = 1,    --等级排名
    ACT_MOUNT_LEVEL = 2,    --坐骑排名
    ACT_SOPH        = 3,    --将魂排名
    ACT_STAGE       = 4,    --进度排名
    ACT_REPUTE      = 5,    --声望排名
    ACT_MONEY       = 6,    --银币排名
    ACT_EMONEY      = 7,    --金币排名
    ACT_ELITE_STAGE = 8,    --精英副本
    ACT_REFRESHTIME = 9,    --剩余刷新时间
}
p.Action = p.RANKING_ACT.ACT_NONE;

function p.SendGetListInfoMsg( nRankingAct )
    LogInfo("p.SendGetListInfoMsg nRankingAct:[%d]",nRankingAct);
    ShowLoadBar();
    local netdata = createNDTransData(NMSG_Type._MSG_RANKING);
    if nil == netdata then
        return false;
    end
    netdata:WriteByte(nRankingAct);
    SendMsg(netdata);
    netdata:Free();
    return true;
end

function p.ProcessGetListInfo(netdata) 
    LogInfo("p.ProcessGetListInfo");
    local nAction = netdata:ReadByte();
    
    if(nAction == p.RANKING_ACT.ACT_REFRESHTIME) then
        local nTime = netdata:ReadInt();
        LogInfo("p.ProcessGetListInfo ACT_REFRESHTIME:[%d]",nTime);
        RankListUI.RefreshTime(nTime);
        return;
    end
    
    
    local nPackageType = netdata:ReadByte();
    local nRecordCount = netdata:ReadShort();
    LogInfo("nAction:[%d],nPackageType:[%d],nRecordCount:[%d]",nAction,nPackageType,nRecordCount);
    p.Action = nAction;
    
    if nPackageType == PACKAGE_BEGIN or nPackageType == PACKAGE_SINGLE then
        LogInfo("p.RankLists clear");
        p.RankLists = {};
    end
    local nt = #p.RankLists;
    for i=1,nRecordCount do
        local pRank = {};
        
        pRank.nRank = nt + i;
        pRank.nNum = netdata:ReadInt();
        
        LogInfo("pRank.nRank:[%d],pRank.nNum:[%d]",pRank.nRank,pRank.nNum);
        if(p.RANKING_ACT.ACT_SOPH == nAction) then
            if(pRank.nNum == 0) then
                pRank.nNum = 1;
            end
            pRank.nStar = netdata:ReadInt();
            pRank.nSoph = netdata:ReadInt();
            
            LogInfo("pRank.nStar:[%d],pRank.nSoph:[%d]",pRank.nStar,pRank.nSoph);
        end
        
        pRank.sName = netdata:ReadUnicodeString();
        
        LogInfo("pRank.sName:[%s]",pRank.sName);
        
        table.insert(p.RankLists, pRank);
    end
    
    if nPackageType == PACKAGE_END or nPackageType == PACKAGE_SINGLE then
        if(p.mUIListener) then
            p.mUIListener(NMSG_Type._MSG_RANKING,p.RankLists);
        end
    end
    
    CloseLoadBar();
end


RegisterNetMsgHandler(NMSG_Type._MSG_RANKING, "p.ProcessGetListInfo", p.ProcessGetListInfo);
