---------------------------------------------------
--描述: 剧情例子
--时间: 2012.4.20
--作者: jhzheng
---------------------------------------------------
Drama = {}

local p = Drama;

local LOOK_MAN = 1000000;
local LOOK_WOMAN = 2000000;
local LOOK_MONSTER = 104000000;
local LOOK_NPC = 9000000;
local FILE_SPRITE = GetSMResPath("animation/button.spr");

local NAME_MAN = "李道纯";
local NAME_WOMAN = "方子晴";
local NAME_MONSTER = "熊";
local NAME_NPC = "NPC测试";

local SPRITE_MOVE_STEP = 8;

---------主角外观------------
function p.GetPlayerLookFace()
	return LOOK_MAN;
end

---------称呼------------
p.TITLE_TYPE_1 = 1;
p.TITLE_TYPE_2 = 2;

---------玩家名称------------
function p.GetPlayerName()
	return NAME_MAN;
end

p.TITLE_STR = 
{
	[p.TITLE_TYPE_1]	= { "少侠", "女侠" },
	[p.TITLE_TYPE_2]	= { "哥哥", "姐姐" },
};

function p.GetTitle(title_type)
	if not CheckN(title_type) or
		not p.TITLE_STR[title_type] then
		return "";
	end
	
	local nSex = 0;
	
	if not CheckS(p.TITLE_STR[title_type][nSex]) then
		return "";
	end
	
	return p.TITLE_STR[title_type][nSex];
end

function p.Example1()
	local nMapId = GetMapId();
	local nManKey = 0;
	local nWomanKey = 0;
	local nNpcKey = 0;
	local nMonsterKey = 0;
	local nSpriteKey = 0;
	local nManKey2 = 0;
	local nSpriteKey2 = 0;
	
	DramaStart();
	DramaLoadScene(nMapId);
	DramaSetCameraPos(37, 14);
	
	nManKey = DramaAddSprite(LOOK_MAN, Drama.SpriteTypePlayer, true, NAME_MAN);
	LogInfo("精灵的key[%d]", nManKey);
	DramaSetSpritePosition(nManKey, 31, 14);
	DramaSetSpriteAni(nManKey, 0);
	
	nWomanKey = DramaAddSprite(LOOK_WOMAN, Drama.SpriteTypePlayer, true, NAME_WOMAN);
	LogInfo("精灵女的key[%d]", nWomanKey);
	DramaSetSpritePosition(nWomanKey, 31, 18);
	DramaSetSpriteAni(nWomanKey, 0);
	
	nNpcKey = DramaAddSprite(LOOK_NPC, Drama.SpriteTypeNpc, false, NAME_NPC);
	LogInfo("npc的key[%d]", nWomanKey);
	DramaSetSpritePosition(nNpcKey, 40, 14);
	DramaSetSpriteAni(nNpcKey, 0);
	
	nMonsterKey = DramaAddSprite(LOOK_MONSTER, Drama.SpriteTypeMonster, true, NAME_MONSTER);
	LogInfo("怪物的key[%d]", nMonsterKey);
	DramaSetSpritePosition(nMonsterKey, 38, 19);
	DramaSetSpriteAni(nMonsterKey, 0);
	
	nSpriteKey = DramaAddSpriteWithFile(FILE_SPRITE);
	LogInfo("动画的key[%d]", nSpriteKey);
	DramaSetSpritePosition(nSpriteKey, 37, 16);
	DramaSetSpriteAni(nSpriteKey, 0);
	
	DramaOpenLChatDlg();
	DramaSetLChatName("李道纯", 18, 0xff0000);
	DramaSetLChatContent("大胆,小心", 14, 0xffffff);
	DramaSetLChatFigure(GetSMImgPath("portrait/head_girl_1.png"), false);
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("方子晴", 18, 0xff0000);
	DramaSetRChatContent("小女子失礼了!", 14, 0xffffff);
	DramaSetRChatFigure(GetSMImgPath("portrait/head_boy_3.png"), true);
	
	DramaWaitPrevActionFinishAndClick();
	
	DramaMoveSprite(nManKey, 49, 17, SPRITE_MOVE_STEP);
	
	DramaMoveSprite(nMonsterKey, 50, 18, SPRITE_MOVE_STEP);
	
	DramaMoveCamera(56, 13, SPRITE_MOVE_STEP * 2);
	
	DramaWaitPrevActionFinish();
	
	DramaSetSpriteAni(nManKey, 0);
	
	DramaSetSpriteAni(nMonsterKey, 0);
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatName("王进喆", 18, 0xff0000);
	DramaSetLChatContent("哇哈哈", 14, 0xffffff);
	DramaSetLChatFigure(GetSMImgPath("portrait/head_lady_1.png"), false);
	
	DramaWaitPrevActionFinishAndClick();
	
	DramaRemoveSprite(nManKey);
	
	local nTransitionKey = DramaLoadEraseInOutScene("一股黑烟弥漫着世界, 过了一个小时....", 20, 0xff0000);
	
	DramaSetWaitTime(5.0);
	
	DramaRemoveEraseInOutScene(nTransitionKey);
	
	DramaSetCameraPos(0, 0);
	nManKey2 = DramaAddSprite(LOOK_MAN, Drama.SpriteTypePlayer, true, NAME_MAN);
	DramaSetSpritePosition(nManKey2, 3, 12);
	DramaSetSpriteAni(nManKey2, 0);
	DramaMoveSprite(nManKey2, 18, 14, SPRITE_MOVE_STEP);
	
	nSpriteKey2 = DramaAddSpriteWithFile(FILE_SPRITE);
	DramaSetSpritePosition(nSpriteKey2, 11, 11);
	DramaSetSpriteAni(nSpriteKey2, 0);
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName("关之在", 18, 0xff0000);
	DramaSetRChatContent("河东师!", 14, 0xffffff);
	DramaSetRChatFigure(GetSMImgPath("portrait/head_lady_2.png"), true);
	
	DramaWaitPrevActionFinishAndClick();
	
	DramaRemoveSprite(nSpriteKey2);
	
	DramaShowTipDlg("这只是一个测试");
	
	DramaWaitPrevActionFinishAndClick();
	
	DramaFinish();
end