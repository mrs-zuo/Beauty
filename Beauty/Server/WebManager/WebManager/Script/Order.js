
/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    $("#OrderDetail").hide();
    $("#TreatmentDetail").hide();
    $("#PaymentDetail").hide();
    $("#CancelOrderDetail").hide();
});

function BindSelect(accountList) {
    if (accountList != null) {
        var $select = $("#ResponsiblePerson");
        $select.children().remove();
        for (var i = 0; i < accountList.length; i++) {
            $select.append("<option value='" + accountList[i].AccountID + "'>" + accountList[i].AccountName + "</option>");
        }
    }
}

function getOrderInfo(cancelOrderFlag) {
    var orderCode = cancelOrderFlag == 0 ? $("#input_orderCode").val() : $("#input_CancelOrderCode").val();
    var patrn = /^[0-9]{12}$/;
    if (!patrn.exec(orderCode)) {
        alert("请输入正确的12位订单号！");
    }
    else {
        $.ajax({
            type: "POST",
            url: "/Order/getOrderDetail",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"OrderCode":"' + orderCode + '","TreatmentListFlag":' + cancelOrderFlag + '}',
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (cancelOrderFlag == 0) {
                    if (data.Code != "1")
                        alert(data.Message);
                    else {
                        BindSelect(data.Data.accountList)
                        bindOrderInfo(data.Data, cancelOrderFlag);
                    }
                }
                else {
                    if (data.Code != "1")
                        alert(data.Message);
                    else {
                        bindOrderInfo(data.Data, cancelOrderFlag);
                    }
                }
            }
        });
    }
}

