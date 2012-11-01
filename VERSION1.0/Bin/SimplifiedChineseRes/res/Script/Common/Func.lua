--** chh 2012-7-2 **--
--开启随机
math.randomseed(os.time());

function LogInfo(fmt, ...)
    LuaLogInfo(string.format(fmt, unpack(arg)));
end

function LogError(fmt, ...)
    LuaLogError(string.format(fmt, unpack(arg)));
end

function SafeS2N(str)
	if nil == str or type(str) ~= "string" then
		return 0;
	end
	local n = tonumber(str);
	if nil == n then
		return 0;
	end
	return n;
end

function SafeN2S(n)
	if nil == n or type(n) ~= "number" then
		return "";
	end
	local str = tostring(n);
	if nil == str then
		return "";
	end
	return str;
end

function ConvertN(n)
	if nil == n or type(n) ~= "number" then
		return 0;
	end
	return n;
end

function ConvertS(s)
	if nil == s or type(s) ~= "string" then
		return "";
	end
	return s;
end

function CheckN(n)
	if nil == n or type(n) ~= "number" then
		return false;
	end
	return true;
end

function CheckS(s)
	if nil == s or type(s) ~= "string" then
		return false;
	end
	return true;
end

function CheckT(t)
	if nil == t or type(t) ~= "table" then
		return false;
	end
	return true;
end

function CheckB(b)
	if nil == b or type(b) ~= "boolean" then
		return false;
	end
	return true;
end

function CheckFunc(func)
	if nil == func or type(func) ~= "function" then
		return false;
	end
	return true;
end

function CheckP(pointer)
	if nil == pointer or type(pointer) ~= "userdata" then
		return false;
	end
	return true;
end

function CheckStruct(struct)
	if nil == struct or type(struct) ~= "userdata" then
		return false;
	end
	return true;
end

function MakeTagList(...)
	local taglist	= {};
	for i, v in ipairs(arg) do
		if CheckN(v) then
			table.insert(taglist, v);
		end
	end
	return taglist;
end

--浮点数比较
function floatEqual(a, b)
	if not CheckN(a) or
		not CheckN(b) then
		return false;
	end
	
	if math.abs(a - b) < 0.0001 then
		return true;
	end
	
	return false;
end

--获取数字的整数位
function getIntPart(x)
	if not CheckN(x) then
		return 0;
	end
	if x <= 0 then
	   return math.ceil(x);
	end
	local n	= math.ceil(x);
	if floatEqual(n, x) then
	   x = n;
	else
	   x = n - 1;
	end
	return x;
end

--返回数字并保留小数点后N位
function GetNumDot(nNumber, nDotNum)
	if not CheckN(nNumber) or
		not CheckN(nDotNum) or 
		nDotNum <= 0 then
		return 0;
	end
	local nRes	= nNumber * (10^nDotNum);
	return getIntPart(nRes) / (10^nDotNum);
end

--将秒数转化为格式化时间，用于显示倒计时,flag=0表示为mm:ss格式，flag＝1表示为hh:mm:ss格式
function FormatTime(second,flag)
	local result="";
	
	if flag==1 then
		local hour=getIntPart(second/3600);
		if hour < 10 then
			result=result.."0"..SafeN2S(hour)..":";
		else
			result=result..SafeN2S(hour)..":";
		end
	end
	
	local mi=getIntPart((second%3600)/60);
	if mi < 10 then
		result=result.."0"..SafeN2S(mi)..":";
	else
		result=result..SafeN2S(mi)..":";
	end
	
	local se = second%60;
	if se < 10 then
		result=result.."0"..SafeN2S(se);
	else
		result=result..SafeN2S(se);
	end
	
	return result;
end

--将秒数转化为格式化为中文时间
function FormatChineseTime(second)
	local result="";
	
	if second>=3600 then
		local hour=getIntPart(second/3600);
		result=result..SafeN2S(hour).."小时";
	end
	
	if second>= 60 then
		local mi=getIntPart((second%3600)/60);
		result=result..SafeN2S(mi).."分";
	end
	
	local se = second%60;
	result=result..SafeN2S(se).."秒";
	
	return result;
