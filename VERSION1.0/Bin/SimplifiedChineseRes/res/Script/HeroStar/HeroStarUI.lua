---------------------------------------------------
--描述: 将星图
--时间: 2012.6.5
--作者: qbw
---------------------------------------------------
   
HeroStarUI = {}
local p = HeroStarUI;


--青龙
local ID_TALENT_R_1_CTRL_BUTTON_10						= 10;
local ID_TALENT_R_1_CTRL_BUTTON_9						= 9;
local ID_TALENT_R_1_CTRL_BUTTON_8						= 8;
local ID_TALENT_R_1_CTRL_BUTTON_7						= 7;
local ID_TALENT_R_1_CTRL_BUTTON_6						= 6;
local ID_TALENT_R_1_CTRL_BUTTON_5						= 5;
local ID_TALENT_R_1_CTRL_BUTTON_4						= 4;
local ID_TALENT_R_1_CTRL_BUTTON_3						= 3;
local ID_TALENT_R_1_CTRL_BUTTON_2						= 2;
local ID_TALENT_R_1_CTRL_BUTTON_1						= 1;


--2
local ID_TALENT_R_2_CTRL_BUTTON_10						= 10;
local ID_TALENT_R_2_CTRL_BUTTON_9						= 9;
local ID_TALENT_R_2_CTRL_BUTTON_8						= 8;
local ID_TALENT_R_2_CTRL_BUTTON_7						= 7;
local ID_TALENT_R_2_CTRL_BUTTON_6						= 6;
local ID_TALENT_R_2_CTRL_BUTTON_5						= 5;
local ID_TALENT_R_2_CTRL_BUTTON_4						= 4;
local ID_TALENT_R_2_CTRL_BUTTON_3						= 3;
local ID_TALENT_R_2_CTRL_BUTTON_2						= 2;
local ID_TALENT_R_2_CTRL_BUTTON_1						= 1;

--3
local ID_TALENT_R_3_CTRL_BUTTON_15					= 15;
local ID_TALENT_R_3_CTRL_BUTTON_14					= 14;
local ID_TALENT_R_3_CTRL_BUTTON_13					= 13;
local ID_TALENT_R_3_CTRL_BUTTON_12					= 12;
local ID_TALENT_R_3_CTRL_BUTTON_11					= 11;
local ID_TALENT_R_3_CTRL_BUTTON_10					= 10;
local ID_TALENT_R_3_CTRL_BUTTON_9					= 9;
local ID_TALENT_R_3_CTRL_BUTTON_8					= 8;
local ID_TALENT_R_3_CTRL_BUTTON_7					= 7;
local ID_TALENT_R_3_CTRL_BUTTON_6					= 6;
local ID_TALENT_R_3_CTRL_BUTTON_5					= 5;
local ID_TALENT_R_3_CTRL_BUTTON_4					= 4;
local ID_TALENT_R_3_CTRL_BUTTON_3					= 3;
local ID_TALENT_R_3_CTRL_BUTTON_2					= 2;
local ID_TALENT_R_3_CTRL_BUTTON_1					= 1;

--4
local ID_TALENT_R_4_CTRL_BUTTON_20					= 20;
local ID_TALENT_R_4_CTRL_BUTTON_19					= 19;
local ID_TALENT_R_4_CTRL_BUTTON_18					= 18;
local ID_TALENT_R_4_CTRL_BUTTON_17					= 17;
local ID_TALENT_R_4_CTRL_BUTTON_16					= 16;
local ID_TALENT_R_4_CTRL_BUTTON_15					= 15;
local ID_TALENT_R_4_CTRL_BUTTON_14					= 14;
local ID_TALENT_R_4_CTRL_BUTTON_13					= 13;
local ID_TALENT_R_4_CTRL_BUTTON_12					= 12;
local ID_TALENT_R_4_CTRL_BUTTON_11					= 11;
local ID_TALENT_R_4_CTRL_BUTTON_10					= 10;
local ID_TALENT_R_4_CTRL_BUTTON_9					= 9;
local ID_TALENT_R_4_CTRL_BUTTON_8					= 8;
local ID_TALENT_R_4_CTRL_BUTTON_7					= 7;
local ID_TALENT_R_4_CTRL_BUTTON_6					= 6;
local ID_TALENT_R_4_CTRL_BUTTON_5					= 5;
local ID_TALENT_R_4_CTRL_BUTTON_4					= 4;
local ID_TALENT_R_4_CTRL_BUTTON_3					= 3;
local ID_TALENT_R_4_CTRL_BUTTON_2					= 2;
local ID_TALENT_R_4_CTRL_BUTTON_1					= 1;

--5
local ID_TALENT_R_5_CTRL_BUTTON_20					= 20;
local ID_TALENT_R_5_CTRL_BUTTON_19					= 19;
local ID_TALENT_R_5_CTRL_BUTTON_18					= 18;
local ID_TALENT_R_5_CTRL_BUTTON_17					= 17;
local ID_TALENT_R_5_CTRL_BUTTON_16					= 16;
local ID_TALENT_R_5_CTRL_BUTTON_15					= 15;
local ID_TALENT_R_5_CTRL_BUTTON_14					= 14;
local ID_TALENT_R_5_CTRL_BUTTON_13					= 13;
local ID_TALENT_R_5_CTRL_BUTTON_12					= 12;
local ID_TALENT_R_5_CTRL_BUTTON_11					= 11;
local ID_TALENT_R_5_CTRL_BUTTON_10					= 10;
local ID_TALENT_R_5_CTRL_BUTTON_9					= 9;
local ID_TALENT_R_5_CTRL_BUTTON_8					= 8;
local ID_TALENT_R_5_CTRL_BUTTON_7					= 7;
local ID_TALENT_R_5_CTRL_BUTTON_6					= 6;
local ID_TALENT_R_5_CTRL_BUTTON_5					= 5;
local ID_TALENT_R_5_CTRL_BUTTON_4					= 4;
local ID_TALENT_R_5_CTRL_BUTTON_3					= 3;
local ID_TALENT_R_5_CTRL_BUTTON_2					= 2;
local ID_TALENT_R_5_CTRL_BUTTON_1					= 1;


