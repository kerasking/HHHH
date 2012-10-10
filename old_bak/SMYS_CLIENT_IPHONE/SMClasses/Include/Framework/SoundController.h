#if !defined SOUNDENGINE_KERNEL_H__
#define SOUNDENGINE_KERNEL_H__

//声音控制
class ISoundController
{
public:
	static ISoundController& sharedInstance();
	virtual bool SetupSound() = 0; 

	virtual void ReleaseSounds() = 0;
	
	//只播放一次音效
	virtual void  PlaySound(const char* filename) = 0; 

	//重复播放音效
	virtual void  PlayMusic(const char* filename="") = 0; 

	virtual void  StopMusic() = 0; 

	virtual void  StopSound() = 0;
	
	//设置是否允许播放声音
	virtual void SetMusicEnabled(bool bEnabled=true) = 0;

	virtual void SetSoundEnabled(bool bEnabled=true) = 0;
	
	virtual void SetMusicVolume(int Vol) = 0;

	virtual void SetSoundVolume(int Vol) = 0;
};
#endif

   
