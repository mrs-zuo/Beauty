/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    var currentInputSearch = $.getUrlParam('InputSearch') != null ? decodeURI($.getUrlParam('InputSearch')) : null;  
    if (currentInputSearch != null) {
        $('#txtInputSearch').val(currentInputSearch);
    }
});

function SearchSupplier() {
    var inputSearch = encodeURI(encodeURI($.trim($("#txtInputSearch").val())));

    window.location.href = "/Supplier/GetSupplierList?InputSearch=" + inputSearch;
}

function delSupplier(ID) {
    var SupplierMode = {
        SupplierID: ID
    };
    if (confirm("确认删除？")) {
        $.ajax({
            type: "POST",
            url: "/Supplier/deleteSupplier",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            data: JSON.stringify(SupplierMode),
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    location.href = "/Supplier/GetSupplierList";

                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function AddSupplier() {
    var SupplierMode = {
        SupplierName: $.trim($("#txtSupplierName").val()),
        SupplierAddr: $.trim($("#txtSupplierAddr").val()),
        SupplierTel: $.trim($("#txtSupplierTel").val()),
        SupplierContactName: $.trim($("#txtSupplierContactName").val()),
        SupplierContactTel: $.trim($("#txtSupplierContactTel").val())
    };

    if (Init(SupplierMode)) {
        $.ajax({
            type: "POST",
            url: "/Supplier/AddSupplier",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(SupplierMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    window.location.href = "/Supplier/GetSupplierList";
                }
                else
                    alert(data.Message);
            }
        });
    }
}

function UpdateSupplier() {
    var SupplierMode = {
        SupplierName: $.trim($("#txtSupplierName").val()),
        SupplierAddr: $.trim($("#txtSupplierAddr").val()),
        SupplierTel: $.trim($("#txtSupplierTel").val()),
        SupplierContactName: $.trim($("#txtSupplierContactName").val()),
        SupplierContactTel: $.trim($("#txtSupplierContactTel").val()),
        SupplierID: $.getUrlParam('SupplierID')
    };

    if (Init(SupplierMode)) {
        $.ajax({
            type: "POST",
            url: "/Supplier/UpdateSupplier",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(SupplierMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    window.location.href = "/Supplier/GetSupplierList";
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function Init(SupplierMode) {
    var result = true;
    if (SupplierMode.SupplierName == "") {
        alert("供应商名称不能为空");
        result = false;
    } else {
        $.ajax({
            type: "POST",
            url: "/Supplier/IsExsitSupplierName",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(SupplierMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    if (data.Data) {
                        {
                            alert(data.Message);
                            result = false;
                        }
                    }
                }
            }
        });
    }
    if (!result) {
        return false;
    } else {
        return true;
    }
}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);