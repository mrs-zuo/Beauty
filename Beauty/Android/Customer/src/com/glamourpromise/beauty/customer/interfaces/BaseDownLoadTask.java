package com.glamourpromise.beauty.customer.interfaces;

import com.glamourpromise.beauty.customer.util.FileCache;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;

/**
 * @author hongchuan.du
 * 下载任务接口；新增的下载任务实现相应的接口
 */
public abstract class BaseDownLoadTask {
	protected FileCache fileCache;
	protected DownFileTaskProgressCallback mProgressCallback;
	@SuppressLint("HandlerLeak")
	private Handler mHandler = new Handler(){
		 public void handleMessage(Message msg) {  
			switch (msg.what) {
			case -1:
				onExecuteError();
				break;
			// 任务完成
			case 0:
				onPostExecute();
				break;
			// 任务进度更新
			case 1:
				onProgressUpdate(msg.arg1);
				break;
			default:
				break;
			}
		} 
	};
	
	/**
	 * 后台下载任务处理
	 * 需在新线程中调用
	 */
	public abstract void  runInBackend();
	
	/**
	 * 下载结束处理
	 */
	final private void  onPostExecute(){
		mProgressCallback.onPostExecute();
	}
	
	/**
	 * 更新操作过程
	 * @param progress
	 */
	final private void onProgressUpdate(int progress){
		mProgressCallback.onProgressUpdate(progress);
	}
	
	/**
	 * 错误处理
	 */
	final private void onExecuteError(){
		mProgressCallback.onExecuteError();
	}
	
	/**
	 * 如果需要更新操作过程，则在runInBackend()中调用该方法
	 * @param progress
	 */
	final protected void publishProgress(int progress) {
		if(mHandler != null)
			mHandler.obtainMessage(1, progress,0).sendToTarget();
	}
	
	final protected void publishError() {
		if(mHandler != null)
			mHandler.obtainMessage(-1).sendToTarget();
	}
	
	/**
	 * 执行
	 */
	final public void execute(){
		new Thread(){

			@Override
			public void run() {
				// TODO Auto-generated method stub
				runInBackend();
				if(mHandler != null)
					mHandler.obtainMessage(0).sendToTarget();
			}
			
		}.start();
	}
	
	public BaseDownLoadTask(FileCache fileCache, DownFileTaskProgressCallback progressCallback){
		this.fileCache = fileCache;
		mProgressCallback = progressCallback;
	}
	
	public interface DownFileTaskProgressCallback{
		/**
		 * 下载结束处理
		 */
		public void  onPostExecute();
		
		/**
		 * 更新操作过程
		 * @param progress
		 */
		public void onProgressUpdate(int progress);
		
		/**
		 * 错误处理
		 */
		public void onExecuteError();
	}
}
