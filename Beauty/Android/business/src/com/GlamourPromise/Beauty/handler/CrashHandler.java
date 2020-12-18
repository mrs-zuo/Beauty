package com.GlamourPromise.Beauty.handler;
import java.lang.Thread.UncaughtExceptionHandler;
/*
 * android 全局Exception Handler
 * */
public class CrashHandler implements UncaughtExceptionHandler{
	private static UncaughtExceptionHandler mDefaultUncaughtExceptionHandler;
	/** Debug Log Tag */  
    public static final String TAG = "CrashHandler";
    /** 是否开启日志输出, 在Debug状态下开启, 在Release状态下关闭以提升程序性能 */  
    public static final boolean DEBUG = true;  
    /** CrashHandler实例 */  
    private static CrashHandler INSTANCE; 
    private CrashHandler() {  
    }  
    /** 获取CrashHandler实例 ,单例模式 */  
    public static CrashHandler getInstance() {  
        if (INSTANCE == null)  
            INSTANCE = new CrashHandler();  
        return INSTANCE;  
    }  
    
	public void init() {
		/*
		 * 弹出解决方案之后把崩溃继续交给系统处理， 所以保存当前UncaughtExceptionHandler用于崩溃发生时使用。
		 */
		mDefaultUncaughtExceptionHandler = Thread.getDefaultUncaughtExceptionHandler();
		Thread.setDefaultUncaughtExceptionHandler(this);
	}
    
    /** 
     * 当UncaughtException发生时会转入该函数来处理 
     */  
    @Override  
    public void uncaughtException(Thread thread, Throwable ex) {
		// 传递给保存的UncaughtExceptionHandler
		mDefaultUncaughtExceptionHandler.uncaughtException(thread, ex);
		// android.os.Process.killProcess(android.os.Process.myPid());
		// System.exit(10);
    }  
}
