package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.glamourpromise.beauty.customer.util.NumberFormatUtil;

public class EcardHistoryInformation {

	private String type;// 0:现金、1:消费
	private String rechargeText;
	private String productName;
	private String amount;
	private String balance;
	private String time;
	private String remark;
	private String changeTypeName;
	private String createTime;
	private int changeType;
	private int targetAccount;
	private int balanceID;
	private int orderCount;// 消费的订单数量
	private int paymentID;// 消费的ID
	private int rechargeID;// 冲值的ID
	private String mode = "";// 0:现金、1:银行卡、2:赠送、3:转入、4:消费、5:转出、6:退款

	public EcardHistoryInformation() {
		rechargeText = "";

	}

	public static ArrayList<EcardHistoryInformation> parseListByJson(String src) {
		ArrayList<EcardHistoryInformation> list = new ArrayList<EcardHistoryInformation>();
		try {
			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			EcardHistoryInformation item;
			for (int i = 0; i < count; i++) {
				item = new EcardHistoryInformation();
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
			if (jsSrc.has("Type")) {
				setType(jsSrc.getString("Type"));
			}
			if (jsSrc.has("RechargeText")) {
				setRechargeText(jsSrc.getString("RechargeText"));
			}
			if (jsSrc.has("Amount")) {
				setAmount(NumberFormatUtil
						.StringFormatToStringWithoutSingle(jsSrc
								.getString("Amount")));
			}
			if (jsSrc.has("Balance")) {
				setBalance(jsSrc.getString("Balance"));
			}
			if (jsSrc.has("Time")) {
				setTime(jsSrc.getString("Time"));
			}
			if (jsSrc.has("Mode")) {
				setMode(jsSrc.getString("Mode"));
			}
			if (jsSrc.has("OrderCount")) {
				setOrderCount(jsSrc.getInt("OrderCount"));
			}
			if (jsSrc.has("ID")) {
				setRechargeID(jsSrc.getInt("ID"));
			}
			if (jsSrc.has("PaymentID")) {
				setPaymentID(jsSrc.getInt("PaymentID"));
			}
			if (jsSrc.has("BalanceID"))
				setBalanceID(jsSrc.getInt("BalanceID"));
			if (jsSrc.has("ChangeTypeName"))
				setChangeTypeName(jsSrc.getString("ChangeTypeName"));
			if (jsSrc.has("CreateTime"))
				setCreateTime(jsSrc.getString("CreateTime"));
			if (jsSrc.has("ChangeType"))
				setChangeType(jsSrc.getInt("ChangeType"));
			if (jsSrc.has("TargetAccount"))
				setTargetAccount(jsSrc.getInt("TargetAccount"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setBalanceID(int balanceID) {
		this.balanceID = balanceID;
	}

	public void setChangeTypeName(String changeTypeName) {
		this.changeTypeName = changeTypeName;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public void setChangeType(int changeType) {
		this.changeType = changeType;
	}

	public void setTargetAccount(int targetAccount) {
		this.targetAccount = targetAccount;
	}

	public int getBalanceID() {
		return balanceID;
	}

	public String getChangeTypeName() {
		return changeTypeName;
	}

	public String getCreateTime() {
		return createTime;
	}

	public int getChangeType() {
		return changeType;
	}

	public int getTargetAccount() {
		return targetAccount;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getRechargeText() {
		return rechargeText;
	}

	public void setRechargeText(String rechargeText) {
		this.rechargeText = rechargeText;
	}

	public String getAmount() {
		return amount;
	}

	public void setAmount(String amount) {
		this.amount = amount;
	}

	public String getBalance() {
		return balance;
	}

	public void setBalance(String balance) {
		this.balance = balance;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public String getRemark() {
		return remark;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public int getOrderCount() {
		return orderCount;
	}

	public void setOrderCount(int orderCount) {
		this.orderCount = orderCount;
	}

	public int getPaymentID() {
		return paymentID;
	}

	public void setPaymentID(int paymentID) {
		this.paymentID = paymentID;
	}

	public String getMode() {
		return mode;
	}

	public void setMode(String mode) {
		this.mode = mode;
	}

	public int getRechargeID() {
		return rechargeID;
	}

	public void setRechargeID(int rechargeID) {
		this.rechargeID = rechargeID;
	}

}
