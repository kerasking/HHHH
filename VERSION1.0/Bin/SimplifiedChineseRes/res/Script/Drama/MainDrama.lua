---------------------------------------------------
--描述: 剧情例子
--时间: 2012.4.20
--作者: jhzheng
---------------------------------------------------
Drama = {}

local p = Drama;
local LOOK_MONSTER6 = 21300013;
local LOOK_MONSTER7 = 21400029;

local LOOK_MONSTER10 = 21100019;
local LOOK_MONSTER11 = 40000090;
local LOOK_MONSTER12 = 40001700;
local LOOK_MONSTER13 = 40000600;
local LOOK_MONSTER14 = 40000600;
local LOOK_MONSTER15 = 40000300;
local LOOK_MONSTER16 = 40002900;
local LOOK_MONSTER17 = 40002800;
local LOOK_MONSTER18 = 40002900;
local LOOK_MONSTER19 = 40002900;
local LOOK_MONSTER20 = 40002800;
local LOOK_MONSTER21 = 40003000;
local LOOK_MONSTER22 = 40003000;
local LOOK_MONSTER23 = 40002800;
local LOOK_MONSTER24 = 40000600;
local LOOK_MONSTER25 = 40000700;
local LOOK_MONSTER26 = 40001600;
local LOOK_MONSTER27 = 20300200;
local LOOK_MONSTER28 = 20200200;
local LOOK_MONSTER29 = 40001600;
local LOOK_MONSTER30 = 40001100;
local LOOK_MONSTER31 = 20300400;
local LOOK_MONSTER32 = 40002400;
local LOOK_MONSTER33 = 40002400;
local LOOK_MONSTER34 = 40002800;
local LOOK_MONSTER35 = 40002500;
local LOOK_MONSTER36 = 40001700;

local LOOK_MONSTER1001 = 20100100;
local LOOK_MONSTER1002 = 20100200;
local LOOK_MONSTER1003 = 20400100;
local LOOK_MONSTER1004 = 20300100;


local FILE_SPRITE = GetSMResPath("animation/button.spr");

--local NAME_MAN = "李道纯";
--local NAME_WOMAN = "方子晴";
local NAME_MONSTER1 = "眼镜蛇";
local NAME_MONSTER2 = "银环蛇";
local NAME_MONSTER3 = "银环蛇王";
local NAME_MONSTER4 = "幼年熊妖";
local NAME_MONSTER5 = "成年熊妖";
local NAME_MONSTER6 = "厚背熊王";
local NAME_MONSTER7 = "疾风狼";
local NAME_MONSTER8 = "剑齿狼";
local NAME_MONSTER9 = "银狼";
local NAME_MONSTER10 = "银狼王";
local NAME_MONSTER11 = "枯木树妖";
local NAME_MONSTER12 = "铁枝树妖";
local NAME_MONSTER13 = "剧毒蜂妖";
local NAME_MONSTER14 = "蜂妖首领";
local NAME_MONSTER15 = "冥煞狂狼";
local NAME_MONSTER16 = "离火刺客";
local NAME_MONSTER17 = "离火统领";
local NAME_MONSTER18 = "影之歌";
local NAME_MONSTER19 = "精锐燎天卫";
local NAME_MONSTER20 = "燎天统领";
local NAME_MONSTER21 = "烈焰傀儡";
local NAME_MONSTER22 = "赤炎傀儡";
local NAME_MONSTER23 = "巫君";
local NAME_MONSTER24 = "暗黑蜂后";
local NAME_MONSTER25 = "刚背赤熊皇";
local NAME_MONSTER26 = "游荡沙匪";
local NAME_MONSTER27 = "灭星";
local NAME_MONSTER28 = "刺月";
local NAME_MONSTER29 = "邪月王子";
local NAME_MONSTER30 = "魔皇";
local NAME_MONSTER31 = "阎";
local NAME_MONSTER32 = "万连山";
local NAME_MONSTER33 = "万归剑使";
local NAME_MONSTER34 = "万玉山";
local NAME_MONSTER35 = "万归长老";
local NAME_MONSTER36 = "神仙茶树";

local NAME_MONSTER1001 = "华佗";
local NAME_MONSTER1002 = "周仓";
local NAME_MONSTER1003 = "马腾";
local NAME_MONSTER1004 = "韩忠";
local NAME_MONSTER1005 = "珈蓝";
local NAME_MONSTER1006 = "星云宝宝";
local NAME_MONSTER1007 = "魔帅应天情";
local NAME_MONSTER1008 = "血夜之王";
local NAME_MONSTER1009 = "英彩";
local NAME_MONSTER1010 = "诛仙";
local NAME_MONSTER1011 = "烟水一";
local NAME_MONSTER1012 = "龙道人";
local NAME_MONSTER1013 = "木道人";
local NAME_MONSTER1014 = "人皇笔";
local NAME_MONSTER1015 = "七公主";
local NAME_MONSTER1016 = "弥宝";
local NAME_MONSTER1017 = "风白羽";
local NAME_MONSTER1018 = "风瑶光";

local SPRITE_MOVE_STEP = 8;

---------主角外观------------
function p.GetPlayerLookFace()
	return GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_LOOKFACE);

end


---------称呼------------
p.TITLE_TYPE_1 = 1;
p.TITLE_TYPE_2 = 2;
p.TITLE_TYPE_3 = 3;
p.TITLE_TYPE_4 = 4;

