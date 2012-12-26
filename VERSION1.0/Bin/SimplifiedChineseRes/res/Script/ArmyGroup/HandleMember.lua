---------------------------------------------------
--描述: 处理成员面板
--时间: 2012.9.21
--作者: Guosen
---------------------------------------------------

HadleMember = {}
local p = HadleMember;

---------------------------------------------------
local ID_BTN_CLOSE					= 3;	-- X
local ID_BTN_INFOR					= 30;	-- “查看资料”按钮ID
local ID_BTN_FRIEND					= 32;	-- “加为好友”按钮ID
local ID_BTN_CHAT					= 33;	-- “私聊”按钮ID
local ID_BTN_DISMISS				= 34	-- “开除”按钮ID
local ID_BTN_PROMOTION				= 35;	-- “升职/降职”按钮ID//promotion/demotion
local ID_BTN_ABDICATE				= 36;	-- “禅让”按钮ID
local ID_LABEL_NAME					= 37;	-- 名字

---------------------------------------------------
local SZ_PROMOTION					= GetTxtPri("MAG2_T30");
local SZ_DEMOTION					= GetTxtPri("MAG2_T31");
local SZ_CONFIRM_00					= GetTxtPri("MAG2_T32");
local SZ_CONFIRM_01					= GetTxtPri("MAG2_T33");
local SZ_CONFIRM_02					= GetTxtPri("MAG2_T34");

---------------------------------------------------
p.nMemberOrdinal	= nil;	-- 选中的玩家序号
p.tMember			= nil;	-- 选中的成员
p.pLayerHandleMemberDlg		= nil;

