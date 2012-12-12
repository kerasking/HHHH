---------------------------------------------------
--描述: 伙伴招募(客栈)界面
--时间: 2012.5.30
--作者: GUOSEN
---------------------------------------------------
-- 进入客栈界面接口：		RoleInvite.LoadUI()

---------------------------------------------------
-- 无界面招募武将接口：		RoleInvite.Invite( nPetType )
-- 参数：武将类型ID

---------------------------------------------------
local _G = _G;

RoleInvite	= {}
local p		= RoleInvite;

-- UI层
p.pUILayer				= nil;
-- 第几页图片 控件
p.pPicCtrlPageNum		= nil;
-- 左右箭头图片控件
p.pPicCtrlLeftArrow		= nil;
p.pPicCtrlRightArrow	= nil;

-- 当前显示的武将阵营/当前是哪个按钮按下
p.nCurrentCamp			= 0;

local tListElementIndex = {
	LEI_PETID		= 1;	-- 
	LEI_PETTYPE		= 2;	-- 
	LEI_PETPOS		= 3;	-- 0在队，1离队，2在野
	LEI_ISGRAY		= 4;	-- bool 变灰--此时无法招募--等级不足
};
-- 可被招募武将列表/没在队伍中的武将/当前显示的{nPetID,nPetType,nPos,bIsGray}
p.tPetEnInvList = {}; 

-- 选中的武将索引
p.nChoosenPetIndex		= 0;

-- 队伍武将人数上限
p.pet_limit				= 0;
-- 队伍武将数量
p.pet_num				= 0;
-- 玩家的军衔
p.nPlayerRank			= 0;
--
p.nPlayerID				= 0;

---------------------------------------------------
-- 阵营
local CAMP_NONE			= 0;	-- 群雄
local CAMP_WEI			= 1;	-- 魏
local CAMP_SHU			= 2;	-- 蜀
local CAMP_WU			= 3;	-- 吴

---------------------------------------------------
-- 切换阵营的按钮的ID
local ID_BTN_CAMP_NONE				= 52;	-- 群雄
local ID_BTN_CAMP_WEI				= 53;	-- 魏
local ID_BTN_CAMP_SHU				= 54;	-- 蜀
local ID_BTN_CAMP_WU				= 55;	-- 吴
local ID_BTN_CLOSE					= 38;	-- x
local ID_LABEL_RANK_NAME			= 62;	-- 玩家军衔称号标签控件ID
local ID_LABEL_TEAM_MEMBER			= 63;	-- 队伍成员人数及上限控件的ID
local ID_CTRL_CONTAINER				= 65;	-- 伙伴列表的容器ID
local ID_LABEL_LEVEL_30				= 17;	-- 30级开启武将招募功能提示标签

-- 左箭头和右箭头图形ID
local ID_PIC_LEFT_ARROW				= 11;
local ID_PIC_RIGHT_ARROW			= 12;

-- 当前页数个位数图形控件ID
local ID_PIC_PAGE_NUMBER			= 10;

-- 武将信息窗口的TAG值--放在InviteLayer层里
local TAG_PET_INFO_LAYER			= 100;

---------------------------------------------------
--每屏(每个列表项包含)显示的武将最大个数
local PET_MAXNUM_PER_LISTITEM		= 10;

--列表里武将选择按钮控件ID
local ID_BTN_CHOOSE_PET_1			= 1;
local ID_BTN_CHOOSE_PET_2			= 2;
local ID_BTN_CHOOSE_PET_3			= 3;
local ID_BTN_CHOOSE_PET_4			= 4;
local ID_BTN_CHOOSE_PET_5			= 5;
local ID_BTN_CHOOSE_PET_6			= 6;
local ID_BTN_CHOOSE_PET_7			= 7;
local ID_BTN_CHOOSE_PET_8			= 8;
local ID_BTN_CHOOSE_PET_9			= 9;
local ID_BTN_CHOOSE_PET_A			= 10;

--列表里武将名标签控件ID
local ID_LABEL_PET_NAME_1			= 11;
local ID_LABEL_PET_NAME_2			= 12;
local ID_LABEL_PET_NAME_3			= 13;
local ID_LABEL_PET_NAME_4			= 14;
local ID_LABEL_PET_NAME_5			= 15;
local ID_LABEL_PET_NAME_6			= 16;
local ID_LABEL_PET_NAME_7			= 17;
local ID_LABEL_PET_NAME_8			= 18;
local ID_LABEL_PET_NAME_9			= 19;
local ID_LABEL_PET_NAME_A			= 20;

--武将列表项里的控件ID表[10],{ 选择按钮，武将名 }
p.tPetListCtrlID = {
	{ ID_BTN_CHOOSE_PET_1, ID_LABEL_PET_NAME_1 },
	{ ID_BTN_CHOOSE_PET_2, ID_LABEL_PET_NAME_2 },
	{ ID_BTN_CHOOSE_PET_3, ID_LABEL_PET_NAME_3 },
	{ ID_BTN_CHOOSE_PET_4, ID_LABEL_PET_NAME_4 },
	{ ID_BTN_CHOOSE_PET_5, ID_LABEL_PET_NAME_5 },
	{ ID_BTN_CHOOSE_PET_6, ID_LABEL_PET_NAME_6 },
	{ ID_BTN_CHOOSE_PET_7, ID_LABEL_PET_NAME_7 },
	{ ID_BTN_CHOOSE_PET_8, ID_LABEL_PET_NAME_8 },
	{ ID_BTN_CHOOSE_PET_9, ID_LABEL_PET_NAME_9 },
	{ ID_BTN_CHOOSE_PET_A, ID_LABEL_PET_NAME_A },
};


---------------------------------------------------
-- 选中武将的弹出窗口
local ID_TIPS_BTN_CLOSE						= 29;	-- "关闭"按钮
local ID_TIPS_BTN_INVITE					= 67;	-- "招募"按钮
local ID_TIPS_BTN_REJOIN					= 30;	-- "归队"按钮
local ID_TIPS_BTN_GOLD_INVITE				= 40;	-- "金币招募"按钮

