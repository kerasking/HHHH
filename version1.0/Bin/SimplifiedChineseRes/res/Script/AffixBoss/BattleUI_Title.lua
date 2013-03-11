---------------------------------------------------
--描述: 战斗中标题显示
--时间: 2012.11.1
--作者: Guosen
---------------------------------------------------

---------------------------------------------------

BattleUI_Title = {}
local p = BattleUI_Title;

---------------------------------------------------
-- 副本和精英副本战斗
local ID_LABEL_BATTLE_NAME				= 2;	-- 副本战斗名标签

-- 竞技场、BOSS战等战斗
local ID_LABEL_ATTACKER_NAME			= 7;	-- 进攻方名称标签
local ID_PIC_ATTACKER_MOUNT				= 3;	-- 进攻方坐骑图
local ID_LABEL_ATTACKER_MOUNT_LEVEL		= 5;	-- 进攻方坐骑等级标签

local ID_LABEL_DEFENDER_NAME			= 8;	-- 防守方名称标签
local ID_PIC_DEFENDER_MOUNT				= 4;	-- 防守方坐骑图
local ID_LABEL_DEFENDER_MOUNT_LEVEL		= 6;	-- 防守方坐骑等级标签

local BattleType = {
	BT_MONSTER		= 1,	-- 怪物战
	BT_BOSS			= 2,	-- BOSS战
	BT_SPORTS		= 3,	-- 竞技场
	BT_GRAIN		= 4,	-- 劫粮
	BT_CHAOS		= 5,	-- 大乱斗
	BT_AGBATTLE		= 6,	-- 军团战
	BT_LANDLORD		= 7,	-- 斗地主
	BT_RELIC		= 8,	-- 古迹寻宝 
};

---------------------------------------------------


---------------------------------------------------
--
function p.ShowUI( tPacket )
	if ( tPacket == nil ) then
		return false;
	end
	
	local pScene = GetSMGameScene();
	if ( pScene == nil ) then
		LogInfo( "BattleUI_Title: ShowUI failed! pScene is nil" );
		return false;
	end
	
	local pLayer = createNDUILayer();
	if not CheckP(pLayer) then
		LogInfo( "BattleUI_Title: ShowUI failed! pLayer is nil" );
		return false;
	end
	pLayer:Init();
	pLayer:SetTag( NMAINSCENECHILDTAG.BattleUI_Title );
	--pLayer:SetFrameRect( RectLayer );
	pScene:AddChildZ( pLayer, 1 );
	---
	
	local uiLoad = createNDUILoad();
	if ( nil == uiLoad ) then
		pLayer:Free();
		LogInfo( "BattleUI_Title: ShowUI failed! uiLoad is nil" );
		return false;
	end
	if ( tPacket.nBattleType == BattleType.BT_MONSTER ) or ( tPacket.nBattleType == BattleType.BT_RELIC )then
		uiLoad:Load( "Battle/BattleUI_Title1.ini", pLayer, nil, 0, 0 );
		p.SetBattleName( pLayer, tPacket.szBattleName );
	elseif ( tPacket.nBattleType == BattleType.BT_CHAOS ) then
		uiLoad:Load( "Battle/BattleUI_Title2.ini", pLayer, nil, 0, 0 );
		p.SetFightersName( pLayer, tPacket.szAttackerName, tPacket.szDefenderName );
		p.SetAttackerMount( pLayer, tPacket.nAttackerMountType, tPacket.nAttackerMountLevel );
		p.SetDefenderMount( pLayer, tPacket.nDefenderMountType, tPacket.nDefenderMountLevel );
		
		--设置星级

				
	else
		uiLoad:Load( "Battle/BattleUI_Title2.ini", pLayer, nil, 0, 0 );
		p.SetFightersName( pLayer, tPacket.szAttackerName, tPacket.szDefenderName );
		p.SetAttackerMount( pLayer, tPacket.nAttackerMountType, tPacket.nAttackerMountLevel );
		p.SetDefenderMount( pLayer, tPacket.nDefenderMountType, tPacket.nDefenderMountLevel );
	end
	uiLoad:Free();
	return true;
end

