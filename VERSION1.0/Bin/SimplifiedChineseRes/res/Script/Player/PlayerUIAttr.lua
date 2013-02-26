---------------------------------------------------
--描述: 玩家属性UI
--时间: 2012.2.1
--作者: jhzheng
---------------------------------------------------

--刷新当前武将装备
--PlayerUIAttr.RefreshCurrentBack();



PlayerUIAttr = {}
local p = PlayerUIAttr;
local ChosedPetId;

--bg tag
local ID_ROLEATTR_L_BG_CTRL_LIST_LEFT					= 51;
local ID_ROLEATTR_L_BG_CTRL_LIST_NAME					= 50;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_115					= 115;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_133					= 133;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_132					= 132;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG					= 200;
local ID_ROLEATTR_L_BG_CTRL_PICTURE_BG2					= 151;
local ID_TASKBG_ARROWLEFT_CTRL_PICTURE					=10;
local ID_TASKBG_ARROWRIGHT_CTRL_PICTURE					=9;

--占星背包
local TAG_DESTINY_BAG = 14;     --占星背包

--属性主界面tag
local ID_ROLEATTR_L_CTRL_TEXT_HELP						= 100;
local ID_ROLEATTR_L_CTRL_EXP_ROLE						= 33;
local ID_ROLEATTR_L_CTRL_BUTTON_SHOES					= 62;              --长靴
local ID_ROLEATTR_L_CTRL_BUTTON_DRESS					= 61;              --腰带
local ID_ROLEATTR_L_CTRL_BUTTON_HELMET				= 60;                  --披风
local ID_ROLEATTR_L_CTRL_BUTTON_AMULET				= 59;                  --护甲
local ID_ROLEATTR_L_CTRL_BUTTON_WEAPON				= 58;              --护盔
local ID_ROLEATTR_L_CTRL_BUTTON_SOUL					= 57;                  --武器
local ID_ROLEATTR_L_CTRL_BUTTON_INHERIT				= 56;
local ID_ROLEATTR_L_CTRL_BUTTON_LEAVE					= 31;
local ID_ROLEATTR_L_CTRL_BUTTON_PILL					= 30;
local ID_ROLEATTR_L_CTRL_TEXT_MAGIC						= 29;
local ID_ROLEATTR_L_CTRL_TEXT_DEX					= 28;
local ID_ROLEATTR_L_CTRL_TEXT_SKILL					= 27;
local ID_ROLEATTR_L_CTRL_TEXT_26						= 26;
local ID_ROLEATTR_L_CTRL_TEXT_25						= 25;
local ID_ROLEATTR_L_CTRL_TEXT_ABILITY					= 24;
local ID_ROLEATTR_L_CTRL_TEXT_23						= 23;
local ID_ROLEATTR_L_CTRL_TEXT_LIFE					= 22;
local ID_ROLEATTR_L_CTRL_TEXT_21						= 21;
local ID_ROLEATTR_L_CTRL_TEXT_FORCE					= 20;
local ID_ROLEATTR_L_CTRL_TEXT_19						= 19;
local ID_ROLEATTR_L_CTRL_TEXT_JOB						= 16;
--local ID_ROLEATTR_L_CTRL_TEXT_16						= 16;
local ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG				= 9;
local ID_ROLEATTR_L_CTRL_BUTTON_BAG					= 97;
local ID_ROLEATTR_L_CTRL_BUTTON_FIRE					= 98;
local ID_ROLEATTR_L_CTRL_BUTTON_TRAIN					= 43;  --快速训练
local ID_ROLEATTR_L_CTRL_TEXT_LEVEL						= 235;

local ID_ROLEATTR_R_CTRL_TEXT_39					= 39;
local ID_ROLEATTR_R_CTRL_TEXT_38						= 38;

--宠物信息界面tag
local ID_ROLEATTR_R_CTRL_BUTTON_95					= 96;
local ID_ROLEATTR_R_CTRL_TEXT_CRIT					= 124;
local ID_ROLEATTR_R_CTRL_TEXT_DODGE					= 125;
local ID_ROLEATTR_R_CTRL_TEXT_134						= 134;
local ID_ROLEATTR_R_CTRL_TEXT_133						= 133;
local ID_ROLEATTR_R_CTRL_TEXT_132						= 132;
local ID_ROLEATTR_R_CTRL_TEXT_KILL					= 130;
local ID_ROLEATTR_R_CTRL_TEXT_WRECK					= 129;
local ID_ROLEATTR_R_CTRL_TEXT_HIT						= 138;
local ID_ROLEATTR_R_CTRL_TEXT_128						= 128;
local ID_ROLEATTR_R_CTRL_TEXT_127						= 127;
local ID_ROLEATTR_R_CTRL_TEXT_126						= 126;
local ID_ROLEATTR_R_CTRL_TEXT_TENACITY				= 121;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK			= 117;
local ID_ROLEATTR_R_CTRL_TEXT_123						= 123;
local ID_ROLEATTR_R_CTRL_TEXT_122						= 122;
local ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE			= 120;
--local ID_ROLEATTR_R_CTRL_TEXT_STUNT_DEFENSE			= 120;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE			= 119;
local ID_ROLEATTR_R_CTRL_TEXT_SPEED						= 27;
local ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK			= 116;
local ID_ROLEATTR_R_CTRL_TEXT_115						= 115;
local ID_ROLEATTR_R_CTRL_TEXT_114						= 114;
local ID_ROLEATTR_R_CTRL_TEXT_113						= 113;
local ID_ROLEATTR_R_CTRL_TEXT_112						= 112;
local ID_ROLEATTR_R_CTRL_TEXT_111						= 111;
local ID_ROLEATTR_R_CTRL_TEXT_110						= 110;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LIFE				= 109;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL				= 108;
local ID_ROLEATTR_R_CTRL_TEXT_107						= 107;
local ID_ROLEATTR_R_CTRL_TEXT_106						= 106;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_SKILL				= 105;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_JOB				= 104;
local ID_ROLEATTR_R_CTRL_TEXT_ROLE_NAME				= 103;
local ID_ROLEATTR_R_CTRL_TEXT_102						= 102;
local ID_ROLEATTR_R_CTRL_TEXT_101						= 101;
local ID_ROLEATTR_R_CTRL_PICTURE_151					= 151;
local ID_ROLEATTR_R_CTRL_PICTURE_152					= 152;
local ID_ROLEATTR_R_CTRL_PICTURE_153					= 153;
local ID_ROLEATTR_R_CTRL_PICTURE_154					= 154;
local ID_ROLEATTR_R_CTRL_PICTURE_155					= 155;
local ID_ROLEATTR_R_CTRL_PICTURE_156					= 156;
local ID_ROLEATTR_R_CTRL_PICTURE_157					= 157;
local ID_ROLEATTR_R_CTRL_PICTURE_158					= 158;
local ID_ROLEATTR_R_CTRL_PICTURE_159					= 159;
local ID_ROLEATTR_R_CTRL_PICTURE_160					= 160;
local ID_ROLEATTR_R_CTRL_PICTURE_161					= 161;
local ID_ROLEATTR_R_CTRL_TEXT_FIGHTING				= 137;
local ID_ROLEATTR_R_CTRL_TEXT_BLOCK					= 135;
local ID_ROLEATTR_R_CTRL_PICTURE_165					= 165;
local ID_ROLEATTR_R_CTRL_PICTURE_164					= 164;
local ID_ROLEATTR_R_CTRL_PICTURE_162					= 162;
local ID_ROLEATTR_R_CTRL_PICTURE_150					= 150;
local ID_ROLEATTR_R_CTRL_PICTURE_163					= 163;
local ID_ROLEATTR_R_CTRL_PICTURE_ROLE_ICON			= 99;
local ID_ROLEATTR_R_CTRL_PICTURE_95					= 95;
local ID_ROLEATTR_R_CTRL_PICTURE_94					= 94;

