
AffixBossEliteMapList = {}
local p = AffixBossEliteMapList 


p.mEliteMapIds = {
5,
6,
7,
};

p.mEliteMapIds2 = {
4,
6,
7,
};

 
function p.getEliteMaps()
	local camp = PlayerFunc.GetPlayerCamp();
	if (camp == 1) then
		return p.mEliteMapIds
	else
		return p.mEliteMapIds2;
	end
end

function p.getIndex(id)
	local ids = p.getEliteMaps();
	for i = 1, #ids do
		if ids[i] == id then
			return i;
		end
	end
	
	return 0
	
end

function p.getIdByIndex(index)
	if not index then
		return nil;
	end
	local ids = p.getEliteMaps();
	return ids[index];
end

function p.getGroupByMapId(mapId)
	if (mapId == 5) then
		return 4;
	else
		return mapId;
	end
end

function p.getMapIdByGroup(group)
	if (group == 4) then
		local camp = PlayerFunc.GetPlayerCamp();
		if (camp == 1) then
			return 4
		else
			return 5;
		end
	else
		return group;
	end
end

