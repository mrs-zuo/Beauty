/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    unBindButton();
    bindButton();
})

function bindButton() {
    $("#btnCommodityStock").bind("click", function () {
        DownloadReport(2);
    });
    $("#btnCustomer").bind("click", function () {
        DownloadReport(1);
    });
    $("#btnProductStockOperateLog").bind("click", function () {
        DownloadReport(3);
    });
    $("#AccountPerformance").bind("click", function () {
        DownloadReport(4);
    });
    $("#BalanceDetailData").bind("click", function () {
        DownloadReport(5);
    });

    $("#PeopleStatistics").bind("click", function () {
        DownloadReport(6);
    });
    $("#BranchPerformance").bind("click", function () {
        DownloadReport(7);
    });
    $("#btnNoCompleteTreatment").bind("click", function () {
        DownloadReport(8);
    });
}

function unBindButton() {
    $("#btnCommodityStock").unbind("click");
    $("#btnCustomer").unbind("click");
    $("#btnProductStockOperateLog").unbind("click");
    $("#AccountPerformance").unbind("click");
    $("#BalanceDetailData").unbind("click");
    $("#PeopleStatistics").unbind("click");
    $("#BranchPerformance").unbind("click");
    $("#btnNoCompleteTreatment").unbind("click");
}

function DownloadReport(type) {
    var beginDay = "";
    var endDay = "";
    if (type == 3) {
        if ($("#stockLogStartDay").val() == "" || $("#stockLogEndDay").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#stockLogStartDay").val() + " 00:00:00";
        endDay = $("#stockLogEndDay").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 100) {
            alert("选择周期不能大于100天");
            return;
        }
    } else if (type == 4) {
        if ($("#AccountPerformanceStartTime").val() == "" || $("#AccountPerformanceEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#AccountPerformanceStartTime").val() + " 00:00:00";
        endDay = $("#AccountPerformanceEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 100) {
            alert("选择周期不能大于100天");
            return;
        }
    } else if (type == 5) {
        if ($("#BalanceDetailDataStartTime").val() == "" || $("#BalanceDetailDataEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#BalanceDetailDataStartTime").val() + " 00:00:00";
        endDay = $("#BalanceDetailDataEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 100) {
            alert("选择周期不能大于100天");
            return;
        }
    }
    else if (type == 6) {
        if ($("#PeopleStatisticsStartTime").val() == "" || $("#PeopleStatisticsEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#PeopleStatisticsStartTime").val() + " 00:00:00";
        endDay = $("#PeopleStatisticsEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 100) {
            alert("选择周期不能大于100天");
            return;
        }
    }
    else if (type == 7) {
        if ($("#BranchPerformanceStartTime").val() == "" ||  $("#BranchPerformanceEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#BranchPerformanceStartTime").val() + " 00:00:00";
        endDay = $("#BranchPerformanceEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 100) {
            alert("选择周期不能大于100天");
            return;
        }
    }
    else if (type == 1) {
        if ($("#CustomerStartDay").val() == "" || $("#CustomerEndDay").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#CustomerStartDay").val() + " 00:00:00";
        endDay = $("#CustomerEndDay").val() + " 23:59:59";;

        var result = DaysBetween(endDay, beginDay);
        if (result > 100) {
            alert("选择周期不能大于100天");
            return;
        }
    }

    var ReportMode = {
        Type: type,
        BeginDay: beginDay,
        EndDay: endDay
    };

    $.ajax({
        type: "POST",
        url: "/Report/Operation",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(ReportMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络异常!");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                window.parent.location.href = data.Data;
            }
            else
                alert(data.Message);
        },
        beforeSend: function () {
            unBindButton();
        },
        complete: function () {
            bindButton();
        }
    });
}

function DownloadCheckDate(e, days) {
    var beginDay = $(e).parent().find(".BeginDate").val();
    var endDay = $(e).parent().find(".EndDate").val();
    var result = (endDay, beginDay);
    if (result > days) {
        alert("选择周期不能大于" + days + "天");
    }
}