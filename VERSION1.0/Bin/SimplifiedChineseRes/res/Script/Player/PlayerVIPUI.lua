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


--新增按钮
local ID_VIP_CTRL_BUTTON_62						= 62;
local ID_VIP_CTRL_BUTTON_61						= 61;
local ID_VIP_CTRL_BUTTON_60						= 60;
local ID_VIP_CTRL_BUTTON_59						= 59;
local ID_VIP_CTRL_BUTTON_58						= 58;
local ID_VIP_CTRL_BUTTON_57						= 57;
local ID_VIP_CTRL_BUTTON_56						= 56;
local ID_VIP_CTRL_BUTTON_55						= 55;
local ID_VIP_CTRL_BUTTON_54						= 54;
local ID_VIP_CTRL_BUTTON_53						= 53;
local ID_VIP_CTRL_BUTTON_52						= 52;
local ID_VIP_CTRL_BUTTON_51						= 51;

local tVipTagLev = {}
		tVipTagLev[ID_VIP_CTRL_BUTTON_62] =12;
		tVipTagLev[ID_VIP_CTRL_BUTTON_61] =11;
		tVipTagLev[ID_VIP_CTRL_BUTTON_60] =10;
		tVipTagLev[ID_VIP_CTRL_BUTTON_59] =9 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_58] =8 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_57] =7 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_56] =6 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_55] =5 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_54] =4 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_53] =3 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_52] =2 ;
		tVipTagLev[ID_VIP_CTRL_BUTTON_51] =1 ;


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

tVipInfo[1][1] = GetTxtPri("PLAYER_T20")
tVipInfo[1][2] = GetTxtPri("PLAYER_T21")
tVipInfo[1][3] = GetTxtPri("PLAYER_T22")
tVipInfo[1][4] = GetTxtPri("PLAYER_T23")
tVipInfo[1][4] = GetTxtPri("PUIA_T9")--添加多语言

tVipInfo[2][1] = GetTxtPri("PLAYER_T24")
tVipInfo[2][2] = GetTxtPri("PLAYER_T25")
tVipInfo[2][3] = GetTxtPri("PLAYER_T26")
tVipInfo[2][4] = GetTxtPri("PUIA_T10")--添加多语言

tVipInfo[3][1] = GetTxtPri("PLAYER_T28")
tVipInfo[3][2] = GetTxtPri("PUIA_T11")--添加多语言
tVipInfo[3][3] = GetTxtPri("PLAYER_T29")
tVipInfo[3][4] = GetTxtPri("PLAYER_T30")
tVipInfo[3][5] = GetTxtPri("PLAYER_T31")

tVipInfo[4][1] = GetTxtPri("PLAYER_T33")
tVipInfo[4][2] = GetTxtPri("PLAYER_T34")
tVipInfo[4][3] = GetTxtPri("PLAYER_T35")
tVipInfo[4][4] = GetTxtPri("PUIA_T12")--添加多语言
tVipInfo[4][5] = GetTxtPri("PLAYER_T36")
tVipInfo[4][6] = GetTxtPri("PLAYER_T37")
tVipInfo[4][7] = GetTxtPri("PLAYER_T38")

tVipInfo[5][1] = GetTxtPri("PLAYER_T40")
tVipInfo[5][2] = GetTxtPri("PUIA_T13")         --添加多语言
tVipInfo[5][3] = GetTxtPri("PUIA_T14")           --添加多语言
tVipInfo[5][4] = GetTxtPri("PUIA_T15")                --添加多语言
tVipInfo[5][5] = GetTxtPri("PLAYER_T41")
tVipInfo[5][6] = GetTxtPri("PLAYER_T42")
tVipInfo[5][7] = GetTxtPri("PLAYER_T43")
tVipInfo[5][8] = GetTxtPri("PLAYER_T44")
tVipInfo[5][9] = GetTxtPri("PLAYER_T45")

tVipInfo[6][1] = GetTxtPri("PLAYER_T47")
tVipInfo[6][2] = GetTxtPri("PUIA_T16")      --添加多语言
tVipInfo[6][3] = GetTxtPri("PLAYER_T48")
tVipInfo[6][4] = GetTxtPri("PLAYER_T49")
tVipInfo[6][5] = GetTxtPri("PLAYER_T50")
tVipInfo[6][6] = GetTxtPri("PLAYER_T51")

