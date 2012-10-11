---------------------------------------------------
--描述: 网络消息处理(奇术:阵法，功法)消息处理及其逻辑
--时间: 2012.3.1
--作者: wjl
---------------------------------------------------

MsgMagic = {}
local p = MsgMagic;
local _G = _G;

p.mCoolTime2 = nil;
p.mCurrentOpenMatrix = -1;

p.RoleMagicCategory = {
	CMagicInfo		= 0,
	CMatrixList		= 1,
	CMatrixStation	= 2,
	CAttackList		= 3,
	CIDS			= 4,
}

p.RoleMagicType = {
	TMatrixInfo     = 0,
	TMatrixList		= 1,
	TMatrixStation  = 2,
	TAttackList		= 3,
	TAttackInfo		= 4,
	TIDS			= 5,
} 


p.RoleMagicInfo = {
	MATRIX_COUNT		= 0,
	MATRIX_COOL_TIME	= 1,
	ATTACK_COUNT		= 2,
	ATTACK_COOL_TIME	= 3,
};


p.RoleMatrixList = {
	ID			= 1,
	TYPE	=	2,
	LEVEL	=	3,
	S1		=	4,
	S2		=	5,
	S3		=	6,
	S4		=	7,
	S5		=	8,
	S6		=	9,
	S7		=	10,
	S8		=	11,
	S9		=	12,
};

p.RoleMatrixStation = {

	ID		= 0,	
	S1		= 1,
	S2		= 2,
	S3		= 3,
	S4		= 4,
	S5		= 5,
	S6		= 6,
	S7		= 7,
	S8		= 8,
	S9		= 9,
	
};

p.RoleAttackList = {
	ID		= 1,
	TYPE	= 2,
	LEVEL	= 3,
}

p.mUIListener = nil;


--=====逻辑

function p.getCoolTime()
	if p.mCoolTime2 then
		return p.mCoolTime2;
	else 
		p.mCoolTime2 = GetCurrentTime();
	end
	return p.mCoolTime2;
	
end

function p.getCurrentOpenMatrixId() 
	return p.mCurrentOpenMatrix;
end

--== 阵法
function p.getRoleMatrixCount() 
	local ids = p.getMatrixIds();
	
	local count = 0;
	if (ids) then
		count = #ids;
	end
	LogInfo("matrix ids count:%d", count);
	return count, ids;
end


-- 获取阵法:第一返回值为数组，第二返回为数量
-- 阵型升级数据结构参接口
function p.getRoleMatrixList()
	local count,ids = p.getRoleMatrixCount();
	local lst = {};
	for k = 1, count do
		local m = {};
		local i = ids[k];
		
		m.id = p.getRoleMatrixListDataN(i, p.RoleMatrixList.ID);
		m.type = p.getRoleMatrixListDataN(i, p.RoleMatrixList.TYPE);
		m.level = p.getRoleMatrixListDataN(i, p.RoleMatrixList.LEVEL);
		m[1] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S1);
		m[2] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S2);
		m[3] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S3);
		m[4] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S4);
		m[5] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S5);
		m[6] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S6);
		m[7] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S7);
		m[8] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S8);
		m[9] = p.getRoleMatrixListDataN(i, p.RoleMatrixList.S9);
		lst[k] = m;
	end
	
	return lst, count
	
end

function p.setRoleMatrixAdd(m)
	
	local i = m.id;
	
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.ID, m.id);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.TYPE, m.type);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.LEVEL, m.level);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S1, m[1]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S2, m[2]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S3, m[3]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S4, m[4]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S5, m[5]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S6, m[6]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S7, m[7]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S8, m[8]);
	p.setRoleMatrixListDataN(i, p.RoleMatrixList.S9, m[9]);
	
	p.addMatrixId(i)
	
end

function p.setRoleMatrixList(listTable, count)
	
	local lst = listTable;
	for k = 1, count do
		local m = lst[k];
		local i = m.id;
		
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.ID, m.id);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.TYPE, m.type);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.LEVEL, m.level);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S1, m[1]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S2, m[2]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S3, m[3]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S4, m[4]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S5, m[5]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S6, m[6]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S7, m[7]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S8, m[8]);
		p.setRoleMatrixListDataN(i, p.RoleMatrixList.S9, m[9]);
		p.addMatrixId(i)
	end
	
