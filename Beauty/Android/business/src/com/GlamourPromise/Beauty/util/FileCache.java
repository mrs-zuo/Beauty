package com.GlamourPromise.Beauty.util;

import java.io.File;

import android.content.Context;
import android.os.Environment;

/*
 * 文件缓存类
 * */
public class FileCache {
	private File cacheDir;
	public FileCache(Context context) {
		if (android.os.Environment.getExternalStorageState().equals(
				android.os.Environment.MEDIA_MOUNTED))
			/*cacheDir = new File(
					android.os.Environment.getExternalStorageDirectory(),
					"LazyList");*/
			cacheDir = new File(
					android.os.Environment.getExternalStoragePublicDirectory
							(Environment.DIRECTORY_DOWNLOADS),
					"LazyList");
		else
			cacheDir = context.getCacheDir();
		if (!cacheDir.exists())
			cacheDir.mkdirs();
	}
	public File getFile(String url) {
		String filename = String.valueOf(url.hashCode());
		File f = new File(cacheDir, filename);
		return f;

	}
	public File getFileWithType(String url, String type) {
		String filename = String.valueOf(url+type);
		File f = new File(cacheDir, filename);
		return f;

	}
	public void clear() {
		File[] files = cacheDir.listFiles();
		if (files == null)
			return;
		for (File f : files)
			f.delete();
	}
}