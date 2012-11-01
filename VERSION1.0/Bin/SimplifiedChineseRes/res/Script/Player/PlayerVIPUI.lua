---------------------------------------------------
--描述: VIP UI
--时间: 2012.2.1
--作者: QBW
---------------------------------------------------
   
PlayerVIPUI = {}
local p = PlayerVIPUI;

--bg
local ID_VIP_CTRL_PICTURE_16					= 16;
local ID_VIP_CTRL_BUTTON_15						= 15;
local ID_VIP_CTRL_TEXT_14						= 14;
local ID_VIP_CTRL_PICTURE_13					= 13;
local ID_VIP_CTRL_PICTURE_12					= 12;
local ID_VIP_CTRL_LIST_1						= 11;
local ID_VIP_CTRL_TEXT_10						= 10;
local ID_VIP_CTRL_TEXT_VIPLEVEL					= 9;
local ID_VIP_CTRL_TEXT_VIP						= 8;
local ID_VIP_CTRL_BUTTON_MONEY					= 7;
local ID_VIP_CTRL_PICTURE_5						= 5;
local ID_VIP_CTRL_EXP_4							= 4;
local ID_VIP_CTRL_BUTTON_3						= 3;
local ID_VIP_CTRL_PICTURE_2						= 2;
local ID_VIP_CTRL_PICTURE_1						= 1;

local ID_BTN_AGIOTAGE							= 89;	-- 兑换金币
local ID_LABEL_GOLD_COIN						= 49;	-- 金币数量

--scroll
local ID_VIP_L_CTRL_TEXT_2						= 2;



local VipCfg = {}
VipCfg[1] = 100
VipCfg[2] = 500
VipCfg[3] = 1000
VipCfg[4] = 2000
VipCfg[5] = 5000
VipCfg[6] = 10000
VipCfg[7] = 20000
VipCfg[8] = 50000
VipCfg[9] = 80000
VipCfg[10]= 100000


local VIP_CTRL_LIST_1 = 11;
-- 界面控件坐标定义
local winsize = GetWinSize();

local tVipInfo ={}
for i=1,10 do 
	tVipInfo[i] = {}
end

tVipInfo[1][1] = "开启白金训练模式"
tVipInfo[1][2] = "每日可以征收20次"
tVipInfo[1][3] = "每日可以购买12个额外军令"
tVipInfo[1][4] = "背包容量增加至72"
tVipInfo[1][5] = "强化装备的冷却时间缩短10%"

tVipInfo[2][1] = "开启白金训练模式"
tVipInfo[2][2] = "每日可以征收20次"
tVipInfo[2][3] = "每日可以购买12个额外军令"

tVipInfo[3][1] = "挑战次数增加：金币购买竞技场挑战次数；"
tVipInfo[3][2] = "精英副本每日可用金币重置1次"
tVipInfo[3][3] = "开启自动战斗的加速功能"
tVipInfo[3][4] = "开启白金洗练功能"
tVipInfo[3][5] = "包含VIP2所有功能"

tVipInfo[4][1] = "每日可以征收30次"
tVipInfo[4][2] = "开放骑宠高级培养功能"
tVipInfo[4][3] = "开启金钻训练模式"
tVipInfo[4][4] = "战斗可直接查看结果（除第一次战斗）。"
tVipInfo[4][5] = "包含VIP3所有功能"

tVipInfo[5][1] = "每日可以征收40次"
tVipInfo[5][2] = "每日可以购买16个额外军令"
tVipInfo[5][3] = "精英副本每日可用金币重置2次"
tVipInfo[5][4] = "包含VIP4所有功能"


tVipInfo[6][1] = "每日可以购买24个额外军令"
tVipInfo[6][2] = "开启至尊洗练功能"
tVipInfo[6][3] = "包含VIP5所有功能"


tVipInfo[7][1] = "每日可以征收50次"
tVipInfo[7][2] = "每日可以购买32个额外军令"
tVipInfo[7][3] = "包含VIP6所有功能"


tVipInfo[8][1] = "每日可以征收70次"
tVipInfo[8][2] = "每日可以购买40个额外军令"
tVipInfo[8][3] = "开启至尊训练模式"
tVipInfo[8][4] = "包含VIP7所有功能"


tVipInfo[9][1] = "每日可以征收100次"
tVipInfo[9][2] = "包含VIP8所有功能"


tVipInfo[10][1] = "每日可以征收100次"
tVipInfo[10][2] = "每日可以购买48个额外军令"
tVipInfo[10][3] = "花费金币突飞伙伴"
tVipInfo[10][4] = "包含VIP9所有功能"





