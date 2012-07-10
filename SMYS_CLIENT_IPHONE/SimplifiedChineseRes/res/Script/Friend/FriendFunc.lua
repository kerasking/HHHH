---------------------------------------------------
--描述: 玩家好友
--时间: 2012.4.22
--作者: fyl
---------------------------------------------------

FriendFunc = {}
local p = FriendFunc;

--添加好友
function p.AddFriend(nPlayerId,nPlayerName)
	--判断好友列表是否已满
	if FriendUI.CanAddFriend() then
		MsgFriend.SendFriendAdd(nPlayerId);
	else
	    CommonDlg.ShowTipInfo("提示", "好友列表已满!", nil, 2); 	
	end
end
