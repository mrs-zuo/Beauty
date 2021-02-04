package com.GlamourPromise.Beauty.bean;

import com.alibaba.fastjson.annotation.JSONField;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class CustomerStatisticsSurplus {
    /**
     * 订单ID
     */
    @JSONField(name = "OrderID")
    private Integer orderId;

    /**
     * 订单编号
     */
    @JSONField(name = "OrderNumber")
    private String orderNumber;

    /**
     * 产品名称
     */
    @JSONField(name = "ProductName")
    private String productName;

    /**
     * 未完成数,剩余数量
     */
    @JSONField(name = "ProductSurPlusNum")
    private Integer productSurPlusNum;

    /**
     * 剩余金额
     */
    @JSONField(name = "ProductSurplusPrice")
    private Double productSurplusPrice;

    /**
     * 服务方式(1:时间卡|2:服务次数)
     */
    @JSONField(name = "ProductServiceType")
    private Integer productServiceType;
}
