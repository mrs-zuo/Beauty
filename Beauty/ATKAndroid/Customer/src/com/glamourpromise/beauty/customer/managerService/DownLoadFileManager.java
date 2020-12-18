package com.glamourpromise.beauty.customer.managerService;

import com.glamourpromise.beauty.customer.interfaces.BaseDownLoadTask;
import com.glamourpromise.beauty.customer.interfaces.BaseDownLoadTask.DownFileTaskProgressCallback;
import com.glamourpromise.beauty.customer.task.DownApkFileTask;
import com.glamourpromise.beauty.customer.util.FileCache;

public class DownLoadFileManager {
	private static BaseDownLoadTask mDownLoadTask;
	public static final int TYPE_DOWNLOAD_APK_FILE = 1;

	public static void executeDownLoadTask(int type, FileCache fileCache,DownFileTaskProgressCallback progressCallback,String apkURL){
		switch (type) {
		case TYPE_DOWNLOAD_APK_FILE:
			mDownLoadTask = new DownApkFileTask(fileCache, progressCallback,apkURL);
			break;

		default:
			break;
		}
		mDownLoadTask.execute();
	}
}
