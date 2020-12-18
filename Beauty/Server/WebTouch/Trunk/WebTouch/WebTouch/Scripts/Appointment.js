/// <reference path="../js/jquery-1.11.1.min.js" />


$(function () {
    var currYear = (new Date()).getFullYear();
    var opt = {};
    opt.date = { preset: 'date' };
    opt.datetime = { preset: 'datetime' };
    opt.time = { preset: 'time' };
    opt.default = {
        theme: 'android-ics light', //皮肤样式
        display: 'modal', //显示方式 
        mode: 'scroller', //日期选择模式
        dateFormat: 'yyyy-mm-dd',
        lang: 'zh',
        showNow: false,
        nowText: "今天",
        startYear: currYear, //开始年份
        endYear: currYear + 10 //结束年份
    };
    var optDateTime = $.extend(opt['datetime'], opt['default']);

    if ($("#hid1").val() == "1") {
        $("#aStartTime").mobiscroll(optDateTime).datetime(optDateTime);
    }
    var accountID = $("#hiddenData").val();
    $("#hiddenData").data("selectAcc", accountID);
});

function selectAcc(AccountID, AccountName) {
    $("#aAccountName").text(AccountName);
    $("#hiddenData").data("selectAcc", "");
    $("#hiddenData").data("selectAcc", AccountID);
    $("#guideImg1").hide();

}


function CreateAppointment(branchId, ProductCode, OrderObjectID, OrderID, TaskSourceType) {

    var CAModel = {
        BranchID: branchId,
        TaskScdlStartTime: $("#aStartTime").val(),
        Remark: $("#txtTaskDescription").val(),
        ReservedServiceCode: ProductCode,
        ExecutorID: $("#hiddenData").data("selectAcc"),
        ReservedOrderServiceID: OrderObjectID,
        ReservedOrderType: OrderObjectID > 0 ? 1 : 2,
        ReservedOrderID: OrderID,
        TaskSourceType: TaskSourceType
    }

    $.ajax({
        type: "POST",
        url: "/Appointment/AddSchedule",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(CAModel),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Appointment/MyAppointment?s=2";
            }
            else {
                alert(data.Message);
            }
        }
    });
}



function EditAppointment(TaskID) {
    var CAModel = {
        ID: TaskID,
        TaskScdlStartTime: $("#aStartTime").val(),
        Remark: $("#txtTaskDescription").val(),
        ExecutorID: $("#hiddenData").data("selectAcc")
    }

    $.ajax({
        type: "POST",
        url: "/Appointment/EditTask",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(CAModel),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Appointment/MyAppointment?s=2";
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function CancelSchedule(TaskID) {
    var UtilityOperationModel = {
        LongID: TaskID
    }

    $.ajax({
        type: "POST",
        url: "/Appointment/CancelSchedule",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperationModel),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Appointment/MyAppointment?s=2";
            }
            else {
                alert(data.Message);
            }
        }
    });
}


