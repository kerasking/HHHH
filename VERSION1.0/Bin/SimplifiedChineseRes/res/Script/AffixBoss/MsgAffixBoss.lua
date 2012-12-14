---------------------------------------------------
--描述: 网络消息处理()消息处理及其逻辑
--时间: 2012.3.11
--作者: wjl
---------------------------------------------------

MsgAffixBoss = {}
local p = MsgAffixBoss;
local _G = _G;

p.mUIListener = nil;
p.rank = nil;

--=====网络
--==获取培养

--
function p.sendNmlOpen()
	LogInfo( "MsgAffixBoss: sendNmlOpen" );
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_OPEN);
	if not CheckP(netdata) then
		return false;
	end
	
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlOpen: %d", NMSG_Type._MSG_AFFIX_BOSS_NML_OPEN);
    ShowLoadBar();
	return true;
end

function p.processNmlOpen(netdata)
    CloseLoadBar();
	LogInfo("MsgAffixBoss: processNmlOpen");
	
	local count		= netdata:ReadByte();
	--local type		= netdata:ReadByte();
	local rtn = {};
	
	local lst = {};
	AffixBossFunc.InitPassway(); -- 初始化passway;
	local maxNormId = AffixBossFunc.getNormalBossMaxId();
--LogInfo("AffixBossFunc.setBossInfo[%d]",count);	
	for i = 1, count do
		local typeId	= netdata:ReadInt();
		rank			= netdata:ReadByte();
		status			= netdata:ReadByte();
		cdtime			= netdata:ReadInt();
		
		LogInfo("qbw9 typeId:" .. typeId.." status:"..status);
		LogInfo("qbw9 rank:" .. rank);
		LogInfo("qbw9 status:" .. status);
        LogInfo("qbw9 cdtime:" .. cdtime);
		
		--local id = AffixBossFunc.GetDataBaseN(typeId,DB_MAP.ID);
		--LogInfo("id:%d", id);
		local elite = AffixBossFunc.findElite(typeId);
		if (elite == 0 and maxNormId < typeId) then
			AffixBossFunc.setNormalBossMaxId(maxNormId);
			maxNormId = typeId;
		end
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

-- 发送战斗请求
function p.sendAgainOpen(nId)
	LogInfo( "MsgAffixBoss: sendAgainOpen id:"..nId );
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_AGAIN);
	if not CheckP(netdata) then
		return false;
	end
	Drama.SetBossId(nId);
	netdata:WriteByte(1);
    netdata:WriteByte(0);
    netdata:WriteByte(1);
    netdata:WriteInt(nId);
    SendMsg(netdata);
	netdata:Free();
	
	LogInfo("p.sendNmlOpen: %d", NMSG_Type._MSG_AFFIX_BOSS_NML_OPEN);
	return true;
end

function p.sendNmlEnter(nId)
	LogInfo( "MsgAffixBoss: sendNmlEnter" );
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
    ShowLoadBar();
	return true;
	
end

--响应进入副本消息
function p.processNmlEnter(netdata)
    CloseLoadBar();
	LogInfo( "MsgAffixBoss: processNmlEnter" );
	local t = {};
	t.typeId	= netdata:ReadInt();
	t.instId	= netdata:ReadInt();
	LogInfo( "p.processNmlEnter TYPE"..t.typeId.." INST"..t.instId)

    -- local bossid =  m.typeId;

    p.sendAgainOpen(t.typeId);--进入战斗


	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_ENTER, t);
	end
end

--发送副本扫荡消息（怪物点，次数，是否自动卖）
function p.sendNmlClean(nTypeId, nTimeType, isAutoSell)
	LogInfo( "MsgAffixBoss: sendNmlClean" );
	if (not CheckN(nTypeId)) or (not CheckN(nTimeType)) then
	LogInfo( "MsgAffixBoss: sendNmlClean 00" );
		return false;
	end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP);
	if not CheckP(netdata) then
	LogInfo( "MsgAffixBoss: sendNmlClean 01" );
		return false;
	end
	netdata:WriteInt(nTypeId);
	netdata:WriteInt(nTimeType);
	if (isAutoSell and isAutoSell == true) then
		netdata:WriteByte(1);
	else
		netdata:WriteByte(0);
	end
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo( "MsgAffixBoss: p.sendNmlClean: TypeId:%d, TimeType:%d", nTypeId, nTimeType );
    ShowLoadBar();
	return true;
