package com.glamourpromise.beauty.customer.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;

import com.glamourpromise.beauty.customer.application.UserInfoApplication;

import android.app.Activity;

public class NumberFormatUtil {
	public static String currencyFormat(Activity content, double sourceCurrency) {
		BigDecimal bigDecimal=new BigDecimal(String.valueOf(sourceCurrency));
		DecimalFormat decimalFormat = new DecimalFormat("0.00"); 
		return  ((UserInfoApplication)content.getApplication()).getLoginInformation().getCurrencySymbols() + decimalFormat.format(bigDecimal);
	}
	
	//不带"¥"符号
	public static String StringFormatToStringWithoutSingle(String sourceCurrency) {
		if(sourceCurrency == null ||sourceCurrency.equals("")){
			return "";
		}
		NumberFormat nf = NumberFormat.getInstance();
		nf.setMaximumFractionDigits(2);
		BigDecimal bigDecimal=new BigDecimal(sourceCurrency);
		DecimalFormat decimalFormat = new DecimalFormat("0.00"); 
		return decimalFormat.format(bigDecimal);
	}
	
	//不带"¥"符号
	public static String FloatFormatToStringWithoutSingle(double sourceCurrency) {
		DecimalFormat decimalFormat = new DecimalFormat("0.00");
		BigDecimal bigDecimal=new BigDecimal(String.valueOf(sourceCurrency));
		return decimalFormat.format(bigDecimal);
	}

	public static String StringFormatToString(Activity content, String sourceCurrency) {
		if(sourceCurrency == null ||sourceCurrency.equals("")){
			return "";
		}
		NumberFormat nf = NumberFormat.getInstance();
		nf.setMaximumFractionDigits(2);
		BigDecimal bigDecimal=new BigDecimal(sourceCurrency);
		DecimalFormat decimalFormat = new DecimalFormat("0.00"); 
		return ((UserInfoApplication)content.getApplication()).getLoginInformation().getCurrencySymbols() + decimalFormat.format(bigDecimal);
	}
}
