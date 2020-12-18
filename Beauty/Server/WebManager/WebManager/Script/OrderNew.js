
/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    //$("#OrderDetail").hide();
    //$("#TGDetail").hide();
    //$("#DeliveredDetail").hide();
    //$("#BalanceDetail").hide();
    //$("#PaymentDetail").hide();
});



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

function BindSelect(accountList, selectId) {
    if (accountList != null) {
        var $select = $("#" + selectId);
        $select.children().remove();
        for (var i = 0; i < accountList.length; i++) {
            $select.append("<option value='" + accountList[i].AccountID + "'>" + accountList[i].AccountName + "</option>");
        }
    }
}

function selectProfits() {
    var profitText = $("#hiddenData").data("porfitText");
    var profitName = "";
    var profitID = "|";
    var profit = new Array();
    $('input[type="checkbox"][name="chk_Sales"]:checked').each(function (a, b) {
        profitName += $(this).attr("accountName") + ",";
        profitID += $(this).val() + "|";
        if (profitText == "paymentProfitName" || profitText == "BalanceProfit") {
            var pTemt = {
                profitName: $(this).attr("accountName"),
                profitID: $(this).val(),
                ProfitPct: $(this).attr("ProfitPct")
            }
        }
        profit.push(pTemt);
    });

    $("#hiddenData").data("newProfitIDs", profitID);

    if (profitText == "paymentProfitName") {
        // $("#hiddenData").data("newProfitArray", profit);
        ShowSelect(profit);
    } else if (profitText == "BalanceProfit") {
        ShowSelectBalance(profit);
    } else {
        $("#" + profitText).text(profitName.substr(0, profitName.length - 1));
    }
}


//TAB1
function getOrderInfo(cancelOrderFlag) {
    var orderCode = $("#input_orderCode").val();
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
            data: '{"OrderCode":"' + orderCode + '"}',
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code != "1")
                    alert(data.Message);
                else {
                    BindSelect(data.Data.accountList, "OrderResponsiblePerson")
                    bindOrderInfo(data.Data);
                }
            }
        });
    }
}

function bindOrderInfo(order) {
    var orderStaus = "";
    var seleOrder = "1";
    $("#hiddenData").data("orderProductType", order.ProductType);
    $("#OrderStatus option").remove();
    switch (order.OrderStatus) {
        case 2:
            $("#hiddenData").data("OrderStatus", OrderStatus);
            $("#OrderStatus").append("<option id='op2' value='2'>已完成</option>");
            $("#OrderStatus").append("<option id='op1' value='1'>未完成</option>");

            $("#OrderStatus").val("2");
            orderStaus = "已完成";
            break;
        case 3:
            orderStaus = "已取消";
            break;
        case 1:
            $("#hiddenData").data("OrderStatus", OrderStatus);

            $("#OrderStatus").append("<option id='op1' value='1'>未完成</option>");
            $("#OrderStatus").val("1");
            orderStaus = "未完成";
            break;
        case 4:
            $("#hiddenData").data("OrderStatus", OrderStatus);
            $("#OrderStatus").append("<option id='op4' value='4'>已终止</option>");
            $("#OrderStatus").append("<option id='op1' value='1'>改为未完成</option>");
            $("#OrderStatus").val("4");
            orderStaus = "已终止";
            break;
    }
    $("#OrderStatus :first").text(orderStaus);

    $("#OrderDetail").show();
    $("#OrderCode").text(order.OrderCode);
    $("#OrderBranchName").text(order.BranchName);
    $("#OrderProductName").text(order.ProductName);
    $("#OrderCreatorName").text(order.CreatorName);
    $("#OrderOrderTime").val(order.OrderTime);
    $("#OrderCustomerName").text(order.CustomerName);
    $("#OrderExpirationTime").text(order.Expirationtime == "0001-01-01 00:00:00" ? "" : order.Expirationtime.substr(0, 10));
    $("#OrderResponsiblePerson").val(order.ResponsiblePersonID.toString());
    $("#OrderQuantity").text(order.Quantity);
    $("#OrderIsPast").text(order.IsPast ? "是" : "否");
    $("#OrderTotalOrigPrice").text(toDecimal2(order.TotalOrigPrice));
    $("#OrderTotalSalePrice").text(toDecimal2(order.TotalSalePrice));
    $("#OrderBenefit").text(order.PolicyName);
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
    $("#OrderPaymentStatus").text(paymentStatus);

    var paymentList = order.PaymentList;
    $("#tbOrderPaymentDetail tr").remove();
    if (paymentList != null) {
        for (var i = 0; i < paymentList.length; i++) {
            $("#tbOrderPaymentDetail").append('<tr><td>' + paymentList[i].PaymentTime + '</td><td>' + paymentList[i].PaymentCode + '</td></tr>');
        }
    }
    $("#OrderDetail").show();
}