end

--++Guosen 2012.6.15
function p.processNmlClean(netdata)
    CloseLoadBar();
	LogInfo( "MsgAffixBoss: processNmlClean" );
	
	local nEnemyID	= netdata:ReadInt();
	local nRemain	= netdata:ReadInt();
	local rtn = {};
	rtn.istId = nEnemyID;
	rtn.time  = nRemain;	
	local nTotal = nRemain;	--总数
	--LogInfo( "MsgAffixBoss: processNmlClean EnemyID:%d", nEnemyID );
    LogInfo( "MsgAffixBoss: processNmlClean EnemyID:%d, nRemain = %d", nEnemyID, nRemain);
    
	if ( AffixBossFunc.findElite( nEnemyID ) == 0 ) then
        LogInfo( "MsgAffixBoss: processNmlCleanAffixBossFunc.findElite( nEnemyID ) == 0");
		-- 关卡扫荡
		if not IsUIShow( NMAINSCENECHILDTAG.AffixBossClearUp ) then
            LogInfo( "MsgAffixBoss: if not IsUIShow( NMAINSCENECHILDTAG.AffixBossClearUp ) then");
		-- 扫荡UI未开启，则是登录时...
			ClearUpSettingUI.LoadUIForLogin( nEnemyID, nRemain, nTotal );
		end
	else
		-- 副本扫荡
		if not IsUIShow( NMAINSCENECHILDTAG.AffixBossClearUpElite ) then
		-- 扫荡UI未开启，则是登录时...
			ClearUpEliteSettingUI.LoadUIForLogin( nEnemyID, nRemain, nTotal );
		end
	end
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_CLEARUP, rtn );
	end
end

--++Guosen 2012.6.19
--发送取消扫荡消息给服务端
function p.sendNmlCancel(nTypeId)
	LogInfo( "MsgAffixBoss: sendNmlCancel" );
	if not CheckN(nTypeId) then
		return false;
	end	
	
	local netdata = createNDTransData(NMSG_Type._MSG_AFFIX_BOSS_NML_CANCEL);
	if not CheckP(netdata) then
		return false;
	end
	
	netdata:WriteInt(nTypeId);
	SendMsg(netdata);
	
	netdata:Free();
	
	LogInfo("p.sendNmlCancel: %d", nTypeId);
	return true;
	
end


-- 处理取消消息，{MapID,CancelFlag}
function p.processNmlCancel(netdata)
    CloseLoadBar();
	LogInfo( "MsgAffixBoss: processNmlCancel" );
	
	--local instId	= netdata:ReadInt();
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_CANCEL, netdata );
	end
end


function p.sendNmlFinish(nTypeId)
	LogInfo( "MsgAffixBoss: sendNmlFinish" );
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


-- 处理完成消息{MapID,FinishFlag}
function p.processNmlFinish(netdata)
    CloseLoadBar();
	LogInfo( "MsgAffixBoss: processNmlFinish" );
	--local instId	= netdata:ReadInt();
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_FINISH, netdata );
	end
end

function p.sendNmlLeave()
	LogInfo( "MsgAffixBoss: sendNmlLeave" );
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
	LogInfo( "MsgAffixBoss: sendNmlReset" );
	if not CheckN(nMapId) then
		return false;
	end	
	
	local nGroupId = nMapId;
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
    CloseLoadBar();
	LogInfo( "MsgAffixBoss: processNmlReset" );
	local nGroupId	= netdata:ReadInt();
	if ( nGroupId == 0 ) then
		local ids	= _G.GetDataBaseIdList("passway");
		for i, v in ipairs(ids) do
			local nMapID	= AffixBossFunc.GetDataBasePasswayN(v, DB_PASSWAY.DEST_MAPID);
			local elite		= AffixBossFunc.findElite(nMapID);
			if ( elite == 1 ) then
				AffixBossFunc.setBossInfoColumnN( 1, nMapID, AffixBossListIndex.time, 0 );
			end
		end  
    	SetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_INSTANCING_RESET_COUNT, 0 );--0点重置消息，把已重置次数也清零
	else
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
	end
	
	
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_NML_RESET, nGroupId);
	end
