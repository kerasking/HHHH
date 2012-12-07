package org.DeNA.DHLJ;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.content.Context;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.view.View;
import android.widget.MediaController;

public class NDVideoControl extends MediaController implements OnCompletionListener
{
	protected Cocos2dxActivity m_pkCocos2dxActivity = null;
	
	public NDVideoControl(Context context)
	{
		super(context);
		
		hide();
	}
	
	public void setCocos2dxActivity(Cocos2dxActivity pkActivity)
	{
		m_pkCocos2dxActivity = pkActivity;
	}

	public void onCompletion(MediaPlayer mp)
	{
		if (null != m_pkCocos2dxActivity)
		{
			m_pkCocos2dxActivity.m_pkView.setVisibility(View.GONE);
		}
	}
}