---------玩家名称------------
function p.GetPlayerName()
	return GetRoleBasicDataS(GetPlayerId(), USER_ATTR.USER_ATTR_NAME);
end

function p.GetPlayerPetBodypic()
	local nPlayerid = GetPlayerId();
	local nPetid 	= RolePetFunc.GetMainPetId(nPlayerid)
	local nPetType = RolePet.GetPetInfoN(nPetid,PET_ATTR.PET_ATTR_TYPE);
	
	local nBodyPic =  GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.BODY_PIC);
	 LogInfo("p.GetPlayerPetBodypic nBodyPic"..nBodyPic);
	return nBodyPic;
end



p.TITLE_STR = 
{
	{ "少侠", "女侠" },
	{ "哥哥", "姐姐" },
	{ "公子", "姑娘" },
	{ "师兄", "师姐" },
};

function p.GetTitle(title_type)
	if not CheckN(title_type) or
		not p.TITLE_STR[title_type] then
		return "";
	end
	
	local nSex = (GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_LOOKFACE)/1000000)%10;
    local nIdxSex = 1;
    if nSex >= 2 and nSex < 3 then
        nIdxSex = 2;
    elseif nSex >=3 and nSex < 4 then
        nIdxSex = 3;
    elseif nSex >= 4 then
        nIdxSex = 4;
    end
	return p.TITLE_STR[title_type][nIdxSex];
end


function p.DramaSetLChatHead(nIndex)
	
	local picPath,nCol,nRow = GetBodyPotraitPicPath(nIndex)  

	if picPath ~= nil and nCol ~= nil and nRow ~= nil then
		DramaSetLChatFigure(picPath, true,nCol,nRow);
	end
end

function p.DramaSetRChatHead(nIndex)
	local picPath,nCol,nRow = GetBodyPotraitPicPath(nIndex)  

	if picPath ~= nil and nCol ~= nil and nRow ~= nil then
		DramaSetRChatFigure(picPath, false,nCol,nRow);
	end	