local ID_TIPS_PIC_PET_HEAD					= 39;	-- 武将头像
local ID_TIPS_LABEL_PET_NAME				= 43;	-- 武将名字(+阵营)
local ID_TIPS_LABEL_PET_LEVEL				= 44;	-- 武将等级
local ID_TIPS_LABEL_PET_JOB					= 46;	-- 武将职业
local ID_TIPS_LABEL_PET_STR					= 55;	-- 武将力量
local ID_TIPS_LABEL_PET_AGI					= 48;	-- 武将敏捷
local ID_TIPS_LABEL_PET_INT					= 57;	-- 武将智力
local ID_TIPS_LABEL_PET_HP					= 54;	-- 武将生命
local ID_TIPS_LABEL_PET_STR_I				= 24;	-- 武将成长加成力量
local ID_TIPS_LABEL_PET_AGI_I				= 25;	-- 武将成长加成敏捷
local ID_TIPS_LABEL_PET_INT_I				= 26;	-- 武将成长加成智力
local ID_TIPS_LABEL_PET_HP_I				= 27;	-- 武将成长加成生命
local ID_TIPS_LABEL_PET_SKILL				= 56;	-- 武将绝招
local ID_TIPS_LABEL_PET_RANK				= 60;	-- 该武将招募需求军衔
local ID_TIPS_LABEL_PET_SILVER 				= 59;	-- 该武将招募需求银币
local ID_TIPS_LABEL_PET_GOLD				= 31;	-- 该武将招募需求金币
local ID_TIPS_LABEL_SKILL_DESC				= 75;	-- 绝招介绍

---------------------------------------------------
function p.LoadUI()
	local scene=GetSMGameScene();
	if scene == nil then
		LogInfo( "RoleInvite: load RoleInvite failed! scene is nil" );
		return;
	end

	local layer = createNDUILayer();
	if layer == nil then
		LogInfo( "RoleInvite: load RoleInvite failed! layer is nil" );
		return  false;
	end
	layer:Init();
	layer:SetTag( NMAINSCENECHILDTAG.RoleInvite );
	layer:SetFrameRect( RectFullScreenUILayer );
	layer:SetBackgroundColor(ccc4(125,125,125,125));
	--scene:AddChild(layer);
	scene:AddChildZ( layer, 1 );--消息不穿透

	local uiLoad=createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		LogInfo( "RoleInvite: load RoleInvite failed! uiLoad is nil" );
		return false;
	end
	uiLoad:Load( "RoleInviteUI_Main.ini", layer, p.OnUIEvent, 0, 0 );
	uiLoad:Free();
	p.pUILayer = layer;
	p.pPicCtrlPageNum = GetImage( p.pUILayer, ID_PIC_PAGE_NUMBER );
	p.pPicCtrlLeftArrow = GetImage( p.pUILayer, ID_PIC_LEFT_ARROW );
	p.pPicCtrlRightArrow = GetImage( p.pUILayer, ID_PIC_RIGHT_ARROW );

	-- 获得滚屏容器
	local containter = GetScrollViewContainer( layer, ID_CTRL_CONTAINER );
	if ( nil == containter ) then
		layer:Free();
		LogInfo( "RoleInvite: load RoleInvite failed! containter is nil" );
		return false;
	end
	--
	local pLabel = GetLabel( layer, ID_LABEL_LEVEL_30 );
	if ( pLabel ~= nil ) then
		local nPlayerPetID	= RolePetFunc.GetMainPetId( GetPlayerId() );
		local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
		if ( nPlayerLevel < 30 ) then
			pLabel:SetVisible( true );
		else
			pLabel:SetVisible( false );
		end
	end
	
	containter:SetStyle(UIScrollStyle.Horzontal);
	containter:SetViewSize( containter:GetFrameRect().size );--	containter:SetViewSize( CGSizeMake( containter:GetFrameRect().size.w, containter:GetFrameRect().size.h ) );
	containter:SetLuaDelegate( p.OnUIEventViewChange );--设置滚屏容器事件回调

	p.nCurrentCamp = CAMP_NONE;
	p.NewRefreshContainer( p.nCurrentCamp );
	p.DisableButton( p.nCurrentCamp )
	p.nChoosenPetIndex = 0;
	return true;
end

