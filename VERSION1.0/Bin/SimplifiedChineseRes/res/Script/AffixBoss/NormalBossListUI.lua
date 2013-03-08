---------------------------------------------------
--描述: 副本+精英副本
--时间: 2012.7.17
--作者: Guosen
---------------------------------------------------
-- 世界地图进入副本界面接口：		NormalBossListUI.LoadUI( nCampaignID, nPromptType);
-- 参数： nCampaignID:战役点ID

---------------------------------------------------
-- 自动寻路进入副本界面接口：		NormalBossListUI.LoadUIWithBattleID( nBattleID, nPromptType );
-- 参数： nBattleID:副本ID(精英副本或普通副本),nPromptType:提示类型(0无提示，1当前副本, 2掉落副本)

---------------------------------------------------
-- 隐藏：							NormalBossListUI.Hide();

---------------------------------------------------
-- 重新显示：						NormalBossListUI.Redisplay();

---------------------------------------------------
-- 关闭：							NormalBossListUI.Close();

---------------------------------------------------
NormalBossListUI = {}
local p = NormalBossListUI;

---------------------------------------------------
-- 副本及精英副本界面一些控件ID
local ID_BTN_CLOSE					= 3;	-- X
local ID_BTN_NORMAL					= 6;	-- 普通副本按钮ID
local ID_BTN_ELITE					= 7;	-- 精英副本按钮ID
local ID_BTN_RESET					= 4;	-- 重置按钮ID
local ID_BTN_CLEAR					= 8;	-- 扫荡按钮ID
local ID_BTN_BACK					= 16;	-- 回城按钮ID
local ID_LABEL_ENERGY				= 5;	-- 军令数值标签ID
local ID_LIST_CONTAINER				= 67;	-- 列表容器控件ID
local ID_BTN_LEFT_ARROW				= 24;	-- 左箭头控件ID
local ID_BTN_RIGHT_ARROW			= 25;	-- 右箭头控件ID
local ID_PIC_PAGE_NUM				= 65;	-- 页数控件ID

-- 列表项里的每个按钮ID
local tListItemBtnID ={
	101, 102, 103, 104, 105,
	106, 107, 108, 109, 110,
};

---------------------------------------------------
-- 确认对话框的一些控件ID
local ID_CFMDLG_BTN_CLOSE			= 80;	-- X
local ID_CFMDLG_BTN_GUIDE			= 79;	-- 攻略
local ID_CFMDLG_BTN_CLEAR			= 81;	-- 扫荡
local ID_CFMDLG_BTN_FIGHT			= 78;	-- 战斗
local ID_CFMDLG_LABEL_TITLE			= 966;	-- 标题

---------------------------------------------------
local TAG_LAYER_ELITE				= 200;	-- 精英副本页面层的TAG值
local TAG_LAYER_CONFDLG				= 300;	-- 确认对话框层的TAG值
--local N_GOLD_RESET					= 10;	-- 重置一次精英副本需要的金币
local N_GOLD_RESET ={[0]=100,[1]=300,[2]=500}

-- 副本提示类型
PromptType = {
	NONE	= 0,	-- 无提示
	TASK	= 1,	-- 当前任务副本
	DROP	= 2,	-- 材料掉落副本
};

---------------------------------------------------
p.nCampaignID						= nil;	-- 战役ID--隐藏后恢复用
p.pLayerNormal						= nil;	-- 普通副本界面
p.pLayerElite						= nil;	-- 精英副本界面
p.pLayerConfDlg						= nil;	-- 确认框界面--
p.pCtrlNormalLeftArrow				= nil;	-- 普通副本左箭头控件
p.pCtrlNormalRightArrow				= nil;	-- 普通副本右箭头控件
p.pCtrlNormalPageNum				= nil;	-- 普通副本页数控件
p.pCtrlEliteLeftArrow				= nil;	-- 精英副本左箭头控件
p.pCtrlEliteRightArrow				= nil;	-- 精英副本右箭头控件
p.pCtrlElitePageNum					= nil;	-- 精英副本页数控件
p.nChosenBattleID					= nil;	-- 选中的副本ID--隐藏后恢复用
p.nNormalDispPageNum				= nil;	-- 普通副本当前显示的页数--隐藏后恢复用
p.nEliteDispPageNum					= nil;	-- 精英副本当前显示的页数--隐藏后恢复用
p.nTaskBattleID						= nil;	-- 任务副本ID--隐藏后恢复用--寻路而得--未完成则一直存在到新的寻路
p.nPromptType						= nil;	-- 任务提示类型--隐藏后恢复用
p.bEliteLayerVisible				= nil;	-- 显示精英副本页面--隐藏后恢复用

p.bBattleInfoRank = 0;  --副本是否已经通关过
---------------------------------------------------
-- 创建并显示副本界面--WithCampaignID
function p.LoadUI( nCampaignID, nPromptType)
    MsgLogin.EnterInstanceBattle();
    ArenaUI.isInChallenge = 4;
    p.nCampaignID = nCampaignID;
    p.nPromptType = nPromptType;
        
    local pDirector = DefaultDirector();
	if ( pDirector == nil ) then
		LogInfo( "NormalBossListUI.LoadUI: pDirector == nil" );
		return false;
	end
    
	local pScene = pDirector:GetRunningScene();
	if ( pScene == nil ) then
		LogInfo( "NormalBossListUI.LoadUI: scene == nil" );
		return false;
	end

	if ( p.nTaskBattleID ~= nil ) then
		if ( TASK.GetTaskState( p.nTaskBattleID ) == TASK.SM_TASK_STATE.STATE_UNCOMPLETE ) then
			-- 完成任务则将值置空
			p.nTaskBattleID	= nil;
			p.nPromptType	= nil;
		end
	end
    
	p.GenerateNoramlLayer( pScene );
	MsgAffixBoss.mUIListener = p.HandleNetMsg;	-- 设置网络消息的响应
	
	

   	
end

