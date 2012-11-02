---------------------------------------------------
--描述: 玩家好友
--时间: 2012.4.22
--作者: fyl
---------------------------------------------------

FriendFunc = {}
local p = FriendFunc;

--判断好友列表是否已满
function p.CanAddFriend(nRoleId)
	local idlist = p.GetFriendIdList(nRoleId);
	
	if #idlist < 50 then	 
		return true;
	else
	    return false;	
	end	
end 

--添加好友
function p.AddFriend(nPlayerId)
	--判断好友列表是否已满
	if p.CanAddFriend(GetPlayerId()) then
		MsgFriend.SendFriendAdd(nPlayerId);
	else
	    CommonDlg.ShowTipInfo("提示", "好友列表已满!", nil, 0.5); 	
	end
end

function p.IsExistFriend(nFriendId)

	if not CheckN(nFriendId) then
		LogInfo("p.IsExistFriend invalid arg");
		return false;
	end

	local nFriendId = GetRoleFriendDataN(GetPlayerId(), FRIEND_DATA.FRIEND_ID,nFriendId);
	if nFriendId <= 0 then
		LogInfo("qbw1: dont exist friend");
		return false;
	end

	return true;
end

function p.IsExistFriendByName(sName)
	if not CheckS(sName) then
		LogInfo("p.IsExistFriendByName invalid arg");
		return false;
	end

    local tFriendlist = p.GetFriendIdList(GetPlayerId());
    
    if tFriendlist == nil  then
        return false;
    end
    
    for i,v in pairs(tFriendlist) do
        local sIndName = GetRoleFriendDataS(GetPlayerId(), FRIEND_DATA.FRIEND_NAME,v);
        if string.upper(sIndName) == string.upper(sName) then
            return true;
        end
        
    end
    
    return false;
end



function p.DelFriend(nRoleId, nFriendId)
	if	not CheckN(nRoleId) or
		not CheckN(nFriendId) then
		return;
	end
	
	_G.DelRoleSubGameDataById(NScriptData.eRole, nRoleId, NRoleData.eFriend, nFriendId);
end



function p.GetFriendIdList(nRoleId)
	local idlist = {};
	if	not CheckN(nRoleId) then
		return idlist;
	end
	
	
	idlist = GetGameDataIdList(NScriptData.eRole, nRoleId, NRoleData.eFriend);
	if not CheckT(idlist) then
		idlist	= {};
		LogInfo("GetGameDataIdList fail");
	end
	return idlist;
end


function p.GetAttrDesc(nPlayerId, nIndex,nFriendId)
	local strRes	= "";
	if not CheckN(nPlayerId) or
		not CheckN(nIndex) then
		LogInfo("FriendFunc.GetAttrDesc invalid arg");
		return strRes;
	end
	if nIndex == FRIEND_DATA.FRIEND_NAME then
		strRes	= GetRoleFriendDataS(nPlayerId, FRIEND_DATA.FRIEND_NAME,nFriendId);
	elseif nIndex == FRIEND_DATA.FRIEND_LEVEL then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_LEVEL,nFriendId);
	elseif nIndex == FRIEND_DATA.FRIEND_ONLINE then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_ONLINE,nFriendId);
	elseif 	nIndex == FRIEND_DATA.FRIEND_LOOKFACE then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_LOOKFACE,nFriendId);
		
	elseif 	nIndex == FRIEND_DATA.FRIEND_PROFESSION then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_PROFESSION,nFriendId);
	elseif 	nIndex == FRIEND_DATA.FRIEND_REPUTE then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_REPUTE,nFriendId);
	elseif 	nIndex == FRIEND_DATA.FRIEND_SYNDYCATE then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_SYNDYCATE,nFriendId);
	elseif 	nIndex == FRIEND_DATA.FRIEND_SPORTS then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_SPORTS,nFriendId);
	elseif 	nIndex == FRIEND_DATA.FRIEND_CAPACITY then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_CAPACITY,nFriendId);
    elseif 	nIndex == FRIEND_DATA.FRIEND_QUALITY then
		strRes	= GetRoleFriendDataN(nPlayerId, FRIEND_DATA.FRIEND_QUALITY,nFriendId);
	end
	
	return strRes;
end


--设置显示或隐藏主场景中的layer
function p.SetLayerVisible(tag,visiable)

	local scene = GetSMGameScene();
	if nil == scene then
		LogInfo("scene is nil");
		return nil;
	end
	
	local layer = GetUiLayer(scene, tag);
	if nil == layer then
	    LogInfo("layer is nil");
	end
	layer:SetVisible(visiable);
end	


function p.IsLayerVisible(tag)
	local scene = GetSMGameScene();
	if nil == scene then
		LogInfo("scene is nil");
		return false;
	end
	
	local layer = GetUiLayer(scene, tag);
	if nil == layer then
	    LogInfo("layer is nil");
		return false;
	end
	return layer:IsVisible();
end	