---------------------------------------------------
-- 响应滚屏容器事件，
function p.OnUIEventViewChange( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	--LogInfo( "RoleInvite: OnUIEventViewChange[%d]", param );

	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		-- 某视图跑到容器起始处,param 为索引
		local containter	= ConverToSVC(uiNode);
		--
		p.ShowPageNum( param + 1 );
		p.ShowArrow(  param + 1, containter:GetViewCount() );
		--
	end

	return true;
end

-- 显示第几页(0~9)
function p.ShowPageNum( nPageNum )
	local pool = DefaultPicPool();
	if not CheckP(pool) then
		return;
	end

	-- 数字图像一个数字的宽高
	local N_W = 42;
	local N_H = 34;
	local norpic = pool:AddPicture( GetSMImgPath( "number/num_1.png" ), false);
	-- 数字图需要改
	local tRect = CGRectMake( N_W*nPageNum, 0, N_W, N_H );
	norpic:Cut( tRect );
	p.pPicCtrlPageNum:SetPicture(norpic);
end

--显示箭头，nCurPageNum为0时全黑
function p.ShowArrow( nCurPageNum, nMaxPageNum )
    
    --** chh 2012-08-02 **--
	--[[
    --
	if ( 0 == nCurPageNum ) then
		p.pPicCtrlLeftArrow:GetPicture():SetGrayState( true );
		p.pPicCtrlRightArrow:GetPicture():SetGrayState( true );
	else
		if ( 1 == nCurPageNum ) then
			p.pPicCtrlLeftArrow:GetPicture():SetGrayState( true );
		else
			p.pPicCtrlLeftArrow:GetPicture():SetGrayState( false );
		end
		if ( nMaxPageNum <= nCurPageNum ) then
			p.pPicCtrlRightArrow:GetPicture():SetGrayState( true );
		else
			p.pPicCtrlRightArrow:GetPicture():SetGrayState( false );
		end
	end
    ]]
    local containter = GetScrollViewContainer( p.pUILayer, ID_CTRL_CONTAINER );
    SetArrow(p.pUILayer,containter,1,ID_PIC_LEFT_ARROW,ID_PIC_RIGHT_ARROW);
    
end

---------------------------------------------------
-- 客栈UI的按钮事件响应
function p.OnUIEvent(uiNode,uiEventType,param)
	local tag = uiNode:GetTag();
	--LogInfo("RoleInvite: p.OnUIEvent[%d]",tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ( ID_BTN_CLOSE == tag ) then
			local scene = GetSMGameScene();
			if scene~= nil then
				scene:RemoveChildByTag( NMAINSCENECHILDTAG.RoleInvite, true );
				return true;
			end
		elseif ( ID_BTN_CAMP_NONE == tag ) then
			if ( p.nCurrentCamp ~= CAMP_NONE ) then
				p.EnableButton( p.nCurrentCamp );
				p.nCurrentCamp = CAMP_NONE;
				p.NewRefreshContainer( p.nCurrentCamp );
				p.DisableButton( CAMP_NONE );
			end
		elseif ( ID_BTN_CAMP_WEI == tag ) then
			if ( p.nCurrentCamp ~= CAMP_WEI ) then
				p.EnableButton( p.nCurrentCamp );
				p.nCurrentCamp = CAMP_WEI;
				p.NewRefreshContainer( p.nCurrentCamp );
				p.DisableButton( CAMP_WEI );
			end
		elseif ( ID_BTN_CAMP_SHU == tag ) then
			if ( p.nCurrentCamp ~= CAMP_SHU ) then
				p.EnableButton( p.nCurrentCamp );
				p.nCurrentCamp = CAMP_SHU;
				p.NewRefreshContainer( p.nCurrentCamp );
				p.DisableButton( CAMP_SHU );
			end
		elseif ( ID_BTN_CAMP_WU == tag ) then
			if ( p.nCurrentCamp ~= CAMP_WU ) then
				p.EnableButton( p.nCurrentCamp );
				p.nCurrentCamp = CAMP_WU;
				p.NewRefreshContainer( p.nCurrentCamp );
				p.DisableButton( CAMP_WU );
			end
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end

-- 按钮失效--选择效果
function p.DisableButton( nCamp )
	local pInvUILayer = p.GetInvUILayer();
    
	if ( CAMP_NONE == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_NONE );
		--pBtn:EnalbeGray( true );
        pBtn:TabSel(true);

	elseif ( CAMP_WEI == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_WEI );
		--pBtn:EnalbeGray( true );
        pBtn:TabSel(true);
        
	elseif ( CAMP_SHU == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_SHU );
		--pBtn:EnalbeGray( true );
        pBtn:TabSel(true);
        
	elseif ( CAMP_WU == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_WU );
		--pBtn:EnalbeGray( true );
        pBtn:TabSel(true);
        
	end
end

-- 按钮恢复正常--恢复正常颜色
function p.EnableButton( nCamp )
	local pInvUILayer = p.GetInvUILayer();
	if ( CAMP_NONE == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_NONE );
		--pBtn:EnalbeGray( false );
        pBtn:TabSel(false);
	elseif ( CAMP_WEI == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_WEI );
		--pBtn:EnalbeGray( false );
        pBtn:TabSel(false);
	elseif ( CAMP_SHU == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_SHU );
		--pBtn:EnalbeGray( false );
        pBtn:TabSel(false);
	elseif ( CAMP_WU == nCamp ) then
		local pBtn	= GetButton( pInvUILayer, ID_BTN_CAMP_WU );
		--pBtn:EnalbeGray( false );
        pBtn:TabSel(false);
	end
end

---------------------------------------------------
-- 获得客栈的UI层
function p.GetInvUILayer()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end

	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.RoleInvite);
	if nil == layer then
		return nil;
	end

	return layer;
end


---------------------------------------------------
-- 显示指定阵营的可招募武将
function p.NewRefreshContainer( nCamp )
	--LogInfo( "RoleInvite: NewRefreshContainer()" );
	-- 获得UI
	local pInvUILayer = p.GetInvUILayer();
	if nil == pInvUILayer then
		LogInfo( "RoleInvite: NewRefreshContainer failed! pInvUILayer is nil" );
		return false;
	end

	-- 获得滚屏容器
	local pScrollViewContainer = GetScrollViewContainer( pInvUILayer,ID_CTRL_CONTAINER );
	if nil == pScrollViewContainer then
		LogInfo( "RoleInvite: NewRefreshContainer failed! pScrollViewContainer is nil" );
		return false;
	end
	pScrollViewContainer:ShowViewByIndex(0);
	pScrollViewContainer:RemoveAllView();
	--pScrollViewContainer:SetLeftReserveDistance( 20 );
	--pScrollViewContainer:SetRightReserveDistance( 20 );

	-- 获得玩家ID
	p.nPlayerID = GetPlayerId();--User表中的ID
	--LogInfo( "RoleInvite: nPlayerId:%d" ,p.nPlayerID  );
	if nil == p.nPlayerID then
		LogInfo( "RoleInvite: NewRefreshContainer failed! nPlayerId is nil" );
		return false;
	end

	-- 获得玩家的军衔
	p.nPlayerRank	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_RANK );
	local szPlayerRank	= "浪迹天涯";
	if ( 0 < p.nPlayerRank ) then
		szPlayerRank	= GetDataBaseDataS( "rank_config", p.nPlayerRank, DB_RANK_CONFIG.RANK_NAME );
	end
	SetLabel( pInvUILayer, ID_LABEL_RANK_NAME, szPlayerRank );
	
	-- 获得玩家的等级
	--local nPlayerLevel	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_LEVEL );	-- user 表无更新
	local nPlayerPetID	= RolePetFunc.GetMainPetId( p.nPlayerID );
	local nPlayerLevel	= RolePet.GetPetInfoN( nPlayerPetID, PET_ATTR.PET_ATTR_LEVEL );
	
	-- 获得玩家的阶段
	local nPlayerStage	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_STAGE );


	--获取当前已招募的列表
	local invited_idTable	= RolePetUser.GetPetList( p.nPlayerID );
	local inTeam_idTable	= RolePetUser.GetPetListPlayer( p.nPlayerID );
	p.pet_num				= 1;
	if nil ~= invited_idTable then
		p.pet_num = table.getn(inTeam_idTable);
	end

	--显示招募上限
	p.pet_limit = GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_PET_LIMIT );
	--队伍人数包括主角
	SetLabel( pInvUILayer, ID_LABEL_TEAM_MEMBER, " "..SafeN2S(p.pet_num).."/"..SafeN2S(p.pet_limit) );

	if ( nPlayerLevel < 30 ) then--小于30级别不刷新-----------
		return false;
	end
	
	--获得所有武将列表
	local idList = GetDataBaseIdList( "pet_config" );
	if nil == idList then
		LogInfo( "RoleInvite: NewRefreshContainer failed! idList is nil" );
		return false;
	end

	-- 可被招募武将列表
	p.tPetEnInvList = {};
	for i, v in ipairs(idList) do
		local bBreakRepeat		= false;
		repeat
			local nPetType		= v;--
			
			-- 能否被招募，可被招募才显示
			local value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.CAN_CALL );
			if ( 0 == value ) then
				break;
			end
			
			-- 阵营
			local camp = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.CAMP );
			if ( camp ~= nCamp ) then
				break
			end
        	
			-- 军衔
			--value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REPUTE_LEV );
			
			--判断玩家当前的游戏进度是否可以开启这个伙伴
			local need_stage = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.NEED_STAGE );
			--LogInfo( "RoleInvite: PlayerStage:%d, PetNeedStage:%d", nPlayerStage, need_stage );
			if ( nPlayerStage < need_stage ) then
				break;
			end
			
			local bIsGray = false;--变灰（等级不足武将头像变灰）
			--判断玩家当前的等级是否可以开启这个伙伴
			local need_level = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REQ_LEVEL );
			--LogInfo( "RoleInvite: PlayerLevel:%d, PetNeedLevel:%d", nPlayerLevel, need_level );
			if ( nPlayerLevel < need_level ) then
				bIsGray = true;--break;
			end
        	
			-- 判断已招募和招募过的伙伴
			local petPosition	= 2;		--0队伍中;1已离队;2未入队;
			local nPetID		= 0;
        	
			if ( nil ~= invited_idTable ) then
				for nIndex, nInvitedPetID  in ipairs( invited_idTable ) do
					local tmpPetType = RolePet.GetPetInfoN( nInvitedPetID, PET_ATTR.PET_ATTR_TYPE );
					--LogInfo( "RoleInvite: nInvitedPetID=%d,type=%d", nInvitedPetID, petType );
					if ( nPetType == tmpPetType ) then
						petPosition = RolePet.GetPetInfoN( nInvitedPetID, PET_ATTR.PET_ATTR_POSITION );	-- 0/1
						nPetID = nInvitedPetID;
						break;
					end
				end
			end
        	
			-- 已招募的伙伴不显示
			if petPosition == 0 then
				break;
			end
			
			-- 银币需求为0且未曾招募过的不显示（离队的可显示）
			local nPetSilver	= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.MONEY );
			if ( 0 == nPetSilver and petPosition == 2 ) then
				break;
			end
			
			table.insert( p.tPetEnInvList, { nPetID, nPetType, petPosition, bIsGray } );
		until true
		if ( bBreakRepeat ) then
			break;
		end
	end

	-- 得到显示的页数
	local nPetAmount		= table.getn( p.tPetEnInvList );
	--LogInfo( "RoleInvite: NewRefreshContainer() nPetAmount:%d",nPetAmount );
	local view_page_amount	= ( nPetAmount + ( PET_MAXNUM_PER_LISTITEM - 1 ) ) / PET_MAXNUM_PER_LISTITEM;
	--LogInfo( "RoleInvite: amount:%d, page:%d", nPetAmount, view_page_amount );

	--
	for i = 1, view_page_amount do
		local viewListItem = createUIScrollView();

		if not CheckP( viewListItem ) then
			LogInfo( "RoleInvite: NewRefreshContainer failed! viewListItem is nil" );
			return false;
		end

		viewListItem:Init( false );
		--viewListItem:SetScrollStyle(UIScrollStyle.Horzontal);
		viewListItem:SetViewId( i );
		viewListItem:SetTag( i );
		pScrollViewContainer:AddView( viewListItem );

		--初始化ui
		local uiLoad = createNDUILoad();
		if not CheckP(uiLoad) then
			LogInfo( "RoleInvite: NewRefreshContainer failed! uiLoad is nil" );
			return false;
		end

		--local nOffsetX	= pScrollViewContainer:GetViewSize().w * ( view_page_amount - 1 );
		-- 关联列表项UI与视图与事件响应
		uiLoad:Load( "RoleInviteUI_ListItem.ini", viewListItem, p.OnListItemEvent, 0, 0 );
		uiLoad:Free();

		--LogInfo( "RroleInvite, cur_page:%d", i );
		p.FillListItem( viewListItem, (i-1)*PET_MAXNUM_PER_LISTITEM+1 );
   end

	if ( 0 < nPetAmount ) then
		p.ShowPageNum( 1 );
		p.ShowArrow( 1, view_page_amount );
		p.pPicCtrlPageNum:SetVisible(true);
		p.pPicCtrlLeftArrow:SetVisible(true);
		p.pPicCtrlRightArrow:SetVisible(true);
	else
		p.pPicCtrlPageNum:SetVisible(false);
		p.pPicCtrlLeftArrow:SetVisible(false);
		p.pPicCtrlRightArrow:SetVisible(false);
	end

	pScrollViewContainer:ShowViewByIndex(0);
