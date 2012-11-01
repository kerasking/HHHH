---------------------------------------------------
--描述: 玩家物品升阶界面
--时间: 2012.6.1
--作者: QBW
---------------------------------------------------

PlayerEquipUpStepUI = {}
local p = PlayerEquipUpStepUI;


--bg
local ID_FOSTER_B_CTRL_TEXT_15					= 15;
local ID_FOSTER_B_CTRL_TEXT_14					= 14;
local ID_FOSTER_B_CTRL_LIST_L						= 600;
local ID_FOSTER_B_CTRL_PICTURE_20					= 22;
local ID_FOSTER_B_CTRL_PICTURE_TITLE				= 638;
local ID_FOSTER_B_CTRL_BUTTON_CLOSE				= 3;
local ID_FOSTER_B_CTRL_PICTURE_36					= 36;
local ID_FOSTER_B_CTRL_PICTURE_22					= 23;
local ID_FOSTER_B_CTRL_PICTURE_1					= 1;

--合成界面
local ID_FOSTER_B_R_CTRL_PICTURE_37					= 38;
local ID_FOSTER_B_R_CTRL_TEXT_36						= 37;
local ID_FOSTER_B_R_CTRL_TEXT_35						= 36;
local ID_FOSTER_B_R_CTRL_EQUIP_BUTTON_32				= 33;
local ID_FOSTER_B_R_CTRL_TEXT_34						= 35;
local ID_FOSTER_B_R_CTRL_TEXT_33						= 34;
local ID_FOSTER_B_R_CTRL_TEXT_32						= 32;
local ID_FOSTER_B_R_CTRL_TEXT_26						= 26;
local ID_FOSTER_B_R_CTRL_TEXT_25						= 25;
local ID_FOSTER_B_R_CTRL_TEXT_24						= 24;
local ID_FOSTER_B_R_CTRL_TEXT_23						= 23;
local ID_FOSTER_B_R_CTRL_TEXT_22						= 22;
local ID_FOSTER_B_R_CTRL_TEXT_21						= 21;
local ID_FOSTER_B_R_CTRL_BUTTON_11					= 11;
local ID_FOSTER_B_R_CTRL_PICTURE_20					= 20;
local ID_FOSTER_B_R_CTRL_TEXT_4						= 4;
local ID_FOSTER_B_R_CTRL_TEXT_3						= 3;
local ID_FOSTER_B_R_CTRL_EQUIP_BUTTON_2				= 2;
local ID_FOSTER_B_R_CTRL_PICTURE_1					= 1;

--材料item
local ID_FOSTER_B_L_CTRL_TEXT_7						= 7;
local ID_FOSTER_B_L_CTRL_TEXT_6						= 6;
local ID_FOSTER_B_L_CTRL_EQUIP_BUTTON_2				= 2;


-- 界面控件tag定义
local TAG_CONTAINER = 2;						--容器tag
local TAG_EQUIP_LIST = {};						--装备tag列表
local TAG_MATERIAL_IMG_LIST = {};				--合成材料图标tag列表
local TAG_MATERIAL_TEXT_LIST = {};				--合成材料完成度文本tag列表
local TAG_LAYER_COMPOSE = 12345;				--合成信息界面层tag

-- 界面控件坐标定义
local winsize = GetWinSize();

local CONTAINTER_W = RectUILayer.size.w / 2;
local CONTAINTER_H = RectUILayer.size.h;
local CONTAINTER_X = 0;
local CONTAINTER_Y = 0;

local ATTR_OFFSET_X = winsize.w * 0.4;
local ATTR_OFFSET_Y =  winsize.h / 8;

local  formulaID          = 0;--合成卷子类型id
local  g_ItemId          = 0;--装备id
local  g_ItemTypeId          = 0;--装备类型id



