---------------------------------------------------
--描述: 玩家器灵界面
--时间: 2012.4.20
--作者: xxj
---------------------------------------------------
PlayerNimbusUI = {}
local p = PlayerNimbusUI;

--背景tag
local ID_LOCK_SPIRIT_CTRL_TEXT_15						= 15;
local ID_LOCK_SPIRIT_CTRL_TEXT_NUM						= 14;
local ID_LOCK_SPIRIT_CTRL_TEXT_13						= 13;
local ID_LOCK_SPIRIT_CTRL_VERTICAL_LIST_SPIRIT			= 11;
local ID_LOCK_SPIRIT_CTRL_PICTURE_SPIRIT_BG				= 9;
local ID_LOCK_SPIRIT_CTRL_LIST_WEAPON					= 8;
local ID_LOCK_SPIRIT_CTRL_LIST_ROLE_NAME				= 7;
local ID_LOCK_SPIRIT_CTRL_BUTTON_4						= 4;
local ID_LOCK_SPIRIT_CTRL_TEXT_3						= 3;
local ID_LOCK_SPIRIT_CTRL_PICTURE_2						= 2;
local ID_LOCK_SPIRIT_CTRL_PICTURE_BG					= 1;
--器灵背包tag
local ID_40_40_16_CTRL_OBJECT_BUTTON_16			= 16;
local ID_40_40_16_CTRL_OBJECT_BUTTON_15			= 15;
local ID_40_40_16_CTRL_OBJECT_BUTTON_14			= 14;
local ID_40_40_16_CTRL_OBJECT_BUTTON_12			= 12;
local ID_40_40_16_CTRL_OBJECT_BUTTON_11			= 11;
local ID_40_40_16_CTRL_OBJECT_BUTTON_10			= 10;
local ID_40_40_16_CTRL_OBJECT_BUTTON_8			= 8;
local ID_40_40_16_CTRL_OBJECT_BUTTON_7			= 7;
local ID_40_40_16_CTRL_OBJECT_BUTTON_6			= 6;
local ID_40_40_16_CTRL_OBJECT_BUTTON_4			= 4;
local ID_40_40_16_CTRL_OBJECT_BUTTON_3			= 3;
local ID_40_40_16_CTRL_OBJECT_BUTTON_2			= 2;
local ID_40_40_16_CTRL_OBJECT_BUTTON_13			= 13;
local ID_40_40_16_CTRL_OBJECT_BUTTON_9			= 9;
local ID_40_40_16_CTRL_OBJECT_BUTTON_5			= 5;
local ID_40_40_16_CTRL_OBJECT_BUTTON_1			= 1;
--武器信息tag
local ID_WEAPON_CTRL_TEXT_WEAPON_NAME			= 84;
local ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT6		= 10;
local ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT5		= 9;
local ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT4		= 8;
local ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT3		= 7;
local ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT2		= 5;
local ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT1		= 4;
local ID_WEAPON_CTRL_SPRITE_9			        = 1;
--器灵信息tag
local ID_SPIRIT_PROMPT_CTRL_BUTTON_CLOSE				= 76;
local ID_SPIRIT_PROMPT_CTRL_BUTTON_SELL					= 10;
local ID_SPIRIT_PROMPT_CTRL_BUTTON_WEAR_OR_TAKEOFF		= 9;
local ID_SPIRIT_PROMPT_CTRL_BUTTON_8					= 8;
local ID_SPIRIT_PROMPT_CTRL_TEXT_PROMPT					= 7;
local ID_SPIRIT_PROMPT_CTRL_TEXT_ATTRIBUTE3				= 6;
local ID_SPIRIT_PROMPT_CTRL_TEXT_ATTRIBUTE2				= 5;
local ID_SPIRIT_PROMPT_CTRL_TEXT_ATTRIBUTE1				= 4;
local ID_SPIRIT_PROMPT_CTRL_TEXT_SPIRIT_NAME			= 3;
local ID_SPIRIT_PROMPT_CTRL_OBJECT_BUTTON_SPIRIT		= 2;
local ID_SPIRIT_PROMPT_CTRL_PICTURE_BG					= 1;
--阵眼重铸tag
local ID_RECAST_CTRL_BUTTON_RECAST				= 16;
local ID_RECAST_CTRL_TEXT_PROMPT				= 15;
local ID_RECAST_CTRL_BUTTON_ACTIVATION1			= 13;
local ID_RECAST_CTRL_CHECK_BUTTON_LOCK3			= 12;
local ID_RECAST_CTRL_CHECK_BUTTON_LOCK2			= 11;
local ID_RECAST_CTRL_CHECK_BUTTON_LOCK1			= 10;
local ID_RECAST_CTRL_TEXT_ATTRIBUTE3			= 9;
local ID_RECAST_CTRL_TEXT_ATTRIBUTE2			= 8;
local ID_RECAST_CTRL_TEXT_ATTRIBUTE1			= 7;
local ID_RECAST_CTRL_TEXT_LOCK					= 6;
local ID_RECAST_CTRL_OBJECT_BUTTON_SPIRIT		= 5;
local ID_RECAST_CTRL_PICTURE_SPIRIT_BG			= 4;
local ID_RECAST_CTRL_TEXT_TITAL					= 3;
local ID_RECAST_CTRL_BUTTON_CLOSE				= 2;
local ID_RECAST_CTRL_PICTURE_BG					= 1;

-- 界面控件tag定义
local TAG_NIMBUS_BG     = 990               --器灵背景tag
local TAG_NIMBUS_INFO   = 991               --器灵信息tag
local TAG_NIMBUS_RECAST = 992               --器灵重铸tag
local TAG_MOUSE         = 993               --鼠标图片tag 

--自定义数据
local selectItemId = 0;
local dragWeapId = 0;
local selectPetId = 0;
local isWear = true;
local choseTarget = {};
local partsBagViewId = 1;
local MAX_PARTS_NUM = 16;
local sealIconFileName = "icon_role.png";
local weapAniPath = "weapQLAni.spr";
local aniSpace = 2;
--table数据
local CHIPS_LIST = {1,3,9};

