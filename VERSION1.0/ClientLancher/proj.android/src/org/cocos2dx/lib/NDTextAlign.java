/****************************************************************************
 * NDTextAlign.java
 * 
 * to calc text alignment
 ****************************************************************************/
package org.cocos2dx.lib;

import java.util.*;
import android.util.*;
import android.graphics.*;
import android.graphics.Paint.*;

import org.cocos2dx.lib.*;
import org.cocos2dx.lib.NDTextProxy.CharLine;
import org.cocos2dx.lib.NDTextProxy.CharProperty;

/**
 * NDTextParse: all method are static.
 */
public class NDTextAlign
{ 
	/* The values are the same as cocos2dx/platform/CCImage.h. */
	public static final int HORI_ALIGN_LEFT = 1;
	private static final int HORI_ALIGN_RIGHT = 2;
	private static final int HORI_ALIGN_CENTER = 3;
	private static final int VERT_ALIGN_TOP = 1;
	private static final int VERT_ALIGN_BOTTOM = 2;
	private static final int VERT_ALIGN_CENTER = 3;
	
	private static Paint paint;
	private static ArrayList<NDTextProxy.CharLine> charLineList;
	private static int uiMaxWidth = 0;
	private static int uiMaxHeight = 0; 
	private static int alignmentHorz = 0;
	private static int alignmentVert = 0;
	
	private static boolean withUILimit = false;
	private static int curLineY = 0;
	
	public static int bitmapWidth = 0;
	public static int bitmapHeight = 0;
	private static int calcTotalWidth = 0;
	private static int calcTotalHeight = 0;
	
	
	
	/**
	 * calcAlignment:	calculate multi-line text alignment
	 * @param paint				
	 * @param charLineList		: input multiple line text
	 * @param uiMaxWidth		: ui constraint width
	 * @param uiMaxHeight		: ui constraint height
	 * @param alignmentHorz		: alignment horizontal
	 * @param alignmentVert		: alignment vertical
	 */
	public static void calcAlignment( Paint in_paint, 
		ArrayList<NDTextProxy.CharLine> in_charLineList, 
		final int in_uiMaxWidth, final int in_uiMaxHeight, 
		final int in_alignmentHorz, final int in_alignmentVert)
	{
		log("NDTextAlign.calcAlignment() -- begin: horzAlign="+in_alignmentHorz + ", vertAlign=" + in_alignmentVert + "\r\n");
		
		paint = in_paint;
		charLineList = in_charLineList;
		uiMaxWidth = in_uiMaxWidth;
		uiMaxHeight = in_uiMaxHeight;
		alignmentHorz = in_alignmentHorz;
		alignmentVert = in_alignmentVert;
		
		withUILimit = (uiMaxWidth > 0);
		
		//
		log("calc each line size\r\n");
		for (NDTextProxy.CharLine charLine : charLineList)
		{
			calcCharLineSize( charLine );
		}
		
		//
		log("calc bitmap size\r\n");
		calcBitmapSize(paint);
		
		//
		log("calc start Y\r\n");
		curLineY = calcStartY();
		
		//
		log("calc each line alignment\r\n" );
		for (NDTextProxy.CharLine charLine : charLineList)
		{
			calcAlignment( charLine );
		}
		
		log("NDTextAlign.calcAlignment() -- leave\r\n");
	}
	
	/**
	 * calcStartY
	 */
	private static int calcStartY()
	{
		int startY = 0;
		
		// deal with vertical align
		switch (alignmentVert)	
		{
		case VERT_ALIGN_CENTER:
			{
				startY = (int) (0.5 * (uiMaxHeight - calcTotalHeight));
				startY = Math.max(0, startY);
			}
			break;
		case VERT_ALIGN_BOTTOM:
			{
				startY = (int) (uiMaxHeight - calcTotalHeight);
				startY = Math.max(0, startY);
			}
			break;
		}
		
		return startY;
	}
	