--BG
local ID_TALENT_CTRL_BUTTON_22					= 22;
local ID_TALENT_CTRL_TEXT_21						= 21;
local ID_TALENT_CTRL_LIST_20						= 20;
local ID_TALENT_CTRL_PICTURE_19					= 19;
local ID_TALENT_CTRL_PICTURE_18					= 18;
local ID_TALENT_CTRL_BUTTON_5						= 5;
local ID_TALENT_CTRL_TEXT_16						= 16;
local ID_TALENT_CTRL_PICTURE_15					= 15;
local ID_TALENT_CTRL_PICTURE_4					= 4;
local ID_TALENT_CTRL_BUTTON_6						= 6;
local ID_TALENT_CTRL_LIST_23						= 23;
local ID_TALENT_CTRL_PICTURE_2					= 2;
local ID_TALENT_CTRL_PICTURE_1					= 1;

--tip old 
--[[
local ID_TALENT_TIPS_CTRL_BUTTON_4						= 4;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_9					= 28;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_9					= 27;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_8					= 26;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_8					= 25;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_7					= 24;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_7					= 23;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_6					= 22;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_6					= 21;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_5					= 20;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_5					= 19;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_4					= 18;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_4					= 17;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_3					= 16;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_3					= 15;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_2					= 14;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_2					= 13;
local ID_TALENT_TIPS_CTRL_TEXT_NUM_1					= 12;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_1					= 11;
local ID_TALENT_TIPS_CTRL_TEXT_8						= 8;
local ID_TALENT_TIPS_CTRL_TEXT_7						= 7;
local ID_TALENT_TIPS_CTRL_TEXT_6						= 6;
local ID_TALENT_TIPS_CTRL_TEXT_5						= 5;
local ID_TALENT_TIPS_CTRL_TEXT_2						= 2;
local ID_TALENT_TIPS_CTRL_PICTURE_1						= 1;
--]]

--tip new
local ID_TALENT_TIPS_CTRL_TEXT_21						= 21;
local ID_TALENT_TIPS_CTRL_TEXT_20						= 20;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_9					= 27;
local ID_TALENT_TIPS_CTRL_TEXT_ATR_1					= 11;
local ID_TALENT_TIPS_CTRL_TEXT_5						= 5;
local ID_TALENT_TIPS_CTRL_TEXT_2						= 2;
local ID_TALENT_TIPS_CTRL_BUTTON_4						= 4;
local ID_TALENT_TIPS_CTRL_PICTURE_39					= 39;
local ID_TALENT_TIPS_CTRL_PICTURE_38					= 38;
local ID_TALENT_TIPS_CTRL_PICTURE_37					= 37;
local ID_TALENT_TIPS_CTRL_PICTURE_36					= 36;
local ID_TALENT_TIPS_CTRL_PICTURE_35					= 35;
local ID_TALENT_TIPS_CTRL_PICTURE_34					= 34;
local ID_TALENT_TIPS_CTRL_PICTURE_33					= 33;
local ID_TALENT_TIPS_CTRL_PICTURE_32					= 32;
local ID_TALENT_TIPS_CTRL_PICTURE_31					= 31;

local TAG_LAYER_STAR = 1000;--星图tag
local TAG_LAYER_ATTR = 1001;--加成属性

local TAG_LAYER_JT   = 89;  --提示升级箭头


--星星状态
local STAR_STATE_LIGHT = 1; --已经点亮
local STAR_STATE_CHOSED = 2;--选中
local STAR_STATE_DARK = 3;--未点亮




-- 界面控件坐标定义
local winsize = GetWinSize();


--选中星星位置
local g_Grade = 0;
local g_Lev = 0;

--星图配置文件
local tStarPicINI = {}
	tStarPicINI[1] = "talent/talent_R_1.ini"
	tStarPicINI[2] = "talent/talent_R_2.ini"
	tStarPicINI[3] = "talent/talent_R_3.ini"
	tStarPicINI[4] = "talent/talent_R_4.ini"
	tStarPicINI[5] = "talent/talent_R_5.ini"


