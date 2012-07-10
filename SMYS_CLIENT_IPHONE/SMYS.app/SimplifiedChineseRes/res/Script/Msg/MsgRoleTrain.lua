---------------------------------------------------
--描述: 网络消息处理(培养)消息处理及其逻辑
--时间: 2012.3.11
--作者: wjl
---------------------------------------------------

MsgRoleTrain = {}
local p = MsgRoleTrain;
local _G = _G;

p.mUIListener = nil;

--=====网络
--==获取培养

--4506
function p.sendTrainGet(id)
	if not CheckN(id) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_ROLE_TRAIN_GET);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send id[%d]", id);
	return true;
end

function p.processTrainGet(netdata)
	
	local t = {};
	t.id	= netdata:ReadInt();
	t.phy	= netdata:ReadShort();
	t.skl	= netdata:ReadShort();
	t.mag	= netdata:ReadShort();
	LogInfo("process 4506 id:%d", id)
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_ROLE_TRAIN_GET, t);
	end
end

--培养 4507
function p.sendTrain(id, type)
	if not CheckN(id) then
		return false;
	end
	
	if not CheckN(type) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_ROLE_TRAIN_TRAIN);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	netdata:WriteByte(type);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send id[%d],type[%d]", id, type);
	return true;
end

--
function p.processTrain(netdata)
	local t = {};
	t.id	= netdata:ReadInt();
	t.phy	= netdata:ReadShort();
	t.skl	= netdata:ReadShort();
	t.mag	= netdata:ReadShort();
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_ROLE_TRAIN_TRAIN, t);
	end
end


--4508
function p.sendTrainCommit(id)
	if not CheckN(id) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_ROLE_TRAIN_COMMIT);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send id[%d]", id);
	return true;
end

function p.processTrainCommit(netdata)
	
	local t = {};
	t.id	= netdata:ReadInt();
	t.phy	= netdata:ReadShort();
	t.skl	= netdata:ReadShort();
	t.mag	= netdata:ReadShort();
	LogInfo("process 4506 id:%d, phy:%d, skl:%d, mag:%d", t.id, t.phy, t.skl, t.mag)
	p.saveTrainPhy(t.id, t.phy);
	p.saveTrainSkl(t.id, t.skl);
	p.saveTrainMag(t.id, t.mag);
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_ROLE_TRAIN_COMMIT, t);
	end
end

--======消息注册
--==悟道购买
RegisterNetMsgHandler(NMSG_Type._MSG_ROLE_TRAIN_GET, "p.processTrainGet", p.processTrainGet);
RegisterNetMsgHandler(NMSG_Type._MSG_ROLE_TRAIN_TRAIN, "p.processTrain", p.processTrain);
RegisterNetMsgHandler(NMSG_Type._MSG_ROLE_TRAIN_COMMIT, "p.processTrainCommit", p.processTrainCommit);

--保存 
function p.saveTrainPhy(nPetId, nValue)
	RolePet.SetPetInfoN(nPetId, PET_ATTR.PET_ATTR_PHY_FOSTER, nValue);
end

function p.saveTrainSkl(nPetId, nValue)
	RolePet.SetPetInfoN(nPetId, PET_ATTR.PET_ATTR_SUPER_SKILL_FOSTER, nValue);
end

function p.saveTrainMag(nPetId, nValue)
	RolePet.SetPetInfoN(nPetId, PET_ATTR.PET_ATTR_MAGICL_FOSTER, nValue);
end


	
	