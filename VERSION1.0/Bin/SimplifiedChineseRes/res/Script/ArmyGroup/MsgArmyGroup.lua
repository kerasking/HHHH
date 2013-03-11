---------------------------------------------------
--描述: 军团相关消息响应及发送
--时间: 2012.9.19
--作者: Guosen
---------------------------------------------------
--判定玩家是否拥有军团籍		MsgArmyGroup.GetUserArmyGroupShipStatus( nUserID ) == ArmyGroupShipStatus.AGMSS_MEMBER
---------------------------------------------------
--获得玩家所在军团的军团ID		MsgArmyGroup.GetUserArmyGroupID( nUserID )	--
--参数为玩家的用户ID
---------------------------------------------------

MsgArmyGroup = {}
local p = MsgArmyGroup;

---------------------------------------------------
p.ArmyGroupApplyLimit		= 5;	-- 军团申请条数限制数

p.COLOR_GRAY						= ccc4(158,158,158,255);
p.COLOR_YELLOW						= ccc4(255,255,0,255);

local tArmyGroupPositionString = {
	GetTxtPri("MAG2_T1"), GetTxtPri("MAG2_T2"), GetTxtPri("MAG2_T3"),
};

local tArmyGroupErrorString = {
	GetTxtPri("MAG2_T4"),
	GetTxtPri("MAG2_T5"),
	GetTxtPri("MAG2_T6"),
	GetTxtPri("MAG2_T7"),
	GetTxtPri("MAG2_T8"),
	GetTxtPri("MAG2_T9"),
	GetTxtPri("MAG2_T10"),
	GetTxtPri("MAG2_T11"),
	GetTxtPri("MAG2_T12"),
	GetTxtPri("MAG2_T13"),
	GetTxtPri("MAG2_T14"),
	GetTxtPri("MAG2_T15"),
	GetTxtPri("MAG2_T16"),
	GetTxtPri("MAG2_T17"),
	GetTxtPri("MAG2_T18"),
	GetTxtPri("MAG2_T19"),
	GetTxtPri("MAG2_T20"),
	GetTxtPri("MAG2_T21"),
    GetTxtPri("MAG2_T22"),
    GetTxtPri("MAG2_T36"),
    GetTxtPri("MAG2_T37"),
    GetTxtPri("MAG2_T38"),
    GetTxtPri("MAG2_T39"),
};

local tArmyGroupOnlineString = {
	GetTxtPri("MAG2_T23"), GetTxtPri("MAG2_T24"),
};

--
local SZ_QUIT_STRING	= GetTxtPri("MAG2_T25");
local SZ_ENTRY_STRING	= GetTxtPri("MAG2_T26");
local SZ_DISMISS_STRING	= GetTxtPri("MAG2_T27");


---------------------------------------------------
function p.GetLogoutString( nTime )
	local str="";
    if nTime < 60 then
        str = str..GetTxtPri("AREAUI_T7");
	elseif nTime < 1800 then
		str=str..SafeN2S(getIntPart(nTime/60))..GetTxtPri("AREAUI_T8");
	elseif nTime < 3600 then
		str=str..GetTxtPri("AREAUI_T18");
	elseif nTime < 86400 then
		str=str..SafeN2S(getIntPart(nTime/3600))..GetTxtPri("AREAUI_T9");
	else
		str=str..SafeN2S(getIntPart(nTime/86400))..GetTxtPri("AREAUI_T10");
	end
	str = str.. GetTxtPri("AREAUI_T11");
	return str;
end

---------------------------------------------------
-- 军团记录索引枚举
ArmyGroupRecordIndex = {
	AGRI_ID				= 1,	-- ID
	AGRI_RANKING		= 2,	-- 排名
	AGRI_AGNAME			= 3,	-- 军团名
	AGRI_ONAME			= 4,	-- 军团长名
	AGRI_LEVEL			= 5,	-- 等级
	AGRI_MEMBER			= 6,	-- 成员数
	AGRI_MEMBERLIMIT	= 7,	-- 成员数限制
	AGRI_NOTICE			= 8,	-- 公告
};

-- 军团资格状态枚举
ArmyGroupShipStatus = {
	AGMSS_NONE		= 1,	-- 啥都木有
	AGMSS_APPLY		= 2,	-- 处于申请加入某军团待审批中
	AGMSS_MEMBER	= 3,	-- 已是某军团成员
};

-- 职位等级枚举
ArmyGroupPositionGrade = {
	AGPG_NONE				= 1;	-- 普通成员
	AGPG_DEPUTY_LEGATUS		= 2;	-- 副军团长
	AGPG_LEGATUS			= 3;	-- 军团长
};

-- 军团成员属性索引枚举
ArmyGroupMemberIndex = {
	AGMI_USERID			= 1,	-- 成员的用户ID
	AGMI_NAME			= 2,	-- 名字
	AGMI_LEVEL			= 3,	-- 等级
	AGMI_POSITION		= 4,	-- 职位
	AGMI_RANKING		= 5,	-- 竞技场排名
	AGMI_REPUTTODAY		= 6,	-- 当天声望
	AGMI_REPUTTOTAL		= 7,	-- 总声望
	AGMI_ISONLINE		= 8,	-- 是否在线
	AGMI_CONTTODAY		= 9,	-- 当天捐献
	AGMI_CONTTOTAL		= 10,	-- 捐献总额
	AGMI_LASTLOGOUT		= 11,	-- 最近离线时刻
};

-- 军团申请者的属性索引枚举
ArmyGroupApplicantIndex = {
	AGAI_USERID			= 1,	-- 申请者的用户ID
	AGAI_NAME			= 2,	-- 名字
	AGAI_LEVEL			= 3,	-- 等级
	AGAI_RANKING		= 4,	-- 竞技场排名
	AGAI_REPUTE			= 5,	-- 声望
};

-- 军团消息下各事件的枚举
ArmyGroupMsgAction = {
	AGMA_USERINFORMATION		= 100,	-- 玩家的军团信息
	AGMA_CreateArmyGroup		= 1,	-- 创建军团
	AGMA_ArmyGroupList			= 3,	-- 军团列表
	AGMA_Information			= 4,	-- 军团信息
	AGMA_ApplyJion				= 5,	-- 申请加入
	AGMA_CancelApply			= 6,	-- 撤消申请
	AGMA_ApplicantList			= 7,	-- 申请者列表
	AGMA_AcceptApplication		= 8,	-- 接受申请
	AGMA_RefuseApplication		= 9,	-- 拒绝申请
	AGMA_Quit					= 10,	-- 退出军团
	AGMA_Dismiss				= 11,	-- 开除成员
	AGMA_SetNotice				= 13,	-- 设置公告
	AGMA_AppointDeputy			= 15,	-- 任命副军团长
	AGMA_RemovalDeputy			= 16,	-- 解除副军团长
	AGMA_Abdicate				= 17,	-- 禅让军团长
	AGMA_MemberList				= 18,	-- 成员列表
	AGMA_AGUpgrade				= 19,	-- 军团信息变更
    AGMA_GetStorage				= 20,	-- 军团仓库
	AGMA_Delivery				= 21,	-- 发放
    --AGMA_BeLegatus				= 19,	-- 莫名就成为军团长……
	--AGMA_BeDeputy				= 100,	-- 被任命副军团长
	--AGMA_BeRemoval				= 100,	-- 被解除副军团长
	--AGMA_BeMember				= 100,	-- 成为某军团成员了……
	AGMA_ErrorCode				= 100,	-- 错误码
};