--
function p.CloseUI()
	LogInfo( "BattleUI_Title: CloseUI" );
	if IsUIShow(NMAINSCENECHILDTAG.BattleUI_Title) then
		CloseUI(NMAINSCENECHILDTAG.BattleUI_Title);
	end
end

---------------------------------------------------
--
function p.SetBattleName( pLayer, szBattleName )
	if ( pLayer == nil ) then
		return;
	end
	local pLabelBattleName = GetLabel( pLayer, ID_LABEL_BATTLE_NAME );
	if ( pLabelBattleName ~= nil ) then
		pLabelBattleName:SetText( szBattleName );
	end
	--SetLabel( pLayer, ID_LABEL_BATTLE_NAME, szBattleName );
end

---------------------------------------------------
--
function p.SetFightersName( pLayer, szAttackerName, szDefenderName )
	if ( pLayer == nil ) then
		return;
	end
	local pLabelAttackerName = GetLabel( pLayer, ID_LABEL_ATTACKER_NAME );
	if ( pLabelAttackerName ~= nil ) then
		pLabelAttackerName:SetText( szAttackerName );
	end
	local pLabelDefenderName = GetLabel( pLayer, ID_LABEL_DEFENDER_NAME );
	if ( pLabelDefenderName ~= nil ) then
		pLabelDefenderName:SetText( szDefenderName );
	end
	--SetLabel( pLayer, ID_LABEL_ATTACKER_NAME, szAttackerName );
	--SetLabel( pLayer, ID_LABEL_DEFENDER_NAME, szDefenderName );
end



function p.SetFightersLevel( pLayer, szAttackerlevel, szDefenderlevel )
	if ( pLayer == nil ) then
		LogInfo( "SetFightersLevel: pLayer nil" );
		return;
	end
	local pLabelAttackerlevel = GetLabel( pLayer, 11 );
	if ( pLabelAttackerlevel ~= nil )  then
		if szAttackerlevel > 0 then
			pLabelAttackerlevel:SetText( GetTxtPri("ADD_57_65_01")..(szAttackerlevel)..GetTxtPri("ADD_57_65_02") );
		end
	else
		LogInfo( "SetFightersLevel: pLabelAttackerlevel nil" );
			
	end
	
	
	local pLabelDefenderlevel = GetLabel( pLayer, 12 );
	if ( pLabelDefenderlevel ~= nil ) then
		if szDefenderlevel > 0 then
			pLabelDefenderlevel:SetText( GetTxtPri("ADD_57_65_01")..(szDefenderlevel)..GetTxtPri("ADD_57_65_02") );
		end	
	else
		LogInfo( "SetFightersLevel: pLabelDefenderlevel nil" );	
	end
end


---------------------------------------------------
-- 进攻方名称
function p.SetAttackerName( pLayer, szAttackerName )
	if ( pLayer == nil ) then
		return;
	end
	SetLabel( pLayer, ID_LABEL_ATTACKER_NAME, szAttackerName );
end

---------------------------------------------------
-- 进攻方坐骑
function p.SetAttackerMount( pLayer, nMountType, nMountLevel )
	if ( pLayer == nil ) then
		return;
	end
	local pPicMount		= GetImage( pLayer, ID_PIC_ATTACKER_MOUNT );
	if ( pPicMount ~= nil ) then
		if ( nMountType == nil or nMountType == 0 ) then
			pPicMount:SetVisible( false );
		else
    		local pPic = GetMountHeadPotraitPic( nMountType );
			pPic:SetReverse(true);
			pPicMount:SetPicture( pPic );
		end
	end
	local pLabelLevl	= GetLabel( pLayer, ID_LABEL_ATTACKER_MOUNT_LEVEL );
	if ( pLabelLevl ~= nil ) then
		if ( nMountLevel == nil or nMountLevel == 0 ) then
			pLabelLevl:SetVisible( false );
		else
    		local nTurn	= PetUI.GetTurn( nMountLevel );
    		local nStar	= PetUI.GetStar( nMountLevel );
			pLabelLevl:SetText( nTurn ..GetTxtPri("PETUI_T1") .. nStar .. GetTxtPri("SYN_D30") );
		end
	end
end

---------------------------------------------------
-- 防守方名称
function p.SetDefenderName( pLayer, szDefenderName )
	if ( pLayer == nil ) then
		return;
	end
	SetLabel( pLayer, ID_LABEL_DEFENDER_NAME, szDefenderName );