local TAG_BEGIN_ARROW2   = 10;
local TAG_END_ARROW2     = 9;

-- 界面控件tag定义
--local TAG_CONTAINER = 2;			--容器tag
local TAG_EQUIP_LIST = {};			--装备tag列表
local TAG_LAYER_ATTR = 12345;				--属性界面层tag

-- 界面控件坐标定义
local winsize = GetWinSize();
local RectUILayer = CGRectMake(0, 0, winsize.w , winsize.h);

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = RectUILayer.size.w / 2;
local ATTR_OFFSET_Y = 0;



--===================新增pvp查看功能=========================--
local ID_ROLEATTR_PVPATR_CTRL_TEXT_23						= 23;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_22						= 22;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_21						= 21;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_20						= 20;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_19						= 19;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_18						= 18;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_17						= 17;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_16						= 16;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_15						= 15;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_14						= 14;
local ID_ROLEATTR_PVPATR_CTRL_BUTTON_5						= 533;
local ID_ROLEATTR_PVPATR_CTRL_TEXT_3						= 3;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_69					= 69;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_68					= 68;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_67					= 67;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_66					= 66;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_65					= 65;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_64					= 64;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_63					= 63;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_62					= 62;
local ID_ROLEATTR_PVPATR_CTRL_PICTURE_61					= 61;

function p.LoadPVPAttrUI(life,strength,dex,intel,speed)
	local scene = GetSMGameScene();
	--local bglayer = p.GetPetParent();
	
	local layer = createNDUILayer();
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PVPADDUI);	
	
	layer:SetFrameRect(RectFullScreenUILayer);
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	uiLoad:Load("RoleAttr_PVPatr.ini", layer, p.OnUIEventPVPLayer, 0, 0);	
	uiLoad:Free();
	SetLabel(layer, 19,  ""..strength);
	SetLabel(layer, 20,  ""..dex);
	SetLabel(layer, 21,  ""..intel);
	SetLabel(layer, 22,  ""..life);
	--SetLabel(layer, 23,  ""..speed);
    SetLabel(layer, ID_ROLEATTR_PVPATR_CTRL_TEXT_18,  "");
    SetLabel(layer, 23,  "");
	
	scene:AddChildZ(layer,5006);
end


function p.OnUIEventPVPLayer(uiNode, uiEventType, param)
 	--local bglayer = p.GetPetParent();
 	local scene = GetSMGameScene();
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventPVPLayer[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK  then
		if ID_ROLEATTR_PVPATR_CTRL_BUTTON_5 == tag then
		--关闭界面
			scene:RemoveChildByTag(NMAINSCENECHILDTAG.PVPADDUI,true);
		end
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end
--=========================================================--




--任务属性界面
function p.LoadUI(nPetId)
	LogInfo("chh 1")
	p.Init();
    
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("p.LoadUI scene == nil,load PlayerAttr failed!");
		return;
	end
    
	LogInfo("chh 2")
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerAttr);
	layer:SetDebugName( "PlayerUI" ); --@opt
	layer:SetFrameRect(RectFullScreenUILayer);
	layer:SetDebugName( "PlayerUI" ); --@opt
	--layer:SetBackgroundColor(ccc4(125, 125, 125, 125));
	--scene:AddChild(layer);
	scene:AddChildZ(layer,UILayerZOrder.NormalLayer);
	LogInfo("chh 3")
    
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	
	--bg 任务属性背景框
	uiLoad:Load("RoleAttr_L_BG.ini", layer, p.OnUIEventBG, 0, 0);
	
   --重新生成一个层加载任务属性界面右半边
	local layerAttr = createNDUILayer();
	if not CheckP(layerAttr) then
		uiLoad:Free();
		layer:Free();
		return false;
	end
	layerAttr:Init();
	layerAttr:SetTag(TAG_LAYER_ATTR);
	layerAttr:SetFrameRect(CGRectMake(ATTR_OFFSET_X, ATTR_OFFSET_Y, RectFullScreenUILayer.size.w / 2, RectFullScreenUILayer.size.h));
	layer:AddChild(layerAttr);
	
	uiLoad:Load("RoleAttr_R.ini", layerAttr, p.OnUIEvent, 0, 0);
	
	uiLoad:Free();
	
    --装备信息窗口初始化   背包武器，宝石，材料，道具等属性页面的初始化
    BackLevelThreeWin.LoadUI(layer);
    
    --初始化左侧view
	p.InitLeftView(layer,p.OnUIEventViewChange, nPetId);
	
	
	--设置关闭音效
   	local closeBtn=GetButton(layerAttr,ID_ROLEATTR_R_CTRL_BUTTON_95);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);
   	
    
    if(nPetId) then
        p.ShowPetInfo(nPetId);
    end
    
    SetArrow(p.GetLayer(),p.GetPetNameSVC(),1,TAG_BEGIN_ARROW2,TAG_END_ARROW2);
    
    p.refreshMoney();
    
    --stage限制判断
    if not MainUIBottomSpeedBar.GetFuncIsOpen(129) then
        local btn = GetButton(layer, TAG_DESTINY_BAG);
        btn:SetImage(nil);
        btn:SetTouchDownImage(nil);
    end

    return true;