end

---------------------------------------------------
-- 填充列表视图，
-- 列表项UI层, 起始索引(下标1开始)
function p.FillListItem( layerListItem, nIndex )
	local nPetAmount = table.getn( p.tPetEnInvList );
	if ( nil == layerListItem ) or ( 0 == nPetAmount )
		or ( 0 == nIndex ) or ( nIndex > nPetAmount ) then
		return;
	end

	-- 当前列表视图可见到的武将数量
	local nVisiblePetAmount = PET_MAXNUM_PER_LISTITEM;
	if ( nIndex + PET_MAXNUM_PER_LISTITEM > nPetAmount ) then
		nVisiblePetAmount = nPetAmount - nIndex + 1;
	end

	local nCount = 1;
	for i = 1, nVisiblePetAmount do
		local nPetType	= p.tPetEnInvList[nIndex+i-1][tListElementIndex.LEI_PETTYPE];
		local bIsGray	= p.tPetEnInvList[nIndex+i-1][tListElementIndex.LEI_ISGRAY];
		
		-- 头像
		local pBtnChoosePet	= GetButton( layerListItem, p.tPetListCtrlID[i][1] );
        local pPic			;--= GetPetBigPotraitTranPic(nPetType);
        if ( bIsGray ) then
        	pPic			= GetPetBigGrayPotraitTranPic(nPetType);
        else
        	pPic			= GetPetBigPotraitTranPic(nPetType);
        end
        if CheckP(pPic) then
            pBtnChoosePet:SetImage( pPic, true );
        end
        
		-- 名字
		--local value = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
		--SetLabel( layerListItem, p.tPetListCtrlID[i][2], value );
		nCount = i;
	end
	
	if ( nCount < PET_MAXNUM_PER_LISTITEM ) then
		--LogInfo( "RoleInvite: other space " );
		for i = nCount+1, PET_MAXNUM_PER_LISTITEM do
			local pBtnChoosePet		= GetButton( layerListItem, p.tPetListCtrlID[i][1] );
			pBtnChoosePet:SetVisible(false);
			--local pLabelPetName		= GetLabel( layerListItem, p.tPetListCtrlID[i][2] );
			--pLabelPetName:SetVisible(false);
		end
	end