end


	
function p.MainDrama_6()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(1);
	DramaSetCameraPos(13, 16);

	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 13, 16);
	DramaSetSpriteAni(nManKey, 0);

	nMonsterKey = DramaAddSprite(LOOK_MONSTER6, Drama.SpriteTypeMonster, false, NAME_MONSTER6);
	LogInfo("怪物的key[%d]", nMonsterKey);
	DramaSetSpritePosition(nMonsterKey, 23, 16);
	DramaSetSpriteAni(nMonsterKey, 0);

	nNpcKey = DramaAddSprite(LOOK_MONSTER7, Drama.SpriteTypeNpc, false, NAME_MONSTER1001);
	LogInfo("npc的key[%d]", nNpcKey);
	DramaSetSpritePosition(nNpcKey, 21, 16);
	DramaSetSpriteAni(nNpcKey, 0);
	
	DramaOpenLChatDlg();
	DramaSetLChatName("貂蝉MM", 9, 0xffde00);
	DramaSetLChatContent("救命啊，救命啊！", 7, 0xffffff);
	p.DramaSetLChatHead(111);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("是貂蝉MM！厚背熊王，放开貂蝉MM，饶你不死！", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("厚背熊王", 14, 0xff0000);
	DramaSetRChatContent("什么，放开她？这貂蝉MM是仙鹤成灵，吃了她可以益寿延年，我好不容易才抓到的，怎么可能放开她？", 7, 0xffffff);
	p.DramaSetRChatHead(111);
	DramaWaitPrevActionFinishAndClick();

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("我最后警告你一次，快放开貂蝉MM！", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("厚背熊王", 14, 0xff0000);
	DramaSetRChatContent("好大的口气，竟然还敢警告我？赶紧给我滚，别怪我没提醒你，要是再来坏我好事，我将你一同煮着吃！", 7, 0xffffff);
	p.DramaSetRChatHead(111);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("这可是你自找的！", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaFinish();
end

function p.MainDrama_7()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(1);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 13, 12);
	DramaSetSpriteAni(nManKey, 0);


	nNpcKey = DramaAddSprite(LOOK_MONSTER6, Drama.SpriteTypeNpc, false, NAME_MONSTER1001);
	LogInfo("npc的key[%d]", nNpcKey);
	DramaSetSpritePosition(nNpcKey, 15, 12);
	DramaSetSpriteAni(nNpcKey, 0);
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("貂蝉MM，你没事吧？", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();

	
	
	--====移动精灵====--
	DramaMoveSprite(nNpcKey, 28, 12, SPRITE_MOVE_STEP*2);
	--====移动精灵====--

		
	
	--====移动摄像机====-- X（0～max）  Y（10） 不能越界 否则不会移动
	DramaMoveCamera(28, 10, SPRITE_MOVE_STEP*2);
	--DramaMoveCamera(32, 12, SPRITE_MOVE_STEP * 2);
	--====移动摄像机====--
	

	
	--==等待2秒 设定站定状态==-- 
	DramaSetWaitTime(2);
	DramaSetSpriteAni(nNpcKey, 0);	--npc设定站定动作

	
	DramaOpenRChatDlg();
	DramaSetRChatName("貂蝉", 9, 0xffde00);
	DramaSetRChatContent("走开，走开，你个臭熊怪……", 7, 0xffffff);
	p.DramaSetRChatHead(413);
	DramaWaitPrevActionFinishAndClick();
	
	--=====移回摄像头===----
	DramaMoveCamera(15, 10, SPRITE_MOVE_STEP*4);
	DramaSetWaitTime(1);

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("貂蝉MM，你误会了，是婆婆让我来救你的，厚背熊妖已经被我杀死了！", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("貂蝉", 9, 0xffde00);
	DramaSetRChatContent("你是婆婆派来的？我就知道婆婆一定会救我的！多谢你了！", 7, 0xffffff);
	p.DramaSetRChatHead(413);
	DramaWaitPrevActionFinishAndClick();
	
	
	DramaMoveSprite(nNpcKey, 18, 12, SPRITE_MOVE_STEP*2);
	DramaSetWaitTime(2);
	DramaSetSpriteAni(nNpcKey, 0);	--npc设定站定动作
	
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("不必客气！啊，你受伤啦？", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("貂蝉", 9, 0xffde00);
	DramaSetRChatContent("不碍事的，只是小伤……", 7, 0xffffff);
	p.DramaSetRChatHead(413);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseRChatDlg();
	DramaSetSpriteAni(nNpcKey, 9);
	DramaWaitPrevActionFinish()
	
	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene("突然，美女晕倒在地上......", 11, 0xffffff);
	DramaSetWaitTime(3.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--	
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("小蝉，小蝉……看来她伤的不轻，我得赶紧把她送回去。", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())

	
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
	
	--====提示框====--
	DramaShowTipDlg("这只是一个测试");
	--====提示框====--
	
	DramaWaitPrevActionFinishAndClick();

	DramaFinish();
end



function p.MainDrama_8()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(1);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 16, 12);
	DramaSetSpriteAni(nManKey, 0);


	nNpcKey = DramaAddSprite(LOOK_MONSTER6, Drama.SpriteTypeNpc, true, NAME_MONSTER1001);
	LogInfo("npc的key[%d]", nNpcKey);
	DramaSetSpritePosition(nNpcKey, 6, 10);
	DramaSetSpriteAni(nNpcKey, 0);
	
	--移动主角
	--====移动精灵====--
	DramaMoveSprite(nManKey, 8, 12, SPRITE_MOVE_STEP*2);
	--====移动精灵====--
	DramaSetWaitTime(0.5);
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("师傅,真是天助我也,我还打算自己冒着危险去救回妹妹,现在有刘表来请,待我击败那黄巾贼闯出名堂 有一定的实力再去救妹妹,胜算更大,妹妹身上承受的苦,定要让那老贼加倍奉还!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();

	--====移动摄像机====-- X（0～max）  Y（10） 不能越界 否则不会移动
	--DramaMoveCamera(16, 10, SPRITE_MOVE_STEP*2);
	--====移动摄像机====--
		
	--==等待2秒 设定站定状态==-- 
	DramaSetWaitTime(1);

	
	DramaOpenRChatDlg();
	DramaSetRChatName("华佗", 9, 0xffde00);
	DramaSetRChatContent("好徒儿,这或许就是传言中的天命难违了,你这一生注定不平凡啊!", 7, 0xffffff);
	p.DramaSetRChatHead(434);
	DramaWaitPrevActionFinishAndClick();
	

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("天命难违?难道师傅已经知道了什么?", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("华佗", 9, 0xffde00);
	DramaSetRChatContent("此事以后再议,相信等你遇到的时候就会明白为师所言,到时为师自会与你详细说明!", 7, 0xffffff);
	p.DramaSetRChatHead(434);
	DramaWaitPrevActionFinishAndClick();
	
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("是,师傅!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("华佗", 9, 0xffde00);
	DramaSetRChatContent("我已经派你师兄郭嘉提前下山前往颖川助你,如你有遇到难解的问题可以问你师兄,相信以你们师兄弟两人的实力此次颖川之战定能大获全胜!", 7, 0xffffff);
	p.DramaSetRChatHead(434);
	DramaWaitPrevActionFinishAndClick();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene("于是,"..p.GetPlayerName().."带上行囊随左中郎刘表下山去了", 11, 0xffffff);
	DramaSetWaitTime(2.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--
	DramaFinish();
end


function p.MainDrama_9()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(3);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 13, 12);
	DramaSetSpriteAni(nManKey, 0);
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("咦,前方有一个人躺着的身影,看起来有几分眼熟,难道还有黄巾军埋伏在此处,赶紧去看看!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene("靠近后发现原来是我军一个身受重伤的将士,你将背起后护送回城….", 11, 0xffffff);
	DramaSetWaitTime(2.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--
	
	DramaRemoveSprite(nManKey);
	
	DramaLoadScene(5);	

	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 13, 12);
	DramaSetSpriteAni(nManKey, 0);
		
	nNpcKey = DramaAddSprite(LOOK_MONSTER7, Drama.SpriteTypeNpc, false, NAME_MONSTER1002);
	LogInfo("npc的key[%d]", nNpcKey);
	DramaSetSpritePosition(nNpcKey, 16, 12);
	DramaSetSpriteAni(nNpcKey, 0);
	
	DramaOpenRChatDlg();
	DramaSetRChatName("周仓", 9, 0xffde00);
	DramaSetRChatContent("我是周仓,原本是颖川城中守将.... 此次颖川城准备不足,防守力量薄弱被黄巾军攻破,全城将士死的只剩下我一人!", 7, 0xffffff);
	p.DramaSetRChatHead(811);
	DramaWaitPrevActionFinishAndClick();


	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("你怎么会这么狼狈,受伤这么严重,到底发生什么事? 左中郎刘表已经率兵前来平乱,我受师傅华佗嘱咐.下山助他退敌!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("周仓", 9, 0xffde00);
	DramaSetRChatContent("竟然是隐者华佗之徒吗,怪不得首战如此轻易获胜..看来我颖川城有救了.全靠将军此次我才能脱困,如若将军不嫌弃,愿追随将军一同征战沙场,也好为我一帮军中兄弟报这血海深仇!", 7, 0xffffff);
	p.DramaSetRChatHead(811);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("且先随疗伤再做打算! 能与周将军如此重情重义之人一同征战沙场是在下的荣幸!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaFinish();
end


function p.MainDrama_10()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(4);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 7, 12);
	DramaSetSpriteAni(nManKey, 0);


	nNpcKey = DramaAddSprite(LOOK_MONSTER10, Drama.SpriteTypeNpc, false, NAME_MONSTER1003);
	LogInfo("npc的key[%d]", nNpcKey);
	DramaSetSpritePosition(nNpcKey, 11, 12);
	DramaSetSpriteAni(nNpcKey, 0);
	
	local tLoLo ={}
	for i=1,9 do
		tLoLo[i] = DramaAddSprite(LOOK_MONSTER11, Drama.SpriteTypeNpc, false, "");
		DramaSetSpritePosition(tLoLo[i], 18+(i%3)*3, 9 + math.ceil(i/3)*2 );
		DramaSetSpriteAni(nNpcKey, 0);
	end
	
	
	
	
	
	--==主角攻击动作==--5受击 6攻击 0站立 2备战
	DramaSetSpriteAni(nManKey, 2);	
	DramaSetSpriteAni(nNpcKey, 0);	
	
	DramaPlaySoundEffect(1002);
	
	DramaSetWaitTime(1.0);
	
	DramaSetSpriteAni(nManKey, 6);
		
	nEffectKey = DramaAddSpriteWithFile("sm_effect_1.spr");
	DramaSetSpritePosition(nEffectKey, 12, 10);
	DramaSetSpriteAni(nEffectKey, 0);
	DramaMoveSprite(nEffectKey, 18, 10, SPRITE_MOVE_STEP*2);

	DramaSetWaitTime(0.5);
	DramaSetSpriteAni(nManKey, 0);
	DramaSetSpriteAni(nNpcKey, 5);
	--==士兵受到攻击===---
	for i,v in pairs(tLoLo) do 
		local nKey = tLoLo[i];
		DramaSetSpriteAni(nKey, 5);
	end
		
	DramaRemoveSprite(nEffectKey);
	
	DramaSetWaitTime(0.5);
	
	--====移动精灵====--
	DramaMoveSprite(nNpcKey, 16, 12, SPRITE_MOVE_STEP*2);
	--====移动精灵====--
	DramaSetWaitTime(0.5);

	
	DramaSetSpriteReverse(nNpcKey , false); 
	DramaSetSpriteAni(nNpcKey, 2);
	--===============--
	
	
	--==士兵逃跑===---
	for i,v in pairs(tLoLo) do 
		local nKey = tLoLo[i];
		DramaMoveSprite(nKey, 35, math.random(9,17), math.random(8,16));
	end
	
	
	DramaOpenRChatDlg();
	DramaSetRChatName("黄巾军士兵", 9, 0xffde00);
	DramaSetRChatContent("太厉害了！ 大家逃命啊！", 7, 0xffffff);
	p.DramaSetRChatHead(213);
	
	DramaWaitPrevActionFinishAndClick();

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("阁下得实力令人佩服,我看阁下不像其他黄巾将士,为何要为那乱党卖命!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("马腾", 9, 0xffde00);
	DramaSetRChatContent("我随黄巾军征战沙场,只因董卓扰乱朝纲祸国殃民…阁下实力出众,此战是我败了,但求能放过我手下这帮穷苦兄弟,作为首领我任由阁下处置!", 7, 0xffffff);
	p.DramaSetRChatHead(814);
	DramaWaitPrevActionFinishAndClick();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene("你放了马腾的手下", 11, 0xffffff);
	DramaSetWaitTime(2.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--

	DramaLoadScene(1);
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 7, 12);
	DramaSetSpriteAni(nManKey, 0);


	nNpcKey = DramaAddSprite(LOOK_MONSTER10, Drama.SpriteTypeNpc, false, NAME_MONSTER1003);
	LogInfo("npc的key[%d]", nNpcKey);
	DramaSetSpritePosition(nNpcKey, 10, 12);
	DramaSetSpriteAni(nNpcKey, 0);	

	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("既然是马将军兄弟,自当放行,你看这颖川之战中黄巾军屠杀百姓,已与董贼无异,我乃当世隐者华佗之徒,此次下山助刘表击破黄巾乱军,马将军不如随我一起为天下百姓苍生讨伐董贼!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("马腾", 9, 0xffde00);
	DramaSetRChatContent("多谢将军成全,原来是传奇人士华佗门下,既然将军放过我手下那帮兄弟,我自愿追随将军征战四方!", 7, 0xffffff);
	p.DramaSetRChatHead(814);
	DramaWaitPrevActionFinishAndClick();

	DramaFinish();
end


function p.MainDrama_11()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(4);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 7, 12);
	DramaSetSpriteAni(nManKey, 0);


	nNpcKey = DramaAddSprite(LOOK_MONSTER11, Drama.SpriteTypeNpc, false, NAME_MONSTER1004);
	LogInfo("npc的key[%d]", nNpcKey);
	DramaSetSpritePosition(nNpcKey, 15, 12);
	DramaSetSpriteAni(nNpcKey, 0);
	
	
	
	
	--===============--
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("久仰韩将军大名,今日一见果然名不虚传,不过我为将军现在所受到的待遇感到可惜啊! 将军实力出众,而黄巾军中所有好处都让张梁三兄弟拿了,实在为将军感到可惜啊!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("韩忠", 9, 0xffde00);
	DramaSetRChatContent("谁让这黄巾军本来就是张梁他们三兄弟带领的,我又有什么办法!", 7, 0xffffff);
	p.DramaSetRChatHead(213);
	DramaWaitPrevActionFinishAndClick();

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("非也非也,眼下正好有一条光明大道等着将军! 左中郎刘表说了,大汉皇帝为了平这黄巾之乱,悬赏能人异士,只要能帮忙剿灭黄巾军,赐一品官,赏黄金万两?", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("韩忠", 9, 0xffde00);
	DramaSetRChatContent("什么?竟然有这等好事,人不为己天诛地灭,为了老子的美好未来,拼了!赶紧帮我介绍介绍,这黄巾军的各种机密消息我都知道!", 7, 0xffffff);
	p.DramaSetRChatHead(213);
	DramaWaitPrevActionFinishAndClick();
	
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("哈哈,韩将军果然是明白人,我肯定不会让将军失望的!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene("经过一番劝说,韩忠被高官厚禄吸引,答应反叛为你做内应", 11, 0xffffff);
	DramaSetWaitTime(2.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--

	DramaFinish();
end



--张角被灭
function p.MainDrama_12()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(5);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 7, 12);
	DramaSetSpriteAni(nManKey, 0);


	--张角
	nZJKey = DramaAddSprite(21300009, Drama.SpriteTypeNpc, false, "张角");
	DramaSetSpritePosition(nZJKey, 15, 12);
	DramaSetSpriteAni(nZJKey, 2);
	
	--周仓
	nZCKey = DramaAddSprite(21400029, Drama.SpriteTypeNpc, true, "周仓");
	DramaSetSpritePosition(nZCKey, 4, 10);
	DramaSetSpriteAni(nZCKey, 2);	
	--马腾
	nMTKey = DramaAddSprite(21100019, Drama.SpriteTypeNpc, true, "马腾");
	DramaSetSpritePosition(nMTKey, 4, 14);
	DramaSetSpriteAni(nMTKey, 2);
	
	
	--小兵
	local tLoLo ={}
	for i=1,3 do
		tLoLo[i] = DramaAddSprite(LOOK_MONSTER11, Drama.SpriteTypeNpc, false, "");
		DramaSetSpritePosition(tLoLo[i], 18, 9 + 2*(i%3) );
		DramaSetSpriteAni(tLoLo[i], 2);
	end	
	
	
	--==主角攻击动作==--5受击 6攻击 0站立 2备战
	DramaSetWaitTime(1.0);
	
	DramaSetSpriteAni(nMTKey, 6);
		
	nEffectKey = DramaAddSpriteWithFile("sm_effect_1.spr");
	DramaSetSpritePosition(nEffectKey, 12, 10);
	DramaSetSpriteAni(nEffectKey, 0);

	DramaMoveSprite(nEffectKey, 19, 10, 16);

	DramaSetWaitTime(0.5);
	
	DramaSetSpriteAni(nZJKey, 5);
	DramaSetSpriteAni(nMTKey, 2);
	
	
	
	--==士兵受到攻击===---
	for i,v in pairs(tLoLo) do 
		local nKey = tLoLo[i];
		
		DramaSetSpriteAni(nKey, 5);
	end
		
		
	
	DramaRemoveSprite(nEffectKey);
	
	DramaSetWaitTime(0.7);
	
	for i,v in pairs(tLoLo) do 
		local nKey = tLoLo[i];
		DramaSetSpriteAni(nKey, 0);
	end
	DramaSetSpriteAni(nZJKey, 0);

	

		
	for  i,v in pairs(tLoLo) do 
		DramaRemoveSprite(tLoLo[i]);
	end
	DramaSetWaitTime(0.1);
	--死亡光效
	local tDieEffect = {}
	for  i=1,3 do 
		tDieEffect[i]= DramaAddSpriteWithFile("die_action.spr");
		DramaSetSpritePosition(tDieEffect[i], 18, 9 + 2*(i%3));
	end
	
	DramaSetWaitTime(0.6);
	
	for  i,v in pairs(tDieEffect) do 
		DramaRemoveSprite(tDieEffect[i]);
	end
	
	DramaSetSpriteAni(nZJKey, 2);
	--===============--
	

	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("贼人张角,你的黄巾军已被剿灭,还不速速受死!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("张角", 9, 0xffde00);
	DramaSetRChatContent("哼,此次是我小看了你~不过我天公将军自会让你们为此付出代价的!", 7, 0xffffff);
	p.DramaSetRChatHead(421);
	DramaWaitPrevActionFinishAndClick();
	DramaCloseRChatDlg();
	
	local nDieEffect = 0;
	for i=1,5 do
		
		local nRandomTime = math.random(1,3);
		local tKeyThunder = {};
		for j= 1 ,nRandomTime do
			tKeyThunder[j] = DramaAddSpriteWithFile("sm_effect_16.spr");
			DramaSetSpritePosition(tKeyThunder[j], 15+math.random(-3,3), 12+math.random(-2,2));
			
			--随机雷击音效
			if math.random(1,3) ==1 then
				 DramaPlaySoundEffect(1009);
			end
		end
		DramaSetWaitTime(0.5);
		
		for j= 1 ,nRandomTime do
			DramaRemoveSprite(tKeyThunder[j]);
		end
		
		if i == 3 then
			
		
		end
		
		if i == 4 then
			DramaRemoveSprite(nZJKey);
			nDieEffect= DramaAddSpriteWithFile("die_action.spr");
			DramaSetSpritePosition(nDieEffect, 15, 11);
		end
		
		if i == 5 then
			DramaRemoveSprite(nDieEffect);
		end
	end
	
	
	DramaSetWaitTime(1);

	--主角被雷劈
	nEffectKeyThunder = DramaAddSpriteWithFile("sm_effect_16.spr");
	DramaSetSpritePosition(nEffectKeyThunder, 7, 12);
	DramaSetWaitTime(0.5);
	DramaSetWaitTime(0.5);
	DramaSetSpriteAni(nManKey, 5);
	DramaRemoveSprite(nEffectKeyThunder);
	DramaSetWaitTime(0.5);
	DramaSetSpriteAni(nManKey, 0);
	DramaPlaySoundEffect(1009);
	
	DramaSetWaitTime(0.5);


	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("怎么回事, 手心突然火烧般疼痛，眼前幻想突生，冲天的火光，无边的杀戮，手心中多了一个五芒星状的金色印记,这是怎么回事!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatName("郭嘉", 9, 0xffde00);
	DramaSetLChatContent("妖道张角，临死前以20万黄巾军士兵魂魄为引引动天象，中天之上紫薇星光被破军掩去，这下不好了……看来这就是师傅所说的天命了,此番事了之后你赶紧去找师傅了解详情", 7, 0xffffff);
	p.DramaSetLChatHead(612)
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("是了,我在下山之前师傅好像隐约说过天命此事,此番事了之后我马上去找师傅!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaFinish();
end




--斩华雄
function p.MainDrama_13()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(6);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 8, 13);
	DramaSetSpriteAni(nManKey, 2);


	--关羽
	--nGYKey = DramaAddSprite(21100038, Drama.SpriteTypeNpc, true, "关羽");
	--DramaSetSpritePosition(nGYKey, 5, 11);
	--DramaSetSpriteAni(nGYKey, 2);
	
	--华雄
	nHXKey = DramaAddSprite(21400010, Drama.SpriteTypeNpc, false, "华雄");
	DramaSetSpritePosition(nHXKey, 24, 13);
	DramaSetSpriteAni(nHXKey, 0);


	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("华雄小儿,还不速速受死…", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
	
	--==主角攻击动作==--5受击 6攻击 0站立 2备战
	DramaSetWaitTime(1.0);	
	DramaSetSpriteAni(nManKey, 6);
	DramaSetSpriteAni(nHXKey, 2);

	nEffectKey = DramaAddSpriteWithFile("sm_effect_1.spr");
	DramaSetSpritePosition(nEffectKey, 12, 11);
	DramaSetSpriteAni(nEffectKey, 0);
	DramaMoveSprite(nEffectKey, 24, 11, 18);

	DramaSetWaitTime(0.3);	
	DramaRemoveSprite(nEffectKey);
	DramaSetSpriteAni(nManKey, 2);
	
	--被打了反击动作
	DramaSetSpriteAni(nHXKey, 6);
    DramaSetWaitTime(0.5);
	DramaSetSpriteAni(nHXKey, 0);
	
	
	--===华雄攻击====--
	DramaSetWaitTime(0.5);	
	DramaSetSpriteAni(nHXKey, 6);
	DramaSetSpriteAni(nManKey, 2);
	DramaPlaySoundEffect(1005);
	local tEffect = {}
	for i =1,5 do
		tEffect[i] = DramaAddSpriteWithFile("sm_effect_2.spr");
		DramaSetSpritePosition(tEffect[i], 22+(i-3)*(i-3), 11);
		DramaMoveSprite(tEffect[i], 7, 6+i*2, 28);
	end

	DramaSetWaitTime(0.001);

	for i =1,5 do
		DramaRemoveSprite(tEffect[i]);
	end
		
	
	DramaSetSpriteAni(nHXKey, 0);


	--主角受击
	DramaSetSpriteAni(nManKey, 5);
    DramaSetWaitTime(0.4);
	DramaSetSpriteAni(nManKey, 2);
	
	
	DramaOpenRChatDlg();
	DramaSetRChatName("华雄", 9, 0xffde00);
	DramaSetRChatContent("哼,无知小儿,看起来就是一副弱不禁风的模样,不配死在我刀下~换个人来!", 7, 0xffffff);
	p.DramaSetRChatHead(414);
	DramaWaitPrevActionFinishAndClick();
	DramaCloseRChatDlg();	
	
	--关羽出现
	--关羽
	nGYKey = DramaAddSprite(21100038, Drama.SpriteTypeNpc, true, "关羽");
	DramaSetSpritePosition(nGYKey, 0, 11);
	DramaMoveSprite(nGYKey, 6, 12, 10);
	 DramaSetWaitTime(0.5);
	DramaMoveSprite(nGYKey, 11, 13, 10);
    --DramaSetSpriteReverse(nGYKey , true);  

	DramaOpenLChatDlg();
	DramaSetLChatName("关羽", 9, 0xffde00);
	DramaSetLChatContent("关某前来领教", 7, 0xffffff);
	p.DramaSetLChatHead(431)
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
	
	--关羽大招
	DramaSetWaitTime(0.5);	
	DramaSetSpriteAni(nGYKey, 6);
	DramaSetSpriteAni(nHXKey, 2);
	DramaPlaySoundEffect(1005);
	local tEffect = {}
	for i =1,5 do
		tEffect[i] = DramaAddSpriteWithFile("sm_effect_6.spr");
		DramaSetSpritePosition(tEffect[i], 6+(i-3)*(i-3), 11);
		DramaMoveSprite(tEffect[i], 28, 6+i*2, 28);
	end

	DramaSetWaitTime(0.001);

	for i =1,5 do
		DramaRemoveSprite(tEffect[i]);
	end
		
	
	DramaSetSpriteAni(nGYKey, 0);
			
	--华雄受击
	DramaSetSpriteAni(nHXKey, 5);
    DramaSetWaitTime(0.3);
	
	--华雄死亡
	local nDieEffect= DramaAddSpriteWithFile("die_action.spr");
	DramaSetSpritePosition(nDieEffect, 24, 12);
	DramaRemoveSprite(nHXKey);
	
	DramaSetWaitTime(0.3);
	DramaRemoveSprite(nDieEffect);
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("关将军威猛,一刀就斩下那华雄首级…", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();

	DramaOpenLChatDlg();
	DramaSetLChatName("关羽", 9, 0xffde00);
	DramaSetLChatContent("能和将军联手作战真是人生一大乐事!", 7, 0xffffff);
	p.DramaSetLChatHead(431)
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
		
		
					
	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene("你和关羽提着华雄首级回营复命", 11, 0xffffff);
	DramaSetWaitTime(2.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--	

	DramaFinish();
	
end	


--三英战吕布
function p.MainDrama_14()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(7);
	DramaSetCameraPos(10, 10);
	
	nManKey = DramaAddSprite(p.GetPlayerLookFace(), Drama.SpriteTypePlayer, true, p.GetPlayerName());
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 5, 14);
	DramaSetSpriteAni(nManKey, 2);


	--关羽
	nGYKey = DramaAddSprite(21100038, Drama.SpriteTypeNpc, true, "关羽");
	DramaSetSpritePosition(nGYKey, 9, 11);
	DramaSetSpriteAni(nGYKey, 2);

	--张飞
	nZFKey = DramaAddSprite(21100036, Drama.SpriteTypeNpc, true, "张飞");
	DramaSetSpritePosition(nZFKey, 9, 17);
	DramaSetSpriteAni(nZFKey, 2);

	--刘备
	nLiuBKey = DramaAddSprite(21100037, Drama.SpriteTypeNpc, true, "刘备");
	DramaSetSpritePosition(nLiuBKey, 11, 14);
	DramaSetSpriteAni(nLiuBKey, 2);
	
	--吕布
	nLvBKey = DramaAddSprite(21100027, Drama.SpriteTypeNpc, false, "吕布");
	DramaSetSpritePosition(nLvBKey, 24, 14);
	DramaSetSpriteAni(nLvBKey, 0);
	

	--吕布大招
	DramaSetWaitTime(1);	
	DramaSetSpriteAni(nLvBKey, 6);
	DramaSetSpriteAni(nManKey, 2);
	DramaPlaySoundEffect(1005);
	local tEffect = {}
	for i =1,3 do
		tEffect[i] = DramaAddSpriteWithFile("sm_effect_5.spr");
		DramaSetSpritePosition(tEffect[i], 22+(i-2)*(i-2), 12);
		DramaMoveSprite(tEffect[i], 7, 6+i*3, 35);
	end

	DramaSetWaitTime(0.001);

	for i =1,3 do
		DramaRemoveSprite(tEffect[i]);
	end
		
	
	DramaSetSpriteAni(nLvBKey, 0);


	--主角受击
	
	DramaSetSpriteAni(nLiuBKey, 5);
	
	DramaSetWaitTime(0.3);
	DramaSetSpriteAni(nGYKey, 5);
	DramaSetSpriteAni(nZFKey, 5);
	DramaSetSpriteAni(nLiuBKey, 2);	
	
	DramaSetWaitTime(0.3);
	DramaSetSpriteAni(nManKey, 5);
	DramaSetSpriteAni(nZFKey, 2);	
	DramaSetSpriteAni(nGYKey, 2);	
	
    DramaSetWaitTime(0.3);
	DramaSetSpriteAni(nManKey, 2);	


	DramaOpenRChatDlg();
	DramaSetRChatName("吕布", 9, 0xffde00);
	DramaSetRChatContent("你们也许能侥幸击败华雄,但是想凭借这种实力击败我吕布,那就是自不量力了!", 7, 0xffffff);
	p.DramaSetRChatHead(412);
	DramaWaitPrevActionFinishAndClick();
	DramaCloseRChatDlg();

	--群英攻击
	DramaSetSpriteAni(nLiuBKey, 6);
	DramaSetWaitTime(0.5);	
	DramaSetSpriteAni(nLiuBKey, 2);

	DramaOpenLChatDlg();
	DramaSetLChatName("刘备", 9, 0xffde00);
	DramaSetLChatContent("我兄弟三人愿领教你的实力!", 7, 0xffffff);
	p.DramaSetLChatHead(424)
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
		
	DramaSetSpriteAni(nGYKey, 6);
	DramaSetWaitTime(0.5);	
	DramaSetSpriteAni(nGYKey, 2);
		
	DramaSetSpriteAni(nZFKey, 6);
	DramaSetWaitTime(0.5);	
	DramaSetSpriteAni(nZFKey, 2);

		
	DramaSetSpriteAni(nManKey, 6);
	DramaSetWaitTime(0.5);	
	DramaSetSpriteAni(nManKey, 2);

	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("有刘关张三英在,岂容你如此放肆!", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
		
	--吕布大招
	DramaSetWaitTime(1);	
	DramaSetSpriteAni(nLvBKey, 6);
	DramaSetSpriteAni(nManKey, 2);
	
	local tEffect = {}
	for i =1,5 do
		tEffect[i] = DramaAddSpriteWithFile("sm_effect_5.spr");
		DramaSetSpritePosition(tEffect[i], 22+(i-3)*(i-3), 12+math.random(-5,5));
		DramaMoveSprite(tEffect[i], 7, 12+math.random(-5,5), 35);
	end
	DramaPlaySoundEffect(1005);
	
	
	DramaSetWaitTime(0.001);

	for i =1,5 do
		DramaRemoveSprite(tEffect[i]);
	end

	DramaSetSpriteAni(nLiuBKey, 5);
	DramaSetSpriteAni(nGYKey, 5);
	DramaSetSpriteAni(nZFKey, 5);	
	DramaSetSpriteAni(nManKey, 5);	
		
	
	local tEffect = {}
	for i =1,7 do
		tEffect[i] = DramaAddSpriteWithFile("sm_effect_5.spr");
		DramaSetSpritePosition(tEffect[i], 22+(i-4)*(i-4), 12+math.random(-5,5));
		DramaMoveSprite(tEffect[i], 7, 12+math.random(-5,5), 35);
	end
	DramaPlaySoundEffect(1005);
	
	DramaSetWaitTime(0.001);
	DramaSetSpriteAni(nLiuBKey, 2);	
	DramaSetSpriteAni(nZFKey, 2);	
	DramaSetSpriteAni(nGYKey, 2);	
	DramaSetSpriteAni(nManKey, 2);	
	
	for i =1,7 do
		DramaRemoveSprite(tEffect[i]);
	end	
	
	local tEffect = {}
	for i =1,9 do
		tEffect[i] = DramaAddSpriteWithFile("sm_effect_6.spr");
		DramaSetSpritePosition(tEffect[i], 22+(i-5)*(i-5), 12+math.random(-5,5));
		DramaMoveSprite(tEffect[i], 7, 12+math.random(-5,5), 35);
	end
	
	DramaSetSpriteAni(nLiuBKey, 5);
	DramaSetSpriteAni(nGYKey, 5);
	DramaSetSpriteAni(nZFKey, 5);	
	DramaSetSpriteAni(nManKey, 5);	
	DramaPlaySoundEffect(1005);
	DramaSetWaitTime(0.001);

	for i =1,9 do
		DramaRemoveSprite(tEffect[i]);
	end		
	DramaSetSpriteAni(nLvBKey, 0);	
	
	DramaSetWaitTime(0.4);
	

	--主角受击
	DramaSetWaitTime(0.3);
	DramaSetSpriteAni(nLiuBKey, 2);	
	DramaSetSpriteAni(nZFKey, 2);	
	DramaSetSpriteAni(nGYKey, 2);	
	DramaSetSpriteAni(nManKey, 2);		
	
	--雷击特效
	DramaSetWaitTime(0.3);
	
			
	nEffectKeyThunder = DramaAddSpriteWithFile("sm_effect_16.spr");
	DramaSetSpritePosition(nEffectKeyThunder, 15, 5);
	DramaMoveSprite(nEffectKeyThunder, 15, 12, 100);
	DramaSetWaitTime(0.1);
	DramaRemoveSprite(nEffectKeyThunder);
	DramaPlaySoundEffect(1009);
	DramaSetWaitTime(0.5);
	
	DramaSetWaitTime(1);
	
					
	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene("你手上的金色命轮突然散发出耀眼的光芒…", 11, 0xffffff);
	DramaSetWaitTime(2.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--		
	
	DramaOpenRChatDlg();
	DramaSetRChatName("吕布", 9, 0xffde00);
	DramaSetRChatContent("这…这是什么情况,撤,快撤…", 7, 0xffffff);
	p.DramaSetRChatHead(412);
	DramaWaitPrevActionFinishAndClick();
	DramaCloseRChatDlg();
		
	--吕布撤退
	DramaMoveSprite(nLvBKey, 50, 12, 40);
	DramaSetWaitTime(0.1);
	DramaSetSpriteAni(nLiuBKey, 0);	
	DramaSetSpriteAni(nZFKey, 0);	
	DramaSetSpriteAni(nGYKey, 0);	
	DramaSetSpriteAni(nManKey, 0);	
		

	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent("战神吕布果然勇猛,有你们三兄弟相助才能侥幸获胜", 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
			
	
	DramaOpenLChatDlg();
	DramaSetLChatName("关羽", 9, 0xffde00);
	DramaSetLChatContent("将军过谦了,此次能获胜全靠将军…", 7, 0xffffff);
	p.DramaSetLChatHead(431)
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();

	DramaFinish();
end	








