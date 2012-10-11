---------------------------------------------------
--描述: 网络消息处理()消息处理及其逻辑
--时间: 2012.3.11
--作者: wjl
---------------------------------------------------

MsgAffixBoss = {}
local p = MsgAffixBoss;
local _G = _G;

p.mUIListener = nil;

--=====网络
--==获取培养

--
function p.sendNmlOpen()
	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_OPEN);
	if not CheckP(netdata) then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlOpen: %d", NMSG_Type._MSG_AFFIX_BOSS_NML_OPEN);
	return true;
end

function p.processNmlOpen(netdata)
	LogInfo("process 4540");
	
	local count		= netdata:ReadByte();
	--local type		= netdata:ReadByte();
	LogInfo(" count:" .. count);
	local rtn = {};
	
	local lst = {};
	AffixBossFunc.InitPassway(); -- 初始化passway;
	local maxNormId = AffixBossFunc.getNormalBossMaxId();
	for i = 1, count do
		local typeId	= netdata:ReadInt();
		rank			= netdata:ReadByte();
		status			= netdata:ReadByte();
		cdtime			= netdata:ReadInt();
		
		LogInfo(" typeId:" .. typeId);
		LogInfo(" rank:" .. rank);
		LogInfo(" status:" .. status);
		LogInfo(" cdtime:" .. cdtime);
		
		--local id = AffixBossFunc.GetDataBaseN(typeId,DB_MAP.ID);
		--LogInfo("id:%d", id);
		local elite = AffixBossFunc.findElite(typeId);
		if (elite == 0 and maxNormId < typeId) then
			AffixBossFunc.setNormalBossMaxId(maxNormId);
			maxNormId = typeId;
		end
		LogInfo(" elite:" .. elite);
		--local group = AffixBossFunc.findGroup(typeId);
		AffixBossFunc.setBossInfo(elite, typeId, rank, status, cdtime);
		
		lst[i] = m;
	end
	
	rtn.type = type;
	rtn.list = lst;
	
	--if(p.mUIListener) then
		--p.mUIListener(NMSG_Type._MSG_AFFIX_BOSS_NML_OPEN,lst);
	--end
	
	return 1;
end

function p.sendNmlEnter(nId)
	if not CheckN(nId) then
		return false;
	end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_ENTER);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nId);
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlEnter: %d", nId);
	return true;
	
end

function p.processNmlEnter(netdata)
	
	local t = {};
	t.typeId	= netdata:ReadInt();
	t.instId	= netdata:ReadInt();
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_ENTER, t);
	end
end

function p.sendNmlClean(nTypeId, nTimeType, isAutoSell)
	--if (not CheckN(nTypeId)) or (not CheckN(nTimeType)) then
	--	return false;
	-- end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nTypeId);
	netdata:WriteByte(nTimeType);
	if (isAutoSell and isAutoSell == true) then
		netdata:WriteByte(1);
	else
		netdata:WriteByte(0);
	end
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlClean: %d", nTypeId);
	return true;
	
end

function p.processNmlClean(netdata)
	
	local instId	= netdata:ReadInt();
	local time		= netdata:ReadInt();
	local rtn = {};
	rtn.istId = instId;
	rtn.time  = time;	
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP, rtn);
	end
end


function p.sendNmlCancel(nTypeId)
	if not CheckN(nTypeId) then
		return false;
	end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nTypeId);
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlCancel: %d", nTypeId);
	return true;
	
end


function p.processNmlCancel(netdata)
	
	local instId	= netdata:ReadInt();
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_CANCEL, instId);
	end
end


function p.sendNmlFinish(nTypeId)
	if not CheckN(nTypeId) then
		return false;
	end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_FINISH);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nTypeId);
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlFinish: %d", nTypeId);
	return true;
	
end


function p.processNmlFinish(netdata)
	
	local instId	= netdata:ReadInt();
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_FINISH, instId);
	end
end

function p.sendNmlLeave()
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_LEAVE);
	if not CheckP(netdata) then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlLeave");
	return true;
	
end

function p.sendNmlReset(nMapId)
	if not CheckN(nMapId) then
		return false;
	end	
	
	local nGroupId = AffixBossEliteMapList.getGroupByMapId(nMapId);
	if (not nGroupId) or nGroupId <= 0 then
		return false;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_RESET);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nGroupId);
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlReset: %d", nGroupId);
	return true;
	
end


function p.processNmlReset(netdata)
	
	local nGroupId	= netdata:ReadInt();
	
	-- deal
	local nEliteMap = AffixBossEliteMapList.getMapIdByGroup(nGroupId);
	if (not nEliteMap) or nEliteMap <= 0 then
		return false;
	end
	
	local ids = AffixBossFunc.getIdListByPassway(nEliteMap, 1);
	if ids then
		for i = 1, #ids do
			AffixBossFunc.setBossInfoColumnN(1,ids[i],AffixBossListIndex.time,0);
		end
	end
	
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_RESET, nGroupId);
	end
end