function p.LoadUI()
local scene = GetSMGameScene();	

	if scene == nil then
		LogInfo("scene == nil,load PlayerStar failed!");
		return;
	end

	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerVIPUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	

	scene:AddChildZ(layer,1);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("VIP.ini", layer, p.OnUIEventBg, 0, 0);
	
	
	--初始化星图界面
	--
	local containter = RecursiveSVC(layer, {VIP_CTRL_LIST_1});
	containter:SetViewSize(containter:GetFrameRect().size);
	containter:SetLuaDelegate(p.OnUIEventSVC)

	for rank,v in pairs(tVipInfo) do
		--LogInfo("1:"..rank)
		local view = createUIScrollView();
	
	     view:Init(false);
	     view:SetViewId(rank);
	     containter:AddView(view);
		 --view:SetFrameRect(CGRectMake(0,0,640,640));
		-- LogInfo("2")
	     local uiLoad = createNDUILoad();
	     if uiLoad ~= nil then
		     uiLoad:Load("VIP_L.ini",view,nil,0,0);
		     uiLoad:Free();
	     end
	     
	     local label =  RecursiveLabel(view,{ID_VIP_L_CTRL_TEXT_2});
	     local str = p.GetTipbyVIPRank(rank);
		label:SetText("VIP"..rank..":\n"..str)
	    	
	end	
	
	
	local nVIPRank = p.GetPlayerVipRank();
	if tVipInfo[nVIPRank] ~= nil then
		containter:ShowViewById(nVIPRank);
	end
	
	p.GameDataUserInfoRefresh();	
	GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"p.GameDataUserInfoRefresh",p.GameDataUserInfoRefresh);
    
    --向Mobage获取访问证书
    sendMsgCreateTempCredential();
    
    --设置关闭音效
   	local closeBtn=GetButton(layer,ID_VIP_CTRL_BUTTON_3);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);

	return true;
end
		
		
		
		
--ui事件

--背景事件
function p.OnUIEventBg(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventStarBg[%d]", tag);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	
		if tag == ID_VIP_CTRL_BUTTON_3 then
            
            RemoveChildByTagNew(NMAINSCENECHILDTAG.PlayerVIPUI, true,true);
            return true;

		elseif tag == ID_VIP_CTRL_BUTTON_MONEY then
            doGoToMobageVipPage();


		elseif tag == ID_VIP_CTRL_BUTTON_15 then	
			p.OnClickBuyMilOrderBtn();
		elseif ( tag == ID_BTN_AGIOTAGE ) then
			Agiotage.LoadUI();
		end	
	end
end

function p.OnUIEventSVC(uiNode, uiEventType, param)
	return true;
end
	
	
	
--获取对应vip等级特权
function p.GetTipbyVIPRank(nRank)
	
	local str = "";
	
	if tVipInfo[nRank] == nil  then
		LogInfo("p.GetTipbyVIPRank wrong rank:"..nRank);
	
		return "";
	end
	
	for i,v in pairs(tVipInfo[nRank]) do
		str = str.."\n"..i.."."..v
	end
	return str;
end	

local tVIPMilOrder = {}
	tVIPMilOrder[0] = 15
	tVIPMilOrder[1] = 20
	tVIPMilOrder[2] = 20
	tVIPMilOrder[3] = 20
	tVIPMilOrder[4] = 20
	tVIPMilOrder[5] = 25
	tVIPMilOrder[6] = 30
	tVIPMilOrder[7] = 35
	tVIPMilOrder[8] = 40
	tVIPMilOrder[9] = 48
	tVIPMilOrder[10] = 48
	
	
local tGoldNeeded = {}
	for i=0,48 do
		if i <=10 then
			tGoldNeeded[i] = 20 
		elseif i<=20 then
			tGoldNeeded[i] = 30
		elseif i<=25 then
			tGoldNeeded[i] = 40
		elseif i<=30 then
			tGoldNeeded[i] = 50
		elseif i<=35 then
			tGoldNeeded[i] = 70
		elseif i<=40 then
			tGoldNeeded[i] = 100
		elseif i<=48 then
			tGoldNeeded[i] = 150
		end
	end	

--数据显示刷新
function p.GameDataUserInfoRefresh()
	CloseLoadBar();
    if not IsUIShow(NMAINSCENECHILDTAG.PlayerVIPUI) then
        return;
    end


	local nPlayerId = GetPlayerId();
	local layer =  p.GetBgLayer();
	local nUserGold		= GetRoleBasicDataN( nPlayerId, USER_ATTR.USER_ATTR_EMONEY );
	local pLabelGold	= GetLabel( layer, ID_LABEL_GOLD_COIN );
	if ( pLabelGold ~= nil ) then
		pLabelGold:SetText( SafeN2S(nUserGold) );
	end
	
	local MOlabel =  RecursiveLabel(layer,{ID_VIP_CTRL_TEXT_14});
	local VipLevLable = RecursiveLabel(layer,{ID_VIP_CTRL_TEXT_VIPLEVEL});
	local VipexpUI	= RecursivUIExp(layer, {ID_VIP_CTRL_EXP_4});	
	local tipLabel = RecursiveLabel(layer, {ID_VIP_CTRL_TEXT_10});	
	
	--vip等级
	--local nVipRank = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
	--VipLevLable:SetText("VIP"..nVipRank.."会员");
	--if tVIPMilOrder[nVipRank] == nil then
	--	LogInfo(":wrong VIP RANK");
	--	return;
	--end

	--充值金币累积数
	local Recharge = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_RECHARGE_EMONEY);
	LogInfo("Recharge:"..Recharge);
	
	local nVipRank = 0;
	for viplev,nNeedRecharge in pairs(VipCfg) do
		if Recharge < nNeedRecharge then
			 nVipRank = viplev - 1;
			break;
		end
	end 	
	VipLevLable:SetText("VIP"..nVipRank.."会员");
	
	
	--vip经验条
	if CheckP(VipexpUI) then
		LogInfo("vipexp ui ");
		VipexpUI:SetProcess(Recharge);--ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_EXP)));
		VipexpUI:SetTotal(VipCfg[nVipRank+1]);--ConvertN(RolePetFunc.GetNextLvlExp(nPetId)));
	end	
	
	
	--充值提示信息
	if nVipRank == 10 then
		tipLabel:SetText("恭喜您变为VIP10!");
	else
		tipLabel:SetText(string.format("再充值%d金币，您将成为VIP%d会员。",VipCfg[nVipRank+1]-Recharge,nVipRank+1));
	end
	
	--军令
	local nAvailBuyTime = tVIPMilOrder[nVipRank]; --每天可购买次数
	local nBought = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA);
	local nLeftTime = nAvailBuyTime - nBought;	--剩余军令购买次数
	local nMilOrders = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_STAMINA);
	local nGold =  GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
	MOlabel:SetText(string.format("您今天还可以购买军令%d次。",nLeftTime));
	
	

	
	
	
	--local str = string.format("军令:(%d/%d)\n 剩余购买次数:%d\nvip等级:%d\n金币:%d",nMilOrders,MAX_MILORDERS,nLeftTime,nVipRank,nGold);
	

	
	
	

	

