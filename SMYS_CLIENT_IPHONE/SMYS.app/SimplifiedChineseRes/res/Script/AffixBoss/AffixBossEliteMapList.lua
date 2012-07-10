
AffixBossEliteMapList = {}
local p = AffixBossEliteMapList 


p.mEliteMapIds = {
4,
5,
6,
7,
};
 
function p.getEliteMaps()
	return p.mEliteMapIds;
end

function p.getIndex(id)
	for i = 1, #p.mEliteMapIds do
		if p.mEliteMapIds[i] == id then
			return i;
		end
	end
	
	return 0
	
end

function p.getIdByIndex(index)
	if not index then
		return nil;
	end
	return p.mEliteMapIds[index];
end


