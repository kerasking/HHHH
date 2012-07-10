function GetScene(nSceneTag)
	local director = DefaultDirector();
	if nil == director then
		return nil;
	end
	
	local scene = director:GetSceneByTag(nSceneTag);
	return scene;
end

--主界面某个UI是否处于显示状态
function IsUIShow(tagUI)
	if not GetUI(tagUI) then
		return false;	
	end
	return true;
end

function SetUIVisible(visible)
	LogInfo("ui visible=%d ",visible);
	if visible==0 then --隐藏所有UI
		if not CheckT(NMAINSCENECHILDTAG) then
			LogInfo("CloseMainUI not CheckT(NMAINSCENECHILDTAG)");
			return;
		end
		for i, v in pairs(NMAINSCENECHILDTAG) do
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(false);
			else
				LogInfo("can not find ui");
			end
		end
	elseif visible == 1 then --显示所有UI
		if not CheckT(NMAINSCENECHILDTAG) then
			LogInfo("CloseMainUI not CheckT(NMAINSCENECHILDTAG)");
			return;
		end
		for i, v in pairs(NMAINSCENECHILDTAG) do
			local ui = GetUI(v)
			if ui then
				ui:SetVisible(true);
			else
				LogInfo("can not find ui");
			end
		end
	end
end

function CloseMainUI()
	local bRet	= false;
	if not CheckT(NMAINSCENECHILDTAG) then
		LogInfo("CloseMainUI not CheckT(NMAINSCENECHILDTAG)");
		return;
	end
	for i, v in pairs(NMAINSCENECHILDTAG) do
		if i ~= "BottomSpeedBar" 
			and i~="TopSpeedBar" 
			and i ~= "WorldMapBtn" 
			and i ~= "bossUI" 
			and i ~= "bossRankUI" then
			if CloseUI(v) then
				bRet	= true;
			end
		end
	end
	
	if CloseDlg() then
	--npc对话
		bRet	= true;
	end
	
	return bRet;
end

function GetWorldMapUITag()
	if not CheckT(NMAINSCENECHILDTAG) then
		return 0;
	end
	
	if not CheckN(NMAINSCENECHILDTAG.WorldMap) then
		return 0;
	end
	
	return NMAINSCENECHILDTAG.WorldMap;
end

--关闭主界面某个UI
function CloseUI(tagUI)
	local ui = GetUI(tagUI)
	if not ui then
		return false;	
	end
	ui:RemoveFromParent(true);
	
	return true;
end

--获取主界面某个UI
function GetUI(tagUI)
	local scene = GetSMGameScene();	
	if scene == nil then
		return nil;
	end 
	if not CheckN(tagUI) then
		return nil;
	end
	local layer = GetUiLayer(scene, tagUI);
	return layer;
end


-- 设置游戏数据到标签上
-- pParent: 标签的父节点
-- nTag: 标签的tag
-- nScriptData: NScriptData枚举
-- nRoleData: NRoleData枚举
-- nRoleId: 角色ID(人或怪物或NPC..),对应于NScriptData枚举
-- nId:	数据ID(宠物或技能或物品...),对应于NRoleData枚举
-- nEnum: 数据枚举索引
-- 注:	1.SetGameDataNToLabel设置数值
--		2.SetGameDataSToLabel设置字符串

function SetGameDataNToLabel(pParent, nTag, nScriptData, nRoleData, nRoleId, nId, nEnum)
	if pParent == nil then
		return;
	end
	
	local lb = GetLabel(pParent, nTag);
	if nil == lb then
		return;
	end
	
	local val = GetGameDataN(nScriptData, nRoleId, nRoleData, nId, nEnum);
	if nil == val then
		return;
	end
	
	lb:SetText(tostring(val));
end

function SetGameDataSToLabel(pParent, nTag, nScriptData, nRoleData, nRoleId, nId, nEnum)
	if pParent == nil then
		return;
	end

	if not CheckN(nTag) then
		return;
	end
	
	local lb = GetLabel(pParent, nTag);
	if nil == lb then
		return;
	end
	
	local val = GetGameDataS(nScriptData, nRoleId, nRoleData, nId, nEnum);
	if nil == val then
		return;
	end
	
	lb:SetText(val);
end

function SetLabel(pParent, nTag, str)
	if not CheckP(pParent) or not CheckS(str) then
		LogInfo("SetLabel invalid arg1");
		return;
	end

	if not CheckN(nTag) then
		LogInfo("SetLabel invalid arg2");
		return;
	end
	
	local lb = GetLabel(pParent, nTag);
	if nil == lb then
		return;
	end
	
	lb:SetText(str);
end

function SetHyperlinkText(pParent, nTag, str)
	if pParent == nil or not CheckS(str) then
		return;
	end

	if not CheckN(nTag) then
		return;
	end
	
	local hlt = GetHyperLinkText(pParent, nTag);
	if nil == hlt then
		return;
	end
	
	hlt:SetLinkText(str);
