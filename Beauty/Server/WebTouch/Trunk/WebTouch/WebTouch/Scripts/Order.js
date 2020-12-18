function confirmTG(OrderTyle, OrderID, OrderObjectID, GroupNo) {
    var TGDetailList = new Array();
    var TGDetail = {
        OrderType: OrderTyle,
        OrderID: OrderID,
        OrderObjectID: OrderObjectID,
        GroupNo: GroupNo
    }

    TGDetailList.push(TGDetail);

    $.ajax({
        type: "POST",
        url: "/Order/ComfirmTG",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(TGDetailList),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Order/UnconfirmedOrder";
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function EditReview(groupNo) {
    var TGSatisfaction = $('#star li[class="on"]').size();
    if (TGSatisfaction < 1) {
        alert("评价错误");
        return false;
    }
    var TGComment = $("#TGComment").val();

    var TMList = new Array();

    $('#small  div[name="TMReviewDiv"]').each(function () {
        var TreatmentID = $(this).attr("tId");
        var TMComment = $(this).find('[name="textAreaTMReview"]').val();
        var TMSatisfaction = $(this).find('li[class="on"]').size();
        var TM = {
            TreatmentID: TreatmentID,
            Satisfaction: TMSatisfaction,
            Comment: TMComment,
        }
        TMList.push(TM)
    });


    var mTGReview = {
        GroupNo: groupNo,
        Satisfaction: TGSatisfaction,
        Comment: TGComment,
    }

    var ReviewMode = {
        mTGReview: mTGReview,
        listTMReview: TMList
    }


    $.ajax({
        type: "POST",
        url: "/Order/EditReview",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(ReviewMode),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Order/UnReviewedOrder";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function AddPayment(jsonAdd) {
    $.ajax({
        type: "POST",
        url: "/Order/AddPayment",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: jsonAdd,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Order/UnpaidOrder";
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function GotoPayment() {
    var branchId = -1;
    var cardId = -1;
    var paymentStatus = -1;
    var result = 0;
    var OrderCount = 0;
    var TotalPrice = 0;
    var OrderList = new Array();
    $('input[type="checkbox"][name="chkOrder"]:checked').each(function () {
        if (result < 0) {
            return;
        }
        var bId = $(this).attr("bId");
        var cId = $(this).attr("cId");
        var pys = $(this).attr("pys");
        if (branchId == -1) {
            branchId = bId;
        } else {
            if (branchId != bId) {
                result = -1;
                return;
            }
        }
        if (cId == 0) {
            result = -4;
            return;
        } else {
            if (cardId == -1) {
                cardId = cId;
            } else {
                if (cardId != cId) {
                    result = -2;
                    return;
                }
            }
        }

        if (paymentStatus == -1) {
            paymentStatus = pys;
        } else if (paymentStatus == 1) {
            if (pys > 1) {
                result = -3;
                return;
            }
        } else {
            result = -3;
            return;
        }

        OrderCount += 1;
        TotalPrice += parseFloat($(this).attr("up"));
        var order = {
            OrderID: $(this).attr("od"),
            OrderObjectID: $(this).attr("ob"),
            ProductType: $(this).attr("pt")
        }
        result = 1;
        OrderList.push(order);
    });

    if (result < 1) {
        var msg;
        switch (result) {
            case -1:
                msg ="不同门店的订单不能一起支付" ;
                break;
            case -2:
                msg = "不同卡的订单不能一起支付";
                break;
            case -3:
                msg = "部分付的订单不能一起支付";
                break;
            case -4:
                msg = "没有会员卡的订单不能支付";
                break;
            case 0:
                msg = "请选择支付的订单";
                break;
        }
        alert(msg);
        return;
    }

    var Payment = {
        OrderCount: OrderCount,
        TotalSalePrice: TotalPrice,
        BranchID: branchId,
        OrderList: OrderList
    }

    $("#txtOrderList").val(JSON.stringify(Payment));
    $("#formUnpaid").submit();

}

function selectAllUnpaid() {
    var checked = $("#selectAllUnpaid").prop("checked");
    $('input[type="checkbox"][name="chkOrder"]').prop("checked", checked);
    calcTotalPrice();
}

function calcTotalPrice() {
    var totalPirce = 0;
    $('input[type="checkbox"][name="chkOrder"]:checked').each(function () {
        totalPirce += parseFloat($(this).attr("up"));
    });
    $("#totalSpan").text(totalPirce);
}