end


--初始化人物装备界面  layer:背景层对象(roleattr_l_bg.ini)  fCallBack:事件回调函数
function p.InitLeftView(layer, fCallBack, PetId)

	local containter = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	if not CheckP(containter) then
		layer:Free();
		return false;
	end
		
	containter:SetViewSize(containter:GetFrameRect().size);
	containter:SetLuaDelegate(fCallBack);
	
    --获取名字list控件
	local petNameContainer = p.GetPetNameSVC();
	if CheckP(petNameContainer) then
		petNameContainer:SetCenterAdjust(true);
		local size		= petNameContainer:GetFrameRect().size;
		local viewsize	= CGSizeMake(size.w, size.h)
		petNameContainer:SetLeftReserveDistance(size.w / 2 + viewsize.w / 2);
		petNameContainer:SetRightReserveDistance(size.w / 2 - viewsize.w / 2);
		petNameContainer:SetViewSize(viewsize);
		petNameContainer:SetLuaDelegate(fCallBack);
	end
		
	p.RefreshContainer();
    p.RefreshUpgradeStatu();
	p.UpdatePetAttr();
			
   --[[                 		
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	--获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
		LogInfo("nil == idTable");
		return;
	end
    idTable = RolePet.OrderPets(idTable);
    
    local iIndex = 0;
    LogInfo("iIndex = %d, PetId = %d", iIndex, PetId);
	for i, v in ipairs(idTable) do
           LogInfo("v = %d, PetId = %d, i = %d", v, PetId, d);
        if v == PetId then
            iIndex = i - 1;
            break;
        end
    end ]]

	local beginView	= containter:GetBeginView(0);
    --local beginView	= containter:GetView(0);
    if CheckP(beginView) then
		p.ChangePetAttr(beginView:GetViewId());
		p.ChangePetHeadPic(beginView:GetViewId());
	end

    --if CheckP(containter) then
		--containter:ShowViewByIndex(0);   
    --end
    
	if CheckP(petNameContainer) then
        petNameContainer:ShowViewByIndex(0);   
	end

	return layer

end


