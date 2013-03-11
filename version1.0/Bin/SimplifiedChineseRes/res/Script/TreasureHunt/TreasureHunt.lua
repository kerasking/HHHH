---------------------------------------------------
--描述: 古迹寻宝
--时间: 2012.12.24
--作者: Guosen
---------------------------------------------------
-- 进入古迹寻宝界面接口：		TreasureHunt.Entry()
---------------------------------------------------

TreasureHunt = {}
local p = TreasureHunt;


---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 30;	-- X

local ID_LABEL_FREE					= 18;	-- 当天免费寻宝次数数值标签
local ID_LABEL_SURPLUS				= 16;	-- 当天剩余寻宝次数数值标签
local ID_LABEL_GOLD					= 19;	-- 金币

-- 古迹按钮
local ID_BTN_RELIC_1				= 11;
local ID_BTN_RELIC_2				= 12;
local ID_BTN_RELIC_3				= 13;
local ID_BTN_RELIC_4				= 14;


-- 古迹MapID
local ID_RELIC_MAP1					= 600300000;	-- 蚩尤冢
local ID_RELIC_MAP2					= 600100000;	-- 琅嬛玉洞
local ID_RELIC_MAP3					= 600200000;	-- 秦始皇陵
local ID_RELIC_MAP4					= 600400000;	-- 殷商古迹

---------------------------------------------------
--
local ID_LABEL_QUESTION				= 18;
local ID_LABEL_ANSWER1				= 20;--19;
local ID_LABEL_ANSWER2				= 21;--20;
--local ID_LABEL_ANSWER3				= 21;

local ID_BTN_ANSWER1				= 23;--22;
local ID_BTN_ANSWER2				= 24;--23;
--local ID_BTN_ANSWER3				= 24;

local ID_BTN_CONFIRM				= 93;

---------------------------------------------------
local FreeTreasureHuntLimit				= GetDataBaseDataN( "findbox_static_config", 6, DB_FINDBOX_CONFIG.VALUE );--3;	-- 免费寻宝次数限制
local GoldTreasureHuntLimit				= GetDataBaseDataN( "findbox_static_config", 7, DB_FINDBOX_CONFIG.VALUE );--20;	-- 非免费寻宝次数限制

---------------------------------------------------
local GOLD_BASE							= GetDataBaseDataN( "findbox_static_config", 8, DB_FINDBOX_CONFIG.VALUE );--10;	-- 非免费寻宝需要的金币基值
local GOLD_INCR							= GetDataBaseDataN( "findbox_static_config", 9, DB_FINDBOX_CONFIG.VALUE );--10;	-- 非免费寻宝需要的金币累加值

---------------------------------------------------
local SZ_LOTTERYWITHGOLD				= GetTxtPri("TH_T1");--"免费次数用完，继续寻宝需要花费%d金币，继续吗？";
local SZ_GOLD_NOT_ENOUGH                = GetTxtPri("TH_T2");--"金币不足，请充值";
local SZ_HUNTLIMIT						= GetTxtPri("TH_T3");--"当日寻宝次数用尽"

---------------------------------------------------

---------------------------------------------------
p.nFreeTreasureHuntAmount		= nil;	-- 免费寻宝次数
p.nSurplusTreasureHunt			= nil;	-- 剩余寻宝次数--允许金币寻宝次数
p.nAnswer						= nil;	--
p.pBtnAnswer					= nil;	--

---------------------------------------------------
-- 进入--时间点到才可以
function p.Entry()
p.nFreeTreasureHuntAmount		= nil;
p.nSurplusTreasureHunt			= nil;
p.nAnswer						= nil;
p.pBtnAnswer					= nil;
	--p.ShowTreasureHuntMainUI();
	--ShowLoadBar();--
	MsgTreasureHunt.SendMsgGetHuntedAmount();
end


---------------------------------------------------
-- 检测玩家是否有某种道具
-- 参数：该道具的 ITEM_TYPE
function p.GetItemAmount( nItemType )
    local nCount = 0;
	local nUserID		= GetPlayerId();
	local tItemIDList	= ItemUser.GetBagItemList( nUserID );
	for i,v in ipairs( tItemIDList ) do
		local nItemTypeTmp	= Item.GetItemInfoN( v, Item.ITEM_TYPE );
		if( nItemTypeTmp == nItemType ) then
            nCount = Item.GetItemInfoN( v, Item.ITEM_AMOUNT );
			break;
		end
	end
	return nCount;
end

---------------------------------------------------
-- 显示古迹寻宝主界面
function p.ShowTreasureHuntMainUI()
	--LogInfo( "TreasureHunt: ShowTreasureHuntMainUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "TreasureHunt: ShowTreasureHuntMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "TreasureHunt: ShowTreasureHuntMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.TreasureHunt );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "TreasureHunt: ShowTreasureHuntMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Treasure/Treasure_M.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
	ArenaUI.isInChallenge = 8;-- 古迹寻宝结算
	p.RefreshMoney();
end

-- 关闭古迹寻宝界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.TreasureHunt, true );
	end
	p.nFreeTreasureHuntAmount		= nil;
	p.nSurplusTreasureHunt			= nil;
	p.nAnswer						= nil;
	p.pBtnAnswer					= nil;