-- 军团信息变更事件类型
AGUpgradeAction = {
	AGUA_Legatus		= 1,	-- 军团长变更
	AGUA_Member			= 2,	-- 成员数量变更
	AGUA_Notice			= 3,	-- 公告变更
	AGUA_Level			= 4,	-- 等级变更
	AGUA_Ranking		= 5,	-- 排名变更
	AGUA_Experience		= 6,	-- 经验变更
};

-- 数据包标志
local PacketFlag = {
	PF_BEGIN	= 1,	-- 首包(多个包情况下)
	PF_CONTINUE	= 0,	-- 中包(多个包情况下)
	PF_END		= 2,	-- 尾包(多个包情况下)
	PF_SINGLE	= 3,	-- 单包
};

--升级所需经验
local tUpgradeLevelExp = {
	2000000, 3150000, 4400000, 4600000, 6000000, 6250000, 6500000, 8100000, 9800000, 9800000,
};

-- 玩家的军团属性缓存字段索引
UserArmyGroupAttrIndex = {
	UAGAI_AGID			= 1,
	UAGAI_AGName		= 2,
	UAGAI_AGPosition	= 3,
	UAGAI_CtbtToday		= 4,
	UAGAI_CtbtTotal		= 5,
	UAGAI_ApplyList		= 6,
	UAGAI_AGStatus		= 7,
};

---------------------------------------------------
--{ nArmyGroupID, nRanking, szAGName, szOName, nLevel, nMember }
--测试数据
local tArmyGroupList = {
	{ 1001, 1, "青龙帮", "龙皇", 9, 10, 18 },
	{ 1002, 2, "白虎堂", "虎帝", 8, 10, 17 },
	{ 1003, 3, "朱雀宫", "雀圣", 7, 10, 16 },
	{ 1004, 4, "玄武门", "武尊", 6, 10, 15 },
};

-- 测试数据
local tArmyGroupInformation = {
	nArmyGroupID	= 1001, 
	nRanking		= 1, 
	szAGName		= "青龙帮", 
	szOName			= "龙皇", 
	nLevel			= 9, 
	nMember			= 10, 
	nExperience		= 9999,
	szNotice		= "抢钱！抢粮！抢地盘！",
	nMemberLimit	= 9+19,
	nExpNextLevel	= 12000,
};


-- 成员列表{ nUserID, szName, nLevel, nPosition, nRanking, nReputationToday, nReputationTotal, nLastOline, nContributionToday, nContributionTotal }
--测试数据
local tArmyGroupMemberList = {
	{ 1001, "龙皇", 99, 3, 10, 1000, 5000, 10, 200, 1, 2000 },
	{ 1002, "星仔", 80, 2, 20, 800, 4000, 20, 100, 1, 1000 },
	{ 1003, "小七", 70, 1, 30, 600, 2000, 40, 10, 1, 100 },
	{ 1004, "紫霞", 60, 1, 40, 500, 1000, 40, 10, 1, 100 },
	{ 1005, "晶晶", 50, 1, 50, 60, 900, 40, 10, 1, 100 },
	{ 1006, "苏灿", 40, 1, 60, 40, 800, 40, 10, 1, 100 },
	{ 1007, "小宝", 30, 1, 70, 30, 700, 40, 10, 1, 100 },
	{ 1008, "小习", 20, 1, 4000, 2, 2, 40, 0, 0, 0 },
	{ 1009, "小胡", 10, 1, 5000, 1, 1, 40, 0, 0, 0 },
	{ 1010, "小江", 5, 1, 9000, 0, 0, 40, 0, 0, 0 },
};

-- 申请人列表{ nUserID, szName, nLevel, nRanking, nReputation }
--测试数据
local tApplicantList = {
	{ 1011, "小虾米", 10, 800, 100 },
	{ 1012, "大虾米", 20, 600, 200 },
	{ 1013, "毛东东", 30, 400, 300 },
	{ 1014, "邓平平", 40, 200, 400 },
};

--
local tStorage = {
	{ 34000000, 1234 },
	{ 34000001, 123 },
	{ 34000002, 12 },
	{ 34000003, 1 },
};

---------------------------------------------------
p.tUserInfor		= nil;
p.tArmyGroupList	= nil;		-- 军团列表
p.tAGInformation	= nil;		-- 军团信息--当前玩家所在军团的军团信息
p.tAGMemberList		= nil;		-- 成员列表--当前玩家所在军团的成员列表
p.tAGApplicantList	= nil;		-- 申请者列表--当前玩家所在军团的申请者列表
p.tmpMemberList		= nil;		-- 临时数据
p.tStorage            = nil;        -- 

function p.ClearBuffer()
	p.tUserInfor		= nil;
	p.tArmyGroupList	= nil;
	p.tAGInformation	= nil;
	p.tAGMemberList		= nil;
	p.tAGApplicantList	= nil;
	p.tmpMemberList		= nil;
    p.tStorage            = nil;
end

---------------------------------------------------
-- 获取玩家军团状态
function p.GetUserArmyGroupShipStatus( nUserID )
	if ( nUserID == nil ) or ( p.tUserInfor == nil ) or ( p.tUserInfor[nUserID] == nil ) then
		return nil;
	end
	local nAGID  = p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGID];
	if ( nAGID ~= nil ) then
		return ArmyGroupShipStatus.AGMSS_MEMBER;
	end
	if ( table.getn(p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]) > 0 ) then
		return ArmyGroupShipStatus.AGMSS_APPLY;
	end
	return ArmyGroupShipStatus.AGMSS_NONE;
end

-- 获取玩家所在军团ID
function p.GetUserArmyGroupID( nUserID )
	if ( nUserID == nil ) or ( p.tUserInfor == nil ) or ( p.tUserInfor[nUserID] == nil ) then
		return nil;
	end
	local nAGID  = p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGID];
	return nAGID;
end

-- 获取玩家所在军团职位
function p.GetUserArmyGroupPosition( nUserID )
	if ( nUserID == nil ) or ( p.tUserInfor == nil ) or ( p.tUserInfor[nUserID] == nil ) then
		return nil;
	end
	local nPosition  = p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition];
	return nPosition;
end

---------------------------------------------------
-- 获取玩家申请加入的军团ID列表
function p.GetArmyGroupApplyList( nUserID )
	if ( nUserID == nil ) or ( p.tUserInfor == nil ) or ( p.tUserInfor[nUserID] == nil ) then
		return nil;
	end
	return p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList];
end

---------------------------------------------------
-- 获取军团升级需要的经验
function p.GetUpgradeExp( nLevel )
	return tUpgradeLevelExp[nLevel];
end

---------------------------------------------------
-- 获取军团列表
function p.GetArmyGroupList()
	return p.tArmyGroupList;
	--return tArmyGroupList;
end

---------------------------------------------------
-- 获取玩家所在军团军团信息
function p.GetArmyGroupInformation( nArmyGroupID )
	return p.tAGInformation;
	--return tArmyGroupInformation;
end

---------------------------------------------------
-- 获取玩家所在军团成员列表
function p.GetArmyGroupMemberList( nArmyGroupID )
	return p.tAGMemberList;
	--return tArmyGroupMemberList;
end

---------------------------------------------------
-- 获取玩家所在军团申请者列表
function p.GetArmyGroupApplicantList( nArmyGroupID )
	return p.tAGApplicantList;
	--return tApplicantList;
end

---------------------------------------------------
-- 获取玩家所在军团仓库
function p.GetArmyGroupStorage( nArmyGroupID )
	return p.tStorage;
	--return tStorage;
end


---------------------------------------------------
-- 获得职位名称字符串
function p.GetPositionString( nPosition )
	if ( nPosition <= 0 or nPosition > table.getn(tArmyGroupPositionString) ) then
		return "";
	end
	return tArmyGroupPositionString[nPosition];
