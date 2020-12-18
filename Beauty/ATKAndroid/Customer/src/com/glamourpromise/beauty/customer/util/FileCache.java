package com.glamourpromise.beauty.customer.util;

import java.io.File;

import android.content.Context;

public class FileCache {
	private File cacheDir;
	private static final String fileDir = "GlamourPromiseCustomer";
	public FileCache(Context context) {
		if (android.os.Environment.getExternalStorageState().equals(android.os.Environment.MEDIA_MOUNTED))
			cacheDir = new File(android.os.Environment.getExternalStorageDirectory(), fileDir);
		else
			cacheDir = context.getCacheDir();
		if (!cacheDir.exists())
			cacheDir.mkdirs();
	}

	public File getFile(String url) {
		String filename = String.valueOf(url.hashCode() + ".png");
		File f = new File(cacheDir, filename);
		return f;

	}
	
	public File getFileWithType(String url, String type) {
		String filename = String.valueOf(url+type);
		File f = new File(cacheDir, filename);
		return f;

	}
	
	public String getFilePath(String url){
		String path  = new StringBuilder(cacheDir.getAbsolutePath()).append("/").append(url).append(".png").toString();
		return path;
	}

	public void clear() {
		File[] files = cacheDir.listFiles();
		if (files == null)
			return;
		for (File f : files)
			f.delete();
	}
}