function p.OnUIEvent(uiNode, uiEventType, param)
	 --LuaLogInfo("1111111");
	 
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEvent[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK  then
		if ID_ROLEATTR_R_CTRL_BUTTON_95 == tag then
		--关闭界面
			CloseUI(NMAINSCENECHILDTAG.PlayerAttr);
			
		elseif ID_ROLEATTR_L_CTRL_BUTTON_BAG == tag then	
			--CloseUI(NMAINSCENECHILDTAG.PlayerAttr);
			
		    local nPetId = p.GetCurPetId();
            CloseMainUI();
            PlayerUIBackBag.LoadUI(nil, nPetId);
		elseif  ID_ROLEATTR_L_CTRL_BUTTON_FIRE == tag then  
			p.FirePetId = ChosedPetId;
			CommonDlgNew.ShowYesOrNoDlg(string.format(GetTxtPri("PUIA_T1"),ConvertS(RolePetFunc.GetPropDesc(ChosedPetId,PET_ATTR.PET_ATTR_NAME))), p.FirePet, true);
			--MsgRolePet.SendPetLeaveAction(ChosedPetId);
		    --if RolePetFunc.IsMainPet()
       	elseif  ID_ROLEATTR_L_CTRL_BUTTON_TRAIN	 == tag then   --快速训练
            RoleTrainUI.LoadUI( ChosedPetId );
        elseif tag == 91 then
           local nPetId = ChosedPetId;
           MsgPlayer.SendCheckPVPAddtion(nPetId);   
        end 
        
	elseif uiEventType == NUIEventType.TE_TOUCH_TABLE_FOCUS then
	end
	return true;
end


function p.FirePet(nEventType , nEvent, param)
	if nEventType ~= CommonDlgNew.BtnOk then
		return;
	end
	
    --阵型中宠物不可下野
    if MatrixConfigFunc.ifIsInMatrix(p.FirePetId) then
        CommonDlgNew.ShowYesDlg(GetTxtPri("PLAYER_T17"));
        return;
    end

	if RolePetFunc.IsMainPet(p.FirePetId) then
		return;
	end
	
	MsgRolePet.SendPetLeaveAction(p.FirePetId);

end



function p.OnUIEventScroll(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventScroll[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		if ID_ROLEATTR_L_CTRL_BUTTON_INHERIT == tag then
				if not IsUIShow(NMAINSCENECHILDTAG.RoleInherit) then
					CloseMainUI();
					RoleInherit.LoadUI();
				end
				return true;
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_LEAVE then
				local view = PRecursiveSV(uiNode, 1);
				if not CheckP(view) then
					LogInfo("p.OnUIEventScroll ot CheckP(view)");
					return true;
				end
				p.OnClickPetLeave(view:GetViewId());
				return true;
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_TRAIN then
			local view = PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				LogInfo("p.OnUIEventScroll ot CheckP(view)");
				return true;
			end
			local nPetId = view:GetViewId();
			--RoleTrainUI.LoadUI(nPetId);
			return true;
		elseif tag == ID_ROLEATTR_L_CTRL_BUTTON_PILL then
			local view = PRecursiveSV(uiNode, 1);
			if not CheckP(view) then
				LogInfo("p.OnUIEventScroll ot CheckP(view)");
				return true;
			end
			local nPetId = view:GetViewId();
		    if not IsUIShow(NMAINSCENECHILDTAG.PlayerUIPill) then
				CloseMainUI();
			    PlayerUIPill.LoadUI(nPetId);
			end
			return true;
		end
		
		
		--点击装备按钮
		local equipBtn = ConverToEquipBtn(uiNode);
		if not CheckP(equipBtn) then
			LogInfo("click equipment not CheckP(itemBtn) ");
			return true;
		end
		LogInfo("equip p.ChangeItemInfo[%d]", equipBtn:GetItemId());
		--p.ChangeItemInfo(equipBtn:GetItemId(), true);
		
		local nItemId = equipBtn:GetItemId();
		--判断是否弹出框
    	if(nItemId == 0) then
        	return true;
   	    end
   	    
        BackLevelThreeWin.ShowUIEquip(nItemId, ChosedPetId, true);
    
    elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE_CLICK then
        
        local equipBtn = ConverToItemButton(uiNode);
        LogInfo("equip p.ChangeItemInfo[%d]", equipBtn:GetItemId());
        
        local nItemId = equipBtn:GetItemId();
            
        if(nItemId == 0) then
            return;
        end
        
        local nPetId = p.GetCurPetId();
        BackLevelThreeWin.EquipOperate(nItemId, nPetId, true);
        
	end
	
	return true;
end

--获得当前武将ID
function p.GetCurPetId()
	local view	= p.GetCurPetView();
	if view == nil then
        LogInfo("p.GetCurPetView view is nil!");
		return 0;
	end
	
	return view:GetViewId();
end

function p.GetCurPetView()
	local parent	= p.GetPetParent();
	if parent == nil then
        LogInfo("p.GetCurPetView parent is nil!");
		return nil;
	end
	
	return parent:GetBeginView(); 
end


--下野按钮以及快速训练按钮等的显示控制
function p.ChangeFireButton(nPetId)
		local scene = GetSMGameScene();

		local FireButton	= RecursiveButton(scene, {NMAINSCENECHILDTAG.PlayerAttr,TAG_LAYER_ATTR,ID_ROLEATTR_L_CTRL_BUTTON_FIRE});
		local QuickTrainButton	= RecursiveButton(scene, {NMAINSCENECHILDTAG.PlayerAttr,TAG_LAYER_ATTR,ID_ROLEATTR_L_CTRL_BUTTON_TRAIN});
		
        local TrainTimeText = RecursiveLabel(scene, {NMAINSCENECHILDTAG.PlayerAttr,TAG_LAYER_ATTR,ID_ROLEATTR_R_CTRL_TEXT_38});
        local TrainText = RecursiveLabel(scene, {NMAINSCENECHILDTAG.PlayerAttr,TAG_LAYER_ATTR,ID_ROLEATTR_R_CTRL_TEXT_39});
        
        --小于10级不能培养
        local nPlayerId = GetPlayerId();
        local nPlayerPetId = RolePetFunc.GetMainPetId(nPlayerId); 
        local PlayerLever = SafeS2N(RolePetFunc.GetPropDesc(nPlayerPetId, PET_ATTR.PET_ATTR_LEVEL));
        
        LogInfo("p.ChangeFireButton PlayerLever = %d", PlayerLever);
        
		if RolePetFunc.IsMainPet(nPetId) then
			FireButton:SetVisible(false);                 --下野按钮
            QuickTrainButton:SetVisible(false);     --快速训练按钮 
            TrainText:SetVisible(false);               --快速训练文字
            TrainTimeText:SetVisible(false);     --时间       
            
		else
			FireButton:SetVisible(true);
            
            --主角小于30级不显示下野
            if PlayerLever < 30 then
    			FireButton:SetVisible(false);                 --下野按钮 	
            end
            
            
            --小于10级不能培养
            if PlayerLever < 10 then
                QuickTrainButton:SetVisible(false);
                TrainText:SetVisible(false);                
                TrainTimeText:SetVisible(false);    
            else
                QuickTrainButton:SetVisible(true);
                --TrainText:SetVisible(true);                
                --TrainTimeText:SetVisible(true);  
            end
		end
end


function p.RefreshArrowPic(nIndex,nViewCount)
		local scene = GetSMGameScene();
		local ArrowLeft = RecursiveUINode(scene,{NMAINSCENECHILDTAG.PlayerAttr,TAG_LAYER_ATTR,ID_TASKBG_ARROWLEFT_CTRL_PICTURE});
		local ArrowRight =RecursiveUINode(scene,{NMAINSCENECHILDTAG.PlayerAttr,TAG_LAYER_ATTR,ID_TASKBG_ARROWRIGHT_CTRL_PICTURE}); 

--	local containter	= ConverToSVC(uiNode);
--	 containter = p.GetPetNameSVC();--RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerAttr,TAG_LAYER_ATTR,ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	
--	if nil == containter then
--			LogInfo("nil !")
--	end

	
	--local index = container:GetBeginIndex();
	--local view = container:GetBeginView();
	--LogInfo("QBW:"..index.." "..nViewCount.." ")
--[[
	if index + 1 < nViewCount then
		--index = index + MAX_TASK_NUM_PER_PAGE;
		--container:ShowViewByIndex(index);
		ArrowRight:SetVisible(true);
	else

		ArrowRight:SetVisible(false);
	end--]]
end


function p.OnUIEventBG(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    
        if tag == TAG_DESTINY_BAG then
            if(DestinyUI.LoadUI(p.GetCurPetId())) then
                CloseUI(NMAINSCENECHILDTAG.PlayerAttr);
            end
        end
    end
    return true;
end

function p.OnUIEventViewChange(uiNode, uiEventType, param)
	
    local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventViewChange[%d]", tag);
    LogInfo("p.OnUIEventViewChange[%d]", param);
    
	if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
		local containter	= ConverToSVC(uiNode);
		local nPetId		= 0;
		if CheckP(containter) and CheckN(param) then
			local beginView	= containter:GetView(param);
			if CheckP(beginView) then
				nPetId	= beginView:GetViewId()
				p.ChangePetAttr(nPetId);
				p.ChangePetHeadPic(nPetId);
				
				--if (RoleTrainUI.isInShow()) then
				--	RoleTrainUI.LoadUI(beginView:GetViewId());
				--end
				
				
				
			end
		end
		
		if not nPetId or nPetId <= 0 then
			return true;
		end
	
		if ID_ROLEATTR_L_BG_CTRL_LIST_LEFT == tag then
			LogInfo("qbw: test 222");
			containter	= p.GetPetNameSVC();
			--local nViewCount = container:GetViewCount();
			local nIndex = containter:GetBeginIndex();
			LogInfo("qbw test ind:"..nIndex);
			--local nstyle = container:GetScrollStyle();
			--local viewsize = container:GetViewSize();
						
			--local nViewCount = container:GetViewCount();
			--local nViewCount = container:GetViewCount();
			--LogInfo("qbw get begin ind:"..containter:GetBeginIndex());
			--p.RefreshArrowPic(nIndex,nViewCount);
			
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
		elseif ID_ROLEATTR_L_BG_CTRL_LIST_NAME == tag then
			LogInfo("ID_ROLEATTR_L_BG_CTRL_LIST_NAME == tag");
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
            SetArrow(p.GetLayer(),p.GetPetNameSVC(),1,TAG_BEGIN_ARROW2,TAG_END_ARROW2);
		end

	end
	
	return true;
end

function p.OnUIEventClickPetName(uiNode, uiEventType, param)
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		local view	= PRecursiveSV(uiNode, 1);
		if CheckP(view) then
			local nPetId		= ConvertN(view:GetViewId())
			local containter	= p.GetPetNameSVC();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
			
			containter = p.GetPetParent();
			if CheckP(containter) then
				containter:ShowViewById(nPetId);
			end
		end
	end
	
	return true;
end

function p.SetPetEnumN(pParent, nEnum, nTag, nRoleId, nPetId)
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("PlayerUIAttr SetPetEnumN invalid petId[%d]", nPetId);
		return;
	end
	local str = tostring(RolePet.GetPetInfoN(nPetId, nEnum));
	SetLabel(pParent, nTag, str);
end

function p.SetPetEnumS(pParent, nEnum, nTag, nRoleId, nPetId)
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("PlayerUIAttr SetPetEnumN invalid petId[%d]", nPetId);
		return;
	end
	SetLabel(pParent, nTag, RolePet.GetPetInfoS(nPetId, nEnum));
end

function p.GetDetailParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerAttr, TAG_LAYER_ATTR});
	return layer;
end

function p.GetPetParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerAttr);
	if nil == layer then
		return nil;
	end
	
	local containter = RecursiveSVC(layer, {ID_ROLEATTR_L_BG_CTRL_LIST_LEFT});
	--local container = GetScrollViewContainer(layer, ID_ROLEATTR_L_BG_CTRL_LIST_LEFT);
	return containter;
end

function p.GetPetNameSVC()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	local svc = RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerAttr, ID_ROLEATTR_L_BG_CTRL_LIST_NAME});
	return svc;