end

---------------------------------------------------
-- 响应列表项UI的事件--点击武将
function p.OnListItemEvent( uiNode, uiEventType, param )
	local tagNode = uiNode:GetTag();
	--LogInfo( "RoleInvite: touch item:%d", uiNode:GetParent() );
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local pParentNode = uiNode:GetParent();	--获得控件所在的列表项UI，
		local tagParent = pParentNode:GetTag();	--获得该UI的tag(tag>=1)，即序列
		local nPetIndex = ( tagParent - 1 ) * PET_MAXNUM_PER_LISTITEM + tagNode;
		--LogInfo( "RoleInvite: tagParent:%d, petIndex:%d", tagParent, nPetIndex );
		if ( p.tPetEnInvList[nPetIndex][tListElementIndex.LEI_ISGRAY] ) then
			local nPetType		= p.tPetEnInvList[nPetIndex][tListElementIndex.LEI_PETTYPE];
			local need_level	= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REQ_LEVEL );
			CommonDlg.ShowWithConfirm( need_level..GetTxtPri("RI_T1"), nil );
		else
			p.nChoosenPetIndex = nPetIndex;
			p.CreatePetTipsLayer( nPetIndex );
		end
	end
	return true;
end

---------------------------------------------------
-- 创建“武将信息及招募/归队”窗口（"p.tPetEnInvList"表的索引）
function p.CreatePetTipsLayer( nPetIndex )
	--LogInfo( "RoleInvite: CreatePetTipsLayer begin" );
	local layerTips = createNDUILayer();
	if layerTips == nil then
		LogInfo( "RoleInvite: CreatePetTipsLayer failed! layerTips is nil" );
		return  false;
	end
	layerTips:Init();
	layerTips:SetFrameRect( RectFullScreenUILayer );
	layerTips:SetTag( TAG_PET_INFO_LAYER );
	layerTips:SetBackgroundColor(ccc4(0,0,0,100));

	local uiLoad = createNDUILoad();
	if uiLoad ~= nil then
		uiLoad:Load( "RoleInviteUI_PetInfo.ini", layerTips, p.OnPetInfoUIEvent, 0, 0 );
		uiLoad:Free();
	end

	--local scene = GetSMGameScene();
	local pInvUILayer = p.GetInvUILayer();
	pInvUILayer:AddChildZ( layerTips, 2 );--触摸消息不穿透

	local nPetID		= p.tPetEnInvList[nPetIndex][tListElementIndex.LEI_PETID];
	local nPetType		= p.tPetEnInvList[nPetIndex][tListElementIndex.LEI_PETTYPE];
	local nPetPos		= p.tPetEnInvList[nPetIndex][tListElementIndex.LEI_PETPOS];
	-- ( table.getn(p.tPetEnInvList) );
	--LogInfo( "RoleInvite: PetID:%d, PetType:%d, PetPos:%d", nPetID, nPetType, nPetPos );
	
	if ( 1 == nPetPos ) then
		-- 离队--PetID
		p.InitPetInfoUIWithPetID( layerTips, nPetID );
	else
		-- 在野--PetType
		p.InitPetInfoUIWithPetType( layerTips, nPetType );
	end
	
	--LogInfo( "RoleInvite: CreatePetTipsLayer succeed" );
	return true;
end

