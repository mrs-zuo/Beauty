package com.GlamourPromise.Beauty.bean;
import java.io.Serializable;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.GlamourPromise.Beauty.application.UserInfoApplication;

/*
 * 系统的账户类
 * */
public class AccountInfo implements Serializable {
	private static final long serialVersionUID = 1L;
	private int accountId;
	private int companyId;
	private int branchId;
	private String accountName;
	private String headImage;
	private String loginMobile;
	private String companyCode;//公司Code
	private String companyAbbreviation;//公司简称
	private int roleID;
	private int authReadHomePageServicingList = 0;//查看首页动态权限
	private int authMyCustomerRead = 0;// 查看我的顾客权限
	private int authAllCustomerRead = 0;// 查看所有顾客权限
	private int authAllCustomerInfoWrite = 0;//编辑顾客信息权限(所有)
	private int authAllCustomerContactInfoWrite=0;//编辑顾客的联系信息(所有)
	private int authAllCustomerRecordInfoWrite = 0;//编辑顾客专业记录权限(所有)
	private int authMyOrderRead = 0;// 查看顾客订单权限
	private int authMyOrderWrite = 0;//编辑我的订单权限
	private int authAllOrderWrite = 0;//编辑门店所有订单权限
	private int authPaymentUse = 0;// 使用结账功能权限
	private int authEcardRead = 0;// 查看顾客e卡账户信息
	private int authCustomerEcardAdd = 0;//创建顾客E卡账户
	private int authCustomerEcardWrite = 0;//编辑顾客的e卡账户
	private int authServiceRead = 0;// 查看和选择服务权限
	private int authCommodityRead = 0;// 查看和选择商品权限
	private int authOpportunityUse = 0;// 使用商机功能权限
	private int authChatUse = 0;// 使用飞语功能权限
	private int authMarketingRead = 0;// 查看市场营销信息权限
	private int authMarketingWrite = 0;// 发送市场营销信息权限
	private int authMyInfoWrite = 0;// 编辑账户信息权限
	private int authMyReportRead = 0;// 查看我的报表权限
	private int authBusinessReportRead = 0;// 查看商家报表权限
	private int accountIsAllowedEcardPay = 0;// 是否允许Ecard支付
	private int accountIsAllowedWriteOrderTotalSalePrice = 0;// 账户是否允许修改订单优惠价格
	private String currency;//当前账号使用的货币
	private String moduleInUse;//|1|2|3|4|5|   1:咨询 2：商机 3:营销 4:销售顾问功能 5：是否具有微信支付功能  6:是否具有支付宝支付功能
	private String branchInfo;
	private String infoJason;
	private int    authAllTheBranchOrderRead=0;//读取本店订单列表的权限
	private int    authAllTaskRead;//读取本店所有任务列表权限
	private int    authAttendanceCode;//具有展示考勤码的功能
	private boolean isComissionCalc;//是否使用业绩提成计算功能
	private int authPastPayment = 0;// 填写转入订单的过去支付金额
	private int authPastFinished = 0;// 填写转入订单的过去完成次数
	private int authBalanceCharge = 0;// 允许余额转入
	private int authDirectExpend = 0;// 允许直扣
	private int authTerminateOrder = 0; // 允许终止订单
	
	public AccountInfo() {
		isComissionCalc=false;
	}

	public int getAccountId() {
		return accountId;
	}

	public void setAccountId(int accountId) {
		this.accountId = accountId;
	}

	public int getCompanyId() {
		return companyId;
	}

	public void setCompanyId(int companyId) {
		this.companyId = companyId;
	}

	public int getBranchId() {
		return branchId;
	}

	public void setBranchId(int branchId) {
		this.branchId = branchId;
	}