end


---------------------------------------------------
-- 获得最后在线字符串
function p.GetIsOnlineString( nIsOnline )
	if ( nIsOnline == 0 ) then
		return tArmyGroupOnlineString[1];
	else
		return tArmyGroupOnlineString[2];
	end
end


--==消息发送接收==--
---------------------------------------------------
-- 发送获取军团列表请求
function p.SendMsgGetArmyGroupList()
	LogInfo( "MsgArmyGroup: SendMsgGetArmyGroupList" );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_ArmyGroupList );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理军团列表消息
function p.HandleMsgArmyGroupList( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgArmyGroupList" );
	local nPacketFlag = tNetDataPackete:ReadByte();
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
		p.tArmyGroupList = {};
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		p.tArmyGroupList = {};
	end
	local nAmount = tNetDataPackete:ReadShort();
	LogInfo( "MsgArmyGroup: nAmount:%d",nAmount );
	for i=1, nAmount do
		local nArmyGroupID	= tNetDataPackete:ReadInt();
		local nAGLevel		= tNetDataPackete:ReadShort();
		local nRanking		= tNetDataPackete:ReadInt();
		local nMbrAmount	= tNetDataPackete:ReadShort();
		local nMbrLimit		= tNetDataPackete:ReadShort();
		local nExp			= tNetDataPackete:ReadInt();
		local szAGName		= tNetDataPackete:ReadUnicodeString();
		local szLegatusName	= tNetDataPackete:ReadUnicodeString();
	--LogInfo( "MsgArmyGroup: nArmyGroupID:%d, nAGLevel:%d, nRanking:%d, nMbrAmount:%d, nMbrLimit:%d, nExp:%d, szAGName:%s, szLegatusName:%s",nArmyGroupID,nAGLevel,nRanking,nMbrAmount,nMbrLimit,nExp,szAGName,szLegatusName );
		
		local tArmyGroup = {};
		tArmyGroup[ArmyGroupRecordIndex.AGRI_ID]			= nArmyGroupID;
		tArmyGroup[ArmyGroupRecordIndex.AGRI_RANKING]		= nRanking;
		tArmyGroup[ArmyGroupRecordIndex.AGRI_AGNAME]		= szAGName;
		tArmyGroup[ArmyGroupRecordIndex.AGRI_ONAME]			= szLegatusName;
		tArmyGroup[ArmyGroupRecordIndex.AGRI_LEVEL]			= nAGLevel;
		tArmyGroup[ArmyGroupRecordIndex.AGRI_MEMBER]		= nMbrAmount;
		tArmyGroup[ArmyGroupRecordIndex.AGRI_MEMBERLIMIT]	= nMbrLimit;
		table.insert( p.tArmyGroupList, tArmyGroup );
	end
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
		-- 按排名排
		table.sort(p.tArmyGroupList, function (a,b)  return (a[ArmyGroupRecordIndex.AGRI_RANKING] < b[ArmyGroupRecordIndex.AGRI_RANKING]) end);
		if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
			CreateOrJoinArmyGroup.RefreshAGList( p.tArmyGroupList );
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshAGList( p.tArmyGroupList );
		end
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		-- 按排名排
		table.sort(p.tArmyGroupList, function (a,b)  return (a[ArmyGroupRecordIndex.AGRI_RANKING] < b[ArmyGroupRecordIndex.AGRI_RANKING]) end);
		if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
			CreateOrJoinArmyGroup.RefreshAGList( p.tArmyGroupList );
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshAGList( p.tArmyGroupList );
		end
	end
end

---------------------------------------------------
-- 发送获取某军团信息请求
function p.SendMsgGetArmyGroupInformation( nArmyGroupID )
	LogInfo( "MsgArmyGroup: SendMsgGetArmyGroupInformation:%d",nArmyGroupID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_Information );
	netdata:WriteInt( nArmyGroupID );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理军团信息消息
function p.HandleMsgArmyGroupInformation( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgArmyGroupInformation" );
	local nArmyGroupID	= tNetDataPackete:ReadInt();
	local nLevel		= tNetDataPackete:ReadShort();
	local nRanking		= tNetDataPackete:ReadShort();
	local nMbrAmount	= tNetDataPackete:ReadShort();
	local nMbrLimit		= tNetDataPackete:ReadShort();
	local nExp			= tNetDataPackete:ReadInt();
	local nExpUpgrade	= p.GetUpgradeExp( nLevel );
	local szAGName		= tNetDataPackete:ReadUnicodeString();
	local szLegatusName	= tNetDataPackete:ReadUnicodeString();
	local szNotice		= tNetDataPackete:ReadUnicodeString();
	LogInfo( "MsgArmyGroup: nArmyGroupID:%d, nLevel:%d, nRanking:%d, nMbrAmount:%d, nMbrLimit:%d, nExp:%d, nExpUpgrade:%d",nArmyGroupID,nLevel,nRanking,nMbrAmount,nMbrLimit,nExp,nExpUpgrade );
	LogInfo( "MsgArmyGroup: szAGName:%s, szLegatusName:%s, szNotice:%s",szAGName,szLegatusName,szNotice );
	
	tArmyGroupInformation = {};
	tArmyGroupInformation.nArmyGroupID	= nArmyGroupID; 
	tArmyGroupInformation.nRanking		= nRanking;
	tArmyGroupInformation.szAGName		= szAGName;
	tArmyGroupInformation.szOName		= szLegatusName;
	tArmyGroupInformation.nLevel		= nLevel;
	tArmyGroupInformation.nMember		= nMbrAmount;
	tArmyGroupInformation.nExperience	= nExp;
	tArmyGroupInformation.szNotice		= szNotice;
	tArmyGroupInformation.nMemberLimit	= nMbrLimit;
	tArmyGroupInformation.nExpNextLevel	= nExpUpgrade;
	
	local nUserID = GetPlayerId();
	local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
	if ( nArmyGroupID == nUserArmyGroupID ) then
		p.tAGInformation = tArmyGroupInformation;
	end
	if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
		ArmyGroup.RefreshInformation( tArmyGroupInformation );
	end
	if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
		CreateOrJoinArmyGroup.RefreshInformation( tArmyGroupInformation );
	end
end

---------------------------------------------------
-- 发送获取成员列表信息请求
function p.SendMsgGetArmyGroupMemberList( nArmyGroupID )
	LogInfo( "MsgArmyGroup: SendMsgGetArmyGroupMemberList:%d",nArmyGroupID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_MemberList );
	netdata:WriteInt( nArmyGroupID );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理成员列表信息消息
function p.HandleMsgArmyGroupMemberList( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgArmyGroupMemberList" );
	local nArmyGroupID	= tNetDataPackete:ReadInt();
	local nPacketFlag	= tNetDataPackete:ReadByte();
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
		p.tmpMemberList = {};
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		p.tmpMemberList = {};
	end
	local nAmount = tNetDataPackete:ReadShort();
	LogInfo( "MsgArmyGroup: nAmount:%d",nAmount );
	for i=1, nAmount do
		local nUserID			= tNetDataPackete:ReadInt();	-- 成员的用户ID
		local nLevel			= tNetDataPackete:ReadShort();	-- 等级
		local nPosition			= tNetDataPackete:ReadByte();	-- 职位
		local nRanking			= tNetDataPackete:ReadInt();	-- 竞技场排名
		local nIsOnline			= tNetDataPackete:ReadByte();	-- 在线否
		local nContributeToday	= tNetDataPackete:ReadInt();	-- 当天捐献
		local nContributeTotal	= tNetDataPackete:ReadInt();	-- 捐献总额
		local nReputeToday		= tNetDataPackete:ReadInt();	-- 当天声望
		local nReputeTotal		= tNetDataPackete:ReadInt();	-- 总声望
		local nLastLogoutTime	= tNetDataPackete:ReadInt();	-- 最近上线时刻
		local szName			= tNetDataPackete:ReadUnicodeString();	-- 名字
		local tMember = {};
		tMember[ArmyGroupMemberIndex.AGMI_USERID]		= nUserID;
		tMember[ArmyGroupMemberIndex.AGMI_NAME]			= szName;
		tMember[ArmyGroupMemberIndex.AGMI_LEVEL]		= nLevel;
		tMember[ArmyGroupMemberIndex.AGMI_POSITION]		= nPosition;
		tMember[ArmyGroupMemberIndex.AGMI_RANKING]		= nRanking;
		tMember[ArmyGroupMemberIndex.AGMI_REPUTTODAY]	= nReputeToday;
		tMember[ArmyGroupMemberIndex.AGMI_REPUTTOTAL]	= nReputeTotal;
		tMember[ArmyGroupMemberIndex.AGMI_CONTTODAY]	= nContributeToday;
		tMember[ArmyGroupMemberIndex.AGMI_CONTTOTAL]	= nContributeTotal;
		tMember[ArmyGroupMemberIndex.AGMI_ISONLINE]		= nIsOnline;
		tMember[ArmyGroupMemberIndex.AGMI_LASTLOGOUT]	= nLastLogoutTime;
		table.insert( p.tmpMemberList, tMember );
	end
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
		-- 按职位等级排
		table.sort(p.tmpMemberList, function (a,b)  return (a[ArmyGroupMemberIndex.AGMI_POSITION] > b[ArmyGroupMemberIndex.AGMI_POSITION]) end);
		
		local nUserID = GetPlayerId();
		local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
		if ( nArmyGroupID == nUserArmyGroupID ) then
			p.tAGMemberList = p.tmpMemberList;
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshMemberlist( p.tmpMemberList, nArmyGroupID );
		end
		if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
			CreateOrJoinArmyGroup.RefreshMemberlist( p.tmpMemberList );
		end
		
		--斗地主求救
		if IsUIShow( NMAINSCENECHILDTAG.SlaveUI ) then
			Slave.LoadUISynSos(p.tmpMemberList);			
		end
				
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		-- 按职位等级排
		table.sort(p.tmpMemberList, function (a,b)  return (a[ArmyGroupMemberIndex.AGMI_POSITION] > b[ArmyGroupMemberIndex.AGMI_POSITION]) end);
		
		local nUserID = GetPlayerId();
		local nUserArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
		if ( nArmyGroupID == nUserArmyGroupID ) then
			p.tAGMemberList = p.tmpMemberList;
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshMemberlist( p.tmpMemberList, nArmyGroupID );
		end
		if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
			CreateOrJoinArmyGroup.RefreshMemberlist( p.tmpMemberList );
		end
		
		--斗地主求救
		if IsUIShow( NMAINSCENECHILDTAG.SlaveUI ) then		
			Slave.LoadUISynSos(p.tmpMemberList);	
		end
	
	end
end

---------------------------------------------------
-- 发送获取申请者列表信息请求
function p.SendMsgGetArmyGroupApplicantList( nArmyGroupID )
	LogInfo( "MsgArmyGroup: SendMsgGetArmyGroupApplicantList:%d",nArmyGroupID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_ApplicantList );
	netdata:WriteInt( nArmyGroupID );
	SendMsg( netdata );
	netdata:Free();
end

---------------------------------------------------
-- 处理申请者列表信息消息
function p.HandleMsgArmyGroupApplicantList( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgArmyGroupApplicantList" );
	local nArmyGroupID	= tNetDataPackete:ReadInt();
	local nPacketFlag	= tNetDataPackete:ReadByte();
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
		p.tAGApplicantList = {};
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		p.tAGApplicantList = {};
	end
	local nAmount = tNetDataPackete:ReadShort();
	LogInfo( "MsgArmyGroup: nAmount:%d",nAmount );
	for i=1, nAmount do
		local nUserID			= tNetDataPackete:ReadInt();	-- 申请者的用户ID
		local nLevel			= tNetDataPackete:ReadShort();	-- 等级
		local nRanking			= tNetDataPackete:ReadInt();	-- 竞技场排名
		local nRepute			= tNetDataPackete:ReadInt();	-- 声望
		local szName			= tNetDataPackete:ReadUnicodeString();	-- 名字
		local tApplicant ={};
		tApplicant[ArmyGroupApplicantIndex.AGAI_USERID]		= nUserID;
		tApplicant[ArmyGroupApplicantIndex.AGAI_NAME]		= szName;
		tApplicant[ArmyGroupApplicantIndex.AGAI_LEVEL]		= nLevel;
		tApplicant[ArmyGroupApplicantIndex.AGAI_RANKING]	= nRanking;
		tApplicant[ArmyGroupApplicantIndex.AGAI_REPUTE]		= nRepute;
		table.insert( p.tAGApplicantList, tApplicant );
	end
	
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			Solicit.RefreshApplicantList( p.tAGApplicantList );
		end
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			Solicit.RefreshApplicantList( p.tAGApplicantList );
		end
	end
end

---------------------------------------------------
-- 发送申请加入军团消息
function p.SendMsgJoinArmyGroupApplication( nArmyGroupID )
	LogInfo( "MsgArmyGroup: SendMsgJoinArmyGroupApplication:%d",nArmyGroupID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_ApplyJion );
	netdata:WriteInt( nArmyGroupID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 响应发送申请成功--响应某玩家申请加入某军团成功
function p.HandleMsgJoinArmyGroupApplication( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgJoinArmyGroupApplication" );
	local nFlag			= tNetDataPackete:ReadByte();
	local nArmyGroupID	= tNetDataPackete:ReadInt();
	LogInfo( "MsgArmyGroup: nFlag:%d, nArmyGroupID:%d",nFlag,nArmyGroupID );
	if ( nFlag == 0 ) then
		local nPlayerID			= tNetDataPackete:ReadInt();	-- 申请者的用户ID
		local nLevel			= tNetDataPackete:ReadShort();	-- 等级
		local nRanking			= tNetDataPackete:ReadInt();	-- 竞技场排名
		local nRepute			= tNetDataPackete:ReadInt();	-- 声望
		local szName			= tNetDataPackete:ReadUnicodeString();	-- 名字
		local nUserID	= GetPlayerId();
		if ( nUserID == nPlayerID ) then
			-- 当前玩家发起的申请
			table.insert( p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList], nArmyGroupID );
			-- 玩家属性
			if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
				CreateOrJoinArmyGroup.RefreshApplyList();
    			CloseLoadBar();--
			end
		else
			local tApplicant ={};
			tApplicant[ArmyGroupApplicantIndex.AGAI_USERID]		= nPlayerID;
			tApplicant[ArmyGroupApplicantIndex.AGAI_NAME]		= szName;
			tApplicant[ArmyGroupApplicantIndex.AGAI_LEVEL]		= nLevel;
			tApplicant[ArmyGroupApplicantIndex.AGAI_RANKING]	= nRanking;
			tApplicant[ArmyGroupApplicantIndex.AGAI_REPUTE]		= nRepute;
			table.insert( p.tAGApplicantList, tApplicant );
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				Solicit.RefreshApplicantList( p.tAGApplicantList );
			end
		end
	else
    	CloseLoadBar();--
	end
end


---------------------------------------------------
-- 发送取消申请消息
function p.SendMsgCancelApply( nArmyGroupID )
	LogInfo( "MsgArmyGroup: SendMsgCancelApply:%d",nArmyGroupID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_CancelApply );
	netdata:WriteInt( nArmyGroupID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 响应取消申请成功--响应某玩家取消申请加入某军团
function p.HandleMsgCancelApply( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgCancelApply" );
	local nFlag			= tNetDataPackete:ReadByte();
	local nArmyGroupID	= tNetDataPackete:ReadInt();
	local nSenderID		= tNetDataPackete:ReadInt();	-- 执行批准操作的玩家ID
	LogInfo( "MsgArmyGroup: nFlag:%d, nArmyGroupID:%d",nFlag,nArmyGroupID );
	local nUserID		= GetPlayerId();
	if ( nFlag == 0 ) then
		local nUserID	= GetPlayerId();
		if ( nUserID == nSenderID ) then
			-- 当前玩家发起的取消申请
			for i, v in ipairs(p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]) do
				if ( nArmyGroupID == v ) then
					table.remove( p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList], i );
					break;
				end
			end
			-- 玩家属性
			if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
				CreateOrJoinArmyGroup.RefreshApplyList();
				CloseLoadBar();--
			end
		else
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				if ( p.tAGApplicantList ~= nil ) then
					for i, v in pairs(p.tAGApplicantList) do
						if ( nSenderID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
							table.remove( p.tAGApplicantList, i );
							break;
						end
					end
					Solicit.RefreshApplicantList( p.tAGApplicantList );
				end
			end
		end
	else
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 发送创建军团请求
function p.SendMsgCreateArmyGroup( szAGName )
	LogInfo( "MsgArmyGroup: SendMsgCreateArmyGroup:"..szAGName );
	local netdata = createNDTransData( NMSG_Type._MSG_ARMYGROUP );
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_CreateArmyGroup );
	netdata:WriteStr( szAGName );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 响应创建军团请求
function p.HandleMsgCreateArmyGroup( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgCreateArmyGroup" );
    CloseLoadBar();--
	local nFlag	= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then--为0=成功，跟数据；非0=错误，且为错误代码
		local nArmyGroupID	= tNetDataPackete:ReadInt();
		local szAGName		= tNetDataPackete:ReadUnicodeString();
		
		local nUserID	= GetPlayerId();
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGID]		= nArmyGroupID;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGName]		= szAGName;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition]	= ArmyGroupPositionGrade.AGPG_LEGATUS;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_CtbtToday]	= 0;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_CtbtTotal]	= 0;
	
		if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
			CreateOrJoinArmyGroup.CloseUI();
		end
		LogInfo( "MsgArmyGroup: HandleMsgCreateArmyGroup nArmyGroupID:%d, szAGName:%s",nArmyGroupID,szAGName );

		ArmyGroup.ShowArmyGroupMainUI( nArmyGroupID );
	else
		CommonDlgNew.ShowYesDlg( tArmyGroupErrorString[nFlag], nil, nil, 3 );
	end
end

---------------------------------------------------
-- 批准某玩家加入本军团的申请
function p.SendMsgApproveApplication( nPlayerID )
	LogInfo( "MsgArmyGroup: SendMsgApproveApplication:%d",nPlayerID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_AcceptApplication );
	netdata:WriteInt( nPlayerID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 某玩家被批准加入本军团
function p.HandleMsgArmyAcceptApplication( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgArmyAcceptApplication" );
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nSenderID			= tNetDataPackete:ReadInt();	-- 执行批准操作的玩家ID
		local nPlayerID			= tNetDataPackete:ReadInt();	-- 被批准的玩家ID
		local nArmyGroupID		= tNetDataPackete:ReadInt();	-- 军团ID
		local nLevel			= tNetDataPackete:ReadShort();	-- 等级
		local nPosition			= tNetDataPackete:ReadByte();	-- 职位
		local nRanking			= tNetDataPackete:ReadInt();	-- 竞技场排名
		local nIsOnline			= tNetDataPackete:ReadByte();	-- 在线否
		local nContributeToday	= tNetDataPackete:ReadInt();	-- 当天捐献
		local nContributeTotal	= tNetDataPackete:ReadInt();	-- 捐献总额
		local nReputeToday		= tNetDataPackete:ReadInt();	-- 当天声望
		local nReputeTotal		= tNetDataPackete:ReadInt();	-- 总声望
		local nLastLogoutTime	= tNetDataPackete:ReadInt();	-- 最近上线时刻
		local szName			= tNetDataPackete:ReadUnicodeString();	-- 玩家名字
		local szAGName			= tNetDataPackete:ReadUnicodeString();	-- 军团名字
	--LogInfo( "MsgArmyGroup: nPlayerID:%d, nLevel:%d, nPosition:%d, nRanking:%d, nIsOnline:%d, nContributeToday:%d, nReputeTotal:%d, nLastLogoutTime:%d, szName:%s",nPlayerID,nLevel,nPosition,nRanking,nIsOnline,nContributeToday,nReputeTotal,nLastLogoutTime,szName );
		local tMember = {};
		tMember[ArmyGroupMemberIndex.AGMI_USERID]		= nPlayerID;
		tMember[ArmyGroupMemberIndex.AGMI_NAME]			= szName;
		tMember[ArmyGroupMemberIndex.AGMI_LEVEL]		= nLevel;
		tMember[ArmyGroupMemberIndex.AGMI_POSITION]		= nPosition;
		tMember[ArmyGroupMemberIndex.AGMI_RANKING]		= nRanking;
		tMember[ArmyGroupMemberIndex.AGMI_REPUTTODAY]	= nReputeToday;
		tMember[ArmyGroupMemberIndex.AGMI_REPUTTOTAL]	= nReputeTotal;
		tMember[ArmyGroupMemberIndex.AGMI_CONTTODAY]	= nContributeToday;
		tMember[ArmyGroupMemberIndex.AGMI_CONTTOTAL]	= nContributeTotal;
		tMember[ArmyGroupMemberIndex.AGMI_ISONLINE]		= nIsOnline;
		tMember[ArmyGroupMemberIndex.AGMI_LASTLOGOUT]	= nLastLogoutTime;
		local nUserID	= GetPlayerId();
		if ( nUserID == nPlayerID ) then
			-- 当前玩家被批准
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGID]		= nArmyGroupID;
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGName]		= szAGName;
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition]	= nPosition;
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_CtbtToday]	= 0;
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_CtbtTotal]	= 0;
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]	= {};
			if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
				CreateOrJoinArmyGroup.CloseUI();
				CommonDlgNew.ShowYesDlg( SZ_ENTRY_STRING.."“"..szAGName.."”", nil, nil, 3 );
			end
		else
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				if ( p.tAGApplicantList ~= nil ) then
					for i, v in pairs(p.tAGApplicantList) do
						if ( nPlayerID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
							table.remove( p.tAGApplicantList, i );
							break;
						end
					end
					Solicit.RefreshApplicantList( p.tAGApplicantList );
				end
				if ( p.tAGMemberList ~= nil ) then
					table.insert( p.tAGMemberList, tMember );
					ArmyGroup.RefreshMemberlist( p.tAGMemberList, nArmyGroupID );
				end
				if ( nUserID == nSenderID ) then--
    				CloseLoadBar();--
    			end
			end
		end
	else
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 拒绝某玩家加入本军团的申请
function p.SendMsgRefuseApplication( nPlayerID )
	LogInfo( "MsgArmyGroup: SendMsgRefuseApplication:%d",nPlayerID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_RefuseApplication );
	netdata:WriteInt( nPlayerID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 某玩家被拒绝加入本军团
function p.HandleMsgArmyRefuseApplication( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgArmyRefuseApplication" );
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nArmyGroupID	= tNetDataPackete:ReadInt();
		local nPlayerID		= tNetDataPackete:ReadInt();	-- 被拒绝的玩家
		local nSenderID		= tNetDataPackete:ReadInt();	-- 执行拒绝操作的玩家ID
		local nUserID		= GetPlayerId();
		--LogInfo( "MsgArmyGroup: nArmyGroupID:%d, nPlayerID:%d, nSenderID:%d, nUserID:%d,",nArmyGroupID,nPlayerID,nSenderID,nUserID );
		if ( nUserID == nPlayerID ) then
			-- 当前玩家被拒绝
			for i, v in pairs(p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]) do
				if ( nArmyGroupID == v ) then
					table.remove( p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList], i );
					break;
				end
			end
			if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
				CreateOrJoinArmyGroup.RefreshApplyList();
			end
		else
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				if ( p.tAGApplicantList ~= nil ) then
					for i, v in pairs(p.tAGApplicantList) do
						if ( nPlayerID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
							table.remove( p.tAGApplicantList, i );
							break;
						end
					end
					Solicit.RefreshApplicantList( p.tAGApplicantList );
				end
			end
			if ( nUserID == nSenderID ) then--
    			CloseLoadBar();--
    		end
		end
	else
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 踢人
function p.SendMsgDismiss( nPlayerID )
	LogInfo( "MsgArmyGroup: SendMsgDismiss:%d",nPlayerID );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_Dismiss );
	netdata:WriteInt( nPlayerID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 某玩家被踢--
function p.HandleMsgBeDismiss( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgBeDismiss" );
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nPlayerID	= tNetDataPackete:ReadInt();	-- 被踢的玩家ID
		local nSenderID	= tNetDataPackete:ReadInt();	-- 执行踢人操作的玩家ID
		local nUserID	= GetPlayerId();
		if ( nUserID == nPlayerID ) then
			-- 当前玩家被踢
			local szAGName	= p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGName];
			p.tUserInfor = {};
			p.tUserInfor[nUserID] = {};
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]	= {};
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				ArmyGroup.CloseUI();
			end
			CommonDlgNew.ShowYesDlg( SZ_DISMISS_STRING.."“"..szAGName.."”", nil, nil, 3 );
		else
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				for i, v in pairs(p.tAGMemberList) do
					if ( nPlayerID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
						table.remove( p.tAGMemberList, i );
						local nArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
						ArmyGroup.RefreshMemberlist( p.tAGMemberList, nArmyGroupID );
						break;
					end
				end
			end
			if ( nUserID == nSenderID ) then--
    			CloseLoadBar();--
    		end
		end
	else
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 成为某军团成员了--
--function p.HandleMsgBeMember( tNetDataPackete )
--	LogInfo( "MsgArmyGroup: HandleMsgBeMember" );
--	if IsUIShow( NMAINSCENECHILDTAG.CreateOrJoinArmyGroup ) then
--		CreateOrJoinArmyGroup.CloseUI();
--	end
--	local szAGName	= "";
--	CommonDlgNew.ShowYesDlg( SZ_ENTRY_STRING.."“"..szAGName.."”", nil, nil, 3 );
--end

---------------------------------------------------
-- 退出军团
function p.SendMsgQuit()
	LogInfo( "MsgArmyGroup: SendMsgQuit" );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_Quit );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 退出军团成功
function p.HandleMsgQuit( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgQuit" );
	local nFlag			= tNetDataPackete:ReadByte();
	local nPlayerID		= tNetDataPackete:ReadInt();
	if ( nFlag == 0 ) then
		local nUserID		= GetPlayerId();
		if ( nPlayerID == nUserID ) then
			local szAGName		= p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGName];
			p.tUserInfor = {};
			p.tUserInfor[nUserID] = {};
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]	= {};
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				ArmyGroup.CloseUI();
			end
			CommonDlgNew.ShowYesDlg( SZ_QUIT_STRING.."“"..szAGName.."”", nil, nil, 3 );
			CloseLoadBar();--
		else
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				for i, v in pairs(p.tAGMemberList) do
					if ( nPlayerID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
						table.remove( p.tAGMemberList, i );
						local nArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
						ArmyGroup.RefreshMemberlist( p.tAGMemberList, nArmyGroupID );
						break;
					end
				end
			end
		end
	else
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 设置公告
function p.SendMsgSetNotice( szNotice )
	LogInfo( "MsgArmyGroup: SendMsgSetNotice:"..szNotice );
	if ( szNotice == nil ) then
		return false;
	end
	if ( szNotice == "" ) then
		szNotice = " ";
	end
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_SetNotice );
	--netdata:WriteInt( nArmyGroupID );
	netdata:WriteStr( szNotice );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 设置公告
