---------------------------------------------------
--描述: 古迹寻宝相关消息响应及发送
--时间: 2012.12.24
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgTreasureHunt = {}
local p = MsgTreasureHunt;


---------------------------------------------------
--TreasureHuntMesageAction
local LBMA_GetHuntedAmount			= 1;	-- 已寻宝次数
local LBMA_TreasureHunt				= 2;	-- 寻宝



---------------------------------------------------

---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
-- 发送已寻宝次数请求
function p.SendMsgGetHuntedAmount()
	LogInfo( "MsgTreasureHunt: SendMsgGetHuntedAmount" );
	local netdata = createNDTransData(NMSG_Type._MSG_TREASUREHUNT);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( LBMA_GetHuntedAmount );
	netdata:WriteInt( 0 );--map
	netdata:WriteInt( 0 );--count
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理获取免费抽奖次数消息
function p.HandleMsgGetHuntedAmount( tNetDataPackete )
	--LogInfo( "MsgTreasureHunt: HandleMsgGetFreeCardAmount" );
	local nMapID		= tNetDataPackete:ReadInt();--
	local nHuntedAmount = tNetDataPackete:ReadInt();
	LogInfo( "MsgTreasureHunt: HandleMsgGetHuntedAmount:%d",nHuntedAmount );
	TreasureHunt.CallBack_GetHuntedAmount( nHuntedAmount );
end

---------------------------------------------------
-- 发送获寻宝请求
function p.SendMsgTreasureHunt( nRelicID )
	LogInfo( "MsgTreasureHunt: SendMsgTreasureHunt:%d",nRelicID );
	local netdata = createNDTransData(NMSG_Type._MSG_TREASUREHUNT);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( LBMA_TreasureHunt );
	netdata:WriteInt( nRelicID );
	netdata:WriteInt( 0 );--
	SendMsg( netdata );
	netdata:Free();
	ShowLoadBar();--
end

---------------------------------------------------
-- 寻宝
function p.HandleMsgTreasureHunt( tNetDataPackete )
	--LogInfo( "MsgTreasureHunt: HandleMsgTreasureHunt" );
	local nMapID		= tNetDataPackete:ReadInt();--
	local nHuntedAmount = tNetDataPackete:ReadInt();--
	LogInfo( "MsgTreasureHunt: HandleMsgTreasureHunt:%d",nHuntedAmount );
	if IsUIShow( NMAINSCENECHILDTAG.TreasureHunt ) then
		TreasureHunt.RefreshTreasureHuntAmount( nHuntedAmount );
	end
	CloseLoadBar();--
end

---------------------------------------------------
-- 寻宝消息分发处理
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgTreasureHunt: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgTreasureHunt: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == LBMA_GetHuntedAmount ) then
		p.HandleMsgGetHuntedAmount( tNetDataPackete );
	elseif ( nActionID == LBMA_TreasureHunt ) then
		p.HandleMsgTreasureHunt( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_TREASUREHUNT, "MsgTreasureHunt.HandleNetMessage", p.HandleNetMessage );




---------------------------------------------------
---------------------------------------------------
-- 发送答案
function p.SendMsgAnswer( nAnswer )
	LogInfo( "MsgTreasureHunt: SendMsgAnswer:%d",nAnswer );
	local netdata = createNDTransData(NMSG_Type._MSG_QUESTION_INFO);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( nAnswer );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 问答消息处理
function p.HandleNetMessageQuestion( tNetDataPackete )
	LogInfo( "MsgTreasureHunt: HandleNetMessageQuestion" );
	local szQ		= tNetDataPackete:ReadUnicodeString();
	local szA1		= tNetDataPackete:ReadUnicodeString();
	local szA2		= tNetDataPackete:ReadUnicodeString();
	local szA3		= tNetDataPackete:ReadUnicodeString();
	local szA4		= tNetDataPackete:ReadUnicodeString();
	if IsUIShow( NMAINSCENECHILDTAG.TreasureHunt ) then
		TreasureHunt.CallBack_ShowQuestionPanel( szQ, szA1, szA2, szA3 );
	end
end

---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_QUESTION_INFO, "MsgTreasureHunt.HandleNetMessageQuestion", p.HandleNetMessageQuestion );


---------------------------------------------------
---------------------------------------------------
local PrizeType = {
	PT_NONE			= 0,	--  无，
	PT_NB			= 1,	-- 普通怪物战斗
	PT_EB			= 2,	-- 精英怪物战斗
	PT_SB			= 3,	-- 小宝箱
	PT_MB			= 4,	-- 大宝箱
	PT_GB			= 5,	-- 超级宝箱
	PT_QB			= 6,	-- 问答
};