---------------------------------------------------
-- 通过PetID来初始化“武将信息及招募/归队”窗口(离队武将)
function p.InitPetInfoUIWithPetID( pLayerTips, nPetID )
	
	local nPetType = RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_TYPE );

	-- 头像
	local pPetImage	= GetButton( pLayerTips, ID_TIPS_PIC_PET_HEAD );
	local pic			= GetPetPotraitPic(nPetType);
	if CheckP(pic) then
	    pPetImage:SetImage( pic, true );
	end
    

	-- 阵营
	local nCamp = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.CAMP );
	local szCamp = "";
	if ( CAMP_NONE == nCamp ) then
		szCamp = GetTxtPri("RI_T2");
	elseif ( CAMP_WEI == nCamp ) then
		szCamp = GetTxtPri("RI_T3");
	elseif ( CAMP_SHU == nCamp ) then
		szCamp = GetTxtPri("RI_T4");
	elseif ( CAMP_WU == nCamp ) then
		szCamp = GetTxtPri("RI_T5");
	end
	-- 名称
	local value = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
	local l_name = SetLabel( pLayerTips, ID_TIPS_LABEL_PET_NAME, value .. szCamp );
    ItemPet.SetLabelColor(l_name, nPetID);

	-- 等级
	value = RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_LEVEL );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_LEVEL, SafeN2S(value)..GetTxtPub("Level") );
	
	-- 站位类型
	local nStandType = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.STAND_TYPE );
	local szStandType = "(+)";
	if ( 1 == nStandType ) then
		szStandType = GetTxtPri("RI_T6");
	elseif ( 2 == nStandType ) then
		szStandType = GetTxtPri("RI_T7");
	elseif ( 3 == nStandType ) then
		szStandType = GetTxtPri("RI_T8");
	end
	-- 职业
	value = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.PRO_NAME );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_JOB, value .. szStandType );

	-- 力量
	value = RolePet.GetTotalPhy( nPetID );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_STR, SafeN2S(value) );
	
	-- 敏捷
	value = RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_DEX );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_AGI, SafeN2S(value) );
	
	-- 智力
	value = RolePet.GetTotalMagic( nPetID );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_INT, SafeN2S(value) );
	
	-- 生命
	value = RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_LIFE_LIMIT );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_HP, value );

	-- 力量加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_PHYSICAL );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_STR_I, SafeN2S(value/1000) );

	-- 敏捷加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_SUPER_SKILL );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_AGI_I, SafeN2S(value/1000) );

	-- 智力加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_MAGIC );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_INT_I, SafeN2S(value/1000) );

	-- 生命加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_LIFE );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_HP_I, SafeN2S(value/1000) );
	
	-- 绝招
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.SKILL );
	local szSkillName = GetDataBaseDataS( "skill_config", value, DB_SKILL_CONFIG.NAME );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_SKILL, szSkillName );
	
	-- 绝招描述
	local szSkillDesc = GetDataBaseDataS( "skill_config", value, DB_SKILL_CONFIG.DESCRRIPTION );
	SetLabel( pLayerTips, ID_TIPS_LABEL_SKILL_DESC, szSkillDesc );
	
	
	local pLabel = GetLabel( pLayerTips, ID_TIPS_LABEL_PET_RANK );
	pLabel:SetText( "无" );
	pLabel = GetLabel( pLayerTips, ID_TIPS_LABEL_PET_SILVER )
	pLabel:SetText( "无" );
	pLabel = GetLabel( pLayerTips, ID_TIPS_LABEL_PET_GOLD );
	pLabel:SetVisible(false);
	
	--隐藏"招募"按钮
	local pBtnInvite	= GetButton( pLayerTips, ID_TIPS_BTN_INVITE );
	if CheckP( pBtnInvite ) then
		pBtnInvite:SetVisible(false);
	end
	--隐藏"金币招募"按钮
	local pBtnGoldInvite = GetButton( pLayerTips, ID_TIPS_BTN_GOLD_INVITE );
	if CheckP( pBtnGoldInvite ) then
		pBtnGoldInvite:SetVisible(false);
	end
	
end

---------------------------------------------------
-- 通过PetType来初始化“武将信息及招募/归队”窗口(在野武将)
function p.InitPetInfoUIWithPetType( pLayerTips, nPetType )
	
	-- 头像
	local pPetImage	= GetButton( pLayerTips, ID_TIPS_PIC_PET_HEAD );
	local pic			= GetPetPotraitPic(nPetType);
	if CheckP(pic) then
	    pPetImage:SetImage( pic, true );
	end
    
    

	-- 阵营
	local nCamp = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.CAMP );
	local szCamp = "";
	if ( CAMP_NONE == nCamp ) then
		szCamp = GetTxtPri("RI_T2");
	elseif ( CAMP_WEI == nCamp ) then
		szCamp = GetTxtPri("RI_T3");
	elseif ( CAMP_SHU == nCamp ) then
		szCamp = GetTxtPri("RI_T4");
	elseif ( CAMP_WU == nCamp ) then
		szCamp = GetTxtPri("RI_T5");
	end
	-- 名称
	local value = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
	local l_name = SetLabel( pLayerTips, ID_TIPS_LABEL_PET_NAME, value .. szCamp );
    local cColor = ItemPet.GetPetConfigQuality(nPetType);
    l_name:SetFontColor(cColor);

	-- 等级
	value = 1;
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_LEVEL, value ..GetTxtPub("Level") );
	
	-- 站位类型
	local nStandType = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.STAND_TYPE );
	local szStandType = "(+)";
	if ( 1 == nStandType ) then
		szStandType = GetTxtPri("RI_T6");
	elseif ( 2 == nStandType ) then
		szStandType = GetTxtPri("RI_T7");
	elseif ( 3 == nStandType ) then
		szStandType = GetTxtPri("RI_T8");
	end
	-- 职业
	value = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.PRO_NAME );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_JOB, value .. szStandType );

	--力量
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_PHYSICAL );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_STR, SafeN2S(value) );
	
	--敏捷
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_SUPER_SKILL );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_AGI, SafeN2S(value) );
	
	--智力
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_MAGIC );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_INT, SafeN2S(value) );
	
	--生命
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.INIT_LIFE );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_HP, SafeN2S(value) );

	--力量加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_PHYSICAL );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_STR_I, SafeN2S(value/1000) );

	--敏捷加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_SUPER_SKILL );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_AGI_I, SafeN2S(value/1000) );

	--智力加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_MAGIC );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_INT_I, SafeN2S(value/1000) );

	--生命加成
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.ADD_LIFE );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_HP_I, SafeN2S(value/1000) );
	
	--绝招
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.SKILL );
	local szSkillName = GetDataBaseDataS( "skill_config", value, DB_SKILL_CONFIG.NAME );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_SKILL, szSkillName );
	
	-- 绝招描述
	local szSkillDesc = GetDataBaseDataS( "skill_config", value, DB_SKILL_CONFIG.DESCRRIPTION );
	SetLabel( pLayerTips, ID_TIPS_LABEL_SKILL_DESC, szSkillDesc );
	
	--需要军衔
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REPUTE_LEV );
	local szPlayerRank	= GetDataBaseDataS( "rank_config", value, DB_RANK_CONFIG.RANK_NAME );
	if ( "" == szPlayerRank ) then
		szPlayerRank = GetTxtPri("RI_T9");
	end
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_RANK, szPlayerRank);
	
	--需要银币
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.MONEY );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_SILVER, SafeN2S(value).."银币" );
	
	-- VIP Level
	local nVipLv = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REQ_VIP );
	--需要金币
	value = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.EMONEY );
	SetLabel( pLayerTips, ID_TIPS_LABEL_PET_GOLD, "(VIP"..nVipLv..":"..SafeN2S(value).."金币)" );
	-- 不显示需要金币……
	local pLabel = GetLabel( pLayerTips, ID_TIPS_LABEL_PET_GOLD );
	pLabel:SetVisible(false);
	
	-- 隐藏"归队"按钮
	local pBtnRejoin	= GetButton( pLayerTips, ID_TIPS_BTN_REJOIN );
	if CheckP( pBtnRejoin ) then
		pBtnRejoin:SetVisible(false);
	end
	local nPlayerVIPLv	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_VIP_RANK );
	local nPetVIPLv		= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REQ_VIP );
	if ( nPlayerVIPLv < nPetVIPLv ) then
		--隐藏"金币招募"按钮
		local pBtnGoldInvite = GetButton( pLayerTips, ID_TIPS_BTN_GOLD_INVITE );
		if CheckP( pBtnGoldInvite ) then
			pBtnGoldInvite:SetVisible(false);
		end
	end