function SaveOrderEdit() {
    var OrderTime = $.trim($("#OrderOrderTime").val());
    if (OrderTime == "") {
        alert("下单时间不能为空");
        return;
    }

    if (confirm("确定提交？")) {
        var param = "{'" +
            "OrderCode':'" + $("#OrderCode").text() +
            "','Status':" + $("#OrderStatus").val() +
            ",'ResponsiblePersonID':" + $("#OrderResponsiblePerson").val()
        + ",'OrderTime':'" + $("#OrderOrderTime").val() + "'}";

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

function CancelOrder() {
    var productType = $("#hiddenData").data("orderProductType");
    var confirmMessage = productType == "0" ? "订单取消后无法恢复，是否确定取消？" : "确认取消？";
    if (confirm(confirmMessage)) {
        var orderCode = $("#input_orderCode").val();
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

}

//TAB2
function gettTGInfo() {
    var GroupNo = $("#input_GroupNo").val();
    var patrn = /^[0-9]{16}$/;
    if (!patrn.exec(GroupNo)) {
        alert("请输入正确的16位服务号！");
    }
    else {
        $.ajax({
            type: "POST",
            url: "/Order/getTGDetail",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"GroupNo":"' + GroupNo + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code != "1")
                    alert(data.Message)
                else {
                    bindTGInfo(data.Data);
                }
            }
        });
    }
}



function bindTGInfo(TG) {
    $("#TGNo").text(TG.GroupNo);
    $("#TGName").text(TG.ServiceName);
    $("#TGStatus option").remove();
    switch (TG.Status) {
        case 1:
            $("#TGStatus").append("<option id='op1' value='1'>未完成</option>");
            $("#TGStatus").val("1");
            break;
        case 2:
            $("#TGStatus").append("<option id='op2' value='2'>已完成</option>");
            $("#TGStatus").append("<option id='op1' value='1'>未完成</option>");

            $("#TGStatus").val("2");
            orderStaus = "已完成";
            break;
        case 5:
            $("#TGStatus").append("<option id='op5' value='5'>完成待确认</option>");
            $("#TGStatus").append("<option id='op1' value='1'>未完成</option>");
            $("#TGStatus").val("5");
            break;
    }
    $("#hiddenData").data("TGStatus", TG.Status);
    $("#TGStartTime").val(TG.StartTime);
    $("#TGEndTime").val(TG.EndTime);
    BindSelect(TG.AccountList, "TGServicePIC");

    var accountList = TG.AccountList;
    $("#TGServicePIC").val(TG.ServicePicID.toString());

    $("#tbTGDetail tr").remove();
    if (TG.TreatmentList != null) {
        var Treatment = TG.TreatmentList;
        for (var i = 0; i < Treatment.length; i++) {
            var html = "<tr tId='" + Treatment[i].TreatmentID + "'><td>" + Treatment[i].SubServiceName + "</td>";
            html += "<td><div class='btn-group width100P no-padding-left'><select name = 'TreamtExecut' class='form-control noradius'>";
            if (accountList != null) {
                for (var j = 0; j < accountList.length; j++) {
                    var check = "";
                    if (accountList[j].AccountID == Treatment[i].ExecutorID) {
                        check = " selected='selected' ";
                    }
                    html += "<option " + check + " value='" + accountList[j].AccountID + "'>" + accountList[j].AccountName + "</option>";
                }
            }
            html += "</select></div></td> ";
            html += "<td name = 'TreamtStart'>" + Treatment[i].StartTime + "</td>";
            html += "<td><div class='btn-group width100P no-padding-left'><span class='input-icon icon-right time-layer'>";

            var endTime = Treatment[i].EndTime;
            if (endTime == "0001-01-01 00:00") {
                endTime = "";
            }
            html += "<input name = 'TreamtEnd' onclick='laydate({ istime: true, format: " + '"YYYY-MM-DD hh:mm:ss"' + "})' placeholder='完成时间' class='form-control date-picker' value='" + endTime + "'>";
            html += "<i class='fa fa-calendar'></i></span></div></td> "

            var Status = "";
            switch (Treatment[i].Status) {
                case 1:
                    Status = "进行中";
                    break;
                case 2:
                    Status = "已完成";
                    break;
                case 3:
                    Status = "已取消";
                    break;
                case 4:
                    Status = "已终止";
                    break;
                case 5:
                    Status = "完成待确认";
                    break;
            }
            html += "<td name = 'TreamtStatus'>" + Status + "</td>";
            $("#tbTGDetail").append(html);
        }
    }

    $("#TGDetail").show();
}



function EditTreatmentStartTime(e) {
    $('#tbTGDetail td[name="TreamtStart"]').text(e);
}

function EditTreatmentStatus() {
    var status = $("#TGStatus").find("option:selected").text();
    $('#tbTGDetail td[name="TreamtStatus"]').text(status);
}

function EditTG() {

    var result = true;
    var TreatmentList = new Array();
    $('#tbTGDetail tr').each(function (a, b) {
        if ($("#TGStartTime").val() > $(this).find("[name='TreamtEnd']").val()) {
            result = false;
        }

        var treatMentDeatil = {
            TreatmentID: $(this).attr("tId"),
            ExecutorID: $(this).find("[name='TreamtExecut']").val(),
            StartTime: $("#TGStartTime").val(),
            Status: $("#TGStatus").val(),
            EndTime: $(this).find("[name='TreamtEnd']").val()
        }
        TreatmentList.push(treatMentDeatil);
    });
    if (!result) {
        alert("服务开始时间不能晚于结束时间");
        return false;
    }
    var param = {
        GroupNo: $("#TGNo").text(),
        ServicePicID: $("#TGServicePIC").val(),
        StartTime: $("#TGStartTime").val(),
        EndTime: $("#TGEndTime").val(),
        Status: $("#TGStatus").val(),
        TreatmentList: TreatmentList
    }



    var status = $("#hiddenData").data("TGStatus");
    if (status != 1 && param.EndTime == "") {
        alert("已完成的服务结束时间不能为空");
        return false;
    }
    if (param.EndTime != "" && param.StartTime > param.EndTime) {
        alert("开始时间不能晚于结束时间");
        return false;
    }

    $.ajax({
        type: "POST",
        url: "/Order/EditTG",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                $("#input_GroupNo").val("");
                $("#TGDetail").hide();
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function CancelTG() {
    var confirmMessage = "是否确认取消服务";
    if (confirm(confirmMessage)) {
        var TreatmentList = new Array();
        $('#tbTGDetail tr').each(function (a, b) {
            var treatMentDeatil = {
                TreatmentID: $(this).attr("tId")
            }
            TreatmentList.push(treatMentDeatil);
        });

        var param = {
            GroupNo: $("#TGNo").text(),
            TreatmentList: TreatmentList
        }


        $.ajax({
            type: "POST",
            url: "/Order/CancelTG",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(param),
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code == "1" && data.Data) {
                    alert(data.Message);
                    $("#input_GroupNo").val("");
                    $("#TGDetail").hide();
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}


//TAB3 
function getDeliveryInfo() {
    var DeliveryCode = $("#input_DeliveryCode").val();
    var patrn = /^[0-9]{16}$/;
    if (!patrn.exec(DeliveryCode)) {
        alert("请输入正确的16位交付号！");
    }
    else {
        $.ajax({
            type: "POST",
            url: "/Order/getDeliveryDetail",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"DeliveryCode":"' + DeliveryCode + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code != "1")
                    alert(data.Message)
                else {
                    bindDeliveryInfo(data.Data);
                }
            }
        });
    }
}


function bindDeliveryInfo(Delivery) {
    $("#DeliveredNo").text(Delivery.DeliveryCode);
    $("#DeliveredCommodityName").text(Delivery.CommodityName);
    var Status = "";
    switch (Delivery.Status) {
        case 1:
            Status = "进行中";
            break;
        case 2:
            Status = "已完成";
            break;
        case 3:
            Status = "已取消";
            break;
        case 4:
            Status = "已终止";
            break;
        case 5:
            Status = "完成待确认";
            break;
    }
    $("#DeliveredStatus").text(Status);
    $("#DeliveryStartTime").val(Delivery.CDStartTime);
    $("#DeliveryEndTime").val(Delivery.CDEndTime);
    BindSelect(Delivery.AccountList, "DeliveredPersonPIC")
    $("#DeliveredPersonPIC").val(Delivery.ServicePIC.toString());
    $("#hiddenData").data("DeliveryStatus", Delivery.Status);
    $("#DeliveredDetail").show();
}

function EditDelivery() {


    var param = {
        DeliveryCode: $("#DeliveredNo").text(),
        ServicePIC: $("#DeliveredPersonPIC").val(),
        CDStartTime: $("#DeliveryStartTime").val(),
        CDEndTime: $("#DeliveryEndTime").val()
    }

    var status = $("#hiddenData").data("DeliveryStatus");
    if (status != 1 && param.CDEndTime == "") {
        alert("已交付的记录结束时间不能为空");
        return false;
    }
    if (param.CDEndTime != "" && param.CDStartTime > param.CDEndTime) {
        alert("开始时间不能小于结束时间");
        return false;
    }

    $.ajax({
        type: "POST",
        url: "/Order/EditDelivery",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                $("#input_DeliveryCode").val("");
                $("#DeliveredDetail").hide();
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function CancelDelivery() {
    var param = {
        DeliveryCode: $("#DeliveredNo").text()
    }

    var status = $("#hiddenData").data("DeliveryStatus");
    if (status == 3) {
        alert("该记录已经被取消");
        return false;
    }


    $.ajax({
        type: "POST",
        url: "/Order/CancelDelivey",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                $("#input_DeliveryCode").val("");
                $("#DeliveredDetail").hide();
            }
            else {
                alert(data.Message);
            }
        }
    });
}

//TAB4
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
                }
            }
        });
    }
}

function bindPaymentInfo(payment) {
    $("#hiddenData").data("porfitText", "paymentProfitName");
    $("#PaymentCode").text(payment.PaymentCode);
    $("#PaymentAmount").text(toDecimal2(payment.TotalPrice));
    $("#PaymentCreatorName").text(payment.Operator);
    $("#PaymentTime").val(payment.PaymentTime);

    $("#PaymentTime").removeAttr("disabled");
    $("#btnCancelPayment").show();
    $("#tbPaymentDetail tr").remove();

    if (payment.IsUseRate == 1) {
        $("#radioCheckY").prop("checked", "checked");
        $("#radioCheckN").prop("checked", false);
    } else {
        $("#radioCheckY").prop("checked", false);
        $("#radioCheckN").prop("checked", "checked");
    }


    var paymentList = payment.PaymentDetailList;
    if (paymentList != null) {
        for (var i = 0; i < paymentList.length; i++) {
            var id = "ddlMode" + i;
            if (paymentList[i].PaymentMode == 0 || paymentList[i].PaymentMode == 2 || paymentList[i].PaymentMode == 3 || paymentList[i].PaymentMode == 100 || paymentList[i].PaymentMode == 101) {

                $("#tbPaymentDetail").append('<tr><td><select id="' + id + '" class="form-control noradius" name="PaymentDdlMode" dId="' + paymentList[i].PaymentDetailID + '"><option value="0">现金</option><option value="2">银行卡</option><option value="3">其它</option><option value="100">消费贷款</option><option value="101">第三方收款</option></select></td><td>' + paymentList[i].PaymentAmount + '</td>' + '<td><input name="txtProfit" type="text" class="form-control" placeholder="输入业绩折算率" value="' + paymentList[i].ProfitRate + '"></td></tr>');
                $("#" + id).val(paymentList[i].PaymentMode);
            } else {
                var mode = "";
                switch (paymentList[i].PaymentMode) {
                    case 1:
                        mode = paymentList[i].CardName;
                        $("#PaymentTime").attr("disabled", "disabled");
                        break;
                    case 4:
                        mode = "免支付";
                        break;
                    case 5:
                        mode = "过去支付";
                        break;
                    case 6:
                        mode = "积分";
                        break;
                    case 7:
                        mode = "现金券";
                        break;
                    case 8:
                        $("#PaymentTime").attr("disabled", "disabled");
                        $("#btnCancelPayment").hide();
                        mode = "微信支付";
                        break;

                    case 9:
                        $("#PaymentTime").attr("disabled", "disabled");
                        $("#btnCancelPayment").hide();
                        mode = "支付宝支付";
                        break;
                }
                $("#tbPaymentDetail").append('<tr><td><select id="' + id + '" class="form-control noradius" name="PaymentDdlMode" dId="' + paymentList[i].PaymentDetailID + '"><option value="' + paymentList[i].PaymentMode + '">' + mode + '</option></select><td>' + paymentList[i].PaymentAmount + '</td>' + '<td><input name="txtProfit" type="text" class="form-control" placeholder="输入业绩折算率" value="' + paymentList[i].ProfitRate + '"></td></tr>');
            }
        }
    }

    var comCalc = $("#txtHiddenCom").val();
    var profit = payment.ProfitList;
    var profitIDs = "";
    var profitName = "";
    $("#tbPorfit tr[name='trProfit']").remove();
    if (profit != null) {
        for (var i = 0; i < profit.length; i++) {
            if (profitIDs != "") {
                profitIDs += "|"
            }

            profitIDs += profit[i].AccountID;
            var html = '<tr name="trProfit" tId="' + profit[i].AccountID + '"><td><div class="form-group"><div class="col-sm-2 radio no-padding-left text-center">' + profit[i].AccountName + '</div><div class="col-sm-2 no-padding-left">';
            if(comCalc == "True"){
                html += ' <input placeholder="请输入数额" class="form-control" type="text" name="txtProfitPct" value=' + (profit[i].ProfitPct * 100).toFixed("0.0") + '></div><div class="col-sm-1 radio no-padding-left text-left">(%)</div>';
            }
            html += '</div></td></tr>';
            $("#tbPorfit").append(html);
                
               
        }
        $("#trFirstPorfit").attr("rowspan", profit.length + 1);
    }
    profitIDs = "|" + profitIDs + "|";
    //  $("#paymentProfitName").text(profitName);

    $("#tbPaymentOrderList tr").remove();
    var orderList = payment.OrderList;
    if (orderList != null) {
        for (var i = 0; i < orderList.length; i++) {
            $("#tbPaymentOrderList").append('<tr><td class="txtR">' + orderList[i].OrderNumber + '</th><td class="txtL">' + orderList[i].ProductName + '</td></tr>');
        }
    }

    BindProfit(payment.accountList, profitIDs)

    $("#PaymentDetail").show();

}


function BindProfit(accountList, profitIDs) {
    $("#tbSales tr:not(:first)").remove();
    if (accountList != null) {
        var $tbSales = $("#tbSales");
        var html = "";
        for (var i = 0; i < accountList.length; i++) {
            html += "<tr><td><label class='btn-group no-pm'>";
            html += "<input type='checkbox' " + (profitIDs.indexOf("|" + accountList[i].AccountID + "|") >= 0 ? "checked='checked'" : "") + " value=" + accountList[i].AccountID + " name='chk_Sales' accountName='" + accountList[i].AccountName + "'  ProfitPct='" + (accountList[i].ProfitPct * 100).toFixed("0.0") + "'>"
            html += "<span class='text over-text col-xs-12 no-pm'>" + accountList[i].AccountName + "</span>";
            html += "</label></td></tr>";
        }
        $tbSales.append(html);
    }
    $("#hiddenData").data("profitIDs", profitIDs);
    $("#hiddenData").data("newProfitIDs", profitIDs);
}


function Reselected() {
    var profitIDs = $("#hiddenData").data("newProfitIDs");
    $('input[type="checkbox"][name="chk_Sales"]').prop("checked", false);
    $('input[type="checkbox"][name="chk_Sales"]').each(function (a, b) {
        var id = "|" + $(this).val() + "|";
        if (profitIDs.indexOf(id) > -1) {
            $(this).prop("checked", "checked")
        }
    });
}

function allcheck() {
    var checked = $("#chk_All").is(":checked") ? "checked" : "";
    $('input[name="chk_Sales"]').prop("checked", checked);
}

function ShowSelect(profit) {
    $("#tbPorfit tr[name='trProfit']").remove();
    var comCalc = $("#txtHiddenCom").val();
    if (profit != null) {
        for (var i = 0; i < profit.length; i++) {
            var html = '<tr name="trProfit" tId="' + profit[i].profitID + '"><td><div class="form-group"><div class="col-sm-2 radio no-padding-left text-center">' + profit[i].profitName + '</div><div class="col-sm-2 no-padding-left">';
            if (comCalc == "True") {
                html += '<input placeholder="请输入数额" class="form-control" type="text" name="txtProfitPct" value=' + profit[i].ProfitPct + '></div><div class="col-sm-1 radio no-padding-left text-left">(%)';
            }
            html += '</div></div></td></tr>';
            $("#tbPorfit").append(html);
        }
        $("#trFirstPorfit").attr("rowspan", profit.length + 1);
    }
}




function SavePaymentEdit() {
    var detailList = new Array();
    var paymentMode = "|";
    var result = 1;

    var comCalc = $("#txtHiddenCom").val();
    $('#tbPaymentDetail [name="PaymentDdlMode"]').each(function (a, b) {

        var profitRate = $(this).parent().next().next().find('[name="txtProfit"]').val();
        if (profitRate < 0 || profitRate >= 10) {
            result = -2;
            return;
        }
        var pamentDeatil = {
            PaymentMode: $(this).val(),
            PaymentDetailID: $(this).attr("dId"),
            ProfitRate: profitRate
        }
        if (paymentMode.indexOf("|" + $(this).val() + "|") > -1 && $(this).val() != "1") {
            result = -1;
            return;
        }
        paymentMode += $(this).val() + "|";
        detailList.push(pamentDeatil);
    })

    if (result == -1) {
        alert("支付方式不能重复");
        return false;
    } else if (result == -2) {
        alert("业绩折算率必须在0-10之间");
        return false;

    }
    var profitList = new Array();
    $("#tbPorfit tr[name='trProfit']").each(function () {
        var ProfitPct = 0;
        if (comCalc) {
            ProfitPct = parseFloat($(this).find("[name='txtProfitPct']").val() / 100);
        }
        var Profit = {
            SlaveID: $(this).attr("tId"),
            ProfitPct: ProfitPct
        }

        if (Profit.ProfitPct < 0) {
            result = -3;
            return;
        }
        profitList.push(Profit);
    })

    if (result == -3) {
        alert("业绩参与比例必须大于0");
        return false;
    }

    var IsUseRate = 2;
    if ($("#radioCheckY").is(":checked")) {
        IsUseRate = 1;
    }

    var param = {
        PaymentCode: $("#PaymentCode").text(),
        PaymentTime: $("#PaymentTime").val(),
        IsUseRate: IsUseRate,
        DetailList: detailList,
        ProfitList: profitList
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

function CancelPayment() {
    var PaymentCode = $("#PaymentCode").text();
    $.ajax({
        type: "POST",
        url: "/Order/cancelPayment",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"PaymentCode":"' + PaymentCode + '"}',
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                var balance = data.Data;
                var message = "本次取消执行之后： ";
                for (var i = 0; i < balance.length; i++) {
                    if (message != "") {
                        message += ",";
                    }
                    message += balance[i].CardName + "还剩下" + balance[i].Balance;
                }
                alert(message);
                $("#input_paymentCode").val("");
                $("#PaymentDetail").hide();
            }
            else {
                alert(data.Message);
            }
        }
    });
}





//TAB5
function getBalanceInfo() {
    var BalanceCode = $("#input_BalanceCode").val();
    var patrn = /^[0-9]{12}$/;
    if (!patrn.exec(BalanceCode)) {
        alert("请输入正确的12位充值号！");
    }
    else {
        $.ajax({
            type: "POST",
            url: "/Order/getBalanceDetail",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"BalanceCode":"' + BalanceCode + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code != "1")
                    alert(data.Message)
                else {
                    bindBalanceInfo(data.Data);
                }
            }
        });
    }
}