end

--获取数字的个位
function Num1(n)
	return n % 10;
end

function Num2(n)
	return getIntPart(Num1(n / 10));
end

function Num3(n)
	return Num1(getIntPart(n / 100));
end

function Num4(n)
	return Num1(getIntPart(n / 1000));
end

function Num5(n)
	return Num1(getIntPart(n / 10000));
end

function Num6(n)
	return Num1(getIntPart(n / 100000));
end

function Num7(n)
	return Num1(getIntPart(n / 1000000));
end

function Num8(n)
	return Num1(getIntPart(n / 10000000));
end

function Num9(n)
	return Num1(getIntPart(n / 100000000));
end

-- 只打印数字与字符串
function LogInfoT(t)
	if not CheckT(t) then
		return;
	end
	
	for	i, v in ipairs(t) do
		if type(v) == "number" then
			LogInfo("[%d][%d]", i, v);
		elseif type(v) == "string" then 
			LogInfo("[%d][%s]", i, v);
		end
	end
end


function GetCurrentTime()
	return os.time()
end
function fomatBigNumber(value)
	if value<10000 then
		return SafeN2S(value);
	elseif value<100000000 then
		local v1=getIntPart(value/10000);
		return SafeN2S(v1).."万";
	else 
		local v1=getIntPart(value/100000000);
		return SafeN2S(v1).."亿";
	end
end

function GetRunningScene()
    local pDirector = DefaultDirector();
	if ( pDirector == nil ) then
		LogInfo( "GetRunningScene: pDirector == nil" );
		return nil;
	end
    
	local pScene = pDirector:GetRunningScene();
	if ( pScene == nil ) then
		LogInfo( "GetRunningScene: scene == nil" );
		return nil;
	end
    return pScene;
end

--功能stage
StageFunc = {
    Star = 31,              --将星
    Matrix = 41,            --阵法
    Strengthen = 71,        --强化
    Levy = 161,             --征收
    Rank = 171,             --军衔
    Arena = 181,            --竞技场
    EliteCoyp = 241,        --精英副本
    Mount = 291,            --坐骑
    Fete = 321,             --祭祀
    RepeatCoyp = 541,       --副本扫荡
};


--** chh 2012-08-10 **--
function IsFunctionOpen(nStage)
    local nPlayerStage      = _G.ConvertN(_G.GetRoleBasicDataN(GetPlayerId(), USER_ATTR.USER_ATTR_STAGE));
    if(nStage>nPlayerStage) then
        return false;
    end
    return true;
end


--获得当前VIP的权限值
function GetVipVal(nVipConfigId)
    local nVipRank = GetRoleBasicDataN(GetPlayerId(),USER_ATTR.USER_ATTR_VIP_RANK);
    return GetDataBaseDataN("vip_config",nVipRank,nVipConfigId);
end

--判断某功能是否开启
function GetVipIsOpen(nVipConfigId)
    local nVal = GetVipVal(nVipConfigId)
    if(nVal == 0) then
        return false;
    end
    return true;
end


--判断是否可洗炼
function Is_EQUIP_EDU(nType)
    LogInfo("Is_EQUIP_EDU()");
    local nEduType = GetVipVal(DB_VIP_CONFIG.EQUIP_EDU);
    
    LogInfo("nEduType:[%d],nType:[%d]",nEduType,nType);
    if (nEduType >= nType) then
        return true;
    end
    return false;
end


--根据类型判断需要多少VIP才可洗炼
function GetVipLevel_EQUIP_EDU(nType)
    local ids = GetDataBaseIdList("vip_config");
    for i,v in ipairs(ids) do
        local val = GetDataBaseDataN("vip_config",v,DB_VIP_CONFIG.EQUIP_EDU);
        if(val == nType) then
            return v;
        end
    end
end