end

---------------------------------------------------
-- 宴会界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( tag == ID_BTN_RELIC_1 ) then
			p.EntryRelic( ID_RELIC_MAP1 );
		elseif ( tag == ID_BTN_RELIC_2 ) then
			p.EntryRelic( ID_RELIC_MAP2 );
		elseif ( tag == ID_BTN_RELIC_3 ) then
			p.EntryRelic( ID_RELIC_MAP3 );
		elseif ( tag == ID_BTN_RELIC_4 ) then
			p.EntryRelic( ID_RELIC_MAP4 );
			--local pParentLayer = uiNode:GetParent();
			--p.ShowQusetPanel( pParentLayer );
		end
	end
	return true;
end

---------------------------------------------------
-- 进入古迹
function p.EntryRelic( nRelicID )
	LogInfo( "TreasureHunt:  EntryRelic:%d",nRelicID );
    if ( p.nFreeTreasureHuntAmount == nil ) then
		CommonDlgNew.ShowYesDlg( SZ_HUNTLIMIT, nil, nil, 3 );
        return;
    end
    if ( p.nSurplusTreasureHunt == nil ) then
		CommonDlgNew.ShowYesDlg( SZ_HUNTLIMIT, nil, nil, 3 );
        return;
    end
	if ( p.nFreeTreasureHuntAmount > 0 ) then
		MsgTreasureHunt.SendMsgTreasureHunt( nRelicID );
    else
    	if ( p.nSurplusTreasureHunt > 0 ) then
			local nNeedGold = ( GoldTreasureHuntLimit - p.nSurplusTreasureHunt ) * GOLD_INCR + GOLD_BASE;
			local szTitle	= string.format( SZ_LOTTERYWITHGOLD, nNeedGold );
			CommonDlgNew.ShowYesOrNoDlg( szTitle, p.CallBack_TreasureHuntWithGold, nRelicID );
		else
			CommonDlgNew.ShowYesDlg( SZ_HUNTLIMIT, nil, nil, 3 );
		end
	end
end

---------------------------------------------------
-- 金币寻宝确认
function p.CallBack_TreasureHuntWithGold( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
        local nGold = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_EMONEY );
		local nNeedGold = ( GoldTreasureHuntLimit - p.nSurplusTreasureHunt ) * GOLD_INCR + GOLD_BASE;
        if ( nGold < nNeedGold ) then
            CommonDlgNew.ShowYesOrNoDlg( SZ_GOLD_NOT_ENOUGH, p.CallBack_GoldEnough );
        else
            -- 发送金币寻宝消息
            MsgTreasureHunt.SendMsgTreasureHunt( param );
        end
	end
end