tVipInfo[7][1] = GetTxtPri("PLAYER_T53")
tVipInfo[7][2] = GetTxtPri("PUIA_T17")      --添加多语言
tVipInfo[7][3] = GetTxtPri("PUIA_T18")      --添加多语言
tVipInfo[7][4] = GetTxtPri("PLAYER_T54")
tVipInfo[7][5] = GetTxtPri("PLAYER_T55")
tVipInfo[7][6] = GetTxtPri("PLAYER_T56")

tVipInfo[8][1] = GetTxtPri("PLAYER_T58")
tVipInfo[8][2] = GetTxtPri("PUIA_T19")      --添加多语言
tVipInfo[8][3] = GetTxtPri("PUIA_T20")      --添加多语言
tVipInfo[8][4] = GetTxtPri("PLAYER_T59")
tVipInfo[8][5] = GetTxtPri("PLAYER_T60")
tVipInfo[8][6] = GetTxtPri("PLAYER_T61")
tVipInfo[8][7] = GetTxtPri("PLAYER_T62")

tVipInfo[9][1] = GetTxtPri("PLAYER_T64")
tVipInfo[9][2] = GetTxtPri("PUIA_T21")      --添加多语言
tVipInfo[9][3] = GetTxtPri("PUIA_T22")      --添加多语言
tVipInfo[9][4] = GetTxtPri("PLAYER_T65")
tVipInfo[9][5] = GetTxtPri("PLAYER_T66")

tVipInfo[10][1] = GetTxtPri("PLAYER_T68")
tVipInfo[10][2] = GetTxtPri("PUIA_T23")      --添加多语言
tVipInfo[10][3] = GetTxtPri("PUIA_T24")      --添加多语言
tVipInfo[10][4] = GetTxtPri("PLAYER_T69")

--[[
tVipInfo[11][1] = "背包容量增加至144格"
tVipInfo[11][2] = "星运背包容量增加至16格"      --添加多语言
tVipInfo[11][3] = "降低装备强化费用20%"

tVipInfo[12][1] = "背包容量增加至144格"
tVipInfo[12][2] = "星运背包容量增加至16格"      --添加多语言
tVipInfo[12][3] = "降低装备强化费用20%"
--]]

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
	layer:SetPopupDlgFlag(true);
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerVIPUI);
	layer:SetDebugName( "VIP" ); --@opt
	layer:SetFrameRect(RectFullScreenUILayer);
	

	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);

	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg
	uiLoad:Load("VIP.ini", layer, p.OnUIEventBg, 0, 0);
	
	
	
	--屏蔽11 12级vip按钮
	local btn11 = RecursiveButton(layer, {61});
	local btn12 = RecursiveButton(layer, {62});
	btn11:EnalbeGray( true );
	btn12:EnalbeGray( true );
	
	--local nVIPRank = p.GetPlayerVipRank();
	local nPlayerId = GetPlayerId();
	local nVIPRank 		= GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
	
	
	p.GameDataUserInfoRefresh();	
	GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"p.GameDataUserInfoRefresh",p.GameDataUserInfoRefresh);
    
    --向Mobage获取访问证书
    sendMsgCreateTempCredential();-- 91测试的话关闭掉
    --local pBtn = GetButton( layer, ID_BTN_AGIOTAGE );-- 91测试的话关闭掉
    --if ( pBtn ~= nil ) then
    --	pBtn:SetVisible( false );
    --end
    --pBtn = GetButton( layer, ID_VIP_CTRL_BUTTON_MONEY );
    --if ( pBtn ~= nil ) then
    --	pBtn:SetVisible( false );
    --end
    --local pLabel = GetLabel( layer, 90 );
    --if ( pLabel ~= nil ) then
    --	pLabel:SetText( "内测版本暂不提供兑换金币功能，金币可从礼包中获得。" );
    --	local tRect = pLabel:GetFrameRect();
    --	pLabel:SetFrameRect( CGRectMake(tRect.origin.x, tRect.origin.y, tRect.size.w, tRect.size.h*2) );
    --end
    
    --设置关闭音效
   	local closeBtn=GetButton(layer,ID_VIP_CTRL_BUTTON_3);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    --** chh 2012-09-02 **--
    --设置箭头显示
    --SetArrow(p.GetBgLayer(),p.GetVipViewList(),1,ID_VIP_CTRL_PICTURE_12,ID_VIP_CTRL_PICTURE_13);
    
	return true;
end

--** chh 2012-09-02 **--
function p.GetVipViewList()
    local containter = RecursiveSVC(p.GetBgLayer(), {VIP_CTRL_LIST_1});
    return containter;
end
		