function p.LoadUI(itemID)
	g_ItemId = itemID;

	g_ItemTypeId= Item.GetItemInfoN(g_ItemId,Item.ITEM_TYPE);
	  
	formulaID = ItemFunc.GetFormulaIdByItemType(g_ItemTypeId,1)

	 
	 --不存在公式 
	if formulaID == 0 then
		CommonDlgNew.ShowYesDlg("该装备无法升阶！（无对应公式）"..g_ItemTypeId);
		return;
	end
	
	--不存在卷子
	if ItemFunc.GetItemCount(formulaID) <= 0 then
		CommonDlgNew.ShowYesDlg("无法升阶，缺少卷轴:"..ItemFunc.GetName(formulaID));
		return;		
	end
	
	
  
	p.Init();
	local scene = GetSMGameScene();	
	if scene == nil then
		LogInfo("scene == nil,load PlayerBackBag failed!");
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetTag(NMAINSCENECHILDTAG.PlayerEquipUpStepUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,1);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("foster_B.ini", layer, p.OnUIEventBg, 0, 0);
	
	
	
	--合成信息界面
	local layerCompose = createNDUILayer();
	if not CheckP(layerCompose) then
		layer:Free();
		return false;
	end
	layerCompose:Init();
	layerCompose:SetTag(TAG_LAYER_COMPOSE);
	layerCompose:SetFrameRect(CGRectMake(ATTR_OFFSET_X, ATTR_OFFSET_Y, RectFullScreenUILayer.size.w *2/ 3, RectFullScreenUILayer.size.h));
	layer:AddChild(layerCompose);
	
	uiLoad:Load("foster_B_R.ini", layerCompose, p.OnUIEventInfoLayer, 0, 0);
	uiLoad:Free();
	
	--formulaID=Item.GetItemInfoN(itemID, Item.ITEM_TYPE);
	
	LogInfo("formulaID="..formulaID);	
	
	--p.initComposeUI(layerCompose);
	
	local containter = RecursiveSVC(layer, {ID_FOSTER_B_CTRL_LIST_L});
	if not CheckP(containter) then
		layer:Free();
		return false;
	end
	
	local rectview = containter:GetFrameRect();
	local nWidth	= rectview.size.w;
	local nHeight	= rectview.size.h / 4;
			
	containter:SetViewSize(CGSizeMake(nWidth, nHeight));
	containter:SetLuaDelegate(p.OnUIEventMatirialContainerViewChange);
	containter:SetStyle(UIScrollStyle.Verical);
	containter:EnableScrollBar(true);
	
	p.RefreshMatirialContainer();
	p.RefreshComposeInfoLayer()
	
	
	
	   	--设置关闭音效
   	local closeBtn=GetButton(layer,ID_FOSTER_B_CTRL_BUTTON_CLOSE);
   	closeBtn:SetSoundEffect(Music.SoundEffect.CLOSEBTN);

	return true;
end



