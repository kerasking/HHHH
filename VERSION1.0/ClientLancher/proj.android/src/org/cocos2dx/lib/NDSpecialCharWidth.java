/****************************************************************************
* NDSpecialCharWidth.java
****************************************************************************/
package org.cocos2dx.lib;

import java.util.*;

public class NDSpecialCharWidth 
{
	private static boolean initFlag = false;
	private static HashMap mapChar = new HashMap();
	
	private static class CharInfo
	{
		char c;
		float rate;
	}
	
	private static void add( final char c, final float rate )
	{
		String key = ""+c;
		String value = ""+rate;
		mapChar.put( key, value );
	}
	
	private static void init()
	{
		if (!initFlag)
		{
			doInit();
			initFlag = true;
		}
	}
	
	private static void doInit()
	{
		add('A', 1.00f); 	add('a', 0.55f);
		add('B', 1.00f); 	add('b', 0.60f);
		add('C', 1.00f); 	add('c', 0.55f);
		add('D', 1.00f); 	add('d', 0.55f);
		add('E', 1.00f); 	add('e', 0.60f);
		add('F', 1.00f); 	add('f', 0.60f);
		add('G', 1.00f); 	add('g', 0.60f);
		
		add('H', 1.00f); 	add('h', 0.60f);
		add('I', 0.80f); 	add('i', 0.50f);
		add('J', 0.70f); 	add('j', 0.40f);
		add('K', 1.00f); 	add('k', 0.60f);
		add('L', 1.00f); 	add('l', 0.40f);
		add('M', 1.00f); 	add('m', 0.60f);
		add('N', 1.00f); 	add('n', 0.60f);
		
		add('O', 1.00f); 	add('o', 0.60f);
		add('P', 1.00f); 	add('p', 0.60f);
		add('Q', 1.00f); 	add('q', 0.60f);
		add('R', 1.00f); 	add('r', 0.55f);
		add('S', 1.00f); 	add('s', 0.60f);
		add('T', 1.00f); 	add('t', 0.60f);
		
		add('U', 1.00f); 	add('u', 0.60f);
		add('V', 1.00f); 	add('v', 0.60f);
		add('W', 1.00f); 	add('w', 0.85f);
		add('X', 1.00f); 	add('x', 0.60f);
		add('Y', 1.00f); 	add('y', 0.60f);
		add('Z', 1.00f); 	add('z', 0.60f);
		
		add('0', 0.85f);
		add('1', 0.6f);
		add('2', 0.65f);
		add('3', 0.65f);
		add('4', 0.65f);
		add('5', 0.65f);
		add('6', 0.65f);
		add('7', 0.65f);
		add('8', 0.65f);
		add('9', 0.65f);
		
		add('(', 0.90f);	add(')', 0.90f);
		add('[', 0.70f);	add(']', 0.70f);
		add('<', 0.70f);	add('>', 0.75f);
		add('+', 0.70f);	add('-', 0.70f);
		add('.', 0.40f);	add(',', 0.40f);
		add('=', 0.70f);	add(':', 0.60f);
		add('/', 0.70f);	add('\\', 0.70f);
		add('%', 1.00f);	add('\'', 0.60f);
	}
	
	public static int fixCharWidth( final char c, final int width )
	{
		init();
		
		String key = ""+c;
		String value = (String) mapChar.get( key );
		if (value.length() > 0)
		{
			float rate = Float.valueOf(value);
			return Math.max(1, (int)(width * rate));
		}
		return width;
	}
}
