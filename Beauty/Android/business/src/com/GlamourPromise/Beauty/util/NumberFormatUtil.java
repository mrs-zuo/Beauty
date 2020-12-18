package com.GlamourPromise.Beauty.util;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;


public class NumberFormatUtil {
	public static String currencyFormat(String sourceCurrency) {
		BigDecimal sourceCurrencyDouble=new BigDecimal(sourceCurrency);
		DecimalFormat decimalFormat = new DecimalFormat("0.00"); 
		return decimalFormat.format(sourceCurrencyDouble);
	}
	//double类型数值比较  0两个相等  >0 d1值大于d2  <0 d1值小于d2
	public static int  doubleCompare(double d1,double d2){
		return Double.compare(d1,d2);
	}
/*
 * 设置输入数字时，小数点后面可以输入的位数
 * */
 public static void setPricePoint(final EditText editText,final int limitNumber) {
        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                    int count) {
                if (s.toString().contains(".")) {
                    if (s.length() - 1 - s.toString().indexOf(".") >limitNumber) {
                        s = s.toString().subSequence(0,
                                s.toString().indexOf(".") + (limitNumber+1));
                        editText.setText(s);
                        editText.setSelection(s.length());
                    }
                }
                if (s.toString().trim().substring(0).equals(".")) {
                    s = "0" + s;
                    editText.setText(s);
                    editText.setSelection(2);
                }
 
                if (s.toString().startsWith("0")
                        && s.toString().trim().length() > 1) {
                    if (!s.toString().substring(1, 2).equals(".")) {
                        editText.setText(s.subSequence(0, 1));
                        editText.setSelection(1);
                        return;
                    }
                }
            }
 
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                    int after) {
 
            }
 
            @Override
            public void afterTextChanged(Editable s) {
                // TODO Auto-generated method stub
                 
            }
 
        });
    }
 /*
  * 设置输入数字时，小数点后面可以输入的位数
  * */
  public static void setPricePointArray(final EditText[] editText,final int limitNumber) {
	  for(int i=0;i<editText.length;i++){
		  final int editIndex=i;
         editText[i].addTextChangedListener(new TextWatcher() {
             @Override
             public void onTextChanged(CharSequence s, int start, int before,
                     int count) {
                 if (s.toString().contains(".")) {
                     if (s.length() - 1 - s.toString().indexOf(".") >limitNumber) {
                         s = s.toString().subSequence(0,
                                 s.toString().indexOf(".") + (limitNumber+1));
                         editText[editIndex].setText(s);
                         editText[editIndex].setSelection(s.length());
                     }
                 }
                 if (s.toString().trim().substring(0).equals(".")) {
                     s = "0" + s;
                     editText[editIndex].setText(s);
                     editText[editIndex].setSelection(2);
                 }
  
                 if (s.toString().startsWith("0")
                         && s.toString().trim().length() > 1) {
                     if (!s.toString().substring(1, 2).equals(".")) {
                    	 editText[editIndex].setText(s.subSequence(0, 1));
                    	 editText[editIndex].setSelection(1);
                         return;
                     }
                 }
             }
  
             @Override
             public void beforeTextChanged(CharSequence s, int start, int count,
                     int after) {
  
             }
  
             @Override
             public void afterTextChanged(Editable s) {
                 // TODO Auto-generated method stub
                  
             }
  
         });
       }
     }
}
