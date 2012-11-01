---------------------------------------------------
--描述: 玩家物品神铸界面
--时间: 2012.6.3
--作者: QBW
---------------------------------------------------

PlayerEquipGlidUI = {}
local p = PlayerEquipGlidUI;


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

local ATTR_OFFSET_X = winsize.w * 3/ 8;
local ATTR_OFFSET_Y =  winsize.h / 8;

local  formulaID          = 0;--合成卷子类型id
local  g_ItemId          = 0;--装备id
local  g_ItemTypeId          = 0;--装备类型id
local  g_StoneId          = 0;--神石id

local TAG_EQUIP_PIC     = 2;    --装备图片
local TAG_EQUIP_NAME    = 6;    --装备名字
local TAG_EQUIP_LEVEL   = 7;    --强化等级
local TAG_EQUIP_BUTTON  = 5;    --强化按钮

p.TagPetNameList    = 601;      --武将列表
p.TagUserList      = 600;       --用户列表
p.TagEquipList      = 5;        --装备列表
p.TagEquipListItemHeight = 110; --装备列表项
local TAG_PET_NAME		=  1;

p.TagEquipListItemHeight = 55*ScaleFactor; --装备列表项
p.idEquipListItem   = {};       --背包装备列表

--function p.LoadUI(itemID)
function p.LoadUI(nStoneId)
	  g_StoneId = nStoneId

  

	 local nStoneItemType = Item.GetItemInfoN(nStoneId,Item.ITEM_TYPE);
	 --不是神石 
	if Num7(nStoneItemType) ~= 5 then
		CommonDlgNew.ShowYesDlg("该物品不是神石！");
		return;
	end

	
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
	layer:SetTag(NMAINSCENECHILDTAG.PlayerEquipGlidUI);
	layer:SetFrameRect(RectFullScreenUILayer);
	scene:AddChildZ(layer,2);
	
	--初始化ui
	local uiLoad = createNDUILoad();
	if nil == uiLoad then
		layer:Free();
		return false;
	end
	uiLoad:Load("foster_C.ini", layer, p.OnUIEventBg, 0, 0);
	
	
	
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
	
	uiLoad:Load("foster_C_R.ini", layerCompose, p.OnUIEventInfoLayer, 0, 0);
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
	
	p.initData();
	 p.RefreshUI();
	--p.RefreshMatirialContainer();
	p.RefreshComposeInfoLayer()
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
			local scene = GetSMGameScene();
			if scene ~= nil then
				scene:RemoveChildByTag(NMAINSCENECHILDTAG.PlayerEquipGlidUI, true);
				return true;
			end
		end	
	end

end


--合成信息层事件
function p.OnUIEventInfoLayer(uiNode, uiEventType, param)
   local tag = uiNode:GetTag();
   LogInfo("p.OnUIEventInfoLayer[%d]", tag);
   if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
      if ID_FOSTER_B_R_CTRL_BUTTON_11 == tag then 
		  p.EquipGlid();
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
		          CloseUI(NMAINSCENECHILDTAG.PlayerEquipGlidUI);
		          TaskUI.GoToDynMap(mapID,1);
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
	local MatirialListC = RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerEquipGlidUI,ID_FOSTER_B_CTRL_LIST_L});
	return MatirialListC;

end



---------------------------------------------------
--刷新信息
---------------------------------------------------


--刷新合成信息层
function p.RefreshComposeInfoLayer()
	local Infolayer = p.GetDetailParent();
	
	
	
	if formulaID == 0 then
		
		SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_24,"");
		SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_26,"");
		SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_32,"");
		SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_34,"");
		SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_36,"");
		SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_3,"");
		SetLabel(Infolayer,ID_FOSTER_B_R_CTRL_TEXT_4,"");		
		return;
	end
	
	--获取公式id
	
	
	
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
		 CloseUI(NMAINSCENECHILDTAG.PlayerEquipGlidUI);
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
		          CloseUI(NMAINSCENECHILDTAG.PlayerEquipGlidUI);
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