end

---------------------------------------------------
-- “武将信息及招募/归队”窗口事件响应
function p.OnPetInfoUIEvent( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	--LogInfo( "RoleInvite: p.OnPetInfoUIEvent[%d]",tag );
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_TIPS_BTN_CLOSE == tag then
			uiNode:GetParent():GetParent():RemoveChild( uiNode:GetParent(), true );
			return true;
		elseif ID_TIPS_BTN_INVITE == tag then
			-- 招募
			local nPetType	= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETTYPE];
			local nPetPos	= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETPOS];
			if ( p.pet_num >= p.pet_limit ) then
				-- 队伍满员
				CommonDlg.ShowWithConfirm(GetTxtPri("RI_T10"), nil );
			else
				if ( p.nPlayerRank < GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REPUTE_LEV ) ) then
					-- 军衔低
					CommonDlg.ShowWithConfirm( GetTxtPri("RI_T11"), nil );
				else
					local nPlayerSilver	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_MONEY );
					local nPetSilver	= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.MONEY );
					--LogInfo( "RoleInvite: PlayerSilver:%d, PetSilver%d", nPlayerSilver, nPetSilver  );
					if ( nPlayerSilver >= nPetSilver ) then
						-- 银币足
						CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("RI_T12"),nPetSilver), p.InviteCallSilver);
					else
						-- 银币缺
						local nPlayerVIPLv	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_VIP_RANK );
						local nPetVIPLv		= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REQ_VIP );
						--LogInfo( "RoleInvite: PetType:%d, PlayerVIP:%d, PetVIP%d", nPetType, nPlayerVIPLv, nPetVIPLv  );
						if ( nPlayerVIPLv < nPetVIPLv ) then
							CommonDlg.ShowWithConfirm( GetTxtPri("RI_T13"), nil );
						else
							local nPetGold = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.EMONEY );
							local szName = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
							local nGold = ( nPetSilver - nPlayerSilver ) * nPetGold / nPetSilver;
							nGold = math.ceil( nGold );
							CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("RI_T14"),nGold,szName), p.InviteCallBackGold );
						end
					end
				end
			end
		elseif ID_TIPS_BTN_REJOIN == tag then
			-- 归队
			local nPetID	= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETID];
			local nPetPos	= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETPOS];
			if ( p.pet_num < p.pet_limit ) then
				-- 发送归队消息给服务端
				_G.MsgRolePet.SendBuyBackPet( nPetID );
			else
				CommonDlg.ShowWithConfirm( GetTxtPri("RI_T10"), nil );
			end 
		elseif ID_TIPS_BTN_GOLD_INVITE == tag then
			-- 金币招募
			local nPetType	= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETTYPE];
			local nPetPos	= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETPOS];
			if ( p.pet_num >= p.pet_limit ) then
				-- 队伍满员
				CommonDlg.ShowWithConfirm( GetTxtPri("RI_T10"), nil );
			else
				if ( p.nPlayerRank < GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REPUTE_LEV ) ) then
					-- 军衔低
					CommonDlg.ShowWithConfirm( GetTxtPri("RI_T11"), nil );
				else
					local nPlayerVIPLv	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_VIP_RANK );
					local nPetVIPLv		= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.REQ_VIP );
					if ( nPlayerVIPLv < nPetVIPLv ) then
						CommonDlg.ShowWithConfirm( GetTxtPri("RI_T19"), nil );
					else
						local nPetGold = GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.EMONEY );
						local szName = GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
						CommonDlgNew.ShowYesOrNoDlg( string.format(GetTxtPri("RI_T20"),nPetGold), p.InviteCallBackOnlyGold );
					end
				end
			end
		end
	end
	return true;
end

---------------------------------------------------
-- 响应服务器消息刷新
function p.RefreshContainer( btAction, nPetID )
    LogInfo("RoleInvite: RefreshContainer");
	-- 关闭武将信息窗口
	local pInvUILayer	= p.GetInvUILayer();
	if ( nil == pInvUILayer ) then
    	LogInfo("RoleInvite: RefreshContainer() faild pInvUILayer is nil");
		return;
	end
	local pTipsLayer	= GetUiLayer( pInvUILayer, TAG_PET_INFO_LAYER )
	if ( nil == pTipsLayer ) then
    	LogInfo("RoleInvite: RefreshContainer() faild pTipsLayer is nil");
		return;
	end
    pTipsLayer:RemoveFromParent(true);
    
	local nPetType	= RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_TYPE );
	local szName 	= GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
    
	if ( 2 == btAction ) then
		-- 归队
		CommonDlg.ShowWithConfirm( szName..GetTxtPri("RI_T16"), 3 );
	elseif ( 1 == btAction ) then
		-- 招募
		CommonDlg.ShowWithConfirm( szName..GetTxtPri("RI_T17"), 3 );
		-- 播放招募成功光效
		PlayEffectAnimation.ShowAnimation(6);
	end
	p.nChoosenPetIndex	= 0;
	p.NewRefreshContainer( p.nCurrentCamp );	-- 该函数会改变 p.tPetEnInvList，所以放在后面

    CloseLoadBar();
