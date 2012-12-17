---------------------------------------------------
--描述: 兑换
--时间: 2012.7.31
--作者: Guosen
---------------------------------------------------
-- 进入兑换界面接口：		Agiotage.LoadUI()

---------------------------------------------------
Agiotage = {}
local p = Agiotage;

---------------------------------------------------


local ID_BTN_CLOSE						= 6;	-- X按钮ID

local ID_BTN_EXCHANGE_10				= 1;	-- 兑换10元宝按钮ID
local ID_BTN_EXCHANGE_50				= 2;	-- 兑换50元宝按钮ID
local ID_BTN_EXCHANGE_100				= 3;	-- 兑换100元宝按钮ID
local ID_BTN_EXCHANGE_ANY				= 4;	-- 兑换任意元宝按钮ID


local ID_LABEL_BALANCE					= 25;	-- 账户余额标签ID
local ID_LABEL_GOLD						= 23;	-- 任意兑换换算的金币值标签ID

local ID_EDIT_INPUT						= 17;	-- 任意元宝值输入框控件ID 

-- 
local EXCHANGE_RATE						= 10;	-- 元宝对金币的汇率 1:10

---------------------------------------------------
local szBalance		= GetTxtPri("PLAYER_T1");
local szDestGold	= GetTxtPub("shoe");


---------------------------------------------------
p.pAgiotageUILayer		= nil;	-- UI层
p.pEditInput			= nil;	-- 数字输入框
p.pLabelGold			= nil;	-- 金币标签

---------------------------------------------------
-- 进入训练界面
function p.LoadUI()
	--LogInfo( "Agiotage: LoadUI()" );
	local pScene = GetSMGameScene();	
	--local pDirector = DefaultDirector();
	--if ( pDirector == nil ) then
	--	LogInfo( "Agiotage: pDirector == nil" );
	--	return false;
	--end
	--local pScene = pDirector:GetRunningScene();
	if ( pScene == nil ) then
		LogInfo( "Agiotage: LoadUI() failed! scene = nil" );
		return false;
	end
	
	local pLayer = createNDUILayer();
	if ( pLayer == nil ) then
		LogInfo( "Agiotage: LoadUI() failed! pLayer = nil" );
		return false;
	end
	pLayer:SetPopupDlgFlag(true);
	pLayer:Init();
	pLayer:bringToTop();
	pLayer:SetTag( NMAINSCENECHILDTAG.Agiotage );--
	pLayer:SetFrameRect( RectFullScreenUILayer );
	--pLayer:SetBackgroundColor( ccc4(125, 125, 125, 0) );
	pScene:AddChildZ(pLayer,UILayerZOrder.NormalLayer+1);--pScene:AddChild( pLayer );--VIP界面的ZOrder为1,so..
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "Agiotage: LoadUI() failed! uiLoad = nil" );
		return false;
	end
	
	uiLoad:Load( "AgiotageUI.ini", pLayer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	p.pAgiotageUILayer	= pLayer;
	
	-- 输入框
	local pUINode	= GetUiNode( pLayer, ID_EDIT_INPUT );
	p.pEditInput	= ConverToEdit( pUINode ) 
	p.pEditInput:SetFlag( 1 );		-- 仅可输入数字
	p.pEditInput:SetMaxLength( 9 );	-- 最多9位数
	p.pEditInput:SetText( "0" );
	
	-- 兑换XX金币
	p.pLabelGold	= GetLabel( pLayer, ID_LABEL_GOLD );
	p.pLabelGold:SetText( "0" .. szDestGold );
	
	-- 您账户有XX元宝
	local pLabelBalance	= GetLabel( pLayer, ID_LABEL_BALANCE );
	pLabelBalance:SetVisible(false);
    
	doShowMobageBalance();
	
	return true;
end

---------------------------------------------------

---------------------------------------------------
-- 主界面触摸事件响应
function p.OnUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ( ID_BTN_CLOSE == tag ) then
			if ( p.pAgiotageUILayer ~= nil ) then
				p.pAgiotageUILayer:RemoveFromParent(true);
				p.pAgiotageUILayer	= nil;
			end
            doHideMobageBalance();
		elseif ( ID_BTN_EXCHANGE_10 == tag ) then
			p.AgiotageQuest( 10 );
		elseif ( ID_BTN_EXCHANGE_50 == tag ) then
			p.AgiotageQuest( 50 );
		elseif ( ID_BTN_EXCHANGE_100 == tag ) then
			p.AgiotageQuest( 100 );
		elseif ( ID_BTN_EXCHANGE_ANY == tag ) then
			p.OnBtnExchangeAny();
		elseif ( ID_EDIT_INPUT == tag ) then
			-- 点击到编辑框
			doHideMobageBalance();
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_EDIT_INPUT_FINISH ) then
		if ( ID_EDIT_INPUT == tag ) then
		    local nInputNumber = SafeS2N( p.pEditInput:GetText() );
			p.pLabelGold:SetText( ( nInputNumber * EXCHANGE_RATE ) .. szDestGold );
			doShowMobageBalance();
		end
	end
	return true;
end

---------------------------------------------------
-- 响应兑换自己数值
function p.OnBtnExchangeAny()
	local nNum = SafeS2N( p.pEditInput:GetText() );
	if ( nNum == 0 ) then
		--CommonDlgNew.ShowYesDlg( "输入为零！", nil, nil, nil );
		return
	end
	p.AgiotageQuest( nNum );
end

---------------------------------------------------
-- 兑换请求，参数：兑换的元宝数值
function p.AgiotageQuest( nMMoney )
	-- 用户的元宝数量
	local nUserMMoney	= 999999999;--
	if ( nMMoney > nUserMMoney ) then
		CommonDlgNew.ShowYesDlg( GetTxtPri("PLAYER_T2"), nil, nil, nil );
		return;
	end
	-- 发送兑换请求
	-- 
    ShowLoadBar();
    doExchangeEmoney(nMMoney);
end

---------------------------------------------------
-- 处理网络消息
function p.HandleNetMsg( nParam )
	CloseLoadBar();
end

---------------------------------------------------

