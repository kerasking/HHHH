package tw.mobage.g23000052;

import org.DeNA.DHLJ.DaHuaLongJiang;

import android.app.Application;
import android.view.WindowManager;

public class MainActivity extends DaHuaLongJiang {
	
	/**
	 * 创建全局变量
	 * 全局变量一般都比较倾向于创建一个单独的数据类文件，并使用static静态变量
	 * 
	 * 这里使用了在Application中添加数据的方法实现全局变量
	 * 注意在AndroidManifest.xml中的Application节点添加android:name=".MyApplication"属性
	 * 
	 */
}