end

function p.ContainerAddPetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local strPetName = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	
    --获取名字list控件
	local container	= p.GetPetNameSVC();
	if not CheckP(container) then
		return;
	end
	
	local view = createUIScrollView();
	if not CheckP(view) then
		return;
	end
	view:Init(false);
	view:SetViewId(nPetId);
	container:AddView(view);
	
	local size	= view:GetFrameRect().size;
	local btn	= _G.CreateButton("", "", strPetName, CGRectMake(0, 0, size.w, size.h), 15);
    
	if CheckP(btn) then
        local cColor = ItemPet.GetPetQuality(nPetId);
        btn:SetFontColor(cColor);
        
		btn:SetLuaDelegate(p.OnUIEventClickPetName);
		view:AddChild(btn);
	end
end

function p.ContainerShowPetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local container	= p.GetPetNameSVC();
	if not CheckP(container) then
		return;
	end
	
	container:ShowViewById(nPetId);
end

function p.ContainerRemovePetName(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	local container	= p.GetPetNameSVC();
	if not CheckP(container) then
		return;
	end
	
	container:RemoveViewById(nPetId);
end

function p.RefreshContainer()
    --左侧list控件
	local container = p.GetPetParent();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
	container:RemoveAllView();
    
	local petNameContainer = p.GetPetNameSVC();
	if CheckP(petNameContainer) then
		petNameContainer:RemoveAllView();
	end
	
	local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
	
	--获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
		LogInfo("nil == idTable");
		return;
	end
    idTable = RolePet.OrderPets(idTable);
    
	LogInfo("p.RefreshContainer begin");
	LogInfoT(idTable);
	LogInfo("p.RefreshContainer begin");
	
	local rectview = container:GetFrameRect();
	if nil == rectview then
		LogInfo("nil == rectview");
		return;
	end
	rectview.origin.x = 0;
	rectview.origin.y = 0;
	
	for i, v in ipairs(idTable) do
		local view = createUIScrollView();
        
		if view ~= nil then
            view:Init(false);
			view:bringToTop();
            view:SetViewId(v);
            container:AddView(view);

            local uiLoad = createNDUILoad();
            if uiLoad ~= nil then
                uiLoad:Load("RoleAttr_L.ini", view, p.OnUIEventScroll, 0, 0);
                uiLoad:Free();
            end
            
            --加上人物名字
            p.ContainerAddPetName(v);
            
            --设置离队标签
            local leaveBtn	= RecursiveButton(view, {ID_ROLEATTR_L_CTRL_BUTTON_LEAVE});
            if CheckP(leaveBtn) then
                p.SetPetLeaveText(leaveBtn, v);
            end
            
            --如果是人物去掉传承按钮
            if RolePetFunc.IsMainPet(v) then
                local inheritBtn	= RecursiveButton(view, {ID_ROLEATTR_L_CTRL_BUTTON_INHERIT});
                if CheckP(inheritBtn) then
                    inheritBtn:RemoveFromParent(true);
                end
            end
            
            --中间角色图片
            local pRoleForm = GetUiNode(view, ID_ROLEATTR_L_CTRL_BUTTON_ROLE_IMG);
            local rectForm	= pRoleForm:GetFrameRect();
            if nil ~= pRoleForm then
                local roleNode = createUIRoleNode();
                if nil ~= roleNode then
                    roleNode:Init();
                    roleNode:SetFrameRect(CGRectMake(0, 0, rectForm.size.w, rectForm.size.h));
                    roleNode:ChangeLookFace(RolePetFunc.GetLookFace(v));
                    pRoleForm:AddChild(roleNode); 
                end
            end
            
            p.RefreshPetEquip(v);
        end
	end
end

--刷新当前背包
function p.RefreshCurrentBack()
    local nPetId = p.GetCurPetId();
    p.RefreshPetEquip(nPetId);
    p.RefreshUpgradeStatu();
end

--显示当前武将信息
function p.ShowPetInfo(nPetId)
    local container = p.GetPetParent();
    if(container == nil) then
        LogInfo("p.RefreshPetEquip container is nil");
        return;
    end
    if(nPetId == nil) then
        LogInfo("p.RefreshPetEquip nPetId is nil");
        return;
    end
    container:ShowViewById(nPetId);
end

--刷新武将装备
function p.RefreshPetEquip(nPetId)
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    local container = p.GetPetParent();
    if(container == nil) then
        LogInfo("p.RefreshPetEquip container is nil");
        return;
    end
    local view = container:GetViewById(nPetId);
    if(view == nil) then
        LogInfo("p.RefreshPetEquip view is nil");
        return;
    end
    
    --装备
    local idlist	= ItemPet.GetEquipItemList(nPlayerId, nPetId);
    for i, v in ipairs(idlist) do
        local nPos	= Item.GetItemInfoN(v, Item.ITEM_POSITION);
        local nTag	= p.GetEquipTag(nPos);
        if nTag > 0 then
            local equipBtn	= GetEquipButton(view, nTag);
            if CheckP(equipBtn) then
                equipBtn:ChangeItem(v);
                --[[
                if(_G.ItemFunc.IfItemCanUpStep(v, nPetId)) then
                    
                    local nItemtype = Item.GetItemInfoN(v, Item.ITEM_TYPE);
                    if(PlayerEquipUpStepUI.IfUpStepMatrialEnough(nItemtype)) then
                        equipBtn:SetUpgrade(1);
                    else
                        equipBtn:SetUpgrade(2);
                    end
                    
                    if(i<=#idlist/2) then
                        equipBtn:SetUpgradeIconPos(1);
                    end
                else
                    equipBtn:SetUpgrade(0);
                end
                ]]
            end
        end
    end
end

--** 刷新升阶状态 **--
function p.RefreshUpgradeStatu()
    LogInfo("p.RefreshUpgradeStatu");
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		return;
	end
    
    local container = p.GetPetParent();
	if nil == container then
		LogInfo("nil == container");
		return;
	end
    local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    for i,nPetId in ipairs(idTable) do
        local view = container:GetViewById(nPetId);
        local idlist	= ItemPet.GetEquipItemList(nPlayerId, nPetId);
        
        for j,nItemId in ipairs(idlist) do
            local nPos	= Item.GetItemInfoN(nItemId, Item.ITEM_POSITION);
            local nTag	= p.GetEquipTag(nPos);
            local equipBtn	= GetEquipButton(view, nTag);
            if nTag > 0 then
                if CheckP(equipBtn) then
                    if(_G.ItemFunc.IfItemCanUpStep(nItemId, nPetId)) then
                        local nItemtype = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
                        if(PlayerEquipUpStepUI.IfUpStepMatrialEnough(nItemtype)) then
                            equipBtn:SetUpgrade(1);
                        else
                            equipBtn:SetUpgrade(2);
                        end
                        
                        if(nPos%10<=3) then
                            equipBtn:SetUpgradeIconPos(1);
                        end
                    else
                        equipBtn:SetUpgrade(0);
                    end
                    
                end
            end
            
        end
        
    end
end



function p.SetPetAttr(petView, nPetDataIndex, str)
	if not CheckP(petView) or
		not CheckN(nPetDataIndex) or
		not CheckS(str) then
		LogInfo("PlayerUIAttr.SetPetAttr invalid arg");
		return;
	end
	
	local nTag = 0;
	if nPetDataIndex == PET_ATTR.PET_ATTR_TYPE then
	--职业
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_JOB;

	elseif nPetDataIndex == PET_ATTR.PET_ATTR_LIFE then
	--生命
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_LIFE;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SUPER_SKILL then
	--绝技
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_ABILITY;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SKILL then
	--技能
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_SKILL;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_NAME then
	--名字
		--todo
		--nTag	= ID_ROLEATTR_L_CTRL_TEXT_PLAYER_NAME;
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_SPEED	then
	--速度
		nTag	= ID_ROLEATTR_R_CTRL_TEXT_SPEED;
        
   --[[    
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHYSICAL then
	--力量
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        
   	elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC then
	--智力
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_MAGIC;     
        
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_DEX	then
    --敏捷	
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_DEX;
    ]]
    
    
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHY_ATK then
	--物理攻击
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        SetLabel(petView, ID_ROLEATTR_L_CTRL_TEXT_19, GetTxtPri("HS_T9"));
        
   elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC_ATK then
	--策略攻击
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_FORCE;    
        SetLabel(petView, ID_ROLEATTR_L_CTRL_TEXT_19, GetTxtPri("HS_T11"));
        
    elseif nPetDataIndex == PET_ATTR.PET_ATTR_PHY_DEF	then
    --物理防御
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_DEX;      
        
   	elseif nPetDataIndex == PET_ATTR.PET_ATTR_MAGIC_DEF then
	--策略防御
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_MAGIC;     
         
        
	elseif nPetDataIndex == PET_ATTR.PET_ATTR_LEVEL	then
	--等级
		nTag	= ID_ROLEATTR_L_CTRL_TEXT_LEVEL;
	end
	
	if nTag > 0 then
		return SetLabel(petView, nTag, str);
	end
end

function p.UpdatePetAttrById(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local container = p.GetPetParent();
	if not CheckP(container) then
		return;
	end
	
	local nPlayerId = GetPlayerId();
	if not CheckN(nPlayerId) then
		return;
	end
	
	if not RolePetUser.IsExistPet(nPlayerId, nPetId) then
		return;
	end
	
	local view	= container:GetViewById(nPetId);
	if not CheckP(view) then
		return;
	end
	--名字
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_NAME, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
    
    
    
	--职业
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_TYPE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));
    
	--生命
    local strlife = RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE);-- .. "/" .. RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE_LIMIT);
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LIFE, strlife);
	--技能
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SUPER_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));
	
    --获取职业类型 主要有  猛将: 1   射手: 2  军师: 3
    local nPetType = RolePet.GetPetInfoN(nPetId,PET_ATTR.PET_ATTR_TYPE);
    
    local nActType = GetDataBaseDataN("pet_config", nPetType, DB_PET_CONFIG.ATK_TYPE);
    if ( nActType == 3) then
           --策略攻击
        p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC_ATK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK)); 
    else
        --物理攻击
        p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHY_ATK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_ATK));
    end

    --物理防御
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHY_DEF, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_DEF));  
    
    --策略防御
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC_DEF, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF));
    
   --[[ 
    --力量
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_PHYSICAL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL));
    
    --法术
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_MAGIC, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC));
    
	--敏捷
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_DEX, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DEX));
	]]
    
	--速度
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_SPEED, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SPEED));
    
	--等级
	p.SetPetAttr(view, PET_ATTR.PET_ATTR_LEVEL, GetTxtPub("levels")..":"..RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	
	local expUI	= RecursivUIExp(view, {ID_ROLEATTR_L_CTRL_EXP_ROLE});
	if CheckP(expUI) then
		expUI:SetProcess(ConvertN(RolePet.GetPetInfoN(nPetId, PET_ATTR.PET_ATTR_EXP)));
		expUI:SetTotal(ConvertN(RolePetFunc.GetNextLvlExp(nPetId)));
	end
end

function p.UpdatePetAttr()
	--获取玩家宠物id列表
	local nPlayerId = GetPlayerId();
	if not CheckN(nPlayerId) then
		return;
	end
    
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if not CheckT(idTable) then
		return;
	end
    idTable = RolePet.OrderPets(idTable);

	for i, v in ipairs(idTable) do
		p.UpdatePetAttrById(v);
	end
end


--更新宠物头像
function p.ChangePetHeadPic(nId)
	if not CheckN(nId) then
		return nil;
	end
	
	local nPetType = RolePet.GetPetInfoN(nId,PET_ATTR.PET_ATTR_TYPE);
	
    if(nPetType == 0) then
        return nil;
    end
    
    local layer = p.GetDetailParent();
    
    local pic = GetPetPotraitPic(nPetType);
    local HeadPic = GetImage(layer, ID_ROLEATTR_R_CTRL_PICTURE_ROLE_ICON);
	HeadPic:SetPicture(pic,true);
end
 

function p.ChangePetAttr(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("not RolePet.IsExistPet[%d]", nPetId);
	end
	
	local layer = p.GetDetailParent();
	if not CheckP(layer) then
		return;
	end

	ChosedPetId = nPetId;
	
	--姓名
	local l_name = SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_NAME, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
	ItemPet.SetLabelColor(l_name, nPetId);
    
    --职业
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_JOB, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TYPE));
	--技能
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_SKILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SKILL));
	--等级
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LEVEL));
	--SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LEVEL, SafeN2S(99));
	--生命
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_ROLE_LIFE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_LIFE));
	

    --力量
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHYSICAL));
    --敏捷
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DEX));
    --智力
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC));
    --速度
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_SPEED));
    
    --[[
	--物理攻击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_ATK));
	--物理防御
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_NORMAL_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_PHY_DEF));
	--策略攻击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_ATTACK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_ATK));
	--策略防御
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_MAGIC_DEFENSE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_MAGIC_DEF));]]
    
	--暴击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_CRIT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DRITICAL));
	--韧性
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_TENACITY, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_TENACITY));
	--命中
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_HIT, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HITRATE));
	--闪避
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_DODGE, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_DODGE));
	--破击
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_WRECK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_WRECK));
	--格档
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_BLOCK, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_BLOCK));
	--必杀
	SetLabel(layer, ID_ROLEATTR_R_CTRL_TEXT_KILL, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HURT_ADD));
	--护驾
	SetLabel(layer, ID_ROLEATTR_L_CTRL_TEXT_HELP, RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_HELP));
	
	--下野按钮显示
	p.ChangeFireButton(nPetId);