function p.HandleMsgSetNotice( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgSetNotice" );
	CloseLoadBar();--
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nSenderID	= tNetDataPackete:ReadInt();	-- 执行拒绝操作的玩家ID
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshEditNotice();
		end
	else
		CommonDlgNew.ShowYesDlg( tArmyGroupErrorString[nFlag], nil, nil, 3 );
	end
end

---------------------------------------------------
-- 军团信息更新
function p.HandleMsgAGUpgrade( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgAGUpgrade" );
	local nArmyGroupID		= tNetDataPackete:ReadInt();
	if ( ( p.tAGInformation ~= nil ) and ( p.tAGInformation.nArmyGroupID == nArmyGroupID ) ) then
		local nUpgradeAction	= tNetDataPackete:ReadByte();
		LogInfo( "MsgArmyGroup: nArmyGroupID:%d, nUpgradeAction:%d",nArmyGroupID,nUpgradeAction );
		if ( nUpgradeAction == AGUpgradeAction.AGUA_Legatus ) then
			local nLegatusID	= tNetDataPackete:ReadInt();
			local nLegatusName	= tNetDataPackete:ReadUnicodeString();
			p.tAGInformation.szOName = nLegatusName;
		elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Member ) then
			local nMbrAmount	= tNetDataPackete:ReadInt();
			p.tAGInformation.nMember = nMbrAmount;
		elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Notice ) then
			local szNotice		= tNetDataPackete:ReadUnicodeString();
			p.tAGInformation.szNotice = szNotice;
		elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Level ) then
			local nLevel		= tNetDataPackete:ReadByte();
			local nExp			= tNetDataPackete:ReadInt();
			p.tAGInformation.nLevel = nLevel;
			p.tAGInformation.nExperience = nExp;
			p.tAGInformation.nExpNextLevel = p.GetUpgradeExp( nLevel );
		LogInfo( "MsgArmyGroup: nLevel:%d, nExperience:%d, nExpNextLevel:%d",nLevel,nExp,p.tAGInformation.nExpNextLevel );
		elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Ranking ) then
			local nRanking		= tNetDataPackete:ReadShort();
			p.tAGInformation.nRanking = nRanking;
		elseif ( nUpgradeAction == AGUpgradeAction.AGUA_Experience ) then
			local nExp			= tNetDataPackete:ReadInt();
			p.tAGInformation.nExperience = nExp;
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshInformation( p.tAGInformation );
		end
	end
