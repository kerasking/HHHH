---------------------------------------------------
--描述: 幸运宝箱
--时间: 2012.12.11
--作者: Guosen
---------------------------------------------------
-- 进入幸运宝箱界面接口：		LuckyBox.Entry()
---------------------------------------------------

LuckyBox = {}
local p = LuckyBox;


---------------------------------------------------
-- 主界面控件
local ID_BTN_CLOSE					= 27;	-- X

-- 宝箱按钮
local ID_BTN_BOX_1					= 11;
local ID_BTN_BOX_2					= 12;
local ID_BTN_BOX_3					= 13;
local ID_BTN_BOX_4					= 14;
local ID_BTN_BOX_5					= 15;
local ID_BTN_BOX_6					= 16;
local ID_BTN_BOX_7					= 17;
local ID_BTN_BOX_8					= 18;
local ID_BTN_BOX_9					= 19;
local ID_BTN_BOX_10					= 20;
local ID_BTN_BOX_11					= 21;
local ID_BTN_BOX_12					= 22;
local ID_BTN_BOX_13					= 23;
local ID_BTN_BOX_14					= 24;
local ID_BTN_BOX_15					= 25;
local ID_BTN_BOX_16					= 26;

---------------------------------------------------
--local GOLD_NUM						= 10;
local GOLD_NUM						= GetDataBaseDataN( "findbox_static_config", 2, DB_FINDBOX_CONFIG.VALUE );

local LuckyBoxLimit					= GetDataBaseDataN( "findbox_static_config", 1, DB_FINDBOX_CONFIG.VALUE );--5;	-- 免费次数限制

---------------------------------------------------
local SZ_LOTTERYWITHGOLD			= GetTxtPri("LB_T1");--"免费次数用完，继续抽奖需要花费%d金币，继续吗？";
local SZ_GOLD_NOT_ENOUGH			= GetTxtPri("LB_T2");--"金币不足，请充值";

---------------------------------------------------

---------------------------------------------------
p.nFreeLuckyBoxAmount		= nil;	-- 剩余的免费抽奖次数

---------------------------------------------------
-- 进入--时间点到才可以
function p.Entry()
p.nFreeLuckyBoxAmount		= nil;
	--local nUserID		= GetPlayerId();
	--local nPlayerPetID	= RolePetFunc.GetMainPetId( nUserID );
	--local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	--if ( nPlayerLevel < LEVEL_LIMIT ) then
	--	CommonDlgNew.ShowYesDlg( SZ_ERROR_00, nil, nil, 3 );
	--	return;
	--end
	p.ShowLuckyBoxMainUI();
	--ShowLoadBar();--
	MsgLuckyBox.SendMsgGetFreeLotteryAmount();
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
-- 显示幸运宝箱主界面
function p.ShowLuckyBoxMainUI()
	--LogInfo( "LuckyBox: ShowLuckyBoxMainUI()" );
	local scene = GetSMGameScene();
	if not CheckP(scene) then
	LogInfo( "LuckyBox: ShowLuckyBoxMainUI failed! scene is nil" );
		return false;
	end
	
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "LuckyBox: ShowLuckyBoxMainUI failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.LuckyBox );
	layer:SetFrameRect( RectFullScreenUILayer );
	scene:AddChildZ( layer, 1 );

	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "LuckyBox: ShowLuckyBoxMainUI failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "LuckyBox/LuckyBoxUI.ini", layer, p.OnUIEventMain, 0, 0 );
	uiLoad:Free();
end

-- 关闭幸运宝箱界面
function p.CloseUI()
	local scene = GetSMGameScene();
	if ( scene ~= nil ) then
		scene:RemoveChildByTag( NMAINSCENECHILDTAG.LuckyBox, true );
	end
    p.nFreeLuckyBoxAmount		= nil;
end

---------------------------------------------------
-- 宴会界面的事件响应
function p.OnUIEventMain( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
		elseif ( tag == ID_BTN_BOX_1 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_2 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_3 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_4 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_5 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_6 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_7 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_8 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_9 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_10 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_11 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_12 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_13 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_14 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_15 ) then
			p.OpenBox();
		elseif ( tag == ID_BTN_BOX_16 ) then
			p.OpenBox();
		end
	end
	return true;
end

---------------------------------------------------
-- 点击宝箱
function p.OpenBox()
    if ( p.nFreeLuckyBoxAmount == nil ) then
        return;
    end
	if ( p.nFreeLuckyBoxAmount < 1 ) then
		local szTitle	= string.format( SZ_LOTTERYWITHGOLD, GOLD_NUM );
		CommonDlgNew.ShowYesOrNoDlg( szTitle, p.CallBack_LotteryWithGold );
    else
        MsgLuckyBox.SendMsgLottery();
	end
end

---------------------------------------------------
-- 金币抽奖确认
function p.CallBack_LotteryWithGold( nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
        local nGold = GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_EMONEY );
        if ( nGold < GOLD_NUM ) then
            CommonDlgNew.ShowYesOrNoDlg( SZ_GOLD_NOT_ENOUGH, p.CallBack_GoldEnough );
        else
            -- 发送金币抽奖消息
            MsgLuckyBox.SendMsgLottery();
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
-- 刷新免费次数
function p.RefreshLotteryAmount( nAmount )
	--local pLabel;
	--pLabel:SetText( SafeN2S(nAmount) );
    p.nFreeLuckyBoxAmount = nAmount;
end

---------------------------------------------------
-- 进入时，获取免费抽奖次数回调
function p.CallBack_GetFreeLotteryAmount( nAmount )
    --CloseLoadBar();
	if not IsUIShow( NMAINSCENECHILDTAG.LuckyBox ) then
		p.ShowLuckyBoxMainUI();
    end
    p.RefreshLotteryAmount( nAmount );
end

