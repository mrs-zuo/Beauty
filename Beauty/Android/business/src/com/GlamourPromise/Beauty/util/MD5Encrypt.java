/**
 * MD5Encrypt.java
 * com.GlamourPromise.Beauty.util
 * tim.zhang@bizapper.com
 * 2015年3月4日 上午11:21:36
 * @version V1.0
 */
package com.GlamourPromise.Beauty.util;

import java.security.MessageDigest;

/**
 * MD5Encrypt TODO
 * 
 * @author tim.zhang@bizapper.com 2015年3月4日 上午11:21:36
 */
public class MD5Encrypt {
	public static String md5Encrypt(String source) {
		char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9','A', 'B', 'C', 'D', 'E', 'F' };
		try {
			byte[] btInput = source.getBytes();
			// 获得MD5摘要算法的 MessageDigest 对象
			MessageDigest md5Inst = MessageDigest.getInstance("MD5");
			// 使用指定的字节更新摘要
			md5Inst.update(btInput);
			// 获得密文
			byte[] md = md5Inst.digest();
			// 把密文转换成十六进制的字符串形式
			int j = md.length;
			char str[] = new char[j * 2];
			int k = 0;
			for (int i = 0; i < j; i++) {
				byte byte0 = md[i];
				str[k++] = hexDigits[byte0 >>> 4 & 0xf];
				str[k++] = hexDigits[byte0 & 0xf];
			}
			return new String(str);
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
