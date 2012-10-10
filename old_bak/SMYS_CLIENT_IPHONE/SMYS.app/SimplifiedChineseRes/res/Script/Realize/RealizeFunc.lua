-- func
-- wjl

local _G = _G

RealizeFunc = {}
local f = RealizeFunc;

--local database
function f.GetDataBaseN(nPriV, nIndex)
	return _G.ConvertN(_G.GetDataBaseDataN("martial_config", nPriV, nIndex));
end

function f.GetDataBaseS(nPriV, nIndex)
	return _G.ConvertS(_G.GetDataBaseDataS("martial_config", nPriV, nIndex));
end


function f.getColorByQut(nQut)
	
	if CheckN(nQut) then
		if (nQut == 0) then
			return ccc4(128, 128, 128, 255), "808080";
		elseif (nQut == 1) then
			return ccc4(255,0,0,255), "ff0000";
		elseif (nQut == 2) then
			return ccc4(0, 255, 0, 255), "00ff00";
		elseif (nQut == 3) then
			return ccc4(0, 0, 255, 255), "0000ff";
		elseif (nQut == 4) then
			return ccc4(227, 69, 237, 255), "e345ed";
		elseif (nQut == 5) then
			return ccc4(253, 246, 57, 255), "fdf639";
		end
	end
	
	return ccc4(255,255,255,255), "ffffff";
end