package cn.com.antika.util;
import com.nostra13.universalimageloader.core.DisplayImageOptions;

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