local TAG_ATTR_LIST = 
{
  ID_SPIRIT_PROMPT_CTRL_TEXT_ATTRIBUTE1,
  ID_SPIRIT_PROMPT_CTRL_TEXT_ATTRIBUTE2,
  ID_SPIRIT_PROMPT_CTRL_TEXT_ATTRIBUTE3
};

local TAG_PARTS_LIST = 
{
  ID_40_40_16_CTRL_OBJECT_BUTTON_1,
  ID_40_40_16_CTRL_OBJECT_BUTTON_2,
  ID_40_40_16_CTRL_OBJECT_BUTTON_3,
  ID_40_40_16_CTRL_OBJECT_BUTTON_4,
  ID_40_40_16_CTRL_OBJECT_BUTTON_5,
  ID_40_40_16_CTRL_OBJECT_BUTTON_6,
  ID_40_40_16_CTRL_OBJECT_BUTTON_7,
  ID_40_40_16_CTRL_OBJECT_BUTTON_8,
  ID_40_40_16_CTRL_OBJECT_BUTTON_9,
  ID_40_40_16_CTRL_OBJECT_BUTTON_10,
  ID_40_40_16_CTRL_OBJECT_BUTTON_11,
  ID_40_40_16_CTRL_OBJECT_BUTTON_12,
  ID_40_40_16_CTRL_OBJECT_BUTTON_13,
  ID_40_40_16_CTRL_OBJECT_BUTTON_14,
  ID_40_40_16_CTRL_OBJECT_BUTTON_15,
  ID_40_40_16_CTRL_OBJECT_BUTTON_16
};

local TAG_RECAST_ATTR_LIST = 
{
  ID_RECAST_CTRL_TEXT_ATTRIBUTE1,
  ID_RECAST_CTRL_TEXT_ATTRIBUTE2,
  ID_RECAST_CTRL_TEXT_ATTRIBUTE3
};

local TAG_CHECK_BUTTON_LIST = 
{
  ID_RECAST_CTRL_CHECK_BUTTON_LOCK1,
  ID_RECAST_CTRL_CHECK_BUTTON_LOCK2,
  ID_RECAST_CTRL_CHECK_BUTTON_LOCK3
};  

local TAG_WEAPON_EQUIP_LIST = 
{
  ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT1,
  ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT2,
  ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT3,
  ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT4,
  ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT5,
  ID_WEAPON_CTRL_EQUIP_BUTTON_SPIRIT6
};
local sellMoney ={10000,20000,50000};
local sellLiQi ={1,3,9};

--临时数据
local maxNimbusNum = 6;

