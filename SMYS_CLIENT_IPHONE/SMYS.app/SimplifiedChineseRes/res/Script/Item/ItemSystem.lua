---------------------------------------------------
--描述: 系统类物品
--时间: 2012.3.1
--作者: jhzheng
--注:   这里的物品都是归属于系统,不属于任务角色
---------------------------------------------------

ItemSystem = {};
local p = ItemSystem;

local	eSold						= 0;	--已售出的物品
local	eMail						= 1;	--邮件物品

--已售出物品(Item.POSITION_SOLD)
function p.AddSoldItem(nItemId)
	p.AddItem(nItemId, eSold);
end

function p.DelSoldItem(nItemId)
	p.DelItem(nItemId, eSold);
end

function p.GetSoldItemList(nItemId)
	return p.GetItemList(nItemId, eSold);
end

--邮件物品(Item.POSITION_MAIL)
function p.AddMailItem(nItemId)
	p.AddItem(nItemId, eMail);
end

function p.DelMailItem(nItemId)
	p.DelItem(nItemId, eMail);
end

function p.GetMailItemList(nItemId)
	return p.GetItemList(nItemId, eMail);
end

--内部接口
function p.AddItem(nItemId, e)
	if	not CheckN(nItemId) or
		not CheckN(e) then
		return;
	end
	
	_G.AddRoleDataId(NScriptData.eSysItem, 0, NRoleData.eItem, 0, e, nItemId);
end

function p.DelItem(nItemId, e)
	if	not CheckN(nItemId) or
		not CheckN(e) then
		return;
	end
	
	_G.DelRoleDataId(NScriptData.eSysItem, 0, NRoleData.eItem, 0, e, nItemId);
end

function p.GetItemList(e)
	local idlist = {};
	if	not CheckN(e) then
		return idlist;
	end
	idlist = _G.GetRoleDataIdTable(NScriptData.eSysItem, 0, NRoleData.eItem, 0, e);
	return idlist;
end