--神铸按钮
function p.EquipGlid()
	--qbw 检测是否存在合成公式
  if formulaID == 0 then
  		
  		
  	  return;
  end

    --判断背包是否已满
   if(ItemFunc.IsBagFull()) then
       return false;
   end
   

  local formulaEmoney1 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL1,DB_FORMULATYPE.NUM1);
  local formulaEmoney2 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL2,DB_FORMULATYPE.NUM2);
  local formulaEmoney3 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL3,DB_FORMULATYPE.NUM3);
  local formulaEmoney4 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL4,DB_FORMULATYPE.NUM4);
  local formulaEmoney5 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL5,DB_FORMULATYPE.NUM5);
  local formulaEmoney6 = p.GetFormulaEmoney(DB_FORMULATYPE.MATERIAL6,DB_FORMULATYPE.NUM6);
  if formulaEmoney1 > 0 
     or formulaEmoney2 > 0 
	 or formulaEmoney3 > 0 
	 or formulaEmoney4 > 0 
	 or formulaEmoney5 > 0 
	 or formulaEmoney6 > 0 then
	local needEmoney =  formulaEmoney1 + formulaEmoney2 + formulaEmoney3 + formulaEmoney4 + formulaEmoney5 + formulaEmoney6;
	CommonDlg.ShowNoPrompt("将花费"..needEmoney.."金币弥补缺失的材料", p.OnCommonDlg,true);
  else
    MsgCompose.SendGlidAction(formulaID,g_ItemId);
  end	

end



function p.OnCommonDlg(nId, nEvent, param)
  if nEvent == CommonDlg.EventOK then
    MsgCompose.SendGlidAction(formulaID,g_ItemId);
  end
end

function p.GetFormulaEmoney(material,num)
  local formulaEmoney = 0;

  local materialItemType = GetDataBaseDataN("formulatype",formulaID,material); 
  if materialItemType ~= 0 then
	local needNum = GetDataBaseDataN("formulatype",formulaID,num);
	local owerNum = ItemFunc.GetItemCount(materialItemType);
    if owerNum < needNum then
	  formulaEmoney = (needNum - owerNum) * GetDataBaseDataN("itemtype", materialItemType, DB_ITEMTYPE.FORMULA_EMONEY);
    end
  end
  
  return formulaEmoney;
end



--获得信息层
function p.GetDetailParent()
	local scene = GetSMGameScene();
	if nil == scene then
		return nil;
	end
	
	local layer = RecursiveUILayer(scene, {NMAINSCENECHILDTAG.PlayerEquipGlidUI, TAG_LAYER_COMPOSE});
	return layer;
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
	p.initData();
	CommonDlgNew.ShowYesDlg("制作成功:"..ItemFunc.GetName(nProductType));
	scene:RemoveChildByTag(NMAINSCENECHILDTAG.PlayerEquipGlidUI, true);
	
end


----------------------------------------------------------------------
------------------------- 复用chh强化界面   ----------------------------
----------------------------------------------------------------------
function p.RefreshUI()
    p.RefreshPetInfo();
    p.RefreshEquipInfo();
    --p.RefreshGemInfo();
end
--[[
function p.RefreshEquipInfo()
    
    local userContainer = p.GetUserContainer();
    userContainer:RemoveAllView();
    local rectview = userContainer:GetFrameRect();
    userContainer:SetViewSize(rectview.size);
    
    --用户列表
    local nPlayerId = GetPlayerId();
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    
    for i=1, #idTable do
        p.AddUserItem(idTable[i]);
    end
    
end

function p.AddUserItem(petId)
    local container = p.GetUserContainer();
 
    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.AddUserItem createUIScrollView failed");
        return;
    end
    view:Init(false);
    view:SetViewId(petId);
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
	
    uiLoad:Load("foster_A_L.ini", view, nil, 0, 0);
    p.refreshUserInfoListItem(view, petId);
end
--]]

