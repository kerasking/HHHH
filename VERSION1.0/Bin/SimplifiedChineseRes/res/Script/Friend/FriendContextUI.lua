---------------------------------------------------
--描述: 鲜花榜UI
--时间: 2012.4.17
--作者: fyl
---------------------------------------------------



FriendContextUI = {}
local p = FriendContextUI;

local ID_SM_JH_POP_MSG_CTRL_BUTTON_1   =  1 ;
local ID_SM_JH_POP_MSG_CTRL_BUTTON_2   =  2 ;
local ID_SM_JH_POP_MSG_CTRL_BUTTON_3   =  3 ;
local ID_SM_JH_POP_MSG_CTRL_BUTTON_4   =  4 ;
local ID_SM_JH_POP_MSG_CTRL_BUTTON_5   =  5 ;

local friendId;
local friendName;


-----------------------
-----------------------

function p.LoadUI(id,name)
	friendId = id;
	friendName = name;

	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load GiveFlowersUI failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.FriendContext);
	layer:SetFrameRect(RectUILayer);
	scene:AddChild(layer);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("SM_JH_POP_MSG.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	
	local delBtn = GetButton(layer,ID_SM_JH_POP_MSG_CTRL_BUTTON_1);       --删除好友
    local selBtn = GetButton(layer,ID_SM_JH_POP_MSG_CTRL_BUTTON_2);       --查看资料
	local giveFlowerBtn = GetButton(layer,ID_SM_JH_POP_MSG_CTRL_BUTTON_3);--赠送鲜花
	local chatBtn = GetButton(layer,ID_SM_JH_POP_MSG_CTRL_BUTTON_4);      --私聊
	local compareBtn = GetButton(layer,ID_SM_JH_POP_MSG_CTRL_BUTTON_5);   --切磋
	delBtn:SetLuaDelegate(p.OnUIEventDelFriend);
	selBtn:SetLuaDelegate(p.OnUIEventSelFriend);
	giveFlowerBtn:SetLuaDelegate(p.OnUIEventGiveFlower);
	--chatBtn:SetLuaDelegate();
	--compareBtn:SetLuaDelegate();	
	
end



---------------
--UI事件处理回调函数
---------------
function p.OnUIEventGiveFlower(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	    local flag = 1;
		--判断今天是否赠送过了
		if flag == 0 then
		    MsgFriend.SendOpenGiveFlower(friendId);
		else
			CommonDlg.ShowTipInfo("提示", "您今天已经赠送过鲜花了!", nil, 2);
		end
		
	end
	
	return true;
end

function p.OnUIEventDelFriend(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
        CommonDlg.ShowNoPrompt(string.format("确定删除好友%s吗？",friendName), p.OnCommonDlgDelFriend, true);
	end
	
	return true;
end

function p.OnUIEventSelFriend(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		--获取玩家宠物id列表
	    local idTable = RolePetUser.GetPetListPlayer(friendId);
	    if not CheckT(idTable) then
		    MsgFriend.SendSelFriend(friendId,friendName);
		else 
		    FriendAttrUI.LoadUI(friendId);
	    end
	end
	
	return true;
end





function p.OnCommonDlgDelFriend(nId, nEvent, param)
	if nEvent == CommonDlg.EventOK then
         MsgFriend.SendFriendDel(friendId,friendName);
	end
end	