--ui事件

--背景事件
function p.OnUIEventBg(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventStarBg[%d]", tag);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	
		if tag == ID_VIP_CTRL_BUTTON_3 then
            doHideMobageBalance();
            RemoveChildByTagNew(NMAINSCENECHILDTAG.PlayerVIPUI, true,true);
            return true;

		elseif tag == ID_VIP_CTRL_BUTTON_MONEY then
            doGoToMobageVipPage();


		elseif tag == ID_VIP_CTRL_BUTTON_15 then	
			p.OnClickBuyMilOrderBtn();
		elseif ( tag == ID_BTN_AGIOTAGE ) then
			Agiotage.LoadUI();
			
		elseif tag >= 51 and tag<= 62 then
			local nVipLev = tVipTagLev[tag];
			p.LoadUIVIPDesc(nVipLev);
		end	
	end
end

function p.OnUIEventSVC(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if VIP_CTRL_LIST_1 == tag then
        --** chh 2012-09-02 **--
        --设置箭头显示
        SetArrow(p.GetBgLayer(),p.GetVipViewList(),1,ID_VIP_CTRL_PICTURE_12,ID_VIP_CTRL_PICTURE_13);
    end
    
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
	--[[
	for viplev,nNeedRecharge in pairs(VipCfg) do
		if Recharge < nNeedRecharge then
			 nVipRank = viplev - 1;
			break;
		end
	end 	--]]
	
	local nVipRank 		= GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_VIP_RANK);
		
	VipLevLable:SetText("VIP"..nVipRank..GetTxtPub("HuiYuan"));
	
	
	--vip经验条
	if CheckP(VipexpUI) then
		LogInfo("vipexp ui ");
        
        --** chh 2012-08-29 **--
        if(nVipRank == #VipCfg) then
            VipexpUI:SetProcess(VipCfg[nVipRank]);
            VipexpUI:SetTotal(VipCfg[nVipRank]);
        else
            VipexpUI:SetProcess(Recharge);--ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_EXP)));
            VipexpUI:SetTotal(VipCfg[nVipRank+1]);--ConvertN(RolePetFunc.GetNextLvlExp(nPetId)));
        end
	end	
	
	
	--充值提示信息
	if nVipRank == 10 then
		tipLabel:SetText(GetTxtPri("PV_T1"));
	else
        tipLabel:SetText(string.format(GetTxtPri("PLAYER_T71"),VipCfg[nVipRank+1]-Recharge,nVipRank+1));
	end
	
	--军令
	local nAvailBuyTime = tVIPMilOrder[nVipRank]; --每天可购买次数
	local nBought = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA);
	local nLeftTime = p.allowBuyCount(); --nAvailBuyTime - nBought;	--剩余军令购买次数
	local nMilOrders = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_STAMINA);
	local nGold =  GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY);
	
	
	--
	local nBought = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA);
	local sGoldTip = "";
	if nLeftTime > 0 and nBought <=47 then
        local nEMoney = GetDataBaseDataN("stamina_config", (nBought+1), DB_STAMINA_CONFIG.REQ_EMONEY);
	     sGoldTip = string.format(GetTxtPri("PLAYER_T81"),nEMoney);	          
	end
	    
	--ffff00
	--]]
	MOlabel:SetText(string.format(GetTxtPri("PLAYER_T82"),nLeftTime,sGoldTip));
	

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



function p.BuyMilOrders(nEventType, param, val)	
    --[[
    if(CommonDlgNew.BtnOk == nEventType) then
        _G.MsgMilOrder.SendMsgBuyMilOrder();
    end
    ]]
    if(nEventType == CommonDlgNew.BtnOk) then
        _G.MsgMilOrder.SendMsgBuyMilOrder();
        p.bTwiceConfirm = val;
    elseif(nEventType == CommonDlgNew.BtnNo) then
        p.bTwiceConfirm = val;
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
		p.buyMilOrderTip(0);
end	

--是否消费提示
p.bTwiceConfirm = false;

