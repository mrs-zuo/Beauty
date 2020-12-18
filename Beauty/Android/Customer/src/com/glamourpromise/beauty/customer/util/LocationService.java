package com.glamourpromise.beauty.customer.util;
import android.app.Activity;

import com.baidu.location.BDLocation;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.baidu.location.LocationClientOption.LocationMode;
import com.glamourpromise.beauty.customer.application.UserInfoApplication;

public class LocationService {
	private LocationMode tempMode = LocationMode.Hight_Accuracy;
    private String tempcoor="gcj02";
    private LocationClient mLocationClient;
	public BDLocation getBaiDuLocation(Activity context){
		 	mLocationClient = ((UserInfoApplication)context.getApplication()).mLocationClient;
		 	LocationClientOption option = new LocationClientOption();
	        option.setLocationMode(tempMode);//可选，默认高精度，设置定位模式，高精度，低功耗，仅设备
	        option.setCoorType(tempcoor);//可选，默认gcj02，设置返回的定位结果坐标系，	        
	        option.setScanSpan(1000);//可选，默认0，即仅定位一次，设置发起定位请求的间隔需要大于等于1000ms才是有效的
	        option.setIsNeedAddress(true);//可选，设置是否需要地址信息，默认不需要
	        option.setOpenGps(false);//可选，默认false,设置是否使用gps
	        option.setLocationNotify(true);//可选，默认false，设置是否当gps有效时按照1S1次频率输出GPS结果
	        option.setIgnoreKillProcess(true);//可选，默认true，定位SDK内部是一个SERVICE，并放到了独立进程，设置是否在stop的时候杀死这个进程，默认不杀死
	        mLocationClient.setLocOption(option);
	        mLocationClient.start();//定位SDK start之后会默认发起一次定位请求，开发者无须判断isstart并主动调用request
            mLocationClient.requestLocation();
            BDLocation  bdLocation=mLocationClient.getLastKnownLocation();
            return bdLocation;
	}
}
