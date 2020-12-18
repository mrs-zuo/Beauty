package cn.com.antika.bean;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
/*
 * 订单信息
 * */
public class OrderInfo implements Serializable {
	/**
	 * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么)
	 */
	private static final long serialVersionUID = 1L;
	private String             createTime;
	private int                orderID;
	private int                companyID;
	private boolean            appointmentMustPaid;//预约是否显示于结账后
	private int                customerID;
	private String             customerName;
	private String             customerHeadImageUrl;
	private int                creatorID;
	private String             creatorName;
	private int                responsiblePersonID;
	private String             responsiblePersonName;//美丽顾问
	private int                accountID;
	private String             accountName;
	private int                productType;// 0 服务   1 商品
	private String             totalPrice;//原价
	private String             totalCalculatePrice;//会员价
	private String             totalSalePrice;//协商价 最终订单的成交价
	private int                opportunityID;
	private int                serviceID;
	private double              serviceUnitPrice;
	private String             productName;
	private int                quantity;// 订单中的商品或者服务数量
	private int                status;// 订单状态  0:未完成  1：已完成  2：已取消
	private int                paymentStatus;// 0：未支付、1：部分支付、2:已支付  5:免支付
	private String             orderTime;// 订单时间
	private int                operationFlag;//当前帐号操作订单权限
	private String             orderSerialNumber;
	private String             orderRemark;
	private String             orderExpirationDate;//服务订单的过期日期
	private String             paymentRemark;
	private String             orderSource;
	private int                salesID;//销售顾问ID
	private String             salesName;//销售顾问名字
	private String             subServiceIDs;//子服务的ID
	private String             unpaidPrice;
	private int                isThisBranch;//是否是本店  1：是本店  0：非本店
	private boolean            isPast;//是否老订单转入
	private int                branchID;//订单的下单门店
	private String             branchName;//下单门店
	private double              orderPastPaidPrice;//订单过去已支付价格
	private int                courseFrequency;//0:无限次课程  !=0:有限课程
	private List<Contact>      orderContactList;
	private List<OrderProduct> orderProductList;
	private List<TreatmentGroup> treatmentGroupList;//TG集合
	private int                  completeCount;//订单的完成的次数或者是已交付的商品的数量
	private int                  totalCount;//订单的总的次数或者是总的商品数量
	private int                  executingCount;//订单正在进行中的服务次数或者正在交付的商品数量
	private int                 surplusCount;//订单剩余的未交付的商品数量或者TG数量
	private String              tgGroupNo;//待结的TG的GroupNO
	private int                 orderObejctID=0;
	private boolean             isSelected;
	private boolean             isDesignated;
	private boolean             isPayment;//是否立即交付
	private int                 unfinshTgStatus;// 1：进行中  2：已完成  3:已取消   4：已终止  5：待确认
	private int                 tgPastCount;//订单过去已交付的或者已完成的
	private int                 scdlCount;//订单的预约条数
    private ArrayList<SubService> subServiceList;
    private List<AppointmentInfo> appointmentList;//预约集合
	private boolean               hasNetTrade;//是否有第三方支付
	private boolean               isMergePay;//订单是否是合并支付
	private String                refundAmount;//退款金额
	private ArrayList<CustomerBenefit> customerBenefitList;
	private int                   isConfirmed;//订单确认方式    0:不再需要确认，1:需要客户端确认，2：需要顾客签字确认
	public OrderInfo() {
		paymentRemark = "";
		orderSource = "";
		isThisBranch=1;
		isPast=false;
		branchName="";
		isSelected=false;
		isDesignated=false;
		isPayment=true;
		isMergePay=false;
	}
	
