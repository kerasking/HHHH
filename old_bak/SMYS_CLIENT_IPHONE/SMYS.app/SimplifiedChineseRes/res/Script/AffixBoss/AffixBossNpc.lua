


----  不再使用
AffixBossNpc = {}
p = AffixBossNpc;

-- nGroup 
function p.findNpc(nGroup)
	if not CheckN(nGroup) then
		return 10099
	end
    if nGroup == 1 then
       return 10099
     elseif nGroup == 2 then
        return 20099
     elseif nGroup == 3 then
        return 30099
     elseif nGroup == 4 then
        return 40099
     elseif nGroup == 5 then
        return 60099  
     elseif nGroup == 6 then
        return 70099                                 
     end
     return 10099
end


