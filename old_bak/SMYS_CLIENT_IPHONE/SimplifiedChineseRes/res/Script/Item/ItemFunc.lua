---------------------------------------------------
--描述: 物品通用的一些接口
--时间: 2012.3.5
--作者: jhzheng
---------------------------------------------------
ItemFunc = {};
local p = ItemFunc;

--ItemType表接口
function p.GetName(nItemType)
	local str	= "";
	if CheckN(nItemType) then
		str		= GetDataBaseDataS("itemtype", nItemType, DB_ITEMTYPE.NAME);
	end
	return ConvertS(str);
end

function p.GetQuality(nItemType)
	local nQuality	= 0;
	if CheckN(nItemType) then
		nQuality	= Num1(nItemType);
	end
	return nQuality;
end

function p.GetDesc(nItemType)
	local str	= "";
	if CheckN(nItemType) then
		str		= GetDataBaseDataS("itemtype", nItemType, DB_ITEMTYPE.DESCRIPT);
	end
	return ConvertS(str);
end

function p.GetJobReq(nItemType)
	local nJobReq	= 0;
	if CheckN(nItemType) then
		nJobReq	= Num4(nItemType);
	end
	return nJobReq;
end

function p.GetLvlReq(nItemType)
	local nRes	= 0;
	if CheckN(nItemType) then
		nRes	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.REQ_LEVEL);
	end
	return ConvertN(nRes);
end

function p.CanChaiFen(nItemType)
	local nRes	= 0;
	if CheckN(nItemType) then
		nRes	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.AMOUNT_LIMIT);
	end
	if nRes > 1 then
		return true;
	end
	return false;
end

function p.GetPrice(nItemType)
	local nRes	= 0;
	if CheckN(nItemType) then
		nRes	= GetDataBaseDataN("itemtype", nItemType, DB_ITEMTYPE.PRICE);
	end
	return ConvertN(nRes);
end

function p.CanEquip(nItemId)
	if not CheckN(nItemId) then
		return false;
	end
	local nItemType = Item.GetItemInfoN(nItemId, Item.ITEM_TYPE);
	return p.CanEquipByItemType(nItemType);
end

function p.CanEquipByItemType(nItemType)
	if not CheckN(nItemType) then
		return false;
	end
	
	if 0 == Num8(nItemType) and 1 == Num7(nItemType) then
		return true;
	end
	
	return false;
end

function p.GetType(nItemType)
	if not CheckN(nItemType) then
		return Item.TypeInvalid;
	end
	
	local nNum8 = Num8(nItemType);
	local nNum7 = Num7(nItemType);
	
	if 0 == nNum8 then
	--可装备类
		if 1 == nNum7 then
		--装备
			return Item.TypeEquip;
		elseif 2 == nNum7 then
		--器灵
			return Item.TypeQiLing;
		elseif 3 == nNum7 then
		--道法
			return Item.TypeDaoFa;
		end
	elseif 1 == nNum8 then
	--坐骑
		return Item.TypeRide;
	elseif 2 == nNum8 then
	--普通物品
		if 1 == nNum7 or 
			2 == nNum7 or
			3 == nNum7 then
		--消耗类物品(回复药,丹药,变身卷轴)
			return Item.TypeConsume;
		elseif 4 == nNum7 then
		--玉牌
			return Item.TypeNone;
		elseif 5 == nNum7 then
		--材料
			return Item.TypeNone;
		end
	elseif 3 == nNum8 then
	--合成卷
		return Item.TypeComposeRoll;
	elseif 4 == nNum8 then
	--任务物品
		return Item.TypeQuest;
	elseif 5 == nNum8 then
	--礼包
		return Item.TypeGift;
	end
	
	return Item.TypeInvalid;
end

--获取装备每次升级增加的属性内容(attr_type_1,attr_value_1,attr_grow_1,...)
function p.GetAttrTypeAndValueAndGrow(itemTypeId)
	local attr_type_1,attr_value_1,attr_grow_1,
	      attr_type_2,attr_value_2,attr_grow_2,
		  attr_type_3,attr_value_3,attr_grow_3;
		  
	if CheckN(itemTypeId) then
		attr_type_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_1);
		attr_value_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_1);
		attr_grow_1 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_1);
		
		attr_type_2 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_2);
		attr_value_2 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_2);
		attr_grow_2 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_2);
		
		attr_type_3 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_TYPE_3);
		attr_value_3 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_VALUE_3);
		attr_grow_3 = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ATTR_GROW_3);
	end
	return attr_type_1,attr_value_1,attr_grow_1,
		   attr_type_2,attr_value_2,attr_grow_2,
		   attr_type_3,attr_value_3,attr_grow_3;
end

function p.GetEnhancedId(itemTypeId)
	local nId;
	if CheckN(itemTypeId) then
		nId = GetDataBaseDataN("itemtype", itemTypeId, DB_ITEMTYPE.ENHANCED_ID);
	end
	return nId;
end


--物品接口
--获取第N个物品属性(N从0开始)
function p.GetAttrType(nItemId, nIndex)
	if not CheckN(nItemId) or
		not CheckN(nIndex) then
		return 0;
	end
	
	return Item.GetItemInfoN(nItemId, Item.ITEM_ATTR_BEGIN + nIndex * 2);
end