function p.LoadUI()
  LogInfo("PlayerNimbusUI.LoadUI()");
  local scene = GetSMGameScene();	
  if scene == nil then
	LogInfo("scene == nil,load PlayerNimbusUI failed!");
	return;
  end
  local layer = createNDUILayer();
  if layer == nil then
	return false;
  end
  layer:Init();
  layer:SetTag(NMAINSCENECHILDTAG.PlayerNimbusUI);
  layer:SetFrameRect(RectUILayer);
  scene:AddChild(layer);
  
  local uiLoad = createNDUILoad();
  if nil == uiLoad then
	layer:Free();
	return false;
  end
  
  local nimbusBgLayer = createNDUILayer();
  if CheckP(nimbusBgLayer) then
	nimbusBgLayer:Init();
    nimbusBgLayer:SetTag(TAG_NIMBUS_BG);
    nimbusBgLayer:SetFrameRect(CGRectMake(0, 0, RectUILayer.size.w, RectUILayer.size.h));
	uiLoad:Load("SM_QL_Lock_Spirit.ini", nimbusBgLayer, p.OnUIEventMain, 0, 0);
	
	local partsContainer = RecursiveSVC(nimbusBgLayer,{ID_LOCK_SPIRIT_CTRL_VERTICAL_LIST_SPIRIT});
	if CheckP(partsContainer) then
	  local rectview = partsContainer:GetFrameRect();
      if nil ~= rectview then
        partsContainer:SetViewSize(rectview.size);
      end
	  local view = createUIScrollView();
	  if CheckP(view) then
	    view:Init(false);
	    view:SetViewId(partsBagViewId);
	    partsContainer:AddView(view);
		uiLoad:Load("40_40_16.ini", view, p.OnUIEventPartsBag, 0, 0);
	  end
	end	
	
	local nPlayerId = GetPlayerId();
	--获取玩家宠物id列表
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
	  LogInfo("nil == idTable");
	  return;
	end
	
	local petNameContainer = RecursiveSVC(nimbusBgLayer,{ID_LOCK_SPIRIT_CTRL_LIST_ROLE_NAME});
	if nil == petNameContainer then
	  LogInfo("nil == petNameContainer");
      return;
    end
	petNameContainer:SetCenterAdjust(true);
	local size = petNameContainer:GetFrameRect().size;
	local viewsize	= CGSizeMake(size.w / 3, size.h)
	petNameContainer:SetLeftReserveDistance(size.w / 2 + viewsize.w / 2);
	petNameContainer:SetRightReserveDistance(size.w / 2 - viewsize.w / 2);
	petNameContainer:SetViewSize(viewsize);
	petNameContainer:SetLuaDelegate(p.OnUIEventViewChange);
	
	local weaponContainter = RecursiveSVC(nimbusBgLayer,{ID_LOCK_SPIRIT_CTRL_LIST_WEAPON});
	if CheckP(weaponContainter) then
	  local rectview = weaponContainter:GetFrameRect();
      if nil ~= rectview then
        weaponContainter:SetViewSize(rectview.size);
      end
      weaponContainter:SetLuaDelegate(p.OnUIEventViewChange);
	  for i,v in ipairs(idTable) do
	  
		local strPetName = ConvertS(RolePetFunc.GetPropDesc(v, PET_ATTR.PET_ATTR_NAME));
	    local petNameView = createUIScrollView();
		if CheckP(petNameView) then
		  petNameView:Init(false);
          petNameView:SetViewId(v);
		  petNameContainer:AddView(petNameView); 
          local size = petNameView:GetFrameRect().size;
          local btn	= CreateButton("", "", strPetName, CGRectMake(0, 0, size.w, size.h), 12);
          if CheckP(btn) then
	        btn:SetLuaDelegate(p.OnUIEventClickPetName);
	        petNameView:AddChild(btn);
          end  
		end

		local weapView = createUIScrollView();
		if CheckP(weapView) then
		  weapView:Init(false);
	      weapView:SetViewId(v);
		  local weapId = ItemFunc.GetItemIdByPosition(ItemPet.GetEquipItemList(nPlayerId, v),Item.POSITION_EQUIP_2);
		  uiLoad:Load("SM_QL_Weapon.ini", weapView, p.OnUIEvenWeap, 0, 0);
		  local weapSprite = RecursivUISprite(weapView,{ID_WEAPON_CTRL_SPRITE_9});
		  if weapId ~= 0 then
		    local itemType = Item.GetItemInfoN(weapId,Item.ITEM_TYPE);
			local weapNameLabel = GetLabel(weapView,ID_WEAPON_CTRL_TEXT_WEAPON_NAME);
			if CheckP(weapNameLabel) then
			  local itemName = ItemFunc.GetName(itemType)
			  local nEnhance = Item.GetItemInfoN(weapId, Item.ITEM_ADDITION);
			  if nEnhance > 0 then
			    itemName = itemName .." ".. EquipStrFunc.GetLevelName(nEnhance);
			  end
			  weapNameLabel:SetFontColor(ItemUI.GetEquipColor(itemType));
			  weapNameLabel:SetText(itemName);
			end
			local idlist = ItemInlay.GetQiLinItemList(weapId);
			if CheckP(weapSprite) then
			  weapSprite:ChangeSprite(GetSMAniPath(weapAniPath));
			  local nJobReq	= ConvertN(ItemFunc.GetJobReq(itemType));
			  weapSprite:SetAnimation(nJobReq-1,false);
			  local curFrame = table.getn(idlist) * aniSpace;
			  weapSprite:SetPlayFrameRange(curFrame,curFrame);
			end 
			for i, v in ipairs(idlist) do
			  local itemType = Item.GetItemInfoN(v,Item.ITEM_TYPE);
	          local index = Num6(itemType);
			  local weapButton = GetEquipButton(weapView,TAG_WEAPON_EQUIP_LIST[index]);
			  if CheckP(weapButton) then
			    weapButton:SetShowAdapt(true);
				weapButton:ChangeItem(v);
			  end
			end
			for i, v in ipairs(TAG_WEAPON_EQUIP_LIST) do
			local weapButton = GetEquipButton(weapView,v);
			  if CheckP(weapButton) then
			    if i > maxNimbusNum then
				  local pic = EmailList.GetPicByFileName(sealIconFileName);
				  if CheckP(pic) then
				    weapButton:SetImage(pic);
				  end 
				end
			  end
			end
          else
			if CheckP(weapSprite) then
			  weapSprite:SetVisible(false);
			end  
		  end
	      weaponContainter:AddView(weapView);	 	  
		end
	  end  	  
    end
          
	petNameContainer:ShowViewByIndex(0);
	layer:AddChildZ(nimbusBgLayer,1);
  end
  
  local nimbusInfoLayer = createNDUILayer();
  if CheckP(nimbusBgLayer) then
	nimbusInfoLayer:Init();
	nimbusInfoLayer:SetTag(TAG_NIMBUS_INFO);
	uiLoad:Load("SM_QL_Spirit_Prompt.ini", nimbusInfoLayer, p.OnUIEventNimbusInfo, 0, 0);	
	local infoBackLayer = GetUiNode(nimbusInfoLayer,ID_SPIRIT_PROMPT_CTRL_PICTURE_BG);
	if CheckP(infoBackLayer) then
	  local infoBackRect = infoBackLayer:GetFrameRect();
	  local infoW = infoBackRect.size.w;
	  local infoH = infoBackRect.size.h;
	  local infoX = (RectUILayer.size.w - infoW) / 2;
	  local infoY = (RectUILayer.size.h - infoH) / 2;
	  nimbusInfoLayer:SetFrameRect(CGRectMake(infoX,infoY,infoW,infoH));
	end
	nimbusInfoLayer:SetVisible(false);
	layer:AddChildZ(nimbusInfoLayer, 2);
  end
  
  local recastLayer = createNDUILayer();
  if CheckP(recastLayer) then
  	recastLayer:Init();
	recastLayer:SetTag(TAG_NIMBUS_RECAST);
	uiLoad:Load("SM_QL_Recast.ini", recastLayer, p.OnUIEventRecast, 0, 0);	
	local recastBackLayer = GetUiNode(recastLayer,ID_RECAST_CTRL_PICTURE_BG);
	if CheckP(recastBackLayer) then
	  local recastBackRect = recastBackLayer:GetFrameRect();
	  local recastW = recastBackRect.size.w;
	  local recastH = recastBackRect.size.h;
	  local recastX = (RectUILayer.size.w - recastW) / 2;
	  local recastY = (RectUILayer.size.h - recastH) / 2;
	  recastLayer:SetFrameRect(CGRectMake(recastX,recastY,recastW,recastH));
	end
	recastLayer:SetVisible(false);
	layer:AddChildZ(recastLayer, 3);
  end
 
  --鼠标图片初始化
  local imgMouse = createNDUIImage();
  if CheckP(imgMouse) then
    imgMouse:Init();
    imgMouse:SetTag(TAG_MOUSE);
    layer:AddChildZ(imgMouse,4); 
  end
    

  uiLoad:Free();  
  
  p.RefreshPartsBag();

end