---------------------------------------------------
p.tPrize	= nil;	--
-- 战斗奖励消息处理
function p.HandleNetMessagePrize( tNetDataPackete )
	LogInfo( "MsgTreasureHunt: HandleNetMessagePrize" );
	local nType			= tNetDataPackete:ReadInt();	-- PrizeType
	LogInfo( "MsgTreasureHunt: HandleNetMessagePrize nType:%d",nType );
	local nMoney		= tNetDataPackete:ReadInt();
	local nEMoney		= tNetDataPackete:ReadInt();
	local nRepute		= tNetDataPackete:ReadInt();
	local nStamina		= tNetDataPackete:ReadInt();
	local nSoph			= tNetDataPackete:ReadInt();
	local nExp			= tNetDataPackete:ReadInt();
	local nItemTypeNum	= tNetDataPackete:ReadInt();
	local tPrize	= {};
	tPrize[1]		= nMoney;
	tPrize[2]		= nEMoney;
	tPrize[3]		= nRepute;
	tPrize[4]		= nStamina;
	tPrize[5]		= nSoph;
	tPrize[6]		= nExp;
	tPrize[7]		= {};
	for i=1, nItemTypeNum do
		local nItemType		= tNetDataPackete:ReadInt();
		local nItemCount	= tNetDataPackete:ReadInt();
		tPrize[7][i] = {};
		tPrize[7][i][1] = nItemType;
		tPrize[7][i][2] = nItemCount;
	end
	p.tPrize = tPrize;
	if ( nType == PrizeType.PT_SB ) then
    	local szPrize = p.GetPrizeString();
    	szPrize = GetTxtPri("MTH_T1")  .. "\n" .. szPrize;
		CommonDlgNew.ShowYesDlg(szPrize,nil,nil,nil);
	elseif ( nType == PrizeType.PT_MB ) then
    	local szPrize = p.GetPrizeString();
    	szPrize = GetTxtPri("MTH_T2")  .. "\n" .. szPrize;
		CommonDlgNew.ShowYesDlg(szPrize,nil,nil,nil);
	elseif ( nType == PrizeType.PT_GB ) then
    	local szPrize = p.GetPrizeString();
    	szPrize = GetTxtPri("MTH_T3")  .. "\n" .. szPrize;
		CommonDlgNew.ShowYesDlg(szPrize,nil,nil,nil);
	elseif ( nType == PrizeType.PT_QB ) or ( nType == PrizeType.PT_NONE ) then
    	local szPrize = p.GetPrizeString();
		CommonDlgNew.ShowYesDlg(szPrize,nil,nil,nil);
	end
end

function p.ShowPrize()
    if ( p.tPrize == nil ) then
    	return;
    end
    
    local infos = {};
    if(p.tPrize[1]>0) then
        table.insert(infos,{string.format(GetTxtPub("coin").." +%d",p.tPrize[1]),FontColor.Silver});
    end
    if(p.tPrize[2]>0) then
        table.insert(infos,{string.format(GetTxtPub("shoe").." +%d",p.tPrize[2]),FontColor.Coin});
    end
    if(p.tPrize[3]>0) then
        table.insert(infos,{string.format(GetTxtPub("ShenWan").." +%d",p.tPrize[3]),FontColor.Reput});
    end
    if(p.tPrize[4]>0) then
        table.insert(infos,{string.format(GetTxtPub("Stamina").." +%d",p.tPrize[4]),FontColor.Stamina});
    end
    if(p.tPrize[5]>0) then
        table.insert(infos,{string.format(GetTxtPub("JianHun").." +%d",p.tPrize[5]),FontColor.Soul});
    end
    if(p.tPrize[6]>0) then
        table.insert(infos,{string.format(GetTxtPub("exp").." +%d",p.tPrize[6]),FontColor.Exp});
    end
    
    local nItemCount = table.getn( p.tPrize[7] );
    
    for i=1,nItemCount do
        local nItemType	=  p.tPrize[7][i][1];
        local nNum		=  p.tPrize[7][i][2];
        if(nNum>0) then
            table.insert(infos,{string.format(ItemFunc.GetName(nItemType).." x%d",nNum),ItemFunc.GetItemColor(nItemType)});
        end
    end
    p.tPrize = nil;
    
    CommonDlgNew.ShowTipsDlg(infos);
end

---------------------------------------------------
-- 填充列表
function p.FillPrizeInList( pScrollViewContainer )
	
end

---------------------------------------------------
-- 奖励内容文本
function p.GetPrizeString()
    if ( p.tPrize == nil ) then
    	return "";
    end
    local szResult = "";
    
    if(p.tPrize[1]>0) then
    	szResult = szResult .. string.format(GetTxtPub("coin").."+%d, ",p.tPrize[1]);
    end
    if(p.tPrize[5]>0) then
    	szResult = szResult .. string.format(GetTxtPub("JianHun").."+%d, ",p.tPrize[5]);
    end
    if(p.tPrize[3]>0) then
    	szResult = szResult .. string.format(GetTxtPub("ShenWan").."+%d, \n",p.tPrize[3]);
    end
    if(p.tPrize[2]>0) then
    	szResult = szResult .. string.format(GetTxtPub("shoe").."+%d, ",p.tPrize[2]);
    end
    if(p.tPrize[4]>0) then
    	szResult = szResult .. string.format(GetTxtPub("Stamina").."+%d, ",p.tPrize[4]);
    end
    if(p.tPrize[6]>0) then
    	szResult = szResult .. string.format(GetTxtPub("exp").."+%d, ",p.tPrize[6]);
    end
    
    local nItemCount = table.getn( p.tPrize[7] );
    
    for i=1,nItemCount do
        local nItemType	=  p.tPrize[7][i][1];
        local nNum		=  p.tPrize[7][i][2];
        if(nNum>0) then
            szResult = szResult ..string.format(ItemFunc.GetName(nItemType).."+%d, ",nNum);
        end
    end
    p.tPrize = nil;
    return szResult;
end

---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_PRIZE_INFO, "MsgTreasureHunt.HandleNetMessagePrize", p.HandleNetMessagePrize );