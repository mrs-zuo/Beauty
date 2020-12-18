package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

import android.os.Parcel;
import android.os.Parcelable;
/*
 * customer的地址信息
 * */
public  class AddressInfo implements Serializable {
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	public int    addressID;
	public int    addressType;//地址类型
	public String addressContent;//地址内容
	public String zipcode;//邮政编码
	public AddressInfo()
	{	
	}
}
