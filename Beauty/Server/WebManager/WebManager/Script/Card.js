/// <reference path="../assets/js/jquery-2.0.3.min.js" />
function deleteCard(CardID) {
    if (confirm("确定要删除吗?")) {
        var param = '{"CardID":' + CardID + '}';
        $.ajax({
            type: "POST",
            url: "/Card/deleteCard",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Card/GetCardList";
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function setDefaultCard(CardCode, Type) {

    if (Type == 1) {
        CardCode = 0;
    }
    var param = '{"CardCode":' + CardCode + '}';
    $.ajax({
        type: "POST",
        url: "/Card/setDefaultCard",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Card/GetCardList";
            }
            else {
                alert(data.Message);
            }
        }
    });

}

function showDiscountList() {
    var DiscountList = new Array();
    $('#divDiscount [name="showDiscountDiv"]').each(function () {
        var DiscountMode = {
            DiscountID: $(this).attr("id"),
            Discount: $(this).find(".form-control").val()
        };
        DiscountList.push(DiscountMode);
        $('#tbDiscount input[type="checkbox"][name="chkDiscount"][value="' + $(this).attr("id") + '"]').prop("checked", "checked");
    });

    $("#hidData").data("Discount", "");
    $("#hidData").data("Discount", DiscountList);
}



function showSelectedDiscount() {
    var selectedList = new Array();
    var jsonDiscount = $("#hidData").data("Discount");
    $('#tbDiscount input[type="checkbox"][name="chkDiscount"]:checked').each(function () {
        var DiscountName = $(this).next().text();
        var DiscountID = this.value;
        var Discount = "0.00";
        for (var i = 0; i < jsonDiscount.length; i++) {
            if (jsonDiscount[i].DiscountID == DiscountID) {
                Discount = jsonDiscount[i].Discount;
            }
        }

        var DiscountMode = {
            DiscountID: DiscountID,
            DiscountName: DiscountName,
            Discount: Discount
        };
        selectedList.push(DiscountMode);
    });

    $('#divDiscount [name="showDiscountDiv"]').remove();
    for (var i = 0; i < selectedList.length; i++) {
        $("#divDiscount").append('<div class="form-group" id="' + selectedList[i].DiscountID + '" name ="showDiscountDiv"><label class="col-sm-3 control-label no-padding-right">' + selectedList[i].DiscountName + '</label><div class="col-xs-3"><input type="text" value="' + selectedList[i].Discount + '" class="form-control" name="firstName" placeholder="输入折扣值" data-bv-notempty="true"  maxlength="5"></div></div>');
    }

}

function selectDiscountAll(e) {
    if ($(e).is(":checked")) {
        $('#tbDiscount input[type="checkbox"][name="chkDiscount"]').prop("checked", true);
    } else {
        $('#tbDiscount input[type="checkbox"][name="chkDiscount"]').prop("checked", false);
    }
}



function showBranchList() {
    $('#divBranch [name="showBranchDiv"]').each(function () {
        $('#tbBranch input[type="checkbox"][name="chkBranch"][value="' + $(this).attr("id") + '"]').prop("checked", "checked");
    });
}



function showSelectedBranch() {
    var selectedList = new Array();
    $('#tbBranch input[type="checkbox"][name="chkBranch"]:checked').each(function () {
        var BranchName = $(this).next().text();
        var BranchID = this.value;

        var BranchMode = {
            BranchID: BranchID,
            BranchName: BranchName
        };
        selectedList.push(BranchMode);
    });

    $('#divBranch [name="showBranchDiv"]').remove();
    for (var i = 0; i < selectedList.length; i++) {
        $("#divBranch").append('<div class="form-group" id="' + selectedList[i].BranchID + '" name="showBranchDiv"><label class="col-sm-3 control-label no-padding-right">' + selectedList[i].BranchName + '</label></div>');
    }

}

function selectBranchAll(e) {
    if ($(e).is(":checked")) {
        $('#tbBranch input[type="checkbox"][name="chkBranch"]').prop("checked", true);
    } else {
        $('#tbBranch input[type="checkbox"][name="chkBranch"]').prop("checked", false);
    }
}

function submit(cardId, cardType) {
    if ($.trim($("#txtCardName").val()) == "") {
        alert("卡的名称不能为空!");
        return false;
    }

    if ($("#ddlVaildPeriodUnit").val() != 4) {
        if ($.trim($("#txtVaildPeriod").val()) == "") {
            alert("有效期间不能为空!");
            return false;
        } else {
            if (isNaN($("#txtVaildPeriod").val())) {
                alert("有效期间必须是数字!")
                return false;
            } else {
                if ($("#txtVaildPeriod").val() < 1) {
                    alert("有效期间必须大于0!")
                    return false;
                }
            }
        }
    }

    if ($.trim($("#txtProfitRate").val()) == "") {
        alert("业绩折算率不能为空!");
        return false;
    } else {
        if (isNaN($("#txtProfitRate").val())) {
            alert("业绩折算率必须是数字!");
            return false;
        } else {
            if ($("#txtProfitRate").val() <= 0) {

                alert("业绩折算率必须大于0!");
                return false;
            }
            else if ($("#txtProfitRate").val() > 9.99) {
                alert("业绩折算率必须小于 9.99!");
                return false;
            }
        }
    }

    if ($.trim($("#txtRate").val()) == "") {
        if (cardId == 0 || cardType == 1) {
            alert("基础折扣率不能为空!");
        } else if (cardType == 2 || cardType == 3) {
            alert("金额抵扣率不能为空!");
        }
        return false;
    } else {
        if (isNaN($("#txtRate").val())) {
            if (cardId == 0 || cardType == 1) {
                alert("基础折扣率必须是数字!");
            } else if (cardType == 2 || cardType == 3) {
                alert("金额抵扣率必须是数字!");
            }
            return false;
        } else {
            if ($("#txtRate").val() <= 0) {
                if (cardId == 0 || cardType == 1) {
                    alert("基础折扣率必须大于0!");
                } else if (cardType == 2 || cardType == 3) {
                    alert("金额抵扣率必须大于0!");
                }
                return false;
            } else if ($("#txtRate").val() > 1) {
                if (cardId == 0 || cardType == 1) {
                    alert("基础折扣率必须小于1!");
                } else if (cardType == 2 || cardType == 3) {
                    alert("金额抵扣率必须小于1!");
                }
                return false;
            }
        }
    }

    if (cardId == 0 || cardType == 1) {
        if ($.trim($("#txtStartAmount").val()) != "") {
            if (isNaN($("#txtStartAmount").val())) {
                alert("起冲金额必须是数字!");
                return false;
            } else {
                if ($("#txtStartAmount").val() < 0) {
                    alert("起冲金额必须大于0!");
                    return false;
                } else if ($("#txtStartAmount").val() > 92237203685477.5808) {
                    alert("金额抵扣率必须小于92237203685477.5808!");
                    return false;
                }
            }
        }

        if ($.trim($("#txtBalanceNotice").val()) != "") {
            if (isNaN($("#txtBalanceNotice").val())) {
                alert("余额提醒值必须是数字!");
                return false;
            } else {
                if ($("#txtBalanceNotice").val() < 0) {
                    alert("余额提醒值必须大于0!");
                    return false;
                } else if ($("#txtBalanceNotice").val() > 92237203685477.5808) {
                    alert("余额提醒值必须小于92237203685477.5808!");
                    return false;
                }
            }
        }

        var result = true;
        var DiscountList = new Array();
        $('#divDiscount [name="showDiscountDiv"]').each(function () {
            var discount = $(this).find(".form-control").val();

            if (discount == "") {
                alert("折扣不能为空!");
                result = false;
                return false;
            } else {
                if (isNaN(discount)) {
                    alert("折扣必须是数字!");
                    result = false;
                    return false;
                } else {
                    if (discount <= 0) {
                        alert("折扣必须大于0!");
                        result = false;
                        return false;
                    } else if (discount > 1) {
                        alert("折扣必须小于1!");
                        result = false;
                        return false;
                    }
                }
            }
            var DiscountMode = {
                DiscountID: $(this).attr("id"),
                Discount: discount
            };
            DiscountList.push(DiscountMode);
        });

        if (!result) {
            return;
        }
        var BranchList = new Array();

        $('#divBranch [name="showBranchDiv"]').each(function () {
            var BranchMode = {
                BranchID: $(this).attr("id")
            };
            BranchList.push(BranchMode)
        });

        var CardMode = {
            ID: cardId,
            CardName: $("#txtCardName").val(),
            CardCode: $("#txtCardCode").val(),
            CardTypeID: $("#ddlCardType").val(),
            CardDescription: $("#txtCardDescription").val(),
            VaildPeriod: $("#txtVaildPeriod").val(),
            ValidPeriodUnit: $("#ddlVaildPeriodUnit").val(),
            Rate: $("#txtRate").val(),
            StartAmount: $("#txtStartAmount").val() == "" ? 0 : $("#txtStartAmount").val(),
            BalanceNotice: $("#txtBalanceNotice").val() == "" ? 0 : $("#txtBalanceNotice").val(),
            CardBranchType: 2,
            CardProductType: 2,
            listDiscount: DiscountList,
            listBranch: BranchList,
            ProfitRate: $.trim($("#txtProfitRate").val())
        };
    } else if (cardType == 2 || cardType == 3) {
        if ($.trim($("#txtPresentRate").val()) != "") {
            if (isNaN($("#txtPresentRate").val())) {
                alert("赠送比例必须是数字!");
                return false;
            } else {
                if ($("#txtPresentRate").val() < 0) {
                    alert("赠送比例必须大于0!");
                    return false;
                } else if ($("#txtPresentRate").val() > 1) {
                    alert("赠送比例必须小于1!");
                    return false;
                }
            }
        }
        var CardMode = {
            ID: cardId,
            CardName: $("#txtCardName").val(),
            CardCode: $("#txtCardCode").val(),
            CardTypeID: $("#ddlCardType").val(),
            CardDescription: $("#txtCardDescription").val(),
            VaildPeriod: $("#txtVaildPeriod").val(),
            ValidPeriodUnit: $("#ddlVaildPeriodUnit").val(),
            Rate: $("#txtRate").val(),
            PresentRate: $("#txtPresentRate").val() == "" ? 0 : $("#txtPresentRate").val(),
            CardBranchType: 2,
            CardProductType: 2,

            ProfitRate: $.trim($("#txtProfitRate").val())
        };
    }

    $.ajax({
        type: "POST",
        url: "/Card/OperationCard",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(CardMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Card/GetCardList";
            }
            else {
                alert(data.Message);
            }
        }
    });

}

function ValidPeriodUnitChange(e) {
    if ($(e).val() == 4) {
        $("#txtVaildPeriod").val("");
        $("#txtVaildPeriod").attr("disabled", "disabled");
    } else {
        $("#txtVaildPeriod").removeAttr("disabled");
    }

}