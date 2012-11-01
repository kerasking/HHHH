---------------------------------------------------
--描述: 网络消息处理(培养)消息处理及其逻辑
--时间: 2012.7.13
--作者: Guosen
---------------------------------------------------

MsgRoleTrain = {}
local p = MsgRoleTrain;
local _G = _G;

p.mUIListener = nil;
--{ { nTrainID, nPetID, nTrainType, nEndtime, nEndMoment }, ... }
p.tTrainPet = {};


---------------------------------------------------
-- 响应更新培养信息列表消息
function p.ProcessTrainInfoList( tNetData )
    CloseLoadBar();
	--LogInfo( "MsgRoleTrain: ProcessTrainInfoList()" );
	local nCount	= tNetData:ReadByte();
	LogInfo( "MsgRoleTrain: ProcessTrainInfoList() nCount:%d",nCount );
	p.tTrainPet = {};
	if ( nCount > 0 ) then
		for i = 1, nCount do
			local tRecord = {};
			tRecord.nTrainID		= tNetData:ReadInt();	-- 训练表里的ID
			tRecord.nPetID			= tNetData:ReadInt();	-- 武将ID
			tRecord.nTrainType		= tNetData:ReadByte();	-- 训练类型
			tRecord.nEndTime		= tNetData:ReadInt();	-- 到训练结束剩余时间
			tRecord.nPickUpTime		= tNetData:ReadInt();	-- 最近一次提取经验的时间点，在(0～24H)里的某个位置
			tRecord.nEndMoment		= tRecord.nEndTime + GetCurrentTime();		-- 训练结束时刻
			table.insert( p.tTrainPet, tRecord );
			--LogInfo( "MsgRoleTrain: ProcessTrainInfoList() nTrainID:%d, nPetID:%d, nTrainType:%d, nEndTime:%d, nPickUpTime:%d",tRecord.nTrainID,tRecord.nPetID,tRecord.nTrainType,tRecord.nEndTime,tRecord.nPickUpTime );
		end
	end
	if ( p.mUIListener ) then
		p.mUIListener( NMSG_Type._MSG_TRAIN_INFO_LIST, p.tTrainPet );
	end
end

---------------------------------------------------
-- 发送开始培养消息
function p.SetMsgStartTrain( nPetID, nTrainType )
	LogInfo( "MsgRoleTrain: SetMsgStartTrain() PetID:%d, TrainType:%d", nPetID, nTrainType );
	local tNetData = createNDTransData( NMSG_Type._MSG_CONFIRM_TRAIN_PET );
	if ( nil == tNetData ) then
		return false;
	end
	tNetData:WriteInt( nPetID );
	tNetData:WriteByte( nTrainType );
	SendMsg( tNetData );
	tNetData:Free();
    ShowLoadBar();
	return true;
end

---------------------------------------------------
-- 发送终止培养消息
function p.SetMsgStopTrain( nPetID )
	LogInfo( "MsgRoleTrain: SetMsgStopTrain() PetID:%d", nPetID );
	for nIndex, tRecord in pairs( p.tTrainPet ) do
		if ( tRecord.nPetID == nPetID ) then
			local tNetData = createNDTransData( NMSG_Type._MSG_END_TRAIN_PET );
			if ( nil == tNetData ) then
				return false;
			end
			tNetData:WriteInt( tRecord.nTrainID );
			SendMsg( tNetData );
			tNetData:Free();
   			ShowLoadBar();
			return true;
		end
	end
	return false;
end

---------------------------------------------------
-- 发送提取经验消息
function p.SetMsgPickUpExp( nPetID )
	LogInfo( "MsgRoleTrain: SetMsgPickUpExp() PetID:%d", nPetID );
	for nIndex, tRecord in pairs( p.tTrainPet ) do
		if ( tRecord.nPetID == nPetID ) then
			local tNetData = createNDTransData( NMSG_Type._MSG_GET_TRAIN_PET_EXP );
			if ( nil == tNetData ) then
				return false;
			end
			tNetData:WriteInt( tRecord.nTrainID );
			SendMsg( tNetData );
			tNetData:Free();
   			ShowLoadBar();
			return true;
		end
	end
	return false;
end

---------------------------------------------------
-- 获得训练记录
function p.GetPetTrainRecord( nPetID )
	for nIndex, tRecord in pairs( p.tTrainPet ) do
		if ( tRecord.nPetID == nPetID ) then
			return tRecord;
		end
	end
	return nil;
end

---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_TRAIN_INFO_LIST, "p.ProcessTrainInfoList", p.ProcessTrainInfoList );


