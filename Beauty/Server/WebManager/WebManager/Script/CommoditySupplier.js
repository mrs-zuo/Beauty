/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    getCommodityList();
    getSupplierList();
    $("#mutiSelect").val("0");
    $("#selectCommodityId").val("");
})

function getCommodityList() {
    $("#hidData").data("Commodity", "");
    var UtilityOperation = {
    };

    $.ajax({
        type: "POST",
        url: "/CommoditySupplier/GetCommodityList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#txtSearchCommodity").val("");
                $("#hidData").data("Commodity", data.Data);
                showCommodityList(0);
            }
        }
    });
}

function getSupplierList() {

    $("#hidData").data("Supplier", "");
    var UtilityOperation = {
    };

    $.ajax({
        type: "POST",
        url: "/CommoditySupplier/GetSupplierList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#txtSearchSupplier").val("");
                $("#hidData").data("Supplier", data.Data);
                showSupplierList(0, 0);
            }
        }
    });
}

function getCommoditySupplier(CommodityId, e) {
    $("#hidData").data("selectedSupplier", "");
    var muti = $("#mutiSelect").val();
    var selectCnt = 1;
    if (muti == "0") {
        $("#selectCommodityId").val("");
        $("#selectCommodityId").val(CommodityId);
        $("#tbCommodity tr").attr("class", "");
        $(e).addClass("selected");
        $("#hidData").data("relationFlg", "");
    } else {
        var temp = $("#selectCommodityId").val();
        if (temp != "") {
            selectCnt = 2;
            temp += "|" + CommodityId;
        } else {
            temp = CommodityId;
        }
        $("#selectCommodityId").val(temp);
        if ($(e).hasClass("selected")) {
            $(e).removeClass("selected");
        } else {
            $(e).addClass("selected");
        }
    }

    if (selectCnt == 1) {
        $("#hidData").data("Supplier", "");
        var UtilityOperation = {
            CommodityID: CommodityId
        };

        $.ajax({
            type: "POST",
            url: "/CommoditySupplier/GetCommoditySupplierList",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(UtilityOperation),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code == "1") {
                    $("#txtSearchSupplier").val("");
                    $("#hidData").data("Supplier", data.Data);
                    initSelectSupplier();
                    showSupplierList(0, 1);
                }
            }
        });
    }
}

function showSupplierList(searchFlg, relationFlg) {
    if ($("#selectCommodityId").val() == "" && searchFlg == 1) {
        alert("请先选择商品");
        $("#txtSearchSupplier").val("");
        return false;
    }

    var strSearch = $("#txtSearchSupplier").val();
    var selectList = new Array();
    if (searchFlg == 1) {
        selectList = $("#hidData").data("selectedSupplier");
    }

    var jsonSupplier = $("#hidData").data("Supplier");
    $("#tbSupplier tr").remove();
    for (var i = 0; i < jsonSupplier.length; i++) {
        if (searchFlg == 0) {
            if (jsonSupplier[i].isChecked) {
                $("#tbSupplier").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" checked="checked" onclick="selectSupplier(this)" name="chkSupplier" value="' + jsonSupplier[i].SupplierID + '"><span class="over-text text">' + jsonSupplier[i].SupplierName + '</span></label></td></tr>');
                if (relationFlg == 1) {
                    $("#hidData").data("relationFlg", "true");
                }
            } else {
                $("#tbSupplier").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" name="chkSupplier" onclick="selectSupplier(this)" value="' + jsonSupplier[i].SupplierID + '"><span class="over-text text">' + jsonSupplier[i].SupplierName + '</span></label></td></tr>');
            }
        } else {
            if (jsonSupplier[i].SearchOut.indexOf(strSearch) > -1) {
                var Re = false;
                for (var j = 0; j < selectList.length; j++) {
                    if (jsonSupplier[i].SupplierID == selectList[j]) {
                        Re = true;
                        break;
                    }
                }
                if (Re) {
                    $("#tbSupplier").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" checked="checked" onclick="selectSupplier(this)" name="chkSupplier" value="' + jsonSupplier[i].SupplierID + '"><span class="over-text text">' + jsonSupplier[i].SupplierName + '</span></label></td></tr>');
                } else {
                    $("#tbSupplier").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" name="chkSupplier" onclick="selectSupplier(this)" value="' + jsonSupplier[i].SupplierID + '"><span class="over-text text">' + jsonSupplier[i].SupplierName + '</span></label></td></tr>');
                }
            }
        }
    }

    $("#SupplierCnt").text(jsonSupplier.length);

}