end

--** chh 2012-0710 **--
--允许购买军令数量
function p.allowBuyCount()
    local nVipRank = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
    local nAvailBuyTime = tVIPMilOrder[nVipRank]; --每天可购买次数
	local nBought = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA);
	local nLeftTime = nAvailBuyTime - nBought;	--剩余军令购买次数
    return nLeftTime;
end



function p.BuyMilOrders(nEventType ,nEvent,param)	
    if(CommonDlgNew.BtnOk == nEventType) then
        _G.MsgMilOrder.SendMsgBuyMilOrder();
    end
end


function p.OnClickBuyMilOrderBtn()
		local nPlayerId = GetPlayerId();
		local nVipRank = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
		
		if tVIPMilOrder[nVipRank] == nil then
			LogInfo(":wrong VIP RANK");
			return;
		end
		

		
		
        --** chh 2012-07-10 **--
		p.buyMilOrderTip();
end	

--** chh 2012-07-10 **--
--购买军令提示
function p.buyMilOrderTip()
    local nLeftTime = p.allowBuyCount();
    local nBought = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA);
    
    if nLeftTime <= 0 then
        CommonDlgNew.ShowYesDlg("剩余购买次数不足！");
        return;
    end

    if tGoldNeeded[nBought+1] >  GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY) then
        CommonDlgNew.ShowYesDlg("金币不足！");
        return;
    end

    if   GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_STAMINA) >= 48 then
			
        CommonDlgNew.ShowYesDlg("您的军令数已经达到上限！");
        return;
    end
    
    CommonDlgNew.ShowYesOrNoDlg("今日可购买"..nLeftTime.."次。花费"..tGoldNeeded[nBought+1].."金币购买1个军令",p.BuyMilOrders,true)

end


function p.GetBgLayer()
	local scene = GetSMGameScene();	
	local layer =  RecursiveUILayer(scene,{NMAINSCENECHILDTAG.PlayerVIPUI})
	return layer;
end


function p.GetPlayerVipRank()
	local nPlayerId = GetPlayerId();

	--充值金币累积数
	local Recharge = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_RECHARGE_EMONEY);
	
	local nVipRank = 0;
	for viplev,nNeedRecharge in pairs(VipCfg) do
		if Recharge < nNeedRecharge then
			nVipRank = viplev - 1;
			break;
		end
	end
	return nVipRank;
end
