---------------------------------------------------
-- 主界面按键响应
function p.OnUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		if ( ID_BTN_CLOSE == tag ) then
			p.OnBtnClose();
		elseif ( ID_BTN_NORMAL == tag ) then
			p.pLayerElite:SetVisible( false );
		elseif ( ID_BTN_ELITE == tag ) then
                p.pLayerElite:SetVisible( true );
		elseif ( ID_BTN_RESET == tag ) then
			p.OnBtnReset();
		elseif ( ID_BTN_CLEAR == tag ) then
			p.OnBtnClear();
		elseif ( ID_BTN_BACK == tag ) then
			p.OnBtnBack();
		end
	end
	return true
end

---------------------------------------------------
-- 关闭界面
function p.Close()
	local pScene = DefaultDirector():GetRunningScene();
	if ( pScene ~= nil ) then
		pScene:RemoveChildByTag( NMAINSCENECHILDTAG.AffixNormalBoss, true );
	end
p.nCampaignID						= nil;
p.pLayerNormal						= nil;
p.pLayerElite						= nil;
p.pLayerConfDlg						= nil;
p.pCtrlNormalLeftArrow				= nil;
p.pCtrlNormalRightArrow				= nil;
p.pCtrlNormalPageNum				= nil;
p.pCtrlEliteLeftArrow				= nil;
p.pCtrlEliteRightArrow				= nil;
p.pCtrlElitePageNum					= nil;
p.nChosenBattleID					= nil;
p.nNormalDispPageNum				= nil;
p.nEliteDispPageNum					= nil;
--p.nTaskBattleID						= nil;--完成任务才至空
--p.nPromptType						= nil;
p.bEliteLayerVisible				= nil;
	MsgAffixBoss.mUIListener	= nil;
end

---------------------------------------------------
-- 响应关闭按钮
function p.OnBtnClose()
	p.Close();
	--BackCity();
end

---------------------------------------------------
-- 响应回城按钮
function p.OnBtnBack()
	p.Close();
	BackCity();
end

---------------------------------------------------
-- 响应重置按钮
function p.OnBtnReset()
	--判定VIP等级，
	--local nPlayerVIPLv	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_VIP_RANK );
	--if ( nPlayerVIPLv < 3 ) then
    
    local nNeedLevel = GetGetVipLevel_ELITE_MAP_RESET_NUM();
    if ( nNeedLevel<=0 ) then
		CommonDlgNew.ShowYesDlg( string.format(GetTxtPri("CUESU_T3"),nNeedLevel), nil, nil, 3 );
		return;
	end
	--获得可重置次数
	local nResetCount	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_INSTANCING_RESET_COUNT );
    nResetCount = ConvertReset(nResetCount, p.nCampaignID);
    local nResetNumber	= RolePetFunc.GetResetNumber(p.nCampaignID);
    
    LogInfo("nResetCount:[%d],nResetNumber:[%d],p.nCampaignID:[%d]",nResetCount,nResetNumber,p.nCampaignID);
	if ( nResetNumber > 0 ) then
		CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("CUESU_T4")..N_GOLD_RESET[nResetCount]..GetTxtPri("CUESU_T5"), p.Callback_CostGoldToReset, true );
	else
		CommonDlgNew.ShowYesDlg( GetTxtPri("CUESU_T6"), nil, nil, 3 );
	end
end

-- 确定重置精英副本的回调
function p.Callback_CostGoldToReset( nId, param )
	if ( CommonDlgNew.BtnOk == nId ) then
		local nPlayerID		= GetPlayerId();--User表中的ID
		local nPlayerGold	= GetRoleBasicDataN( nPlayerID, USER_ATTR.USER_ATTR_EMONEY );
        
		local nResetCount	= GetRoleBasicDataN( GetPlayerId(), USER_ATTR.USER_ATTR_INSTANCING_RESET_COUNT );
        nResetCount = ConvertReset(nResetCount, p.nCampaignID);
        local nResetNumber	= RolePetFunc.GetResetNumber(p.nCampaignID);
        if ( nPlayerGold < N_GOLD_RESET[nResetCount] ) then
			CommonDlgNew.ShowYesDlg( GetTxtPri("CUESU_T7"), nil, nil, nil );
		else
		-- 发送重置精英副本的消息
			MsgAffixBoss.sendNmlReset( p.nCampaignID );
		end
	end
end

---------------------------------------------------
-- 响应扫荡按钮
function p.OnBtnClear()
	local tBattleIDList, nCount = AffixBossFunc.findBossList( p.nCampaignID, 1 );
	for i = 1, nCount do
		if ( ( tBattleIDList[i].rank == 1 ) and ( tBattleIDList[i].time == 0 ) ) then
			NormalBossListUI.Hide();
			ClearUpEliteSettingUI.LoadUI( p.nCampaignID );
			return;
		end
	end
	CommonDlgNew.ShowYesDlg( GetTxtPri("CUESU_T2"), nil, nil, 3 );
end

