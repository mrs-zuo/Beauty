function AddTask(ProductCode, ProductName) {

    var branchId = 0;
    var branchName;
    $('#olBranch [name="radio1"]:checked').each(function () {
        branchId = this.value;
        branchName = $(this).attr("bName");
    });
    if (branchId == 0) {
        alert("请选择门店");
        return false;
    }

    location.href = "/Appointment/CreateAppointment?bi=" + branchId + "&cd=" + ProductCode + "&tk=1";
}


function AddFavorite(ProductCode, ProductType) {
    var Favorite = {
        ProductCode: ProductCode,
        ProductType: ProductType
    }

    $.ajax({
        type: "POST",
        url: "/Product/AddFavorite",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Favorite),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                if (ProductType == 0) {
                    location.href = "/Product/ServiceDetail?lc=" + ProductCode;
                } else {
                    location.href = "/Product/CommodityDetail?lc=" + ProductCode;
                }
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function DelFavorite(ProductCode, ProductType, UserFavoriteID) {
    var Favorite = {
        ProductCode: ProductCode,
        ProductType: ProductType,
        UserFavoriteID: UserFavoriteID
    }

    $.ajax({
        type: "POST",
        url: "/Product/DelFavorite",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Favorite),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                if (ProductType == 0) {
                    location.href = "/Product/ServiceDetail?lc=" + ProductCode;
                } else {
                    location.href = "/Product/CommodityDetail?lc=" + ProductCode;
                }
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function AddCart(gotoFlg, ProductType, ProductCode) {
    var branchId = 0;
    $('#olBranch [name="radio1"]:checked').each(function () {
        branchId = this.value;
    });
    if (branchId == 0) {
        alert("请选择门店");
        return false;
    }


    var Cart = {
        BranchID: branchId,
        ProductCode: ProductCode,
        ProductType: ProductType,
        Quantity: 1
    }

    $.ajax({
        type: "POST",
        url: "/Product/AddCart",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Cart),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                if (gotoFlg == 2) {
                    location.href = "/Product/MyCart";
                }
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function UpdateCart(e, flg, CardId) {
    var updateQty = 0;
    if (flg == 1) {
        if ($(e).next().val() > 1) {
            $(e).next().val(parseInt($(e).next().val()) - 1);
        }
        updateQty = $(e).next().val();
    } else if (flg == 2) {
        if ($(e).prev().val() < 9999) {
            $(e).prev().val(parseInt($(e).prev().val()) + 1);
        }
        updateQty = $(e).prev().val();
    } else if (flg == 3) {
        if ($(e).val() == 0) {
            $(e).val("1");
        }
        updateQty = $(e).val();
    }
    var totalPrice = 0;
    $('input[type="checkbox"][name="chkCartID"]:checked').each(function () {
        var price = $(this).parent().parent().find("[name='spanPrice']").text();
        var qty = $(this).parent().parent().find("[name='inputQty']").val();
        totalPrice += price * qty;

    });
    var Cart = {
        CartID: CardId,
        Quantity: updateQty
    }

    $.ajax({
        type: "POST",
        url: "/Product/UpdateCart ",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Cart),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {

            }
            else {
                alert(data.Message);
            }
        }
    });


    $("#spanTotal").text(totalPrice)
}

function selectCart(e) {
    var check = true;
    $(e).parent().parent().parent().find("[name='chkCartID']").each(function () {
        if (!check) {
            return;
        }
        check = $(this).prop("checked");
    });
    $(e).parent().parent().parent().parent().find("[name='branchName']").prop("checked", check);
    CalcTotalPrice();
}

function CalcTotalPrice() {
    var totalPrice = 0;
    $('input[type="checkbox"][name="chkCartID"]:checked').each(function () {
        var price = $(this).parent().parent().find("[name='spanPrice']").text();
        var qty = $(this).parent().parent().find("[name='inputQty']").val();
        totalPrice += price * qty;

    });
    $("#spanTotal").text(totalPrice)
}

function delCart(CartID) {
    var CartIDList = new Array();
    CartIDList.push(CartID);
    var Cart = {
        CartIDList: CartIDList
    }

    var r = confirm("确认要删除该宝贝吗？")
    if (r == true) {
        $.ajax({
            type: "POST",
            url: "/Product/DeleteCart ",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(Cart),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("失败");
            },
            success: function (data) {
                if (data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Product/MyCart"
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}


function gotoPurchaseDetail() {

    var CartIDList = new Array();

    $('[name="ulDetail"] input[type="checkbox"][name="chkCartID"]:checked').each(function () {
        CartIDList.push(this.value);
    });

    if (CartIDList == "") {
        alert("请选择购买的宝贝");
        return;
    }
    var Cart = {
        CartIDList: CartIDList
    }
    $("#txtCardIDList").val(JSON.stringify(Cart));
    $("#formCart").submit();
}



//关闭弹框
function closePop() {
    $("#guideImg1").hide();
}

function showDiv(e, BranchID, ProductType, ProductCode, Qty, MarketingPolicy) {
    var aId = $(e).attr("id");

    var model = {
        BranchID: BranchID,
        ProductCode: ProductCode,
        ProductType: ProductType
    }

    $.ajax({
        type: "POST",
        url: "/Product/GetCardList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(model),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#txtCardList").data("Card", data.Data);
                showCardList(aId, Qty, MarketingPolicy);
            }
            else {
                alert(data.Message);
            }
        }
    });
}  

function showCardList(aId, Qty, MarketingPolicy) {
    var jsonCard = $("#txtCardList").data("Card");
    $("#ulCard li").remove();
     
    var navigationLinkData = new Array();

    if (typeof (jsonCard) == "undefined") {
        alert("没有可用的e卡");
        return false;
    }

    if (jsonCard.length == 0) {
        alert("没有可用的e卡");
        return false;

    }

    for (var i = 0; i < jsonCard.length; i++) {

        var model = {
            aId: aId,
            CardID: jsonCard[i].CardID,
            CardName: jsonCard[i].CardName,
            Discount: jsonCard[i].Discount,
            Quantity: Qty,
            MarketingPolicy: MarketingPolicy
        }
        navigationLinkData.push(model);
    }
    var getNavContent = function (data) {
        if (!data || !data.length) {
            return '';
        }
        var res = easyTemplate($('#templateSign').html(), data).toString();
        return res;
    };
    $('#ulCard').html(getNavContent(navigationLinkData));

    $("#guideImg1").show();
}

function selectCard(aId, CardID, CardName, Discount, Qty,MarketingPolicy) {
  
        var kj = $("#" + aId);
        kj.text(CardName);
        kj.attr("cdId", CardID)
        if (MarketingPolicy == 1) {
        var unitPrice = kj.parent().parent().parent().find("[name='UnitPrice']").text();
        var newPrice = EffectiveNum(unitPrice * Math.pow(10, 2) * Discount * Math.pow(10, 2) / Math.pow(10, 4) * Qty, 2);
        kj.parent().parent().parent().find("[name='PromotionPrice']").text(newPrice);

        var totalPrice = 0;
        $('[name="PromotionPrice"]').each(function () {
            //var Qty = $(this).parent().parent().parent().parent().parent().find("[name='divQty']").text();
            totalPrice += parseFloat($(this).text());
        });

        $("#divPromotionTotal").text(totalPrice.toFixed(2));
    }
    closePop();

}


function AddOrder() {
    var OrderList = new Array();
    $('[name=divPurchaseDetail]').each(function () {
        var UnitPrice = $(this).find("[name='UnitPrice']").text();
        var Qty = $(this).find("[name='divQty']").text();
        var TotalOrigPrice = UnitPrice * Qty;
        var TotalSalePrice = $(this).find("[name='PromotionPrice']").text();
        var model = {
            CartID: $(this).attr("cId"),
            CardID: $(this).find("[name='aCard']").attr("cdId"),
            TGPastCount: 0,
            ProductCode: $(this).attr("pCd"),
            ProductID: $(this).attr("pId"),
            BranchID: $(this).attr("bId"),
            ProductType: $(this).attr("pt"),
            StrTotalOrigPrice: TotalOrigPrice,
            StrTotalCalcPrice: TotalSalePrice
        }
        OrderList.push(model);
    });

    if (OrderList == "") {
        alert("没有数据");
        return;
    }
    var Order = {
        OrderList: OrderList
    }

    $.ajax({
        type: "POST",
        url: "/Product/AddNewOrder",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Order),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Order/UnpaidOrder"
            }
            else {
                alert(data.Message);
            }
        }
    });

}


function selectBranchCartAll(e) {
    var checked = $(e).prop("checked");
    $(e).parent().parent().parent().next().find("[name='chkCartID']").prop("checked", checked);
    CalcTotalPrice();
    
}