local tStarList = {} --星星按钮tag列表
	tStarList[1]={}
	tStarList[1][10]= ID_TALENT_R_1_CTRL_BUTTON_10	
	tStarList[1][9] = ID_TALENT_R_1_CTRL_BUTTON_9	
	tStarList[1][8] = ID_TALENT_R_1_CTRL_BUTTON_8	
	tStarList[1][7] = ID_TALENT_R_1_CTRL_BUTTON_7
	tStarList[1][6] = ID_TALENT_R_1_CTRL_BUTTON_6
	tStarList[1][5] = ID_TALENT_R_1_CTRL_BUTTON_5
	tStarList[1][4] = ID_TALENT_R_1_CTRL_BUTTON_4
	tStarList[1][3] = ID_TALENT_R_1_CTRL_BUTTON_3
	tStarList[1][2] = ID_TALENT_R_1_CTRL_BUTTON_2
	tStarList[1][1] = ID_TALENT_R_1_CTRL_BUTTON_1


	tStarList[2]={}	
	tStarList[2][10]= ID_TALENT_R_2_CTRL_BUTTON_10
	tStarList[2][9] = ID_TALENT_R_2_CTRL_BUTTON_9
	tStarList[2][8] = ID_TALENT_R_2_CTRL_BUTTON_8
	tStarList[2][7] = ID_TALENT_R_2_CTRL_BUTTON_7
	tStarList[2][6] = ID_TALENT_R_2_CTRL_BUTTON_6
	tStarList[2][5] = ID_TALENT_R_2_CTRL_BUTTON_5
	tStarList[2][4] = ID_TALENT_R_2_CTRL_BUTTON_4
	tStarList[2][3] = ID_TALENT_R_2_CTRL_BUTTON_3
	tStarList[2][2] = ID_TALENT_R_2_CTRL_BUTTON_2
	tStarList[2][1] = ID_TALENT_R_2_CTRL_BUTTON_1

	tStarList[3]={}	
	tStarList[3][15]= ID_TALENT_R_3_CTRL_BUTTON_15
	tStarList[3][14]= ID_TALENT_R_3_CTRL_BUTTON_14
	tStarList[3][13]= ID_TALENT_R_3_CTRL_BUTTON_13
	tStarList[3][12]= ID_TALENT_R_3_CTRL_BUTTON_12
	tStarList[3][11]= ID_TALENT_R_3_CTRL_BUTTON_11
	tStarList[3][10]= ID_TALENT_R_3_CTRL_BUTTON_10
	tStarList[3][9] = ID_TALENT_R_3_CTRL_BUTTON_9	
	tStarList[3][8] = ID_TALENT_R_3_CTRL_BUTTON_8	
	tStarList[3][7] = ID_TALENT_R_3_CTRL_BUTTON_7	
	tStarList[3][6] = ID_TALENT_R_3_CTRL_BUTTON_6	
	tStarList[3][5] = ID_TALENT_R_3_CTRL_BUTTON_5	
	tStarList[3][4] = ID_TALENT_R_3_CTRL_BUTTON_4	
	tStarList[3][3] = ID_TALENT_R_3_CTRL_BUTTON_3	
	tStarList[3][2] = ID_TALENT_R_3_CTRL_BUTTON_2	
	tStarList[3][1] = ID_TALENT_R_3_CTRL_BUTTON_1	

	tStarList[4]={}	
	tStarList[4][20]= ID_TALENT_R_4_CTRL_BUTTON_20
	tStarList[4][19]= ID_TALENT_R_4_CTRL_BUTTON_19
	tStarList[4][18]= ID_TALENT_R_4_CTRL_BUTTON_18
	tStarList[4][17]= ID_TALENT_R_4_CTRL_BUTTON_17
	tStarList[4][16]= ID_TALENT_R_4_CTRL_BUTTON_16
	tStarList[4][15]= ID_TALENT_R_4_CTRL_BUTTON_15
	tStarList[4][14]= ID_TALENT_R_4_CTRL_BUTTON_14
	tStarList[4][13]= ID_TALENT_R_4_CTRL_BUTTON_13
	tStarList[4][12]= ID_TALENT_R_4_CTRL_BUTTON_12
	tStarList[4][11]= ID_TALENT_R_4_CTRL_BUTTON_11
	tStarList[4][10]= ID_TALENT_R_4_CTRL_BUTTON_10
	tStarList[4][9] = ID_TALENT_R_4_CTRL_BUTTON_9
	tStarList[4][8] = ID_TALENT_R_4_CTRL_BUTTON_8
	tStarList[4][7] = ID_TALENT_R_4_CTRL_BUTTON_7
	tStarList[4][6] = ID_TALENT_R_4_CTRL_BUTTON_6
	tStarList[4][5] = ID_TALENT_R_4_CTRL_BUTTON_5
	tStarList[4][4] = ID_TALENT_R_4_CTRL_BUTTON_4
	tStarList[4][3] = ID_TALENT_R_4_CTRL_BUTTON_3
	tStarList[4][2] = ID_TALENT_R_4_CTRL_BUTTON_2
	tStarList[4][1] = ID_TALENT_R_4_CTRL_BUTTON_1

	tStarList[5]={}	
	tStarList[5][20]= ID_TALENT_R_5_CTRL_BUTTON_20
	tStarList[5][19]= ID_TALENT_R_5_CTRL_BUTTON_19
	tStarList[5][18]= ID_TALENT_R_5_CTRL_BUTTON_18
	tStarList[5][17]= ID_TALENT_R_5_CTRL_BUTTON_17
	tStarList[5][16]= ID_TALENT_R_5_CTRL_BUTTON_16
	tStarList[5][15]= ID_TALENT_R_5_CTRL_BUTTON_15
	tStarList[5][14]= ID_TALENT_R_5_CTRL_BUTTON_14
	tStarList[5][13]= ID_TALENT_R_5_CTRL_BUTTON_13
	tStarList[5][12]= ID_TALENT_R_5_CTRL_BUTTON_12
	tStarList[5][11]= ID_TALENT_R_5_CTRL_BUTTON_11
	tStarList[5][10]= ID_TALENT_R_5_CTRL_BUTTON_10
	tStarList[5][9] = ID_TALENT_R_5_CTRL_BUTTON_9
	tStarList[5][8] = ID_TALENT_R_5_CTRL_BUTTON_8
	tStarList[5][7] = ID_TALENT_R_5_CTRL_BUTTON_7
	tStarList[5][6] = ID_TALENT_R_5_CTRL_BUTTON_6
	tStarList[5][5] = ID_TALENT_R_5_CTRL_BUTTON_5
	tStarList[5][4] = ID_TALENT_R_5_CTRL_BUTTON_4
	tStarList[5][3] = ID_TALENT_R_5_CTRL_BUTTON_3
	tStarList[5][2] = ID_TALENT_R_5_CTRL_BUTTON_2
	tStarList[5][1] = ID_TALENT_R_5_CTRL_BUTTON_1

local tStarBg = {}
	tStarBg[1] = "talent/bottom_talent1.png"
	tStarBg[2] = "talent/bottom_talent2.png"
	tStarBg[3] = "talent/bottom_talent3.png"
	tStarBg[4] = "talent/bottom_talent4.png"
	tStarBg[5] = "talent/bottom_talent5.png"

local tStarTitleInd ={}
	tStarTitleInd[1] = 2
	tStarTitleInd[2] = 1
	tStarTitleInd[3] = 4
	tStarTitleInd[4] = 3
	tStarTitleInd[5] = 5

local	g_AniGrade = nil;
local	g_AniLev = nil;
	
