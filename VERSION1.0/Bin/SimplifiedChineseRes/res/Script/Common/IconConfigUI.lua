local _G = _G;

--获取技能图标
function GetSkillPotraitPic(skillId)
	return GetPotraitPic(skillId, "skill_config", DB_SKILL_CONFIG.ICONINDEX, "Skill", 80, 80);
end

--获得物品图片
function GetHeadPotraitPic(headId)
	return GetPotraitPic(headId, "itemtype", DB_ITEMTYPE.ICONINDEX, "Goods", 80, 80);
end

--获得坐骑图片
function GetMountModelPotraitPic(id)
    return GetPotraitPic(id, "mount_model_config", DB_MOUNT_MODEL.ICON, "Mounts", 280, 280);
end

--获得坐骑头像
function GetMountHeadPotraitPic(id)
    return GetPotraitPic(id, "mount_model_config", DB_MOUNT_MODEL.ICON, "MountsHead", 100, 100);
end


--获得武将半身像
function GetPetBodyPic(petTypeId)
    return GetPotraitPic(petTypeId, "pet_config", DB_PET_CONFIG.BODY_PIC, "Bust", 256, 256);
end

--获得武将任务圆头像
function GetNpcTaskPic(nNpcId)
    return GetPotraitPic(nNpcId, "npc", DB_NPC.HEAD_PIC, "bast_small", 220, 220);
end

--获得武将全身像
function GetNpcWholePic(nNpcId)
    return GetPotraitPic(nNpcId, "npc", DB_NPC.WHOLE_PIC, "bast_all", 500, 500);
end

--获得武将头像带背景
function GetPetPotraitPic(petTypeId)
    return GetPotraitPic(petTypeId, "pet_config", DB_PET_CONFIG.ICON, "Figure_Portrait", 80, 80);
end

--获得主角头像不带背景
function GetPetPotraitTranPic(petTypeId)
    return GetPotraitPic(petTypeId, "pet_config", DB_PET_CONFIG.ICON, "Figure_Portrait", 80, 80, -1, 0);
end



--获得主角高清头像带背景
function GetPlayerPotraitPic(petTypeId)
    return GetPotraitPic(petTypeId, "pet_config", DB_PET_CONFIG.ICON, "PlayerHeadNew", 120, 120);
end

--获得主角高清头像不带背景
function GetPlayerPotraitTranPic(petTypeId)
    return GetPotraitPic(petTypeId, "pet_config", DB_PET_CONFIG.ICON, "PlayerHeadNew", 120, 118, -1, 0);
end


--获得主角高清主界面头像
function GetPlayerMainUIPotraitPic(petTypeId)
return GetPotraitPic(petTypeId, "pet_config", DB_PET_CONFIG.ICON, "PlayerHeadMainUI", 150, 126, -1, 0);
end


--获得竞技场头像
function GetArenaUIPlayerHeadPic(petTypeId)
    return GetPotraitPic(petTypeId, "pet_config", DB_PET_CONFIG.ICON, "ArenaPlayerHead", 136, 136, -1, 0);
end



--获取物品图片
function GetGoodsPic(id)
    return GetPotraitPic(id, "itemtype", DB_ITEMTYPE.ICONINDEX, "Goods", 80, 80);
end

--获取礼包图片
function GetGiftPic(id)
    return GetPotraitPic(id, "itemtype", DB_ITEMTYPE.ICONINDEX, "Goods", 80, 80);
    --return GetPotraitPic(id, "giftpack_config", DB_GIFTPACK_CONFIG.ICON, "Gifts", 80, 80);
end

--获得boss战图片
function GetBossTypePic( nActivity )
	return GetPotraitPic( nActivity, "event_activity", DB_EVENT_ACTIVITY_CONFIG.ICON, "boss", 424, 430 );
end