end

---------------------------------------------------
-- 任命某玩家为副军团长
function p.SendMsgAppointDeputy( nPlayerID )
	LogInfo( "MsgArmyGroup: SendMsgAppointDeputy" );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_AppointDeputy );
	--netdata:WriteInt( nArmyGroupID );
	netdata:WriteInt( nPlayerID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 某玩家被任命副军团长职务
function p.HandleMsgAppointDeputy( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgAppointDeputy" );
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nPlayerID	= tNetDataPackete:ReadInt();
		local nSenderID	= tNetDataPackete:ReadInt();
		local nUserID	= GetPlayerId();
		local nArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
		if ( nUserID == nPlayerID ) then
			-- 当前玩家被任职
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition]	= ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS;
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				ArmyGroup.RefreshForPermissionChange();
			end
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			for i, v in pairs(p.tAGMemberList) do
				if ( nPlayerID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
					p.tAGMemberList[i][ArmyGroupMemberIndex.AGMI_POSITION] = ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS;
					ArmyGroup.RefreshMemberlist( p.tAGMemberList, nArmyGroupID );
					break;
				end
			end
		end
		if ( nUserID == nSenderID ) then--
    		CloseLoadBar();--
    	end
	else
        CommonDlgNew.ShowYesDlg( tArmyGroupErrorString[nFlag], nil, nil, 3 );
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 发送解除某玩家副军团长职务
function p.SendMsgRemovalDeputy( nPlayerID )
	LogInfo( "MsgArmyGroup: SendMsgRemovalDeputy" );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_RemovalDeputy );
	--netdata:WriteInt( nArmyGroupID );
	netdata:WriteInt( nPlayerID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 某玩家被解除副军团长职务
function p.HandleMsgRemovalDeputy( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgRemovalDeputy" );
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nPlayerID	= tNetDataPackete:ReadInt();
		local nSenderID	= tNetDataPackete:ReadInt();
		local nUserID	= GetPlayerId();
		if ( nUserID == nPlayerID ) then
			-- 当前玩家被解职
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition]	= ArmyGroupPositionGrade.AGPG_NONE;
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				ArmyGroup.RefreshForPermissionChange();
			end
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			for i, v in pairs(p.tAGMemberList) do
				if ( nPlayerID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
					p.tAGMemberList[i][ArmyGroupMemberIndex.AGMI_POSITION] = ArmyGroupPositionGrade.AGPG_NONE;
					local nArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
					ArmyGroup.RefreshMemberlist( p.tAGMemberList, nArmyGroupID );
					break;
				end
			end
		end
		if ( nUserID == nSenderID ) then--
    		CloseLoadBar();--
    	end
	else
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 被委任副军团长职位

---------------------------------------------------
-- 被解除副军团长职位

---------------------------------------------------
-- 禅让军团长--
function p.SendMsgAbdicate( nPlayerID )
	LogInfo( "MsgArmyGroup: SendMsgAbdicate" );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_Abdicate );
	--netdata:WriteInt( nArmyGroupID );
	netdata:WriteInt( nPlayerID );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 禅让成功(成为普通成员)--军团长变更
function p.HandleMsgAbdicate( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgAbdicate" );
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nPreLegatusID	= tNetDataPackete:ReadInt();
		local nCurLegatusID	= tNetDataPackete:ReadInt();
		local nCause		= tNetDataPackete:ReadByte();
		local nUserID		= GetPlayerId();
		if ( nUserID == nPreLegatusID ) then
			-- 当前玩家曾为军团长
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition]	= ArmyGroupPositionGrade.AGPG_NONE;
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				ArmyGroup.RefreshForPermissionChange();
    			CloseLoadBar();--
			end
		end
		if ( nUserID == nCurLegatusID ) then
			-- 当前玩家成为军团长
			p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition]	= ArmyGroupPositionGrade.AGPG_LEGATUS;
			if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
				ArmyGroup.RefreshForPermissionChange();
			end
		end
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			for i, v in pairs(p.tAGMemberList) do
				if ( nPreLegatusID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
					p.tAGMemberList[i][ArmyGroupMemberIndex.AGMI_POSITION] = ArmyGroupPositionGrade.AGPG_NONE;
				end
				if ( nCurLegatusID == v[ArmyGroupMemberIndex.AGMI_USERID] ) then
					p.tAGMemberList[i][ArmyGroupMemberIndex.AGMI_POSITION] = ArmyGroupPositionGrade.AGPG_LEGATUS;
				end
			end
			local nArmyGroupID = MsgArmyGroup.GetUserArmyGroupID( nUserID );
			ArmyGroup.RefreshMemberlist( p.tAGMemberList, nArmyGroupID );
		end
	else
    	CloseLoadBar();--
	end
end

---------------------------------------------------
-- 成为军团长（禅让，军团长离团，军团长持久不在线）
--function p.HandleMsgBeLegatus( tNetDataPackete )
--	LogInfo( "MsgArmyGroup: HandleMsgBeLegatus" );
--end

---------------------------------------------------
-- 获得仓库
function p.SendMsgGetStorage( nArmyGroupID )
	LogInfo( "MsgArmyGroup: SendMsgGetStorage" );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_GetStorage );
	netdata:WriteInt( nArmyGroupID );
	SendMsg( netdata );
	netdata:Free();
	return true;
end

---------------------------------------------------
-- 仓库
function p.HandleMsgGetStorage( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgGetStorage" );
	local nAGID			= tNetDataPackete:ReadInt();
	local nPacketFlag	= tNetDataPackete:ReadByte();
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
		p.tStorage = {};
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		p.tStorage = {};
	end
	local nAmount = tNetDataPackete:ReadShort();
	for i=1, nAmount do
		local nItemType	= tNetDataPackete:ReadInt();
		local nAmount	= tNetDataPackete:ReadInt();
		local tItem = {};
		tItem[1] = nItemType;
		tItem[2] = nAmount;
		table.insert( p.tStorage, tItem );
	end
	if ( nPacketFlag == PacketFlag.PF_BEGIN ) then
	elseif ( nPacketFlag == PacketFlag.PF_CONTINUE ) then
	elseif ( nPacketFlag == PacketFlag.PF_END ) then
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshStorage( p.tStorage );
		end
	elseif ( nPacketFlag == PacketFlag.PF_SINGLE ) then
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshStorage( p.tStorage );
		end
	end
end

---------------------------------------------------
-- 分配
function p.SendMsgDelivery( nPlayerID, nItemType, nAmount )
	LogInfo( "MsgArmyGroup: SendMsgGetStorage" );
	local netdata = createNDTransData(NMSG_Type._MSG_ARMYGROUP);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteByte( ArmyGroupMsgAction.AGMA_Delivery );
	netdata:WriteInt( nPlayerID );
	netdata:WriteInt( nItemType );
	netdata:WriteInt( nAmount );
	SendMsg( netdata );
	netdata:Free();
    ShowLoadBar();--
	return true;
end

---------------------------------------------------
-- 分配
function p.HandleMsgDelivery( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgDelivery" );
    CloseLoadBar();--
	local nFlag			= tNetDataPackete:ReadByte();
	if ( nFlag == 0 ) then
		local nLegatusID	= tNetDataPackete:ReadInt();
		local nTargetID		= tNetDataPackete:ReadInt();
		local nItemType		= tNetDataPackete:ReadInt();
		local nAmount		= tNetDataPackete:ReadInt();
		if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
			ArmyGroup.RefreshDelivery( );
		end
	else
		CommonDlgNew.ShowYesDlg( tArmyGroupErrorString[nFlag], nil, nil, 3 );
	end
end
	
---------------------------------------------------
-- 玩家信息
function p.UserInformation( tNetDataPackete )
	LogInfo( "MsgArmyGroup: UserInformation" );
	-- 设置，设置
	local nUserID	= tNetDataPackete:ReadInt();
	local nStatus	= tNetDataPackete:ReadByte();
	p.ClearBuffer();
	p.tUserInfor = {};
	p.tUserInfor[nUserID] = {};
	p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]	= {};
	--p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGStatus]	= nStatus;
	LogInfo( "MsgArmyGroup: nUserID:%d, nStatus:%d", nUserID,nStatus );
	if ( ArmyGroupShipStatus.AGMSS_NONE == nStatus ) then
	elseif ( ArmyGroupShipStatus.AGMSS_APPLY == nStatus ) then
		local nAmount = tNetDataPackete:ReadInt();
		LogInfo( "MsgArmyGroup: ArmyGroupIDListAmount:%d", nAmount );
		local tArmyGroupIDList = {};
		for i = 1, nAmount do
			local nArmyGroupID = tNetDataPackete:ReadInt();
			table.insert( p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList], nArmyGroupID );
		end
		
		--local szIDList = "";
		--for i, v in ipairs(p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_ApplyList]) do
		--	szIDList = szIDList .. v .. ", ";
		--end
		--LogInfo( "MsgArmyGroup: ApplyIDList:" .. szIDList );
	elseif ( ArmyGroupShipStatus.AGMSS_MEMBER == nStatus ) then
		local nAGID		= tNetDataPackete:ReadInt();
		local nPosition	= tNetDataPackete:ReadByte();
		local szAGName	= tNetDataPackete:ReadUnicodeString();
		--local nContributionToday	= tNetDataPackete:ReadInt();
		--local nContributionTotal	= tNetDataPackete:ReadInt();
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGID]		= nAGID;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGName]		= szAGName;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_AGPosition]	= nPosition;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_CtbtToday]	= 0;
		p.tUserInfor[nUserID][UserArmyGroupAttrIndex.UAGAI_CtbtTotal]	= 0;
		LogInfo( "MsgArmyGroup: nAGID:%d, szAGName:%s, nPosition:%d", nAGID,szAGName,nPosition );
	end
	