end

function p.OnClickPetLeave(nPetId)
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("p.OnPetLeave invalid petid");
		return;
	end
	
	if RolePetFunc.IsMainPet(nPetId) then
		--打开客栈
		if not IsUIShow(NMAINSCENECHILDTAG.RoleInvite) then
			CloseMainUI();
			RoleInvite.LoadUI();
		end
	else 
		--发送离队消息
		LogInfo("call send pet[%d] leave", nPetId);
		MsgRolePet.SendPetLeaveAction(nPetId);
	end 
end

function p.SetPetLeaveText(btn, nPetId)
	if not CheckP(btn) then
		LogInfo("p.SetPetLeaveText invalid btn");
		return;
	end
	if not RolePet.IsExistPet(nPetId) then
		LogInfo("p.SetPetLeaveText invalid petid");
		return;
	end
	
	if RolePetFunc.IsMainPet(nPetId) then
		btn:SetTitle(GetTxtPri("PLAYER_T18"));
	else
		btn:SetTitle(GetTxtPri("PLAYER_T19"));
	end
end

function p.Init()
	p.InitEquipTag();
end

function p.InitEquipTag()
	if not CheckT(TAG_EQUIP_LIST) or TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] then
		return;
	end 
	
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_1] = ID_ROLEATTR_L_CTRL_BUTTON_SOUL;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_2] = ID_ROLEATTR_L_CTRL_BUTTON_WEAPON;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_3] = ID_ROLEATTR_L_CTRL_BUTTON_AMULET;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_4] = ID_ROLEATTR_L_CTRL_BUTTON_HELMET;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_5] = ID_ROLEATTR_L_CTRL_BUTTON_DRESS;
	TAG_EQUIP_LIST[Item.POSITION_EQUIP_6] = ID_ROLEATTR_L_CTRL_BUTTON_SHOES;