---------------------------------------------------
-- 创建普通副本界面--一并创建了精英副本界面及确认对话框
function p.GenerateNoramlLayer( pScene )
    
    local layer = createNDUILayer();
	if ( layer == nil ) then
		LogInfo( "NormalBossListUI: GenerateNoramlLayer() failed! createNDUILayer = nil" );
		return false;
	end
    
    layer:SetPopupDlgFlag(true);
	layer:Init();
	layer:SetDebugName("NormalBoss_layer");
	layer:SetTag( NMAINSCENECHILDTAG.AffixNormalBoss );
	layer:SetFrameRect( RectFullScreenUILayer );
	pScene:AddChildZ( layer,UILayerZOrder.NormalLayer );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "NormalBossListUI: GenerateNoramlLayer() failed! createNDUILoad = nil" );
		return false;
	end
	
	uiLoad:Load( "TranscriptUI_Normal.ini", layer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	p.pLayerNormal = layer;
	p.InitializeNoramlLayer();
	p.GenerateEliteLayer( p.pLayerNormal );
	p.pLayerElite:SetVisible( false );
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_BTN_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
	--p.GenerateConfirmDialog( p.pLayerNormal );
	--p.pLayerConfDlg:SetVisible( false );
    
    
    SetArrow(p.pLayerNormal,p.GetPageContainer(),1,ID_BTN_LEFT_ARROW,ID_BTN_RIGHT_ARROW);
end

function p.GetPageContainer()
    local pListContainer = GetScrollViewContainer( p.pLayerNormal, ID_LIST_CONTAINER );
    return pListContainer;
end



-- 初始化普通副本界面
function p.InitializeNoramlLayer()

	if ( p.pLayerNormal == nil ) then
		return false;
	end
	
	-- 军令值(体力值)
	local pLabelEnergy	= GetLabel( p.pLayerNormal, ID_LABEL_ENERGY )
	local nEnergy		= PlayerFunc.GetStamina( GetPlayerId() );
	if ( CheckP(pLabelEnergy) ) then
		pLabelEnergy:SetText( SafeN2S(nEnergy) );
	end
	
	--副本按钮置灰
	local pBtnNormal	= GetButton( p.pLayerNormal, ID_BTN_NORMAL );
	--pBtnNormal:EnalbeGray( true );
    --pBtnNormal:SetFocusImage();
	
    --获取箭头与数字
	p.pCtrlNormalLeftArrow	= GetImage( p.pLayerNormal, ID_BTN_LEFT_ARROW );
	p.pCtrlNormalRightArrow	= GetImage( p.pLayerNormal, ID_BTN_RIGHT_ARROW );
	p.pCtrlNormalPageNum	= GetImage( p.pLayerNormal, ID_PIC_PAGE_NUM );
	
	-- 获得该战役的普通副本信息表    
    --tBattleIDList 副本信息列表  nCount副本的总数量
	local tBattleIDList, nCount = AffixBossFunc.findBossList( p.nCampaignID, 0 );
	if ( nCount == 0 ) then
		return false;
	end
	
	-- 列表控件
	local pListContainer = GetScrollViewContainer( p.pLayerNormal, ID_LIST_CONTAINER );
	pListContainer:SetLuaDelegate( p.OnUIEventNormalListView );--设置滚屏容器事件回调
	pListContainer:ShowViewByIndex(0);
	pListContainer:RemoveAllView();
	pListContainer:SetStyle( UIScrollStyle.Horzontal );
	pListContainer:SetViewSize( pListContainer:GetFrameRect().size );
	
    --获取列表控件容纳数量
	local nListItemLimit	= table.getn( tListItemBtnID );
    --计算需要显示的页数
	local view_page_amount	= ( nCount + ( nListItemLimit - 1 ) ) / nListItemLimit;
        
    --遍历所有的页，填充其中的内容
	for i = 1, view_page_amount do
		local pListItem = createUIScrollView();
		if not CheckP( pListItem ) then
			LogInfo( "NormalBossListUI: InitializeNoramlLayer failed! pListItem is nil" );
			return false;
		end

		pListItem:SetPopupDlgFlag(true);
		pListItem:Init( false );
		pListItem:SetDebugName("NormalBoss_Scroll_layer");
		pListItem:SetViewId( i );
		pListItem:SetTag( i );
		pListContainer:AddView( pListItem );

		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			LogInfo( "NormalBossListUI: InitializeNoramlLayer failed! uiLoad is nil" );
			return false;
		end

		-- 关联列表项UI与视图与事件响应
		uiLoad:Load( "TranscriptUI_ListItem.ini", pListItem, p.OnListItemEvent, 0, 0 );
		uiLoad:Free();
		p.FillListItem( pListItem, tBattleIDList, i );
	end

    --[[
    local nUserStage	= PlayerFunc.GetPlayerStage();
    LogInfo( "NormalBossListUI: nUserStage = %d", nUserStage );
    local nPositionPageNum	= 1;
	for i = 0, nCount do
        if( tBattleIDList[i + 1] == nil) then
            nPositionPageNum = view_page_amount;
            break;
        end
    
        local nNeedStage	= AffixBossFunc.findStage( tBattleIDList[i + 1].typeid );
        LogInfo( "NormalBossListUI: nNeedStage = %d", nNeedStage );
		if ( nNeedStage >= nUserStage) then
			nPositionPageNum = ( i + ( nListItemLimit - 1 ) ) / nListItemLimit;
            LogInfo( "NormalBossListUI: i = %d", i );
			break;
		end
	end    
    ]]
    
    local nPositionPageNum	= 0;
    local nBreakNum	= 0;  
	--获取当前显示的页码
    for i = 1, nCount do
        if( tBattleIDList[i] == nil) then
            nPositionPageNum = view_page_amount;
            break;
        end
    
        local bIsCanShow = p.IsBattleCanShow( tBattleIDList[i].typeid)
		if ( bIsCanShow ~= true) then
			nPositionPageNum = ( i - 1 + ( nListItemLimit - 1 ) ) / nListItemLimit;
            LogInfo( "NormalBossListUI: i = %d", i );
			break;
		end
        nBreakNum = i;
	end    
    --当前所有的副本都可以显示，那么显示最后一页
    if (nBreakNum == nCount) then
       nPositionPageNum = view_page_amount;
    end
    
    if nPositionPageNum == 0 then
       nPositionPageNum = 1;
    end

    LogInfo( "NormalBossListUI: nPositionPageNum = %d", nPositionPageNum );
	p.ShowNormalPageNum( nPositionPageNum );
	p.ShowNormalArrow(nPositionPageNum, view_page_amount );
    pListContainer:ShowViewByIndex(nPositionPageNum - 1);
	--pListContainer:ShowViewByIndex(0);--此处调用会造成 1 ~= 1 的现象--????????????????????????????????????????????????????????
end

---------------------------------------------------
-- 响应列表项UI的事件--点击副本按钮
function p.OnListItemEvent( uiNode, uiEventType, param )
	local nTag = uiNode:GetTag();
	--LogInfo( "NormalBossListUI: touch item:%d", uiNode:GetParent() );
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
		--LogInfo( "NormalBossListUI: nTag:%d ", nTag );
		p.ShowConfirmDialog( nTag );
	end
	return true;
end

---------------------------------------------------
--战斗副本是否可显示    入参战斗副本id
function p.IsBattleCanShow( nBattleID)
    if nBattleID == nil then
       return false;
    end
    
    local nPreId = AffixBossFunc.findPreId( nBattleID );
    LogInfo( "p.IsBattleCanShow:nBattleID = %d, nPreId = %d", nBattleID, nPreId);

    --获取角色所处的阶段
	local nUserStage	= PlayerFunc.GetPlayerStage();  
    local nNeedStage	= AffixBossFunc.findStage(nBattleID);
    
   LogInfo( "p.IsBattleCanShow: nNeedStage = %d,  nUserStage = %d",  nNeedStage, nUserStage);
    
    if (nPreId == 0) then
      if ( nNeedStage < nUserStage ) then
        LogInfo( "p.IsBattleCanShow:nPreId == 0");
        return true;
      else 
        return false;
      end
    end
    
    local nPreRank = 2, nId;
    if (nPreId ~= nil) then
        local bElite             = AffixBossFunc.findElite( nPreId );
        nId, nPreRank = AffixBossFunc.getBossInfoCache(bElite, nPreId);
    else
        LogInfo( "nPreId == nil return ture");
        return true;
    end    

   LogInfo( "p.IsBattleCanShow: nNeedStage = %d,  nUserStage = %d, inPreRank = %d",  nNeedStage, nUserStage, nPreRank);
   
    if ( nNeedStage < nUserStage ) and (( nPreid == 0) or (nPreRank == 1)) then
        LogInfo( "p.IsBattleCanShow: return true");
       return true;
    else
        LogInfo( "p.IsBattleCanShow: return false");
       return false;
    end
    
    return false;
end
    
-- 填充列表视图，
-- 列表项UI层, 
-- 参数：pLayerListItem:层, tList:副本表, nCurPageNum:
function p.FillListItem( pLayerListItem, tBattleIDList, nPageNum )
	
    --副本总数量
    local nBattleIDAmount	= table.getn( tBattleIDList );
    --一页可显示的数量
	local nBtnAmount		= table.getn( tListItemBtnID );

	if ( nil == pLayerListItem ) or ( nil == tBattleIDList ) or( 0 == nBattleIDAmount )
		or ( 0 == nPageNum ) or ( ( nPageNum - 1 ) * nBtnAmount > nBattleIDAmount ) then
		return;
	end

	LogInfo( "p.FillListItem: nBattleIDAmount = %d, nPageNum = %d",nBattleIDAmount, nPageNum);
	
    --循环当前页，显示图片
    for i = 1, nBtnAmount do
		local pBtnBattle	= GetButton( pLayerListItem, tListItemBtnID[i] );
		local tBattleInfo	= tBattleIDList[ ( nPageNum - 1 ) * nBtnAmount + i ];
        
		if ( tBattleInfo ~= nil ) then
        
            local bCanShow = p.IsBattleCanShow(tBattleInfo.typeid);
            if bCanShow == true then
            	--LogInfo( "GetMapPic tBattleInfo.typeid = %d, i = %d", tBattleInfo.typeid, i );
				local pPic	= nil;
				if ( tBattleInfo.elite == 1 ) and ( tBattleInfo.time ~= 0 ) then
					--pPic:SetGrayState( true );
                    pPic	= GetEliteGrayMapPic( tBattleInfo.typeid );
                else
                    pPic	= GetMapPic( tBattleInfo.typeid );
				end
				pBtnBattle:SetImage( pPic );
			else
				local pool		= DefaultPicPool();
				local pPic	=  pool:AddPicture( GetSMImgPath("transcript/icon_transcript_locked.png"), false )
				pBtnBattle:SetImage( pPic );
			end
			pBtnBattle:SetTag( tBattleInfo.typeid );
			if ( p.nTaskBattleID == tBattleInfo.typeid ) then
				p.ShowPrompt( pBtnBattle, p.nPromptType );
			end
		else
            LogInfo( "tBattleInfo == nil, i = %d", i );
			pBtnBattle:SetVisible( false );
		end
	end
end

---------------------------------------------------
-- 响应滚屏事件-普通副本
function p.OnUIEventNormalListView( uiNode, uiEventType, param )
	LogInfo( "NormalBossListUI: OnUIEventNormalListView()" );
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN ) then
		-- 某视图跑到容器起始处,param 为索引
		local containter	= ConverToSVC(uiNode);
		--
		p.ShowNormalPageNum( param + 1 );
		p.ShowNormalArrow( param + 1, containter:GetViewCount() );
		--
	end
	return true;
