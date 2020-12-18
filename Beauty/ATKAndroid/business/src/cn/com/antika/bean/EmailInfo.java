package cn.com.antika.bean;

import java.io.Serializable;
/*
 * customer的电子邮件信息类
 * 
 * */
public class EmailInfo implements Serializable {
	/**
	 * serialVersionUID
	 */
	private static final long serialVersionUID = 1L;
	public int    emailID;//邮件地址主键
	public int    emailType;//邮件地址类型
	public String emailContent;//邮件地址内容
	public EmailInfo()
	{
		
	}
}
