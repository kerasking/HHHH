---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------

local _G = _G
AffixBossFunc = {}
local f = AffixBossFunc;

-- NScriptData,eAffixBoss

 f.DefaultKey = 0; --普通副本
 f.EliteKey = 1; --精英副本
local AffixBossSubClass_LIST = 1; 
local AffixBossSubClass_IDList = 2;
local AffixBossSubClass_MAX = 3;
local AffixBoss_MAX_NORMAL = 1;
local AffixBoss_MAX_ELITE = 2;

AffixBossListIndex = {
	typeid = 1,
	rank = 2,
	status = 3,
	time = 4,
	nParentMapId = 5,
}

--local f.InitPassway;

--副本进入点列表
local PassWayList = {};

f.InstRaise = nil;
f.InstRaisIsCallbacked = false;

--战斗结束nState:1 评价, 2,宝箱
function f.OnBattleFinish(nMapId, nState)
	LogInfo("f.OnBattleFinish");
	if nState == 1 then
		if f.InstRaise then
			AffixBossBattleRaiseDlg.ShowRaiseDlg(f.InstRaise);
			f.InstRaise = nil;
			f.InstRaisIsCallbacked = false;
		else
			f.InstRaisIsCallbacked = true;
		end
	elseif nState == 2 then
		MsgAffixBoss.sendBoxList();
	end
end

function f.OnProcessBattleFinish(m)
	LogInfo("f.OnProcessBattleFinish");
	if f.InstRaisIsCallbacked and f.InstRaisIsCallbacked == true then
		AffixBossBattleRaiseDlg.ShowRaiseDlg(f.InstRaise);
		f.InstRaise = nil;
		f.InstRaisIsCallbacked = false;
	else
		f.InstRaise = m;
	end
end

function f.IsDynMap(nMapId)
	if not CheckN(nMapId) then
		return false;
	end
	
	return nMapId > 100000000;
end

--加载副本入口点列表
function f.LoadPassWayList()
	local idlist	= _G.GetDataBaseIdList("passway");
	if 0 >= #idlist then
		return;
	end
	
	for i, v in ipairs(idlist) do
		local nDestMapId		= _G.ConvertN(_G.GetDataBaseDataN("passway", v, DB_PASSWAY.DEST_MAPID));
		local nMapId			= _G.ConvertN(_G.GetDataBaseDataN("passway", v, DB_PASSWAY.MAPID));
		local nPassWayIndex		= _G.ConvertN(_G.GetDataBaseDataN("passway", v, DB_PASSWAY.INDEX));

		if not PassWayList[nDestMapId] then
			PassWayList[nDestMapId]	= {};
		end
		
		table.insert(PassWayList[nDestMapId], nMapId);
		table.insert(PassWayList[nDestMapId], nPassWayIndex);
	end
end

--获取某副本的入口
--ret : nMapId, nPassWayIndex
function f.GetDynMapPassWay(nDynMapId)
	local nMapId			= 0;
	local nPassWayIndex		= 0;
	
	if not f.IsDynMap(nDynMapId) then
		return nMapId, nPassWayIndex;
	end
	
	if not PassWayList[nDynMapId] then
		f.LoadPassWayList();
	end
	
	local tPassWay	= PassWayList[nDynMapId];
	if not CheckT(tPassWay) then
		return nMapId, nPassWayIndex;
	end
	
	--todo可在此加等级过滤等条件
	for i=1, #tPassWay, 2 do
		local nId		= tPassWay[i];
		local nIndex	= tPassWay[i+1];
		if CheckN(nId) and CheckN(nIndex) and nId > 0 then
			nMapId			= nId;
			nPassWayIndex	= nIndex;
			break;
		end
	end
	
	return nMapId, nPassWayIndex;
end

