---------------------------------------------------
--描述: 普通副本
--时间: 2012.3.15
--作者: wjl
---------------------------------------------------
AffixBossBoxDlg = {}
local p = AffixBossBoxDlg;


p.TagUiLayer = NMAINSCENECHILDTAG.AffixBossBoxDlg;
p.TagClose = 10;
p.TagContainer = 677;

-- 界面控件坐标定义
local winsize = GetWinSize();
p.data = {};

p.TagPic = {
	3,
	6,
	8,
}

p.TagDes = {
	5,
	7,
	9,
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
	
	uiLoad:Load("SM_FB_BOX.ini", layer, p.OnUIEvent, 0, 0);
	uiLoad:Free();
	
	local m = data;
	p.data = data;
	
	local index = 1;
	if (m.money > 0 ) then
		local btV = GetButton(layer, p.TagPic[index]);
		local desV = GetHyperLinkText(layer, p.TagDes[index]);
		btV:SetImage(p.getMoneyPic());
		desV:SetLinkText(SafeN2S(m.money).."铜钱");
		index = index + 1;
	end

	if (m.emoney > 0 ) then
		local btV = GetButton(layer, p.TagPic[index]);
		local desV = GetHyperLinkText(layer, p.TagDes[index]);
		btV:SetImage(p.getEMoneyPic());
		desV:SetLinkText(SafeN2S(m.emoney) .. "元宝");
		index = index + 1;
	end
	
	local itemId = m.equip or m.scoll;
	if (itemId > 0) then
		local btV = GetItemButton(layer, p.TagPic[index]);
		local desV = GetHyperLinkText(layer, p.TagDes[index]);
		btV:ChangeItemType(itemId);
		btV:RefreshItemCount(1);
		local name = ItemFunc.GetName(itemId);
		name = name or "";
		desV:SetLinkText(SafeN2S(name));
		index = index + 1;
	end
	
	for i = index, #p.TagPic do
		local btV = GetItemButton(layer, p.TagPic[i]);
		local desV = GetHyperLinkText(layer, p.TagDes[i]);
		if (CheckP(btV)) then
			btV:SetVisible(false);
		end
		if (CheckP(desV)) then
			desV:SetVisible(false);
		end
		
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
	
	local tip =  "生命值+" .. SafeN2S(data.health) .."\n武力+".. SafeN2S(data.phy) .. "\n技能+".. SafeN2S(data.skill).. "\n法术+"..SafeN2S(data.magic);
	CommonDlg.ShowTipInfo("恭喜您的修为\n得到提升！",tip);
	--[[
	data.health = health;
	data.phy = phy;
	data.skill = skill;
	data.magic = magic
	]]--
end

function p.getMoneyPic()
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath("mark_copper_single.png"), false)
end
	
function p.getEMoneyPic()
	local pool = DefaultPicPool();
	return pool:AddPicture(GetSMImgPath("mark_ingot_single.png"), false)
	
end

