package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class BalanceInfo {
	private String paymentMode = "";
	private String paymentAmount = "";
	private String remark = "";
	private String operator = "";
	private String createTime = "";
	private String actionModeName;
	private int actionMode;
	private List<BalanceCardInfo> balanceCardInfoList = new ArrayList<BalanceCardInfo>();

	public BalanceInfo() {

	}

	public static ArrayList<BalanceInfo> parseListByJson(String src) {
		ArrayList<BalanceInfo> list = new ArrayList<BalanceInfo>();
		try {
			JSONObject tmp = new JSONObject(src);
			JSONArray jarrList = tmp.getJSONArray("OrderList");
			int count = jarrList.length();
			BalanceInfo item;
			for (int i = 0; i < count; i++) {
				item = new BalanceInfo();
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
			if (jsSrc.has("Amount")) {
				setPaymentAmount(jsSrc.getString("Amount"));
			}
			if (jsSrc.has("Mode")) {
				setPaymentMode(jsSrc.getString("Mode"));
			}
			if (jsSrc.has("Remark")) {
				setRemark(jsSrc.getString("Remark"));
			}
			if (jsSrc.has("Operator")) {
				setOperator(jsSrc.getString("Operator"));
			}
			if (jsSrc.has("CreateTime")) {
				setCreateTime(jsSrc.getString("CreateTime"));
			}
			if (jsSrc.has("ActionModeName"))
				setActionModeName(jsSrc.getString("ActionModeName"));
			if (jsSrc.has("ActionMode"))
				setActionMode(jsSrc.getInt("ActionMode"));
			if (jsSrc.has("BalanceCardList"))
				setBalanceCardList(jsSrc.getJSONArray("BalanceCardList"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setActionMode(int actionMode) {
		this.actionMode = actionMode;
	}

	public void setActionModeName(String actionModeName) {
		this.actionModeName = actionModeName;
	}

	public int getActionMode() {
		return actionMode;
	}

	public String getActionModeName() {
		return actionModeName;
	}

	public String getPaymentMode() {
		return paymentMode;
	}

	public void setPaymentMode(String paymentMode) {
		this.paymentMode = paymentMode;
	}

	public String getPaymentAmount() {
		return paymentAmount;
	}

	public void setPaymentAmount(String paymentAmount) {
		this.paymentAmount = paymentAmount;
	}

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public String getOperator() {
		return operator;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	public String getCreateTime() {
		return createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public void setBalanceCardList(JSONArray balanceCardInfoJson) {
		List<BalanceCardInfo> balanceCardInfo = new ArrayList<BalanceCardInfo>();
		try {
			int count = balanceCardInfoJson.length();
			BalanceCardInfo item = null;
			for (int i = 0; i < count; i++) {
				item = new BalanceCardInfo();
				item.parseByJson(balanceCardInfoJson.getJSONObject(i));
				balanceCardInfo.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		this.balanceCardInfoList = balanceCardInfo;
	}

	public List<BalanceCardInfo> getBalanceCardList() {
		return balanceCardInfoList;
	}

}