	public String getAccountName() {
		return accountName;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public String getCompanyAbbreviation() {
		return companyAbbreviation;
	}

	public void setCompanyAbbreviation(String companyAbbreviation) {
		this.companyAbbreviation = companyAbbreviation;
	}

	public String getHeadImage() {
		return headImage;
	}

	public void setHeadImage(String headImage) {
		this.headImage = headImage;
	}

	public String getLoginMobile() {
		return loginMobile;
	}

	public void setLoginMobile(String loginMobile) {
		this.loginMobile = loginMobile;
	}

	public int getAuthMyCustomerRead() {
		return authMyCustomerRead;
	}

	public int getAuthAllCustomerRead() {
		return authAllCustomerRead;
	}

	public int getAuthPaymentUse() {
		return authPaymentUse;
	}

	public int getAuthEcardRead() {
		return authEcardRead;
	}
	public int getAuthServiceRead() {
		return authServiceRead;
	}

	public int getAuthCommodityRead() {
		return authCommodityRead;
	}

	public int getAuthOpportunityUse() {
		return authOpportunityUse;
	}

	public int getAuthChatUse() {
		return authChatUse;
	}

	public int getAuthMarketingRead() {
		return authMarketingRead;
	}

	public int getAuthMarketingWrite() {
		return authMarketingWrite;
	}

	public void setAuthMyCustomerRead(int authMyCustomerRead) {
		this.authMyCustomerRead = authMyCustomerRead;
	}

	public void setAuthAllCustomerRead(int authAllCustomerRead) {
		this.authAllCustomerRead = authAllCustomerRead;
	}
	public int getAuthMyOrderRead() {
		return authMyOrderRead;
	}

	public void setAuthMyOrderRead(int authMyOrderRead) {
		this.authMyOrderRead = authMyOrderRead;
	}

	public void setAuthPaymentUse(int authPaymentUse) {
		this.authPaymentUse = authPaymentUse;
	}

	public void setAuthEcardRead(int authEcardRead) {
		this.authEcardRead = authEcardRead;
	}
	public void setAuthServiceRead(int authServiceRead) {
		this.authServiceRead = authServiceRead;
	}

	public void setAuthCommodityRead(int authCommodityRead) {
		this.authCommodityRead = authCommodityRead;
	}

	public void setAuthOpportunityUse(int authOpportunityUse) {
		this.authOpportunityUse = authOpportunityUse;
	}

	public void setAuthChatUse(int authChatUse) {
		this.authChatUse = authChatUse;
	}

	public void setAuthMarketingRead(int authMarketingRead) {
		this.authMarketingRead = authMarketingRead;
	}

	public void setAuthMarketingWrite(int authMarketingWrite) {
		this.authMarketingWrite = authMarketingWrite;
	}

	public String getCompanyCode() {
		return companyCode;
	}

	public void setCompanyCode(String companyCode) {
		this.companyCode = companyCode;
	}

	public int getRoleID() {
		return roleID;
	}
	public void setRoleID(int roleID) {
		this.roleID = roleID;
	}
	public int getAuthMyInfoWrite() {
		return authMyInfoWrite;
	}
	public void setAuthMyInfoWrite(int authMyInfoWrite) {
		this.authMyInfoWrite = authMyInfoWrite;
	}

	public int getAuthMyReportRead() {
		return authMyReportRead;
	}

	public int getAuthBusinessReportRead() {
		return authBusinessReportRead;
	}

	public void setAuthMyReportRead(int authMyReportRead) {
		this.authMyReportRead = authMyReportRead;
	}

	public void setAuthBusinessReportRead(int authBusinessReportRead) {
		this.authBusinessReportRead = authBusinessReportRead;
	}
	public int getAccountIsAllowedEcardPay() {
		return accountIsAllowedEcardPay;
	}
	public void setAccountIsAllowedEcardPay(int accountIsAllowedEcardPay) {
		this.accountIsAllowedEcardPay = accountIsAllowedEcardPay;
	}

	public int getAccountIsAllowedWriteOrderTotalSalePrice() {
		return accountIsAllowedWriteOrderTotalSalePrice;
	}

	public void setAccountIsAllowedWriteOrderTotalSalePrice(
			int accountIsAllowedWriteOrderTotalSalePrice) {
		this.accountIsAllowedWriteOrderTotalSalePrice = accountIsAllowedWriteOrderTotalSalePrice;
	}
	public int getAuthReadHomePageServicingList() {
		return authReadHomePageServicingList;
	}

	public void setAuthReadHomePageServicingList(int authReadHomePageServicingList) {
		this.authReadHomePageServicingList = authReadHomePageServicingList;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getModuleInUse() {
		return moduleInUse;
	}

	public void setModuleInUse(String moduleInUse) {
		this.moduleInUse = moduleInUse;
	}

	public String getInfoJason() {
		return infoJason;
	}

	public String getBranchInfo() {
		return branchInfo;
	}

	public void setBranchInfo(String branchInfo) {
		this.branchInfo = branchInfo;
	}
	
	public int getAuthAllTheBranchOrderRead() {
		return authAllTheBranchOrderRead;
	}

	public void setAuthAllTheBranchOrderRead(int authAllTheBranchOrderRead) {
		this.authAllTheBranchOrderRead = authAllTheBranchOrderRead;
	}
	
	public int getAuthCustomerEcardWrite() {
		return authCustomerEcardWrite;
	}

	public void setAuthCustomerEcardWrite(int authCustomerEcardWrite) {
		this.authCustomerEcardWrite = authCustomerEcardWrite;
	}
	

	public int getAuthAllCustomerInfoWrite() {
		return authAllCustomerInfoWrite;
	}

	public void setAuthAllCustomerInfoWrite(int authAllCustomerInfoWrite) {
		this.authAllCustomerInfoWrite = authAllCustomerInfoWrite;
	}

	public int getAuthAllCustomerContactInfoWrite() {
		return authAllCustomerContactInfoWrite;
	}

	public void setAuthAllCustomerContactInfoWrite(
			int authAllCustomerContactInfoWrite) {
		this.authAllCustomerContactInfoWrite = authAllCustomerContactInfoWrite;
	}
	
	public int getAuthAllCustomerRecordInfoWrite() {
		return authAllCustomerRecordInfoWrite;
	}

	public void setAuthAllCustomerRecordInfoWrite(int authAllCustomerRecordInfoWrite) {
		this.authAllCustomerRecordInfoWrite = authAllCustomerRecordInfoWrite;
	}

	public int getAuthCustomerEcardAdd() {
		return authCustomerEcardAdd;
	}

	public void setAuthCustomerEcardAdd(int authCustomerEcardAdd) {
		this.authCustomerEcardAdd = authCustomerEcardAdd;
	}
	
	public int getAuthMyOrderWrite() {
		return authMyOrderWrite;
	}

	public void setAuthMyOrderWrite(int authMyOrderWrite) {
		this.authMyOrderWrite = authMyOrderWrite;
	}
	
	public int getAuthAllOrderWrite() {
		return authAllOrderWrite;
	}

	public void setAuthAllOrderWrite(int authAllOrderWrite) {
		this.authAllOrderWrite = authAllOrderWrite;
	}
	
	public int getAuthAllTaskRead() {
		return authAllTaskRead;
	}

	public void setAuthAllTaskRead(int authAllTaskRead) {
		this.authAllTaskRead = authAllTaskRead;
	}
	
	public int getAuthAttendanceCode() {
		return authAttendanceCode;
	}

	public void setAuthAttendanceCode(int authAttendanceCode) {
		this.authAttendanceCode = authAttendanceCode;
	}
	public boolean isComissionCalc() {
		return isComissionCalc;
	}

	public void setComissionCalc(boolean isComissionCalc) {
		this.isComissionCalc = isComissionCalc;
	}

	public void setBaseInfoByJson(JSONObject jsonObject, int branchPosition) {
		infoJason = jsonObject.toString();
		try {
			if (jsonObject.has("AccountID"))
				accountId = jsonObject.getInt("AccountID");
			if (jsonObject.has("AccountName"))
				accountName = jsonObject.getString("AccountName");
			if (jsonObject.has("CompanyCode"))
				companyCode = jsonObject.getString("CompanyCode");
			if (jsonObject.has("CompanyID"))
				companyId = jsonObject.getInt("CompanyID");
			if (jsonObject.has("CompanyAbbreviation"))
				companyAbbreviation = jsonObject.getString("CompanyAbbreviation");
			if (jsonObject.has("CurrencySymbol"))
				currency = jsonObject.getString("CurrencySymbol");
			else
				currency = "¥";
			if (jsonObject.has("BranchID"))
				branchId = jsonObject.getInt("BranchID");
			if (jsonObject.has("HeadImageURL"))
				headImage = jsonObject.getString("HeadImageURL");
			if (jsonObject.has("Advanced"))
				moduleInUse = jsonObject.getString("Advanced");
			if (jsonObject.has("BranchList")&& !jsonObject.isNull("BranchList")) {
				branchInfo = jsonObject.getString("BranchList");
				JSONArray branchListJson = jsonObject.getJSONArray("BranchList");
				JSONObject tmpJsonObject = branchListJson.getJSONObject(branchPosition);
				branchId = Integer.valueOf(tmpJsonObject.getString("BranchID"));
			}
			if (jsonObject.has("IsComissionCalc"))
				isComissionCalc = jsonObject.getBoolean("IsComissionCalc");
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void setPermissionInfoByJson(JSONObject jsonObject) {
		String accountPermissionStr = "";
		String GUID="";
		try {
			accountPermissionStr = jsonObject.getString("Role");
			GUID=jsonObject.getString("GUID");
		} catch (JSONException e) {
			accountPermissionStr = "";
		}
		if (accountPermissionStr != null && !("").equals(accountPermissionStr)) {
			if (accountPermissionStr.contains("|1|"))
				authMyCustomerRead = 1;
			if (accountPermissionStr.contains("|2|"))
				authReadHomePageServicingList= 1;
			if (accountPermissionStr.contains("|3|"))
				authAllCustomerRead = 1;
			if (accountPermissionStr.contains("|4|"))
				authAllCustomerInfoWrite = 1;
			if (accountPermissionStr.contains("|5|"))
				authMyOrderRead = 1;
			if (accountPermissionStr.contains("|6|"))
				authMyOrderWrite= 1;
			if (accountPermissionStr.contains("|7|"))
				authPaymentUse = 1;
			if (accountPermissionStr.contains("|8|"))
				authEcardRead = 1;
			if (accountPermissionStr.contains("|9|"))
				authCustomerEcardAdd = 1;
			if (accountPermissionStr.contains("|10|"))
				authCustomerEcardWrite = 1;
			if (accountPermissionStr.contains("|11|"))
				authServiceRead = 1;
			if (accountPermissionStr.contains("|13|"))
				authCommodityRead = 1;
			if (accountPermissionStr.contains("|15|"))
				authChatUse = 1;
			if (accountPermissionStr.contains("|16|"))
				authMyReportRead = 1;
			if (accountPermissionStr.contains("|17|"))
				authBusinessReportRead = 1;
			if (accountPermissionStr.contains("|21|"))
				authMyInfoWrite = 1;
			if(accountPermissionStr.contains("|28|"))
				authAllCustomerContactInfoWrite=1;
			if(accountPermissionStr.contains("|29|"))
				authAllCustomerRecordInfoWrite=1;
			if (accountPermissionStr.contains("|30|"))
				authOpportunityUse = 1;
			if (accountPermissionStr.contains("|32|"))
				authMarketingRead = 1;
			if (accountPermissionStr.contains("|33|"))
				authMarketingWrite = 1;
			if (accountPermissionStr.contains("|34|"))
				accountIsAllowedWriteOrderTotalSalePrice = 1;
			//查看本店所有的订单
			if(accountPermissionStr.contains("|39|"))
				authAllTheBranchOrderRead=1;
			//管理所有订单的权限
			if(accountPermissionStr.contains("|44|"))
				authAllTaskRead=1;
			//管理所有订单的权限
			if(accountPermissionStr.contains("|45|"))
				authAllOrderWrite=1;
			//生成考勤码的权限
			if(accountPermissionStr.contains("|47|"))
				authAttendanceCode=1;
			// 填写转入订单的过去支付金额的权限
			if(accountPermissionStr.contains("|51|"))
				authPastPayment=1;
			// 填写转入订单的过去完成次数
			if(accountPermissionStr.contains("|52|"))
				authPastFinished=1;
			// 允许余额转入
			if(accountPermissionStr.contains("|53|"))
				authBalanceCharge=1;
			// 允许直扣
			if(accountPermissionStr.contains("|54|"))
				authDirectExpend=1;
			// 允许终止订单
			if(accountPermissionStr.contains("|55|"))
				authTerminateOrder=1;
		}
		UserInfoApplication.getInstance().setGUID(GUID);
	}
	public int getAuthPastPayment() {
		return authPastPayment;
	}

	public void setAuthPastPayment(int authPastPayment) {
		this.authPastPayment = authPastPayment;
	}

	public int getAuthPastFinished() {
		return authPastFinished;
	}

	public void setAuthPastFinished(int authPastFinished) {
		this.authPastFinished = authPastFinished;
	}

	public int getAuthBalanceCharge() {
		return authBalanceCharge;
	}

	public void setAuthBalanceCharge(int authBalanceCharge) {
		this.authBalanceCharge = authBalanceCharge;
	}

	public int getAuthDirectExpend() {
		return authDirectExpend;
	}

	public void setAuthDirectExpend(int authDirectExpend) {
		this.authDirectExpend = authDirectExpend;
	}

	public int getAuthTerminateOrder() {
		return authTerminateOrder;
	}

	public void setAuthTerminateOrder(int authTerminateOrder) {
		this.authTerminateOrder = authTerminateOrder;
	}
}