end

-- upgrade
function p.setRoleMatrixUpdate(id, level)
	p.setRoleMatrixListDataN(id, p.RoleMatrixList.LEVEL, level);
	
end

-- coolTime
function p.setMatrixCoolTime(time)
	p.setRoleMatrixInfoDataN(p.RoleMagicInfo.MATRIX_COOL_TIME, time);
end

-- coolTime
function p.getMatrixCoolTime()
	return p.getRoleMatrixInfoDataN(p.RoleMagicInfo.MATRIX_COOL_TIME);
end

function p.getRoleMatrixStation()
	local m = {};
	m.id = p.getRoleMatrixStationDataN( p.RoleMatrixStation.ID);
	m[1] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S1);
	m[2] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S2);
	m[3] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S3);
	m[4] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S4);
	m[5] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S5);
	m[6] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S6);
	m[7] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S7);
	m[8] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S8);
	m[9] = p.getRoleMatrixStationDataN( p.RoleMatrixStation.S9);
	
	return m;
	
end

--设置当前矩阵
function p.setRoleMatixStation(m)
	
	if not m then
		return;
	end
	
	local index = m.id;
	
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S1,  m[1]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S2,  m[2]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S3,  m[3]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S4,  m[4]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S5,  m[5]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S6,  m[6]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S7,  m[7]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S8,  m[8]);
	p.setRoleMatrixListDataN(index, p.RoleMatrixList.S9,  m[9]);
	p.addMatrixId(index);
end

--==功法

function p.getRoleAttackCount() 
	local ids = p.getAttackIds()
	local count = 0;
	if (ids) then
		count = #ids;
	end
	LogInfo("p.getRoleAttackCount:%d", count);
	return count, ids;
end

function p.getRoleAttackList()
	local count,ids = p.getRoleAttackCount();
	local lst = {};
	for k = 1, count do
		local m = {};
		local i = ids[k];
		m.id = p.getRoleAttackListDataN(i, p.RoleAttackList.ID);
		m.type = p.getRoleAttackListDataN(i, p.RoleMatrixList.TYPE);
		m.level = p.getRoleAttackListDataN(i, p.RoleMatrixList.LEVEL);
		LogInfo("attack id:%d,type:%d,level:%d", m.id, m.type, m.level);
		lst[k] = m;
	end
	
	return lst, count
	
end

function p.setRoleAttackAdd(m)
	
	local i = m.id;
	p.setRoleAttackListDataN(i, p.RoleAttackList.ID, m.id);
	p.setRoleAttackListDataN(i, p.RoleAttackList.TYPE, m.type);
	p.setRoleAttackListDataN(i, p.RoleAttackList.LEVEL, m.level);
	p.addAttackId(i);
end

function p.setRoleAttackList(listTable, count)
	
	local lst = listTable;
	for k = 1, count do
		local m = lst[k];
		local i = m.id;
		p.setRoleAttackListDataN(i, p.RoleAttackList.ID, m.id);
		p.setRoleAttackListDataN(i, p.RoleAttackList.TYPE, m.type);
		p.setRoleAttackListDataN(i, p.RoleAttackList.LEVEL, m.level);
		p.addAttackId(i);
	end
end

-- upgrade
function p.setRoleAttackUpdate(id, level)
	
	p.setRoleAttackListDataN(id, p.RoleAttackList.LEVEL, level);

	
end

-- coolTime
function p.setAttackCoolTime(time)
	--p.setRoleAttackInfoDataN(p.RoleMagicInfo.ATTACK_COOL_TIME, time);
	p.setMatrixCoolTime(time);  -- 两个时间一致
end

-- coolTime
function p.getAttackCoolTime()
	--return p.getRoleAttackInfoDataN(p.RoleMagicInfo.ATTACK_COOL_TIME);
	return p.getMatrixCoolTime(); -- 两个时间一致
end

--===== 网络

--== 阵法
--升级(4502)
function p.sendMatrixUpgrade(id)
	if not CheckN(id) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_MATRIX_UPGRADED);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send id[%d] ", id);
	return true;
end

--重置时间(4503)
function p.sendMatrixCoolDown()
	
	local netdata = createNDTransData(NMSG_Type._MSG_MATRIX_COOLDOWN);
	if nil == netdata then
		return false;
	end
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send send Cool down");
	return true;