---------------
--UI事件处理回调函数
---------------
--背景事件
function p.OnUIEventBg(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventBg[%d]", tag);
	
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	
		if tag == ID_FOSTER_B_CTRL_BUTTON_CLOSE then
			--local scene = GetSMGameScene();
			--if scene ~= nil then
			--	scene:RemoveChildByTag(NMAINSCENECHILDTAG.PlayerEquipUpStepUI, true);
			--	return true;
			--end
            
            RemoveChildByTagNew(NMAINSCENECHILDTAG.PlayerEquipUpStepUI, true,true);
            return true;
        end	
	end

end


--合成信息层事件
function p.OnUIEventInfoLayer(uiNode, uiEventType, param)
   local tag = uiNode:GetTag();
   LogInfo("p.OnUIEventInfoLayer[%d]", tag);
   if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
      if ID_FOSTER_B_R_CTRL_BUTTON_11 == tag then 
		  p.EquipUpStep();
		 return true; 
	  end 
   end	  	
end


--材料列表容器事件
function p.OnUIEventMatirialContainerViewChange(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	LogInfo("p.OnUIEventBg[%d]", tag);
	if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
		--local nItemId = tag;
		--点击图片寻路
		if tag ==ID_FOSTER_B_L_CTRL_EQUIP_BUTTON_2 then
			local itemBtn = ConverToItemButton(uiNode);
			local nItemType  =ConvertN(itemBtn:GetItemType());
			if nItemType ~= 0 then
			
			    local mapID=GetDataBaseDataN("itemtype",nItemType,DB_ITEMTYPE.ORIGIN_MAP); 
			    LogInfo("qbw: mapid:"..mapID);
				if mapID ~= 0 then 
		          --CloseUI(NMAINSCENECHILDTAG.PlayerEquipUpStepUI);
		          TaskUI.GoToDynMap(mapID,1,2);
		          
		          --关闭界面
		          CloseMainUI();
		          
		          --CloseUI(NMAINSCENECHILDTAG.PlayerEquipUpStepUI);
		          --CloseUI(NMAINSCENECHILDTAG.PlayerEquipUpStepUI);
		          return true;
				end		  
		    end
		
		end
	end
end








--材料列表   物品ID 1:现有物品数量  2：需要物品数量 3：物品获得方式str
function p.GetMatirialList()
	
	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.PRODUCT);

	--local nMaterialId1 =	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL1); 初始装备
	local nMaterialId2 =	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL2);
	local nMaterialId3 =	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL3);
	local nMaterialId4 =	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL4);
	local nMaterialId5 =	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL5);
	local nMaterialId6 =	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL6);

	--local nMaterialNum1 =GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.NUM1);
	local nMaterialNum2 =GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.NUM2);
	local nMaterialNum3 =GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.NUM3);
	local nMaterialNum4 =GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.NUM4);
	local nMaterialNum5 =GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.NUM5);
	local nMaterialNum6 =GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.NUM6);


	local t ={}
	t[nMaterialId2] = {ItemFunc.GetItemCount(nMaterialId2),nMaterialNum2,"副本掉落"} 
	t[nMaterialId3] = {ItemFunc.GetItemCount(nMaterialId3),nMaterialNum3,"副本掉落"}
	t[nMaterialId4] = {ItemFunc.GetItemCount(nMaterialId4),nMaterialNum4,"副本掉落"}
	t[nMaterialId5] = {ItemFunc.GetItemCount(nMaterialId5),nMaterialNum5,"副本掉落"}
	t[nMaterialId6] = {ItemFunc.GetItemCount(nMaterialId6),nMaterialNum6,"副本掉落"}
	
	return t;
end

function p.GetMatirialListContainer()
	local scene = GetSMGameScene();
	local MatirialListC = RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerEquipUpStepUI,ID_FOSTER_B_CTRL_LIST_L});
	return MatirialListC;

end



---------------------------------------------------
--刷新信息
---------------------------------------------------
--刷新合成信息层
function p.RefreshComposeInfoLayer()
	local Infolayer = p.GetDetailParent();
	
	local nItemType=GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL1);
	local productItemType=GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.PRODUCT);
	local nNeedMoney 		= GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.FEE_MONEY);

	--根据装备类型显示属性
    local equipLv = Item.GetItemInfoN(g_ItemId, Item.ITEM_ADDITION);
    local sDesc,num = ItemFunc.GetAttrDesc(nItemType,equipLv);
	
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_23,sDesc);
	
	
	--local desc = ItemFunc.GetAttrTypeDesc(Item.GetItemInfoN(nItemId, Item.ITEM_ATTR_BEGIN));
	local nAttack  			= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.ATTR_VALUE_1);	
	local nAttackNew 		= GetDataBaseDataN("itemtype", productItemType, DB_ITEMTYPE.ATTR_VALUE_1);
	    
    --附加属性显示
    --local desc = ItemFunc.GetAttrTypeDesc(Item.GetItemInfoN(nItemId, Item.ITEM_ATTR_BEGIN));
    
		 
		 
		 
	local nEquipLev 		= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.REQ_LEVEL);
	local nEquipLevNew 		= GetDataBaseDataN("itemtype", productItemType, DB_ITEMTYPE.REQ_LEVEL);
	
	
	local nAdvanceLev	 = Item.GetItemInfoN(g_ItemId, Item.ITEM_ADDITION);
	local nAdvanceLevNew 	= nAdvanceLev - 5;
	if nAdvanceLevNew < 0 then
		nAdvanceLevNew = 0;
	end
	
	local i = 2;
	for i =2,15 do
		local test = GetDataBaseDataN("itemtype", nItemType,i);
		LogInfo("qbw1:"..test.."  i:"..i);	 
	end 	
	
	
	local sItemName	= ItemFunc.GetName(nItemType);
	local sItemNameNew = ItemFunc.GetName(productItemType);
	
	
	--LogInfo("qbw1: item:"..nItemType.." newitem:"..productItemType)
	
	local itemBtn=GetItemButton(Infolayer,ID_FOSTER_B_R_CTRL_EQUIP_BUTTON_2);
	if CheckP(itemBtn) then
	    itemBtn:ChangeItemType(nItemType);
	end	
	
	local itemBtnPROD=GetItemButton(Infolayer,ID_FOSTER_B_R_CTRL_EQUIP_BUTTON_32);
	if CheckP(itemBtnPROD) then
	    itemBtnPROD:ChangeItemType(productItemType);
	end	
	
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_24,""..nEquipLev 	);
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_25,""..nAdvanceLev	);
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_26,""..nAttack  	);
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_32,""..nEquipLevNew );
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_33,""..nAdvanceLevNew);
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_34,""..nAttackNew 	);
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_36,""..nNeedMoney.."银币");
		
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_3,""..sItemName 	);
	SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_4,""..sItemNameNew 	);
	

			
	--强化等级		
			
			
			
