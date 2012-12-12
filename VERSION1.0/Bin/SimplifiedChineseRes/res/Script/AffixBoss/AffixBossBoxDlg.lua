---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
AffixBossBoxDlg = {}
local p = AffixBossBoxDlg;


local ID_BOX_CTRL_BUTTON_194					= 194;
local ID_BOX_CTRL_TEXT_EQUIP					= 193;
local ID_BOX_CTRL_TEXT_GOLD						= 192;
local ID_BOX_CTRL_TEXT_MONEY					= 191;
local ID_BOX_CTRL_PICTURE_EQUIP					= 190;
local ID_BOX_CTRL_PICTURE_GOLD					= 189;
local ID_BOX_CTRL_PICTURE_MONEY					= 188;
local ID_BOX_CTRL_PICTURE_187					= 187;


p.TagUiLayer = NMAINSCENECHILDTAG.AffixBossBoxDlg;
p.TagClose = ID_BOX_CTRL_BUTTON_194;
p.TagContainer = 677;

-- 界面控件坐标定义
local winsize = GetWinSize();
p.data = {};

p.TagPic = {
	money = ID_BOX_CTRL_PICTURE_MONEY,
	gold = ID_BOX_CTRL_PICTURE_GOLD,
	equip = ID_BOX_CTRL_PICTURE_EQUIP,
}

p.TagDes = {
	money = ID_BOX_CTRL_TEXT_MONEY,
	gold = ID_BOX_CTRL_TEXT_GOLD,
	equip = ID_BOX_CTRL_TEXT_EQUIP,
}


function p.IsOnShowing()
	if IsUIShow(p.TagUiLayer) then
		return true;
	else
		return false;
	end
end
	
function p.ShowDlg(data)
	if (p.IsOnShowing()) then
		return;
	end
	local RectUILayerPicture = CGRectMake((winsize.w - 160 * ScaleFactor) / 2, (winsize.h - 260 * ScaleFactor) / 2, 160 * ScaleFactor, 260 * ScaleFactor);
	LogInfo("p.ShowRaiseDlg1");
	if data == nil then
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
	
	uiLoad:Load("Box.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	
	local moneyPicV = GetLabel(layer,p.TagPic.money);
	local goldPicV = GetLabel(layer, p.TagPic.gold);
	local equipPicV = GetLabel(layer, p.TagPic.equip);
	
	local moneyDesV = GetLabel(layer, p.TagDes.money);
	local goldDesV = GetLabel(layer, p.TagDes.gold);
	local equipDesV = GetLabel(layer, p.TagDes.equip);
	
	local m = data;
	p.data = data;
	if CheckP(moneyDesV) then
		if (m.money >= 0 ) then
			moneyDesV:SetText(SafeN2S(m.money) .. GetTxtPub("coin"));
		end
	end
	
	if (CheckP(goldDesV)) then
		if (m.emoney >= 0 ) then
			goldDesV:SetText(SafeN2S(m.emoney) .. GetTxtPub("shoe"));
		end
	end
	
	if (CheckP(equipDesV)) then
		local itemId = m.equip or m.scoll;
		local name = ItemFunc.GetName(itemId);
		name = name or "";
		name = name .. "X1"
		equipDesV:SetText(SafeN2S(name));
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
	--local mapLayer=GetMapLayer();
	--mapLayer:ShowTreasureBox();
	if (p.data.money) then
		MsgAffixBoss.sendPickItem(1);
	end
	if (p.data.emoney) then
		MsgAffixBoss.sendPickItem(0);
	end
	if (p.data.equip) then
		MsgAffixBoss.sendPickItem(2);
	end
	if (p.data.scoll) then
		MsgAffixBoss.sendPickItem(3);
	end
	
end

function p.freeData()
	--MsgMagic.mUIListener = nil;
	
end

function p.showRaiseGroupDlg(data)
	if not data then
	--	return;
	end
	
	data = {};
	
	local tip =  GetTxtPri("ABBD_T1") .. SafeN2S(data.health) .."\n"..GetTxtPri("ABBD_T2").. SafeN2S(data.phy) .. "\n"..GetTxtPri("ABBD_T3").. SafeN2S(data.skill).. "\n"..GetTxtPri("ABBD_T4")..SafeN2S(data.magic);
	CommonDlg.ShowTipInfo(GetTxtPri("ABBD_T5").."\n"..GetTxtPri("ABBD_T6"),tip);
	--[[
	data.health = health;
	data.phy = phy;
	data.skill = skill;
	data.magic = magic
	]]--
end

