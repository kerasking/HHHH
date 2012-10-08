---------------------------------------------------
--描述: 镶嵌类(子)物品
--时间: 2012.3.1
--作者: jhzheng
--注:   这里的物品都是归属于物品(Item.OWNER_TYPE_ITEM)
---------------------------------------------------

ItemInlay = {};
local p = ItemInlay;

local eQiLinItem					= 0; --器灵物品

--器灵物品(Item.POSITION_PARTS_1 ~ Item.POSITION_PARTS_6)
function p.AddQiLinItem(nOwnerItemId, nItemId)
	p.AddItem(nOwnerItemId, nItemId, eQiLinItem);
end

function p.DelQiLinItem(nOwnerItemId, nItemId)
	p.DelItem(nOwnerItemId, nItemId, eQiLinItem);
end

function p.GetQiLinItemList(nOwnerItemId)
	return p.GetItemList(nOwnerItemId, eQiLinItem);
end

--内部接口
function p.AddItem(nOwnerItemId, nItemId, e)
	if	not CheckN(nOwnerItemId) or
		not CheckN(nItemId) or
		not CheckN(e) then
		return;
	end

	if not Item.IsExistItem(nOwnerItemId) then
		return;
	end
	
	_G.AddRoleDataId(NScriptData.eItemInfo, nOwnerItemId, NRoleData.eItem, 0, e, nItemId);
end

function p.DelItem(nOwnerItemId, nItemId, e)
	if	not CheckN(nOwnerItemId) or
		not CheckN(nItemId) or
		not CheckN(e) then
		return;
	end

	if not Item.IsExistItem(nOwnerItemId) then
		return;
	end
	
	_G.DelRoleDataId(NScriptData.eItemInfo, nOwnerItemId, NRoleData.eItem, 0, e, nItemId);
end

function p.GetItemList(nOwnerItemId, e)
	local idlist = {};
	if	not CheckN(nOwnerItemId) or
		not CheckN(e) then
		return idlist;
	end
	idlist = _G.GetRoleDataIdTable(NScriptData.eItemInfo, nOwnerItemId, NRoleData.eItem, 0, e);
	if not idlist then
		idlist = {};
	end
	return idlist;
end