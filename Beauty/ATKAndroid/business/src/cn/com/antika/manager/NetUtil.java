package cn.com.antika.manager;

import java.util.Comparator;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.Future;
import java.util.concurrent.PriorityBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import android.os.Message;

/**下载webservice数据的工具类
 * 
 * @author hongchuan.du
 *
 */
public class NetUtil {
	protected static ThreadPoolExecutor mThreadExecutor;
	private  static BlockingQueue<Runnable> opsToRun;
	private static NetUtil sInstance;
	public interface onModelListener{
		public void handleResult(Message msg);
	}
	
	private  NetUtil(){
		if(mThreadExecutor == null){
			opsToRun = new PriorityBlockingQueue<Runnable>(10,new Comparator<Runnable>() {

				@Override
				public int compare(Runnable lhs, Runnable rhs) {
					// TODO Auto-generated method stub
					return 0;
				}
			}); 
			mThreadExecutor = new ThreadPoolExecutor(5, 5, 0, TimeUnit.SECONDS, opsToRun);
		}
			
	}
	
	/**
	 * 单例模式
	 * @return
	 */
	public static NetUtil getNetUtil(){
		if(sInstance == null){
			sInstance = new NetUtil();
		}
		return sInstance;
	}
	
	/**
	 * 添加新的下载数据任务
	 * @param task
	 * @return
	 */
	public Future<?> submitDownloadTask(Runnable task){
		
		return mThreadExecutor.submit(task);
	}
}
