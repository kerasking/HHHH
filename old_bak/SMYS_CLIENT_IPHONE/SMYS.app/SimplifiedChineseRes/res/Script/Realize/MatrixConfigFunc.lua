-- func
-- wjl

local _G = _G

MatrixConfigFunc = {}
local f = MatrixConfigFunc;

--local database
function f.GetDataBaseN(nPriV, nIndex)
	return _G.ConvertN(_G.GetDataBaseDataN("matrix_config", nPriV, nIndex));
end

function f.GetDataBaseS(nPriV, nIndex)
	return _G.ConvertS(_G.GetDataBaseDataS("matrix_config", nPriV, nIndex));
end

function f.GetUpLevelN(nPriV, nIndex)
	return _G.ConvertN(_G.GetDataBaseDataN("matrix_up_level", nPriV, nIndex));
end

function f.GetUpLevelS(nPriV, nIndex)
	return _G.ConvertS(_G.GetDataBaseDataS("matrix_up_level", nPriV, nIndex));
end