---------------------------------------------------
--描述: 音乐接口
--时间: 2012.7.25
--作者: qbw
---------------------------------------------------

---------------------------------------------------

Music = {}
local p = Music;

p.SoundEffect =
{
	CLOSEBTN       = 0,
	CLICK	       = 1,
	POPWIN	       = 2,
	ENTER_BATTLE   = 3,
	EQ_STR		   = 4,
	EQ_UPSTEP      = 5,
	EQ_GLIDE       = 6,
	WEAPON_BAPTIZE = 7,
	HEROSTAR	   = 8,
	MOUNTING	   = 9,
	SACRIFICE	   = 10,
	LEVY		   = 11,
	RECEIVE_TASK   = 12,
	FINISH_TASK    = 13,
	MOUNT_UPGRADE  = 14,	
	PAGETURN	   = 15,
	REMIND		   = 16,
	LEVUP		   = 17,
	RANK_UP	   	   = 18,
	RECRUIT	   	   = 19,
}



--技能音效列表  
p.SkillSoundEffect = {}
--光效id			音效id
p.SkillSoundEffect[1]  = 1002;	
p.SkillSoundEffect[2]  = 1002;	
p.SkillSoundEffect[3]  = 1003;	
p.SkillSoundEffect[4]  = 1003;	
p.SkillSoundEffect[5]  = 1005;	
p.SkillSoundEffect[6]  = 1005;	
p.SkillSoundEffect[7]  = 1017;	
p.SkillSoundEffect[8]  = 1017;	
p.SkillSoundEffect[9]  = 1016;	
p.SkillSoundEffect[10] = 1016;	
p.SkillSoundEffect[11] = 1014;	
p.SkillSoundEffect[12] = 1011;	
p.SkillSoundEffect[13] = 1012;	
p.SkillSoundEffect[14] = 1012;	
p.SkillSoundEffect[15] = 1009;	
p.SkillSoundEffect[16] = 1009;	
p.SkillSoundEffect[17] = 1010;	
p.SkillSoundEffect[18] = 1013;	
p.SkillSoundEffect[19] = 1015;	
p.SkillSoundEffect[20] = 1018;	
p.SkillSoundEffect[21] = 1006;	
p.SkillSoundEffect[22] = 1019;	

--BUFF DEBUFF	
p.SkillSoundEffect[23] = 1096;	
p.SkillSoundEffect[24] = 1096;	
p.SkillSoundEffect[25] = 1096;	
p.SkillSoundEffect[26] = 1096;	
p.SkillSoundEffect[27] = 1096;	
p.SkillSoundEffect[28] = 1096;	
p.SkillSoundEffect[29] = 1096;	
p.SkillSoundEffect[30] = 1096;	
p.SkillSoundEffect[31] = 1096;	
p.SkillSoundEffect[32] = 1096;	
p.SkillSoundEffect[33] = 1096;	

p.SkillSoundEffect[34] = 1095;	
p.SkillSoundEffect[35] = 1095;	
p.SkillSoundEffect[36] = 1095;	
p.SkillSoundEffect[37] = 1095;	
p.SkillSoundEffect[38] = 1095;	
p.SkillSoundEffect[39] = 1095;	
p.SkillSoundEffect[40] = 1095;	

--普通攻击
p.SkillSoundEffect[1099] = 1099;	
p.SkillSoundEffect[1098] = 1098;	
p.SkillSoundEffect[1097] = 1097;	
	
	



--根据map播放背景音乐
function p.PlayBackGroundMusic(nMapId)
	SetSceneMusicNew(nMapId);
end

--播放login音乐
function p.PlayLoginMusic()
	SetSceneMusicNew(99);
end

--播放世界地图音乐
function p.PlayWorldMusic()
	SetSceneMusicNew(98);
end

--播放战斗音乐 
function p.PlayBattleMusic()
	SetSceneMusicNew(97);
end

--停止音乐播放
function p.StopMusic()
	StopBGMusic();
end

function p.SetBgVolune(nVol)
	SetBgMusicVolume(nVol);
end



--播放技能音效 nId 光效ID   nSec延迟播放时间(ms)
function p.PlayBattleSoundEffect(nId,nSec)
	if nSec ~= nil and nSec > 0 then
		_G.LogInfo("PlayBattleSoundEffect DelayPlaySound");
		_G.LogInfo("PlayBattleSoundEffect DelayPlaySound nSec"..nSec);
		p.DelayPlaySound(nId,nSec)
		return;
	end
	
	if p.SkillSoundEffect[nId] == nil then
		_G.LogInfo("PlayBattleSoundEffect SE is nil id:"..nId);
		return;
	end
	
	_G.LogInfo("PlayBattleSoundEffect  right now");
	 p.PlayEffectSound(p.SkillSoundEffect[nId]);
end

--===================延迟播放音效=================--
local m_SEId;
p.mTimerTaskTag = nil;
function p.DelayPlaySound(nId,nSec)
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
		p.mTimerTaskTag = nil;
	end
	m_SEId = nId;
	p.mTimerTaskTag = RegisterTimer(p.PlayBattleSoundEffectDelay, nSec/1000);

end


function p.PlayBattleSoundEffectDelay()
	local nId = m_SEId;
	
	if (p.mTimerTaskTag) then
		UnRegisterTimer(p.mTimerTaskTag);
		p.mTimerTaskTag = nil;
	end
	
	if p.SkillSoundEffect[nId] == nil then
		_G.LogInfo("PlayBattleSoundEffectDelay SE is nil id:"..nId);
		return;
	end
	
	 p.PlayEffectSound(p.SkillSoundEffect[nId]);
end

--==================================================--

--播放声效 返回声效key用于控制声效
function p.PlayEffectSound(nEffect)
	--屏蔽点击和滑动音效
	if nEffect == p.SoundEffect.CLICK 
		or nEffect ==p.SoundEffect.PAGETURN 
		or nEffect ==p.SoundEffect.CLOSEBTN 
		
		or nEffect ==p.SoundEffect.RECEIVE_TASK 
		or nEffect ==p.SoundEffect.FINISH_TASK 
		or nEffect ==p.SoundEffect.POPWIN then
		return;
	end
	
	return StartEffectSound(nEffect)
end


function p.OnEnterGameScene()

	local nCurMapId			= ConvertN(_G.GetMapId());
	_G.LogInfo("Music OnEnterGameScene nCurMapId:"..nCurMapId);
	p.PlayBackGroundMusic(nCurMapId);
	
end

_G.RegisterGlobalEventHandler(_G.GLOBALEVENT.GE_GENERATE_GAMESCENE, "Music.OnEnterGameScene", p.OnEnterGameScene);