--获取地图入口点坐标
--ret: cellX, cellY
function f.GetMapPortal(nMapId, nPortalIndex)
	local nCellX		= 0;
	local nCellY		= 0;
	
	if not CheckN(nMapId) or not CheckN(nPortalIndex) then
		return nCellX, nCellY;
	end
	
	if f.IsDynMap(nMapId) then
		return nCellX, nCellY;
	end
	
	local idlist	= _G.GetDataBaseIdList("portal");
	if not CheckT(idlist) then
		return nCellX, nCellY;
	end
	
	for i, v in ipairs(idlist) do
		local mapId = _G.ConvertN(_G.GetDataBaseDataN("portal", v, DB_PORTAL.MAPID));
		if mapId == nMapId then
			local portal_index	= _G.ConvertN(_G.GetDataBaseDataN("portal", v, DB_PORTAL.INDEX));
			if portal_index == nPortalIndex then
				nCellX	= _G.ConvertN(_G.GetDataBaseDataN("portal", v, DB_PORTAL.PORTALX));
				nCellY	= _G.ConvertN(_G.GetDataBaseDataN("portal", v, DB_PORTAL.PORTALY));
				break;
			end
		end
	end
	
	return nCellX, nCellY;
end

function f.IsMapCanOpen(nMapId)
	--LogInfo("AffixBossFunc: IsMapCanOpen() nMapId:%d",nMapId);
	if not CheckN(nMapId) then
		return false;
	end
	
	local nNeedStage	= _G.ConvertN(_G.GetDataBaseDataN("map", nMapId, DB_MAP.NEED_STAGE));
	local nPlayerStage	= _G.ConvertN(_G.GetRoleBasicDataN(_G.GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
	--LogInfo("AffixBossFunc: IsMapCanOpen() nPlayerStage:%d, nNeedStage:%d", nPlayerStage, nNeedStage );
	
	return nPlayerStage >= nNeedStage;
end

--lstId
-- return lst:t{typeid,name, rank, status, time, pic, order},count
function f.findBossList(nParentMap, nPassway)
    
	local ids = f.getIdListByPassway(nParentMap, nPassway);
	local count = #ids;
    
    --LogInfo("f.findBossList ids")
    --_G.LogInfoT(ids)
        
	local lst = {};
	for i = 1,count do
		lst[i] = f.getBossInfo(ids[i]);
	end
	
	--table.sort(lst, function(a,b) return a.order < b.order end);
	table.sort(lst, function(a,b) return a.typeid  < b.typeid  end);
	local rtn = {};
	local i = 1;
	for k, v in pairs(lst) do
       -- LogInfo("i:"..i.." v[1]:"..v.typeid);
		rtn[i] = v;
		i = i +1;
	end
    
   -- LogInfo("f.findBossList")

    
	return rtn, count;
	
end

-- t{typeid,name, rank, status, time, pic, order,elite}
function f.getBossInfo(nTypeId)
	local name	= f.findName(nTypeId);
	local pic	= f.findPic(nTypeId);
	local order = f.findOrder(nTypeId);
	--LogInfo("name:%s order:%d", name, order);
	local elite = f.findElite(nTypeId);
	local id, rank, status, time = f.getBossInfoCache(elite,nTypeId);
	local rtn = {};
	rtn.typeid	= nTypeId;
	rtn.name	= name;
	rtn.rank	= rank;
	rtn.status	= status;
	rtn.time	= time;
	rtn.pic		= pic;
	rtn.order	= order;
	rtn.elite	= elite;
	return rtn;
end

--local database
function f.GetDataBaseN(nPriV, nIndex)
	return _G.ConvertN(_G.GetDataBaseDataN("map", nPriV, nIndex));
end

function f.GetDataBaseS(nPriV, nIndex)
	return _G.ConvertS(_G.GetDataBaseDataS("map", nPriV, nIndex));
end

function f.GetDataBasePasswayN(nPriV, nIndex)
	return _G.ConvertN(_G.GetDataBaseDataN("passway", nPriV, nIndex));
end


function f.findName(nId) 
	return f.GetDataBaseS(nId, DB_MAP.NAME);
end

function f.findPic(nId)
	--return f.GetDataBaseN(nId, );
	return 1;
end

function f.findNpcByBossId(nId)
	--local group = f.findGroup(nId)
	--return AffixBossNpc.findNpc(group);
	return 0;
end

--function f.findGroup(nId)
--	return f.GetDataBasePasswayN(nId, DB_PASSWAY.MAPID);
--end

function f.findOrder(nId)
	return f.GetDataBaseN(nId, DB_MAP.INSTANCING_ORDER);
end

function f.findElite(nId)
	return f.GetDataBaseN(nId, DB_MAP.INSTANCING_IS_ELITE);
end

function f.findStage(nId)
	return f.GetDataBaseN(nId, DB_MAP.NEED_STAGE);
end

function f.findPreId(nId)
	return f.GetDataBaseN(nId, DB_MAP.INSTANCING_PRE_CONDITION);
end

function f.findMapId(nElite, nBossId)
	return f.getBossInfoColumnN(nElite, nBossId, AffixBossListIndex.nParentMapId);
end

--local cache
function f.setBossInfo(nElite,nTypeId, nRank, nStatus, nTime)
	f.setBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.typeid, nTypeId);
	f.setBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.rank, nRank);
	f.setBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.status, nStatus);
	f.setBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.time,	nTime);