--获取第N个物品属性值(N从0开始)
function p.GetAttrTypeVal(nItemId, nIndex)
	if not CheckN(nItemId) or
		not CheckN(nIndex) then
		return 0;
	end
	
	return Item.GetItemInfoN(nItemId, Item.ITEM_ATTR_BEGIN + nIndex * 2 + 1);
end

function p.GetItemCount(nItemType)
	if not CheckN(nItemType) then
		return 0;
	end
	
	local idlist = _G.ItemUser.GetBagItemList(GetPlayerId());
	local nCount = 0;
	
	local bCanChiFen	= p.CanChaiFen(nItemType);
	
	for i, v in ipairs(idlist) do
		local n = Item.GetItemInfoN(v, Item.ITEM_TYPE);
		if n == nItemType then
			if bCanChiFen then
				nCount = nCount + Item.GetItemInfoN(v, Item.ITEM_AMOUNT);
			else
				nCount = nCount + 1;
			end
		end
		
	end
	
	return nCount;
end

function p.GetStorageItemCount(nItemType)
	if not CheckN(nItemType) then
		return 0;
	end
	
	local idlist = _G.ItemUser.GetStorageItemList(GetPlayerId());
	local nCount = 0;
	
	local bCanChiFen	= p.CanChaiFen(nItemType);
	
	for i, v in ipairs(idlist) do
		local n = Item.GetItemInfoN(v, Item.ITEM_TYPE);
		if n == nItemType then
			if bCanChiFen then
				nCount = nCount + Item.GetItemInfoN(v, Item.ITEM_AMOUNT);
			else
				nCount = nCount + 1;
			end
		end
		
	end
	
	return nCount;
end

function p.IsBackBagFull()
	local idlist = ItemUser.GetBagItemList(GetPlayerId());
	return table.getn(idlist) >= _G.GetRoleBasicDataN(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_PACKAGE_LIMIT);
end

function p.getBackBagItemCount()
	local idlist = ItemUser.GetBagItemList(GetPlayerId());
	local count = 0;
	if idlist then
		count = #idlist;
	end
	return count;
end

function p.getBackBagCapability()
	return _G.GetRoleBasicDataN(_G.GetPlayerId(), _G.USER_ATTR.USER_ATTR_PACKAGE_LIMIT);
end


--其它接口
function p.GetAttrTypeDesc(nAttr)
	local str = "";
	if not CheckN(nAttr) then
		return str;
	end
	
	if nAttr == Item.ATTR_TYPE_PHY then
		str = "武力";
	elseif nAttr == Item.ATTR_TYPE_SKILL then
		str = "绝技";
	elseif nAttr == Item.ATTR_TYPE_MAGIC then
		str = "法术";
	elseif nAttr == Item.ATTR_TYPE_LIFE then
		str = "生命";
	elseif nAttr == Item.ATTR_TYPE_LIFE_LIMIT then
		str = "生命上限";
	elseif nAttr == Item.ATTR_TYPE_MANA then
		str = "气势";
	elseif nAttr == Item.ATTR_TYPE_MANA_LIMIT then
		str = "气势上限";
	elseif nAttr == Item.ATTR_TYPE_PHY_ATK then
		str = "普通攻击";
	elseif nAttr == Item.ATTR_TYPE_SKILL_ATK then
		str = "绝技攻击";
	elseif nAttr == Item.ATTR_TYPE_MAGIC_ATK then
		str = "法术攻击";
	elseif nAttr == Item.ATTR_TYPE_PHY_DEF then
		str = "普通防御";
	elseif nAttr == Item.ATTR_TYPE_SKILL_DEF then
		str = "绝技防御";
	elseif nAttr == Item.ATTR_TYPE_MAGIC_DEF then
		str = "法术防御";
	elseif nAttr == Item.ATTR_TYPE_DRITICAL then
		str = "暴击";
	elseif nAttr == Item.ATTR_TYPE_HITRATE then
		str = "命中";
	elseif nAttr == Item.ATTR_TYPE_WRECK then
		str = "破击";
	elseif nAttr == Item.ATTR_TYPE_HURT_ADD then
		str = "必杀";
	elseif nAttr == Item.ATTR_TYPE_TENACITY then
		str = "韧性";
	elseif nAttr == Item.ATTR_TYPE_DODGE then
		str = "闪避";
	elseif nAttr == Item.ATTR_TYPE_BLOCK then
		str = "格挡";
	end
	return str;
end

--根据位置获得物品id(传入物品列表和位置索引)
function p.GetItemIdByPosition(idlist,nPosition)
   for i, v in ipairs(idlist) do
     local position = Item.GetItemInfoN(v,Item.ITEM_POSITION);
	 if position == nPosition then
	   return v;
	 end
   end
   return 0;
end

function p.IsPercent(nAttr)
  local isPercent = false;
  if nAttr == Item.ATTR_TYPE_DRITICAL 
     or nAttr == Item.ATTR_TYPE_TENACITY 
	 or nAttr == Item.ATTR_TYPE_HITRATE
	 or nAttr == Item.ATTR_TYPE_DODGE
	 or nAttr == Item.ATTR_TYPE_WRECK
	 or nAttr == Item.ATTR_TYPE_BLOCK
	 or nAttr == Item.ATTR_TYPE_HURT_ADD  then
    isPercent = true;
  end
  return isPercent;
end