end

---------------------------------------------------
function p.HandleNetMessage( tNetDataPackete )
	--LogInfo( "MsgArmyGroup: HandleNetMessage" );
	local nActionID = tNetDataPackete:ReadByte();
	LogInfo( "MsgArmyGroup: HandleNetMessage nActionID:%d",nActionID );
	if ( nActionID == ArmyGroupMsgAction.AGMA_ArmyGroupList ) then
		p.HandleMsgArmyGroupList( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_CreateArmyGroup ) then
		p.HandleMsgCreateArmyGroup( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_Information ) then
		p.HandleMsgArmyGroupInformation( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_MemberList ) then
		p.HandleMsgArmyGroupMemberList( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_ApplicantList ) then
		p.HandleMsgArmyGroupApplicantList( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_AcceptApplication ) then
		p.HandleMsgArmyAcceptApplication( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_RefuseApplication ) then
		p.HandleMsgArmyRefuseApplication( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_Quit ) then
		p.HandleMsgQuit( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_Dismiss ) then
		p.HandleMsgBeDismiss( tNetDataPackete );
	--elseif ( nActionID == ArmyGroupMsgAction.AGMA_BeMember ) then
	--	p.HandleMsgBeMember( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_AppointDeputy ) then
		p.HandleMsgAppointDeputy( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_RemovalDeputy ) then
		p.HandleMsgRemovalDeputy( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_Abdicate ) then
		p.HandleMsgAbdicate( tNetDataPackete );
	--elseif ( nActionID == ArmyGroupMsgAction.AGMA_BeLegatus ) then
	--	p.HandleMsgBeLegatus( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_ApplyJion ) then
		p.HandleMsgJoinArmyGroupApplication( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_CancelApply ) then
		p.HandleMsgCancelApply( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_SetNotice ) then
		p.HandleMsgSetNotice( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_AGUpgrade ) then
		p.HandleMsgAGUpgrade( tNetDataPackete );
    	elseif ( nActionID == ArmyGroupMsgAction.AGMA_GetStorage ) then
		p.HandleMsgGetStorage( tNetDataPackete );
	elseif ( nActionID == ArmyGroupMsgAction.AGMA_Delivery ) then
		p.HandleMsgDelivery( tNetDataPackete );
	end