end

--布阵(4504 )
function p.sendSetStation(m)
	if (m == nil or not CheckN(m.id)) then
		LogInfo("p.sendSetStation:m is nil");
		return;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_MATRIX_STATION);
	if nil == netdata then
		return false;
	end
	
	LogInfo("sendSetStation id:%d" , m.id);
	for i = 1, 9 do
		LogInfo("sendSetStation m[%d] = %d" , i, m[i]);
	end

	netdata:WriteInt(m.id);
	netdata:WriteInt(m[1]);
	netdata:WriteInt(m[2]);
	netdata:WriteInt(m[3]);
	netdata:WriteInt(m[4]);
	netdata:WriteInt(m[5]);
	netdata:WriteInt(m[6]);
	netdata:WriteInt(m[7]);
	netdata:WriteInt(m[8]);
	netdata:WriteInt(m[9]);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send setStation");
	return true;
end

function p.sendMatrixOpen(id)
	local netdata = createNDTransData(NMSG_Type._MSG_MATRIX_STATION_OPEN);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send p.sendMatrixOpen");
	return true;
end

--阵法列表(4500)
function p.processMatrixList(netdata)
	
	LogInfo("process 4500");
	
	local count			= netdata:ReadByte();
	LogInfo(" count:" .. count);
	for i = 1, count do
		local m = {}
		m.id	= netdata:ReadInt();
		m.type		= netdata:ReadInt();
		m.level		= netdata:ReadByte();
		m[1]		= netdata:ReadInt();
		m[2]		= netdata:ReadInt();
		m[3]		= netdata:ReadInt();
		m[4]		= netdata:ReadInt();
		m[5]		= netdata:ReadInt();
		m[6]		= netdata:ReadInt();
		m[7]		= netdata:ReadInt();
		m[8]		= netdata:ReadInt();
		m[9]		= netdata:ReadInt();
		
		LogInfo(" id:" .. m.id);
		LogInfo(" type:" .. m.type);
		LogInfo(" level:" .. m.level);
		LogInfo(" s1:" .. m[1]);
		LogInfo(" s2:" .. m[2]);
		LogInfo(" s3:" .. m[3]);
		LogInfo(" s4:" .. m[4]);
		LogInfo(" s5:" .. m[5]);
		LogInfo(" s6:" .. m[6]);
		LogInfo(" s7:" .. m[7]);
		LogInfo(" s8:" .. m[8]);
		LogInfo(" s9:" .. m[9]);
		
		p.setRoleMatrixAdd(m);
	end
	
	
	return 1;
end

--add
function p.processMatrixAdd(netdata)
	local m = {}
	m.id	= netdata:ReadInt();
	m.type		= netdata:ReadInt();
	m.level		= netdata:ReadByte();
	m[1]		= netdata:ReadInt();
	m[2]		= netdata:ReadInt();
	m[3]		= netdata:ReadInt();
	m[4]		= netdata:ReadInt();
	m[5]		= netdata:ReadInt();
	m[6]		= netdata:ReadInt();
	m[7]		= netdata:ReadInt();
	m[8]		= netdata:ReadInt();
	m[9]		= netdata:ReadInt();
	
	p.setRoleMatrixAdd(m);
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_MATRIX_ADDED, m);
	end
	
end

--upgrade
function p.processMatrixUpgrade(netdata)
	local idv 		= netdata:ReadInt();
	local levelv		= netdata:ReadByte();
	
	LogInfo("4502:%d,%d",idv,levelv);
	p.setRoleMatrixUpdate(idv,levelv);
	
	if (p.mUIListener) then
		local m = {id = idv, level = levelv};
		p.mUIListener(NMSG_Type._MSG_MATRIX_UPGRADED, m);
	end
	
end

function p.processSatationOpen(netdata)
	local idv 		= netdata:ReadInt();
	LogInfo("4505:%d",idv);
	p.mCurrentOpenMatrix = idv;
	local nPlayerId = GetPlayerId();
	SetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_MATRIX,idv);
	if (p.mUIListener) then
		--local m = {id = idv, level = levelv};
		p.mUIListener(NMSG_Type._MSG_MATRIX_STATION_OPEN, idv);
	end
end

