/// <refer/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    var currentAccountID = $.getUrlParam('UserID');
    var currentType = $.getUrlParam('Type');
    if (currentAccountID != null) {
        $('#ddlAccount').val(currentAccountID);
    }
    if (currentType != null) {
        $('#ddlType').val(currentType);
    }
});

function changeTop() {
    var Userid = $("#ddlAccount").val();
    var Type = $("#ddlType").val();
    location.href = "/Account/AccountHierarchy?UserID=" + Userid + "&Type=" + Type;
}




function SubmitHierarchy(hId, subId, supId) {
    var HierarchyMode = {
        ID: hId,
        SuperiorID: $("#ddlSelect").val(),
        SubordinateID: subId
    };

    if (HierarchyMode.SuperiorID == supId) {
        alert("更新成功");
        return false;
    }

    $.ajax({
        type: "POST",
        url: "/Account/OperationHierarchy",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(HierarchyMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Account/AccountHierarchy";
            }
            else
                alert(data.Message);
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