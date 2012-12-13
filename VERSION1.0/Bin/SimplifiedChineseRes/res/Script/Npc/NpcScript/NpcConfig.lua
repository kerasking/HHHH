
local _G = _G;
setfenv(1, NPC);

MAX_CHAT_OPTION_NUM = 4;

function OpenKeZhang()
	LogInfo("OpenKeZhang: test2")
	CloseDlg();
	_G.RoleInvite.LoadUI();
end

function OpenSecretShop()
    CloseDlg();
    _G.SecretShopUI.LoadUI(_G.MsgShop.GroupType.MYSTERIOUS);
end

function OpenUpgradeUI()
    --[[
   CloseDlg();
   --等级不够屏蔽对话
	_G.EquipUpgradeUI.LoadUI();
    ]]
    
    CloseDlg();
    _G.SecretShopUI.LoadUI(_G.MsgShop.GroupType.SMITH);
end

NpcOptionFunc = 
{
	[1] = OpenKeZhang,
	[2] = OpenDaoJuDian,
	[3] = OpenCangKu,
	[4] = OpenYuPaiShangDian,
	[5] = OpenWuDao,
	[6] = OpenZhuangBeiDian,
	[7] = OpenSecretShop,
	[8] = OpenUpgradeUI,
	
	
};--]]


--开启功能条件判断
function IfIsOpen_10004()
	LogInfo("QBWQBW");
    --[[
	if _G.MainUIBottomSpeedBar.GetFuncIsOpen(113) then
		return true;
	else
		return false;	
	end
    ]]
    return true;
end


NpcConfig = 
{
	[10001] = {"", _G.GetTxtPri("MPF_T5")};
	[10002] = {"", _G.GetTxtPri("MPF_T6")};
	[10003] = {"", _G.GetTxtPri("MPF_T7")};
	[10004] = {"", _G.GetTxtPri("MPF_T8"), _G.GetTxtPri("MPF_T18") ,8,};
	[10005] = {"", _G.GetTxtPri("MPF_T9"), _G.GetTxtPri("MPF_T19"), 1,};
	[10006] = {"", _G.GetTxtPri("MPF_T10")};
	[20001] = {"", _G.GetTxtPri("MPF_T11")};
	[20002] = {"", _G.GetTxtPri("MPF_T12")};
	[20003] = {"", _G.GetTxtPri("MPF_T13")};
	[20004] = {"", _G.GetTxtPri("MPF_T14")};
	[20005] = {"", _G.GetTxtPri("MPF_T15"), _G.GetTxtPri("MPF_T18") ,8,};
	[20006] = {"", _G.GetTxtPri("MPF_T16"), _G.GetTxtPri("MPF_T19"), 1,};
	[20007] = {"", _G.GetTxtPri("MPF_T17"), _G.GetTxtPri("MPF_T20"), 7,};

};



 