	/**
	 * calcAlignment:	calculate alignment
	 * @param charline
	 */
	private static void calcAlignment( NDTextProxy.CharLine charLine )
	{
		charLine.calcStartX = 0;
		charLine.calcStartY = curLineY;
				
		if (charLine.calcWidth < uiMaxWidth)
		{	
			// deal with horz align
			switch (alignmentHorz)
			{
			case HORI_ALIGN_CENTER: //center
				{
					charLine.calcStartX = (int) (0.5 * (uiMaxWidth - charLine.calcWidth));
					charLine.calcStartX = Math.max(0, charLine.calcStartX);
				}
				break;
				
			case HORI_ALIGN_RIGHT: //right
				{
					charLine.calcStartX = (int) (uiMaxWidth - charLine.calcWidth);
					charLine.calcStartX = Math.max(0, charLine.calcStartX);
				}
				break;
			}
		}
		
		// apply startX & startY
		if (charLine.calcStartX != 0 || charLine.calcStartY != 0)
		{
			for (CharProperty objChar : charLine.charList) 
			{
				if (!objChar.bLineFeed)
				{
					objChar.x += charLine.calcStartX;
					objChar.y += charLine.calcStartY;
				}
			}
		}	
		
		// move to next line
		curLineY += charLine.calcHeight;
	}
	
	
	/**
	 * calcCharLineSize: calculate char line size
	 * @param charLine
	 * @param uiMaxWidth
	 * @param uiMaxHeight
	 */
	public static void calcCharLineSize( NDTextProxy.CharLine charLine )
	{	
		// calc char height
		final FontMetricsInt fm = paint.getFontMetricsInt();
		final int fontHeight = (int) Math.ceil(fm.bottom - fm.top);

		charLine.lineCount = 1;
		charLine.calcWidth = 0;
		charLine.calcHeight = 0;
		
		int x = 0;
		int y = (int) (-fm.top * 1);//@tune
		
		for ( CharProperty objChar : charLine.charList ) 
		{
			objChar.x = x;
			objChar.y = y;
			objChar.h = fontHeight;
			
			if (objChar.bLineFeed) continue;

			String str = String.valueOf( objChar.c );
			int charWidth = (int) FloatMath.ceil( paint.measureText( str, 0, str.length()));
			
			// fix width for special char
			if (objChar.bSpecialChar && NDBitmap.isVerOlder())
			{
				charWidth = NDSpecialCharWidth.fixCharWidth(objChar.c, charWidth, objChar.fontName); //@tune
			}
			
			//if ui width not enough, change line.
			if (withUILimit && (x + charWidth > uiMaxWidth))
			{
				// move to next line
				x = 0;
				y += fontHeight;
				charLine.lineCount++;
				
				// set xywh
				objChar.x = x;
				objChar.y = y;
				objChar.w = charWidth;
				objChar.h = fontHeight;
				
				// move forward
				x += charWidth;
			}
			else
			{
				// move forward
				objChar.w = charWidth;
				x += charWidth;								
			}
			
			charLine.calcWidth = Math.max(charLine.calcWidth, x);
		}//for
			
		charLine.calcHeight = Math.max(charLine.lineCount,1) * fontHeight;
	}
	
	/**
	 * calcBitmapSize
	 */
	private static void calcBitmapSize(Paint paint)
	{
		// calculate total widht & height
		calcTotalWidth = 0;
		calcTotalHeight = 0;
		for (CharLine charLine : charLineList)
		{
			calcTotalWidth = Math.max(charLine.calcWidth, calcTotalWidth);
			calcTotalHeight += charLine.calcHeight;
		}
		
		if (withUILimit)
		{
			bitmapWidth = uiMaxWidth;
			bitmapHeight = uiMaxHeight;			
		}
		else
		{
			bitmapWidth = calcTotalWidth;
			bitmapHeight = calcTotalHeight;
			
			// make sure not zero size.
			bitmapWidth = Math.max(bitmapWidth,10);
			bitmapHeight = Math.max(bitmapHeight, getFontHeight(paint));
		}
	}
	
	/**
	 * getFontHeight
	 * @param paint
	 * @return
	 */
	private static int getFontHeight( Paint paint )
	{
		final FontMetricsInt fm = paint.getFontMetricsInt();
		final int fontHeight = (int) Math.ceil(fm.bottom - fm.top);
		return fontHeight;
	}
	
	public static void log( final String str )
	{
		NDBitmap.log( str );
	}	
}