end

---------------------------------------------------
-- 对话框回调事件-确定消耗银币招募
function p.InviteCallSilver(nEvent, param )
	--LogInfo( "RoleInvite: p.InviteCallSilver: nId:%d,nEvent:%d",nId,nEvent );
	if ( CommonDlgNew.BtnOk == nEvent ) then
		--CommonDlg.ShowWithConfirm( "扣银币……", nil );
		-- 发送招募消息给服务端
		local nPetType	= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETTYPE];
		_G.MsgRolePet.SendBuyPet( nPetType );
	end
end

-- 对话框回调事件-确定银币不足消耗金币招募
function p.InviteCallBackGold(nEvent, param )
	--LogInfo( "RoleInvite: p.InviteCallSilver: nId:%d,nEvent:%d",nId,nEvent );
	if ( CommonDlgNew.BtnOk == nEvent ) then
		local nPetType		= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETTYPE];
		local nPlayerSilver	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_MONEY );
		local nPetSilver	= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.MONEY );
		local nPetGold		= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.EMONEY );
		local nGold			= ( nPetSilver - nPlayerSilver ) * nPetGold / nPetSilver;
		local nPlayerGold	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_EMONEY );
		nGold = math.ceil( nGold );
		if ( nGold <= nPlayerGold ) then
			--CommonDlg.ShowWithConfirm( "扣金币……", nil );
			-- 发送招募消息给服务端
			_G.MsgRolePet.SendBuyPet( nPetType );
		else
			--金币不足-充值什么的
			CommonDlgNew.ShowYesOrNoDlg( GetTxtPri("RI_T18"), p.InviteCallBackRecharge );
		end
	end
end

-- 对话框回调事件-全消耗金币招募
function p.InviteCallBackOnlyGold(nEvent, param )
	--LogInfo( "RoleInvite: p.InviteCallSilver: nId:%d,nEvent:%d",nId,nEvent );
	if ( CommonDlgNew.BtnOk == nEvent ) then
		local nPetType		= p.tPetEnInvList[p.nChoosenPetIndex][tListElementIndex.LEI_PETTYPE];
		local nPetGold		= GetDataBaseDataN( "pet_config", nPetType, DB_PET_CONFIG.EMONEY );
		local nPlayerGold	= GetRoleBasicDataN( p.nPlayerID, USER_ATTR.USER_ATTR_EMONEY );
		nGold = math.ceil( nPetGold );
		if ( nPetGold <= nPlayerGold ) then
			--CommonDlg.ShowWithConfirm( "扣金币……", nil );
			-- 发送招募消息给服务端
			_G.MsgRolePet.SendBuyPetWithGold( nPetType );
		else
			--金币不足-充值什么的
			CommonDlgNew.ShowYesOrNoDlg( "您的金币不足，先去充值？", p.InviteCallBackRecharge );
		end
	end
end

-- 对话框回调事件-充值
function p.InviteCallBackRecharge(nEvent, param )
	--LogInfo( "RoleInvite: p.InviteCallSilver: nId:%d,nEvent:%d",nId,nEvent );
	if ( CommonDlgNew.BtnOk == nEvent ) then
		--CommonDlg.ShowWithConfirm( "转充值页面……", nil );
		-- 跳转充值页面
		local scene = GetSMGameScene();
		if scene~= nil then
			scene:RemoveChildByTag( NMAINSCENECHILDTAG.RoleInvite, true );
		end
		PlayerVIPUI.LoadUI();
	end
end

---------------------------------------------------
-- 没开启客栈界面招募武将申请
function p.Invite( nPetType )
	_G.MsgRolePet.SendBuyPet( nPetType );
end

---------------------------------------------------
-- 没开启客栈界面招募到武将的消息处理
--function p.InviteSucess( tNewPets )
--	local szTitle	= "";
--	local nCount = table.getn( tNewPets );
--	if ( nCount > 0 ) then
--		for i=1, nCount do
--			if ( i > 1 ) then
--				szTitle = szTitle .. "、";
--			end
--			local nPetType	= RolePet.GetPetInfoN( tNewPets[i], PET_ATTR.PET_ATTR_TYPE );
--			local szName 	= GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
--			szTitle = szTitle .. szName;
--		end
--		LogInfo( "RoleInvite: " .. szTitle );
--        --** chh 2012-08-20 **--
--		--CommonDlg.ShowWithConfirm( szTitle .. "归您麾下!", nil );
--	end
--end
function p.InviteSucess( btAction, nPetID )
	LogInfo( "RoleInvite: InviteSucess() btAction:%d, nPetId:%d", btAction, nPetID );
	if IsUIShow(NMAINSCENECHILDTAG.RoleInvite) then
		p.RefreshContainer( btAction, nPetID );
	else
		--local nPetType	= RolePet.GetPetInfoN( nPetID, PET_ATTR.PET_ATTR_TYPE );
		--local szName 	= GetDataBaseDataS( "pet_config", nPetType, DB_PET_CONFIG.NAME );
		-- 没开启招募界面的回调
		if ( 2 == btAction ) then
			-- 归队
			--CommonDlg.ShowWithConfirm( szName..GetTxtPri("RI_T16"), 3 );
		elseif ( 1 == btAction ) then
			-- 招募
			--CommonDlg.ShowWithConfirm( szName..GetTxtPri("RI_T17"), 3 );
			PlayEffectAnimation.ShowAnimation(6);
		end
	end
    CloseLoadBar();
end
