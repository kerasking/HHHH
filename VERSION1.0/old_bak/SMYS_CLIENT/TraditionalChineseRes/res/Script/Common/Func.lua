function LogInfo(fmt, ...)
    LuaLogInfo(string.format(fmt, unpack(arg)));
end

function LogError(fmt, ...)
    LuaLogError(string.format(fmt, unpack(arg)));
end