end

-- 显示第几页(0~9)-普通副本
function p.ShowNormalPageNum( nPageNum )
    p.nNormalDispPageNum	= math.floor(nPageNum);
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
	-- 数字图像一个数字的宽高
	local N_W = 42;
	local N_H = 34;
	local norpic = pool:AddPicture( GetSMImgPath( "number/num_1.png" ), false);
	-- 
	--local tRect = CGRectMake( N_W*nPageNum, 0, N_W, N_H );
    local tRect = CGRectMake( N_W*p.nNormalDispPageNum, 0, N_W, N_H );
	norpic:Cut( tRect );
	p.pCtrlNormalPageNum:SetPicture(norpic);
    
    
    SetArrow(p.pLayerNormal,p.GetPageContainer(),1,ID_BTN_LEFT_ARROW,ID_BTN_RIGHT_ARROW);
end

--显示箭头-普通副本
function p.ShowNormalArrow( nCurPageNum, nMaxPageNum )
		LogInfo( "NormalBossListUI: ShowNormalArrow() nCurPageNum:%d, nMaxPageNum:%d",nCurPageNum,nMaxPageNum );
	--nCurPageNum为0时全灰
	if ( 0 == nCurPageNum ) then
		p.pCtrlNormalLeftArrow:GetPicture():SetGrayState( true );
		p.pCtrlNormalRightArrow:GetPicture():SetGrayState( true );
	else
		if ( 1 == nCurPageNum ) then
			p.pCtrlNormalLeftArrow:GetPicture():SetGrayState( true );
		LogInfo( "NormalBossListUI: ShowNormalArrow() nnCurPageNum == 1"  );
		else
			p.pCtrlNormalLeftArrow:GetPicture():SetGrayState( false );
		LogInfo( "NormalBossListUI: ShowNormalArrow() nCurPageNum ~= 1"  );
		end
		if ( nMaxPageNum <= nCurPageNum ) then
			p.pCtrlNormalRightArrow:GetPicture():SetGrayState( true );
		--LogInfo( "NormalBossListUI: ShowNormalArrow() nMaxPageNum <= nCurPageNum"  );
		else
			p.pCtrlNormalRightArrow:GetPicture():SetGrayState( false );
		--LogInfo( "NormalBossListUI: ShowNormalArrow() nMaxPageNum > nCurPageNum"  );
		end
	end
