
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
    _G.SecretShopUI.LoadUI();
end

function OpenUpgradeUI()
   CloseDlg();
   --等级不够屏蔽对话
   
	_G.EquipUpgradeUI.LoadUI();
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
        
	if _G.MainUIBottomSpeedBar.GetFuncIsOpen(113) then
		return true;
	else
		return false;	
	end
end


NpcConfig = 
{
	[10001] = {"", "这战乱一起,草药就越来越难采到了,作为一个牛逼的医生,没有药,让我压力山大啊"};
	[10002] = {"", "这年头,人才难寻啊！"};
	[10003] = {"", "十八路诸侯的盟主是谁?瞧我这么帅,当然是我啦" };
	[10004] = {"", "想要打败你的敌人就需要有犀利的武器装备！", "铁匠" ,8,IfIsOpen_10004};
	[10005] = {"", "笑迎八方来客，觅求天下知音。", "客栈", 1,};
	[10006] = {"", "冥冥之中，自有天意。"};
	[20001] = {"", "瞧瞧这汉室天下,存活不了多久了,将来天下应该是姓曹,而不是姓刘！"};
	[20002] = {"", "暗杀我会,探宝我也会,就是这看人心我怎么都学不会！"};
	[20003] = {"", "在水上战斗?没人是我的对手！"};
	[20004] = {"", "天下大势分久必合合久必分,我一定可以让这天下知道我卧龙的强大！"};
	[20005] = {"", "想要打败你的敌人就需要有犀利的武器装备！", "铁匠" ,8,};
	[20006] = {"", "笑迎八方来客，觅求天下知音。", "客栈", 1,};
	[20007] = {"", "记得每天来本商店刷新各种神秘物品哦！", "神秘商店", 7,};

};



 