end


---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_AG_USERINFO, "MsgArmyGroup.UserInformation", p.UserInformation );
RegisterNetMsgHandler( NMSG_Type._MSG_ARMYGROUP, "MsgArmyGroup.HandleNetMessage", p.HandleNetMessage );


--#################################################
-- nTime, szOName, szTName, nItemType, nItemAmount
DistributeRecordIndex = {
	DRI_TIME		= 1,
	DRI_ONAME		= 2,	-- 操作者名字
	DRI_TNAME		= 3,	-- 目标者名字
	DRI_OID			= 4,	-- 操作者ID
	DRI_TID			= 5,	-- 目标者ID
	DRI_ITEMTYPE	= 6,
	DRI_ITEMAMOUNT	= 7,
};

---------------------------------------------------
-- 获取分配记录
function p.SendMsgGetDistributeHistory( usFrom, usCount )
	LogInfo( "MsgArmyGroup: SendMsgGetDistributeHistory" );
	local netdata = createNDTransData(NMSG_Type._MSG_GetDistributeHistory);
	if nil == netdata then
		LogInfo("memory is not enough");
		return false;
	end
	netdata:WriteShort( usFrom );
	netdata:WriteShort( usCount );
	SendMsg( netdata );
	netdata:Free();
	return true;
end