function ShowSelectBalance(profit) {
    $("#tbPorfitBalance tr[name='trProfit']").remove();
    var comCalc = $("#txtHiddenCom").val();
    if (profit != null) {
        for (var i = 0; i < profit.length; i++) {
            var html = '<tr name="trProfit" tId="' + profit[i].profitID + '"><td><div class="form-group"><div class="col-sm-2 radio no-padding-left text-center">' + profit[i].profitName + '</div><div class="col-sm-2 no-padding-left">';
            if (comCalc == "True") {
                html += '<input placeholder="请输入数额" class="form-control" type="text" name="txtProfitPct" value=' + profit[i].ProfitPct + '></div><div class="col-sm-1 radio no-padding-left text-left">(%)</div>';
            }
            html += '</div></td></tr>';
            $("#tbPorfitBalance").append(html);
        }
        $("#trFirstPorfitBalance").attr("rowspan", profit.length + 1);
    }
}

function bindBalanceInfo(balance) {
    $("#hiddenData").data("porfitText", "BalanceProfit");
    $("#BalanceCode").text(balance.BalanceCode);
    $("#BalanceOperator").text(balance.Operator);
    $("#BalanceCreateTime").text(balance.CreateTime);
    var profitName = "";
    var profitIDs = "";
    var comCalc = $("#txtHiddenCom").val();
    $("#tbPorfitBalance tr[name='trProfit']").remove();
    if (balance.ProfitList != null) {
        var profit = balance.ProfitList;
        for (var i = 0; i < profit.length; i++) {
            if (profitIDs != "") {
                profitIDs += "|"
            }

            profitIDs += profit[i].AccountID;
            var html = '<tr name="trProfit" tId="' + profit[i].AccountID + '"><td><div class="form-group"><div class="col-sm-2 radio no-padding-left text-center">' + profit[i].AccountName + '</div><div class="col-sm-2 no-padding-left">';
            if (comCalc == "True") {
                html += '<input placeholder="请输入数额" class="form-control" type="text" name="txtProfitPct" value=' + (profit[i].ProfitPct * 100).toFixed("0.0") + '></div><div class="col-sm-1 radio no-padding-left text-left">(%)</div>';
            }
            html += '</div></td></tr>';
            $("#tbPorfitBalance").append(html);
        }
        $("#trFirstPorfitBalance").attr("rowspan", profit.length + 1);
    }
    profitIDs = "|" + profitIDs + "|";
    //$("#BalanceProfit").text(profitName);

    if (balance.BalanceList[0].BalanceCardList[0].DepositMode == 4 || balance.BalanceList[0].BalanceCardList[0].DepositMode == 5 ) {
        $("#btnCancelBalance").hide();
    } else {
        $("#btnCancelBalance").show();
    }
    $("#BalanceChangeTypeName").text(balance.ChangeTypeName);
    $("#BalanceAmount").text(balance.Amount);

    if (balance.BalanceList[0].BalanceCardList != null) {
        var BalanceCardList = balance.BalanceList[0].BalanceCardList;

        $("#BalanceCardName").text(BalanceCardList[0].CardName);
        $("#BalanceRechareAmount").text(BalanceCardList[0].Amount);
        $("#BalanceLastAmount").text(BalanceCardList[0].Balance);
        if (BalanceCardList[0].DepositMode == 3 || balance.BalanceList[0].ActionMode == 7 || balance.BalanceList[0].ActionMode == 9) {
            $("#btnBalanceEdit").hide();
        } else {
            $("#btnBalanceEdit").show();
        }
    }



    $("#tbBalanceSendList tr").remove();
    if (balance.GiveList != null) {
        var giveList = balance.GiveList;
        for (var i = 0; i < giveList.length ; i++) {
            if (giveList[i] != null); {
                var BalanceCardList = giveList[i].BalanceCardList;
                for (var j = 0; j < BalanceCardList.length; j++) {
                    $("#tbBalanceSendList").append("<tr><td>" + BalanceCardList[j].CardName + "</td><td>" + BalanceCardList[j].Amount + "</td><td>" + BalanceCardList[j].Balance + "</td></tr>");
                }
            }
        }

        var BalanceCardList = balance.BalanceList[0].BalanceCardList;

        $("#BalanceCardName").text(BalanceCardList[0].CardName);
        $("#BalanceRechareAmount").text(BalanceCardList[0].Amount);
        $("#BalanceLastAmount").text(BalanceCardList[0].Balance);
    }
    BindProfit(balance.accountList, profitIDs)

    if (balance.TargetAccount != 1) {
        $("#btnBalanceSales").hide();
    } else {
        $("#btnBalanceSales").show();
    }


    $("#BalanceDetail").show();

}