function p.RefreshEquipInfo()
    
    local userContainer = p.GetUserContainer();
    local nIndex = userContainer:GetBeginIndex();
    userContainer:RemoveAllView();
    local rectview = userContainer:GetFrameRect();
    userContainer:SetViewSize(rectview.size);
    
    local nPlayerId = GetPlayerId();
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
    
    
    for i=1, #idTable do
        local petId = idTable[i];
        p.AddPetEquipItem(petId);
    end
    
    p.AddPetEquipItem(0);
    
    userContainer:ShowViewByIndex(nIndex);
end



function p.AddPetEquipItem(petId)
        local userContainer = p.GetUserContainer();
        local rectview = userContainer:GetFrameRect();
        
        local clientLayer = createContainerClientLayerM();
        clientLayer:Init(false);
        clientLayer:SetViewSize(CGSizeMake(rectview.size.w, p.TagEquipListItemHeight));
        userContainer:AddView(clientLayer);
        
        local nPlayerId = GetPlayerId();
        
        
        local equipIdList = {};
        if(petId==0) then
            equipIdList = p.idEquipListItem;
        else
            equipIdList = ItemPet.GetEquipItemList(nPlayerId, petId);
        end
        
        
        for j, v in ipairs(equipIdList) do
            local equipId = equipIdList[j];
            local view = createUIScrollViewM();
            view:Init(false);
            view:SetViewId(equipId);
            clientLayer:AddView(view);
    
            --初始化ui
            local uiLoad = createNDUILoad();
            if nil == uiLoad then
                view:Free();
                return false;
            end
            
            uiLoad:Load("foster_A_L_Item.ini", view, nil, 0, 0);
            p.refreshEquipInfoListItem(view,equipId);
        end
end

function p.refreshUserInfoListItem(view, petId)
    local container = p.GetEquipContainer(petId);
    container:RemoveAllView();
    local rectview = container:GetFrameRect();
    container:SetViewSize(CGSizeMake(rectview.size.w, p.TagEquipListItemHeight));
    
    
    local nPlayerId = GetPlayerId();
    local equipIdList = ItemPet.GetEquipItemList(nPlayerId, petId);
    
    --遍历装备
	for i, v in ipairs(equipIdList) do
		p.AddPetEquipItem(v,petId);
	end
    
end

function p.AddPetEquipItem(equipId,petId)
    if not CheckN(equipId) then
		return;
	end
	local container = p.GetEquipContainer(petId);
 
    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.AddPetEquipItem createUIScrollView failed");
        return;
    end
    view:Init(false);
    view:SetViewId(equipId);
    container:AddView(view);
    
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
	
    uiLoad:Load("foster_A_L_Item.ini", view, nil, 0, 0);
    
    p.refreshEquipInfoListItem(view,equipId);
end

function p.GetEquipContainer(viewId)
    local userContainer = p.GetUserContainer();
    local view = userContainer:GetViewById(viewId);
    local container = GetScrollViewContainer(view, p.TagEquipList);
    return container;
end

function p.refreshEquipInfoListItem(view,equipId)
    --set pic
    local pic = GetItemButton(view, TAG_EQUIP_PIC);
    pic:ChangeItem(equipId);
    
    --set name
    local type =Item.GetItemInfoN(equipId, Item.ITEM_TYPE);
    local equipName = ItemFunc.GetName(type);
    local name = GetLabel(view, TAG_EQUIP_NAME);
    name:SetText(equipName);
    
    --set level
    local equipLv = Item.GetItemInfoN(equipId, Item.ITEM_ADDITION);
    local name = GetLabel(view, TAG_EQUIP_LEVEL);
    local lv = "强化"..equipLv;
    lv=lv.."级";
    name:SetText(lv);
    
    local btn = GetButton(view, TAG_EQUIP_BUTTON);
    btn:SetParam1(equipId);
    btn:SetLuaDelegate(p.OnUIEventSelectEquipBtn);
end