---------------------------------------------------
-- 分配记录消息
function p.HandleMsgDistributeHistory( tNetDataPackete )
	LogInfo( "MsgArmyGroup: HandleMsgDistributeHistory" );
	local unFrom		= tNetDataPackete:ReadShort();
	local usCount		= tNetDataPackete:ReadShort();
	local btIsLasted	= tNetDataPackete:ReadByte();
	LogInfo( "MsgArmyGroup: unFrom:%d, usCount:%d, btIsLasted:%d",unFrom,usCount,btIsLasted );
	local tRecordList   = {};
	for i=1, usCount do
		local nLegatusID	= tNetDataPackete:ReadInt();
		local nTargetID		= tNetDataPackete:ReadInt();
		local nItemType		= tNetDataPackete:ReadInt();
		local nItemAmount	= tNetDataPackete:ReadInt();
		local nTime			= tNetDataPackete:ReadInt();
		local szOName		= tNetDataPackete:ReadUnicodeString();--操作人员名字
		local szTName		= tNetDataPackete:ReadUnicodeString();--目标人员名字
		--LogInfo( "MsgArmyGroup: nTime:%d, szOName:%s, szTName:%s, nItemType:%d nItemAmount:%d ",nTime,szOName,szTName,nItemType,nItemAmount );
        local tRecord		= {};
		tRecord[DistributeRecordIndex.DRI_OID] 			= nLegatusID;
		tRecord[DistributeRecordIndex.DRI_TID] 			= nTargetID;
		tRecord[DistributeRecordIndex.DRI_ITEMTYPE]		= nItemType;
		tRecord[DistributeRecordIndex.DRI_ITEMAMOUNT]	= nItemAmount;
		tRecord[DistributeRecordIndex.DRI_TIME]			= nTime;
		tRecord[DistributeRecordIndex.DRI_ONAME]		= szOName;
		tRecord[DistributeRecordIndex.DRI_TNAME]		= szTName;
		table.insert( tRecordList, tRecord );
	end
	if IsUIShow( NMAINSCENECHILDTAG.ArmyGroup ) then
		DistributeRecordDlg.Callback_FillRecordList( tRecordList, btIsLasted );
	end
end

---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_DistributeHistory, "MsgArmyGroup.HandleMsgDistributeHistory", p.HandleMsgDistributeHistory );