---------------------------------------------------
-- 金币不足确认
function p.CallBack_GoldEnough( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
        p.CloseUI();
        PlayerVIPUI.LoadUI();
    end
end

---------------------------------------------------
-- 刷新次数（参数：已寻过的次数，包含免费）
function p.RefreshTreasureHuntAmount( nAmount )
	local pScene	= GetSMGameScene();
	if ( pScene == nil ) then
		return;
	end
	local pLayer	= GetUiLayer( pScene, NMAINSCENECHILDTAG.TreasureHunt );
	if ( pLayer == nil ) then
		return;
	end
	
	local pLabelF	= GetLabel( pLayer, ID_LABEL_FREE );
	local pLabelS	= GetLabel( pLayer, ID_LABEL_SURPLUS );
	local nFree		= FreeTreasureHuntLimit - nAmount;
	if ( nFree < 0 ) then
		nFree = 0;
	end
	local nSurplus	= GoldTreasureHuntLimit + FreeTreasureHuntLimit - nAmount;
	if ( nSurplus < 0 ) then
		nSurplus = 0;
	end
	pLabelF:SetText( SafeN2S(nFree) );
	pLabelS:SetText( SafeN2S(nSurplus) );
    p.nFreeTreasureHuntAmount	= nFree;
    p.nSurplusTreasureHunt		= nSurplus;
end

---------------------------------------------------
-- 进入时，获取已寻宝次数回调（参数：已寻过的次数，包含免费）
function p.CallBack_GetHuntedAmount( nAmount )
    --CloseLoadBar();
	if not IsUIShow( NMAINSCENECHILDTAG.TreasureHunt ) then
		p.ShowTreasureHuntMainUI();
    end
    p.RefreshTreasureHuntAmount( nAmount );
end



---------------------------------------------------
function p.CallBack_ShowQuestionPanel( szQ, szA1, szA2, szA3 )
	local pScene	= GetSMGameScene();
	if ( pScene == nil ) then
		return;
	end
	local pLayer	= GetUiLayer( pScene, NMAINSCENECHILDTAG.TreasureHunt );
	if ( pLayer == nil ) then
		return;
	end
	p.ShowQusetPanel( pLayer, szQ, szA1, szA2, szA3 );
end



---------------------------------------------------
-- 显示答题面板
function p.ShowQusetPanel( pParentLayer, szQ, szA1, szA2, szA3 )
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "TreasureHunt: ShowQusetPanel failed! layer is nil" );
		return false;
	end
	layer:Init();
	--layer:SetTag( NMAINSCENECHILDTAG.TreasureHunt );
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "TreasureHunt: ShowQusetPanel failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "Treasure/Treasure_Quest.ini", layer, p.OnUIEventQusetPanel, 0, 0 );
	uiLoad:Free();
	
	local pLabelQ	= GetLabel( layer, ID_LABEL_QUESTION );
	local pLabelA1	= GetLabel( layer, ID_LABEL_ANSWER1 );
	if ( pLabelQ ~= nil and szQ ~= nil ) then
		pLabelQ:SetText( szQ );
	end
	if ( pLabelA1 ~= nil and szA1 ~= nil ) then
		pLabelA1:SetText( szA1 );
	end
	local pLabelA2	= GetLabel( layer, ID_LABEL_ANSWER2 );
	if ( pLabelA2 ~= nil and szA2 ~= nil ) then
		pLabelA2:SetText( szA2 );
	end
	--local pLabelA3	= GetLabel( layer, ID_LABEL_ANSWER3 );
	--if ( pLabelA3 ~= nil and szA3 ~= nil ) then
	--	pLabelA3:SetText( szA3 );
	--end
	
	local pBtnAnswer1		= ConverToCheckBox( GetUiNode( layer, ID_BTN_ANSWER1 ) );
	pBtnAnswer1:SetSelect( true );
	p.pBtnAnswer	= pBtnAnswer1;
	p.nAnswer		= 1;
end

--function p.CloseQusetPanel()
--end

---------------------------------------------------
-- 答题面板事件响应
function p.OnUIEventQusetPanel( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local pLayer = uiNode:GetParent();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( tag == ID_BTN_CONFIRM ) then
			if ( p.nAnswer ~= nil ) then
				-- 发送答案
				MsgTreasureHunt.SendMsgAnswer( p.nAnswer );
			end
			--p.CloseQusetPanel();
			pLayer:RemoveFromParent( true );
			p.nAnswer		= nil;
			p.pBtnAnswer	= nil;
		end
	elseif ( uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK ) then
		if ( tag == ID_BTN_ANSWER1 ) then
			local pBtnAnswer1		= ConverToCheckBox( GetUiNode ( pLayer, ID_BTN_ANSWER1 ) );
			p.pBtnAnswer:SetSelect( false );
			p.pBtnAnswer	= pBtnAnswer1;
			p.pBtnAnswer:SetSelect( true );
			p.nAnswer		= 1;
		elseif ( tag == ID_BTN_ANSWER2 ) then
			local pBtnAnswer2		= ConverToCheckBox( GetUiNode ( pLayer, ID_BTN_ANSWER2 ) );
			p.pBtnAnswer:SetSelect( false );
			p.pBtnAnswer	= pBtnAnswer2;
			p.pBtnAnswer:SetSelect( true );
			p.nAnswer		= 2;
		--elseif ( tag == ID_BTN_ANSWER3 ) then
		--	local pBtnAnswer3		= ConverToCheckBox( GetUiNode ( pLayer, ID_BTN_ANSWER3 ) );
		--	p.pBtnAnswer:SetSelect( false );
		--	p.pBtnAnswer	= pBtnAnswer3;
		--	p.pBtnAnswer:SetSelect( true );
		--	p.nAnswer		= 3;
		end
	end
	return true;
end

---------------------------------------------------

--刷新金钱
function p.RefreshMoney()
    LogInfo("TreasureHunt: RefreshMoney");
    local pScene = GetSMGameScene();
    if( pScene == nil ) then
        return;
    end
    local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.TreasureHunt );
    if( pLayer == nil ) then
        return;
    end
    local nUserID		= GetPlayerId();
    --local szSilver		= MoneyFormat( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_MONEY ) );
    local szGold		= SafeN2S( GetRoleBasicDataN( nUserID, USER_ATTR.USER_ATTR_EMONEY ) );
    
    --_G.SetLabel( pLayer, ID_LABEL_SELVER, szSilver);
    _G.SetLabel( pLayer, ID_LABEL_GOLD, szGold);
end
GameDataEvent.Register( GAMEDATAEVENT.USERATTR, "TreasureHunt.RefreshMoney", p.RefreshMoney );