function p.LoadUI()
local scene = GetSMGameScene();	

	if scene == nil then
		--LogInfo("scene == nil,load PlayerStar failed!");
		return;
	end

	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.HeroStarUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	

	scene:AddChildZ(layer,1);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("talent/talent.ini", layer, p.OnUIEventStarBg, 0, 0);
	
    local animate = RecursivUISprite(layer,{TAG_LAYER_JT});
    local szAniPath = NDPath_GetAnimationPath();
    animate:ChangeSprite(szAniPath.."jiantx03.spr");
    
	
	--初始化星图界面
	--
	local containter = RecursiveSVC(layer, {ID_TALENT_CTRL_LIST_23});
	containter:SetViewSize(containter:GetFrameRect().size);
	
	containter:SetLuaDelegate(p.OnUIEventStarVC);
	for i,v in pairs(tStarPicINI) do
		local view = createUIScrollView();
	
	     view:Init(false);
	     view:SetViewId(i);
	     containter:AddView(view);
		 --view:SetFrameRect(CGRectMake(0,0,640,640));
		 
	     local uiLoad = createNDUILoad();
	     if uiLoad ~= nil then
		     --uiLoad:Load("talent/talent_R_1.ini",view,p.OnUIEventStarVC,0,0);
		     
		     uiLoad:Load(v,view,p.OnUIEventStarVC,0,0);
		     uiLoad:Free();
	     end				
	end
	--]]	
		

	--初始化星图名字列表	
	local containter = RecursiveSVC(layer, {ID_TALENT_CTRL_LIST_20});	
	containter:SetViewSize(containter:GetFrameRect().size);	
	containter:EnableScrollBar(false);
	containter:SetTouchEnabled(false);
	
	local pool = DefaultPicPool();
	
	for i,v in pairs(tStarPicINI) do
		local picName = pool:AddPicture(GetSMImgPath("talent/title_talent1.png"), false);	
		
		
		picName:Cut(CGRectMake(0.0,60*(tStarTitleInd[i]-1),100.0, 60.0 ));
		
		local view = createUIScrollView();
		view:Init(false);
		view:SetViewId(i);
		view:SetTouchEnabled(false);
		
		containter:AddView(view);
		local btn	= _G.CreateButton("", "", "", CGRectMake(0, 0, 100, 50), 12);
		btn:SetImage(picName);
		view:AddChildZ(btn,2);
	end

	
	local nRoleId =  GetPlayerId();


	--自动切换页面
    g_Grade,g_Lev = p.GetNextStarPosition();
	--LogInfo("NEXT"..g_Grade.."  "..g_Lev);
	p.ChangePage(g_Grade);	
	
	
	p.RefreshStarVC();
	p.RefreshStarInfo();
	
	--[[
	--设置玩家头像
	local nPlayerId     = GetPlayerId();
    local nPetId        = RolePetFunc.GetMainPetId(nPlayerId);
    local nPetType      = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
    local pic       = _G.GetPlayerPotraitTranPic(nPetType);
	local HeadPic = GetImage(layer, ID_TALENT_CTRL_PICTURE_4);
	

	HeadPic:SetPicture(pic,true);
	--]]	


	
	GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"p.RefreshStarInfo",p.RefreshStarInfo);
   
   
   	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_TALENT_CTRL_BUTTON_6);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	
   	--星星响应扩大
   	p.SetAllStarBoundScale()
   
    --** chh 2012-08-22 将星升级箭头提示**--
    p.TipUpgrade();
    --** 左右前头 **--
    SetArrow(p.GetLayer(),p.GetContainter(),1,ID_TALENT_CTRL_PICTURE_18,ID_TALENT_CTRL_PICTURE_19);
    
    
	return true;
end




------------------------------刷新数据-----------------------------------


function p.ChangePage(nGrade)
	local scene = GetSMGameScene();
	local container = RecursiveSVC(scene, {NMAINSCENECHILDTAG.HeroStarUI,ID_TALENT_CTRL_LIST_23});

	--local nGrade = container:GetBeginIndex()+1;
	if nGrade > 0 then
		container:ShowViewByIndex(nGrade-1);
	else
		--LogInfo("p.ChangePage(nGrade) 错误星图:"..nGrade)	
	end	
end

--显示将星加成属性
function p.desplayAttr()
	local scene = GetSMGameScene();	
	
	local bglayer = RecursiveUILayer(scene,{NMAINSCENECHILDTAG.HeroStarUI})
	
	--[[
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetTag(TAG_LAYER_ATTR);
	layer:SetFrameRect(RectFullScreenUILayer);
	

	bglayer:AddChildZ(layer,3);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end

	uiLoad:Load("talent/talent_tips.ini", layer, p.OnUIEventHeroStarAttr, 0, 0);
	--]]
	local MainPetLable = RecursiveLabel(bglayer,{45});
	
	
	local sMainPetBuffstr,sFront,sMid,sBack = p.GetHeroStarBuff();
	
	MainPetLable:SetFontSize(11);	
	MainPetLable:SetText(sMainPetBuffstr);
	

end


--** chh 提示将星升级 **--
--提示升级将星
function p.TipUpgrade()
    local scene = GetSMGameScene();
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
    local animate = RecursivUISprite(layer,{TAG_LAYER_JT});
    animate:SetVisible(HeroStar.CheckHeroStarCanUpLev());
end



--获取累积buff描述
function p.GetHeroStarBuff()
	local nRoleId =  GetPlayerId();
	
	local tStationAll = {}
	for i=0,5 do
		tStationAll[i] = 0;
	end	
		
	local tAttrAll = p.GetHeroStarBuffTable();	
	
	for nGrade,v in pairs(tStarList) do
		for nLevel,nTag in pairs(v) do			
			local lev = HeroStar.GetLevByGrade(nRoleId,nGrade)
			if  nLevel <= HeroStar.GetLevByGrade(nRoleId,nGrade) then
				----LogInfo("qbw 已经点亮 nLevel:"..nLevel.." nGrade:"..nGrade);
				--已经点亮 将值加入表
				local tCell = HeroStar.GetStarAttr(nGrade,nLevel);
		

				--===========阵型奖励======================================-----
				local nStationEffect	= 	tCell[DB_GSCONFIG.STATION_EFFECT];
				local nEffectVal 		= 	tCell[DB_GSCONFIG.EFFECT_VALUE];
				tStationAll[nStationEffect]	= 	tStationAll[nStationEffect] + nEffectVal;
				
				
							
			end
		end		
	end
	
	
	--将表转换为字符串
	local strMainPet = "";
	
	--_G.LogInfoT(tAttrAll);
	
	for nAttrType,nVal in pairs(tAttrAll) do
		if nVal > 0 then
			nVal = nVal/1000;
			strMainPet = strMainPet.."\n"..HeroStar.GetAttrName(nAttrType).."加成+"..nVal.."";
		elseif nVal <0 then
			nVal = nVal/1000;
			strMainPet = strMainPet.."\n"..HeroStar.GetAttrName(nAttrType).."减成-"..nVal.."";
		end
	end
	
	
	
	local tStationStr = {};
	tStationStr[HeroStar.FrontPosition] = "";
	tStationStr[HeroStar.MidPosition] = "";
	tStationStr[HeroStar.BackPosition] = "";		
	
	for neffect,val in pairs(tStationAll) do 
		--LogInfo("qbw 属性:"..neffect.."   val"..val);
		local sEffectDesc,nPos = HeroStar.GetStationBuffDesc(neffect);
	
		if sEffectDesc ~= nil and nPos 	~= nil and neffect ~= 0 then
			tStationStr[nPos] =  tStationStr[nPos].."\n"..sEffectDesc.."    "..val;			
		end
	end
	
	
	return strMainPet,tStationStr[HeroStar.FrontPosition],tStationStr[HeroStar.MidPosition],tStationStr[HeroStar.BackPosition];