end

function SetHyperlinkButtn(pParent, nTag, str)
	if pParent == nil or not CheckS(str) then
		return;
	end

	if not CheckN(nTag) then
		return;
	end
	
	local hlb = GetHyperLinkButton(pParent, nTag);
	if nil == hlb then
		return;
	end
	
	hlb:SetLinkText(str);
end

function CreateLabel(text, rect, fontsize, color)
	if not CheckS(text) or not CheckN(fontsize) or
		nil == rect or nil == color then
		LogInfo("CreateLabel arg invalid");
		return nil;
	end
	local lb = createNDUILabel();
	if not lb then
		LogInfo("CreateLabel create failed");
		return nil;
	end
	lb:Init();
	lb:SetText(text);
	lb:SetFrameRect(rect);
	lb:SetFontSize(fontsize);
	lb:SetFontColor(color);
	return lb;
end

function CreateHyperlinkButton(text, rect, fontsize, color)
	if not CheckS(text) or not CheckN(fontsize) or
		nil == rect or nil == color then
		return nil;
	end
	local hlb = createUIHyperlinkButton();
	if not hlb then
		return nil;
	end
	hlb:Init();
	hlb:SetFrameRect(rect);
	hlb:SetLinkBoundRect(rect);
	hlb:SetLinkTextFontSize(fontsize);
	hlb:SetLinkTextColor(color);
	hlb:SetLinkText(text)
	return hlb;
end

function CreateHyperlinkText(text, rect, fontsize, color)
	if not CheckS(text) or not CheckN(fontsize) or
		nil == rect or nil == color then
		return
	end
	local hlt = createUIHyperlinkButton();
	if not hlt then
		return nil;
	end
	hlt:Init();
	hlt:SetFrameRect(rect);
	hlt:SetLinkBoundRect(rect);
	hlt:SetLinkTextFontSize(fontsize);
	hlt:SetLinkTextColor(color);
	hlt:SetLinkText(text);
	return hlt;
end

--focusPicname, bPicShowInCenter参数可选
function CreateButton(picname, selpicname, text, rect, fontsize, focusPicname, bPicShowInCenter, backPicname)
	if not CheckStruct(rect) or not CheckN(fontsize) then
		LogInfo("CreateButton arg invalid");
		return nil;
	end
	local btn = createNDUIButton();
	if not CheckP(btn) then
		return nil;
	end
	btn:Init();
	btn:CloseFrame();
	btn:SetFrameRect(rect);
	btn:SetFontSize(fontsize);
	if CheckS(text) then
		btn:SetTitle(text);
	end
	--LogInfo("rect[%d][%d]", rect.size.w, rect.size.h);
	local pool = DefaultPicPool();
	if CheckS(picname) and "" ~= picname then
		if CheckP(pool)  then
			local pic = pool:AddPicture(GetSMImgPath(picname), false);
			if CheckP(pic) then
				if not bPicShowInCenter then
					btn:SetImage(pic);
				else
					local size	= pic:GetSize();
					--LogInfo("pic[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetImageEx(pic, true, r, true);
				end
			end
		end
	end
	
	if CheckS(selpicname) and "" ~= selpicname then
		if CheckP(pool)  then
			local picTouch = pool:AddPicture(GetSMImgPath(selpicname), false);
			if CheckP(picTouch) then
				if not bPicShowInCenter then
					btn:SetTouchDownImage(pic);
				else
					local size	= picTouch:GetSize();
					--LogInfo("picTouch[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetTouchDownImageEx(picTouch, true, r, true);
				end
			end
		end
	end
	
	if CheckS(focusPicname) and "" ~= focusPicname then
		if CheckP(pool)  then
			local picFocus = pool:AddPicture(GetSMImgPath(focusPicname), false);
			if CheckP(picFocus) then
				if not bPicShowInCenter then
					btn:SetFocusImage(picFocus);
				else
					local size	= picFocus:GetSize();
					--LogInfo("picFocus[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetFocusImageEx(picFocus, true, r, true);
				end
			end
		end
	end
	
	if CheckS(backPicname) and "" ~= backPicname then
		if CheckP(pool)  then
			local picBack = pool:AddPicture(GetSMImgPath(backPicname), false);
			if CheckP(picBack) then
				if not bPicShowInCenter then
					btn:SetBackgroundPicture(picBack, nil);
				else
					local size	= picBack:GetSize();
					--LogInfo("picBack[%d][%d]", size.w, size.h);
					local r		= CGRectMake((rect.size.w - size.w) / 2, (rect.size.h - size.h) / 2, size.w, size.h);
					btn:SetBackgroundPictureEx(picBack, nil, true, r, true);
				end
			end
		end
	end
	
	return btn;
end
