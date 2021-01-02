package com.GlamourPromise.Beauty.bean;

import java.io.Serializable;

public class OrderProduct implements Serializable {
    /**
     * @Fields serialVersionUID : TODO(用一句话描述这个变量表示什么)
     */
    private static final long serialVersionUID = 1L;
    private int productID;
    private long productCode;
    private int oldOrderID;//老订单的OrderID
    private String productName;
    private String customerName;
    private int quantity;
    private int productType;// 0:服务 1:商品
    private String unitPrice;
    private String totalPrice;//a
    private String totalSalePrice;//c
    private String promotionPrice;//b
    private String oldPromotionPrice;//b
    private int customerID;
    private int opportunityID;
    private int marketingPolicy;//优惠政策
    private int responsiblePersonID;
    private String orderProductRemark;
    private String serviceOrderExpirationDate;
    private String responsiblePersonName;
    private int salesID;//销售顾问ID
    private String salesName;//销售顾问名字
    private boolean isPast;//是否是订单转入
    private int stepTemplateId;
    private double pastPaidPrice;//过去已支付价格
    private boolean isOldOrder;//是否是老订单  true:是老订单  false：新订单
    private int completeCount;//订单的完成的次数或者是已交付的商品的数量
    private int totalCount;//订单的总的次数或者是总的商品数量
    private int executingCount;//订单正在进行中的服务次数或者正在交付的商品数量
    private String userEcardName;//客户卡名称
    private int userEcardID;//客户卡ID
    private int courseFrequency;//服务次数
    private String benefitID;//券号
    private double prValue2;

    public String getOldPromotionPrice() {
        return oldPromotionPrice;
    }

    public void setOldPromotionPrice(String oldPromotionPrice) {
        this.oldPromotionPrice = oldPromotionPrice;
    }

    public int getCourseFrequency() {
        return courseFrequency;
    }

    public void setCourseFrequency(int courseFrequency) {
        this.courseFrequency = courseFrequency;
    }

    public int getUserEcardID() {
        return userEcardID;
    }

    public void setUserEcardID(int userEcardID) {
        this.userEcardID = userEcardID;
    }

    public String getUserEcardName() {
        return userEcardName;
    }

    public void setUserEcardName(String userEcardName) {
        this.userEcardName = userEcardName;
    }

    public OrderProduct() {
        //默认不是老订单转入
        isPast = false;
        //默认是新订单
        isOldOrder = false;
    }

    public int getProductID() {
        return productID;
    }

    public long getProductCode() {
        return productCode;
    }

    public void setProductCode(long productCode) {
        this.productCode = productCode;
    }

    public String getProductName() {
        return productName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getProductType() {
        return productType;
    }

    public void setProductType(int productType) {
        this.productType = productType;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public int getOpportunityID() {
        return opportunityID;
    }

    public void setOpportunityID(int opportunityID) {
        this.opportunityID = opportunityID;
    }

    public String getUnitPrice() {
        return unitPrice;
    }

    public String getTotalSalePrice() {
        return totalSalePrice;
    }

    public String getPromotionPrice() {
        return promotionPrice;
    }

    public void setUnitPrice(String unitPrice) {
        this.unitPrice = unitPrice;
    }

    public void setTotalSalePrice(String totalSalePrice) {
        this.totalSalePrice = totalSalePrice;
    }

    public void setPromotionPrice(String promotionPrice) {
        this.promotionPrice = promotionPrice;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public int getMarketingPolicy() {
        return marketingPolicy;
    }

    public void setMarketingPolicy(int marketingPolicy) {
        this.marketingPolicy = marketingPolicy;
    }

    public int getResponsiblePersonID() {
        return responsiblePersonID;
    }

    public void setResponsiblePersonID(int responsiblePersonID) {
        this.responsiblePersonID = responsiblePersonID;
    }

    public String getOrderProductRemark() {
        return orderProductRemark;
    }

    public void setOrderProductRemark(String orderProductRemark) {
        this.orderProductRemark = orderProductRemark;
    }

    public String getServiceOrderExpirationDate() {
        return serviceOrderExpirationDate;
    }

    public void setServiceOrderExpirationDate(String serviceOrderExpirationDate) {
        this.serviceOrderExpirationDate = serviceOrderExpirationDate;
    }

    public String getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(String totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getResponsiblePersonName() {
        return responsiblePersonName;
    }

    public void setResponsiblePersonName(String responsiblePersonName) {
        this.responsiblePersonName = responsiblePersonName;
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

    public boolean isPast() {
        return isPast;
    }

    public void setPast(boolean isPast) {
        this.isPast = isPast;
    }

    public int getStepTemplateId() {
        return stepTemplateId;
    }

    public void setStepTemplateId(int stepTemplateId) {
        this.stepTemplateId = stepTemplateId;
    }

    public double getPastPaidPrice() {
        return pastPaidPrice;
    }

    public void setPastPaidPrice(double pastPaidPrice) {
        this.pastPaidPrice = pastPaidPrice;
    }

    public int getOldOrderID() {
        return oldOrderID;
    }

    public void setOldOrderID(int oldOrderID) {
        this.oldOrderID = oldOrderID;
    }

    public boolean isOldOrder() {
        return isOldOrder;
    }

    public void setOldOrder(boolean isOldOrder) {
        this.isOldOrder = isOldOrder;
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

    public String getBenefitID() {
        return benefitID;
    }

    public void setBenefitID(String benefitID) {
        this.benefitID = benefitID;
    }

    public double getPrValue2() {
        return prValue2;
    }

    public void setPrValue2(double prValue2) {
        this.prValue2 = prValue2;
    }

    @Override
    public int hashCode() {
        final int prime = 17;
        int result = 1;
        result = prime * result + ((this.productID == 0) ? 0 : (String.valueOf(this.productID)).hashCode());
        result = prime * result + ((this.productType == 0) ? 0 : String.valueOf(this.productType).hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        boolean result = false;
        if (obj instanceof OrderProduct) {
            if (((OrderProduct) obj).getProductID() == this.productID
                    && ((OrderProduct) obj).getProductType() == this.productType
            ) {
                result = true;
            }
        }
        return result;
    }
}