end

--更新副本信息
function p.processInstRaise(netdata)

	local instId = netdata:ReadInt();       
	local score = netdata:ReadInt();
	local rank = netdata:ReadByte();
    p.rank=rank;
	local soph = netdata:ReadInt();
	local cdTime = netdata:ReadInt();
	local count = netdata:ReadByte();
	local lst = {};
	for i = 1, count do
		local petId = netdata:ReadInt();
		local exp  = netdata:ReadInt();
		lst[i] = {};
		lst[i].petId = petId;
		lst[i].exp = exp;
	end 
	
	-- 保存
	local elite = AffixBossFunc.findElite(instId);                             --是否为精英副本 0:否,1:是
	local maxNormId = AffixBossFunc.getNormalBossMaxId();
	if (elite == 0 and maxNormId < instId) then
		AffixBossFunc.setNormalBossMaxId(maxNormId);
		maxNormId = instId;
	end
    
	AffixBossFunc.setBossInfo(elite, instId, rank, 1, cdTime);

	--local status	= AffixBossFunc.getBossInfoColumnN(elite, instId, AffixBossListIndex.status);--++Guosen 2012.6.26
	--AffixBossFunc.setBossInfo(elite, instId, rank, status, cdTime);
	
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

--++Guosen 2012.6.19
-- 扫荡关卡奖励
function p.processCleanUpBattle(netdata)
	LogInfo("MsgAffixBoss: processCleanUpBattle");
	local tData 		= {};
	tData.nExp			= 0;
	tData.nMoney		= 0;
	tData.tItems		= {};
	tData.nExp			= netdata:ReadInt();
	tData.nMoney		= netdata:ReadInt();
	local nItemCount	= netdata:ReadInt();
	for i = 1, nItemCount do
		tData.tItems[i] = {
			nItemType	= netdata:ReadInt(),
			nItemAmount	= netdata:ReadInt(),
		}
	end
	if (p.mUIListener) then
		p.mUIListener( NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_BATTLE, tData );
	end
end

-- 扫荡副本奖励
function p.processCleanUpRaise(netdata)
	LogInfo("MsgAffixBoss: processCleanUpRaise");
	local soph = netdata:ReadInt();
	local money = netdata:ReadInt();
	local item = netdata:ReadInt();
	local count = netdata:ReadByte();
	LogInfo("MsgAffixBoss: processCleanUpRaise soph:%d money:%d item id:%d, count:%d", soph, money, item,count);
	
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
	LogInfo("MsgAffixBoss: processBossGroupRaise");
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
	LogInfo( "MsgAffixBoss: sendBoxList" );
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
	LogInfo( "MsgAffixBoss: processBoxList" );
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
	LogInfo( "MsgAffixBoss: sendPickItem" );
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
	LogInfo( "MsgAffixBoss: processPickBoxItem" );
	local type = netdata:ReadByte();
	local param = netdata:ReadInt();
	LogInfo("type:%d, param:%d", type, param);
end

function p.getrank()
    return p.rank;
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

RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_RESET, "p.processNmlReset", p.processNmlReset);

RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_NML_RAISE, "p.processInstRaise", p.processInstRaise);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_BATTLE, "p.processCleanUpBattle", p.processCleanUpBattle);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_CLEANUP_RAISE, "p.processCleanUpRaise", p.processCleanUpRaise);

RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_GROUP_RAISE, "p.processBossGroupRaise", p.processBossGroupRaise);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_GET_BOX_LST, "p.processBoxList", p.processBoxList);
RegisterNetMsgHandler(NMSG_Type._MSG_AFFIX_BOSS_PICK_BOX_ITEM, "p.processPickBoxItem", p.processPickBoxItem);