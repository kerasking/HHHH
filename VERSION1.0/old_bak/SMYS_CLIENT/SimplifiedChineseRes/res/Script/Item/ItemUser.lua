---------------------------------------------------
--描述: 玩家物品
--时间: 2012.3.1
--作者: jhzheng
--注:  这里的物品统一归属于玩家的各种背包中(Item.OWNER_TYPE_USER)
---------------------------------------------------
ItemUser = {};
local p = ItemUser;

local	eTypeBegin				= 0;
local	eBagItem					= eTypeBegin;		--背包
local	eQiLinItem					= 1					--器灵背包
local	eDaoFaItem					= 2;				--道法背包
local	eStorageItem				= 3;				--仓库
local	eTypeEnd					= eStorageItem;

--物品背包(Item.POSITION_PACK = 1)
function p.AddBagItem(nRoleId, nItemId)
	p.AddItem(eBagItem, nRoleId, nItemId);
end

function p.DelBagItem(nRoleId, nItemId)
	p.DelItem(eBagItem, nRoleId, nItemId);
end

function p.GetBagItemList(nRoleId)
	return p.GetItemList(eBagItem, nRoleId);
end

function p.BagHasItem(nRoleId, nItemId)
	local idlist	= p.GetBagItemList(nRoleId);
	if not CheckT(idlist) or 0 == table.getn(idlist) then
		return false;
	end
	
	for i, v in ipairs(idlist) do
		if v == nItemId then
			return true;
		end
	end
	
	return false;
end

--器灵背包(Item.POSITION_PARTS_PACK = 1)
function p.AddQiLinItem(nRoleId, nItemId)
	p.AddItem(eQiLinItem, nRoleId, nItemId);
end

function p.DelQiLinItem(nRoleId, nItemId)
	p.DelItem(eQiLinItem, nRoleId, nItemId);
end

function p.GetQiLinItemList(nRoleId)
	return p.GetItemList(eQiLinItem, nRoleId);
end

--道法背包(Item.POSITION_DAO_FA_PACK = 3)
function p.AddDaoFaItem(nRoleId, nItemId)
	p.AddItem(eDaoFaItem, nRoleId, nItemId);
end

function p.DelDaoFaItem(nRoleId, nItemId)
	p.DelItem(eDaoFaItem, nRoleId, nItemId);
end

function p.GetDaoFaItemList(nRoleId)
	return p.GetItemList(eDaoFaItem, nRoleId);
end

--仓库(Item.POSITION_STORAGE = 4)
function p.AddStorageItem(nRoleId, nItemId)
	p.AddItem(eStorageItem, nRoleId, nItemId);
end

function p.DelStorageItem(nRoleId, nItemId)
	p.DelItem(eStorageItem, nRoleId, nItemId);
end

function p.GetStorageItemList(nRoleId)
	return p.GetItemList(eStorageItem, nRoleId);
end

--[[
--邮件物品(Item.POSITION_MAIL	= 92)
function p.AddMailItem(nRoleId, nItemId)
	p.AddItem(eMail, nRoleId, nItemId);
end

function p.DelMailItem(nRoleId, nItemId)
	p.DelItem(eMail, nRoleId, nItemId);
end

function p.GetMailItemList(nRoleId)
	return p.GetItemList(eMail, nRoleId);
end

--系统赠品(Item.POSITION_SYSTEM = 93)
function p.AddSysGiveItem(nRoleId, nItemId)
	p.AddItem(eSysGive, nRoleId, nItemId);
end

function p.DelSysGiveItem(nRoleId, nItemId)
	p.DelItem(eSysGive, nRoleId, nItemId);
end

function p.GetSysGiveItemList(nRoleId)
	return p.GetItemList(eSysGive, nRoleId);
end

--已售物品(Item.POSITION_SOLD = 100)
function p.AddSoldItem(nRoleId, nItemId)
	p.AddItem(eSold, nRoleId, nItemId);
end

function p.DelSoldItem(nRoleId, nItemId)
	p.DelItem(eSold, nRoleId, nItemId);
end

function p.GetSoldItemList(nRoleId)
	return p.GetItemList(eSold, nRoleId);
end
--]]
--内部接口
function p.AddItem(e, nRoleId, nItemId)
	if	not CheckN(nRoleId) or
		not CheckN(nItemId) or
		not CheckN(e) then
		return;
	end 
	
	if e < eTypeBegin or e > eTypeEnd then
		return;
	end
	
	_G.AddRoleDataId(NScriptData.eRole, nRoleId, NRoleData.eItem, 0, e, nItemId);
end

function p.DelItem(e, nRoleId, nItemId)
	if	not CheckN(nRoleId) or
		not CheckN(nItemId) or
		not CheckN(e) then
		return;
	end
	
	if e < eTypeBegin or e > eTypeEnd then
		return;
	end
	
	_G.DelRoleDataId(NScriptData.eRole, nRoleId, NRoleData.eItem, 0, e, nItemId);
end

function p.GetItemList(e, nRoleId)
	local idlist = {};
	if	not CheckN(nRoleId) or
		not CheckN(e) then
		return idlist;
	end
	
	if e < eTypeBegin or e > eTypeEnd then
		return;
	end
	
	idlist = _G.GetRoleDataIdTable(NScriptData.eRole, nRoleId, NRoleData.eItem, 0, e);
	return idlist;
end