-----------------------------------------------------
----描述: 网络消息处理(培养)消息处理及其逻辑
----时间: 2012.3.11
----作者: wjl
-----------------------------------------------------
--
--MsgRoleTrain = {}
--local p = MsgRoleTrain;
--local _G = _G;
--
--p.mUIListener = nil;
--
----=====网络
----==获取培养
--
----4506
--function p.sendTrainGet(id)
--	if not CheckN(id) then
--		return false;
--	end
--	
--	local netdata = createNDTransData(NMSG_Type._MSG_ROLE_TRAIN_GET);
--	if nil == netdata then
--		return false;
--	end
--	netdata:WriteInt(id);
--	
--	SendMsg(netdata);
--	
--	netdata:Free();
--	
--	LogInfo("send id[%d]", id);
--	return true;
--end
--
--function p.processTrainGet(netdata)
--	
--	local t = {};
--	t.id	= netdata:ReadInt();
--	t.phy	= netdata:ReadShort();
--	t.skl	= netdata:ReadShort();
--	t.mag	= netdata:ReadShort();
--	LogInfo("process 4506 id:%d", id)
--	
--	if (p.mUIListener) then
--		p.mUIListener( NMSG_Type._MSG_ROLE_TRAIN_GET, t);
--	end
--end
--
----培养 4507
--function p.sendTrain(id, type)
--	if not CheckN(id) then
--		return false;
--	end
--	
--	if not CheckN(type) then
--		return false;
--	end
--	
--	local netdata = createNDTransData(NMSG_Type._MSG_ROLE_TRAIN_TRAIN);
--	if nil == netdata then
--		return false;
--	end
--	netdata:WriteInt(id);
--	netdata:WriteByte(type);
--	
--	SendMsg(netdata);
--	
--	netdata:Free();
--	
--	LogInfo("send id[%d],type[%d]", id, type);
--	return true;
--end
--
----
--function p.processTrain(netdata)
--	local t = {};
--	t.id	= netdata:ReadInt();
--	t.phy	= netdata:ReadShort();
--	t.skl	= netdata:ReadShort();
--	t.mag	= netdata:ReadShort();
--	
--	if (p.mUIListener) then
--		p.mUIListener( NMSG_Type._MSG_ROLE_TRAIN_TRAIN, t);
--	end
--end
--
--
----4508
--function p.sendTrainCommit(id)
--	if not CheckN(id) then
--		return false;
--	end
--	
--	local netdata = createNDTransData(NMSG_Type._MSG_ROLE_TRAIN_COMMIT);
--	if nil == netdata then
--		return false;
--	end
--	netdata:WriteInt(id);
--	
--	SendMsg(netdata);
--	
--	netdata:Free();
--	
--	LogInfo("send id[%d]", id);
--	return true;
--end
--
--function p.processTrainCommit(netdata)
--	
--	local t = {};
--	t.id	= netdata:ReadInt();
--	t.phy	= netdata:ReadShort();
--	t.skl	= netdata:ReadShort();
--	t.mag	= netdata:ReadShort();
--	LogInfo("process 4506 id:%d, phy:%d, skl:%d, mag:%d", t.id, t.phy, t.skl, t.mag)
--	p.saveTrainPhy(t.id, t.phy);
--	p.saveTrainSkl(t.id, t.skl);
--	p.saveTrainMag(t.id, t.mag);
--	
--	if (p.mUIListener) then
--		p.mUIListener( NMSG_Type._MSG_ROLE_TRAIN_COMMIT, t);
--	end
--end
--
----======消息注册
----==悟道购买
--RegisterNetMsgHandler(NMSG_Type._MSG_ROLE_TRAIN_GET, "p.processTrainGet", p.processTrainGet);
--RegisterNetMsgHandler(NMSG_Type._MSG_ROLE_TRAIN_TRAIN, "p.processTrain", p.processTrain);
--RegisterNetMsgHandler(NMSG_Type._MSG_ROLE_TRAIN_COMMIT, "p.processTrainCommit", p.processTrainCommit);
--
----保存 
--function p.saveTrainPhy(nPetId, nValue)
--	RolePet.SetPetInfoN(nPetId, PET_ATTR.PET_ATTR_PHY_FOSTER, nValue);
--end
--
--function p.saveTrainSkl(nPetId, nValue)
--	RolePet.SetPetInfoN(nPetId, PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER, nValue);
--end
--
--function p.saveTrainMag(nPetId, nValue)
--	RolePet.SetPetInfoN(nPetId, PET_ATTR.PET_ATTR_MAGIC_FOSTER, nValue);
--end
--
--
--	
	