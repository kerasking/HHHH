---------------------------------------------------
--描述: 宴会相关消息响应及发送
--时间: 2012.10.19
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

---------------------------------------------------

MsgBanquet = {}
local p = MsgBanquet;

---------------------------------------------------
p.BanquetLimit				= 5;	-- 宴会人数限制
p.TheBanquetBugLimit		= 4;	-- 赴宴人数限制


---------------------------------------------------

-- 消息下各事件的枚举
--BanquetMsgAction = {
--	BMA_EntryUI					= 1,	-- 进入宴会界面
--	BMA_QuitUI					= 2,	-- 离开宴会界面--处于赴宴中的筹备中的退出该状态才可以退出
--	BMA_BanquetList				= 3,	-- 刷新宴会列表
--	BMA_Prepare					= 4,	-- 筹备宴会(向服务端发起请求)
--	BMA_Information				= 5,	-- 参加的宴会信息更新(人员变动)
--	BMA_Feast					= 6,	-- 赴宴(向服务端发起请求)
--	BMA_DriveOut				= 7,	-- 驱逐某人(向服务端发起请求)--show the door 
--	-- 被驱逐
--	-- 普通开席
--	-- 金币开席
--	-- 过时间点筹备中开未开的宴会被强制关闭
--	
--};

-- 宴会消息事件类型
local BMA_GetBanquetList		= 1;	-- 获取宴会列表
local BMA_PrepareBanquet		= 2;	-- 筹备宴会
local BMA_JoinBanquet			= 3;	-- 参加宴会
local BMA_CancelBanquet			= 4;	-- 取消宴会
local BMA_StartBanquet			= 5;	-- 开宴
local BMA_GoldStart				= 6;	-- 金币开宴
local BMA_LeaveBanquet			= 7;	-- 离开宴席
local BMA_ShowTheDoor			= 8;	-- 逐客
local BMA_Information			= 9;	-- 宴会信息
local BMA_GetFreeCardAmount		= 10;	-- 获取免费宴会卡数量
local BMA_TimeOut				= 11;	-- 过了宴会时间-
local BMA_Entry					= 12;	-- 进入宴会消息-服务端发

-- 数据包标志
local PacketFlag = {
	PF_BEGIN	= 1,	-- 首包(多个包情况下)
	PF_CONTINUE	= 0,	-- 中包(多个包情况下)
	PF_END		= 2,	-- 尾包(多个包情况下)
	PF_SINGLE	= 3,	-- 单包
};

--
-- 宴会与会者类型
BanquetStatus = {
	BS_NONE				= 1;	-- 旁观者
	BS_GUEST			= 2;	-- 宾客
	BS_HOST				= 3;	-- 东道主
};

-- 宴会列表项的数据索引
--tBanquetListItemDataIndex ={
--	BLIDI_HostUserID		= 1,	-- 东道主用户ID
--	BLIDI_HostName			= 2,	-- 东道主名
--	BLIDI_AttendeeNumber		= 3,	-- 已出席人数
--};
BLIDI = {
	HostUserID		= 1,	-- 东道主用户ID
	HostName			= 2,	-- 东道主名
	AttendeeNumber		= 3,	-- 已出席人数
};

---------------------------------------------------
--{ nHostUserID, szHostName, nNumber }
--测试数据
local tBanquetList = {
	{ 1001, "小菜鸟", 3 },
	{ 1002, "大菜鸟", 1 },
	{ 1003, "小小菜鸟", 1 },
};
-- 宴会信息列表项的数据索引
ALDI = {
	PlayerID	= 1,
	Name		= 2,
	Level		= 3,
};


--{ nPlayerID, szName, nLevel }
-- 测试数据
local tBanquetInformation = {
	nHostUserID	= 22111,
	tAttendeeList = {
		{ 1001, "小菜鸟", 30 },
		{ 1011, "小菜", 40 },
		{ 1111, "小鸟", 50 },
		{ 1111, "菜菜", 50 },
		{ 1111, "鸟鸟", 50 },
	},
};

---------------------------------------------------
p.tBanquetList	= nil;		-- 宴会列表

function p.ClearBuffer()
	p.tBanquetList	= nil;
end

--------------------------------------------------- 
function p.GetBanquetList()
	return tBanquetList;
end

function p.GetBanquetInfor()
	return tBanquetInformation;
end

---------------------------------------------------

