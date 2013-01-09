package org.DeNA.DHLJ;

import android.content.Context;
import android.util.Log;
import android.view.MotionEvent;
import android.view.WindowManager;
import android.widget.ImageView;

public class FloatView extends ImageView {
	private float mTouchStartX;
    private float mTouchStartY;
    private float x;
    private float y;
    private float mLastX;
    private float mLastY;
    
    private WindowManager wm=(WindowManager)getContext().getApplicationContext().getSystemService("window");
    
    //此wmParams为获取的全局变量，用以保存悬浮窗口的属性
    private WindowManager.LayoutParams wmParams = DaHuaLongJiang.getMywmParams();

	public FloatView(Context context) {
		super(context);		
		// TODO Auto-generated constructor stub
	}
	
	 @Override
	 public boolean onTouchEvent(MotionEvent event) {
		 //获取相对屏幕的坐标，即以屏幕左上角为原点		 
	     x = event.getRawX();   
	     y = event.getRawY()-25;   //25是系统状态栏的高度
	     int nMoveX = 0;
	     int nMoveY = 0;
	     Log.i("currP", "currX"+x+"====currY"+y);
	     switch (event.getAction()) {
	        case MotionEvent.ACTION_DOWN:
	        	//获取相对View的坐标，即以此View左上角为原点
	        	mTouchStartX =  event.getX();  
                mTouchStartY =  event.getY();

	    		mLastX = x;
	    		mLastY = y;
	            Log.i("startP", "startX"+mTouchStartX+"====startY"+mTouchStartY);
	            
	            break;
	        case MotionEvent.ACTION_MOVE:	            
	            updateViewPosition();
	            break;

	        case MotionEvent.ACTION_UP:
	    		nMoveX=(int)Math.abs(x-mLastX);
	    		nMoveY=(int)Math.abs(y-mLastY);
	            Log.i("MoveP", "nMoveX"+nMoveX+"====nMoveY"+nMoveY);

	        	updateViewPosition();
	        	if(nMoveX < 4 && nMoveY < 4) {
   			 		FeedsView.openActivityFeeds();
   		            DaHuaLongJiang.FVClicked();
	        	}
	        	mTouchStartX=mTouchStartY=0;
	        	break;
	        }
	        return true;
		}
	 
	 private void updateViewPosition(){
		//更新浮动窗口位置参数
		wmParams.x=(int)( x-mTouchStartX);
		wmParams.y=(int) (y-mTouchStartY);
	    wm.updateViewLayout(this, wmParams);
	 }

}
