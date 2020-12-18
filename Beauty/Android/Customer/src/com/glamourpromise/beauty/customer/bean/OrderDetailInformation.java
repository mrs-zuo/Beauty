package com.glamourpromise.beauty.customer.bean;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class OrderDetailInformation {

	private String paymentInfoJsonArray;
	private String TGListJsonArray;
	private int orderObjectID;
	private String orderNumber;
	private String orderTime;
	private int productType;
	private String productCode;
	private String productName;
	private int status;
	private int branchID;
	private String branchName;
	private int paymentStatus;
	private String subServiceIDs;
	private String totalOrigPrice;
	private String totalSalePrice;
	private String totalCalcPrice;
	private String unPaidPrice;
	private int responsiblePersonID;
	private int salesPersonID;
	private String responsiblePersonName;
	private String salesName;
	private int customerID;
	private String customerName;
	private int creatorID;
	private String creatorName;
	private String createTime;
	private String remark;
	private String expirationTime;
	private boolean isPast;
	private boolean flag;
	private int finishedCount;
	private int totalCount;
	private int surplusCount;
	private int pastCount;
	private String quantity;
	private int orderID;
	private int scdlCount;
	private List<TGListInfo> tgList = new ArrayList<TGListInfo>();
	private List<ScdlList> scdlList = new ArrayList<ScdlList>();

	public OrderDetailInformation() {
	}

	public static ArrayList<OrderPayListInfo> parseListByJson(String src) {
		ArrayList<OrderPayListInfo> list = new ArrayList<OrderPayListInfo>();
		try {

			JSONArray jarrList = new JSONArray(src);
			int count = jarrList.length();
			OrderPayListInfo item;
			for (int i = 0; i < count; i++) {
				item = new OrderPayListInfo();
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
			if (jsSrc.has("OrderID"))
				setOrderID(jsSrc.getInt("OrderID"));
			if (jsSrc.has("OrderObjectID"))
				setOrderObjectID(jsSrc.getInt("OrderObjectID"));
			if (jsSrc.has("OrderNumber"))
				setOrderNumber(jsSrc.getString("OrderNumber"));
			if (jsSrc.has("OrderTime"))
				setOrderTime(jsSrc.getString("OrderTime"));
			if (jsSrc.has("ProductType"))
				setProductType(jsSrc.getInt("ProductType"));
			if (jsSrc.has("ProductCode"))
				setProductCode(jsSrc.getString("ProductCode"));
			if (jsSrc.has("ProductName"))
				setProductName(jsSrc.getString("ProductName"));
			if (jsSrc.has("Status"))
				setStatus(jsSrc.getInt("Status"));
			if (jsSrc.has("BranchID"))
				setBranchID(jsSrc.getInt("BranchID"));
			if (jsSrc.has("BranchName"))
				setBranchName(jsSrc.getString("BranchName"));
			if (jsSrc.has("PaymentStatus"))
				setPaymentStatus(jsSrc.getInt("PaymentStatus"));
			if (jsSrc.has("SubServiceIDs"))
				setSubServiceIDs(jsSrc.getString("SubServiceIDs"));
			if (jsSrc.has("TotalOrigPrice"))
				setTotalOrigPrice(jsSrc.getString("TotalOrigPrice"));
			if (jsSrc.has("TotalSalePrice"))
				setTotalSalePrice(jsSrc.getString("TotalSalePrice"));
			if (jsSrc.has("TotalCalcPrice"))
				setTotalCalcPrice(jsSrc.getString("TotalCalcPrice"));
			if (jsSrc.has("UnPaidPrice"))
				setUnPaidPrice(jsSrc.getString("UnPaidPrice"));
			if (jsSrc.has("ResponsiblePersonID"))
				setResponsiblePersonID(jsSrc.getInt("ResponsiblePersonID"));
			if (jsSrc.has("SalesPersonID"))
				setSalesPersonID(jsSrc.getInt("SalesPersonID"));
			if (jsSrc.has("ResponsiblePersonName") && !jsSrc.isNull("ResponsiblePersonName"))
				setResponsiblePersonName(jsSrc.getString("ResponsiblePersonName"));
			if (jsSrc.has("SalesName"))
				setSalesName(jsSrc.getString("SalesName"));
			if (jsSrc.has("CustomerID"))
				setCustomerID(jsSrc.getInt("CustomerID"));
			if (jsSrc.has("CustomerName"))
				setCustomerName(jsSrc.getString("CustomerName"));
			if (jsSrc.has("CreatorID"))
				setCreatorID(jsSrc.getInt("CreatorID"));
			if (jsSrc.has("CreatorName"))
				setCreatorName(jsSrc.getString("CreatorName"));
			if (jsSrc.has("CreateTime"))
				setCreateTime(jsSrc.getString("CreateTime"));
			if (jsSrc.has("Remark"))
				setRemark(jsSrc.getString("Remark"));
			if (jsSrc.has("ExpirationTime"))
				setExpirationTime(jsSrc.getString("ExpirationTime"));
			if (jsSrc.has("IsPast"))
				setIsPast(jsSrc.getBoolean("IsPast"));
			if (jsSrc.has("Flag"))
				setFlag(jsSrc.getBoolean("Flag"));
			if (jsSrc.has("FinishedCount"))
				setFinishedCount(jsSrc.getInt("FinishedCount"));
			if (jsSrc.has("TotalCount"))
				setTotalCount(jsSrc.getInt("TotalCount"));
			if (jsSrc.has("SurplusCount"))
				setSurplusCount(jsSrc.getInt("SurplusCount"));
			if (jsSrc.has("PastCount"))
				setPastCount(jsSrc.getInt("PastCount"));
			if (jsSrc.has("Quantity"))
				setQuantity(jsSrc.getString("Quantity"));
			if (jsSrc.has("ScdlCount"))
				setScdlCount(jsSrc.getInt("ScdlCount"));
			if (jsSrc.has("GroupList"))
				setGroupList(jsSrc.getString("GroupList"));
			if (jsSrc.has("ScdlList"))
				setScdlList(jsSrc.getString("ScdlList"));

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public void setScdlList(String src) {
		ScdlList scdlInfo = new ScdlList();
		scdlList = scdlInfo.parseListByJson(src);
	}

	public List<ScdlList> getScdlList() {
		return scdlList;
	}

	public void setGroupList(String src) {
		TGListInfo tgListInfo = new TGListInfo();
		tgList = tgListInfo.parseListByJson(src);
	}

	public List<TGListInfo> getGroupList() {
		return tgList;
	}

	public void setOrderObjectID(int orderObjectID) {
		this.orderObjectID = orderObjectID;
	}

	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}

	public void setOrderTime(String orderTime) {
		this.orderTime = orderTime;
	}

	public void setProductType(int productType) {
		this.productType = productType;
	}

	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}

	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}

	public void setPaymentStatus(int paymentStatus) {
		this.paymentStatus = paymentStatus;
	}

	public void setSubServiceIDs(String subServiceIDs) {
		this.subServiceIDs = subServiceIDs;
	}

	public void setTotalOrigPrice(String totalOrigPrice) {
		this.totalOrigPrice = totalOrigPrice;
	}

	public void setTotalSalePrice(String totalSalePrice) {
		this.totalSalePrice = totalSalePrice;
	}

	public void setTotalCalcPrice(String totalCalcPrice) {
		this.totalCalcPrice = totalCalcPrice;
	}

	public void setUnPaidPrice(String unPaidPrice) {
		this.unPaidPrice = unPaidPrice;
	}

	public void setResponsiblePersonID(int responsiblePersonID) {
		this.responsiblePersonID = responsiblePersonID;
	}

	public void setSalesPersonID(int salesPersonID) {
		this.salesPersonID = salesPersonID;
	}

	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}

	public void setSalesName(String salesName) {
		this.salesName = salesName;
	}

	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public void setCreatorID(int creatorID) {
		this.creatorID = creatorID;
	}

	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	public void setRemark(String remark) {
		this.remark = remark;
	}

	public void setExpirationTime(String expirationTime) {
		this.expirationTime = expirationTime;
	}

	public void setIsPast(boolean isPast) {
		this.isPast = isPast;
	}

	public void setFlag(boolean flag) {
		this.flag = flag;
	}

	public void setFinishedCount(int finishedCount) {
		this.finishedCount = finishedCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public void setSurplusCount(int surplusCount) {
		this.surplusCount = surplusCount;
	}

	public void setPastCount(int pastCount) {
		this.pastCount = pastCount;
	}

	public void setQuantity(String quantity) {
		this.quantity = quantity;
	}

	public void setOrderID(int orderID) {
		this.orderID = orderID;
	}

	public void setScdlCount(int scdlCount) {
		this.scdlCount = scdlCount;
	}

	public int getOrderObjectID() {
		return orderObjectID;
	}

	public String getOrderNumber() {
		return orderNumber;
	}

	public String getOrderTime() {
		return orderTime;
	}

	public int getProductType() {
		return productType;
	}

	public String getProductCode() {
		return productCode;
	}

	public String getProductName() {
		return productName;
	}

	public int getStatus() {
		return status;
	}

	public int getBranchID() {
		return branchID;
	}

	public String getBranchName() {
		return branchName;
	}

	public int getPaymentStatus() {
		return paymentStatus;
	}

	public String getSubServiceIDs() {
		return subServiceIDs;
	}

	public String getTotalOrigPrice() {
		return totalOrigPrice;
	}

	public String getTotalSalePrice() {
		return totalSalePrice;
	}

	public String getTotalCalcPrice() {
		return totalCalcPrice;
	}

	public String getUnPaidPrice() {
		return unPaidPrice;
	}

	public int getResponsiblePersonID() {
		return responsiblePersonID;
	}

	public int getSalesPersonID() {
		return salesPersonID;
	}

	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}

	public String getSalesName() {
		return salesName;
	}

	public int getCustomerID() {
		return customerID;
	}

	public String getCustomerName() {
		return customerName;
	}

	public int getCreatorID() {
		return creatorID;
	}

	public String getCreatorName() {
		return creatorName;
	}

	public String getCreateTime() {
		return createTime;
	}

	public String getRemark() {
		return remark;
	}

	public String getExpirationTime() {
		return expirationTime;
	}

	public boolean getIsPast() {
		return isPast;
	}

	public boolean getFlag() {
		return flag;
	}

	public int getFinishedCount() {
		return finishedCount;
	}

	public int getTotalCount() {
		return totalCount;
	}

	public int getSurplusCount() {
		return surplusCount;
	}

	public int getPastCount() {
		return pastCount;
	}

	public String getQuantity() {
		return quantity;
	}

	public int getOrderID() {
		return orderID;
	}

	public int getScdlCount() {
		return scdlCount;
	}

}