--cooldown
function p.processMatrixCoolDown(netdata)
	local time = netdata:ReadInt();
	LogInfo("4503:%d", time);
	p.mCoolTime2 = GetCurrentTime() + time;
	p.setMatrixCoolTime(time);
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_MATRIX_COOLDOWN, time);
	end
end

--Matrix Station
function p.processMatrixStation(netdata)
	
	
	local m = {}
	m.id	= netdata:ReadInt();
	--m.type		= netdata:ReadInt();
	--m.level		= netdata:ReadByte();
	m[1]		= netdata:ReadInt();
	m[2]		= netdata:ReadInt();
	m[3]		= netdata:ReadInt();
	m[4]		= netdata:ReadInt();
	m[5]		= netdata:ReadInt();
	m[6]		= netdata:ReadInt();
	m[7]		= netdata:ReadInt();
	m[8]		= netdata:ReadInt();
	m[9]		= netdata:ReadInt();
		
	p.setRoleMatixStation(m);
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_MATRIX_STATION, m);
	end
	
	return 1;
end

--==功法
function p.sendAttackUpgrade(id)
	if not CheckN(id) then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_ATTACK_UPGRADED);
	if nil == netdata then
		return false;
	end
	netdata:WriteInt(id);
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("send attack id[%d] ", id);
	return true;
end
	
function p.processAttackList(netdata)
	
	LogInfo("process 3510");
	
	local count			= netdata:ReadByte();
	LogInfo(" count:" .. count);
	for i = 1, count do
		local m = {}
		m.id	= netdata:ReadInt();
		m.type		= netdata:ReadInt();
		m.level		= netdata:ReadByte();
		
		LogInfo(" id:" .. m.id);
		LogInfo(" type:" .. m.type);
		LogInfo(" level:" .. m.level);
		
		p.setRoleAttackAdd(m);
	end
	
	return 1;
end

--add
function p.processAttackAdd(netdata)

	LogInfo("process attack add");
	
	local m = {}
	m.id	= netdata:ReadInt();
	m.type		= netdata:ReadInt();
	m.level		= netdata:ReadByte();
	p.setRoleAttackAdd(m);
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_ATTACK_ADDED, m);
	end
	
	return 1;
end

--upgrade
function p.processAttackUpgrade(netdata)
	local idv 		= netdata:ReadInt();
	local levelv		= netdata:ReadByte();
	
	LogInfo("4502:%d,%d",idv,levelv);
	--p.updateRoleAttack(idv,levelv);
	p.setRoleAttackUpdate(idv, levelv);
	if (p.mUIListener) then
		local m = {id = idv, level = levelv};
		p.mUIListener( NMSG_Type._MSG_ATTACK_UPGRADED, m);
	end
	
	return 1;
end

--cooldown
function p.processAttackCoolDown(netdata)
	local time = netdata:ReadInt();
	LogInfo("4503:%d", time);
	p.setAttackCoolTime(time);
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_ATTACK_COOLDOWN, time);
	end
end

--======消息注册
--==阵法
RegisterNetMsgHandler(NMSG_Type._MSG_MATRIX_LIST, "p.processMatrixList", p.processMatrixList);
RegisterNetMsgHandler(NMSG_Type._MSG_MATRIX_STATION_OPEN, "p.processSatationOpen", p.processSatationOpen);
RegisterNetMsgHandler(NMSG_Type._MSG_MATRIX_ADDED, "p.processMatrixAdd", p.processMatrixAdd);
RegisterNetMsgHandler(NMSG_Type._MSG_MATRIX_UPGRADED, "p.processMatrixUpgrade", p.processMatrixUpgrade);
RegisterNetMsgHandler(NMSG_Type._MSG_MATRIX_COOLDOWN, "p.processMatrixCoolDown", p.processMatrixCoolDown);
RegisterNetMsgHandler(NMSG_Type._MSG_MATRIX_STATION, "p.processMatrixStation", p.processMatrixStation);
--==功法
RegisterNetMsgHandler(NMSG_Type._MSG_ATTACK_LIST, "p.processAttackList", p.processAttackList);
RegisterNetMsgHandler(NMSG_Type._MSG_ATTACK_ADDED, "p.processAttackAdd", p.processAttackAdd);
RegisterNetMsgHandler(NMSG_Type._MSG_ATTACK_UPGRADED, "p.processAttackUpgrade", p.processAttackUpgrade);
--RegisterNetMsgHandler(NMSG_Type._MSG_ATTACK_COOLDOWN, "p.processAttackCoolDown", p.processAttackCoolDown);
RegisterNetMsgHandler(NMSG_Type._MSG_ATTACK_COOLDOWN, "p.processMatrixCoolDown", p.processMatrixCoolDown);