end


--获取主角累积buff表
function p.GetHeroStarBuffTable()
	local nRoleId =  GetPlayerId();
	
	local tAttrAll = {}
	for i=0,22 do
		tAttrAll[i] = 0;
	end
			
	for nGrade,v in pairs(tStarList) do
		for nLevel,nTag in pairs(v) do			
			local lev = HeroStar.GetLevByGrade(nRoleId,nGrade)
			if  nLevel <= HeroStar.GetLevByGrade(nRoleId,nGrade) then
				----LogInfo("qbw 已经点亮 nLevel:"..nLevel.." nGrade:"..nGrade);
				--已经点亮 将值加入表
				local tCell = HeroStar.GetStarAttr(nGrade,nLevel);
				
				
				--===========主将=========================================-----
				--类型1
				local type1 = math.floor(tCell[DB_GSCONFIG.ATTR1]/10);
				--修正方式1
				local adj1	= tCell[DB_GSCONFIG.ATTR1]%10
				--修正值1
				local val1  = tCell[DB_GSCONFIG.VALUE1];
				
				--类型2
				local type2 = math.floor(tCell[DB_GSCONFIG.ATTR2]/10);
				--修正方式2
				local adj2	= tCell[DB_GSCONFIG.ATTR2]%10;
				--修正值2
				local val2  = tCell[DB_GSCONFIG.VALUE2];
		
				--修正
				tAttrAll[type1] = HeroStar.AdjAttr(tAttrAll[type1],val1,adj1);
				tAttrAll[type2] = HeroStar.AdjAttr(tAttrAll[type2],val2,adj2);
			end
		end		
	end
	
	return tAttrAll;
	
	--for nAttrType,nVal in pairs(tAttrAll) do
	--HeroStar.GetAttrName(nAttrType).."加成+"..nVal.."";
	--end
end

--根据属性类型获得当前将星的属性值
function p.GetAttrValByType(nType)
    local tAttrAll = p.GetHeroStarBuffTable();
	for nAttrType,nVal in pairs(tAttrAll) do
		if(nType == nAttrType) then
			return nVal;
		end
	end
	return 0;
end

--刷新星图列表
function p.RefreshStarVC()
	--

	local pool = DefaultPicPool();
	local scene = GetSMGameScene();
	local nRoleId =  GetPlayerId();
	--local picDark = pool:AddPicture(GetSMImgPath("talent/icon_talent3.png")), false);
		
		
	for nGrade,v in pairs(tStarList) do
		local StarView = p.GetStarViewByGrade(nGrade);
		
		for nLevel,nTag in pairs(v) do			
			local lev = HeroStar.GetLevByGrade(nRoleId,nGrade)
			if  nLevel <= HeroStar.GetLevByGrade(nRoleId,nGrade) then
				--已经点亮 关闭点击功能
				p.SetStarState(STAR_STATE_LIGHT,nGrade,nLevel)
			else
				p.SetStarState(STAR_STATE_DARK,nGrade,nLevel)
				
			end
			
		end
	end
	--LogInfo("选定星星SetStarState:"..g_Grade.."   "..g_Lev);
	--设置选定星星
	p.SetStarState(STAR_STATE_CHOSED,g_Grade,g_Lev);
	

end


--刷新星图背景
function p.RefreshStarBg(nGrade)
	--刷新背景
	local scene = GetSMGameScene();
	local pool = DefaultPicPool();
	local layer = RecursiveUILayer(scene,{NMAINSCENECHILDTAG.HeroStarUI})
	local pic = pool:AddPicture(GetSMImgPath(tStarBg[nGrade]), false);
	local StarBgPic = GetImage(layer, 107);
	StarBgPic:SetPicture(pic,true);
end

--刷新左边信息
function p.RefreshStarInfo()
	if not IsUIShow(NMAINSCENECHILDTAG.HeroStarUI) then
		return;
	end
	
	--累积属性层刷新
	p.desplayAttr();
	
	local scene = GetSMGameScene();
	

	
	local Infotxt = RecursiveLabel(scene,{NMAINSCENECHILDTAG.HeroStarUI,ID_TALENT_CTRL_TEXT_21});
	local Soultxt = RecursiveLabel(scene,{NMAINSCENECHILDTAG.HeroStarUI,24});
	Infotxt:SetFontSize(12);
	
		

	if g_Grade ~= 0 and g_Lev ~= 0  then
	
		local tAttr = HeroStar.GetStarAttr(g_Grade,g_Lev);
		if tAttr == nil  then
			--LogInfo("配置文件gs_config.ini错误. g_Grade:"..g_Grade.." g_Lev:"..g_Lev);
			return;
		end
		
		--_G.--LogInfoT(tAttr);
		
		local sAttr1 = "";
		local sAttr2 = "";
	
		
		--LogInfo("DB_GSCONFIG.ATTR1:"..DB_GSCONFIG.ATTR1);
		local sAttrDesc1 = HeroStar.GetAttrDesc(tAttr[DB_GSCONFIG.ATTR1]);
		local sAttrDesc2 = HeroStar.GetAttrDesc(tAttr[DB_GSCONFIG.ATTR2]);
		local nAttr1 = tAttr[DB_GSCONFIG.VALUE1];
		local nAttr2 = tAttr[DB_GSCONFIG.VALUE2];
		local nSkillId = tAttr[DB_GSCONFIG.SKILL];
		
		local nStationeff = tAttr[DB_GSCONFIG.STATION_EFFECT];
		local nEffVal = tAttr[DB_GSCONFIG.EFFECT_VALUE];
		
		local sShowText = "";

				
		local nRoleId =  GetPlayerId();
		local nSoulNeed = HeroStar.GetStarSoulNeed(g_Grade,g_Lev);
		local nLevNeed =tAttr[DB_GSCONFIG.LEVEL_LIMIT];
		
		Soultxt:SetText("   "..GetRoleBasicDataN(nRoleId, USER_ATTR.USER_ATTR_SOPH));
		
		sShowText = "需要将魂:  "..nSoulNeed;--.."\n等级需求:  "..nLevNeed;
		
		
		if sAttrDesc1 ~= nil  then
			--sAttr1 = sAttrDesc1..nAttr1;
			sAttr1 = string.format(sAttrDesc1,(nAttr1/1000));
			sAttr1 =sAttr1.."";
			sShowText = sShowText.."\n"..sAttr1;
		end
		
		if sAttrDesc2 ~= nil  then
			--sAttr2 = sAttrDesc2..nAttr2;
			sAttr2 = string.format(sAttrDesc2,(nAttr2/1000));
			sShowText = sShowText.."\n"..sAttr2;
			sAttr2 =sAttr2.."";
		end
				

		
		if nStationeff >=1 and nStationeff <= 5 then
			
			local sStationDesc =  HeroStar.GetStationBuffDesc(nStationeff).."增加"..(nEffVal/1000).."";
			sShowText = sShowText.."\n"..sStationDesc;
			
			
		end
		
		
		
		if nSkillId ~= nil and nSkillId ~= 0 then
			--sAttr1 = sAttrDesc1..nAttr1;
			local sSkilldesc = GetDataBaseDataS("skill_config",nSkillId,DB_SKILL_CONFIG.NAME);
			if sSkilldesc ~= nil then
				sShowText = sShowText.."\n开启技能:"..sSkilldesc;
				
			else
				--LogInfo("sSkilldesc nil  nSkillId:"..nSkillId);
			end
		end				
		 
		 
		--Infotxt:SetText("将魂:"..GetRoleBasicDataN(nRoleId, USER_ATTR.USER_ATTR_SOPH).."\n需要消耗将魂:"..nSoulNeed.."\n等级需求:"..nLevNeed.."\n星图:"..g_Grade.."  星点:"..g_Lev.."\n"..sAttr1.."\n"..sAttr2.."\n开启技能:"..sSkilldes);
		Infotxt:SetText(sShowText);

	else
		Soultxt:SetText("将魂:"..GetRoleBasicDataN(nRoleId, USER_ATTR.USER_ATTR_SOPH));	
	end