function p.processInstRaise(netdata)
	local instId = netdata:ReadInt();
	local score = netdata:ReadInt();
	local rank = netdata:ReadByte();
	local soph = netdata:ReadInt();
	local cdTime = netdata:ReadInt();
	local count = netdata:ReadByte();
	LogInfo("instId:%d, score:%d, rank:%d, soph:%d, cdTime:%d, count:%d", instId, score, rank, soph, cdTime, count)
	local lst = {};
	for i = 1, count do
		local petId = netdata:ReadInt();
		local exp  = netdata:ReadInt();
		lst[i] = {};
		lst[i].petId = petId;
		lst[i].exp = exp;
		LogInfo("petId:%d, exp:%d", petId, exp);
	end 
	
	-- 保存
	local elite = AffixBossFunc.findElite(instId);
	local maxNormId = AffixBossFunc.getNormalBossMaxId();
	if (elite == 0 and maxNormId < instId) then
		AffixBossFunc.setNormalBossMaxId(maxNormId);
		maxNormId = instId;
	end
	AffixBossFunc.setBossInfo(elite, instId, rank, status, cdtime);
	
	local m = {};
	m.instId = instId;
	m.passway = elite;
	m.rank = rank;
	m.cdtime = cdtime;
	m.count = count;
	m.score = score;
	m.soph = soph;
	m.lst = lst;
	AffixBossFunc.OnProcessBattleFinish(m);
end

-- 扫荡奖励
function p.processCleanUpBattle(netdata)
	LogInfo("扫荡奖励");
	--local name = netdata:ReadUnicodeString();
	local nameId = netdata:ReadInt();
	local count = netdata:ReadByte();
	LogInfo("扫荡奖励:%d count:%d", nameId, count);
	local lst = {};
	for i = 1, count do
		--local petName = netdata:ReadUnicodeString();
		local petNameId = netdata:ReadInt();
		local petExpV  = netdata:ReadInt();
		lst[i] = {petId = petNameId, petExp = petExpV};
		LogInfo("petName:%d, petExp:%d", petNameId, petExpV);
	end
	
	local rtn = {};
	rtn.nameId = nameId;
	rtn.count = count;
	rtn.list = lst;
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_BATTLE, rtn);
	end
end

-- 扫荡副本评价奖励
function p.processCleanUpRaise(netdata)
	LogInfo("扫荡副本奖励");
	local soph = netdata:ReadInt();
	local money = netdata:ReadInt();
	local item = netdata:ReadInt();
	local count = netdata:ReadByte();
	LogInfo("扫荡副本奖励 soph:%d money:%d item id:%d, count:%d", soph, money, item,count);
	
	local lst = {};
	for i = 1, count do
		--local petName = netdata:ReadUnicodeString();
		local petNameId = netdata:ReadInt();
		local petExpV  = netdata:ReadInt();
		lst[i] = { petId = petNameId, petExp = petExpV};
		LogInfo("petName:%d, petExp:%d", petNameId, petExpV);
	end
	
	local rtn = {};
	rtn.soph = soph;
	rtn.money = money;
	rtn.item = item;
	rtn.count = count;
	rtn.list = lst;
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_RAISE, rtn);
	end
end

-- 片区通关奖励
function p.processBossGroupRaise(netdata)
	LogInfo("片区通关奖励");
	local groupId = netdata:ReadInt();
	local health =  netdata:ReadInt();
	local phy =  netdata:ReadInt();
	local skill =  netdata:ReadInt();
	local magic =  netdata:ReadInt();
	LogInfo("groupId:%d, health:%d, phy:%d, skill:%d, magic:%d", groupId, health, phy, skill, magic);
	local data = {};
	
	AffixBossBoxDlg:showRaiseGroupDlg(data);
end

--副本宝箱类表
function p.sendBoxList()
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_GET_BOX_LST);
	if not CheckP(netdata) then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendBoxList: %d", NMSG_Type._MSG_AFFIX_BOSS_GET_BOX_LST);
	return true;
end

--副本宝箱类表
function p.processBoxList(netdata)
	local emoney = netdata:ReadInt();
	local money =  netdata:ReadInt();
	local equip =  netdata:ReadInt();
	local scoll =  netdata:ReadInt();
	LogInfo("emoney:%d, money:%d, equip:%d, scoll:%d", emoney, money, equip, scoll);
	local m = {};
	m.emoney = emoney;
	m.money = money;
	m.equip = equip;
	m.scoll = scoll;
	AffixBossBoxDlg.ShowDlg(m);
end

--副本宝箱物品
function p.sendPickItem(type)
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_PICK_BOX_ITEM);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(type);
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendBoxList: %d", NMSG_Type._MSG_AFFIX_BOSS_PICK_BOX_ITEM);
	return true;
end

--副本宝箱物品
function p.processPickBoxItem(netdata)
	local type = netdata:ReadByte();
	local param = netdata:ReadInt();
	LogInfo("type:%d, param:%d", type, param);
end



--======消息注册
--==悟道购买
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_OPEN, "p.processNmlOpen", p.processNmlOpen);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_ENTER, "p.processNmlEnter", p.processNmlEnter);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP, "p.processNmlClean", p.processNmlClean);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_CANCEL, "p.processNmlCancel", p.processNmlCancel);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_FINISH, "p.processNmlFinish", p.processNmlFinish);

RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_INST_OPEN, "p.processInstOpen", p.processInstOpen);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_INST_ENTER, "p.processInstEnter", p.processInstEnter);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_INST_CLEARUP, "p.processInstClean", p.processInstClean);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_INST_CANCEL, "p.processInstCancel", p.processInstCancel);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_INST_FINISH, "p.processInstFinish", p.processInstFinish);

RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_RAISE, "p.processInstRaise", p.processInstRaise);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_BATTLE, "p.processCleanUpBattle", p.processCleanUpBattle);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_RAISE, "p.processCleanUpRaise", p.processCleanUpRaise);

RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_GROUP_RAISE, "p.processBossGroupRaise", p.processBossGroupRaise);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_GET_BOX_LST, "p.processBoxList", p.processBoxList);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_PICK_BOX_ITEM, "p.processPickBoxItem", p.processPickBoxItem);


	
	