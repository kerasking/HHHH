--NPC挂接UI实现

local _G = _G;
setfenv(1, NPC);

--获取NPC半身像
function GetNpcPotraitPic(nNpcId)
	if not _G.CheckN(nNpcId) then
		return nil;
	end
	
	local nIcon = GetDataBaseN(nNpcId, _G.DB_NPC.ICON);
	if not _G.CheckN(nIcon) then
		return nil;
	end
	
	--千位,百位标识图片资源文件编号
	--十位标识所在文件行,个位标识所在文件列,规格256*256
	local filename		= "Bust";
	local nThousand		= _G.Num4(nIcon);
	local nHundred		= _G.Num3(nIcon);
	local nRow			= _G.Num2(nIcon) - 1; -- 索引从1开始
	local nCol			= _G.Num1(nIcon) - 1; -- 索引从1开始
	
	if nRow < 0 or nCol < 0 then
		_G.LogError("npc GetNpcPotraitPic row or col index err!");
		return nil;
	end
	
	_G.LogInfo("GetNpcPotraitPic[%d][%d][%d][%d]", nThousand, nHundred, nRow, nCol);
	
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
	
	local pool = _G.DefaultPicPool();
	if not _G.CheckP(pool) then
		return nil;
	end
	
	local pic = pool:AddPicture(_G.GetSMImgPath("portrait/" .. filename .. ".png"), true);
	if not _G.CheckP(pic) then
		return nil;
	end
	
	local size		= pic:GetSize();
	local nCutX		= nCol * 256;
	local nCutY		= nRow * 256;
	
	if nCutX > size.w or nCutY > size.h then
		_G.LogInfo("npc GetNpcPotraitPic cut[%d][%d] pic[%d][%d]err!", nCutX, nCutY, size.w, size.h);
		return nil;
	end
	
	pic:Cut(_G.CGRectMake(nCutX, nCutY, 256, 256));
	
	return pic;
end

--打开客栈
--function OpenKeZhang()
--	LogInfo("OpenKeZhang: test2")
--	CloseDlg();
--	RoleInvite.LoadUI();	
--end



 