p.battleId = nil;



 
--购买军令提示         nType为0是每日活动中购买军令    1为副本战斗军令不足购买军令
function p.buyMilOrderTip(nType)
    p.battleId = nType;
    local nLeftTime = p.allowBuyCount();
    local nBought = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA);
    
    if nLeftTime <= 0 then
        CommonDlgNew.ShowYesDlg(GetTxtPri("PLAYER_T73"));
        return;
    end
    
    local nEMoney = GetDataBaseDataN("stamina_config", (nBought+1), DB_STAMINA_CONFIG.REQ_EMONEY);
    if nType == 0 then
        if nEMoney >  GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("PLAYER_T74"));
            return;
        end
    end

    if   GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_STAMINA) >= 48 then
			
        CommonDlgNew.ShowYesDlg(GetTxtPri("PLAYER_T75"));
        return;
    end
    
    if nType == 0 then
        --CommonDlgNew.ShowYesOrNoDlg(string.format(GetTxtPri("PLAYER_T76"),nLeftTime,tGoldNeeded[nBought+1]),p.BuyMilOrders,true);
        if(p.bTwiceConfirm == false) then
            CommonDlgNew.ShowNotHintDlg(string.format(GetTxtPri("PLAYER_T76"),nLeftTime,tGoldNeeded[nBought+1]), p.BuyMilOrders);
        else
            _G.MsgMilOrder.SendMsgBuyMilOrder();
        end
    else
        CommonDlgNew.ShowYesOrNoDlg(string.format(GetTxtPri("PLAYER_T77"),tGoldNeeded[nBought+1]), p.OnNormalBossBuyAtomatic,true);
    end

end

function p.OnNormalBossBuyAtomatic(nEventType ,nEvent, param)	
    if(CommonDlgNew.BtnOk == nEventType) then
        local nBought = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_HAVE_BUY_STAMINA);
        if tGoldNeeded[nBought+1] >  GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_EMONEY) then
            CommonDlgNew.ShowYesDlg(GetTxtPri("PLAYER_T78"));
            return;
        end 
        _G.MsgMilOrder.SendMsgBuyMilOrder();
        MsgAffixBoss.sendNmlEnter( p.battleId );
    end
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


--===========================加载提示层============================--
local g_TipLayerTag = 12345;

function p.LoadUIVIPDesc(nVipLev)
     local layer = createNDUILayer();
     local bglayer = p.GetBgLayer();
	if layer == nil then
		return false;
	end
    
	layer:Init();
	layer:SetTag(g_TipLayerTag);
	layer:SetFrameRect(RectFullScreenUILayer);
	bglayer:AddChild(layer);
    
    local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("VIP_L.ini", layer, p.OnUIEventTiplayer, 0, 0);


	local title =  RecursiveLabel(layer,{3});
	local firsttip =  RecursiveLabel(layer,{151});

	title:SetText(string.format(GetTxtPri("PLAYER_T79"),nVipLev));
	firsttip:SetText(string.format(GetTxtPri("PLAYER_T80"),VipCfg[nVipLev],nVipLev));
	----------------------------容器---------------------------------------
	local rectX = winsize.w*0.25;
	local rectW	= winsize.w*0.5;
	local rect  = CGRectMake(rectX, winsize.h*0.25, rectW, winsize.h*0.65); 
	

	tipcontainer = createUIScrollViewContainer();
	if tipcontainer == nil then
		LogInfo("tipcontainer == nil,load ui failed!");
		return;
	end
	tipcontainer:Init();
	tipcontainer:SetFrameRect(rect);
	layer:AddChild(tipcontainer);
	
	local rectview = tipcontainer:GetFrameRect();
	tipcontainer:SetStyle(UIScrollStyle.Verical);
	tipcontainer:SetViewSize(CGSizeMake(rectview.size.w, rectview.size.h / 10));
	tipcontainer:EnableScrollBar(true);
	
	
	
	local rectview		= tipcontainer:GetFrameRect();
	local nWidthLimit = rectview.size.w;
	
	for nIndex=1,#tVipInfo[nVipLev] do
	
		local view = createUIScrollView();

		if view ~= nil then
			view:Init(false);
			view:SetViewId(nIndex);
		
			tipcontainer:AddView(view);
			local sizeview		= view:GetFrameRect().size;
			local str = "";
			local pLabelTips = nil;
			local pLabelScore = nil;
			
			
		  	pLabelTips = _G.CreateColorLabel( nIndex.."."..tVipInfo[nVipLev][nIndex], 11, nWidthLimit );
			pLabelTips:SetFrameRect(CGRectMake(0, 0, nWidthLimit, 20 * ScaleFactor));
			view:AddChild(pLabelTips);
		end
	end	
end

--提示层背景事件
function p.OnUIEventTiplayer(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventTiplayer[%d]", tag);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	
		if tag == 533 then
    		local layer = p.GetBgLayer();          	
			layer:RemoveChildByTag(g_TipLayerTag, true);           
		end	
	end
	return true;
end


