	public String getAccountName() {
		return accountName;
	}
	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}
	public boolean isPayment() {
		return isPayment;
	}
	public void setPayment(boolean isPayment) {
		this.isPayment = isPayment;
	}
	public boolean isDesignated() {
		return isDesignated;
	}
	public void setDesignated(boolean isDesignated) {
		this.isDesignated = isDesignated;
	}
	public int getOrderID() {
		return orderID;
	}
	public int getCompanyID() {
		return companyID;
	}
	public int getCustomerID() {
		return customerID;
	}
	public int getAccountID() {
		return accountID;
	}
	public int getProductType() {
		return productType;
	}
	public int getOpportunityID() {
		return opportunityID;
	}
	public void setOrderID(int orderID) {
		this.orderID = orderID;
	}
	public void setCompanyID(int companyID) {
		this.companyID = companyID;
	}
	public boolean getAppointmentMustPaid() {
		return appointmentMustPaid;
	}

	public void setAppointmentMustPaid(boolean appointmentMustPaid) {
		this.appointmentMustPaid = appointmentMustPaid;
	}

	public void setCustomerID(int customerID) {
		this.customerID = customerID;
	}
	public void setAccountID(int accountID) {
		this.accountID = accountID;
	}
	public void setProductType(int productType) {
		this.productType = productType;
	}
	public void setOpportunityID(int opportunityID) {
		this.opportunityID = opportunityID;
	}
	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
	public String getCreatorName() {
		return creatorName;
	}
	public void setCreatorName(String creatorName) {
		this.creatorName = creatorName;
	}
	public int getServiceID() {
		return serviceID;
	}
	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}
	public void setServiceID(int serviceID) {
		this.serviceID = serviceID;
	}
	public int getQuantity() {
		return quantity;
	}
	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public String getOrderTime() {
		return orderTime;
	}
	public void setOrderTime(String orderTime) {
		this.orderTime = orderTime;
	}
	public List<OrderProduct> getOrderProductList() {
		return orderProductList;
	}
	public void setOrderProductList(List<OrderProduct> orderProductList) {
		this.orderProductList = orderProductList;
	}
	public int getPaymentStatus() {
		return paymentStatus;
	}
	public void setPaymentStatus(int paymentStatus) {
		this.paymentStatus = paymentStatus;
	}
	public String getResponsiblePersonName() {
		return responsiblePersonName;
	}
	public void setResponsiblePersonName(String responsiblePersonName) {
		this.responsiblePersonName = responsiblePersonName;
	}
	public int getCreatorID() {
		return creatorID;
	}
	public void setCreatorID(int creatorID) {
		this.creatorID = creatorID;
	}
	public int getResponsiblePersonID() {
		return responsiblePersonID;
	}
	public void setResponsiblePersonID(int responsiblePersonID) {
		this.responsiblePersonID = responsiblePersonID;
	}
	public void setServiceUnitPrice(double serviceUnitPrice) {
		this.serviceUnitPrice = serviceUnitPrice;
	}
	public String getTotalPrice() {
		return totalPrice;
	}
	public String getTotalSalePrice() {
		return totalSalePrice;
	}
	public double getServiceUnitPrice() {
		return serviceUnitPrice;
	}
	public void setTotalPrice(String totalPrice) {
		this.totalPrice = totalPrice;
	}
	public void setTotalSalePrice(String totalSalePrice) {
		this.totalSalePrice = totalSalePrice;
	}
	public List<Contact> getOrderContactList() {
		return orderContactList;
	}
	public void setOrderContactList(List<Contact> orderContactList) {
		this.orderContactList = orderContactList;
	}
	public int getOperationFlag() {
		return operationFlag;
	}
	public void setOperationFlag(int operationFlag) {
		this.operationFlag = operationFlag;
	}
	public String getOrderSerialNumber() {
		return orderSerialNumber;
	}
	public void setOrderSerialNumber(String orderSerialNumber) {
		this.orderSerialNumber = orderSerialNumber;
	}
	public String getOrderRemark() {
		return orderRemark;
	}
	public void setOrderRemark(String orderRemark) {
		this.orderRemark = orderRemark;
	}
	public String getOrderExpirationDate() {
		return orderExpirationDate;
	}
	public void setOrderExpirationDate(String orderExpirationDate) {
		this.orderExpirationDate = orderExpirationDate;
	}
	public String getPaymentRemark() {
		return paymentRemark;
	}
	public void setPaymentRemark(String paymentRemark) {
		this.paymentRemark = paymentRemark;
	}
	public String getOrderSource() {
		return orderSource;
	}
	public void setOrderSource(String orderSource) {
		this.orderSource = orderSource;
	}
	public int getSalesID() {
		return salesID;
	}
	public void setSalesID(int salesID) {
		this.salesID = salesID;
	}
	public String getSalesName() {
		return salesName;
	}
	public void setSalesName(String salesName) {
		this.salesName = salesName;
	}
	public String getSubServiceIDs() {
		return subServiceIDs;
	}
	public void setSubServiceIDs(String subServiceIDs) {
		this.subServiceIDs = subServiceIDs;
	}
	public String getUnpaidPrice() {
		return unpaidPrice;
	}
	public void setUnpaidPrice(String unpaidPrice) {
		this.unpaidPrice = unpaidPrice;
	}
	public int getIsThisBranch() {
		return isThisBranch;
	}
	public void setIsThisBranch(int isThisBranch) {
		this.isThisBranch = isThisBranch;
	}
	public boolean isPast() {
		return isPast;
	}
	public void setPast(boolean isPast) {
		this.isPast = isPast;
	}
	public String getBranchName() {
		return branchName;
	}
	public void setBranchName(String branchName) {
		this.branchName = branchName;
	}
	public String getCreateTime() {
		return createTime;
	}
	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}
	public  double getOrderPastPaidPrice() {
		return orderPastPaidPrice;
	}
	public void setOrderPastPaidPrice(double orderPastPaidPrice) {
		this.orderPastPaidPrice = orderPastPaidPrice;
	}
	public int getCourseFrequency() {
		return courseFrequency;
	}
	public void setCourseFrequency(int courseFrequency) {
		this.courseFrequency = courseFrequency;
	}
	public int getCompleteCount() {
		return completeCount;
	}
	public void setCompleteCount(int completeCount) {
		this.completeCount = completeCount;
	}
	public int getTotalCount() {
		return totalCount;
	}
	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}
	public int getExecutingCount() {
		return executingCount;
	}
	public void setExecutingCount(int executingCount) {
		this.executingCount = executingCount;
	}
	public List<TreatmentGroup> getTreatmentGroupList() {
		return treatmentGroupList;
	}
	public void setTreatmentGroupList(List<TreatmentGroup> treatmentGroupList) {
		this.treatmentGroupList = treatmentGroupList;
	}
	public int getSurplusCount() {
		return surplusCount;
	}
	public void setSurplusCount(int surplusCount) {
		this.surplusCount = surplusCount;
	}
	public String getTgGroupNo() {
		return tgGroupNo;
	}
	public void setTgGroupNo(String tgGroupNo) {
		this.tgGroupNo = tgGroupNo;
	}
	public int getOrderObejctID() {
		return orderObejctID;
	}
	public void setOrderObejctID(int orderObejctID) {
		this.orderObejctID = orderObejctID;
	}
	public boolean isSelected() {
		return isSelected;
	}
	public void setSelected(boolean isSelected) {
		this.isSelected = isSelected;
	}
	public String getCustomerHeadImageUrl() {
		return customerHeadImageUrl;
	}
	public void setCustomerHeadImageUrl(String customerHeadImageUrl) {
		this.customerHeadImageUrl = customerHeadImageUrl;
	}
	public int getUnfinshTgStatus() {
		return unfinshTgStatus;
	}
	public void setUnfinshTgStatus(int unfinshTgStatus) {
		this.unfinshTgStatus = unfinshTgStatus;
	}
	public int getTgPastCount() {
		return tgPastCount;
	}
	public void setTgPastCount(int tgPastCount) {
		this.tgPastCount = tgPastCount;
	}
	public String getTotalCalculatePrice() {
		return totalCalculatePrice;
	}
	public void setTotalCalculatePrice(String totalCalculatePrice) {
		this.totalCalculatePrice = totalCalculatePrice;
	}
	public int getBranchID() {
		return branchID;
	}
	public void setBranchID(int branchID) {
		this.branchID = branchID;
	}
	public ArrayList<SubService> getSubServiceList() {
		return subServiceList;
	}
	public void setSubServiceList(ArrayList<SubService> subServiceList) {
		this.subServiceList = subServiceList;
	}
	public List<AppointmentInfo> getAppointmentList() {
		return appointmentList;
	}
	public void setAppointmentList(List<AppointmentInfo> appointmentList) {
		this.appointmentList = appointmentList;
	}
	public int getScdlCount() {
		return scdlCount;
	}
	public void setScdlCount(int scdlCount) {
		this.scdlCount = scdlCount;
	}

	public boolean isHasNetTrade() {
		return hasNetTrade;
	}

	public void setHasNetTrade(boolean hasNetTrade) {
		this.hasNetTrade = hasNetTrade;
	}

	public boolean isMergePay() {
		return isMergePay;
	}

	public void setMergePay(boolean isMergePay) {
		this.isMergePay = isMergePay;
	}

	public String getRefundAmount() {
		return refundAmount;
	}

	public void setRefundAmount(String refundAmount) {
		this.refundAmount = refundAmount;
	}

	public ArrayList<CustomerBenefit> getCustomerBenefitList() {
		return customerBenefitList;
	}

	public void setCustomerBenefitList(ArrayList<CustomerBenefit> customerBenefitList) {
		this.customerBenefitList = customerBenefitList;
	}

	public int getIsConfirmed() {
		return isConfirmed;
	}

	public void setIsConfirmed(int isConfirmed) {
		this.isConfirmed = isConfirmed;
	}
}