function bindOrderInfo(order, cancelOrderFlag) {
    var orderStaus = "";
    var seleOrder = "1";
    $("#hid_ProductType").val(order.ProductType);
    $("#OrderStatus option").remove();
    switch (order.OrderStatus) {
        case 1:
            $("#hid_orderComplete").val("1");
            $("#OrderStatus").append("<option id='op1' value='1'>已完成</option>");
            $("#OrderStatus").append("<option id='op0' value='0'>改为未完成</option>");

            $("#OrderStatus").val("1");
            orderStaus = "已完成";
            break;
        case 2:
            orderStaus = "已取消";
            break;
        case 0:
            $("#hid_orderComplete").val("0");

            $("#OrderStatus").append("<option id='op3' value='3'>未完成</option>");
            $("#OrderStatus").val("3");
            orderStaus = "未完成";
            break;
        case 3:
            $("#hid_orderComplete").val("1");
            $("#OrderStatus").append("<option id='op2' value='2'>待客户确认</option>");
            $("#OrderStatus").append("<option id='op0' value='0'>改为未完成</option>");

            $("#OrderStatus").val("2");
            orderStaus = "待客户确认";
            break;
    }
    $("#OrderStatus :first").text(orderStaus);

    if (cancelOrderFlag == 0) {
        $("#OrderDetail").show();
        $("#OrderCode").text(order.OrderCode);
        $("#ProductName").text(order.ProductName);
        $("#CreatorName").text(order.CreatorName);
        $("#CustomerName").text(order.CustomerName);
        $("#TotalOrigPrice").text(toDecimal2(order.TotalOrigPrice));
        $("#TotalSalePrice").text(toDecimal2(order.TotalSalePrice));
        //$("#OrderStatus").text(orderStaus);
        $("#BranchName").text(order.BranchName);
     //   $("#SalesName").text(order.SalesName);
        $("#CreatorName").text(order.CreatorName);
        $("#OrderTime").val(order.OrderTime);
        $("#IsPast").text(order.IsPast ? "是" : "否");
        var paymentStatus = "";
        switch (order.PaymentStatus) {
            case 1:
                paymentStatus = "未支付";
                break;
            case 2:
                paymentStatus = "部分付";
                break;
            case 3:
                paymentStatus = "已支付";
                break;
            case 4:
                paymentStatus = "已退款";
                break;
            case 5:
                paymentStatus = "免支付";
                break;
        }
        $("#PaymentStatus").text(paymentStatus);
        $("#Quantity").text(order.Quantity);
        $("#Expirationtime").text(order.Expirationtime == "0001-01-01 00:00:00" ? "" : order.Expirationtime.substr(0, 10));
        $("#ResponsiblePerson").val(order.ResponsiblePersonID.toString());
    }
    else {
        $("#CancelOrderDetail").show();
        if ($("#cancelOrder_Treatment").children.length > 1) {
            $("#cancelOrder_Treatment tr:not(:first)").remove();
        }
        $("#cancelOrder_OrderCode").text(order.OrderCode);
        $("#cancelOrder_ProductName").text(order.ProductName);
        $("#cancelOrder_CreatorName").text(order.CreatorName);
        $("#cancelOrder_CustomerName").text(order.CustomerName);
        $("#cancelOrder_TotalOrigPrice").text(toDecimal2(order.TotalOrigPrice));
        $("#cancelOrder_TotalSalePrice").text(toDecimal2(order.TotalSalePrice));
        $("#cancelOrder_OrderStatus").text(orderStaus);
        $("#cancelOrder_BranchName").text(order.BranchName);
        $("#cancelOrder_SalesName").text(order.SalesName);
        $("#cancelOrder_OrderTime").text(order.OrderTime);
        $("#cancelOrder_Expirationtime").text(order.Expirationtime == "0001-01-01 00:00:00" ? "" : order.Expirationtime.substr(0, 10));
        $("#cancelOrder_IsPast").text(order.IsPast ? "是" : "否");
        $("#cancelOrder_Quantity").text(order.Quantity);
        var paymentStatus = "";
        switch (order.PaymentStatus) {
            case 1:
                paymentStatus = "未支付";
                break;
            case 2:
                paymentStatus = "部分付";
                break;
            case 3:
                paymentStatus = "已支付";
                break;
            case 4:
                paymentStatus = "已退款";
                break;
            case 5:
                paymentStatus = "免支付";
                break;
        }
        $("#cancelOrder_PaymentStatus").text(paymentStatus);
        $("#cancelOrder_ResponsiblePersonName").text(order.ResponsiblePersonName);

        if (order.CourseList != null && order.CourseList.length > 0) {
            var tr = "";
            for (var i = 0; i < order.CourseList.length; i++) {
                tr += "<tr><td>" + (i + 1) + "</td><td>" + order.CourseList[i].ServiceName + "</td>";

                if (order.CourseList[i].treatmentList != null && order.CourseList[i].treatmentList.length > 0) {
                    tr += "<td colspan='5' class='table-td'><table style='border:none;' class='table  table-hover table-bordered'><colgroup class='row'><col class='col-xs-2'><col class='col-xs-2'><col class='col-xs-2'><col class='col-xs-1'><col class='col-xs-2'></colgroup>";

                    for (var j = 0; j < order.CourseList[i].treatmentList.length; j++) {
                        var treatmentStatus = "";
                        switch (order.CourseList[i].treatmentList[j].Status) {
                            case 0:
                                treatmentStatus = "未完成";
                                break;
                            case 1:
                                treatmentStatus = "已完成";
                                break;
                            case 2:
                                treatmentStatus = "待客户确认";
                                break;
                            case 4:
                                treatmentStatus = "过去完成";
                                break;
                        }

                        tr += "<tr><td>" + order.CourseList[i].treatmentList[j].ServiceDetail + "</td><td>" + order.CourseList[i].treatmentList[j].ExecutorName + "</td><td>" + (order.CourseList[i].treatmentList[j].ScheduleTime == null ? "" : order.CourseList[i].treatmentList[j].ScheduleTime) + "</td><td>" + (order.CourseList[i].treatmentList[j].IsDesignated ? "指定" : "未指定") + "</td><td>" + treatmentStatus + "</td></tr>";
                    }
                    tr += "</table></td>";
                }
                tr += "</tr>";
            }
            $("#cancelOrder_Treatment").append(tr);
        }
    }
}

