---------------------------------------------------
--描述: 幸运宝箱相关消息响应及发送
--时间: 2012.12.11
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgLuckyBox = {}
local p = MsgLuckyBox;

---------------------------------------------------


---------------------------------------------------
--LuckyBoxMesageAction
local LBMA_GetFreeLotteryAmount	= 1;	-- 免费抽奖次数
local LBMA_Lottery				= 2;	-- 抽奖



---------------------------------------------------

---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
-- 发送获取免费抽奖次数请求
function p.SendMsgGetFreeLotteryAmount()
	LogInfo( "MsgLuckyBox: SendMsgGetFreeLotteryAmount" );
	local netdata = createNDTransData(NMSG_Type._MSG_LUCKYBOX);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( LBMA_GetFreeLotteryAmount );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理获取免费抽奖次数消息
function p.HandleMsgGetFreeLotteryAmount( tNetDataPackete )
	--LogInfo( "MsgLuckyBox: HandleMsgGetFreeCardAmount" );
	local nFreeLotteryAmount = tNetDataPackete:ReadInt();
	LogInfo( "MsgLuckyBox: HandleMsgGetFreeCardAmount:%d",nFreeLotteryAmount );
	LuckyBox.CallBack_GetFreeLotteryAmount( nFreeLotteryAmount );
end

---------------------------------------------------
-- 发送获抽奖请求
function p.SendMsgLottery()
	LogInfo( "MsgLuckyBox: SendMsgLottery" );
	local netdata = createNDTransData(NMSG_Type._MSG_LUCKYBOX);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( LBMA_Lottery );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 抽奖
function p.HandleMsgLottery( tNetDataPackete )
	--LogInfo( "MsgLuckyBox: HandleMsgLottery" );
	local nFreeLotteryAmount = tNetDataPackete:ReadInt();
	LogInfo( "MsgLuckyBox: HandleMsgLottery:%d",nFreeLotteryAmount );
	if IsUIShow( NMAINSCENECHILDTAG.LuckyBox ) then
		LuckyBox.RefreshLotteryAmount( nFreeLotteryAmount );
	end
end


---------------------------------------------------
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgLuckyBox: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgLuckyBox: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == LBMA_GetFreeLotteryAmount ) then
		p.HandleMsgGetFreeLotteryAmount( tNetDataPackete );
	elseif ( nActionID == LBMA_Lottery ) then
		p.HandleMsgLottery( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_LUCKYBOX, "MsgLuckyBox.HandleNetMessage", p.HandleNetMessage );

