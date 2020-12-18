/// <reference path="../assets/js/jquery-2.0.3.min.js" />
function AddStep()
{
    var model = {       
        StepContent: $.trim($("#txtStepContent").val()),
        StepName: $.trim($("#txtStepName").val())
    };

    if (model.strpContent == "") {
        alert("请输入销售步骤");
        return;
    }
    if (model.StepName == "") {
        alert("请输入销售步骤名称");
        return;
    }
    $.ajax({
        type: "POST",
        url: "/Step/AddStep",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data:  JSON.stringify(model),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Step/GetStepList"
            }
            else {
                alert(data.Message);
            }
        }
    });

}

function UpdateStep(StepCode) {
    var model = {
        ID: $.getUrlParam('ID'),
        StepContent: $.trim($("#txtStepContent").val()),
        StepName: $.trim($("#txtStepName").val()),
        StepCode: StepCode
    };

    if (model.strpContent == "") {
        alert("请输入销售步骤");
        return;
    }
    if (model.StepName == "") {
        alert("请输入销售步骤名称");
        return;
    }

    $.ajax({
        type: "POST",
        url: "/Step/UpdateStep",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(model),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Step/GetStepList"
            }
            else {
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