function SaveOrderEdit() {
    var OrderTime = $.trim($("#OrderTime").val());
    if (OrderTime == "") {
        alert("下单时间不能为空");
        return;
    }

    if (confirm("确定提交？")) {
        var param = "{'" +
            "OrderCode':'" + $("#OrderCode").text() +
            "','Status':" + $("#OrderStatus").val() +
            ",'ResponsiblePersonID':" + $("#ResponsiblePerson").val()
        + ",'OrderTime':'" + $("#OrderTime").val() + "'}";

        $.ajax({
            type: "POST",
            url: "/Order/updateOrder",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code == "1" && data.Data) {
                    alert(data.Message);
                    $("#input_orderCode").val("");
                    $("#OrderDetail").hide();
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function cancelOrder() {
    var productType = $("#hid_ProductType").val();
    var confirmMessage = productType == "0" ? "服务订单取消会导致订单下所有服务取消,是否取消？" : "确认取消？";
    if (confirm(confirmMessage)) {
        var orderCode = $("#cancelOrder_OrderCode").text();
        if (orderCode != null) {
            $.ajax({
                type: "POST",
                url: "/Order/cancelCompletedOrder",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: '{"OrderCode":"' + orderCode + '"}',
                error: function () {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {
                    if (data.Code == "1" && data.Data) {
                        alert(data.Message);
                        $("#input_CancelOrderCode").val("");
                        $("#CancelOrderDetail").hide();
                    }
                    else {
                        alert(data.Message);
                    }
                }
            });
        }
    }

}

function getTreatmentInfo() {
    var treatmentCode = $("#input_treatmentCode").val();
    var patrn = /^[0-9]{14}$/;
    if (!patrn.exec(treatmentCode)) {
        alert("请输入正确的14位服务编号！");
    }
    else {
        $.ajax({
            type: "POST",
            url: "/Order/getTreatmentDetail",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"TreatmentCode":"' + treatmentCode + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code == "1") {
                    bindTreatmentInfo(data.Data);
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function bindTreatmentInfo(treatment) {
    $("#TreatmentDetail").show();

    var treatmentStatus = "";
    switch (treatment.Status) {
        case 0:
            treatmentStatus = "未完成!";
            break;
        case 1:
            treatmentStatus = "已完成!";
            break;
        case 2:
            treatmentStatus = "待客户确认!";
            break;
        case 4:
            treatmentStatus = "过去完成!";
            break;
    }

    $("#hid_treatmentCode").val(treatment.TreatmentCode);
    //$("#treatment_ServiceName").text(treatment.ServiceName);
    $("#treatment_ServiceDetail").text(treatment.ServiceDetail == null ? "" : treatment.ServiceDetail);
    $("#treatment_ExecutorName").text(treatment.ExecutorName);
    $("#treatment_ScheduleTime").text(treatment.ScheduleTime == null ? "" : treatment.ScheduleTime);
    $("#treatment_IsDesignated").text(treatment.IsDesignated == 1 ? "是" : "否");
    $("#treatment_Status").text(treatmentStatus);
}

function cancelTreatment() {
    if (confirm("确定提交？")) {
        var treatmentCode = $("#hid_treatmentCode").val();

        if (treatmentCode != null) {
            $.ajax({
                type: "POST",
                url: "/Order/cancelCompletedTreatment",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: '{"TreatmentCode":"' + treatmentCode + '"}',
                error: function () {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {

                    if (data.Code == "1") {
                        alert(data.Message);
                        $("#input_treatmentCode").val("");
                        $("#TreatmentDetail").hide();
                    }
                    else {
                        alert(data.Message);
                    }
                }
            });
        }
    }
}

function getPaymentInfo() {
    var paymentCode = $("#input_paymentCode").val();
    var patrn = /^[0-9]{12}$/;
    if (!patrn.exec(paymentCode)) {
        alert("请输入正确的12位支付号！");
    }
    else {
        $.ajax({
            type: "POST",
            url: "/Order/getPaymentDetail",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"PaymentCode":"' + paymentCode + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code != "1")
                    alert(data.Message)
                else {
                    bindPaymentInfo(data.Data);
                    BindSales(data.Data.accountList, data.Data.SaleIDs)
                }
            }
        });
    }
}

function bindPaymentInfo(payment) {

    $("#PaymentDetail").show();
    $("#hs").show();
    $("#payment_OrderList tr:not(:first)").remove();
    $("#payment_Detail_Multi").children().remove()
    $("#paymentCode").text(payment.PaymentCode);
    $("#payment_change").val("0");
    $("#payment_Operator").text(payment.Operator);
    $("#payment_SalesName").html(payment.SalesName == null ? "" : payment.SalesName);
    $("#paymentTime").val(payment.PaymentTime);
    $("#payment_TotalPrice").text(toDecimal2(payment.TotalPrice));

    var canUpdatePaymentDetail = 0;
    //判断支付方式是不是有多种
    if ((payment.Ecard == 0 && (payment.TotalPrice == payment.Cash || payment.TotalPrice == payment.BankCard || payment.TotalPrice == payment.Others))) {
        $("#payment_Detail_Multi").hide();
        $("#payment_Detail_Multi tr").remove();
        $("#Payment_Detail_One").show();
        if (payment.TotalPrice == payment.Cash) {
            $("#Payment_Detail_One_Select").val("0");
            $("#Payment_Detail_One_TotalPrice").text(toDecimal2(payment.Cash));
        }
        else if (payment.TotalPrice == payment.BankCard) {
            $("#Payment_Detail_One_Select").val("2");
            $("#Payment_Detail_One_TotalPrice").text(toDecimal2(payment.BankCard));
        }
        else {
            $("#Payment_Detail_One_Select").val("3");
            $("#Payment_Detail_One_TotalPrice").text(toDecimal2(payment.Others));
        }
        canUpdatePaymentDetail = 1;
    }
    else {
        $("#Payment_Detail_One").hide();
        $("#payment_Detail_Multi").show();
        $("#payment_Detail_Multi tr").remove();
        var tr = "";
        if (payment.Cash != 0)
            tr += "<tr><td>现金</td><td>" + toDecimal2(payment.Cash) + "</td></tr>";
        if (payment.Ecard != 0)
            tr += "<tr><td>E卡</td><td>" + toDecimal2(payment.Ecard) + "</td></tr>";
        if (payment.BankCard != 0) {
            tr += "<tr><td>银行卡</td><td>" + toDecimal2(payment.BankCard) + "</td></tr>";
        }
        if (payment.PastPaid != 0) {
            tr += "<tr><td>过去支付</td><td>" + toDecimal2(payment.PastPaid) + "</td></tr>";
        }
        if (payment.Others != 0)
            tr += "<tr><td>其他</td><td>" + toDecimal2(payment.Others) + "</td></tr>";
        $("#payment_Detail_Multi").append(tr);
    }

    if (payment.OrderList != null && payment.OrderList.length > 0) {
        var tr = "";

        for (var i = 0; i < payment.OrderList.length; i++) {
            tr += "<tr><td>" + payment.OrderList[i].OrderNumber + "</td><td>" + payment.OrderList[i].ProductName + "</td><td>" + toDecimal2(payment.OrderList[i].OrderPrice) + "</td></tr>";
        }
        $("#payment_OrderList").append(tr);
    }

    $("#hid_canUpdatePaymentDetail").val(canUpdatePaymentDetail);

}

function BindSales(accountList, strSaleIDs) {
    $("#tbSales tr:not(:first)").remove();
    if (accountList != null) {
        var $tbSales = $("#tbSales");
        var html = "";
        for (var i = 0; i < accountList.length; i++) {
            html += "<tr><td><label class='btn-group no-pm'>";
            html += "<input type='checkbox' " + (strSaleIDs.indexOf("|" + accountList[i].AccountID + "|") >= 0 ? "checked='checked'" : "") + " value=" + accountList[i].AccountID + " name='chk_Sales' accountName='" + accountList[i].AccountName + "'>";
            html += "<span class='text over-text col-xs-12 no-pm'>" + accountList[i].AccountName + "</span>";
            html += "</label></td></tr>";
        }
        $tbSales.append(html);
    }

    var salesID = "";
    $('input[type="checkbox"][name="chk_Sales"]:checked').each(function (a, b) {
        salesID += $(this).val() + ",";
    });

    $("#hid_OldSalesID").val(salesID);
}

function paymentUpdate() {
    if (confirm("确定提交？")) {
        if ($("#payment_change").val() == "1")
            cancelPayment();
        else {
            var paymenttime = $.trim($('#paymentTime').val());
            if (paymenttime == "") {
                alert("支付时间不能为空");
                return;
            }
            //if ($("#hid_canUpdatePaymentDetail").val() == "1") {
                updatePaymentMode();
            //}
        }
    }
}

function CancelBalance() {
    var paymentCode = $("#paymentCode").text();
    if (paymentCode != null) {
        $.ajax({
            type: "POST",
            url: "/Order/cancelPayment",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"PaymentCode":"' + paymentCode + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code == "1" && data.Data) {
                    alert(data.Message);
                    $("#input_paymentCode").val("");
                    $("#PaymentDetail").hide();
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }

}

function updatePaymentMode() {

    var salesID = new Array();
    var oldSalesID = $("#hid_OldSalesID").val();
    var newSalesID = $("#hid_NewSalesID").val();

    if (oldSalesID != newSalesID) {
        $('input[type="checkbox"][name="chk_Sales"]:checked').each(function (a, b) {
            salesID.push($(this).val());
        });
    }

    var param = {
        PaymentCode: $("#paymentCode").text(),
        PaymentMode: $("#Payment_Detail_One_Select").val(),
        Time: $.trim($('#paymentTime').val()),
        listOrderID: salesID,
        Flag: oldSalesID != newSalesID ? "1" : "0"
    }

    $.ajax({
        type: "POST",
        url: "/Order/updatePaymentMode",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                $("#input_paymentCode").val("");
                $("#PaymentDetail").hide();
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function toDecimal2(x) {
    var f = parseFloat(x);
    if (isNaN(f)) {
        return false;
    }
    var f = Math.round(x * 100) / 100;
    var s = f.toString();
    var rs = s.indexOf('.');
    if (rs < 0) {
        rs = s.length;
        s += '.';
    }
    while (s.length <= rs + 2) {
        s += '0';
    }
    return s;
}

function allcheck() {
    var checked = $("#chk_All").is(":checked") ? "checked" : "";
    $('input[name="chk_Sales"]').prop("checked", checked);
}

function selectSales() {
    var salesName = "";
    var salesID = "";
    $('input[type="checkbox"][name="chk_Sales"]:checked').each(function (a, b) {
        salesName += $(this).attr("accountName") + ",";
        salesID = $(this).val() + ",";
    });

    $("#hid_NewSalesID").val(salesID);
    $("#payment_SalesName").text(salesName.substr(0, salesName.length - 1));
}

