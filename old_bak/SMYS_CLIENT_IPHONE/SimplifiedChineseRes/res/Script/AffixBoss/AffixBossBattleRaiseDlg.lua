---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
AffixBossBattleRaiseDlg = {}
local p = AffixBossBattleRaiseDlg;

local ID_COPYEVALUATE_CTRL_TEXT_EVALUATION			= 33;
local ID_COPYEVALUATE_CTRL_PICTURE_STAR5				= 32;
local ID_COPYEVALUATE_CTRL_PICTURE_STAR4				= 31;
local ID_COPYEVALUATE_CTRL_PICTURE_STAR3				= 30;
local ID_COPYEVALUATE_CTRL_PICTURE_STAR2				= 29;
local ID_COPYEVALUATE_CTRL_PICTURE_STAR1				= 28;
local ID_COPYEVALUATE_CTRL_TEXT_27					= 27;
local ID_COPYEVALUATE_CTRL_TEXT_SCORE					= 26;
local ID_COPYEVALUATE_CTRL_PICTURE_25					= 25;
local ID_COPYEVALUATE_CTRL_PICTURE_24					= 24;
local ID_COPYEVALUATE_CTRL_BUTTON_CONFIRM				= 186;
local ID_COPYEVALUATE_CTRL_TEXT_EXP_5					= 177;
local ID_COPYEVALUATE_CTRL_TEXT_EXP_4					= 176;
local ID_COPYEVALUATE_CTRL_TEXT_EXP_3					= 175;
local ID_COPYEVALUATE_CTRL_TEXT_EXP_2					= 174;
local ID_COPYEVALUATE_CTRL_TEXT_173					= 173;
local ID_COPYEVALUATE_CTRL_TEXT_172					= 172;
local ID_COPYEVALUATE_CTRL_TEXT_171					= 171;
local ID_COPYEVALUATE_CTRL_TEXT_170					= 170;
local ID_COPYEVALUATE_CTRL_TEXT_NAME_5				= 169;
local ID_COPYEVALUATE_CTRL_TEXT_NAME_4				= 168;
local ID_COPYEVALUATE_CTRL_TEXT_NAME_3				= 167;
local ID_COPYEVALUATE_CTRL_TEXT_NAME_2				= 166;
local ID_COPYEVALUATE_CTRL_TEXT_READ					= 165;
local ID_COPYEVALUATE_CTRL_TEXT_EXP_1					= 164;
local ID_COPYEVALUATE_CTRL_TEXT_163					= 163;
local ID_COPYEVALUATE_CTRL_TEXT_162					= 162;
local ID_COPYEVALUATE_CTRL_TEXT_NAME_1				= 161;
local ID_COPYEVALUATE_CTRL_TEXT_158					= 158;
local ID_COPYEVALUATE_CTRL_PICTURE_619				= 619;
local ID_COPYEVALUATE_CTRL_PICTURE_157				= 157;


p.TagUiLayer = NMAINSCENECHILDTAG.AffixBossBattleRaiseDlg;
p.TagClose = ID_COPYEVALUATE_CTRL_BUTTON_CONFIRM;
p.TagContainer = 677;

-- 界面控件坐标定义
local winsize = GetWinSize();

p.TagName = {
	ID_COPYEVALUATE_CTRL_TEXT_NAME_1,
	ID_COPYEVALUATE_CTRL_TEXT_NAME_2,
	ID_COPYEVALUATE_CTRL_TEXT_NAME_3,
	ID_COPYEVALUATE_CTRL_TEXT_NAME_4,
	ID_COPYEVALUATE_CTRL_TEXT_NAME_5,
}

p.TagNameLabel = {
	ID_COPYEVALUATE_CTRL_TEXT_162,
	ID_COPYEVALUATE_CTRL_TEXT_170,
	ID_COPYEVALUATE_CTRL_TEXT_171,
	ID_COPYEVALUATE_CTRL_TEXT_172,
	ID_COPYEVALUATE_CTRL_TEXT_173,
}

p.TagExp = {
	ID_COPYEVALUATE_CTRL_TEXT_EXP_1,
	ID_COPYEVALUATE_CTRL_TEXT_EXP_2,
	ID_COPYEVALUATE_CTRL_TEXT_EXP_3,
	ID_COPYEVALUATE_CTRL_TEXT_EXP_4,
	ID_COPYEVALUATE_CTRL_TEXT_EXP_5,
}

p.TagSoph = ID_COPYEVALUATE_CTRL_TEXT_READ;

p.TagStar = {
	ID_COPYEVALUATE_CTRL_PICTURE_STAR1,
	ID_COPYEVALUATE_CTRL_PICTURE_STAR2,
	ID_COPYEVALUATE_CTRL_PICTURE_STAR3,
	ID_COPYEVALUATE_CTRL_PICTURE_STAR4,
	ID_COPYEVALUATE_CTRL_PICTURE_STAR5,
}