function SetMouse(pic, moveTouch)
  LogInfo("SetMouse");
  if not CheckStruct(moveTouch) then
	LogInfo("SetMouse invalid arg");
	return;
  end	
  local scene = GetSMGameScene();	
  if scene == nil then
	return;
  end
  local idlist = {};
  local imgMouse = RecursiveImage(scene, {NMAINSCENECHILDTAG.PlayerNimbusUI,TAG_MOUSE});
  if not CheckP(imgMouse) then
	LogInfo("not CheckP(imgMouse)");
	return;
  end
  imgMouse:SetPicture(pic, true);
  if CheckP(pic) then
	local size		= pic:GetSize();
	local nMoveX	= moveTouch.x - size.w / 2 - RectUILayer.origin.x;
	local nMoveY	= moveTouch.y - size.h / 2 - RectUILayer.origin.y;
	imgMouse:SetFrameRect(CGRectMake(nMoveX, nMoveY, size.w, size.h));
  else
	LogInfo("imgMouse:SetFrameRect(RectZero)");
	imgMouse:SetFrameRect(RectZero());
  end
end

function GetNimbusInfoLayer()
  local scene = GetSMGameScene();
  if CheckP(scene) then
    local nimbusInfoLayer = RecursiveUILayer(scene,{NMAINSCENECHILDTAG.PlayerNimbusUI,TAG_NIMBUS_INFO});
	if CheckP(nimbusInfoLayer) then
	  return nimbusInfoLayer;
	end
  end
end

function GetNimbusRecastLayer()
  local scene = GetSMGameScene();
  if CheckP(scene) then
    local nimbusRecastLayer = RecursiveUILayer(scene,{NMAINSCENECHILDTAG.PlayerNimbusUI,TAG_NIMBUS_RECAST});
	if CheckP(nimbusRecastLayer) then
	  return nimbusRecastLayer;	
	end
  end
end

function p.RefreshRecastLayer()
  local nimbusRecastLayer = GetNimbusRecastLayer();
  if CheckP(nimbusRecastLayer) then
    if nimbusRecastLayer:IsVisibled() then
	  ShowRecastLayer();
	end
  end
end

function ShowRecastLayer()
  local nimbusRecastLayer = GetNimbusRecastLayer();
  choseTarget = {false,false,false};
  if CheckP(nimbusRecastLayer) then
    nimbusRecastLayer:SetVisible(true);
    local itemType = Item.GetItemInfoN(selectItemId, Item.ITEM_TYPE);
	local nQulity = ItemFunc.GetQuality(itemType);
	local j = 1;
	for i=1, 3 do
	  local nAttrType = ConvertN(ItemFunc.GetAttrType(selectItemId, i - 1));
	  if nAttrType > Item.ATTR_TYPE_NONE then
	    local str = GetAttrDec(nQulity,nAttrType,selectItemId,i - 1);
		local attrInfoLabel = GetLabel(nimbusRecastLayer,TAG_RECAST_ATTR_LIST[j]);
		if CheckP(attrInfoLabel) then
		   attrInfoLabel:SetFontColor(ItemUI.GetQLValueColor(nQulity,nAttrType,selectItemId,i - 1));
		   attrInfoLabel:SetText(str);  
		end
		local checkBox = RecursiveCheckBox(nimbusRecastLayer,{TAG_CHECK_BUTTON_LIST[j]});
		if CheckP(checkBox) then
		   checkBox:SetVisible(true);
		   checkBox:SetSelect(false);
		end
		j = j + 1; 
	  end
	end
	
	for i=j, 3 do
	  local attrInfoLabel = GetLabel(nimbusRecastLayer,TAG_RECAST_ATTR_LIST[i]);
	  if CheckP(attrInfoLabel) then
	    attrInfoLabel:SetFontColor(ccc4(255, 255,255, 255));
	    attrInfoLabel:SetText("未激活");
	  end
	  local checkBox = RecursiveCheckBox(nimbusRecastLayer,{TAG_CHECK_BUTTON_LIST[i]});
	  if CheckP(checkBox) then
		checkBox:SetVisible(false);
		checkBox:SetSelect(false);
	  end
	end

	local activationBtn = GetButton(nimbusRecastLayer,ID_RECAST_CTRL_BUTTON_ACTIVATION1);
	if CheckP(activationBtn) then
	  if j >= 4 then
	    activationBtn:SetVisible(false);
	  else
		activationBtn:SetVisible(true);
	  end
	end	
	
	if j == 2 then
	  local checkBox = RecursiveCheckBox(nimbusRecastLayer,{TAG_CHECK_BUTTON_LIST[1]});
	  if CheckP(checkBox) then
		checkBox:SetVisible(false);
	  end
	end			
	
	local itemBtn = GetItemButton(nimbusRecastLayer,ID_RECAST_CTRL_OBJECT_BUTTON_SPIRIT);
	if CheckP(itemBtn) then
	  itemBtn:ChangeItem(selectItemId);
	end
  RefreshRecastCharge(nimbusRecastLayer,0); 
  end
end

function ShowNimbusInfo(itemId,nIsWear)
  selectItemId = itemId;
  selectPetId = GetCurPetId();
  isWear = nIsWear;
  local nimbusInfoLayer = GetNimbusInfoLayer();
  if CheckP(nimbusInfoLayer) then
	nimbusInfoLayer:SetVisible(true);
	
    local itemType = Item.GetItemInfoN(itemId, Item.ITEM_TYPE);
    local itemName = ItemFunc.GetName(itemType);
    local nQulity = ItemFunc.GetQuality(itemType);
 
	local itemNameLabel = GetLabel(nimbusInfoLayer,ID_SPIRIT_PROMPT_CTRL_TEXT_SPIRIT_NAME);
    if CheckP(itemNameLabel) then		
  	  itemNameLabel:SetFontColor(ItemUI.GetQLColor(itemType));  
	  itemNameLabel:SetText(itemName);
	end
	
	local j = 1;
	for i=1, 3 do
      local itemAttrLabel = GetLabel(nimbusInfoLayer,TAG_ATTR_LIST[j]);
	  if CheckP(itemAttrLabel) then
	    local nAttrType = ConvertN(ItemFunc.GetAttrType(itemId, i - 1));
		if nAttrType > Item.ATTR_TYPE_NONE then		
		  local str = GetAttrDec(nQulity,nAttrType,itemId,i-1);	  
		  itemAttrLabel:SetFontColor(ItemUI.GetQLValueColor(nQulity,nAttrType,itemId,i - 1));
		  itemAttrLabel:SetText(str);
		  j = j + 1;
		end
	  end
	end
	
	for i=j, 3 do
	  local itemAttrLabel = GetLabel(nimbusInfoLayer,TAG_ATTR_LIST[i]);
	  if CheckP(itemAttrLabel) then
	    itemAttrLabel:SetText("");
	  end
	end
	
	local itemWearButton = GetButton(nimbusInfoLayer,ID_SPIRIT_PROMPT_CTRL_BUTTON_WEAR_OR_TAKEOFF);
    if CheckP(itemWearButton) then		
	  itemWearButton:SetVisible(true);
	  if isWear then
		local weaponContainter = GetWeaponContainter();
		if CheckP(weaponContainter) then
		  local curPetView = weaponContainter:GetBeginView();
		  if CheckP(curPetView) then
			local weapSprite= RecursivUISprite(curPetView,{ID_WEAPON_CTRL_SPRITE_9});
			if CheckP(weapSprite) then
			  if weapSprite:IsVisibled() then
			    itemWearButton:SetTitle("装备");
			  else
			    itemWearButton:SetVisible(false);	
			  end
			end  
		  end
		end
	  else
		itemWearButton:SetTitle("卸下");
	  end 
	end	
	
	local itemBtn = GetItemButton(nimbusInfoLayer,ID_SPIRIT_PROMPT_CTRL_OBJECT_BUTTON_SPIRIT);
	if CheckP(itemBtn) then
	  itemBtn:ChangeItem(itemId);
	end

  end
