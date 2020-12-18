/// <reference path="Commodity.js" />
/// <reference path="../assets/js/jquery-2.0.3.min.js" />
var dateMatch = /^(\d{4})(\d{2})(\d{2})$/;
//验证日期格式
function checkExpiryDate(input_ExpiryDate) {
    if ($(input_ExpiryDate).val().match(dateMatch) == null) {
        alert("请输入正确的有效期格式,如:20190101");
        result = false;
        return;
    } else {
        var dateStr = $(input_ExpiryDate).val();
        dateStr = dateStr.substr(0, 4) + "-" + dateStr.substr(4, 2) + "-" + dateStr.substr(6, 2)
        if (!IsDate(dateStr)) {
            alert("请输入正确的有效期格式,如:20190101");
            result = false;
            return;
        }
    }

}
//验证日期合法性
function IsDate(str) {
    arr = str.split("-");
    if (arr.length == 3) {
        intYear = parseInt(arr[0], 10);
        intMonth = parseInt(arr[1], 10);
        intDay = parseInt(arr[2], 10);
        if (isNaN(intYear) || isNaN(intMonth) || isNaN(intDay)) {
            return false;
        }
        if (intMonth == 0 || intDay == 0) {
            return false;
        }
        if (intYear > 2100 || intYear < 1900 || intMonth > 12 || intMonth < 0 || intDay > 31 || intDay < 0) {
            return false;
        }
        if ((intMonth == 4 || intMonth == 6 || intMonth == 9 || intMonth == 11) && intDay > 30) {
            return false;
        }
        if ((intMonth == 1 || intMonth == 3 || intMonth == 5 || intMonth == 7 || intMonth == 8 || intMonth == 10|| intMonth == 12) && intDay > 31) {
            return false;
        }
        if (intYear % 100 == 0 && intYear % 400 || intYear % 100 && intYear % 4 == 0) {
            if (intMonth == 2 && intDay >
                29) return false;
        } else {
            if (intMonth == 2 && intDay > 28) return false;
        }
        return true;
    }
    return false;
}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function selectSupplier() {
    $("#input_Supplier").val($("#selSupplier").val());
}

function AddBatch() {

    var param = {
        ProductCode: $("#hidProductCode").val(),
        BranchID: $("#selBra").val(),
        BatchNO: $("#input_BatchNO").val(),
        Quantity: $("#input_Quantity").val(),
        ExpiryDate: $("#input_ExpiryDate").val(),
        SupplierID: $("#selSupplier").val()
    }

    if (param.BranchID == null || param.BranchID == "") {
        alert("请选择门店！");
        return;
    }

    if (param.BatchNO == null || param.BatchNO == "") {
        alert("请输入批次番号！");
        return;
    }

    if (param.Quantity == null || param.Quantity.trim() == "") {
        alert("请输入数量！");
        return;
    }

    if (isNaN(param.Quantity.trim())) {
        alert("数量必须为数字！");
        return false;
    }

    if (param.ExpiryDate == null || param.ExpiryDate == "") {
        alert("请输入有效期！");
        return;
    } else {
        var expiryDate_match = param.ExpiryDate.match(dateMatch);
        if (expiryDate_match == null) {
            alert("请输入正确的有效期格式,如:20190101");
            result = false;
            return;
        } 
    }
    param.ExpiryDate = param.ExpiryDate.substr(0, 4) + "-" + param.ExpiryDate.substr(4, 2) + "-" + param.ExpiryDate.substr(6, 2)
    if (!IsDate(param.ExpiryDate)) {
        alert("请输入正确的有效期格式,如:20190101");
        result = false;
        return;
    }
    /*if (param.Supplier == null || param.Supplier == "") {
        alert("请输入供应商！");
        return;
    }*/
    if (param.SupplierID == 0) {
        param.SupplierID = null
    }
    $.ajax({
        type: "POST",
        url: "/Commodity/DoAddBatch",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            alert(data.Message);

            if (data.Code == "1") {
                window.location.href = "/Commodity/EditCommodity?CD=" + $("#hidProductCode").val() + "&tabidx=3&b=-1&c=-1&d=-1";
            }
        }
    });
}