---------------------------------------------------
function p.CreateHandleMemberDlg( pParentLayer, nAGID, tMember )
p.tMember			= nil;
p.pLayerHandleMemberDlg		= nil;
	if ( pParentLayer == nil ) then
		LogInfo( "HadleMember: CreateHadleMemberDlg failed! pParentLayer is nil" );
		return false;
	end
	if ( tMember == nil ) then
		LogInfo( "HadleMember: CreateHadleMemberDlg failed! tMember is nil" );
		return false;
	end
	local nUserID	= GetPlayerId();
	local nPlayerID	= tMember[ArmyGroupMemberIndex.AGMI_USERID];
	if ( nPlayerID == nUserID ) then
		--LogInfo( "HadleMember: CreateHadleMemberDlg failed! nPlayerID is nUserID" );
		return false;
	end
	local layer = createNDUILayer();
	if not CheckP(layer) then
		LogInfo( "HadleMember: CreateHadleMemberDlg failed! layer is nil" );
		return false;
	end
	layer:Init();
	layer:SetFrameRect( RectFullScreenUILayer );
	pParentLayer:AddChildZ( layer, 2 );
	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		layer:Free();
		LogInfo( "HadleMember: CreateHadleMemberDlg failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "ArmyGroup/ArmyGroupUI_HandleMemberPanel.ini", layer, p.OnUIEventHandleMemberDlg, 0, 0 );
	uiLoad:Free();
	p.pLayerHandleMemberDlg = layer;
	p.tMember	= tMember;
	
	local szName	= tMember[ArmyGroupMemberIndex.AGMI_NAME];
	local nPosition	= tMember[ArmyGroupMemberIndex.AGMI_POSITION];
	local szPosition = MsgArmyGroup.GetPositionString(nPosition);
	if ( nPosition == ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS or nPosition == ArmyGroupPositionGrade.AGPG_LEGATUS ) then
		szName = szName .. "(" .. szPosition .. ")";
	end
	local pLabelName	= GetLabel( layer, ID_LABEL_NAME );
	pLabelName:SetText( szName );
	
	local pBtnDismiss	= GetButton( layer, ID_BTN_DISMISS );
	local pBtnPromotion	= GetButton( layer, ID_BTN_PROMOTION );
	local pBtnAbdicate	= GetButton( layer, ID_BTN_ABDICATE );
	pBtnDismiss:SetVisible( false );
	pBtnPromotion:SetVisible( false );
	pBtnAbdicate:SetVisible( false );
	
	local nUserArmyGroupID	= MsgArmyGroup.GetUserArmyGroupID( nUserID );
	local nUserPosition		= MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
	if ( nUserArmyGroupID ~= nAGID ) or ( nUserPosition == ArmyGroupPositionGrade.AGPG_NONE ) then
		-- 非本军团成员，或是普通成员
	elseif ( nUserPosition == ArmyGroupPositionGrade.AGPG_LEGATUS ) then
		-- 本军团的军团长
		pBtnDismiss:SetVisible( true );
		pBtnPromotion:SetVisible( true );
		pBtnAbdicate:SetVisible( true );
		if ( nPosition == ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS ) then
			pBtnPromotion:SetTitle( SZ_DEMOTION );	-- 对象是副军团长显示降职
		elseif ( nPosition == ArmyGroupPositionGrade.AGPG_NONE ) then
			pBtnPromotion:SetTitle( SZ_PROMOTION );	-- 对象是普通成员显示升职
		end
	elseif ( nUserPosition == ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS ) and ( nPosition == ArmyGroupPositionGrade.AGPG_NONE ) then
		-- 本军团副军团长且查看对象是普通成员
		pBtnDismiss:SetVisible( true );
	end
	return true;
end

function p.InitUI( pLayer, tMember )
	local nUserID	= GetPlayerId();
	local nPlayerID	= tMember[ArmyGroupMemberIndex.AGMI_USERID];
	if ( nPlayerID == nUserID ) then--
		return;
	end
end

---------------------------------------------------
function p.CloseUI()
	if ( p.pLayerHandleMemberDlg ~= nil ) then
		p.pLayerHandleMemberDlg:RemoveFromParent( true );
		p.pLayerHandleMemberDlg = nil;
	end
end

---------------------------------------------------
--
--function p.ShowHandleMemberDlg( nOrdinal )
--	local pLayer = ArmyGroup.pLayerHandleMemberDlg;
--	if ( pLayer == nil ) then
--		return;
--	end
--	local tArmyGroupMemberList = MsgArmyGroup.GetArmyGroupMemberList( ArmyGroup.nArmyGroupID );
--	if ( ( nOrdinal == 0 ) or ( nOrdinal > table.getn( tArmyGroupMemberList ) ) ) then
--		return;
--	end
--	local nUserID	= GetPlayerId();
--	local nPlayerID	= tArmyGroupMemberList[nOrdinal][ArmyGroupMemberIndex.AGMI_USERID];
--	if ( nPlayerID == nUserID ) then--
--		return;
--	end
--	local szName	= tArmyGroupMemberList[nOrdinal][ArmyGroupMemberIndex.AGMI_NAME];
--	local nPosition	= tArmyGroupMemberList[nOrdinal][ArmyGroupMemberIndex.AGMI_POSITION];
--	local szPosition = MsgArmyGroup.GetPositionString(nPosition);
--	if ( nPosition == ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS or nPosition == ArmyGroupPositionGrade.AGPG_LEGATUS ) then
--		szName = szName .. "(" .. szPosition .. ")";
--	end
--	local pLabelName	= GetLabel( pLayer, ID_LABEL_NAME );
--	pLabelName:SetText( szName );
--	
--	local pBtnDismiss	= GetButton( pLayer, ID_BTN_DISMISS );
--	local pBtnPromotion	= GetButton( pLayer, ID_BTN_PROMOTION );
--	local pBtnAbdicate	= GetButton( pLayer, ID_BTN_ABDICATE );
--	pBtnDismiss:SetVisible( false );
--	pBtnPromotion:SetVisible( false );
--	pBtnAbdicate:SetVisible( false );
--	
--	local nUserArmyGroupID	= MsgArmyGroup.GetUserArmyGroupID( nUserID );
--	local nUserPosition		= MsgArmyGroup.GetUserArmyGroupPosition( nUserID );
--	if ( nUserArmyGroupID ~= ArmyGroup.nArmyGroupID ) or ( nUserPosition == ArmyGroupPositionGrade.AGPG_NONE ) then
--		-- 非本军团成员，或是普通成员
--	elseif ( nUserPosition == ArmyGroupPositionGrade.AGPG_LEGATUS ) then
--		-- 本军团的军团长
--		pBtnDismiss:SetVisible( true );
--		pBtnPromotion:SetVisible( true );
--		pBtnAbdicate:SetVisible( true );
--		if ( nPosition == ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS ) then
--			pBtnPromotion:SetTitle( SZ_DEMOTION );	-- 对象是副军团长显示降职
--		elseif ( nPosition == ArmyGroupPositionGrade.AGPG_NONE ) then
--			pBtnPromotion:SetTitle( SZ_PROMOTION );	-- 对象是普通成员显示升职
--		end
--	elseif ( nUserPosition == ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS ) and ( nPosition == ArmyGroupPositionGrade.AGPG_NONE ) then
--		-- 本军团副军团长且查看对象是普通成员
--		pBtnDismiss:SetVisible( true );
--	end
--	p.nMemberOrdinal = nOrdinal;
--	ArmyGroup.pLayerHandleMemberDlg:SetVisible( true );
--end

---------------------------------------------------
-- 军团成员面板界面的事件响应
function p.OnUIEventHandleMemberDlg( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	local nPlayerID		= p.tMember[ArmyGroupMemberIndex.AGMI_USERID];
	local szName		= p.tMember[ArmyGroupMemberIndex.AGMI_NAME];
	local nPosition		= p.tMember[ArmyGroupMemberIndex.AGMI_POSITION];
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.CloseUI();
        elseif ( ID_BTN_INFOR == tag ) then
        	-- 发送查看资料请求
			LogInfo( "HadleMember: nPlayerID:%d, szName:%s",nPlayerID,szName );
        	--MsgFriend.SendGetFriendInfo( nPlayerID );
			MsgFriend.SendFriendSel( nPlayerID, szName, nil );
			p.CloseUI();
		elseif ( ID_BTN_FRIEND == tag ) then
        	-- 发送加好友请求
        	MsgFriend.SendFriendAdd( nPlayerID );
			p.CloseUI();
		elseif ( ID_BTN_CHAT == tag ) then
        	-- 发送私聊请求
        	ChatMainUI.LoadUIbyFriendName(szName);
			p.CloseUI();
		elseif ( ID_BTN_DISMISS == tag ) then
			-- 开除
        	--MsgArmyGroup.SendMsgDismiss( nPlayerID );
			--p.CloseUI();
			local szTitle	= SZ_CONFIRM_01 .. szName .. SZ_CONFIRM_02 .. "？";
			CommonDlgNew.ShowYesOrNoDlg( szTitle, p.CallBack_Dismiss );
		elseif ( ID_BTN_PROMOTION == tag ) then
			if ( nPosition == ArmyGroupPositionGrade.AGPG_DEPUTY_LEGATUS ) then
				-- 降职
        		--MsgArmyGroup.SendMsgRemovalDeputy( nPlayerID );
				--p.CloseUI();
				local szTitle	= SZ_CONFIRM_01 .. szName .. SZ_DEMOTION .. "？";
				CommonDlgNew.ShowYesOrNoDlg( szTitle, p.CallBack_Demotion );
			elseif ( nPosition == ArmyGroupPositionGrade.AGPG_NONE ) then
				-- 升职
        		--MsgArmyGroup.SendMsgAppointDeputy( nPlayerID );
				--p.CloseUI();
				local szTitle	= SZ_CONFIRM_01 .. szName .. SZ_PROMOTION .. "？";
				CommonDlgNew.ShowYesOrNoDlg( szTitle, p.CallBack_Promotion );
			end
		elseif ( ID_BTN_ABDICATE == tag ) then
			-- 禅让
        	--MsgArmyGroup.SendMsgAbdicate( nPlayerID );
			--p.CloseUI();
			local szTitle	= SZ_CONFIRM_00 .. szName .. "？";
			CommonDlgNew.ShowYesOrNoDlg( szTitle, p.CallBack_Abdicate );
        end
    end
    return true;
end

-- 确认开除
function p.CallBack_Dismiss(nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		local nPlayerID		= p.tMember[ArmyGroupMemberIndex.AGMI_USERID];
        MsgArmyGroup.SendMsgDismiss( nPlayerID );
		p.CloseUI();
	end
end

-- 确认升职
function p.CallBack_Promotion(nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		local nPlayerID		= p.tMember[ArmyGroupMemberIndex.AGMI_USERID];
        MsgArmyGroup.SendMsgAppointDeputy( nPlayerID );
		p.CloseUI();
	end
end

-- 确认降职
function p.CallBack_Demotion(nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		local nPlayerID		= p.tMember[ArmyGroupMemberIndex.AGMI_USERID];
        MsgArmyGroup.SendMsgRemovalDeputy( nPlayerID );
		p.CloseUI();
	end
end

-- 确认禅让
function p.CallBack_Abdicate(nEvent, param )
	if ( CommonDlgNew.BtnOk == nEvent ) then
		local nPlayerID		= p.tMember[ArmyGroupMemberIndex.AGMI_USERID];
        MsgArmyGroup.SendMsgAbdicate( nPlayerID );
		p.CloseUI();
	end
end

