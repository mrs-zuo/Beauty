/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    getSupplierList();
    getCommodityList();
    $("#mutiSelect").val("0");
    $("#selectSupplierId").val("");
})

function getSupplierList() {
    $("#hidData").data("Supplier", "");
    var UtilityOperation = {
    };

    $.ajax({
        type: "POST",
        url: "/SupplierCommodity/GetSupplierList",
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
                showSupplierList(0);
            }
        }
    });
}

function getCommodityList() {

    $("#hidData").data("Commodity", "");
    var UtilityOperation = {
    };

    $.ajax({
        type: "POST",
        url: "/SupplierCommodity/GetCommodityList",
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
                showCommodityList(0, 0);
            }
        }
    });
}

function getSupplierCommodity(SupplierId, e) {
    $("#hidData").data("selectedCommodity","");
    var muti = $("#mutiSelect").val();
    var selectCnt = 1;
    if (muti == "0") {
        $("#selectSupplierId").val("");
        $("#selectSupplierId").val(SupplierId);
        $("#tbSupplier tr").attr("class", "");
        $(e).addClass("selected");
        $("#hidData").data("relationFlg", "");
    } else {
        var temp = $("#selectSupplierId").val();
        if (temp != "") {
            selectCnt = 2;
            temp += "|" + SupplierId;
        } else {
            temp = SupplierId;
        }
        $("#selectSupplierId").val(temp);
        if ($(e).hasClass("selected")) {
            $(e).removeClass("selected");
        } else {
            $(e).addClass("selected");
        }
    }

    if (selectCnt == 1) {
        $("#hidData").data("Commodity", "");
        var UtilityOperation = {
            SupplierID: SupplierId
        };
        $.ajax({
            type: "POST",
            url: "/SupplierCommodity/getSupplierCommodityList",
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
                    initSelectCommodity();
                    showCommodityList(0, 1);
                }
            }
        });
    }
}

function showCommodityList(searchFlg, relationFlg) {
    if ($("#selectSupplierId").val() == "" && searchFlg == 1) {
        alert("请先选择供应商");
        $("#txtSearchCommodity").val("");
        return false;
    }

    var strSearch = $("#txtSearchCommodity").val();
    var selectList = new Array();
    if (searchFlg == 1) {
        selectList =  $("#hidData").data("selectedCommodity");
    }

    var jsonCommodity = $("#hidData").data("Commodity");
    $("#tbCommodity tr").remove();
    for (var i = 0; i < jsonCommodity.length; i++) {
        if (searchFlg == 0) {
            if (jsonCommodity[i].isChecked) {
                $("#tbCommodity").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" checked="checked" onclick="selectCommodity(this)" name="chkCommodity" value="' + jsonCommodity[i].CommodityID + '"><span class="over-text text">' + jsonCommodity[i].CommodityName + '</span></label></td></tr>');
                if (relationFlg == 1) {
                    $("#hidData").data("relationFlg", "true");
                }
            } else {
                $("#tbCommodity").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" name="chkCommodity" onclick="selectCommodity(this)" value="' + jsonCommodity[i].CommodityID + '"><span class="over-text text">' + jsonCommodity[i].CommodityName + '</span></label></td></tr>');
            }
        } else {
            if (jsonCommodity[i].SearchOut.indexOf(strSearch) > -1) {
                var Re = false;
                for (var j = 0; j < selectList.length; j++) {
                    if (jsonCommodity[i].CommodityID == selectList[j]) {
                        Re = true;
                        break;
                    }
                }
                if (Re) {
                    $("#tbCommodity").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" checked="checked" onclick="selectCommodity(this)" name="chkCommodity" value="' + jsonCommodity[i].CommodityID + '"><span class="over-text text">' + jsonCommodity[i].CommodityName + '</span></label></td></tr>');
                } else {
                    $("#tbCommodity").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" name="chkCommodity" onclick="selectCommodity(this)" value="' + jsonCommodity[i].CommodityID + '"><span class="over-text text">' + jsonCommodity[i].CommodityName + '</span></label></td></tr>');
                }
            }
        }
    }

    $("#CommodityCnt").text(jsonCommodity.length);

}

function showSupplierList(relationFlg) {

    var jsonSupplier = $("#hidData").data("Supplier");
    $("#tbSupplier tr").remove();

    if (jsonSupplier.length > 0 && relationFlg == 1) {
        $("#hidData").data("relationFlg", "true");
    }

    for (var i = 0; i < jsonSupplier.length; i++) {
        if ($("#txtSearchSupplier").val() == "") {
            $("#tbSupplier").append('<tr cid=' + jsonSupplier[i].SupplierID + ' class="" onclick="getSupplierCommodity(' + jsonSupplier[i].SupplierID + ',this)"><td>' + jsonSupplier[i].SupplierName + '</td></tr>');
        } else {
            var strSearch = $("#txtSearchSupplier").val();
            if (jsonSupplier[i].SearchOut.indexOf(strSearch) > -1) {
                $("#tbSupplier").append('<tr cid=' + jsonSupplier[i].SupplierID + ' class="" onclick="getSupplierCommodity(' + jsonSupplier[i].SupplierID + ',this)"><td>' + jsonSupplier[i].SupplierName + '</td></tr>');
            }
        }
    }


    $("#SupplierCnt").text(jsonSupplier.length);
}


function selectCommodity(e) {
    if ($("#selectSupplierId").val() == "") {
        alert("请先选择供应商");
        $(e).attr("checked", false)
        return false;
    } else {
        var check = $(e).prop("checked");
        var selectList;
        if ($("#hidData").data("selectedCommodity") == "") {
            selectList = new Array();
        } else {
            selectList = $("#hidData").data("selectedCommodity");
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

            $("#hidData").data("selectedCommodity", selectList);
        } else {
            if (selectList == "") {
                $("#hidData").data("selectedCommodity", "");
            } else {
                for (var i = 0; i < selectList.length; i++) {
                    if (selectList[i] == $(e).val()) {
                        selectList.splice(i, 1);
                    }
                }
                $("#hidData").data("selectedCommodity", selectList);
            }

        }
        $(e).prop("checked", check);
    }
}

function submit() {

    var SupplierList = new Array();

    $('#tbSupplier tr').each(function () {
        if ($(this).hasClass("selected")) {
            var id = $(this).attr("cid");
            SupplierList.push(id);
        }
    });

    if (SupplierList == null) {
        alert("请先选择供应商");
        return false;
    }

    var CommodityId = 0;
    var CommodityList = new Array();

    var selectList =  $("#hidData").data("selectedCommodity");

    for(var i = 0; i<selectList.length;i++){
        CommodityId = selectList[i];
        CommodityList.push(selectList[i]);
    };


    var relationFlg = $("#hidData").data("relationFlg");

    if (CommodityId == 0 && relationFlg == "") {
        alert("当前数据未改变");
        return false;
    }
    var SupplierCommodityOperation = {
        ListCommodityID: CommodityList,
        ListSupplierID: SupplierList
        
    };

    $.ajax({
        type: "POST",
        url: "/SupplierCommodity/ChangeSupplierCommodity",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(SupplierCommodityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                location.href = "/SupplierCommodity/EditSupplierCommodity";
            } else {
                alert(data.Message);
            }
        }
    });

}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);


function initSelectCommodity() {
    var jsonCommodity = $("#hidData").data("Commodity");
    var selectList = new Array();
    for (var i = 0; i < jsonCommodity.length; i++) {
        if (jsonCommodity[i].isChecked) {
            selectList.push(jsonCommodity[i].CommodityID);
        }
    }
    
    $("#hidData").data("selectedCommodity", selectList);
}