end

function p.IsEquipTag(nTag)
	if not CheckT(TAG_EQUIP_LIST) or not CheckN(nTag) then
		return false;
	end
	
	for k, v in pairs(TAG_EQUIP_LIST) do
		if v == nTag then
			return true;
		end
	end
	
	return false;
end

function p.GetEquipTag(nPos)
	if not CheckT(TAG_EQUIP_LIST) or not CheckN(nPos) then
		return 0;
	end
	return ConvertN(TAG_EQUIP_LIST[nPos]);
end

function p.GetLayer()
    local scene     = GetSMGameScene();	
    if(scene == nil) then
        LogInfo("p.GetLayer scene is nil!");
        return;
    end
    
    local layer	= RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerAttr});
    if(layer == nil) then
        LogInfo("p.GetLayer layer is nil!");
        return;
    end
    
    return layer;
end

function p.GetPetPageViewContainer()
	local scene = GetSMGameScene();	
	if not CheckP(scene) then
		LogInfo("not CheckP(scene),load p.LoadPageView failed!");
		return;
	end
	
	local svc	= RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerBackBag, ID_ROLEATTR_L_BG_CTRL_LIST_NAME});
	return svc;
end


function p.GameDataPetInfoRefresh(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerAttr) then
		return;
	end
	p.UpdatePetAttrById(nPetId);
	
	p.refreshPetattr();