end


-- id, rank, status, time
function f.getBossInfoCache(nElite, nTypeId)
	local id		= nTypeId; --f.getBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.typeid);
	local rank		= f.getBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.rank);
	local status	= f.getBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.status);
	local time		= f.getBossInfoColumnN(nElite, nTypeId, AffixBossListIndex.time);
	return id, rank, status, time;
end

-- max 最大已开
function f.setNormalBossMaxId(value) 
	SetGameDataN(NScriptData.eAffixBoss, 0, AffixBossSubClass_MAX, 0, AffixBoss_MAX_NORMAL, value);
end

function f.setEliteBossMaxId(value)
	SetGameDataN(NScriptData.eAffixBoss, 0, AffixBossSubClass_MAX, 0, AffixBoss_MAX_ELITE, value);
end

function f.getNormalBossMaxId()
	return GetGameDataN(NScriptData.eAffixBoss, 0, AffixBossSubClass_MAX, 0, AffixBoss_MAX_NORMAL);
end

function f.getEliteBossMaxId()
	return GetGameDataN(NScriptData.eAffixBoss, 0, AffixBossSubClass_MAX, 0, AffixBoss_MAX_ELITE);
end

--private
function f.setBossInfoColumnN(nElite, nTypeId, key, value) 
	SetGameDataN(NScriptData.eAffixBoss, nElite, AffixBossSubClass_LIST, nTypeId, key, value);
end

function f.getBossInfoColumnN(nElite, nTypeId, key)
	--LogInfo( "AffixBossFunc: getBossInfoColumnN nElite:%d, nTypeId:%d", nElite,nTypeId );
	return GetGameDataN(NScriptData.eAffixBoss, nElite, AffixBossSubClass_LIST, nTypeId, key);
end

function f.InitPassway()
	--if HasInit == true then
	--	return;
	--end
	local ids	= _G.GetDataBaseIdList("passway");
	for i, v in ipairs(ids) do
		local mid = f.GetDataBasePasswayN(v, DB_PASSWAY.MAPID);
		local passway	= f.GetDataBasePasswayN(v, DB_PASSWAY.INDEX);
		local dmid = f.GetDataBasePasswayN(v, DB_PASSWAY.DEST_MAPID);
		--LogInfo("mid%d, passway,%d dmid%d" ,mid, passway, dmid);
		f.setBossInfoColumnN(passway, dmid, AffixBossListIndex.nParentMapId, mid); -- 给boss保存父地图
		f.addId(mid, passway, dmid);
	end
	--HasInit = true;
end

function f.getIdListByPassway(nMapId, nPassway)
	local idList = {};
	if (not CheckN(nMapId)) or (not CheckN(nPassway)) then
		return idList;
	end
	
	idList = _G.GetRoleDataIdTable(NScriptData.eAffixBoss, nMapId, AffixBossSubClass_IDList, f.DefaultKey, nPassway);
	if not idList or #idList == 0 then
	end
	--LogInfo("idsCount:%d", #idList );
	return idList;
end

function f.addId(nMapId, nPassway, nId)
	--LogInfo("add nMapId %d, nPassway %d, nId %d", nMapId, nPassway, nId);
	_G.DelRoleDataId(NScriptData.eAffixBoss, nMapId, AffixBossSubClass_IDList, f.DefaultKey, nPassway, nId);
	_G.AddRoleDataId(NScriptData.eAffixBoss, nMapId, AffixBossSubClass_IDList, f.DefaultKey, nPassway, nId);
end




