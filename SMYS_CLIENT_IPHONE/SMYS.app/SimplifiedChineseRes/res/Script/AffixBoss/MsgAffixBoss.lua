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
	for i = 1, count do
		local typeId	= netdata:ReadInt();
		rank			= netdata:ReadByte();
		status			= netdata:ReadByte();
		cdtime			= netdata:ReadInt();
		
		LogInfo(" typeId:" .. typeId);
		LogInfo(" rank:" .. rank);
		LogInfo(" status:" .. status);
		LogInfo(" cdtime:" .. cdtime);
		
		local id = AffixBossFunc.GetDataBaseN(typeId,DB_MAP.ID);
		LogInfo("id:%d", id);
		local elite = AffixBossFunc.findElite(typeId);
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
	if (not CheckN(nId)) or (not CheckN(nTimeType)) then
		return false;
	end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nId);
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
	
	netdata:WriteInt(nId);
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
	
	netdata:WriteInt(nId);
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

function p.sendNmlReset(nTypeId)
	if not CheckN(nTypeId) then
		return false;
	end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_RESET);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nId);
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlReset: %d", nTypeId);
	return true;
	
end


function p.processNmlReset(netdata)
	
	local instId	= netdata:ReadInt();
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_RESET, instId);
	end
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


	
	