end

--刷新容器列表
function p.RefreshMatirialContainer()
	local MatirialListContainer =p.GetMatirialListContainer();
	MatirialListContainer:RemoveAllView();
	
	local  tItemNeed = p.GetMatirialList();
	
	for i,v in pairs(tItemNeed) do
		
		if i == 0 then
			break;
		end
		
		local nItemTypeId = i;
		local nOwnCount = v[1];
		local nNeedCount = v[2];
		local sTip	= v[3];
		
		local view = createUIScrollView();
	     if view == nil then
		     LogInfo("view == nil");
		     return;
	     end
	
	     view:Init(false);
	     view:SetViewId(nItemTypeId);
	     MatirialListContainer:AddView(view);
		 
	     local uiLoad = createNDUILoad();
	     if uiLoad ~= nil then
		     uiLoad:Load("foster_B_L.ini",view,p.OnUIEventMatirialContainerViewChange,0,0);
		     uiLoad:Free();
	     end	

		local sName =  ItemFunc.GetName(nItemTypeId);
		SetLabel(view,ID_FOSTER_B_L_CTRL_TEXT_6,nOwnCount.."/"..nNeedCount..":"..sName);
		SetLabel(view,ID_FOSTER_B_L_CTRL_TEXT_7,sTip);
		
		--不满足则设置颜色
		local labelCount = GetLabel(view,ID_FOSTER_B_L_CTRL_TEXT_6);
		local labeltip = GetLabel(view,ID_FOSTER_B_L_CTRL_TEXT_7);
		if nOwnCount < nNeedCount then
			  labelCount:SetFontColor(ccc4(255, 0, 0, 255));
			  labeltip:SetFontColor(ccc4(255, 0, 0, 255));
		end
		
		local itemBtn=GetItemButton(view,ID_FOSTER_B_L_CTRL_EQUIP_BUTTON_2);
		if CheckP(itemBtn) then
	    	itemBtn:ChangeItemType(nItemTypeId);
	    	
	    	--itemBtn:SetLuaDelegate(p.OnUIEventMatirialContainerViewChange);
		end	
		
		
		
	end
	

end


function p.OnUIEventRightPanel(uiNode, uiEventType, param)
   local tag = uiNode:GetTag();
   LogInfo("p.OnUIEventRightPanel[%d]", tag);
   if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
      if ID_WEAPONMIX_CTRL_BUTTON_CLOSE == tag then 
		 CloseUI(NMAINSCENECHILDTAG.PlayerEquipUpStepUI);
		 return true; 
	  elseif ID_WEAPONMIX_CTRL_BUTTON_COMPOUND == tag then 
		 p.Compose();
		 return true; 
	  end 	
	  for i, v in ipairs(TAG_MATERIAL_IMG_LIST) do
		if v == tag then
		   local itemBtn = ConverToItemButton(uiNode);
		   if CheckP(itemBtn) then
		      local materialItemType = ConvertN(itemBtn:GetItemType());
			  if materialItemType ~= 0 then
			    local mapID=GetDataBaseDataN("itemtype",materialItemType,DB_ITEMTYPE.ORIGIN_MAP); 
				if mapID ~= 0 then 
		          CloseUI(NMAINSCENECHILDTAG.PlayerEquipUpStepUI);
		          TaskUI.GoToDynMap(mapID,1);
				end		  
			  end
	       end		
		   return true;
		end
	  end
   end  
   return true; 