end

function GetAttrDec(nQulity,nAttrType,itemId,index)
  local attrDec = "";
  local nVal = ConvertN(ItemFunc.GetAttrTypeVal(itemId, index));
  local desc = ItemFunc.GetAttrTypeDesc(nAttrType);
  local isPercent = false;
  if ItemFunc.IsPercent(nAttrType) then
    isPercent = true;
  end
  attrDec = desc.."+"..nVal;
  if isPercent then
    attrDec = attrDec.."%";
  end
  local partsGrowIdList = GetDataBaseIdList("parts_grow");
  for i, v in ipairs(partsGrowIdList) do
	local type = GetDataBaseDataN("parts_grow",v,DB_PARTS_GROW.TYPE);
	local attrType = GetDataBaseDataN("parts_grow",v,DB_PARTS_GROW.ATTR_TYPE);
	if type == nQulity and attrType == nAttrType then
	  local attrLow =GetDataBaseDataN("parts_grow",v,DB_PARTS_GROW.ATTR_LOW);
	  local attrTall =GetDataBaseDataN("parts_grow",v,DB_PARTS_GROW.ATTR_TALL);
	  if nVal == attrTall then
	    attrDec = attrDec .. "(满)";
	  else
		local attrLowStr = SafeN2S(attrLow);
	    local attrTallStr = SafeN2S(attrTall);
	    if isPercent then
          attrLowStr = attrLowStr.."%";
		  attrTallStr = attrTallStr.."%";
        end
	    attrDec = attrDec .. "("..attrLowStr.."-"..attrTallStr..")";
	  end
	  break;
	end
  end
  return attrDec;
end

function CloseRecastLayer()
  local nimbusRecastLayer = GetNimbusRecastLayer();
  if CheckP(nimbusRecastLayer) then
    nimbusRecastLayer:SetVisible(false);
  end
end

function CloseNimbusInfo()
  local nimbusInfoLayer = GetNimbusInfoLayer();
  if CheckP(nimbusInfoLayer) then
    nimbusInfoLayer:SetVisible(false);
  end
end

function GetPartsContainer()
  local scene = GetSMGameScene();
  if CheckP(scene) then
    local container = RecursiveSVC(scene, {NMAINSCENECHILDTAG.PlayerNimbusUI,TAG_NIMBUS_BG,ID_LOCK_SPIRIT_CTRL_VERTICAL_LIST_SPIRIT});
	return container;
  end
end

function GetPartsTag(i)
  if not CheckT(TAG_PARTS_LIST) or 0 == table.getn(TAG_PARTS_LIST) then
	return 0;
  end
  if i <= table.getn(TAG_PARTS_LIST) then
	return TAG_PARTS_LIST[i];
  end
  return 0;
end

function GetPetView(idPet)
  if not CheckN(idPet) then
	return nil;
  end
  local weaponContainter = GetWeaponContainter();
  if not CheckP(weaponContainter) then
	return nil;
  end
  return weaponContainter:GetViewById(idPet);
end

--从器灵装备删除一个物品(根据宠物id)
function p.DelInlayFrameWeap(idPet,idItem)
  if not CheckN(idPet) then
	return;
  end
  local petView = GetPetView(idPet);
  if CheckP(petView) then
    for i, v in ipairs(TAG_WEAPON_EQUIP_LIST) do
	  local weapButton = GetEquipButton(petView,v);
	  if CheckP(weapButton) and idItem == weapButton:GetItemId() then
	    weapButton:ChangeItem(0);
	  end
	end
  end  
end

--从器灵装备删除一个物品(根据武器id)
function p.DelInlayWeap(weapId,idItem)
  LogInfo("p.DelInlayWeap[%d][%d]",weapId,idItem);
  local weaponContainter = GetWeaponContainter();
  if CheckP(weaponContainter) then
    local nPlayerId = GetPlayerId();
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
	  LogInfo("nil == idTable");
	  return;
	end
	for i,v in ipairs(idTable) do
	  local weapId = ItemFunc.GetItemIdByPosition(ItemPet.GetEquipItemList(nPlayerId, v),Item.POSITION_EQUIP_2);
	  if weapId ~= 0 and weapId == weapId then
	    local petView = GetPetView(v);
		if CheckP(petView) then
		
		  local weapSprite = RecursivUISprite(petView,{ID_WEAPON_CTRL_SPRITE_9});
		  if CheckP(weapSprite) then
		    if weapSprite:IsVisibled() then
			  local idlist = ItemInlay.GetQiLinItemList(weapId);
			  local curFrame = table.getn(idlist) * aniSpace;
			  weapSprite:SetPlayFrameRange(curFrame + aniSpace,curFrame);
			end
		  end
				
		  for j, v in ipairs(TAG_WEAPON_EQUIP_LIST) do
			local weapButton = GetEquipButton(petView,v);
	        if CheckP(weapButton) and idItem == weapButton:GetItemId() then
			  weapButton:ChangeItem(0);
			  break;
	        end
		  end
		end
		break;
	  end
	end
  end