function p.OnUIEventSelectEquipBtn(uiNode, uiEventType, param)
	
	local btn = ConverToButton(uiNode);
	 g_ItemId = btn:GetParam1();
  	
	g_ItemTypeId= Item.GetItemInfoN(g_ItemId,Item.ITEM_TYPE);
	
	formulaID = ItemFunc.GetFormulaIdByItemType(g_ItemTypeId,2)
	
	LogInfo("qbw1:glid  itemid:"..g_ItemId.."   type:"..g_ItemTypeId.." formular id :"..formulaID);


 	local reqLev = GetDataBaseDataN("itemtype", g_ItemTypeId, DB_ITEMTYPE.REQ_LEVEL);
	if reqLev <  100 then
		CommonDlgNew.ShowYesDlg("该装备无法神铸，只有100级以上装备才可以神铸！");
	elseif 	formulaID == 0 then
		CommonDlgNew.ShowYesDlg("该物品无法神铸！");
	end
	
		
	
	p.RefreshComposeInfoLayer();
	
	
end

---------------------------刷新武将名称-----------------------------------
function p.RefreshPetInfo()
    local container = p.GetPetNameContainer();
    if nil == container then
		LogInfo("nil == container");
		--return;
	end
	container:RemoveAllView();
    local rectview = container:GetFrameRect();
    container:SetViewSize(rectview.size);
    
    local nPlayerId = GetPlayerId();
	if nil == nPlayerId then
		LogInfo("nil == nPlayerId");
		--return;
	end
    
    --获取玩家伙伴id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
		LogInfo("nil == idTable");
		--return;
	end
    
    --遍历伙伴
	for i, v in ipairs(idTable) do
        --顶部角色名称
		p.AddPetNameItem(v);
	end
    
end

function p.AddPetNameItem(nPetId)
	if not CheckN(nPetId) then
		return;
	end
	
	if not RolePet.IsExistPet(nPetId) then
		return;
	end
	
	local container = p.GetPetNameContainer();
 
    local view = createUIScrollView();
    if view == nil then
        LogInfo("p.AddPetNameItem createUIScrollView failed");
        return;
    end
    view:Init(false);
    view:SetViewId(nPetId);
    view:SetTag(nPetId);
    container:AddView(view);
        
    --初始化ui
    local uiLoad = createNDUILoad();
    if nil == uiLoad then
        layer:Free();
        return false;
    end
	
    uiLoad:Load("PetNameListItem.ini", view, nil, 0, 0);
    p.refreshPetInfoListItem(view,nPetId);
    
end

function p.refreshPetInfoListItem(view,nPetId)
    local strPetName = ConvertS(RolePetFunc.GetPropDesc(nPetId, PET_ATTR.PET_ATTR_NAME));
    local labelName = GetLabel(view, TAG_PET_NAME);
    labelName:SetText(strPetName);
end

function p.GetPetNameContainer()
    local layer = p.GetLayer();
    local container = GetScrollViewContainer(layer, p.TagPetNameList);
    return container;
end

function p.GetLayer()
    local scene = GetSMGameScene();	
	if scene == nil then
		return;
	end
    
    local layer = GetUiLayer(scene, NMAINSCENECHILDTAG.PlayerEquipGlidUI);
    return layer;
end

function p.GetUserContainer()   
    local layer = p.GetLayer();
    local container = GetScrollViewContainerM(layer, p.TagUserList);
    return container;
end

function p.initData()
    p.idEquipListItem = {};
    
    local nPlayerId		= ConvertN(GetPlayerId());
    local idlistItem	= ItemUser.GetBagItemList(nPlayerId);
	local nSize			= table.getn(idlistItem);
    
    for i, v in ipairs(idlistItem) do
        local nItemType		= Item.GetItemInfoN(v, Item.ITEM_TYPE);
        local nType			= ItemFunc.GetBigType(nItemType);

        if(nType == Item.bTypeEquip) then
            table.insert(p.idEquipListItem, v);
        end
    end
    
end


GameDataEvent.Register(GAMEDATAEVENT.PETATTR, "PlayerUIBackBag.GameDataPetAttrRefresh", p.GameDataPetAttrRefresh);
