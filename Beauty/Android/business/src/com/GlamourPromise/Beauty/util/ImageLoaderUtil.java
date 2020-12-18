package com.GlamourPromise.Beauty.util;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;
/*
 * 
 * 使用缓存的图片显示类
 * */
public class ImageLoaderUtil {
	public static DisplayImageOptions getDisplayImageOptions(int defaultImageResources) {
		DisplayImageOptions displayImageOptions= new DisplayImageOptions.Builder()
				.showImageForEmptyUri(defaultImageResources)
				.showImageOnFail(defaultImageResources)
				.cacheInMemory(true).cacheOnDisc(true).build();
		//displayer(new FadeInBitmapDisplayer(1000));图片显示前的动画展示
		return displayImageOptions;
	}
}