end

--从器灵装备添加一个物品(根据武器id)
function p.AddInlayWeap(weapId,idItem)
  LogInfo("p.AddInlayWeap[%d][%d]",weapId,idItem);
  local weaponContainter = GetWeaponContainter();
  if CheckP(weaponContainter) then
    local nPlayerId = GetPlayerId();
	local idTable = RolePetUser.GetPetListPlayer(nPlayerId);
	if nil == idTable then
	  LogInfo("nil == idTable");
	  return;
	end
	for i,v in ipairs(idTable) do
	  local weapId = ItemFunc.GetItemIdByPosition(ItemPet.GetEquipItemList(nPlayerId, v),Item.POSITION_EQUIP_2);
	  if weapId ~= 0 and weapId == weapId then	  
	    local petView = GetPetView(v);
		if CheckP(petView) then
		
		  local weapSprite = RecursivUISprite(petView,{ID_WEAPON_CTRL_SPRITE_9});
		  if CheckP(weapSprite) then
		    if weapSprite:IsVisibled() then
			  local idlist = ItemInlay.GetQiLinItemList(weapId);
			  local curFrame = table.getn(idlist) * aniSpace;
			  weapSprite:SetPlayFrameRange(curFrame - aniSpace,curFrame);
			end
		  end

		  local itemType = Item.GetItemInfoN(idItem,Item.ITEM_TYPE);
	      local index = Num6(itemType);
		  local weapButton = GetEquipButton(petView,TAG_WEAPON_EQUIP_LIST[index]); 
		  if CheckP(weapButton) then
		    weapButton:ChangeItem(idItem);
		  end		  
		end
		break;		
	  end
	end
  end
end

--从器灵背包删除一个物品
function p.DelItemFramePartsBag(idItem)
  LogInfo("p.DelItemFramePartsBag[%d]",idItem);
  local partsContainer = GetPartsContainer();
  if CheckP(partsContainer) then
    local view = partsContainer:GetViewById(partsBagViewId);
	if CheckP(view) then
	  for i, v in ipairs(TAG_PARTS_LIST) do
	    local itemButton = GetItemButton(view,v);
		if CheckP(itemButton) and idItem == itemButton:GetItemId() then
		  itemButton:ChangeItem(0);
		  break;
		end
	  end
	end
  end  
end

--添加一个物品到器灵背包
function p.AddItemToPartsBag(idItem)
  LogInfo("p.AddItemToPartsBag[%d]",idItem);
  local partsContainer = GetPartsContainer();
  if CheckP(partsContainer) then
    local view = partsContainer:GetViewById(partsBagViewId);
	if CheckP(view) then
	  for i, v in ipairs(TAG_PARTS_LIST) do
		local itemButton = RecursiveItemBtn(view, {v});
		if CheckP(itemButton) and 0 == itemButton:GetItemId() then
		  itemButton:ChangeItem(idItem);
		  break;
		end
	  end	
	end
  end  
end

function p.RefreshPartsBag()
   LogInfo("PlayerNimbusUI.RefreshPartsBag()");
   local partsContainer = GetPartsContainer();
   if CheckP(partsContainer) then
     local nPlayerId = ConvertN(GetPlayerId());
	 local idlistItem = ItemUser.GetQiLinItemList(nPlayerId);
	 local nSize = table.getn(idlistItem);
	 	 
	 local view = partsContainer:GetViewById(partsBagViewId);
	 if CheckP(view) then
	 
	   for i = 1, MAX_PARTS_NUM do
	     local nTag = GetPartsTag(i);
	     local itemBtn = GetItemButton(view, nTag);
	     if CheckP(itemBtn) then
		   local nItemId = 0;
		   if i <= nSize then
			 nItemId = idlistItem[i];
			 LogInfo("nItemId="..nItemId);
		   end
           itemBtn:ChangeItem(nItemId);
	     end
	   end
	   
	 end

   end
end

function GetPetNameContainer()
  local scene = GetSMGameScene();	
  if CheckP(scene) then
    local petNameContainer = RecursiveSVC(scene,{NMAINSCENECHILDTAG.PlayerNimbusUI,TAG_NIMBUS_BG,ID_LOCK_SPIRIT_CTRL_LIST_ROLE_NAME});
	return petNameContainer;
  end
end

function GetWeaponContainter()
  local scene = GetSMGameScene();	
  if CheckP(scene) then
    local weaponContainter = RecursiveSVC(scene,{NMAINSCENECHILDTAG.PlayerNimbusUI,TAG_NIMBUS_BG,ID_LOCK_SPIRIT_CTRL_LIST_WEAPON});
	return weaponContainter;
  end
end

function p.OnUIEvenWeap(uiNode, uiEventType, param) 
  local tag = uiNode:GetTag();
  LogInfo("p.OnUIEvenWeap[%d]", tag);
  local equipBtn = ConverToEquipBtn(uiNode);
  if CheckP(equipBtn) then
     if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	   local itemID = equipBtn:GetItemId();
	   if itemID ~= 0 then
		  ShowNimbusInfo(itemID,false);
	    else 
	      CloseNimbusInfo();	
	    end  
	 elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE_CLICK then
	   local itemID = equipBtn:GetItemId();
	   if itemID ~= 0 then
		  CloseNimbusInfo();
		  MsgItem.SendUnLoadSpirit(itemID,GetCurPetWeapId()); 
		  ShowLoadBar();
	   end 	  	
	 elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
	   local weapId = GetCurPetWeapId();
	   if weapId ~= 0 then
	     local itemID = equipBtn:GetItemId();
		 if itemID ~= 0 then
		   dragWeapId = weapId;
		   SetMouse(equipBtn:GetImageCopy(), param);
		 end
	   end	 
     elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
	   SetMouse(nil, SizeZero());
     elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
	   local weapId = GetCurPetWeapId();
	   if weapId ~= 0 then
		 local inItemBtn = ConverToItemButton(param);
		 local inEquipBtn = ConverToEquipBtn(param);
		 if CheckP(inItemBtn) and not CheckP(inEquipBtn) then
		   local itemId = inItemBtn:GetItemId();
		   if itemId ~= 0 then
			 MsgItem.SendLoadSpirit(inItemBtn:GetItemId(),weapId); 
		     ShowLoadBar();
		   end
		 end
		 
	   end
	 end
  end
  return true;