p.TagScore = ID_COPYEVALUATE_CTRL_TEXT_SCORE;

p.TagDes = ID_COPYEVALUATE_CTRL_TEXT_EVALUATION;


function p.IsOnShowing()
	if IsUIShow(p.TagUiLayer) then
		return true;
	else
		return false;
	end
end
	
function p.ShowRaiseDlg(raise)
	if (p.IsOnShowing()) then
		return;
	end
	local RectUILayerPicture = CGRectMake((winsize.w - 437 * ScaleFactor) / 2, (winsize.h - 269 * ScaleFactor) / 2, 437 * ScaleFactor, 269 * ScaleFactor);
	LogInfo("p.ShowRaiseDlg1");
	if raise == nil then
	--	return 0;
	end
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		return 0;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		return 0;
	end
	
	layer:Init();
	layer:SetTag(p.TagUiLayer);
	layer:SetFrameRect(RectUILayerPicture);
	scene:AddChildZ(layer, 9000);
	layer:SetDestroyNotify(p.onClose);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return 0;
	end
	
	uiLoad:Load("CopyEvaluate.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	
	local sophV = GetLabel(layer,p.TagSoph);
	local scoreV = GetLabel(layer, p.TagScore);
	local rankDesV = GetLabel(layer, p.TagDes);
	
	local m = raise;
	if CheckP(sophV) then
		sophV:SetText(SafeN2S(m.soph));
	end
	
	if (CheckP(scoreV)) then
		scoreV:SetText(SafeN2S(m.score));
	end
	
	for k = m.rank+1, 5 do 
		local img = GetImage(layer, p.TagStar[k]);
		if (CheckP(img)) then
			img:SetVisible(false);
		end
	end
	
	if CheckP(rankDesV) then
		rankDesV:SetText(p.getScoreDes(m.score));
	end
	
	local lst = m.lst;
	local count = m.count or 0;
	local vIndex = 2;
	for i = 1, count do
		local petId = lst[i].petId;
		local strPetName = ConvertS(RolePetFunc.GetPropDesc(petId, PET_ATTR.PET_ATTR_NAME));
		strPetName = strPetName or ""
		local nameV;
		local expV;
		
		if RolePetFunc.IsMainPet(petId) then
			nameV = GetLabel(layer, p.TagName[1]);
			expV = GetLabel(layer, p.TagExp[1]);
		else
			nameV = GetLabel(layer, p.TagName[vIndex]);
			expV = GetLabel(layer, p.TagExp[vIndex]);
			vIndex = vIndex + 1;
		end
		
		if CheckP(nameV) then
			nameV:SetText(ConvertS(strPetName));
		end
		
		if CheckP(expV) then
			expV:SetText(SafeN2S(lst[i].exp));
		end
	end
	
	for i = count + 1 , 5 do
		local lab = GetLabel(layer, p.TagNameLabel[i]);
		lab:SetVisible(false);
	end
end

function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("affixboss%d", tag)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if p.TagClose == tag then
			p.freeData();
			CloseUI(p.TagUiLayer);
			p.onClose();
		--elseif (p.TagOpen == tag ) then
		end
	end
	return true;
end


function p.getContainerById(nId)
	local layer = p.getUiLayer();
	local container = GetScrollViewContainer(layer, nId);
	return container;
	
end

function p.getUiLayer()
	local scene = GetSMGameScene();
	if not CheckP(scene) then
		return nil;
	end
	
	local layer = GetUiLayer(scene, p.TagUiLayer);
	if not CheckP(layer) then
		LogInfo("nil == layer")
		return nil;
	end
	
	return layer;
end


function p.clickButton(node) 
	
end


function p.processNet(msgId, m)
	if (msgId == nil ) then
		LogInfo("processNet msgId == nil" );
	end
	--LogInfo(string.format("processNet%d" , msgId));
	--if msgId == NMSG_Type._MSG_MATRIX_ADD then
		
	--end
	
	CloseLoadBar();
end

function p.initData()
	--MsgMagic.mUIListener = p.processNet;
end

function p.onClose()
	-- notice
	local mapLayer=GetMapLayer();
	mapLayer:ShowTreasureBox();
end

function p.freeData()
	--MsgMagic.mUIListener = nil;
	
end

function p.getScoreDes(score)
	if not score or score < 70 then
		return "您太弱了..."
	elseif score < 90 then
		return "百尺竿头，更进一步"
	elseif	score < 110 then
		return "霸气外露，君临天下"
	elseif score < 130 then
		return "破灭万古，震撼诸天"
	else 
		return "功参造化，无上永生"
	end 
end