function CancelBalance() {
    var BalanceCode = $("#BalanceCode").text();
    $.ajax({
        type: "POST",
        url: "/Order/cancelBalance",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"BalanceCode":"' + BalanceCode + '"}',
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                $("#input_BalanceCode").val("");
                $("#BalanceDetail").hide();
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function EditBalance() {
    var profitList = new Array();
    var result = 1;

    var profitList = new Array();
    var comCalc = $("#txtHiddenCom").val();
    $("#tbPorfitBalance tr[name='trProfit']").each(function () {
        var ProfitPct = 0;
        if (comCalc) {
            ProfitPct  =parseFloat($(this).find("[name='txtProfitPct']").val() / 100);
        }
        var Profit = {
            SlaveID: $(this).attr("tId"),
            ProfitPct: ProfitPct
        }

        if (Profit.ProfitPct < 0) {
            result = -3;
            return;
        }
        profitList.push(Profit);
    })

    if (result == -3) {
        alert("业绩参与比例必须大于0");
        return false;
    }
    var param = {
        BalanceCode: $("#BalanceCode").text(),
        ProfitList: profitList
    }



    $.ajax({
        type: "POST",
        url: "/Order/EdtiBalanceProfit",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                $("#BalanceCode").val("");
                $("#BalanceDetail").hide();
            }
            else {
                alert(data.Message);
            }
        }
    });
}