end

---------------------------------------------------
-- 创建精英副本层
function p.GenerateEliteLayer( pParentLayer )
	local layer = createNDUILayer();
	if ( layer == nil ) then
		LogInfo( "NormalBossListUI: GenerateEliteLayer() failed! layer = nil" );
		return false;
	end
	layer:SetPopupDlgFlag(true);
	layer:Init();
	layer:SetDebugName("EliteBoss_layer");
	--layer:SetTag( TAG_LAYER_ELITE );
	layer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(125, 125, 125, 0) );
	pParentLayer:AddChild( layer );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "NormalBossListUI: GenerateEliteLayer() failed! uiLoad = nil" );
		return false;
	end
	
	uiLoad:Load( "TranscriptUI_Elite.ini", layer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	p.pLayerElite = layer;
	p.InitializeEliteLayer();
	
	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_BTN_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
    
    SetArrow(p.pLayerElite,p.GetElitePageContainer(),1,ID_BTN_LEFT_ARROW,ID_BTN_RIGHT_ARROW);
end

function p.GetElitePageContainer()
    local pListContainer = GetScrollViewContainer( p.pLayerElite, ID_LIST_CONTAINER );
    return pListContainer;
end

---------------------------------------------------
-- 初始化精英副本界面
function p.InitializeEliteLayer()
	LogInfo( "NormalBossListUI: InitializeEliteLayer() " );
	if ( p.pLayerElite == nil ) then
		return false;
	end
	
	--local pBtnNormal	= GetButton( p.pLayerElite, ID_BTN_NORMAL );
	local pBtnElite	= GetButton( p.pLayerElite, ID_BTN_ELITE );
	--pBtnElite:EnalbeGray( true );
	
	p.pCtrlEliteLeftArrow	= GetImage( p.pLayerElite, ID_BTN_LEFT_ARROW );
	p.pCtrlEliteRightArrow	= GetImage( p.pLayerElite, ID_BTN_RIGHT_ARROW );
	p.pCtrlElitePageNum		= GetImage( p.pLayerElite, ID_PIC_PAGE_NUM );



	local pBtnClear			= GetButton( p.pLayerElite, ID_BTN_CLEAR );
	local pBtnReset			= GetButton( p.pLayerElite, ID_BTN_RESET );
	local nResetNumber		= RolePetFunc.GetResetNumber(p.nCampaignID);
	local szTitle			= GetTxtPri("CUESU_Reset");
    
    --扫荡功能开启之后才可以显示重置按钮以及扫荡按钮
    if IsFunctionOpen(StageFunc.RepeatCoyp) then
    	--重置次数小于等于0那么置灰
        if ( nResetNumber > 0 ) then
            szTitle				= szTitle .. "(" .. nResetNumber .. ")";
        else
            pBtnReset:EnalbeGray(true);
        end
        pBtnReset:SetTitle( szTitle );
    else
        pBtnReset:SetVisible(false);
        pBtnClear:SetVisible(false);
    end
    
	
	---- 获得该战役的精英副本信息表
	local tBattleIDList, nCount = AffixBossFunc.findBossList( p.nCampaignID, 1 );
    LogInfo( "p.InitializeEliteLayer p.nCampaignID = %d", p.nCampaignID);
        
	-- 列表控件
	local pListContainer = GetScrollViewContainer( p.pLayerElite, ID_LIST_CONTAINER );
	pListContainer:SetLuaDelegate( p.OnUIEventEliteListView );--设置滚屏容器事件回调
	pListContainer:ShowViewByIndex(0);
	pListContainer:RemoveAllView();
	pListContainer:SetStyle( UIScrollStyle.Horzontal );
	pListContainer:SetViewSize( pListContainer:GetFrameRect().size );
	if ( nCount == 0 ) then
		return false;
	end
	
	local nListItemLimit	= table.getn( tListItemBtnID );
	local view_page_amount	= ( nCount + ( nListItemLimit - 1 ) ) / nListItemLimit;
	for i = 1, view_page_amount do
		local pListItem = createUIScrollView();
		if not CheckP( pListItem ) then
			LogInfo( "NormalBossListUI: InitializeNoramlLayer failed! pListItem is nil" );
			return false;
		end

		pListItem:SetPopupDlgFlag(true);
		pListItem:Init( false );
		pListItem:SetDebugName("EliteBoss_Scroll_layer");
		pListItem:SetViewId( i );
		pListItem:SetTag( i );
		pListContainer:AddView( pListItem );

		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			LogInfo( "NormalBossListUI: InitializeNoramlLayer failed! uiLoad is nil" );
			return false;
		end

		-- 关联列表项UI与视图与事件响应
		uiLoad:Load( "TranscriptUI_ListItem.ini", pListItem, p.OnListItemEvent, 0, 0 );
		uiLoad:Free();
        LogInfo( "p.InitializeEliteLayer i= %d nCount= %d view_page_amount=%d", i, nCount, view_page_amount);
		p.FillListItem( pListItem, tBattleIDList, i );
	end
	--p.ShowElitePageNum( 1 );
	--p.ShowEliteArrow( 1, view_page_amount ); -- 此处 view_page_amount 导致 1 > 1 的情况发生;但是直接传递 1,1 就正常 --????????????????????????????????????????????????????????
	pListContainer:ShowViewByIndex(0);
end

---------------------------------------------------
-- 响应滚屏事件-精英副本
function p.OnUIEventEliteListView( uiNode, uiEventType, param )
	LogInfo( "NormalBossListUI: OnUIEventEliteListView()" );
	local tag = uiNode:GetTag();
	if ( uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN ) then
		-- 某视图跑到容器起始处,param 为索引
		local containter	= ConverToSVC(uiNode);
		--
		p.ShowElitePageNum( param + 1 );
		p.ShowEliteArrow( param + 1, containter:GetViewCount() );
		--
	end
	return true;
end

-- 显示第几页(0~9)-精英副本
function p.ShowElitePageNum( nPageNum )
	p.nEliteDispPageNum	= nPageNum;
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end
	-- 数字图像一个数字的宽高
	local N_W = 42;
	local N_H = 34;
	local norpic = pool:AddPicture( GetSMImgPath( "number/num_1.png" ), false);
	-- 
	local tRect = CGRectMake( N_W*nPageNum, 0, N_W, N_H );
	norpic:Cut( tRect );
	p.pCtrlElitePageNum:SetPicture(norpic);
    
    SetArrow(p.pLayerElite,p.GetElitePageContainer(),1,ID_BTN_LEFT_ARROW,ID_BTN_RIGHT_ARROW);
end

--显示箭头-精英副本
function p.ShowEliteArrow( nCurPageNum, nMaxPageNum )
		LogInfo( "NormalBossListUI: ShowEliteArrow() nCurPageNum:%d, nMaxPageNum:%d",nCurPageNum,nMaxPageNum );
	--nCurPageNum为0时全灰
	if ( 0 == nCurPageNum ) then
		p.pCtrlEliteLeftArrow:GetPicture():SetGrayState( true );
		p.pCtrlEliteRightArrow:GetPicture():SetGrayState( true );
	else
		if ( 1 == nCurPageNum ) then
			p.pCtrlEliteLeftArrow:GetPicture():SetGrayState( true );
		else
			p.pCtrlEliteLeftArrow:GetPicture():SetGrayState( false );
		end
		if ( nMaxPageNum <= nCurPageNum ) then
			p.pCtrlEliteRightArrow:GetPicture():SetGrayState( true );
		LogInfo( "NormalBossListUI: ShowEliteArrow() nMaxPageNum <= nCurPageNum"  );
		else
			p.pCtrlEliteRightArrow:GetPicture():SetGrayState( false );
		LogInfo( "NormalBossListUI: ShowEliteArrow() nMaxPageNum > nCurPageNum"  );
		end
	end
end

---------------------------------------------------
-- 创建确认窗口
function p.GenerateConfirmDialog( pParentLayer )
	local layer = createNDUILayer();
	if ( layer == nil ) then
		LogInfo( "NormalBossListUI: GenerateConfirmDialog() failed! layer = nil" );
		return false;
	end
	layer:SetPopupDlgFlag(true);
	layer:Init();
	layer:SetDebugName("NormalBoss_ConfirmDialog");
	--layer:SetTag( TAG_LAYER_CONFDLG );
	layer:SetFrameRect( RectFullScreenUILayer );
	--layer:SetBackgroundColor( ccc4(125, 125, 125, 0) );
	pParentLayer:AddChild( layer );
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if not CheckP(uiLoad) then
		LogInfo( "NormalBossListUI: GenerateConfirmDialog() failed! uiLoad = nil" );
		return false;
	end
	
	uiLoad:Load( "TranscriptLoad.ini", layer, p.OnUIEventConfirmDialog, 0, 0 );
	uiLoad:Free();
	p.pLayerConfDlg	= layer;
end

---------------------------------------------------
-- 确认窗口UI响应
function p.OnUIEventConfirmDialog( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if ( p.nChosenBattleID == nil ) then
		return true;
	end
	local tBattleInfo	= AffixBossFunc.getBossInfo( p.nChosenBattleID );
	if ( tBattleInfo == nil ) then
		return true;
	end
	local nEnergy = PlayerFunc.GetStamina(GetPlayerId());
	if ( uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK ) then
        
        --关闭
		if ( ID_CFMDLG_BTN_CLOSE == tag ) then
			p.CloseConfirmDialog();
         -- 攻略
		elseif ( ID_CFMDLG_BTN_GUIDE == tag ) then
			p.CloseConfirmDialog();
            _G.MsgDynMap.SendDynMapGuide( 0, p.nChosenBattleID );
            LogInfo( "NormalBossListUI: p.nChosenBattleID11 = %d", p.nChosenBattleID );   
        --扫荡
		elseif ( ID_CFMDLG_BTN_CLEAR == tag ) then
			p.CloseConfirmDialog();
			if ( tBattleInfo.elite == 0 ) then
				if ( nEnergy > 0 ) then
					NormalBossListUI.Hide();
					ClearUpSettingUI.LoadUI( p.nChosenBattleID );
					return true;
				else
					CommonDlgNew.ShowYesDlg( GetTxtPri("CUSU_T2"), nil, nil, 3 );
				end
            end
        --战斗
		elseif ( ID_CFMDLG_BTN_FIGHT == tag ) then
			p.CloseConfirmDialog();
			if ( tBattleInfo.elite == 0 ) then
				if ( nEnergy > 0 ) then
					MsgAffixBoss.sendNmlEnter( p.nChosenBattleID );
					return true;
				else
                    --先判断是否允许再买军令
                    local allowBuyCount = AssistantUI.allowBuyStaminaCount();
                    LogInfo( "allowBuyCount = %d", allowBuyCount ); 
                    if(allowBuyCount > 0) then
                        PlayerVIPUI.buyMilOrderTip( p.nChosenBattleID );
                    else
                        CommonDlgNew.ShowYesDlg( GetTxtPri("CUSU_T2"), nil, nil, 3);
                    end
                end
            else
            	if ( tBattleInfo.time == 0 ) then
					MsgAffixBoss.sendNmlEnter( p.nChosenBattleID );
				else
                    local nNeedLevel = GetGetVipLevel_ELITE_MAP_RESET_NUM();
                
					CommonDlgNew.ShowYesDlg(string.format(GetTxtPri("NORMAL_T4"),nNeedLevel), nil, nil, 3 );
				end
            end
		end
	end
	return true;
end
---------------------------------------------------
-- 显示确认对话框
-- 参数：nBattleID:副本ID
function p.ShowConfirmDialog( nBattleID )
	if ( nBattleID == nil ) then
		return false;
	end
	if ( p.pLayerConfDlg ~= nil ) then
		p.CloseConfirmDialog();
	end
	
	local tBattleInfo	= AffixBossFunc.getBossInfo( nBattleID );
    
    p.bEliteLayerVisible = p.pLayerElite:IsVisibled();--保存该值来重新显示并定位
    
	if ( tBattleInfo == nil ) then
		LogInfo( "NormalBossListUI: p.ShowConfirmDialog() tBattleInfo == nil " );
		return false;
	else
		local nNeedStage	= AffixBossFunc.findStage( tBattleInfo.typeid );
		local nUserStage	= PlayerFunc.GetPlayerStage();
        local bIsCanShow = p.IsBattleCanShow(tBattleInfo.typeid );
		--if ( nUserStage <= nNeedStage ) then
        if ( bIsCanShow ~= true ) then
			CommonDlgNew.ShowYesDlg( GetTxtPri("TPL2_T5"), nil, nil, 3 );
			return false;
		end
        
		p.GenerateConfirmDialog( p.pLayerNormal );
		p.nChosenBattleID	= nBattleID;
		local pBtnGuide		= GetButton( p.pLayerConfDlg, ID_CFMDLG_BTN_GUIDE );
		local pBtnClear		= GetButton( p.pLayerConfDlg, ID_CFMDLG_BTN_CLEAR );
		local pBtnFight		= GetButton( p.pLayerConfDlg, ID_CFMDLG_BTN_FIGHT );
		local pLabelTitle	= GetLabel( p.pLayerConfDlg, ID_CFMDLG_LABEL_TITLE );
        p.bBattleInfoRank = tBattleInfo.rank;
        
		if ( tBattleInfo.elite == 0 ) then
			if ( tBattleInfo.rank == 0 ) or not IsFunctionOpen(StageFunc.RepeatCoyp) then
				pBtnClear:SetVisible( false );
			else
				pBtnClear:SetVisible( true );
			end
		else
			pBtnClear:SetVisible( false );
		end
		pLabelTitle:SetText( tBattleInfo.name );
		p.pLayerConfDlg:SetVisible( true );
        
		return true;
	end
end

function p.GetIsBattleRank()
    if(p.nChosenBattleID == nil) then
        return 1;
    end
	local tBattleInfo	= AffixBossFunc.getBossInfo( p.nChosenBattleID );
    
	if ( tBattleInfo == nil ) then
		LogInfo( "NormalBossListUI: p.ShowConfirmDialog() tBattleInfo == nil " );
		return false;
	else
        p.bBattleInfoRank = tBattleInfo.rank;
    end

    return p.bBattleInfoRank;
end

--是否为精英副本
function p.GetIsBattleType()
	local tBattleInfo	= AffixBossFunc.getBossInfo( p.nChosenBattleID );
    
	if ( tBattleInfo == nil ) then
		LogInfo( "NormalBossListUI: p.ShowConfirmDialog() tBattleInfo == nil " );
		return 0;
    end

    return tBattleInfo.elite;
end

--
-- 关闭确认对话框
function p.CloseConfirmDialog()
	if ( p.pLayerConfDlg ~= nil ) then
		p.pLayerConfDlg:GetParent():RemoveChild( p.pLayerConfDlg, true );
		p.pLayerConfDlg = nil;--	p.pLayerConfDlg:SetVisible( false );
	end
end


---------------------------------------------------
-- 处理网络消息
function p.HandleNetMsg( nMsgID, param )
	if ( nMsgID == nil ) then
		return;
	end
	if ( nMsgID == NMSG_Type._MSG_AFFIX_BOSS_NML_RESET ) then
		-- 响应重置消息
		if ( p.pLayerElite ~= nil ) then
			p.InitializeEliteLayer();
		end
	end
end

---------------------------------------------------
-- 隐藏--进入战斗，进入扫荡，查看战斗记录时调用--(精英扫荡不记录进入战斗的副本ID,)
function p.Hide()
	local pScene = DefaultDirector():GetRunningScene();
	if ( pScene == nil ) then
		return;
	end
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.AffixNormalBoss );
	if ( pLayer == nil ) then
		return;
	end
    
	--p.bEliteLayerVisible = p.pLayerElite:IsVisibled();--保存该值来重新显示并定位
    
	pScene:RemoveChild( pLayer, true );
--p.nCampaignID						= nil;-- 通过该值来重新显示并定位
p.pLayerNormal						= nil;
p.pLayerElite						= nil;
p.pLayerConfDlg						= nil;
p.pCtrlNormalLeftArrow				= nil;
p.pCtrlNormalRightArrow				= nil;
p.pCtrlNormalPageNum				= nil;
p.pCtrlEliteLeftArrow				= nil;
p.pCtrlEliteRightArrow				= nil;
p.pCtrlElitePageNum					= nil;
--p.nChosenBattleID					= nil;--通过该值，再来一次战斗
--p.nNormalDispPageNum				= nil;-- 通过该值来重新显示并定位
--p.nEliteDispPageNum					= nil;-- 通过该值来重新显示并定位
--p.nTaskBattleID						= nil;-- 通过该值来重新显示并定位
--p.nPromptType						= nil;-- 通过该值来重新显示并定位
--p.bEliteLayerVisible				= nil;-- 通过该值来重新显示并定位
	MsgAffixBoss.mUIListener	= nil;
end

---------------------------------------------------
-- 竞技场查看以及攻略结束时候需要调用
function p.RedisplayWorldMap()
	if ( p.nCampaignID == nil ) then
		return;
	end
    WorldMap(p.nCampaignID);  
end




-- 重新显示--结束战斗，结束扫荡时调用
function p.Redisplay()
	if ( p.nCampaignID == nil ) then
		return;
	end
	local pScene = DefaultDirector():GetRunningScene();
	if ( pScene == nil ) then
		return;
	end
	local pLayer = GetUiLayer( pScene, NMAINSCENECHILDTAG.AffixNormalBoss );
	if ( pLayer ~= nil ) then
		MsgAffixBoss.mUIListener = p.HandleNetMsg;	-- 设置网络消息的响应--
		return;
	end
	if ( p.nTaskBattleID ~= nil ) then
		if ( TASK.GetTaskState( p.nTaskBattleID ) == TASK.SM_TASK_STATE.STATE_UNCOMPLETE ) then
			-- 完成任务则将值置空
			p.nTaskBattleID	= nil;
			p.nPromptType	= nil;
		end
	end
	local nNormalDispPageNum	= p.nNormalDispPageNum;
	local nEliteDispPageNum		= p.nEliteDispPageNum;
	local bEliteLayerVisible	= p.bEliteLayerVisible;
	
	p.LoadUI( p.nCampaignID );
	
	if ( nNormalDispPageNum ~= nil ) and ( nNormalDispPageNum > 0 ) then
		local pListContainer = GetScrollViewContainer( p.pLayerNormal, ID_LIST_CONTAINER );
		--p.ShowNormalPageNum( nNormalDispPageNum );
		--p.ShowNormalArrow( nNormalDispPageNum, pListContainer:GetViewCount() );
		pListContainer:ShowViewByIndex( nNormalDispPageNum-1 );
	end
	
	if ( nEliteDispPageNum ~= nil ) and ( nEliteDispPageNum > 0 ) then
		local pListContainer = GetScrollViewContainer( p.pLayerElite, ID_LIST_CONTAINER );
		--p.ShowElitePageNum( nPositionPageNum );
		--p.ShowEliteArrow( nPositionPageNum, pListContainer:GetViewCount() );
		pListContainer:ShowViewByIndex( nEliteDispPageNum-1 );
	end
	
	if ( p.pLayerElite ~= nil ) then
		if ( bEliteLayerVisible == true ) then
			p.pLayerElite:SetVisible( true );
		else
			p.pLayerElite:SetVisible( false );
		end
	end
end

---------------------------------------------------
-- 通过副本ID进入副本界面--定位到该副本ID所在的页
-- 参数： nBattleID:副本ID, nPromptType:提示类型(0无提示，1当前副本, 2掉落副本)
function p.LoadUIWithBattleID( nBattleID, nPromptType )
    MsgLogin.EnterInstanceBattle();
	p.nTaskBattleID		= nBattleID;
	p.nPromptType		= nPromptType;
	if ( nBattleID == nil ) then
		LogInfo( "NormalBossListUI: p.LoadUIWithBattleID() nBattleID is nil " );
		return;
	end
	local tBattleInfo	= AffixBossFunc.getBossInfo( nBattleID );
	if ( tBattleInfo == nil ) then
		LogInfo( "NormalBossListUI: p.LoadUIWithBattleID() tBattleInfo is nil " );
		return;
	end
	local nCampaignID	= AffixBossFunc.findMapId( tBattleInfo.elite, tBattleInfo.typeid );
	if ( nCampaignID == nil ) then
		LogInfo( "NormalBossListUI: p.LoadUIWithBattleID() nCampaignID is nil " );
		return;
	end
	p.LoadUI( nCampaignID, p.nPromptType);
	
	local tBattleIDList, nCount = AffixBossFunc.findBossList( p.nCampaignID, tBattleInfo.elite );
	local nListItemLimit	= table.getn( tListItemBtnID );
	local view_page_amount	= ( nCount + ( nListItemLimit - 1 ) ) / nListItemLimit;
	local nPositionPageNum	= 1;
	for i = 1, nCount do
		if ( tBattleIDList[i].typeid == tBattleInfo.typeid ) then
			nPositionPageNum = ( i + ( nListItemLimit - 1 ) ) / nListItemLimit;
			break;
		end
	end
	if ( tBattleInfo.elite == 0 ) then
		p.ShowNormalPageNum( nPositionPageNum );
		p.ShowNormalArrow( nPositionPageNum, view_page_amount );
		local pListContainer = GetScrollViewContainer( p.pLayerNormal, ID_LIST_CONTAINER );
		pListContainer:ShowViewByIndex( nPositionPageNum-1 );
	else
		p.ShowElitePageNum( nPositionPageNum );
		p.ShowEliteArrow( nPositionPageNum, view_page_amount );
		p.pLayerElite:SetVisible( true );
		local pListContainer = GetScrollViewContainer( p.pLayerElite, ID_LIST_CONTAINER );
		pListContainer:ShowViewByIndex( nPositionPageNum-1 );
	end
end

---------------------------------------------------
--在指定副本按钮上显示提示指定提示
-- 参数： pBtnBattle:副本ID, nPromptType:提示类型
function p.ShowPrompt( pBtnBattle, nPromptType )
	if ( nPromptType == PromptType.TASK ) then
		-- 当前任务副本
		local pImage	= createNDUIImage();
		pImage:Init();
		local pool		= DefaultPicPool();
		local pPic		= pool:AddPicture( GetSMImg00Path( "Current_Task_Copy.png" ), false );
		local tSize		= pPic:GetSize();
		pImage:SetPicture( pPic, true );
		pImage:SetFrameRect( CGRectMake( 0, -tSize.h*CoordScaleY_960/2, tSize.w*CoordScaleY_960, tSize.h*CoordScaleY_960 ) );
		pBtnBattle:AddChild( pImage );
	elseif ( nPromptType == PromptType.DROP ) then
		-- 材料掉落副本
		local pImage	= createNDUIImage();
		pImage:Init();
		local pool		= DefaultPicPool();
		local pPic		= pool:AddPicture( GetSMImg00Path( "Material_Drop_Copy.png" ), false );
		local tSize		= pPic:GetSize();
		pImage:SetPicture( pPic, true );
		pImage:SetFrameRect( CGRectMake( 0, -tSize.h*CoordScaleY_960/2, tSize.w*CoordScaleY_960, tSize.h*CoordScaleY_960 ) );
		pBtnBattle:AddChild( pImage );
	end
end