end

function p.GameDataPetAttrRefresh(datalist)
	LogInfo("PlayerUIAttr.GameDataPetInfoRefresh");
	if not CheckT(datalist) then
		LogInfo("PlayerUIAttr.GameDataPetInfoRefresh invalid arg");
		return;
	end
	if not IsUIShow(NMAINSCENECHILDTAG.PlayerAttr) then
		return;
	end
	if #datalist <= 1 then
		LogInfo("PlayerUIAttr.GameDataPetInfoRefresh #datalist <= 1");
		return;
	end
	local nPetId = datalist[1];
	if not CheckN(nPetId) then
		return;
	end
	for i=2, #datalist, 2 do
		if datalist[i] and datalist[i] == PET_ATTR.PET_ATTR_POSITION then
			local container = p.GetPetParent();
			if not CheckP(container) then
				return;
			end 
			if RolePet.IsInPlayer(nPetId) then
				--增加伙伴
				local view = createUIScrollView();
				if CheckP(view) then
					view:Init(false);
					view:SetViewId(nPetId);
					container:AddView(view);
				end
				p.ContainerAddPetName(nPetId);
			else
				--伙伴离队
				container:RemoveViewById(nPetId);
				p.ContainerRemovePetName(nPetId);
			end
		end
	end
end

local TAG_E_TMONEY      = 243;  --
local TAG_E_TEMONEY     = 242;  --

function p.refreshPetattr()
	p.ChangePetAttr(ChosedPetId);
end	

--刷新金钱
function p.refreshMoney()
    LogInfo("p.refreshMoney BEGIN");
    local nPlayerId     = GetPlayerId();
    local scene = GetSMGameScene();
    if(scene == nil) then
        return;
    end
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerAttr);
    if(layer == nil) then
        return;
    end
    
    local nmoney        = MoneyFormat(GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_MONEY));
    local ngmoney        = GetRoleBasicDataN(nPlayerId,USER_ATTR.USER_ATTR_EMONEY).."";
    
    _G.SetLabel(layer, TAG_E_TMONEY, nmoney);
    _G.SetLabel(layer, TAG_E_TEMONEY, ngmoney);
end
GameDataEvent.Register(GAMEDATAEVENT.USERATTR,"PlayerUIAttr.refreshMoney",p.refreshMoney);

GameDataEvent.Register(GAMEDATAEVENT.PETINFO, "PlayerUIAttr.GameDataPetInfoRefresh", p.GameDataPetInfoRefresh);
GameDataEvent.Register(GAMEDATAEVENT.PETATTR, "PlayerUIAttr.GameDataPetAttrRefresh", p.GameDataPetAttrRefresh);
		