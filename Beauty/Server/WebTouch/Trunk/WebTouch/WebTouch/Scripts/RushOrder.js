//关闭弹框
function closePop() {
    $("#guideImg1").hide();
}


function QuantityChange(Quantity,DiscountPrice) {
    if (Quantity > 0) {
        if ($("#txtQty").val() < 9999) {
            $("#txtQty").val(parseInt($("#txtQty").val()) + Quantity);
        }
    } else if (Quantity < 0) {
        if ($("#txtQty").val() > 1) {
            $("#txtQty").val(parseInt($("#txtQty").val()) + Quantity);
        }
    }
    
    var Qty = parseInt($("#txtQty").val());
    var Total = Qty * DiscountPrice;
    $("#txtSalePrice").text(Total.toFixed(2));
}

function showBranchDiv() {
    $("#guideImg1").show();
}

function selectBranch(branchId, branchName) {
    $("#divBranchName").text(branchName);
    $("#divBranchName").attr("bId", branchId);
    closePop();
}


function submitRushOrder(PromotionCode,ProductID,ProductType) {
    var branchId = $("#divBranchName").attr("bId");
    if (branchId == "") {
        alert("请选择门店!");
        return;
    }

    var RushOrder = {
        PromotionID: PromotionCode,
        ProductID: ProductID,
        ProductType: ProductType,
        Qty: $("#txtQty").val(),
        Remark: "",
        BranchID: branchId
    }


    $.ajax({
        type: "POST",
        url: "/RushOrder/AddRushOrder",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(RushOrder),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                location.href = "/RushOrder/PayRushOrder?ro=" + data.Data;
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function GotoPay() {
    var temp = "";
    $('[name="buylist"]:checked').each(function () {
        temp = $(this).val();
        location.href = "/RushOrder/PayRushOrder?ro=" + $(this).val();
    });
    if (temp == "") {
        alert("请先选择要支付的抢购单");
    }
}



function AddPay(jsParams,NetTradeNo)
{
    if (typeof WeixinJSBridge == "undefined")
    {
        alert("不是微信不能支付");
        
    }
    else
    {
        onBridgeReady(jsParams,NetTradeNo);
    }
}

function onBridgeReady(jsParams, NetTradeNo) {
    var jsModel = eval("(" + jsParams + ")");
    WeixinJSBridge.invoke(
        'getBrandWCPayRequest', {
            "appId": jsModel.appId,     //公众号名称，由商户传入     
            "timeStamp": jsModel.timeStamp,         //时间戳，自1970年以来的秒数     
            "nonceStr": jsModel.nonceStr, //随机串     
            "package": jsModel.package,
            "signType": 'MD5',         //微信签名方式:     
            "paySign": jsModel.paySign    //微信签名 
        },

        function (res) {
            if (res.err_msg != "get_brand_wcpay_request：cancel") {
                location.href = "/RushOrder/WXPayResults?tr=" + NetTradeNo;
            }
        }
    );
}


   