function GetPotraitPic(id, configfilename, index, picfilename, w, h, offsetRows, offsetCols)
    if not _G.CheckN(id) then
        LogInfo("id not is num!");
		return nil;
	end
    
    if(offsetRows == nil) then
        offsetRows = 0;
    end
    if(offsetCols == nil) then
        offsetCols = 0;
    end
	
	local nIcon = GetDataBaseDataN(configfilename, id, index);
	if not _G.CheckN(nIcon) then
		return nil;
	end
    LogInfo("GetPotraitPic:nIcon:[%d],id[%d],index:[%d]",nIcon, id, index);

	--千位,百位标识图片资源文件编号
	--十位标识所在文件行,个位标识所在文件列
	local filename		= picfilename;
	local nThousand		= _G.Num4(nIcon);
	local nHundred		= _G.Num3(nIcon);
	local nRow			= _G.Num2(nIcon) - 1 + offsetRows; -- 索引从1开始
	local nCol			= _G.Num1(nIcon) - 1 + offsetCols; -- 索引从1开始
	
	if nRow < 0 or nCol < 0 then
		_G.LogError("%s GetPotraitPic row or col index err!",picfilename);
		return nil;
	end
	
	_G.LogInfo("GetPotraitPic[%d][%d][%d][%d]", nThousand, nHundred, nRow, nCol);
	
	if nThousand > 0 then
		filename = filename .. nThousand;
		if nHundred >= 0 then
			filename = filename .. nHundred;
		end
	else
		if nHundred > 0 then
			filename = filename .. nHundred;
		end
	end
	LogInfo("filename=[%s]",filename);
    
	local pool = _G.DefaultPicPool();
    
    
	local pic;
    if(bIsLanguage) then
        LogInfo("%s %s bIsLanguage true",configfilename,picfilename);
        pic = pool:AddPicture(_G.GetSMImg00Path("portrait/" .. filename .. ".png"), false);
    else
        LogInfo("%s %s bIsLanguage false",configfilename,picfilename);
        pic = pool:AddPicture(_G.GetSMImgPath("portrait/" .. filename .. ".png"), false);
    end
    
	if not _G.CheckP(pic) then
        LogInfo("pic is null!");
		return nil;
	end
	
	local nCutX		= nCol * w;
	local nCutY		= nRow * h;
	
	pic:Cut(_G.CGRectMake(nCutX, nCutY, w, h));
	return pic;
end

--获取头像图片文件路径(剧情接口用)
function GetPetPotraitPicPath(petTypeId) 
	LogInfo("DB_PET_CONFIG ICON:")
	return GetPotraitPicPath(petTypeId, "pet_config", 6, "Figure_Portrait", 80, 80);
end


--获取图片文件路径,cellX,cellY
function GetBodyPotraitPicPath(nIndex)
   if not _G.CheckN(nIndex) then
        LogInfo("id not is num!");
		return nil;
	end

	local nIcon = nIndex
	--千位,百位标识图片资源文件编号
	--十位标识所在文件行,个位标识所在文件列
	local filename		= "Bust";
	local nThousand		= _G.Num4(nIcon);
	local nHundred		= _G.Num3(nIcon);
	local nRow			= _G.Num2(nIcon) - 1; -- 索引从1开始
	local nCol			= _G.Num1(nIcon) - 1; -- 索引从1开始
	
	if nRow < 0 or nCol < 0 then
		_G.LogError("%s GetPortraitPicPath row or col index err!",picfilename);
		return nil;
	end
	
	
	if nThousand > 0 then
		filename = filename .. nThousand;
		if nHundred >= 0 then
			filename = filename .. nHundred;
		end
	else
		if nHundred > 0 then
			filename = filename .. nHundred;
		end
	end
	LogInfo("filename=[%s]",filename);
    
	local picPath = _G.GetSMImgPath("portrait/" .. filename .. ".png");
	
	return	picPath,nCol,nRow;
end	




