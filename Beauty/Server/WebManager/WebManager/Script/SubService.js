/// <reference path="../assets/js/jquery-2.0.3.min.js" />
function AddSubService() {
    var SubServiceMode = {
        SubServiceName: $.trim($("#txtSubServiceName").val()),
        SpendTime: $.trim($("#txtSpendTime").val()),
        NeedVisit: $("#rdNeedVisit").is(":checked"),
        VisitTime: $.trim($("#txtVisitTime").val())
    };

    if (Init(SubServiceMode)) {
        $.ajax({
            type: "POST",
            url: "/SubService/AddSubService",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(SubServiceMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/SubService/GetSubServiceList";
                }
                else
                    alert(data.Message);
            }
        });
    }
}

function UpdateSubService() {
    var SubServiceMode = {
        SubServiceName: $.trim($("#txtSubServiceName").val()),
        SpendTime: $.trim($("#txtSpendTime").val()),
        NeedVisit: $("#rdNeedVisit").is(":checked"),
        VisitTime: $.trim($("#txtVisitTime").val()),
        SubServiceCode: $.getUrlParam('SubServiceCode')
    };
    
    if (Init(SubServiceMode)) {
        $.ajax({
            type: "POST",
            url: "/SubService/UpdateSubService",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(SubServiceMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/SubService/GetSubServiceList";
                }
                else
                    alert(data.Message);

            }
        });
    }
}

function Init(SubServiceMode) {
    if (SubServiceMode.SubServiceName == "") {
        alert("子服务名称不能为空");
        return false;
    }
    if (SubServiceMode.SpendTime == "" || SubServiceMode.SpendTime==0)
    {
        SubServiceMode.SpendTime = 60;
    }
    if (isNaN(SubServiceMode.SpendTime)) {
        alert("请输入数字");
        return false;
    } else if (SubServiceMode.SpendTime % 5 != 0) {
        alert("服务时间必须为5的倍数");
        return false;
    } else if (SubServiceMode.SpendTime < 1) {
        alert("服务时间必须大于0");
        return false;

    } else if (SubServiceMode.SpendTime > 65535) {
        alert("服务时间必须小于65535");
        return false;
    }
    else if (parseInt(SubServiceMode.SpendTime) != SubServiceMode.SpendTime) {
        alert("服务时间必须为整数");
        return false;
    }

    if (SubServiceMode.NeedVisit)
    {
        if (SubServiceMode.VisitTime == "") {
            if (isNaN(SubServiceMode.VisitTime)) {
                alert("请输入数字");
                return false;
            }
            else if (SubServiceMode.VisitTime < 0) {
                alert("回访周期必须大于等于0");
                return false;

            } else if (SubServiceMode.VisitTime > 255) {
                alert("回访周期必须小于255");
                return false;
            }
            else if (parseInt(SubServiceMode.VisitTime) != SubServiceMode.VisitTime) {
                alert("回访周期必须为整数");
                return false;
            }
        }
    }
    return true;
}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function showVisitTime() {
    if ($("#rdNeedVisit").prop("checked") == true) {
        $("#lb_VisitTime").show();
    } else {
        $("#lb_VisitTime").hide();
    }
}