end

--获取对应星星buff描述
function p.GetAttrDescByStar(nGrade,nLev)

	if nGrade ~= 0 and nLev ~= 0  then
	
		local tAttr = HeroStar.GetStarAttr(nGrade,nLev);
		if tAttr == nil  then
			return;
		end
		
		--_G.--LogInfoT(tAttr);
		
		local sAttr1 = "";
		local sAttr2 = "";
	
		local sAttrDesc1 = HeroStar.GetAttrDesc(tAttr[DB_GSCONFIG.ATTR1]);
		local sAttrDesc2 = HeroStar.GetAttrDesc(tAttr[DB_GSCONFIG.ATTR2]);
		local nAttr1 = tAttr[DB_GSCONFIG.VALUE1];
		local nAttr2 = tAttr[DB_GSCONFIG.VALUE2];
		local nSkillId = tAttr[DB_GSCONFIG.SKILL];
		
		local nStationeff = tAttr[DB_GSCONFIG.STATION_EFFECT];
		local nEffVal = tAttr[DB_GSCONFIG.EFFECT_VALUE];
		
		local sShowText = "";

				
		local nRoleId =  GetPlayerId();
		--local nSoulNeed = HeroStar.GetStarSoulNeed(g_Grade,g_Lev);
		--local nLevNeed =tAttr[DB_GSCONFIG.LEVEL_LIMIT];
	
		--sShowText ="等级需求:     "..nLevNeed;
		
		
		if sAttrDesc1 ~= nil  then
			--sAttr1 = sAttrDesc1..nAttr1;
			sAttr1 = string.format(sAttrDesc1,(nAttr1/1000));
			sAttr1 =sAttr1.."";
			sShowText = sShowText.."\n"..sAttr1;
		end
		
		if sAttrDesc2 ~= nil  then
			--sAttr2 = sAttrDesc2..nAttr2;
			sAttr2 = string.format(sAttrDesc2,(nAttr2/1000));
			sShowText = sShowText.."\n"..sAttr2;
			sAttr2 =sAttr2.."";
		end
				

		
		if nStationeff >=1 and nStationeff <= 5 then
			
			local sStationDesc =  HeroStar.GetStationBuffDesc(nStationeff).."增加"..(nEffVal/1000).."";
			sShowText = sShowText.."\n"..sStationDesc;
			
			
		end
		
		
		
		if nSkillId ~= nil and nSkillId ~= 0 then
			--sAttr1 = sAttrDesc1..nAttr1;
			local sSkilldesc = GetDataBaseDataS("skill_config",nSkillId,DB_SKILL_CONFIG.NAME);
			if sSkilldesc ~= nil then
				sShowText = sShowText.."\n开启技能:"..sSkilldesc;
				
			else
				--LogInfo("sSkilldesc nil  nSkillId:"..nSkillId);
			end
		end				
		 
		 return sShowText;
	else
		return "";	
	end




end

--获取对应星星技能描述
function p.GetSkillDescByStar(nGrade,nLev)
	if nGrade ~= 0 and nLev ~= 0  then
	
		local tAttr = HeroStar.GetStarAttr(nGrade,nLev);
		if tAttr == nil  then
			return "";
		end

		local nSkillId = tAttr[DB_GSCONFIG.SKILL];
		local sShowText = "";
		local nRoleId =  GetPlayerId();
				
		if nSkillId ~= nil and nSkillId ~= 0 then
			local sSkilldesc = GetDataBaseDataS("skill_config",nSkillId,DB_SKILL_CONFIG.NAME);
			if sSkilldesc ~= nil then
				sShowText = "开启技能:"..sSkilldesc;
			end
		end		
		 
		return sShowText;
	else
		return "";	
	end
end

