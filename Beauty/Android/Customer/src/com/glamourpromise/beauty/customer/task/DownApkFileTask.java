package com.glamourpromise.beauty.customer.task;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import com.glamourpromise.beauty.customer.constant.Constant;
import com.glamourpromise.beauty.customer.interfaces.BaseDownLoadTask;
import com.glamourpromise.beauty.customer.util.FileCache;

public class DownApkFileTask extends BaseDownLoadTask{
	private static StringBuilder apkUrl = new StringBuilder();
	
	public DownApkFileTask(FileCache fileCache, DownFileTaskProgressCallback progressCallback ,String apkURL) {
		super(fileCache, progressCallback);
//		apkUrl.append(Constant.OUT_SERVER_URL);
//		apkUrl.append("/download/android/customer.apk");
		apkUrl.append(apkURL);
	}

	@Override
	public void runInBackend() {
		try {
			URL imageUrl = new URL(String.valueOf(apkUrl));
			HttpURLConnection conn = (HttpURLConnection) imageUrl.openConnection();
			conn.setInstanceFollowRedirects(true);
			conn.setRequestMethod("GET");
			conn.setDoInput(true);
			conn.connect();

			InputStream is = conn.getInputStream();
			int apkFileSize = conn.getContentLength();
			File file = fileCache.getFileWithType(Constant.APK_FILE_NAME, ".apk");
			FileOutputStream fileOutPutStream = new FileOutputStream(file);

			byte[] buffer = new byte[4096];
			int len = 0;
			int count = 0;
			int downloadFileSize;
			do {
				len = is.read(buffer);
				if (len <= 0)
					break;
				fileOutPutStream.write(buffer, 0, len);
				count += len;
				downloadFileSize =(int)(((float)count / apkFileSize) * 100); 
				publishProgress(downloadFileSize);
			} while (true);

			is.close();
			fileOutPutStream.close();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			publishError();
		}
	}
}