end


--升阶按钮
function p.EquipUpStep()
	--qbw 检测武器是否存在

   --判断背包是否已满
   if(ItemFunc.IsBagFull()) then
       return false;
   end


  --local formulaEmoney1 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL1,DB_FORMULATYPE.NUM1);
  local formulaEmoney2 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL2,DB_FORMULATYPE.NUM2);
  local formulaEmoney3 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL3,DB_FORMULATYPE.NUM3);
  local formulaEmoney4 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL4,DB_FORMULATYPE.NUM4);
  local formulaEmoney5 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL5,DB_FORMULATYPE.NUM5);
  local formulaEmoney6 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL6,DB_FORMULATYPE.NUM6);
  if formulaEmoney2 > 0 
	 or formulaEmoney3 > 0 
	 or formulaEmoney4 > 0 
	 or formulaEmoney5 > 0 
	 or formulaEmoney6 > 0 then
	local needEmoney =  formulaEmoney2 + formulaEmoney3 + formulaEmoney4 + formulaEmoney5 + formulaEmoney6;
	CommonDlg.ShowNoPrompt("将花费"..needEmoney.."金币弥补缺失的材料", p.OnCommonDlg,true);
  else
    MsgCompose.SendUpstepAction(formulaID,g_ItemId);
  end	

end



function p.OnCommonDlg(nId, nEvent, param)
  if nEvent == CommonDlg.EventOK then
    MsgCompose.SendUpstepAction(formulaID,g_ItemId);
  end
end

function p.GetFormulaEmoney(material,num)
  local formulaEmoney = 0;

  local materialItemType = GetDataBaseDataN("formulatype",formulaID,material); 
  --LogInfo("qbw1: emoney materialItemType"..materialItemType);
  if materialItemType ~= 0 then
  	local needNum = GetDataBaseDataN("formulatype",formulaID,num);
	---LogInfo("qbw1: emoney needNum"..needNum);
	local owerNum = ItemFunc.GetItemCount(materialItemType);
    if owerNum < needNum then
	  formulaEmoney = (needNum - owerNum) * GetDataBaseDataN("itemtype", materialItemType, DB_ITEMTYPE.FORMULA_EMONEY);

	   --LogInfo("qbw1: FORMULA_EMONEY:"..GetDataBaseDataN("itemtype", materialItemType, DB_ITEMTYPE.FORMULA_EMONEY));
    end
    --LogInfo("qbw1: emoney owerNum:"..owerNum.." needNum:"..needNum);
  end
  -- LogInfo("qbw1: emoney need"..formulaEmoney);
  return formulaEmoney;
end

	--local nMaterialId6 =	GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.MATERIAL6);
	--local nMaterialNum2 =GetDataBaseDataN("formulatype",formulaID,DB_FORMULATYPE.NUM2);

--获得信息层
function p.GetDetailParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerEquipUpStepUI, TAG_LAYER_COMPOSE});
	return layer;
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

--成功升阶
function p.SuccGetProduct(nProductType)
	local scene = GetSMGameScene();
	CommonDlgNew.ShowYesDlg("制作成功:"..ItemFunc.GetName(nProductType));
	
	--成功音效    
    Music.PlayEffectSound(Music.SoundEffect.EQ_UPSTEP);
	
	scene:RemoveChildByTag(NMAINSCENECHILDTAG.PlayerEquipUpStepUI, true);

end

GameDataEvent.Register(GAMEDATAEVENT.PETATTR, "PlayerUIBackBag.GameDataPetAttrRefresh", p.GameDataPetAttrRefresh);