end

---------------------------------------------------
-- 防守方坐骑
-- 幻化等级
function p.SetDefenderMount( pLayer, nMountType, nMountLevel )
	if ( pLayer == nil ) then
		return;
	end
	local pPicMount		= GetImage( pLayer, ID_PIC_DEFENDER_MOUNT );
	if ( pPicMount ~= nil ) then
		if ( nMountType == nil or nMountType == 0 ) then
			pPicMount:SetVisible( false );
		else
    		local pPic = GetMountHeadPotraitPic( nMountType );
			pPicMount:SetPicture( pPic );
		end
	end
	local pLabelLevl	= GetLabel( pLayer, ID_LABEL_DEFENDER_MOUNT_LEVEL );
	if ( pLabelLevl ~= nil ) then
		if ( nMountLevel == nil or nMountLevel == 0 ) then
			pLabelLevl:SetVisible( false );
		else
    		local nTurn	= PetUI.GetTurn( nMountLevel );
    		local nStar	= PetUI.GetStar( nMountLevel );
			pLabelLevl:SetText( nTurn ..GetTxtPri("PETUI_T1") .. nStar .. GetTxtPri("SYN_D30") );
		end
	end
end

	
    --local img = GetMountModelPotraitPic(num);
	--local szAniPath	= NDPath_GetAnimationPath();
	--local nLockface	= GetDataBaseDataN( "mount_model_config", nMountLevel, DB_MOUNT_MODEL.LOOKFACE );
	--szAniPath = szAniPath .. "model_"..(nLockface%1000) .. ".spr";
    --local nTurn	= PetUI.GetTurn( nMountLevel );--nTurn = math.ceil( nMountLevel / 10 ) - 1;
    --local nStar	= PetUI.GetStar( nMountLevel );--nStar = nMountLevel%10; if(nStar==0) then nStar = 10; end
--p.MountInfo.illusionId--幻化等级
--    
--	local l_turn = GetLabel(layer, p.TagMountLevel.TURN);
--    l_turn:SetText( PetUI.GetTurn(p.MountInfo.star).."转" );
--
--	local l_star = GetLabel(layer, p.TagMountLevel.STAR);
--    l_star:SetText( PetUI.GetStar(p.MountInfo.star)..GetTxtPri("SYN_D30") );

---------------------------------------------------
-- 消息响应
function p.HandleNetMessage( tNetDataPackete )
	LogInfo( "BattleUI_Title: HandleNetMessage" );
	local tPacket	= {};
	tPacket.nBattleType				= tNetDataPackete:ReadByte();
	tPacket.nAttackerMountLevel	= tNetDataPackete:ReadByte();
	tPacket.nAttackerMountType		= tNetDataPackete:ReadByte();
	tPacket.nDefenderMountLevel	= tNetDataPackete:ReadByte();
	tPacket.nDefenderMountType		= tNetDataPackete:ReadByte();
	tPacket.szBattleName			= tNetDataPackete:ReadUnicodeString();
	tPacket.szAttackerName			= tNetDataPackete:ReadUnicodeString();
	tPacket.szDefenderName			= tNetDataPackete:ReadUnicodeString();
	LogInfo( "BattleUI_Title: nBattleType:%d",tPacket.nBattleType );
	LogInfo( "BattleUI_Title: szBattleName:%s",tPacket.szBattleName );
	LogInfo( "BattleUI_Title: szAttackerName:%s",tPacket.szAttackerName );
	LogInfo( "BattleUI_Title: szDefenderName:%s",tPacket.szDefenderName );
	LogInfo( "BattleUI_Title: nAttackerMountLevel:%d, nAttackerMountType:%d",tPacket.nAttackerMountLevel,tPacket.nAttackerMountType );
	LogInfo( "BattleUI_Title: nDefenderMountLevel:%d, nDefenderMountType:%d",tPacket.nDefenderMountLevel,tPacket.nDefenderMountType );
	p.ShowUI( tPacket );
end

---------------------------------------------------
RegisterNetMsgHandler( NMSG_Type._MSG_BATTLEUI_TITLE, "BattleUI_Title.HandleNetMessage", p.HandleNetMessage );

