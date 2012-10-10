---------------------------------------------------
--描述: 玩家信息网络消息处理及其逻辑
--时间: 2012.2.17
--作者: jhzheng
---------------------------------------------------

MsgPlayer = {}
local p = MsgPlayer;

local MSG_GRID_ACT_BEGIN				= 0;
local MSG_GRID_ACT_STORAGE				= 0; --仓库
local MSG_GRID_ACT_BAG					= 1; --背包
local MSG_GRID_ACT_END					= 2;

--发送开玩家背包消息
function p.SendOpenBagGrid(nNum)
	p.SendOpenGrid(MSG_GRID_ACT_BAG, nNum);
end

--发送开格子消息
function p.SendOpenGrid(nAction, nNum)
	if not CheckN(nAction) or
		not CheckN(nNum) then
		LogInfo("发送开格子消息失败,参数不对");
		return;
	end
	
	if nAction < MSG_GRID_ACT_BEGIN or 
		nAction >= MSG_GRID_ACT_END then
		LogInfo("发送开格子消息失败,action不对");
		return;
	end
	
	local netdata = createNDTransData(NMSG_Type._MSG_LIMIT);
	if nil == netdata then
		LogInfo("发送开格子消息失败,内存不够");
		return false;
	end
	netdata:WriteByte(nAction);
	netdata:WriteShort(nNum);
	SendMsg(netdata);
	netdata:Free();
	LogInfo("send Grid action[%d] num[%d]", nAction, nNum);
	return true;
end

-- 网络消息处理(用户信息, 宠物信息)
function p.ProcessUserInfo(netdata)
	local idUser				= netdata:ReadInt();
	local idLookface			= netdata:ReadInt();
	local idRecordMap			= netdata:ReadInt();
	local usRecordX				= netdata:ReadShort();
	local usRecordY				= netdata:ReadShort();
	local unMoney				= netdata:ReadInt();
	local unEMoney				= netdata:ReadInt();
	local usPackage				= netdata:ReadShort();
	local usStorage				= netdata:ReadShort();
	local unRepute				= netdata:ReadInt();
	local btCamp				= netdata:ReadByte();
	local btVipLevel			= netdata:ReadByte();
	local unVipExp				= netdata:ReadInt();
	local unMatrix				= netdata:ReadInt();
	local unSoph				= netdata:ReadInt();
	local usPartsBag			= netdata:ReadShort();
	local usDaoFaBag			= netdata:ReadShort();
	local btPet_limit			= netdata:ReadByte();
	local unStage				= netdata:ReadInt();
	local strName				= netdata:ReadUnicodeString();

	LogInfo("btPet_limit:%d",btPet_limit);
	
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_ID, idUser);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_LOOKFACE, idLookface);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RECORD_MAP, idRecordMap);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RECORD_X, usRecordX);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_RECORD_Y, usRecordY);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_MONEY, unMoney);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_EMONEY, unEMoney);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_PACKAGE_LIMIT, usPackage);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_STORAGELIMIT, usStorage);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_REPUTE, unRepute);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_CAMP, btCamp);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_VIP_RANK, btVipLevel);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_VIP_EXP, unVipExp);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_MATRIX, unMatrix);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_SOPH, unSoph);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_PARTS_BAG, usPartsBag);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_DAO_BAG, usDaoFaBag);	
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_PET_LIMIT, btPet_limit);
	SetRoleBasicDataN(idUser, USER_ATTR.USER_ATTR_STAGE, unStage);
	SetRoleBasicDataS(idUser, USER_ATTR.USER_ATTR_NAME, strName);
	
	CreatePlayer(idLookface, usRecordX, usRecordY, idUser);
	
	return 1;
end


function p.ProcessUserInfoUpdate(netdata)
	local idUser				= ConvertN(netdata:ReadInt());
	local nPlayerId				= ConvertN(GetPlayerId());
	if nPlayerId ~= idUser then
		LogError("ProcessUserInfoUpdate playerid[%d] idUser[%d]", nPlayerId, idUser);
		return;
	end
	
	local btAmount				= netdata:ReadByte();
	local datalist				= {};
	for i=1, btAmount do
		local nAttr				= ConvertN(netdata:ReadInt());
		local nAttrData			= ConvertN(netdata:ReadInt());
		
		if nAttr ~= USER_ATTR.USER_ATTR_ID then
			SetRoleBasicDataN(idUser, nAttr, nAttrData);
			--状态如果有特殊处理todo
			table.insert(datalist, nAttr);
			table.insert(datalist, nAttrData);
		end
	end
	if 0 < #datalist then
		GameDataEvent.OnEvent(GAMEDATAEVENT.USERATTR, datalist);
	end
end

RegisterNetMsgHandler(NMSG_Type._MSG_USERINFO, "p.ProcessUserInfo", p.ProcessUserInfo);

RegisterNetMsgHandler(NMSG_Type._MSG_USERINFO_UPDATE, "p.ProcessUserInfoUpdate", p.ProcessUserInfoUpdate);