--=====本地缓村
--==奇术
function p.getRoleMagicDataN(category, type, typeValue, key) 
	return GetGameDataN(NScriptData.eMagic, category, type, typeValue, key);
end

function p.getRoleMagicDataS(category, type, typeValue, key)
	return GetGameDataS(NScriptData.eMagic, category, type, typeValue, key);
end

function p.setRoleMagicDataN(category, type, typeValue, key, value) 
	SetGameDataN(NScriptData.eMagic, category, type, typeValue, key, value);
end
function p.setRoleMagicDataS(category, type, typeValue, key, value) 
	SetGameDataS(NScriptData.eMagic, category, type, typeValue, key, value);
end

--==阵法

function p.getRoleMatrixInfoDataN(key)
	return p.getRoleMagicDataN(p.RoleMagicCategory.CMagicInfo, p.RoleMagicType.TMatrixInfo, 0, key); 
end
function p.setRoleMatrixInfoDataN(key, value)
	p.setRoleMagicDataN(p.RoleMagicCategory.CMagicInfo, p.RoleMagicType.TMatrixInfo, 0, key, value);
end

function p.getRoleMatrixListDataN(typeValue, key)
	return p.getRoleMagicDataN(p.RoleMagicCategory.CMatrixList, p.RoleMagicType.TMatrixList, typeValue, key); 
end
function p.setRoleMatrixListDataN(typeValue, key, value)
	p.setRoleMagicDataN(p.RoleMagicCategory.CMatrixList, p.RoleMagicType.TMatrixList, typeValue, key, value);
end

function p.getRoleMatrixStationDataN(key)
	return p.getRoleMagicDataN(p.RoleMagicCategory.CMatrixStation, p.RoleMagicType.TMatrixStation, 0, key);
end
function p.setRoleMatrixStationDataN(key, value)
	p.setRoleMagicDataN(p.RoleMagicCategory.CMatrixStation, p.RoleMagicType.TMatrixStation, 0, key, value);
end

function p.addMatrixId(id)
	_G.DelRoleDataId(NScriptData.eMagic, p.RoleMagicCategory.CIDS, p.RoleMagicType.TIDS, 0, 0,id);
	_G.AddRoleDataId(NScriptData.eMagic, p.RoleMagicCategory.CIDS, p.RoleMagicType.TIDS, 0, 0,id);
end

function p.getMatrixIds()
	return _G.GetRoleDataIdTable(NScriptData.eMagic, p.RoleMagicCategory.CIDS, p.RoleMagicType.TIDS, 0, 0);
end

--== 功法

function p.getRoleAttackInfoDataN(key)
	return p.getRoleMagicDataN(p.RoleMagicCategory.CMagicInfo, p.RoleMagicType.TAttackInfo, 0, key); 
end
function p.setRoleAttackInfoDataN(key, value)
	p.setRoleMagicDataN(p.RoleMagicCategory.CMagicInfo, p.RoleMagicType.TAttackInfo, 0, key, value);
end

function p.getRoleAttackListDataN(typeValue, key)
	return p.getRoleMagicDataN(p.RoleMagicCategory.CAttackList, p.RoleMagicType.TAttackList, typeValue, key); 
end
function p.setRoleAttackListDataN(typeValue, key, value)
	p.setRoleMagicDataN(p.RoleMagicCategory.CAttackList, p.RoleMagicType.TAttackList, typeValue, key, value);
end

function p.addAttackId(id)
	_G.DelRoleDataId(NScriptData.eMagic, p.RoleMagicCategory.CIDS, p.RoleMagicType.TIDS, 0, 1,id);
	_G.AddRoleDataId(NScriptData.eMagic, p.RoleMagicCategory.CIDS, p.RoleMagicType.TIDS, 0, 1,id);
end

function p.getAttackIds()
	return _G.GetRoleDataIdTable(NScriptData.eMagic, p.RoleMagicCategory.CIDS, p.RoleMagicType.TIDS, 0, 1);
end

	