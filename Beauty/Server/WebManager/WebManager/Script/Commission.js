/// <reference path="../assets/js/jquery-2.0.3.min.js" />
(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function SearchAccount() {
    var inputSearch = encodeURI(encodeURI($.trim($("#txtInputSearch").val())));
    window.location.href = "/Commission/AccountList?InputSearch=" + inputSearch;
}

function EditAccount(AccountID) {
    var res = true;
    var BaseSalary = $.trim($("#txtBaseSalary").val());
    if (BaseSalary == "") {
        alert("请输入底薪");
        return;
    }
    var ListComm = new Array();
    var HaveSales = $("#radioCommSalesY").is(":checked");
    if (HaveSales) {
        var mCommFirst = {
            CommType: 1,
            CommPattern: 2,
            ProfitRangeUnit: 1,
            ProfitMinRange: 0,
            ProfitMaxRange: $("#txtFirstMaxSales").val(),
            ProfitPct: $("#txtFirstPorfitSales").val()
        }

        if ($.trim(mCommFirst.ProfitMaxRange) == "") {
            alert("请输入销售的最大值");
            return;
        } else {
            if (isNaN(mCommFirst.ProfitMaxRange) || mCommFirst.ProfitMaxRange <= 0) {
                alert("销售最大值请输入大于0的数字");
                return;
            }
        }

        if ($.trim(mCommFirst.ProfitPct) == "") {
            alert("请输入销售提成比例");
            return;
        } else {
            if (isNaN(mCommFirst.ProfitPct) || mCommFirst.ProfitPct < 0) {
                alert("提成比例请输入大于0的数字");
                return;
            }
        }


        ListComm.push(mCommFirst);

        $("#divCommSales div[name='divCommProfit']").each(function () {
            if (!res) {
                return;
            }
            var mComm = {
                CommType: 1,
                CommPattern: 2,
                ProfitRangeUnit: 1,
                ProfitMinRange: $(this).find("[name='txtMinRange']").val(),
                ProfitMaxRange: $(this).find("[name='txtMaxRange']").val(),
                ProfitPct: $(this).find("[name='txtProfitPct']").val(),
            }


            if ($.trim(mComm.ProfitMinRange) == "") {
                alert("请先输入最小值");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitMinRange) || mComm.ProfitMinRange <= 0) {
                    alert("最小值请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if ($.trim(mComm.ProfitMaxRange) == "") {
                alert("请先输入最大值");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitMaxRange) || mComm.ProfitMaxRange <= 0) {
                    alert("最大值请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if ($.trim(mComm.ProfitPct) == "") {
                alert("请输入提成比例");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitPct) || mComm.ProfitPct < 0) {
                    alert("提成比例请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            ListComm.push(mComm);
        });

        if (!res) {
            return;
        }
        var mCommLast = {
            CommType: 1,
            CommPattern: 2,
            ProfitRangeUnit: 1,
            ProfitMinRange: $("#txtLastMinSales").val(),
            ProfitMaxRange: 999999999,
            ProfitPct: $("#txtLastPorfitSales").val()
        }

        if ($.trim(mCommLast.ProfitMinRange) == "") {
            alert("请输入销售的最小值");
            return;
        } else {
            if (isNaN(mCommLast.ProfitMinRange) || mCommLast.ProfitMinRange <= 0) {
                alert("销售的最小值请输入大于0的数字");
                return;
            }
        }

        if ($.trim(mCommLast.ProfitPct) == "") {
            alert("请输入销售的提成比例");
            return;
        } else {
            if (isNaN(mCommLast.ProfitPct) || mCommLast.ProfitPct < 0) {
                alert("销售的提成比例请输入大于0的数字");
                return;
            }
        }
        ListComm.push(mCommLast);
    } else {
        var mComm = {
            CommType: 1,
            CommPattern: 1,
            ProfitRangeUnit: 1,
            ProfitMinRange: -1,
            ProfitMaxRange: -1,
            ProfitPct: -1
        }
        ListComm.push(mComm);
    }



    var HaveOperate = $("#radioCommOperateY").is(":checked");
    var ProfitRangeUnit = $("#ddlRole").val();
    if (HaveOperate) {

        var mCommFirst = {
            CommType: 2,
            CommPattern: 2,
            ProfitRangeUnit: ProfitRangeUnit,
            ProfitMinRange: 0,
            ProfitMaxRange: $("#txtFirstMaxOperate").val(),
            ProfitPct: $("#txtFirstPorfitOperate").val()
        }

        if ($.trim(mCommFirst.ProfitMaxRange) == "") {
            alert("请输入操作的最大值");
            return;
        } else {
            if (isNaN(mCommFirst.ProfitMaxRange) || mCommFirst.ProfitMaxRange <= 0) {
                alert("操作的最大值请输入大于0的数字");
                return;
            }
        }

        if ($.trim(mCommFirst.ProfitPct) == "") {
            alert("请输入操作的提成比例");
            return;
        } else {
            if (isNaN(mCommFirst.ProfitPct) || mCommFirst.ProfitPct < 0) {
                alert("操作的提成比例请输入大于0的数字");
                return;
            }
        }


        ListComm.push(mCommFirst);

        $("#divCommOperate div[name='divCommProfit']").each(function () {
            if (!res) {
                return;
            }
            var mComm = {
                CommType: 2,
                CommPattern: 2,
                ProfitRangeUnit: ProfitRangeUnit,
                ProfitMinRange: $(this).find("[name='txtMinRange']").val(),
                ProfitMaxRange: $(this).find("[name='txtMaxRange']").val(),
                ProfitPct: $(this).find("[name='txtProfitPct']").val(),
            }


            if ($.trim(mComm.ProfitMinRange) == "") {
                alert("请输入操作的最小值");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitMinRange) || mComm.ProfitMinRange <= 0) {
                    alert("操作的最小值请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if ($.trim(mComm.ProfitMaxRange) == "") {
                alert("请先输入操作的最大值");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitMaxRange) || mComm.ProfitMaxRange <= 0) {
                    alert("操作的最大值请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if ($.trim(mComm.ProfitPct) == "") {
                alert("请输入操作的提成比例");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitPct) || mComm.ProfitPct < 0) {
                    alert("操作的提成比例请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            ListComm.push(mComm);
        });

        if (!res) {
            return;
        }
        var mCommLast = {
            CommType: 2,
            CommPattern: 2,
            ProfitRangeUnit: ProfitRangeUnit,
            ProfitMinRange: $("#txtLastMinOperate").val(),
            ProfitMaxRange: 999999999,
            ProfitPct: $("#txtLastPorfitOperate").val()
        }

        if ($.trim(mCommLast.ProfitMinRange) == "") {
            alert("请先输入操作的最小值");
            return;
        } else {
            if (isNaN(mCommLast.ProfitMinRange) || mCommLast.ProfitMinRange <= 0) {
                alert("操作的最小值请输入大于0的数字");
                return;
            }
        }

        if ($.trim(mCommLast.ProfitPct) == "") {
            alert("请输入操作的提成比例");
            return;
        } else {
            if (isNaN(mCommLast.ProfitPct) || mCommLast.ProfitPct < 0) {
                alert("操作的提成比例请输入大于0的数字");
                return;
            }
        }
        ListComm.push(mCommLast);
    } else {
        var mComm = {
            CommType: 2,
            CommPattern: 1,
            ProfitRangeUnit: ProfitRangeUnit,
            ProfitMinRange: -1,
            ProfitMaxRange: -1,
            ProfitPct: -1
        }
        ListComm.push(mComm);
    }



    var HaveRecharge = $("#radioCommRechargeY").is(":checked");
    if (HaveRecharge) {
        var mCommFirst = {
            CommType: 3,
            CommPattern: 2,
            ProfitRangeUnit: 1,
            ProfitMinRange: 0,
            ProfitMaxRange: $("#txtFirstMaxRecharge").val(),
            ProfitPct: $("#txtFirstPorfitRecharge").val()
        }

        if ($.trim(mCommFirst.ProfitMaxRange) == "") {
            alert("请先输入储值卡销售的最大值");
            return;
        } else {
            if (isNaN(mCommFirst.ProfitMaxRange) || mCommFirst.ProfitMaxRange <= 0) {
                alert("储值卡销售的最大值请输入大于0的数字");
                return;
            }
        }

        if ($.trim(mCommFirst.ProfitPct) == "") {
            alert("请输入储值卡销售的提成比例");
            return;
        } else {
            if (isNaN(mCommFirst.ProfitPct) || mCommFirst.ProfitPct < 0) {
                alert("储值卡销售的提成比例请输入大于0的数字");
                return;
            }
        }


        ListComm.push(mCommFirst);

        $("#divCommRecharge div[name='divCommProfit']").each(function () {
            if (!res) {
                return;
            }
            var mComm = {
                CommType: 3,
                CommPattern: 2,
                ProfitRangeUnit: 1,
                ProfitMinRange: $(this).find("[name='txtMinRange']").val(),
                ProfitMaxRange: $(this).find("[name='txtMaxRange']").val(),
                ProfitPct: $(this).find("[name='txtProfitPct']").val(),
            }


            if ($.trim(mComm.ProfitMinRange) == "") {
                alert("请先输入储值卡销售的最小值");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitMinRange) || mComm.ProfitMinRange <= 0) {
                    alert("储值卡销售的最小值请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if ($.trim(mComm.ProfitMaxRange) == "") {
                alert("请先输入储值卡销售的最大值");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitMaxRange) || mComm.ProfitMaxRange <= 0) {
                    alert("储值卡销售的最大值请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if ($.trim(mComm.ProfitPct) == "") {
                alert("请输入储值卡销售的提成比例");
                res = false;
                return;
            } else {
                if (isNaN(mComm.ProfitPct) || mComm.ProfitPct < 0) {
                    alert("储值卡销售的提成比例请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            ListComm.push(mComm);
        });

        if (!res) {
            return;
        }
        var mCommLast = {
            CommType: 3,
            CommPattern: 2,
            ProfitRangeUnit: 1,
            ProfitMinRange: $("#txtLastMinRecharge").val(),
            ProfitMaxRange: 999999999,
            ProfitPct: $("#txtLastPorfitRecharge").val()
        }

        if ($.trim(mCommLast.ProfitMinRange) == "") {
            alert("请先输入储值卡销售的最小值");
            return;
        } else {
            if (isNaN(mCommLast.ProfitMinRange) || mCommLast.ProfitMinRange <= 0) {
                alert("储值卡销售的最小值请输入大于0的数字");
                return;
            }
        }

        if ($.trim(mCommLast.ProfitPct) == "") {
            alert("请输入储值卡销售的提成比例");
            return;
        } else {
            if (isNaN(mCommLast.ProfitPct) || mCommLast.ProfitPct < 0) {
                alert("储值卡销售的提成比例请输入大于0的数字");
                return;
            }
        }
        ListComm.push(mCommLast);
    } else {
        var mComm = {
            CommType: 3,
            CommPattern: 1,
            ProfitRangeUnit: 1,
            ProfitMinRange: -1,
            ProfitMaxRange: -1,
            ProfitPct: -1
        }
        ListComm.push(mComm);
    }

    var Account = {
        AccountID: AccountID,
        BaseSalary: BaseSalary,
        ListComm: ListComm
    }

    $.ajax({
        type: "POST",
        url: "/Commission/UpdateAccount",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Account),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Commission/AccountList?#" + AccountID;
            }
            else
                alert(data.Message);
        }
    });
}


function ShowCommDiv(divName, value) {

    var parentName = "div" + divName;
    if (value) {
        $("#" + parentName).show();
    } else {
        var subName = "divComm" + divName;
        var txtFirstMax = "txtFirstMax" + divName;
        var txtLastMin = "txtLastMin" + divName;
        $("#" + subName + " div").remove();
        $("#" + parentName).hide();
        $("#" + txtFirstMax).val("");
        $("#" + txtLastMin).val("");
    }
}

function addComm(divName) {
    var MaxProfit = "";
    var parentName = "div" + divName;
    var subName = "divComm" + divName;
    var Total = $("#" + subName + " div[name='divCommProfit']").length;
    if (Total == 0) {
        var txtMaxName = "txtFirstMax" + divName;
        MaxProfit = $("#" + txtMaxName).val();
        if ($.trim(MaxProfit) == "") {
            alert("请输入最大值");
            return;
        } else {
            if (isNaN(MaxProfit) || MaxProfit <= 0) {
                alert("最大值请输入大于0的数字");
                return;
            }
        }
        $("#" + txtMaxName).attr("readonly", "readonly");
    } else {
        var CurrentDiv = $("#" + subName).children().eq(Total - 1);
        MaxProfit = CurrentDiv.find("[name='txtMaxRange']").val();
        if ($.trim(MaxProfit) == "") {
            alert("请输入最大值");
            return;
        } else {
            if (isNaN(MaxProfit) || MaxProfit <= 0) {
                alert("最大值请先入大于0的数字");
                return;
            }
        }
        CurrentDiv.find("[name='txtMaxRange']").attr("readonly", "readonly");
    }



    var MinProfit = parseFloat(MaxProfit) + 0.01;

    var navigationLinkData = new Array();
    var model = {
        ProfitMinRange: MinProfit,
        ProfitName: divName
    }
    navigationLinkData.push(model);
    var getNavContent = function (data) {
        if (!data || !data.length) {
            alert(2);
            return '';
        }
        var res = easyTemplate($('#templateSign').html(), data).toString();
        return res;
    };
    $('#' + subName).append(getNavContent(navigationLinkData));
}

function Minus(e, divName) {
    var subName = "divComm" + divName;
    $(e).parent().parent().remove();
    var divCount = $("#" + subName + " div[name='divCommProfit']").length;
    if (divCount == 0) {
        var txtMaxName = "txtFirstMax" + divName
        $("#" + txtMaxName).removeAttr("readonly");
    } else {
        $("#" + subName).children().eq(divCount - 1).find("[name='txtMaxRange']").removeAttr("readonly");
    }
}

function MaxChange(e, divName) {
    var txtLastMin = "txtLastMin" + divName;
    var min = $(e).val();
    if ($.trim(min) == "") {
        alert("请输入最大值");
        return;
    } else {
        if (isNaN(min) || min <= 0) {
            alert("最大值请输入大于0的数字");
            return;
        }
    }
    var MinProfit = parseFloat($(e).val()) + 0.01;

    $("#" + txtLastMin).val(MinProfit);
}




function SearchService() {
    var inputSearch = encodeURI(encodeURI($.trim($("#txtInputSearch").val())));
    window.location.href = "/Commission/ServiceList?InputSearch=" + inputSearch;
}

function SubmitService(ProductCode, HaveSubService) {

    var res = true;
    var ProfitPct = $.trim($("#txtProfitPct").val());
    var ECardSACommType = $("#ddlECardSACommType").val();
    var ECardSACommValue = $.trim($("#txtECardSACommValue").val());
    var NECardSACommType = $("#ddlNECardSACommType").val();
    var NECardSACommValue = $.trim($("#txtNECardSACommValue").val());
    var DesOPCommType = 1;
    var DesOPCommValue = 1;
    var OPCommType = 1;
    var OPCommValue = 1;
    var listSubService = new Array();

    if (ProfitPct == "") {
        alert("请输入业绩计算比例");
        return;
    } else {
        if (isNaN(ProfitPct) || ProfitPct < 0) {
            alert("业绩计算比例请输入大于0的数字");
            return;
        }
    }


    if (ECardSACommValue == "") {
        alert("请输入e账户的提成");
        return;
    } else {
        if (isNaN(ECardSACommValue) || ECardSACommValue < 0) {
            alert("e账户的提成请输入大于0的数字");
            return;
        }
    }

    if (NECardSACommValue == "") {
        alert("请输入非e账户的提成");
        return;
    } else {
        if (isNaN(NECardSACommValue) || NECardSACommValue < 0) {
            alert("非e账户的提成请输入大于0的数字");
            return;
        }
    }

    if (HaveSubService == 0) {
        DesOPCommType = $("#divSubService").find("[name='ddlDesOPCommType']").val();
        DesOPCommValue = $("#divSubService").find("[name='txtDesOPCommValue']").val();
        OPCommType = $("#divSubService").find("[name='ddlOPCommType']").val();
        OPCommValue = $("#divSubService").find("[name='txtOPCommValue']").val();
        if (DesOPCommValue == "") {
            alert("请输入指定操作业绩提成");
            return;
        } else {
            if (isNaN(DesOPCommValue) || DesOPCommValue < 0) {
                alert("指定操作业绩提成请输入大于0的数字");
                return;
            }
        }
        if (OPCommValue == "") {
            alert("请输入非指定操作业绩提成");
            return;
        } else {
            if (isNaN(OPCommValue) || OPCommValue < 0) {
                alert("非指定操作业绩提成请输入大于0的数字");
                return;
            }
        }
    } else {

        $("#divSubService div[name='divSubServiceOP']").each(function () {
            if (!res) {
                return;
            }

            var SubService = {
                SubServiceCode: $(this).attr("tId"),
                DesSubServiceProfitPct: $(this).find("[name='txtDesSubServiceProfitPct']").val(),
                DesSubOPCommType: $(this).find("[name='ddlDesSubOPCommType']").val(),
                DesSubOPCommValue: $(this).find("[name='txtDesSubOPCommValue']").val(),
                SubServiceProfitPct: $(this).find("[name='txtSubServiceProfitPct']").val(),
                SubOPCommType: $(this).find("[name='ddlSubOPCommType']").val(),
                SubOPCommValue: $(this).find("[name='txtSubOPCommValue']").val(),
            }

            if (SubService.DesSubServiceProfitPct == "") {
                alert("请输入指定操作业绩计算比例");
                res = false;
                return;
            } else {
                if (isNaN(SubService.DesSubServiceProfitPct) || SubService.DesSubServiceProfitPct < 0) {
                    alert("指定操作业绩计算比例请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if (SubService.DesSubOPCommValue == "") {
                alert("请输入指定操作业绩提成");
                res = false;
                return;
            } else {
                if (isNaN(SubService.DesSubOPCommValue) || SubService.DesSubOPCommValue < 0) {
                    alert("请输入指定操作业绩提成请输入大于0的数字");
                    res = false;
                    return;
                }
            }



            if (SubService.SubServiceProfitPct == "") {
                alert("请输入非指定操作业绩计算比例");
                res = false;
                return;
            } else {
                if (isNaN(SubService.SubServiceProfitPct) || SubService.SubServiceProfitPct < 0) {
                    alert("非指定操作业绩计算比例请输入大于0的数字");
                    res = false;
                    return;
                }
            }

            if (SubService.SubOPCommValue == "") {
                alert("请输入非指定操作业绩提成");
                res = false;
                return;
            } else {
                if (isNaN(SubService.SubOPCommValue) || SubService.SubOPCommValue < 0) {
                    alert("请输入非指定操作业绩提成请输入大于0的数字");
                    res = false;
                    return;
                }
            }


            listSubService.push(SubService);
        });
    }
    if (!res) {
        return;
    }

    var Service = {
        ProductType: 0,
        ProductCode: ProductCode,
        ProfitPct: ProfitPct,
        ECardSACommType: ECardSACommType,
        ECardSACommValue: ECardSACommValue,
        NECardSACommType: NECardSACommType,
        NECardSACommValue: NECardSACommValue,
        HaveSubService: HaveSubService,
        DesOPCommType: DesOPCommType,
        DesOPCommValue: DesOPCommValue,
        OPCommType: OPCommType,
        OPCommValue: OPCommValue,
        listSubService: listSubService
    }
    $.ajax({
        type: "POST",
        url: "/Commission/EditProduct",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Service),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Commission/ServiceList?#" + ProductCode;
            }
            else
                alert(data.Message);
        }
    });
}


function SearchCommodity() {
    var inputSearch = encodeURI(encodeURI($.trim($("#txtInputSearch").val())));
    window.location.href = "/Commission/CommodityList?InputSearch=" + inputSearch;
}

function SubmitCommodity(ProductCode) {
    var Commodity = {
        ProductType: 1,
        ProductCode: ProductCode,
        ProfitPct: $.trim($("#txtProfitPct").val()),
        ECardSACommType: $("#ddlECardSACommType").val(),
        ECardSACommValue: $.trim($("#txtECardSACommValue").val()),
        NECardSACommType: $("#ddlNECardSACommType").val(),
        NECardSACommValue: $.trim($("#txtNECardSACommValue").val())
    }


    if (Commodity.ProfitPct == "") {
        alert("请输入业绩计算比例");
        return;
    } else {
        if (isNaN(Commodity.ProfitPct) || Commodity.ProfitPct < 0) {
            alert("业绩计算比例请输入大于0的数字");
            return;
        }
    }


    if (Commodity.ECardSACommValue == "") {
        alert("请输入e账户的提成");
        return;
    } else {
        if (isNaN(Commodity.ECardSACommValue) || Commodity.ECardSACommValue < 0) {
            alert("e账户的提成请输入大于0的数字");
            return;
        }
    }



    if (Commodity.NECardSACommValue == "") {
        alert("请输入非e账户的提成");
        return;
    } else {
        if (isNaN(Commodity.NECardSACommValue) || Commodity.NECardSACommValue < 0) {
            alert("非e账户的提成请输入大于0的数字");
            return;
        }
    }



    $.ajax({
        type: "POST",
        url: "/Commission/EditProduct",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Commodity),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Commission/CommodityList?#" + ProductCode;
            }
            else
                alert(data.Message);
        }
    });
}