------------------------------UI事件处理回调函数-----------------------------------
--tips 
function p.OnUIEventHeroStarAttr(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	
		if tag == ID_TALENT_TIPS_CTRL_BUTTON_4 then
			local scene = GetSMGameScene();	
			local bglayer = RecursiveUILayer(scene,{NMAINSCENECHILDTAG.HeroStarUI})
			bglayer:RemoveChildByTag(TAG_LAYER_ATTR, false);
		end
	end	
	
end

--背景事件
function p.OnUIEventStarBg(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	--LogInfo("p.OnUIEventStarBg[%d]", tag);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	
		if tag == ID_TALENT_CTRL_BUTTON_6 then
			--不带音效
			RemoveChildByTagNew(NMAINSCENECHILDTAG.HeroStarUI, true,true);
			return true;
			--[[
			local scene = GetSMGameScene();
			if scene ~= nil then
				
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.HeroStarUI, true);
				return true;
			end--]]
		elseif tag == ID_TALENT_CTRL_BUTTON_5 then	
			
			p.LightStar();
		elseif tag == 	ID_TALENT_CTRL_BUTTON_22 then
			--p.desplayAttr();
		end	
	
		
		
	end

end

function p.LightStar()
	--越级点击提示
	local nextGrade,nextLev = p.GetNextStarPosition();
	----LogInfo("next"..nextGrade.."  "..nextLev.."   g:"..g_Grade.." "..g_Lev)
	if nextGrade == 0  and nextLev == 0 then
		--LogInfo("no available star!")
		return;
	end

	--local btn = p.GetStarBtn(g_Grade,g_Lev);
	--local nState = btn:GetParam1();
	local nRoleId =  GetPlayerId();
	local lev = HeroStar.GetLevByGrade(nRoleId,g_Grade)
	
	--已经是点亮的星星	
	if  g_Lev <= lev then
		--LogInfo("already light star! return")
		CommonDlgNew.ShowYesDlg("这是已经学习过的将星点！");
		return;
	end

	

	
	local nSoulNeed = HeroStar.GetStarSoulNeed(g_Grade,g_Lev);
	--将魂不足
	if nSoulNeed == nil then
		--LogInfo("配置文件缺少对应星点");
		return;
	end	
	local nSoul = GetRoleBasicDataN(nRoleId, USER_ATTR.USER_ATTR_SOPH);
	
	
	
	if nSoul < nSoulNeed then
		CommonDlgNew.ShowYesDlg("将魂不足 无法升级！");
		return;
	end
	
	--等级不足
	local nLevNeed = (HeroStar.GetStarAttr(g_Grade,g_Lev))[DB_GSCONFIG.LEVEL_LIMIT];
	--local nLevPlayer =  GetRoleBasicDataN(nRoleId, USER_ATTR.USER_ATTR_LEVEL);
	local mainpetid 	= RolePetUser.GetMainPetId(nRoleId);
	local nLevPlayer	= SafeS2N(RolePetFunc.GetPropDesc(mainpetid, PET_ATTR.PET_ATTR_LEVEL));
	if nLevPlayer < nLevNeed then
		CommonDlgNew.ShowYesDlg("等级不足 无法升级！");
		return;
	end


	if g_Grade ~= nextGrade or  g_Lev ~= nextLev then
		CommonDlgNew.ShowYesDlg("请先点击前置将星点！");
		return;
	end
--]]
	MsgHeroStar.SendHeroStarActionLight(g_Grade,g_Lev);	
	g_AniGrade = g_Grade;
	g_AniLev = g_Lev;

end




--星图容器事件回调
function p.OnUIEventStarVC(uiNode, uiEventType, param)
	--LogInfo("p.OnUIEventStarVC uiEventType:"..uiEventType)
	
	--刷新星图背景
	if  uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		local scene = GetSMGameScene();
		local container = RecursiveSVC(scene, {NMAINSCENECHILDTAG.HeroStarUI,ID_TALENT_CTRL_LIST_23});
		local nGrade = container:GetBeginIndex()+1;	
		--LogInfo("刷新背景图 nGrade:"..nGrade)
		p.RefreshStarBg(nGrade)
		
		--标题容器刷新
		local Titlecontainer = RecursiveSVC(scene, {NMAINSCENECHILDTAG.HeroStarUI,ID_TALENT_CTRL_LIST_20});
		Titlecontainer:ShowViewByIndex(nGrade-1);
		
        --** 左右前头 **--
        SetArrow(p.GetLayer(),p.GetContainter(),1,ID_TALENT_CTRL_PICTURE_18,ID_TALENT_CTRL_PICTURE_19);
        
		return;
	end
	
	
	
	if uiEventType ~= NUIEventType.TE_TOUCH_BTN_CLICK then
		
		return;
	end
	
	local btnClickTag = uiNode:GetTag();
	local scene = GetSMGameScene();
	local container = RecursiveSVC(scene, {NMAINSCENECHILDTAG.HeroStarUI,ID_TALENT_CTRL_LIST_23});

	local nGrade = container:GetBeginIndex()+1;
	
	if tStarList[nGrade] == nil then
		--LogInfo("map of nGrade:["..nGrade.."] dont exist!");
		return;
	end
	
	local btnLev = 0;
	for nLev,nTag in pairs(tStarList[nGrade]) do
		if nTag == btnClickTag then
			btnLev = nLev;
		end
		
	end 
	
	if btnLev == 0 then
		--LogInfo("btn (tag:"..btnClickTag..") dont exist!")
		return;
	end	


	
	--LogInfo("btn chose  nGrade:"..nGrade.."   btnLev:"..btnLev)
	g_Grade = nGrade;
	g_Lev = btnLev;
	
	p.RefreshStarVC()
	p.RefreshStarInfo()

end


------------------------------获取数据-----------------------------------
--获取下一个星点位置
function p.GetNextStarPosition()
	local nRoleId =  GetPlayerId();
	
	for nGrade=1,#tStarList  do	
		local levelMax = #(tStarList[nGrade]);
		local lev = HeroStar.GetLevByGrade(nRoleId,nGrade)
		if lev < levelMax then
			if lev+1 <= levelMax then
			
				return nGrade,lev+1,false;
			end
		
		elseif 	nGrade == #tStarList then
			--最后一个星点
			return nGrade,lev,true;
		end
	end
	
	return 0,0,false
end

function p.GetLayer()
    local scene = GetSMGameScene();
    if(scene == nil) then
        --LogInfo("p.GetLayer scene is nil");
        return nil;
    end
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.HeroStarUI);
	return layer;
end

function p.GetContainter()
    local layer = p.GetLayer();
    if(layer == nil) then
        --LogInfo("p.GetContainter layer is nil");
        return nil;
    end
	local containter = RecursiveSVC(layer, {ID_TALENT_CTRL_LIST_23});
	return containter;
end

--根据档次获取星星视图
function p.GetStarViewByGrade(nGrade)
	local scene = GetSMGameScene();
	local containter = RecursiveSVC(scene, {NMAINSCENECHILDTAG.HeroStarUI,ID_TALENT_CTRL_LIST_23});
	local view = containter:GetViewById(nGrade);
	return view;
end

