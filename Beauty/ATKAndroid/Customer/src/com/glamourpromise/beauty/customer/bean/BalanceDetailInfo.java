package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class BalanceDetailInfo {

	private String branchName;
	private String targetAccount;
	private String createTime;
	private String operator;
	private String remark;
	private String changeTypeName;
	private String paymentID;
	private String amount;
	private int balanceID;
	private String balanceNumber;
	private List<BalanceInfo> balanceInfoList = new ArrayList<BalanceInfo>();
	private List<OrderBaseInfo> orderList = new ArrayList<OrderBaseInfo>();

	public BalanceDetailInfo() {

	}

	public static ArrayList<BalanceDetailInfo> parseListByJson(String src) {
		ArrayList<BalanceDetailInfo> list = new ArrayList<BalanceDetailInfo>();
		try {
			JSONObject tmp = new JSONObject(src);
			JSONArray jarrList = tmp.getJSONArray("OrderList");
			int count = jarrList.length();
			BalanceDetailInfo item;
			for (int i = 0; i < count; i++) {
				item = new BalanceDetailInfo();
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
			if (jsSrc.has("BalanceNumber"))
				setBalanceNumber(jsSrc.getString("BalanceNumber"));
			if (jsSrc.has("BalanceID"))
				setBalanceID(jsSrc.getInt("BalanceID"));
			if (jsSrc.has("Amount"))
				setAmount(jsSrc.getString("Amount"));
			if (jsSrc.has("PaymentID"))
				setPaymentID(jsSrc.getString("PaymentID"));
			if (jsSrc.has("ChangeTypeName"))
				setChangeTypeName(jsSrc.getString("ChangeTypeName"));
			if (jsSrc.has("Remark"))
				setRemark(jsSrc.getString("Remark"));
			if (jsSrc.has("Operator"))
				setOperator(jsSrc.getString("Operator"));
			if (jsSrc.has("CreateTime"))
				setCreateTime(jsSrc.getString("CreateTime"));
			if (jsSrc.has("TargetAccount"))
				setTargetAccount(jsSrc.getString("TargetAccount"));
			if (jsSrc.has("BranchName"))
				setBranchName(jsSrc.getString("BranchName"));
			if (jsSrc.has("ProfitList"))
				setProfitList(jsSrc.getString("ProfitList"));
			List<BalanceInfo> balanceInfo = new ArrayList<BalanceInfo>();
			if(jsSrc.has("BalanceMain") && !jsSrc.isNull("BalanceMain")){
				BalanceInfo itemA = new BalanceInfo();
				itemA.parseByJson(jsSrc.getJSONObject("BalanceMain"));
				balanceInfo.add(itemA);
			}
			if(jsSrc.has("BalanceSec") && !jsSrc.isNull("BalanceSec")){
				BalanceInfo itemB=new BalanceInfo();
				itemB.parseByJson(jsSrc.getJSONObject("BalanceSec"));
				balanceInfo.add(itemB);
			}
			this.balanceInfoList=balanceInfo;
			if (jsSrc.has("OrderList") && !jsSrc.isNull("OrderList"))
				setOrderList(jsSrc.getJSONArray("OrderList"));
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setOrderList(JSONArray mOrderList) {
		List<OrderBaseInfo> orderListInfo = new ArrayList<OrderBaseInfo>();
		try {
			int count = mOrderList.length();
			OrderBaseInfo item = null;
			for (int i = 0; i < count; i++) {
				item = new OrderBaseInfo();
				item.parseByJson(mOrderList.getJSONObject(i));
				orderListInfo.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		this.orderList = orderListInfo;
	}

	public List<OrderBaseInfo> getOrderList() {
		return orderList;
	}

	public void setBalanceInfoList(JSONArray balanceInfoJson) {
		List<BalanceInfo> balanceInfo = new ArrayList<BalanceInfo>();
		try {
			int count = balanceInfoJson.length();
			BalanceInfo item = null;
			for (int i = 0; i < count; i++) {
				item = new BalanceInfo();
				item.parseByJson(balanceInfoJson.getJSONObject(i));
				balanceInfo.add(item);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		this.balanceInfoList = balanceInfo;
	}

	public List<BalanceInfo> getBalanceInfoList() {
		return balanceInfoList;
	}

	public void setProfitList(String profitList) {
		// TODO Auto-generated method stub

	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;

	}

	public void setTargetAccount(String targetAccount) {
		this.targetAccount = targetAccount;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public void setOperator(String operator) {
		this.operator = operator;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public void setChangeTypeName(String changeTypeName) {
		this.changeTypeName = changeTypeName;
	}

	public void setPaymentID(String paymentID) {
		this.paymentID = paymentID;
	}

	public void setAmount(String amount) {
		this.amount = amount;
	}

	public void setBalanceID(int balanceID) {
		this.balanceID = balanceID;
	}

	public void setBalanceNumber(String balanceNumber) {
		this.balanceNumber = balanceNumber;
	}

	public void getProfitList(String profitList) {
		// TODO Auto-generated method stub

	}

	public String getBranchName() {
		return branchName;

	}

	public String getTargetAccount() {
		return targetAccount;
	}

	public String getCreateTime() {
		return createTime;
	}

	public String getOperator() {
		return operator;
	}

	public String getRemark() {
		return remark;
	}

	public String getChangeTypeName() {
		return changeTypeName;
	}

	public String getPaymentID() {
		return paymentID;
	}

	public String getAmount() {
		return amount;
	}

	public int getBalanceID() {
		return balanceID;
	}

	public String getBalanceNumber() {
		return balanceNumber;
	}

}
