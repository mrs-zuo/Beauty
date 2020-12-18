package cn.com.antika.implementation;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Handler;
import android.os.Message;

import cn.com.antika.bean.WebDataObject;
import cn.com.antika.manager.BaseDownloadDataTask;

public class RechargeEcardTask extends BaseDownloadDataTask{
	private static final String METHOD_NAME = "CardRecharge";
	private static final String METHOD_PARENT_NAME = "ECard";
	private int    mChangeType;//账户操作类型  1:帐户消费、2:帐户消费撤销、3：帐户充值、4：帐户充值撤销、5：帐户直扣、6：帐户直扣撤销)  此接口只接受ChangeType==3 或者 ChangeType==5
	private int    mCardType;//被操作卡的类型    1:储值卡 2:积分卡 3:现金券卡
	private int    mDepositMode;//1:现金 2:银行卡 3:余额转入  4:其他--目前定义为赠送
	private String mUserCardNo;//被操作的卡号
	private int    mCustomerID;
	private int    mResponsiblePersonID;//充值的美丽顾问
	private String mAmount;//充值金额
	private String mRemark;
	private String mSlaveIDs;
	private int    mAverageFlag;
	private Double    mBranchProfitRate;
	private JSONArray mGiveJsonArray;
	private Handler mHandler;
	private RechargeEcardTask(Builder builder) {
		super(METHOD_NAME, METHOD_PARENT_NAME);
		mChangeType=builder.getChangeType();
		mCardType=builder.getCardType();
		mDepositMode=builder.getDepositMode();
		mUserCardNo=builder.getUserCardNo();
		mCustomerID = builder.getCustomerID();
		mResponsiblePersonID = builder.getResponsiblePersonID();
		mAmount = builder.getAmount();
		mRemark = builder.getRemark();
		mSlaveIDs = builder.getSlaveIDs();
		mAverageFlag = builder.getAverageFlag();
		mBranchProfitRate = builder.getBranchProfitRate();
		mHandler = builder.getHandler();
		mGiveJsonArray=builder.getGiveJsonArray();
	}
	
	public static class Builder{
		private int    mChangeType;
		private int    mCardType;
		private int    mDepositMode;
		private String mUserCardNo;
		private int    mCustomerID;
		private int    mResponsiblePersonID;
		private String mAmount;
		private String mRemark;
		private String mSlaveIDs;
		private int    mAverageFlag;
		private Double    mBranchProfitRate;
		private JSONArray mGiveJsonArray;
		private Handler mHandler;
		public Builder(){
			
		}
		public RechargeEcardTask create(){
			return new RechargeEcardTask(this);
		}
		public Builder setChangeType(int changeType) {
			mChangeType = changeType;
			return this;
		}
		public Builder setCardType(int cardType) {
			mCardType = cardType;
			return this;
		}
		public Builder setCustomerID(int customerID) {
			mCustomerID =customerID;
			return this;
		}
		public Builder setDepositMode(int depositMode) {
			mDepositMode =depositMode;
			return this;
		}
		public Builder setUserCardNo(String userCardNo) {
			mUserCardNo = userCardNo;
			return this;
		}
		public Builder setAmount(String amount) {
			mAmount = amount;
			return this;
		}
		public Builder setRemark(String remark) {
			mRemark = remark;
			return this;
		}
		public Builder setResponsiblePersonID(int responsiblePersonID) {
			mResponsiblePersonID = responsiblePersonID;
			return this;
		}
		public Builder setSlaveIDs(String slaveIDs) {
			mSlaveIDs = slaveIDs;
			return this;
		}
		public Builder setAverageFlag(int averageFlag) {
			mAverageFlag = averageFlag;
			return this;
		}
		public Builder setBranchProfitRate(Double branchProfitRate) {
			mBranchProfitRate = branchProfitRate;
			return this;
		}
		public Builder setGiveJsonArray(JSONArray giveJsonArray) {
			mGiveJsonArray=giveJsonArray;
			return this;
		}
		public int getChangeType() {
			return mChangeType;
		}
		public int getCardType() {
			return mCardType;
		}	
		public int getDepositMode() {
			return mDepositMode;
		}
		public String getUserCardNo() {
			return mUserCardNo;
		}
		public int getCustomerID() {
			return mCustomerID;
		}
		public int getResponsiblePersonID() {
			return mResponsiblePersonID;
		}
		
		public String getAmount() {
			return mAmount;
		}
		public String getRemark() {
			return mRemark;
		}
		public JSONArray getGiveJsonArray() {
			return mGiveJsonArray;
		}
		public String getSlaveIDs() {
			return mSlaveIDs;
		}
		public int getAverageFlag() {
			return mAverageFlag;
		}
		public Double getBranchProfitRate() {
			return mBranchProfitRate;
		}
		public Handler getHandler() {
			return mHandler;
		}
		public Builder setHandler(Handler handler) {
			mHandler = handler;
			return this;
		}
		
		
	}

	@Override
	protected Object getParamObject() {
		// TODO Auto-generated method stub
		JSONObject rechargeJsonParam =null;
		try {
			rechargeJsonParam = new JSONObject();
			//基本条件
			rechargeJsonParam.put("ChangeType",mChangeType);
			rechargeJsonParam.put("CardType",mCardType);
			rechargeJsonParam.put("DepositMode",mDepositMode);
			rechargeJsonParam.put("UserCardNo",mUserCardNo);
			rechargeJsonParam.put("CustomerID",mCustomerID);
			rechargeJsonParam.put("ResponsiblePersonID",mResponsiblePersonID);
			rechargeJsonParam.put("Amount",mAmount);
			rechargeJsonParam.put("Remark",mRemark);
			rechargeJsonParam.put("AverageFlag",mAverageFlag);
			rechargeJsonParam.put("BranchProfitRate",mBranchProfitRate);
			if(mSlaveIDs == null || mSlaveIDs.equals(""))
				rechargeJsonParam.put("Slavers", "");
			else{
				JSONArray tmp = new JSONArray(mSlaveIDs);
				rechargeJsonParam.put("Slavers",tmp);
			}
			if(mDepositMode!=3 && mGiveJsonArray.length()!=0){
				rechargeJsonParam.put("GiveList",mGiveJsonArray);
			}
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return rechargeJsonParam;
	}

	@Override
	protected void handleResult(WebDataObject webData) {
		// TODO Auto-generated method stub
		Message msg = mHandler.obtainMessage();
		msg.what = webData.code;
		msg.obj = webData.result;
		msg.sendToTarget();
	}
}
