package com.glamourpromise.beauty.customer.util;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ThreadExecutor {
	private static final int CORE_POOL_SIZE = 3;
	  private static final int MAX_POOL_SIZE = 5;
	  private static final int KEEP_ALIVE_TIME = 120;
	  private static final TimeUnit TIME_UNIT = TimeUnit.SECONDS;
	  private static final BlockingQueue<Runnable> WORK_QUEUE = new LinkedBlockingQueue<Runnable>();

	  private ThreadPoolExecutor threadPoolExecutor;

	  public ThreadExecutor() {
	    int corePoolSize = CORE_POOL_SIZE;
	    int maxPoolSize = MAX_POOL_SIZE;
	    int keepAliveTime = KEEP_ALIVE_TIME;
	    TimeUnit timeUnit = TIME_UNIT;
	    BlockingQueue<Runnable> workQueue = WORK_QUEUE;
	    threadPoolExecutor = new ThreadPoolExecutor(corePoolSize, maxPoolSize, keepAliveTime, timeUnit, workQueue);
	  }

	public void run(final Runnable task) {
		if (task == null) {
			throw new IllegalArgumentException("task to execute can't be null");
		}
		threadPoolExecutor.submit(task);
	}
	
	public void cancelAllTask(){
		WORK_QUEUE.clear();
//		threadPoolExecutor.shutdownNow();
	}
}
