package org.DeNA.DHLJ;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxEditText;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.os.Bundle;

public class DaHuaLongJiang extends Cocos2dxActivity{
	private Cocos2dxGLSurfaceView mGLView;
	
    protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		
		// get the packageName,it's used to set the resource path
		String packageName = getApplication().getPackageName();
		super.setPackageName(packageName);

        setContentView(R.layout.helloworld_demo);
        mGLView = (Cocos2dxGLSurfaceView) findViewById(R.id.helloworld_gl_surfaceview);
        mGLView.setTextField((Cocos2dxEditText)findViewById(R.id.textField));      
	}

	 @Override
	 protected void onPause() {		 
	     super.onPause();
	     
	     mGLView.onPause();
	 }

	 @Override
	 protected void onResume() {
	     super.onResume();
	     
	     mGLView.onResume();
	 }

     static {
         System.loadLibrary("ClientLogic");
     }     
}