-- 获取数据库数据
function GetDataBaseDataN(strIniFile, nDataId, nDataIndex)
	if not CheckS(strIniFile) then
		return 0;
	end
	
	local nKey = GetIniFileKey(strIniFile, nDataId, nDataIndex);
	if 0 == nKey then
		return 0;
	end
	
	local nVal = GetGameDataN(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex);
	return nVal;
end

function GetDataBaseIdList(strIniFile)
	local idList = {};
	local nKey = GetIniFileKey(strIniFile);
	if 0 == nKey then
		LogInfo("nKey==0");
		return;
	end
	idList=GetGameDataIdList(NScriptData.eDataBase, nKey, NRoleData.ePet);
	return idList;
end

function GetDataBaseDataF(strIniFile, nDataId, nDataIndex)
	if not CheckS(strIniFile) then
		return 0;
	end
	
	local nKey = GetIniFileKey(strIniFile);
	if 0 == nKey then
		return 0;
	end
	
	local fVal = GetGameDataF(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex);
	return fVal;
end

function GetDataBaseDataS(strIniFile, nDataId, nDataIndex)
	if not CheckS(strIniFile) or 
		not CheckN(nDataId) or
		not CheckN(nDataIndex) then
		LogInfo("GetDataBaseDataS invalid arg");
		return "";
	end
	
	local nKey = GetIniFileKey(strIniFile);
	if 0 == nKey then
		return "";
	end
	local szVal = GetGameDataS(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex);
	return szVal;
end

-- 设置数据库数据
function SetDataBaseDataN(strIniFile, nDataId, nDataIndex, ulVal)
	if not CheckS(strIniFile) then
		return;
	end
	
	local nKey = GetIniFileKey(strIniFile);
	if 0 == nKey then
		return;
	end
	
	SetGameDataN(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex, ulVal);
end

function SetDataBaseDataF(strIniFile, nDataId, nDataIndex, dVal)
	if not CheckS(strIniFile) then
		return;
	end
	
	local nKey = GetIniFileKey(strIniFile);
	if 0 == nKey then
		return;
	end
	
	SetGameDataF(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex, dVal);
end

function SetDataBaseDataS(strIniFile, nDataId, nDataIndex, szVal)
	if not CheckS(strIniFile) then
		return;
	end
	
	local nKey = GetIniFileKey(strIniFile);
	if 0 == nKey then
		return;
	end
	
	SetGameDataS(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex, szVal);
end

-- 人物基础数据
function GetRoleBasicDataN(nRoleId, dataIndex)
	local nVal = GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eBasic, 0, dataIndex);
	return nVal;
end

function GetRoleBasicDataF(nRoleId, dataIndex)
	local fVal = GetGameDataF(NScriptData.eRole, nRoleId, NRoleData.eBasic, 0, dataIndex);
	return fVal;
end

function GetRoleBasicDataS(nRoleId, dataIndex)
	local szVal = GetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eBasic, 0, dataIndex);
	return szVal;
end

function SetRoleBasicDataN(nRoleId, dataIndex, ulVal)
	SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eBasic, 0, dataIndex, ulVal);
end

function SetRoleBasicDataF(nRoleId, dataIndex, dVal)
	SetGameDataF(NScriptData.eRole, nRoleId, NRoleData.eBasic, 0, dataIndex, dVal);
end

function SetRoleBasicDataS(nRoleId, dataIndex, szVal)
	SetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eBasic, 0, dataIndex, szVal);
end

-- 人物宠物数据
--[[
function GetRolePetDataN(nRoleId, dataIndex, nPetId)
	local nVal = GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, dataIndex);
	return nVal;
end

function GetRolePetDataF(nRoleId, dataIndex, nPetId)
	local fVal = GetGameDataF(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, dataIndex);
	return fVal;
end

function GetRolePetDataS(nRoleId, dataIndex, nPetId)
	local szVal = GetGameDataS(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, dataIndex);
	return szVal;
end

function SetRolePetDataN(nRoleId, dataIndex, ulVal, nPetId)
	SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, dataIndex, ulVal);
end

function SetRolePetDataF(nRoleId, dataIndex, dVal, nPetId)
	SetGameDataF(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, dataIndex, dVal);
end

function SetRolePetDataS(nRoleId, dataIndex, szVal, nPetId)
	SetGameDataS(NScriptData.eRole, nRoleId, NRoleData.ePet, nPetId, dataIndex, szVal);
end

--]]

-- 角色好友数据
--[[
function GetRoleFriendDataN(nRoleId, dataIndex, nFriendId)
	local nVal = GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex);
	return nVal;
end

function GetRoleFriendDataF(nRoleId, dataIndex, nFriendId)
	local fVal = GetGameDataF(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex);
	return fVal;
end

function GetRoleFriendDataS(nRoleId, dataIndex, nFriendId)
	local szVal = GetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex);
	return szVal;
end

function SetRoleFriendDataN(nRoleId, dataIndex,ulVal, nFriendId)
	SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex,ulVal);
end


function SetRoleFriendDataF(nRoleId, dataIndex,dVal, nFriendId)
	SetGameDataF(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex,dVal);
end


function SetRoleFriendDataS(nRoleId, dataIndex,szVal, nFriendId)
	SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex,szVal);
end

--]]

-- 角色好友数据
function GetRoleFriendDataN(nRoleId, dataIndex, nFriendId)
	local nVal = GetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex);
	return nVal;
end

function GetRoleFriendDataF(nRoleId, dataIndex, nFriendId)
	local fVal = GetGameDataF(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex);
	return fVal;
end

function GetRoleFriendDataS(nRoleId, dataIndex, nFriendId)
	local szVal = GetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex);
	return szVal;
end

function SetRoleFriendDataN(nRoleId, dataIndex,ulVal, nFriendId)
	SetGameDataN(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex,ulVal);
end


function SetRoleFriendDataF(nRoleId, dataIndex,dVal, nFriendId)
	SetGameDataF(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex,dVal);
end


function SetRoleFriendDataS(nRoleId, dataIndex,szVal, nFriendId)
	SetGameDataS(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId, dataIndex,szVal);
end





