function SubmitCard(CardCode) {
    var Card = {
        CardCode: CardCode,
        ProfitPct: $.trim($("#txtProfitPct").val()),
        FstChargeCommType: $("#ddlFstChargeCommType").val(),
        FstChargeCommValue: $.trim($("#txtFstChargeCommValue").val()),
        ChargeCommType: $("#ddlChargeCommType").val(),
        ChargeCommValue: $.trim($("#txtChargeCommType").val())
    }



    if (Card.ProfitPct == "") {
        alert("请输入业绩计算比例");
        return;
    } else {
        if (isNaN(Card.ProfitPct) || Card.ProfitPct < 0) {
            alert("业绩计算比例请输入大于0的数字");
            return;
        }
    }




    if (Card.FstChargeCommValue == "") {
        alert("请输入办卡充值提成");
        return;
    } else {
        if (isNaN(Card.FstChargeCommValue) || Card.FstChargeCommValue < 0) {
            alert("办卡充值提成请输入大于0的数字");
            return;
        }
    }


    if (Card.ChargeCommValue == "") {
        alert("请输入续费充值提成");
        return;
    } else {
        if (isNaN(Card.ChargeCommValue) || Card.ChargeCommValue < 0) {
            alert("续费充值提成请输入大于0的数字");
            return;
        }
    }



    $.ajax({
        type: "POST",
        url: "/Commission/UpdateCard",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Card),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Commission/CardList?eId=" + CardCode;
            }
            else
                alert(data.Message);
        }
    });
}