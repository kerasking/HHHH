package org.DeNA.DHLJ;

import android.content.Context;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.view.View;
import android.widget.MediaController;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.DeNA.DHLJ.VideoActivity;

public class NDVideoControl extends MediaController implements OnCompletionListener
{
	protected DaHuaLongJiang m_pkCocos2dxActivity = null;
	
	protected VideoActivity m_videoActivity = null;
	
	public NDVideoControl(Context context)
	{
		super(context);
		
		hide();
	}
	
	public void setCocos2dxActivity(Cocos2dxActivity pkActivity)
	{
		m_pkCocos2dxActivity = (DaHuaLongJiang)pkActivity;
	}

	public void setVideoActivity(VideoActivity pkActivity)
	{
		m_videoActivity = pkActivity;
	}
	
	public void onCompletion(MediaPlayer mp)
	{
		if (null != m_pkCocos2dxActivity)
		{
			m_pkCocos2dxActivity.continueRootView();
		}
		
		if (null != m_videoActivity)
		{
			m_videoActivity.finish();
		}		
	}
}
