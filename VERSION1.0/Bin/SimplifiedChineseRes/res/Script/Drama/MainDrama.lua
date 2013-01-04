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

local NAME_MONSTER1001 = GetTxtPri("MD_T1");
local NAME_MONSTER1002 = GetTxtPri("MD_T2");
local NAME_MONSTER1003 = GetTxtPri("MD_T3");
local NAME_MONSTER1004 = GetTxtPri("MD_T4");


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
	{ GetTxtPri("MD_T5"), GetTxtPri("MD_T6") },
	{ GetTxtPri("MD_T7"), GetTxtPri("MD_T8") },
	{ GetTxtPri("MD_T9"), GetTxtPri("MD_T10") },
	{ GetTxtPri("MD_T11"), GetTxtPri("MD_T12") },
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
	DramaSetLChatName(GetTxtPri("MD_T13"), 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T14"), 7, 0xffffff);
	p.DramaSetLChatHead(111);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T15"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T16"), 14, 0xff0000);
	DramaSetRChatContent(GetTxtPri("MD_T17"), 7, 0xffffff);
	p.DramaSetRChatHead(111);
	DramaWaitPrevActionFinishAndClick();

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T18"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T16"), 14, 0xff0000);
	DramaSetRChatContent(GetTxtPri("MD_T19"), 7, 0xffffff);
	p.DramaSetRChatHead(111);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T20"), 7, 0xffffff);
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
	DramaSetLChatContent(GetTxtPri("MD_T21"), 7, 0xffffff);
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
	DramaSetRChatName(GetTxtPri("MD_T22"), 9, 0xffde00);
	DramaSetRChatContent("走开，走开，你个臭熊怪……", 7, 0xffffff);
	p.DramaSetRChatHead(413);
	DramaWaitPrevActionFinishAndClick();
	
	--=====移回摄像头===----
	DramaMoveCamera(15, 10, SPRITE_MOVE_STEP*4);
	DramaSetWaitTime(1);

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T23"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T22"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T24"), 7, 0xffffff);
	p.DramaSetRChatHead(413);
	DramaWaitPrevActionFinishAndClick();
	
	
	DramaMoveSprite(nNpcKey, 18, 12, SPRITE_MOVE_STEP*2);
	DramaSetWaitTime(2);
	DramaSetSpriteAni(nNpcKey, 0);	--npc设定站定动作
	
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T25"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T22"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T26"), 7, 0xffffff);
	p.DramaSetRChatHead(413);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseRChatDlg();
	DramaSetSpriteAni(nNpcKey, 9);
	DramaWaitPrevActionFinish()
	
	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene(GetTxtPri("MD_T27"), 11, 0xffffff);
	DramaSetWaitTime(3.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--	
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T28"), 7, 0xffffff);
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
	DramaSetLChatContent(GetTxtPri("MD_T29"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();

	--====移动摄像机====-- X（0～max）  Y（10） 不能越界 否则不会移动
	--DramaMoveCamera(16, 10, SPRITE_MOVE_STEP*2);
	--====移动摄像机====--
		
	--==等待2秒 设定站定状态==-- 
	DramaSetWaitTime(1);

	
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T30"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T41"), 7, 0xffffff);
	p.DramaSetRChatHead(434);
	DramaWaitPrevActionFinishAndClick();
	

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T42"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T30"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T43"), 7, 0xffffff);
	p.DramaSetRChatHead(434);
	DramaWaitPrevActionFinishAndClick();
	
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T44"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T30"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T45"), 7, 0xffffff);
	p.DramaSetRChatHead(434);
	DramaWaitPrevActionFinishAndClick();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene(string.format(GetTxtPri("MD_T46"),p.GetPlayerName()), 11, 0xffffff);
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
	DramaSetLChatContent(GetTxtPri("MD_T47"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene(GetTxtPri("MD_T48"), 11, 0xffffff);
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
	DramaSetRChatName(GetTxtPri("MD_T49"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T50"), 7, 0xffffff);
	p.DramaSetRChatHead(811);
	DramaWaitPrevActionFinishAndClick();


	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T51"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T49"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T52"), 7, 0xffffff);
	p.DramaSetRChatHead(811);
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T53"), 7, 0xffffff);
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
	DramaSetRChatName(GetTxtPri("MD_T54"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T55"), 7, 0xffffff);
	p.DramaSetRChatHead(213);
	
	DramaWaitPrevActionFinishAndClick();

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T56"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T57"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T58"), 7, 0xffffff);
	p.DramaSetRChatHead(814);
	DramaWaitPrevActionFinishAndClick();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene(GetTxtPri("MD_T59"), 11, 0xffffff);
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
	DramaSetLChatContent(GetTxtPri("MD_T60"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T57"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T61"), 7, 0xffffff);
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
	DramaSetLChatContent(GetTxtPri("MD_T62"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T63"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T64"), 7, 0xffffff);
	p.DramaSetRChatHead(213);
	DramaWaitPrevActionFinishAndClick();

	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T65"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T63"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T66"), 7, 0xffffff);
	p.DramaSetRChatHead(213);
	DramaWaitPrevActionFinishAndClick();
	
	
	DramaCloseRChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T67"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene(GetTxtPri("MD_T68"), 11, 0xffffff);
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
	nZJKey = DramaAddSprite(21300009, Drama.SpriteTypeNpc, false, GetTxtPri("MD_T69"));
	DramaSetSpritePosition(nZJKey, 15, 12);
	DramaSetSpriteAni(nZJKey, 2);
	
	--周仓
	nZCKey = DramaAddSprite(21400029, Drama.SpriteTypeNpc, true, GetTxtPri("MD_T49"));
	DramaSetSpritePosition(nZCKey, 4, 10);
	DramaSetSpriteAni(nZCKey, 2);	
	--马腾
	nMTKey = DramaAddSprite(21100019, Drama.SpriteTypeNpc, true, GetTxtPri("MD_T57"));
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
		DramaSetSpriteAni(tDieEffect[i], 0);
	end
	
	DramaSetWaitTime(0.6);
	
	for  i,v in pairs(tDieEffect) do 
		DramaRemoveSprite(tDieEffect[i]);
	end
	
	DramaSetSpriteAni(nZJKey, 2);
	--===============--
	

	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T70"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T69"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T71"), 7, 0xffffff);
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
			DramaSetSpriteAni(tKeyThunder[j], 0);
			
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
			DramaSetSpriteAni(nDieEffect, 0);
		end
		
		if i == 5 then
			DramaRemoveSprite(nDieEffect);
		end
	end
	
	
	DramaSetWaitTime(1);

	--主角被雷劈
	nEffectKeyThunder = DramaAddSpriteWithFile("sm_effect_16.spr");
	DramaSetSpritePosition(nEffectKeyThunder, 7, 12);
	DramaSetSpriteAni(nEffectKeyThunder, 0);
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
	DramaSetLChatContent(GetTxtPri("MD_T72"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	
	DramaCloseLChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatName(GetTxtPri("MD_T73"), 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T74"), 7, 0xffffff);
	p.DramaSetLChatHead(612)
	DramaWaitPrevActionFinishAndClick();

	DramaCloseLChatDlg();
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T75"), 7, 0xffffff);
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
	--nGYKey = DramaAddSprite(21100038, Drama.SpriteTypeNpc, true, GetTxtPri("MD_T76"));
	--DramaSetSpritePosition(nGYKey, 5, 11);
	--DramaSetSpriteAni(nGYKey, 2);
	
	--华雄
	nHXKey = DramaAddSprite(21400010, Drama.SpriteTypeNpc, false, GetTxtPri("MD_T77"));
	DramaSetSpritePosition(nHXKey, 24, 13);
	DramaSetSpriteAni(nHXKey, 0);


	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T78"), 7, 0xffffff);
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
		DramaSetSpriteAni(tEffect[i], 0);
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
	DramaSetRChatName(GetTxtPri("MD_T77"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T79"), 7, 0xffffff);
	p.DramaSetRChatHead(414);
	DramaWaitPrevActionFinishAndClick();
	DramaCloseRChatDlg();	
	
	--关羽出现
	--关羽
	nGYKey = DramaAddSprite(21100038, Drama.SpriteTypeNpc, true, GetTxtPri("MD_T76"));
	DramaSetSpritePosition(nGYKey, 0, 11);
	DramaMoveSprite(nGYKey, 6, 12, 10);
	 DramaSetWaitTime(0.5);
	DramaMoveSprite(nGYKey, 11, 13, 10);
    --DramaSetSpriteReverse(nGYKey , true);  

	DramaOpenLChatDlg();
	DramaSetLChatName(GetTxtPri("MD_T76"), 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T80"), 7, 0xffffff);
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
		DramaSetSpriteAni(tEffect[i], 0);
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
	DramaSetSpriteAni(nDieEffect, 0);
	DramaRemoveSprite(nHXKey);
	
	DramaSetWaitTime(0.3);
	DramaRemoveSprite(nDieEffect);
	
	DramaOpenLChatDlg();
	DramaSetLChatNameBySpriteKey(nManKey, 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T81"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();

	DramaOpenLChatDlg();
	DramaSetLChatName(GetTxtPri("MD_T76"), 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T82"), 7, 0xffffff);
	p.DramaSetLChatHead(431)
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
		
		
					
	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene(GetTxtPri("MD_T83"), 11, 0xffffff);
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
	nGYKey = DramaAddSprite(21100038, Drama.SpriteTypeNpc, true, GetTxtPri("MD_T76"));
	DramaSetSpritePosition(nGYKey, 9, 11);
	DramaSetSpriteAni(nGYKey, 2);

	--张飞
	nZFKey = DramaAddSprite(21100036, Drama.SpriteTypeNpc, true, GetTxtPri("MD_T84"));
	DramaSetSpritePosition(nZFKey, 9, 17);
	DramaSetSpriteAni(nZFKey, 2);

	--刘备
	nLiuBKey = DramaAddSprite(21100037, Drama.SpriteTypeNpc, true, GetTxtPri("MD_T85"));
	DramaSetSpritePosition(nLiuBKey, 11, 14);
	DramaSetSpriteAni(nLiuBKey, 2);
	
	--吕布
	nLvBKey = DramaAddSprite(21100027, Drama.SpriteTypeNpc, false, GetTxtPri("MD_T86"));
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
		DramaSetSpriteAni(tEffect[i], 0);
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
	DramaSetRChatName(GetTxtPri("MD_T86"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T87"), 7, 0xffffff);
	p.DramaSetRChatHead(412);
	DramaWaitPrevActionFinishAndClick();
	DramaCloseRChatDlg();

	--群英攻击
	DramaSetSpriteAni(nLiuBKey, 6);
	DramaSetWaitTime(0.5);	
	DramaSetSpriteAni(nLiuBKey, 2);

	DramaOpenLChatDlg();
	DramaSetLChatName(GetTxtPri("MD_T85"), 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T88"), 7, 0xffffff);
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
	DramaSetLChatContent(GetTxtPri("MD_T89"), 7, 0xffffff);
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
		DramaSetSpriteAni(tEffect[i], 0);
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
		DramaSetSpriteAni(tEffect[i], 0);
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
		DramaSetSpriteAni(tEffect[i], 0);
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
	DramaSetSpriteAni(nEffectKeyThunder, 0);
	DramaMoveSprite(nEffectKeyThunder, 15, 12, 100);
	DramaSetWaitTime(0.1);
	DramaRemoveSprite(nEffectKeyThunder);
	DramaPlaySoundEffect(1009);
	DramaSetWaitTime(0.5);
	
	DramaSetWaitTime(1);
	
					
	--======淡入淡出场景======--
	local nTransitionKey = DramaLoadEraseInOutScene(GetTxtPri("MD_T90"), 11, 0xffffff);
	DramaSetWaitTime(2.0);
	DramaRemoveEraseInOutScene(nTransitionKey);
	--======淡入淡出场景======--		
	
	DramaOpenRChatDlg();
	DramaSetRChatName(GetTxtPri("MD_T86"), 9, 0xffde00);
	DramaSetRChatContent(GetTxtPri("MD_T91"), 7, 0xffffff);
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
	DramaSetLChatContent(GetTxtPri("MD_T92"), 7, 0xffffff);
	p.DramaSetLChatHead(p.GetPlayerPetBodypic())
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();
			
	
	DramaOpenLChatDlg();
	DramaSetLChatName(GetTxtPri("MD_T76"), 9, 0xffde00);
	DramaSetLChatContent(GetTxtPri("MD_T93"), 7, 0xffffff);
	p.DramaSetLChatHead(431)
	DramaWaitPrevActionFinishAndClick();
	DramaCloseLChatDlg();

	DramaFinish();
end	