--==消息发送接收==--
---------------------------------------------------
-- 发送获取免费宴会卡次数请求
function p.SendMsgGetFreeCardAmount()
	LogInfo( "MsgBanquet: SendMsgGetFreeCardAmount" );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_GetFreeCardAmount );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理获取免费宴会卡次数消息
function p.HandleMsgGetFreeCardAmount( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgGetFreeCardAmount" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		local nCardAmount = tNetDataPackete:ReadInt();
		Banquet.CallBack_GetFreeCardAmount( nCardAmount );--
	else
	end
end


---------------------------------------------------
-- 发送获取宴会列表请求
function p.SendMsgGetBanquetList()
	LogInfo( "MsgBanquet: SendMsgGetBanquetList" );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_GetBanquetList );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理获取宴会列表消息
function p.HandleMsgGetBanquetList( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgBanquetList" );
	local nPacketFlag = tNetDataPackete:ReadByte();
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
		p.tBanquetList = {};
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		p.tBanquetList = {};
	end
	local nAmount = tNetDataPackete:ReadInt();
	LogInfo( "MsgBanquet: nAmount:%d",nAmount );
	for i=1, nAmount do
		local nHostUserID		= tNetDataPackete:ReadInt();
		local nAttendeeAmount	= tNetDataPackete:ReadInt();
		local szHostName		= tNetDataPackete:ReadUnicodeString();
		LogInfo( "MsgBanquet: nHostUserID:%d, nAttendeeAmount:%d, szHostName:%s",nHostUserID,nAttendeeAmount,szHostName );
		local tBanquet = {};
		tBanquet[BLIDI.HostUserID]		= nHostUserID;
		tBanquet[BLIDI.AttendeeNumber]	= nAttendeeAmount;
		tBanquet[BLIDI.HostName]		= szHostName;
		table.insert( p.tBanquetList, tBanquet );
	end
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.RefreshBanquetList( p.tBanquetList );
		end
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.RefreshBanquetList( p.tBanquetList );
		end
	end
end

---------------------------------------------------
-- 发送筹备宴会请求
function p.SendMsgPrepareBanquet()
	LogInfo( "MsgBanquet: SendMsgPrepareBanquet" );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_PrepareBanquet );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理筹备宴会消息
