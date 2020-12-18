package com.glamourpromise.beauty.customer.bean;

import java.io.Serializable;
import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PaymentInfo implements Serializable {
	private static final long serialVersionUID = 1L;
	private String totalSalePrice;
	private String totalOrigPrice;
	private String totalCalePrice;
	private String unPaidPrice;
	private String expirationDate;
	private boolean isPay;
	private boolean isPartPay;
	private String salesPersonID;
	private String salesName;
	private String productCode;
	private String userCardNo;

	public PaymentInfo() {
	}

	public static ArrayList<PaymentInfo> parseListByJson(String src) {
		ArrayList<PaymentInfo> list = new ArrayList<PaymentInfo>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			PaymentInfo item;
			for (int i = 0; i < count; i++) {
				item = new PaymentInfo();
				item.parseByJson(jarrList.getJSONObject(i));
				list.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return list;
	}

	public boolean parseByJson(String src) {
		JSONObject jsSrc = null;
		try {
			jsSrc = new JSONObject(src);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return parseByJson(jsSrc);
	}

	public boolean parseByJson(JSONObject src) {
		try {
			JSONObject jsSrc = src;
			if (jsSrc.has("TotalSalePrice")) {
				setTotalSalePrice(jsSrc.getString("TotalSalePrice"));
			}
			if (jsSrc.has("UnPaidPrice")) {
				setUnPaidPrice(jsSrc.getString("UnPaidPrice"));
			}
			if (jsSrc.has("ExpirationDate")) {
				setExpirationDate(jsSrc.getString("ExpirationDate"));
			}
			if (jsSrc.has("IsPay")) {
				setIsPay(jsSrc.getBoolean("IsPay"));
			}
			if (jsSrc.has("IsPartPay")) {
				setIsPartPay(jsSrc.getBoolean("IsPartPay"));
			}
			if (jsSrc.has("SalesPersonID")) {
				setSalesPersonID(jsSrc.getString("SalesPersonID"));
			}
			if (jsSrc.has("SalesName")) {
				setSalesName(jsSrc.getString("SalesName"));
			}
			if (jsSrc.has("ProductCode")) {
				setProductCode(jsSrc.getString("ProductCode"));
			}
			if (jsSrc.has("TotalOrigPrice")) {
				setTotalOrigPrice(jsSrc.getString("TotalOrigPrice"));
			}
			if (jsSrc.has("totalCalPrice")) {
				setTotalCalPrice(jsSrc.getString("totalCalPrice"));
			}
			if (jsSrc.has("UserCardNo")) {
				setUserCardNo(jsSrc.getString("UserCardNo"));
			}

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setTotalSalePrice(String totalSalePrice) {
		this.totalSalePrice = totalSalePrice;
	}

	public void setUnPaidPrice(String unPaidPrice) {
		this.unPaidPrice = unPaidPrice;
	}

	public void setExpirationDate(String expirationDate) {
		this.expirationDate = expirationDate;
	}

	public void setIsPay(boolean isPay) {
		this.isPay = isPay;
	}

	public void setIsPartPay(boolean isPartPay) {
		this.isPartPay = isPartPay;
	}

	public void setSalesPersonID(String salesPersonID) {
		this.salesPersonID = salesPersonID;
	}

	public void setSalesName(String salesName) {
		this.salesName = salesName;
	}

	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}

	public String getTotalSalePrice() {
		return totalSalePrice;
	}

	public String getUnPaidPrice() {
		return unPaidPrice;
	}

	public String getExpirationDate() {
		return expirationDate;
	}

	public boolean getIsPay() {
		return isPay;
	}

	public boolean getIsPartPay() {
		return isPartPay;
	}

	public String getSalesPersonID() {
		return salesPersonID;
	}

	public String getSalesName() {
		return salesName;
	}

	public String getProductCode() {
		return productCode;
	}

	public void setTotalCalPrice(String calPrice) {
		this.totalCalePrice = calPrice;
	}

	public String getTotalCalPrice() {
		return totalCalePrice;
	}

	public void setTotalOrigPrice(String origPrice) {
		this.totalOrigPrice = origPrice;
	}

	public String getTotalOrigPrice() {
		return totalOrigPrice;
	}

	public void setUserCardNo(String userCardNo) {
		this.userCardNo = userCardNo;
	}

	public String getUserCardNo() {
		return userCardNo;
	}
}