--获取对应星图星星按钮
function p.GetStarBtn(nGrade,nLev)
	if tStarList[nGrade] == nil then
		--LogInfo("p.GetStarBtn fail grade[%d]",nGrade);
		return;
	end
	
	if tStarList[nGrade][nLev] == nil then
		--LogInfo("p.GetStarBtn fail nLev[%d]",nLev);
		return;
	end	
	
	local nTag = tStarList[nGrade][nLev];
	local StarView = p.GetStarViewByGrade(nGrade);
	
	local StarBtn =  RecursiveButton(StarView, {nTag});
 	return StarBtn;

end



------------------------------设置数据-----------------------------------
--设置星星状态
function p.SetStarState(nState,nGrade,nLev)
	local pool = DefaultPicPool();
	local scene = GetSMGameScene();
	local nRoleId =  GetPlayerId();

	if tStarList[nGrade] == nil then
		--LogInfo("p.SetStarState fail grade[%d]",nGrade);
		return;
	end
	
	if tStarList[nGrade][nLev] == nil then
		--LogInfo("p.SetStarState fail nLev[%d]",nLev);
		return;
	end
	
	local nTag = tStarList[nGrade][nLev];
	local StarView = p.GetStarViewByGrade(nGrade);
	
	
	
	local StarBtn =  RecursiveButton(StarView, {nTag});
 	StarBtn:SetParam1(nState);
 	
	if nState == STAR_STATE_LIGHT then
		----LogInfo("LIGHT  GRADE:"..nGrade.." LEV:"..nLev);
		local picLight = pool:AddPicture(GetSMImgPath("talent/icon_tale3.png"), false);
		StarBtn:SetImage(picLight);
		StarBtn:EnableEvent(true);	
			
	elseif nState == STAR_STATE_DARK then
		----LogInfo("DARK GRADE:"..nGrade.." LEV:"..nLev);
		local picDark = pool:AddPicture(GetSMImgPath("talent/icon_tale2.png"), false);
		StarBtn:SetImage(picDark);		
		StarBtn:EnableEvent(true);		
	elseif nState == STAR_STATE_CHOSED then
		----LogInfo("CHOSED GRADE:"..nGrade.." LEV:"..nLev);
		local picChosed = pool:AddPicture(GetSMImgPath("talent/icon_talen1.png"), false);
		StarBtn:SetImage(picChosed);		
		StarBtn:EnableEvent(true);		
	end
	
end

--成功点亮提示
function p.LightSuccCallback()
	--CommonDlgNew.ShowYesDlg("成功点亮将星点！");
    
	--成功音效    
    Music.PlayEffectSound(Music.SoundEffect.HEROSTAR);
                      
    --成功光效
    if g_AniGrade ~= nil and g_AniLev ~= nil then
		local StarBtn = p.GetStarBtn(g_AniGrade,g_AniLev);
		p.ShowAnimation(StarBtn);
    end
    
    --技能提示动画
	local sTip = p.GetSkillDescByStar(g_AniGrade,g_AniLev)
	CommonDlgNew.ShowTipDlg(sTip);
    
    --** chh 2012-08-22 将星升级箭头提示**--
    p.TipUpgrade();
end

function p.StarDataRefreshCallback()


	--选中下一张图 无则取消选中
	g_Grade,g_Lev = p.GetNextStarPosition();
	--LogInfo("NEXT"..g_Grade.."  "..g_Lev);
	p.ChangePage(g_Grade);
	p.RefreshStarVC();
	p.RefreshStarInfo();	

end

--SetBoundScale

p.AniStarBtn = nil;
p.nEffectKey = nil;
p.nTimerID = nil;
p.tTimerID = {};

--设置星星响应范围
function p.SetAllStarBoundScale()
	local pool = DefaultPicPool();
	local scene = GetSMGameScene();
	local nRoleId =  GetPlayerId();
		
		
	for nGrade,v in pairs(tStarList) do
		local StarView = p.GetStarViewByGrade(nGrade);
		
		for nLevel,nTag in pairs(v) do			
			local lev = HeroStar.GetLevByGrade(nRoleId,nGrade)
			
				local StarBtn =  RecursiveButton(StarView, {nTag});	
			
				if CheckP(StarBtn) then
					----LogInfo("SetAllStarBoundScale "..nTag.." view:"..nGrade);
					StarBtn:SetBoundScale(200);
				else
				    --LogInfo("SetAllStarBoundScale fail nTag"..nTag.." view:"..nGrade);
				end
			
		end
	end
	

end


--播放点亮动画
function p.ShowAnimation(StarBtn)
	--p.AniStarBtn = StarBtn;
	-- 创建精灵NODE
	local tWinSize		= GetWinSize();
	local pSpriteNode	= createUISpriteNode();
	local starrect = StarBtn:GetFrameRect();
	local starWidth =starrect.size.w;
	local starHeight = starrect.size.h;
	pSpriteNode:Init();
	pSpriteNode:SetFrameRect( CGRectMake(-starWidth*0.05,-starWidth*0.1,starWidth,starHeight) );
	local szAniPath		= NDPath_GetAnimationPath();
	local szSprFile		= "jiangx03.spr";
	pSpriteNode:ChangeSprite( szAniPath .. szSprFile );
	
	--
    --加到星星node上
    StarBtn:AddChild( pSpriteNode );
    
    local nEffectKey = 99;
    pSpriteNode:SetTag( nEffectKey );
	--p.nEffectKey	= nEffectKey;

	--if ( p.nTimerID == nil ) then
	
		local nTimerID = RegisterTimer( p.OnTimerCoutDownCounter, 1/24 );
		p.tTimerID[nTimerID] = StarBtn;
	--end
    return true;
end


--获取界面层
function p.OnTimerCoutDownCounter( nTimerID )
	if p.tTimerID[nTimerID] == nil then
		return;
	end
	local AniStarBtn = p.tTimerID[nTimerID];
	
    local pSpriteNode = ConverToSprite( GetUiNode( AniStarBtn, 99 ) );
    if ( pSpriteNode == nil ) then
    	--LogInfo("OnTimerCoutDownCounter 3");
        --p.nEffectKey	= nil;
    	UnRegisterTimer( nTimerID );
		p.tTimerID[nTimerID] = nil;
		return;
    end
    
    --LogInfo("OnTimerCoutDownCounter 1");
    if ( pSpriteNode:IsAnimationComplete() ) then
    	--LogInfo("OnTimerCoutDownCounter 2");
        pSpriteNode:RemoveFromParent( true );
    	--p.nEffectKey	= nil;
    	UnRegisterTimer( nTimerID );
		p.tTimerID[nTimerID] = nil;
    end
end
