function p.HandleMsgPrepareBanquet( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgPrepareBanquet" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.CallBack_PrepareSucceed();
		end
	else
		CommonDlgNew.ShowYesDlg( "举办失败", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发送取消宴会请求
function p.SendMsgCancelBanquet()
	LogInfo( "MsgBanquet: SendMsgCancelBanquet" );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_CancelBanquet );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理取消宴会消息
function p.HandleMsgCancelBanquet( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgCancelBanquet" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.CallBack_CancelSucceed();
		end
	else
		--CommonDlgNew.ShowYesDlg( "取消失败", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发送开宴请求
function p.SendMsgStartBanquet()
	LogInfo( "MsgBanquet: SendMsgStartBanquet" );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_StartBanquet );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理开宴消息
function p.HandleMsgStartBanquet( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgStartBanquet" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.CallBack_StartSucceed();
		end
	else
		CommonDlgNew.ShowYesDlg( "开席失败", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发送金币开席请求
function p.SendMsgGoldStart()
	LogInfo( "MsgBanquet: SendMsgGoldStart" );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_GoldStart );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理金币开席消息
function p.HandleMsgGoldStart( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgGoldStart" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.CallBack_GoldStartSucceed();
		end
	else
		CommonDlgNew.ShowYesDlg( "金币开席失败", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发送逐客请求
function p.SendMsgShowTheDoor( nPlayerID )
	LogInfo( "MsgBanquet: SendMsgStartBanquet nPlayerID:%d",nPlayerID );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_ShowTheDoor );
	netdata:WriteByte( 0 );--此处
	netdata:WriteInt( 0 );--此处
	netdata:WriteInt( nPlayerID );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理逐客消息
function p.HandleMsgShowTheDoor( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgShowTheDoor" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		local nPlayerID = tNetDataPackete:ReadInt();
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.CallBack_ShowTheDoorSucceed( nPlayerID );--
		end
	else
		CommonDlgNew.ShowYesDlg( "驱逐失败", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发送参加宴会请求
function p.SendMsgJoinBanquet( nHostUserID )
	LogInfo( "MsgBanquet: SendMsgJoinBanquet nHostUserID:%d",nHostUserID );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_JoinBanquet );
	netdata:WriteByte( 0 );--此处
	netdata:WriteInt( 0 );--此处
	netdata:WriteInt( nHostUserID );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理参加宴会消息
function p.HandleMsgJoinBanquet( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgJoinBanquet" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.CallBack_JoinSucceed();
		end
	else
		--CommonDlgNew.ShowYesDlg( "参加失败", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发送离开宴会请求
function p.SendMsgLeaveBanquet()
	LogInfo( "MsgBanquet: SendMsgLeaveBanquet" );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_LeaveBanquet );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理离开宴会消息
function p.HandleMsgLeaveBanquet( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgLeaveBanquet" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();--此处无用
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
			Banquet.CallBack_LeaveSucceed();
		end
	else
		--CommonDlgNew.ShowYesDlg( "离开失败", nil, nil, 3 );
	end
end

---------------------------------------------------
-- 发送获取某宴会信息请求
function p.SendMsgGetBanquetInformation( nBanquetID )
	LogInfo( "MsgBanquet: SendMsgGetBanquetInformation:%d",nBanquetID );
	local netdata = createNDTransData(NMSG_Type._MSG_BANQUET);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( BMA_Information );
	netdata:WriteByte( 0 );--此处
	netdata:WriteInt( 0 );--此处
	netdata:WriteInt( nBanquetID );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理宴会信息消息
function p.HandleMsgBanquetInformation( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgBanquetInformation" );
	local nPacketFlag	= tNetDataPackete:ReadByte();--此处无用
	local nAmount		= tNetDataPackete:ReadInt();
	local nHostUserID	= tNetDataPackete:ReadInt();
	local tBanquetInfor	= {};
	tBanquetInfor.nHostUserID		= nHostUserID;
	tBanquetInfor.tAttendeeList	= {};
	for i=1, nAmount do
		local nPlayerID	= tNetDataPackete:ReadInt();
		local nLevel	= tNetDataPackete:ReadInt();
		local szName	= tNetDataPackete:ReadUnicodeString();
		tBanquetInfor.tAttendeeList[i]					= {};
		tBanquetInfor.tAttendeeList[i][ALDI.PlayerID]	= nPlayerID;
		tBanquetInfor.tAttendeeList[i][ALDI.Name]		= szName;
		tBanquetInfor.tAttendeeList[i][ALDI.Level]		= nLevel;
		LogInfo( "MsgBanquet: HandleMsgBanquetInformation:"..szName );
	end
	
	if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
		Banquet.RefreshBanquetInformation( tBanquetInfor );
	end
end

---------------------------------------------------
-- 处理宴会时间已过消息
function p.HandleMsgTimeOut( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgTimeOut" );
	if IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
		Banquet.CallBack_TimeOut();
	end
end

---------------------------------------------------
-- 进入宴会界面
function p.HandleMsgEntry( tNetDataPackete )
	LogInfo( "MsgBanquet: HandleMsgEntry" );
	if not IsUIShow( NMAINSCENECHILDTAG.Banquet ) then
		Banquet.Entry();
	end
end


---------------------------------------------------
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgBanquet: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgBanquet: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == BMA_GetBanquetList ) then
		p.HandleMsgGetBanquetList( tNetDataPackete );
	elseif ( nActionID == BMA_PrepareBanquet ) then
		p.HandleMsgPrepareBanquet( tNetDataPackete );
	elseif ( nActionID == BMA_CancelBanquet ) then
		p.HandleMsgCancelBanquet( tNetDataPackete );
	elseif ( nActionID == BMA_StartBanquet ) then
		p.HandleMsgStartBanquet( tNetDataPackete );
	elseif ( nActionID == BMA_GoldStart ) then
		p.HandleMsgGoldStart( tNetDataPackete );
	elseif ( nActionID == BMA_ShowTheDoor ) then
		p.HandleMsgShowTheDoor( tNetDataPackete );
	elseif ( nActionID == BMA_JoinBanquet ) then
		p.HandleMsgJoinBanquet( tNetDataPackete );
	elseif ( nActionID == BMA_LeaveBanquet ) then
		p.HandleMsgLeaveBanquet( tNetDataPackete );
	elseif ( nActionID == BMA_Information ) then
		p.HandleMsgBanquetInformation( tNetDataPackete );
	elseif ( nActionID == BMA_GetFreeCardAmount ) then
		p.HandleMsgGetFreeCardAmount( tNetDataPackete );
	elseif ( nActionID == BMA_TimeOut ) then
		p.HandleMsgTimeOut( tNetDataPackete );
	elseif ( nActionID == BMA_Entry ) then
		p.HandleMsgEntry( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_BANQUET, "MsgBanquet.HandleNetMessage", p.HandleNetMessage );

