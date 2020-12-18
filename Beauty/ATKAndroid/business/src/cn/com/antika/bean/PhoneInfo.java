package cn.com.antika.bean;

import java.io.Serializable;
/*
 * customer的电话信息类
 * */
public class PhoneInfo implements Serializable {
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	public int    phoneID;
	public int    phoneType;
	public String phoneContent;
	public PhoneInfo()
	{
		
	}
}
