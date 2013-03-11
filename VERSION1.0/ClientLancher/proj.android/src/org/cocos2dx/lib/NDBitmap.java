/****************************************************************************
 * NDBitmap.java
 * extension of Cocos2dxBitmap.java
 ****************************************************************************/
package org.cocos2dx.lib;

import org.cocos2dx.lib.NDHexUtil;
import org.cocos2dx.lib.NDTextProxy.CharProperty;

import android.graphics.*;
import android.graphics.Paint.*;
import android.util.*;

import java.util.*;

public class NDBitmap { 
	private static boolean enableNDBitmap = true; //to enable NDBitmap.
	private static int s_enableNDBitmapCache = -1; //-1,0,1
	public static boolean verbose = false;

	//开关：是否启用NDBitmap的Java端开关
	public static boolean isEnabled()
	{
		return false;
		/*
		if (true) return true;//@del
		if (s_enableNDBitmapCache == -1)
		{
			s_enableNDBitmapCache = 0;
			if (enableNDBitmap)
			{
				s_enableNDBitmapCache = isVerOlder() ? 1 : 0;
			}
		}
		return s_enableNDBitmapCache == 1;
		*/
	}
	
	/**
	 * isVerOlder: is this a older android os, such as 2.x
	 * @param n
	 * @return
	 */
	public static boolean isVerOlder()
	{
		String osVer = android.os.Build.VERSION.RELEASE;
		final String[] ver = osVer.split("\\.");
		return (ver[0].compareTo("2") == 0) ? true : false;
	}
	
	/**
	 * createTextBitmap: create bitmap for rich format label.
	 * @param strText
	 * @param fontName
	 * @param fontSize
	 * @param alignment
	 * @param width
	 * @param height
	 */
	public static void createTextBitmap(
		String strText, final String fontName, final int fontSize, 
		final int alignment, final int width, final int height) 
	{			
		log("------------------");
		log("NDBitmap.createTextBitmap() - enter");

		// create a paint
		final Paint paint = Cocos2dxBitmap.newPaint( fontName, fontSize, alignment & 0x0F );
		
		// reset proxy
		if (NDTextProxy.parse( paint, strText, fontName, fontSize, alignment, width, height ))
		{
			// create bitmap with the calc size
			log("before create bitmap: w=" + NDTextProxy.getBitmapWidth() + ", h=" + NDTextProxy.getBitmapHeight());
			final Bitmap bitmap = Bitmap.createBitmap( NDTextProxy.getBitmapWidth(), NDTextProxy.getBitmapHeight(), Bitmap.Config.ARGB_8888 );
			log("after create bitmap");
			
			// alignment
			final boolean alignLeft = true;
			if (alignLeft)
			{
				paint.setTextAlign(Align.LEFT);
			}
			else
			{
				paint.setTextAlign(Align.CENTER);
			}
			
			// get canvas for bitmap
			final Canvas canvas = new Canvas(bitmap);
			
			// draw each line & each char
			for (final NDTextProxy.CharLine charLine : NDTextProxy.charLineList)
			{
				for (final CharProperty objChar : charLine.charList) 
				{
					if (objChar.bLineFeed) continue;
					
					paint.setAlpha(0xff);
					paint.setColor( objChar.color );
					
					// check x constraint and y constraint (NOTE: when single line, don't check y constraint)
					if (
						(objChar.x >= 0 && objChar.x + objChar.w <= NDTextProxy.getBitmapWidth()) 
						//&& (charLine.lineCount == 1 || (objChar.y >= 0 && objChar.y <= NDTextProxy.getBitmapHeight()))
						&& !objChar.outOfRange
						)
					{
						String str = String.valueOf( objChar.c );
						
						if (alignLeft)
						{
							canvas.drawText( str, objChar.x, objChar.y, paint );
						}
						else
						{
							canvas.drawText( str, objChar.x + objChar.w*0.5f, objChar.y, paint );
						}
						
						log("canvas.drawText(), str="+str+",x="+objChar.x+",y="+objChar.y);
					}
				}//for each char			
			}//for each line
			
			Cocos2dxBitmap.initNativeObject(bitmap);			
		}

		log("NDBitmap.createTextBitmap() - leave");
	}
	
	/**
	 * getStringSize: support rich format
	 * @param strText
	 * @param fontName
	 * @param fontSize
	 * @param alignment
	 * @return
	 */
	public static String getStringSize( final String strText, final String fontName,
											final int fontSize, final int alignment)
	{
		log("------------------");
		log("NDBitmap.getStringSize() - enter");

		final Paint paint = Cocos2dxBitmap.newPaint( fontName, fontSize, alignment & 0x0F );
	
		if (NDTextProxy.parse( paint, strText, fontName, fontSize, alignment, 0, 0 ))
		{
			int w = NDTextProxy.getBitmapWidth();
			int h = NDTextProxy.getBitmapHeight();

			log( "NDBitmap.getStringSize(): text=" + strText + ",fontName=" + fontName + ",fontSize=" + fontSize + ",w=" + w + ",h=" + h);
			return String.valueOf(w)+" " +String.valueOf(h);
		}
		
		log("NDBitmap.getStringSize() - leave");
		return "";
	}
	
	public static void test()
	{
		if (false)
		{
			NDTextTranslate.testFormatText( "你好jack" );
			NDTextTranslate.testFormatText( "<cff00ee你好<cff00ccjack" );
			NDTextTranslate.testFormatText( "<cff00ee你好/e<cff00ccjack/e" );
		}
		if (false)
		{
			//String strText = "<C#112233>hello</C><C#aabbcc>你好吗</C>";
			String strText = "坐騎加成的屬性在競技場、軍團戰等PVP活動中有效<cff0000(加成的屬性受寶石加成)/e。";
			//String strText = "hello你好吗";
			NDBitmap.createTextBitmap(strText, "", 0, 0, 200, 100);
		}
		if (false)
		{
			//String strText = "<C#112233>hello</C><C#aabbcc>你好吗</C>";
			String strText = "<C#112233>这是第一行</C>\n<C#223344>this is second line</C>";
			//String strText = "hello你好吗";
			NDBitmap.createTextBitmap(strText, "", 12, 0x33, 200, 100);
		}		
	}
	
	public static void log( final String str )
	{
		if (verbose)
			Log.d("ndbmp", str);
	}
}
