package com.GlamourPromise.Beauty.util;


import android.graphics.Bitmap;

import com.nostra13.universalimageloader.core.DisplayImageOptions;

/*
 *
 * 使用缓存的图片显示类
 * */
public class ImageLoaderUtil {
    public static DisplayImageOptions getDisplayImageOptions(int defaultImageResources) {
        DisplayImageOptions displayImageOptions = new DisplayImageOptions.Builder()
                .showImageForEmptyUri(defaultImageResources)
                .showImageOnFail(defaultImageResources)
                .cacheInMemory(true).cacheOnDisk(true).bitmapConfig(Bitmap.Config.RGB_565).build();
        //displayer(new FadeInBitmapDisplayer(1000));图片显示前的动画展示
        return displayImageOptions;
    }
}