end

function p.OnUIEventMain(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  LogInfo("p.OnUIEventMain[%d]", tag);
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    if tag == ID_LOCK_SPIRIT_CTRL_BUTTON_4 then
	  CloseUI(NMAINSCENECHILDTAG.PlayerNimbusUI);
	  return true; 
	end
  end
  return true; 
end

function p.OnUIEventPartsBag(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  LogInfo("p.OnUIEventPartsBag[%d]", tag);
  local itemBtn = ConverToItemButton(uiNode);
  if CheckP(itemBtn) then
     if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	   local itemID = itemBtn:GetItemId();
	   if itemID ~= 0 then
		 ShowNimbusInfo(itemID,true);
	   else 
		 CloseNimbusInfo();	
	   end  
	 elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DOUBLE_CLICK then
	   local itemID = itemBtn:GetItemId();
	   local weapId = GetCurPetWeapId();
	    if itemID ~= 0 and weapId ~= 0 then
		  CloseNimbusInfo();
		  MsgItem.SendLoadSpirit(itemID,weapId); 
		  ShowLoadBar();
		end  
	 elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT then
	   local itemID = itemBtn:GetItemId();
	   if itemID ~= 0 then
	     SetMouse(itemBtn:GetImageCopy(), param);
	   end
     elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_OUT_COMPLETE then
	   SetMouse(nil, SizeZero());
     elseif uiEventType == NUIEventType.TE_TOUCH_BTN_DRAG_IN then
	   local equipBtn = ConverToEquipBtn(param);
	   if CheckP(equipBtn) then
	     local itemId = equipBtn:GetItemId();
		 if itemId ~= 0 and dragWeapId ~= 0 then
		   MsgItem.SendUnLoadSpirit(equipBtn:GetItemId(),dragWeapId); 
		   ShowLoadBar();
		 end
	   end	   
	 end
  end
  return true;
end

function p.OnUIEventViewChange(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  LogInfo("p.OnUIEventViewChange[%d]", tag);
  if uiEventType == NUIEventType.TE_TOUCH_SC_VIEW_IN_BEGIN then
    local containter = ConverToSVC(uiNode);
	local nPetId = 0;
	if CheckP(containter) and CheckN(param) then
	  local beginView = containter:GetView(param);
	  if CheckP(beginView) then
	    nPetId = beginView:GetViewId();
	  end
	end
	
	if not nPetId or nPetId <= 0 then
	  return;
	end
	if ID_LOCK_SPIRIT_CTRL_LIST_WEAPON == tag then
	  local petNameContainer = GetPetNameContainer();
	  if CheckP(petNameContainer) then
		 petNameContainer:ScrollViewById(nPetId);
	  end
	elseif ID_LOCK_SPIRIT_CTRL_LIST_ROLE_NAME == tag then	
	  local weaponContainter = GetWeaponContainter();
	  if CheckP(weaponContainter) then
		 weaponContainter:ScrollViewById(nPetId);
	  end
	end
	
  end
  return true;
end

function p.OnUIEventClickPetName(uiNode, uiEventType, param)
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    local view	= PRecursiveSV(uiNode, 1);
	if CheckP(view) then
	  local nPetId = ConvertN(view:GetViewId())
	  
	  local petNameContainer = GetPetNameContainer();
	  if CheckP(petNameContainer) then
		 petNameContainer:ScrollViewById(nPetId);
	  end
	  
	  local weaponContainter = GetWeaponContainter();
	  if CheckP(weaponContainter) then
		 weaponContainter:ScrollViewById(nPetId);
	  end
	  
	end
  end
  return true;  
end

function GetCurPetWeapId()
  local weapId = 0;
  local curPetId = GetCurPetId();
  if curPetId ~= 0 then
    weapId = ItemFunc.GetItemIdByPosition(ItemPet.GetEquipItemList(GetPlayerId(), curPetId),Item.POSITION_EQUIP_2);
  end
  return weapId;
end

function p.OnUIEventNimbusInfo(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  LogInfo("p.OnUIEventNimbusInfo[%d]", tag);
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
	if tag == ID_SPIRIT_PROMPT_CTRL_BUTTON_CLOSE then
	  CloseNimbusInfo();
	elseif tag == ID_SPIRIT_PROMPT_CTRL_BUTTON_8 then
	  CloseNimbusInfo();
	  ShowRecastLayer();
	elseif tag == ID_SPIRIT_PROMPT_CTRL_BUTTON_WEAR_OR_TAKEOFF then	
	  CloseNimbusInfo();
	  local weapId = ItemFunc.GetItemIdByPosition(ItemPet.GetEquipItemList(GetPlayerId(), selectPetId),Item.POSITION_EQUIP_2);
	  if weapId ~= 0 then
		if isWear then 
		  MsgItem.SendLoadSpirit(selectItemId,weapId); 
	    else
		  MsgItem.SendUnLoadSpirit(selectItemId,weapId); 
	    end
		ShowLoadBar();
	  end	  
	elseif tag == ID_SPIRIT_PROMPT_CTRL_BUTTON_SELL then
	  CloseNimbusInfo();
	  local itemType = Item.GetItemInfoN(selectItemId,Item.ITEM_TYPE);
      local itemName = ItemFunc.GetName(itemType);
	  local nQulity = ItemFunc.GetQuality(itemType);
	  CommonDlg.ShowNoPrompt("买出"..itemName.."获得"..sellMoney[nQulity].."铜钱和"..sellLiQi[nQulity].."个器灵碎片", p.OnCommonDlg,true); 
	end
  end
  return true;
end

function GetCurPetId()
  local weaponContainter = GetWeaponContainter();
  local curPetView = weaponContainter:GetBeginView(); 
  if CheckP(curPetView) then
    return curPetView:GetViewId();
  end
  return 0;
end

function p.OnCommonDlg(nId, nEvent, param)
  if nEvent == CommonDlg.EventOK then
	MsgNimbus.SendNimbusAction(MsgNimbus.PARTS_MSG_SELL_PARTS,selectItemId,0,0);	
  end
end

function GetRecastStr()
  local recastStr = "";
  local nimbusRecastLayer = GetNimbusRecastLayer();
  if CheckP(nimbusRecastLayer) then
    local promptLable = GetLabel(nimbusRecastLayer,ID_RECAST_CTRL_TEXT_PROMPT);
	if CheckP(promptLable) then
	  if promptLable:GetText() ~= nill then
	    recastStr = promptLable:GetText();
	  end 
    end
  end 
  return recastStr; 
end

function p.OnUIEventRecast(uiNode, uiEventType, param)
  local tag = uiNode:GetTag();
  LogInfo("p.OnUIEventRecast[%d]", tag);
  if uiEventType == NUIEventType.TE_TOUCH_BTN_CLICK then
    if tag == ID_RECAST_CTRL_BUTTON_CLOSE then
	  CloseRecastLayer();
	elseif tag == ID_RECAST_CTRL_BUTTON_RECAST then
	  CommonDlg.ShowNoPrompt(GetRecastStr(), p.OnRecastDlg,true);
	  CloseRecastLayer();
	elseif tag == ID_RECAST_CTRL_BUTTON_ACTIVATION1 then
	  CommonDlg.ShowNoPrompt("激活阵眼需花费20元宝", p.OnEyesEnableDlg,true); 
	end	
  elseif uiEventType == NUIEventType.TE_TOUCH_CHECK_CLICK then
    for i, v in ipairs(TAG_CHECK_BUTTON_LIST) do
	  if tag == v then
	    local nimbusRecastLayer = GetNimbusRecastLayer();
		if CheckP(nimbusRecastLayer) then
		  local choiseAmount = 0;
		  choseTarget = {false,false,false};
		  for j, v in ipairs(TAG_CHECK_BUTTON_LIST) do
		    local checkBox = RecursiveCheckBox(nimbusRecastLayer,{TAG_CHECK_BUTTON_LIST[j]});
			if CheckP(checkBox) then
			  if checkBox:IsSelect() then
			    choiseAmount = choiseAmount + 1;
				choseTarget[j] = true;
			  end	
			end
		  end
		  LogInfo("choiseAmount="..choiseAmount);
		  local attrAmount = 0;
		  for j=1, 3 do
		    local nAttrType = ConvertN(ItemFunc.GetAttrType(selectItemId, j - 1));
			if nAttrType > Item.ATTR_TYPE_NONE then
			  attrAmount = attrAmount + 1;
			end
		  end
		  LogInfo("attrAmount="..attrAmount);
		  if attrAmount - choiseAmount <= 1 then
		    for j=1,attrAmount do
			  if not choseTarget[j] then
			    local checkBox = RecursiveCheckBox(nimbusRecastLayer,{TAG_CHECK_BUTTON_LIST[j]});
				if CheckP(checkBox) then
				  checkBox:SetVisible(false);
				end
			  end
		    end
		  else
		    for j=1,attrAmount do
			  if not choseTarget[j] then
			    local checkBox = RecursiveCheckBox(nimbusRecastLayer,{TAG_CHECK_BUTTON_LIST[j]});
				if CheckP(checkBox) then
				  checkBox:SetVisible(true);
				end
			  end
		    end
		  end
		  RefreshRecastCharge(nimbusRecastLayer,choiseAmount);
		end
	    break;
	  end
	  
	end 
  end
  return true;
end

function RefreshRecastCharge(nimbusRecastLayer,choiseAmount)
  local promptLable = GetLabel(nimbusRecastLayer,ID_RECAST_CTRL_TEXT_PROMPT);
  if CheckP(promptLable) then
    local promptStr = "";
    local nPlayerId = GetPlayerId();
	--免费锻造数
	local usPartsCastCount = GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_STAMINA_CAST_COUNT);
	if usPartsCastCount > 0 then
	  promptStr = "还可以免费重铸"..usPartsCastCount.."次";
	else
      promptStr = "本次重铸将消耗";
	  local itemType = Item.GetItemInfoN(selectItemId, Item.ITEM_TYPE);
	  local nQulity = ItemFunc.GetQuality(itemType);
	  --玩家灵气值
	  local chips = GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_STAMINA_PARTS_CHIPS);	
	  local needChips = CHIPS_LIST[nQulity] + choiseAmount * CHIPS_LIST[nQulity];
	  local needMoney = 10000 + choiseAmount * 10000;
	  local trueChips = needChips;
	  if chips < needChips then
	    trueChips = chips; 
	  end
	  if trueChips > 0 then
	    promptStr = promptStr..trueChips.."个器灵碎片,";
	  end
	  if chips < needChips then
	    promptStr = promptStr..((needChips - chips) * 10).."元宝,";
	  end
	  promptStr = promptStr..needMoney.."铜钱";  
	end	
    promptLable:SetText(promptStr);
  end  
end

function p.OnEyesEnableDlg(nId, nEvent, param)
  if nEvent == CommonDlg.EventOK then
	MsgNimbus.SendNimbusAction(MsgNimbus.PARTS_MSG_EYES_ENABLE,selectItemId,0,0);
  end
end

function p.OnRecastDlg(nId, nEvent, param)
  if nEvent == CommonDlg.EventOK then
   local btLockAttr = 0;
   for i, v in ipairs(choseTarget) do
     if v then
	   btLockAttr = btLockAttr + LeftShift(1,i-1);  
	 end
   end
	MsgNimbus.SendNimbusAction(MsgNimbus.PARTS_MSG_CAST_PARTS,selectItemId,btLockAttr,0);
  end
end



