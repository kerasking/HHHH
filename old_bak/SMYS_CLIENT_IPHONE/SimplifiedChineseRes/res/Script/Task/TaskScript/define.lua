--任务脚本
local _G = _G;
setfenv(1, TASK);
DoFile("Task/TaskScript/TaskConfig.lua");
DoFile("Task/TaskScript/Task_10001.lua");
DoFile("Task/TaskScript/Task_20001.lua");
DoFile("Task/TaskScript/Task_30001.lua");