function showCommodityList(relationFlg) {

    var jsonCommodity = $("#hidData").data("Commodity");
    $("#tbCommodity tr").remove();

    if (jsonCommodity.length > 0 && relationFlg == 1) {
        $("#hidData").data("relationFlg", "true");
    }

    for (var i = 0; i < jsonCommodity.length; i++) {
        if ($("#txtSearchCommodity").val() == "") {
            $("#tbCommodity").append('<tr cid=' + jsonCommodity[i].ID + ' class="" onclick="getCommoditySupplier(' + jsonCommodity[i].ID + ',this)"><td>' + jsonCommodity[i].CommodityName + '</td></tr>');
        } else {
            var strSearch = $("#txtSearchCommodity").val();
            if (jsonCommodity[i].SearchOut.indexOf(strSearch) > -1) {
                $("#tbCommodity").append('<tr cid=' + jsonCommodity[i].ID + ' class="" onclick="getCommoditySupplier(' + jsonCommodity[i].ID + ',this)"><td>' + jsonCommodity[i].CommodityName + '</td></tr>');
            }
        }
    }


    $("#CommodityCnt").text(jsonCommodity.length);
}



function selectSupplier(e) {
    if ($("#selectCommodityId").val() == "") {
        alert("请先选择商品");
        $(e).attr("checked", false)
        return false;
    } else {
        var check = $(e).prop("checked");
        var selectList;
        if ($("#hidData").data("selectedSupplier") == "") {
            selectList = new Array();
        } else {
            selectList = $("#hidData").data("selectedSupplier");
        }
        if (check) {
            if (selectList.length > 0) {
                var IsPush = true;
                for (var i = 0; i < selectList.length; i++) {
                    if (selectList[i] == $(e).val()) {
                        IsPush = false;
                    }
                }
                if (IsPush) {
                    selectList.push($(e).val());
                }
            } else {
                selectList.push($(e).val());
            }

            $("#hidData").data("selectedSupplier", selectList);
        } else {
            if (selectList == "") {
                $("#hidData").data("selectedSupplier", "");
            } else {
                for (var i = 0; i < selectList.length; i++) {
                    if (selectList[i] == $(e).val()) {
                        selectList.splice(i, 1);
                    }
                }
                $("#hidData").data("selectedSupplier", selectList);
            }

        }
        $(e).prop("checked", check);
    }
}

function submit() {

    var CommodityList = new Array();

    $('#tbCommodity tr').each(function () {
        if ($(this).hasClass("selected")) {
            var id = $(this).attr("cid");
            CommodityList.push(id);
        }
    });

    if (CommodityList == null) {
        alert("请先选择商品");
        return false;
    }

    var SupplierId = 0;
    var SupplierList = new Array();

    var selectList = $("#hidData").data("selectedSupplier");

    for (var i = 0; i < selectList.length; i++) {
        SupplierId = selectList[i];
        SupplierList.push(selectList[i]);
    };


    var relationFlg = $("#hidData").data("relationFlg");

    if (SupplierId == 0 && relationFlg == "") {
        alert("当前数据未改变");
        return false;
    }
    var CommoditySupplierOperation = {
        ListSupplierID: SupplierList,
        ListCommodityID: CommodityList,
    };

    $.ajax({
        type: "POST",
        url: "/CommoditySupplier/ChangeCommoditySupplier",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(CommoditySupplierOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                location.href = "/CommoditySupplier/EditCommoditySupplier";
            } else {
                alert(data.Message);
            }
        }
    });

}

function changeType() {
    $("#mutiSelect").val("0");
    $("#selectCommodityId").val("");
    $("#txtSearchCommodity").val("");
    $("#txtSearchSupplier").val("");
    $("#txtInputSearch").val("");
    $("#hidData").data("selectedSupplier", "");
    getCommodityList();
    getSupplierList();
}
(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);


function initSelectSupplier() {
    var jsonSupplier = $("#hidData").data("Supplier");
    var selectList = new Array();
    for (var i = 0; i < jsonSupplier.length; i++) {
        if (jsonSupplier[i].isChecked) {
            selectList.push(jsonSupplier[i].SupplierID);
        }
    }

    $("#hidData").data("selectedSupplier", selectList);
}