-----======================获取副本图标,武将头像调整=======================-----
--取大地图的图标在副本里使用
--[[
function GetMapPic(mapId)
    return GetPotraitPic(mapId, "map", DB_DYNAMAP.TITLE, "Map", 178, 154);
end
--]]

--取大地图的图标在副本里使用(精英副本由于要加灰色图片导致实现不同修改）
function GetEliteGrayMapPic(mapId)
    return GetPotraitPicMap(mapId, "map", DB_DYNAMAP.TITLE, "MapGray", 178, 154);
end

function GetMapPic(mapId)
    --return GetPotraitPicMap(mapId, "map", DB_DYNAMAP.TITLE, "Map",178, 154);
    return GetPotraitPic(mapId, "map", DB_DYNAMAP.TITLE, "Map",178, 154, nil, nil, true);
end

function GetPotraitPicMap(id, configfilename, index,sHead, w, h, offsetRows, offsetCols)
    if not _G.CheckN(id) then
        LogInfo("id not is num!");
		return nil;
	end
    
    if(offsetRows == nil) then
        offsetRows = 0;
    end
    if(offsetCols == nil) then
        offsetCols = 0;
    end
	
	local nIcon = GetDataBaseDataN(configfilename, id, index);
	if not _G.CheckN(nIcon) then
		return nil;
	end
    LogInfo("GetPotraitPic:nIcon:[%d],id[%d],index:[%d]",nIcon, id, index);

	--千位,百位标识图片资源文件编号
	--十位标识所在文件行,个位标识所在文件列
	local filename		= "Map/"..sHead..nIcon;

	local pool = _G.DefaultPicPool();
	local pic = pool:AddPicture(_G.GetSMImgPath("portrait/" .. filename .. ".png"), false);
	if not _G.CheckP(pic) then
        LogInfo("pic is null!");
		return nil;
	end

	return pic;
end


--获得招募界面的武将头像
--[[
function GetPetBigPotraitTranPic( petTypeId )
    return GetPotraitPic( petTypeId, "pet_config", DB_PET_CONFIG.ICON, "Figure_BigPortrait", 179, 215 );
end

--获得招募界面的灰色武将头像
function GetPetBigGrayPotraitTranPic( petTypeId )
    return GetPotraitPic( petTypeId, "pet_config", DB_PET_CONFIG.ICON, "Figure_BigGrayPortrait", 179, 215 );
end
--]]

function GetPetBigPotraitTranPic( petTypeId )
    return GetPotraitPicFigure( petTypeId, "pet_config", DB_PET_CONFIG.ICON, "Figure_BigPortrait", 179, 215 );
end

--获得招募界面的灰色武将头像
function GetPetBigGrayPotraitTranPic( petTypeId )
    return GetPotraitPicFigure( petTypeId, "pet_config", DB_PET_CONFIG.ICON, "Figure_BigGrayPortrait", 179, 215 );
end


function GetPotraitPicFigure(id, configfilename, index,sHead, w, h, offsetRows, offsetCols)
    if not _G.CheckN(id) then
        LogInfo("id not is num!");
		return nil;
	end
    
    if(offsetRows == nil) then
        offsetRows = 0;
    end
    if(offsetCols == nil) then
        offsetCols = 0;
    end
	
	local nIcon = GetDataBaseDataN(configfilename, id, index);
	if not _G.CheckN(nIcon) then
		return nil;
	end
    LogInfo("GetPotraitPic:nIcon:[%d],id[%d],index:[%d]",nIcon, id, index);

	--千位,百位标识图片资源文件编号
	--十位标识所在文件行,个位标识所在文件列
	local filename		= sHead.."/Figure_BigPortrait"..nIcon;

	local pool = _G.DefaultPicPool();
	local pic = pool:AddPicture(_G.GetSMImgPath("portrait/" .. filename .. ".png"), false);
	if not _G.CheckP(pic) then
        LogInfo("pic is null!");
		return nil;
	end

	return pic;
end













