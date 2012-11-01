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

-- rtn{1=petId,2=petId,3=petId ... 9=petId} 无则0
function f.GetCurrentMatrix()
	local nPlayerId = GetPlayerId();
	local id = GetRoleBasicDataN(nPlayerId, USER_ATTR.USER_ATTR_MATRIX);
	local rtn  = f.findMatrixById(id);
	return rtn;
end

-- private 
function f.findMatrixById(nId)
	local lst, count = MsgMagic.getRoleMatrixList();
	for i = 1, count do
		if (lst and lst[i].id == nId) then
			return lst[i];
		end
	end
end

function f.getEmoneyForCleanCoolDown(time)
	if (time < 30) then
		return 2;
	elseif (time < 10*60) then
		return 5;
	elseif (time < 30*60) then
		return 10;
	else
		return 10 + math.ceil((time - 30* 60) / (15 * 60)) * 5
	end
end

--** chh 2012-06-18 判断武将是否在出战列表中 **--
function f.ifIsInMatrix(petId)
    local lst, count    = MsgMagic.getRoleMatrixList();
	local CurrentMatrix    = lst[1];
        
    if CurrentMatrix == nil then
        LogInfo("错误：玩家没有阵型！");
        return false;
    end 

    for i = 1, #CurrentMatrix do
        if(CurrentMatrix[i] == petId) then
            return true;
        end
    end
    return false;
end

