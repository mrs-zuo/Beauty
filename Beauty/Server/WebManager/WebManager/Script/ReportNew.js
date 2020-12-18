/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    bindButton();
    TimesToCheck();
    
})

function bindButton() {
    var strJson = $("#txtDownloadFile").data("Report")
    if (strJson != "" && strJson != null && typeof (strJson) != "undefined") {
        for (var i = 0; i < strJson.length; i++) {
            switch (strJson[i].Type) {
                case 1:
                    if (strJson[i].Status == 1) {
                        $("#btnCustomer").unbind("click");
                        $("#btnCustomer").text("生成中");
                        $("#btnCustomerDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#btnCustomer").text("生成");
                        $("#btnCustomer").unbind("click");
                        $("#btnCustomer").bind("click", function () {
                            DownloadReport(1);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#btnCustomerDownload").show();
                            $("#btnCustomerDownload").unbind("click");
                            $("#btnCustomerDownload").bind("click", function () {
                                DownloadSuccess(1)
                            });

                        }
                    } else {
                        $("#btnCustomer").text("生成");
                        $("#btnCustomerDownload").hide();
                        $("#btnCustomer").unbind("click");
                        $("#btnCustomer").bind("click", function () {
                            DownloadReport(1);
                        });
                    }
                    break;
                case 2:
                    if (strJson[i].Status == 1) {
                        $("#btnCommodityStock").unbind("click");
                        $("#btnCommodityStock").text("生成中");
                        $("#btnCommodityStockDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#btnCommodityStock").text("生成");
                        $("#btnCommodityStock").unbind("click");
                        $("#btnCommodityStock").bind("click", function () {
                            DownloadReport(2);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#btnCommodityStockDownload").show();

                            $("#btnCommodityStockDownload").unbind("click");
                            $("#btnCommodityStockDownload").bind("click", function () {
                                DownloadSuccess(2)
                            });

                        }
                    } else {
                        $("#btnCommodityStock").text("生成");
                        $("#btnCommodityStockDownload").hide();
                        $("#btnCommodityStock").unbind("click");
                        $("#btnCommodityStock").bind("click", function () {
                            DownloadReport(2);
                        });
                    }
                    break;
                case 3:
                    if (strJson[i].Status == 1) {
                        $("#btnProductStockOperateLog").unbind("click");
                        $("#btnProductStockOperateLog").text("生成中");
                        $("#btnProductStockOperateLogDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#btnProductStockOperateLog").text("生成");
                        $("#btnProductStockOperateLog").unbind("click");
                        $("#btnProductStockOperateLog").bind("click", function () {
                            DownloadReport(3);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#btnProductStockOperateLogDownload").show();

                            $("#btnProductStockOperateLogDownload").unbind("click");
                            $("#btnProductStockOperateLogDownload").bind("click", function () {
                                DownloadSuccess(3)
                            });

                        }
                    } else {
                        $("#btnProductStockOperateLog").text("生成");
                        $("#btnProductStockOperateLogDownload").hide();
                        $("#btnProductStockOperateLog").unbind("click");
                        $("#btnProductStockOperateLog").bind("click", function () {
                            DownloadReport(3);
                        });
                    }
                    break;
                case 4:
                    if (strJson[i].Status == 1) {
                        $("#AccountPerformance").unbind("click");
                        $("#AccountPerformance").text("生成中");
                        $("#AccountPerformanceDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#AccountPerformance").text("生成");
                        $("#AccountPerformance").unbind("click");
                        $("#AccountPerformance").bind("click", function () {
                            DownloadReport(4);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#AccountPerformanceDownload").show();

                            $("#AccountPerformanceDownload").unbind("click");
                            $("#AccountPerformanceDownload").bind("click", function () {
                                DownloadSuccess(4)
                            });

                        }
                    } else {
                        $("#AccountPerformance").text("生成");
                        $("#AccountPerformanceDownload").hide();
                        $("#AccountPerformance").unbind("click");
                        $("#AccountPerformance").bind("click", function () {
                            DownloadReport(4);
                        });
                    }
                    break;
                case 5:
                    if (strJson[i].Status == 1) {
                        $("#BalanceDetailData").unbind("click");
                        $("#BalanceDetailData").text("生成中");
                        $("#BalanceDetailDataDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#BalanceDetailData").text("生成");
                        $("#BalanceDetailData").unbind("click");
                        $("#BalanceDetailData").bind("click", function () {
                            DownloadReport(5);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#BalanceDetailDataDownload").show();

                            $("#BalanceDetailDataDownload").unbind("click");
                            $("#BalanceDetailDataDownload").bind("click", function () {
                                DownloadSuccess(5)
                            });

                        }
                    } else {
                        $("#BalanceDetailData").text("生成");
                        $("#BalanceDetailDataDownload").hide();
                        $("#BalanceDetailData").unbind("click");
                        $("#BalanceDetailData").bind("click", function () {
                            DownloadReport(5);
                        });
                    }
                    break;

                case 7:
                    if (strJson[i].Status == 1) {
                        $("#BranchPerformance").unbind("click");
                        $("#BranchPerformance").text("生成中");
                        $("#BranchPerformanceDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#BranchPerformance").text("生成");
                        $("#BranchPerformance").unbind("click");
                        $("#BranchPerformance").bind("click", function () {
                            DownloadReport(7);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#BranchPerformanceDownload").show();
                            $("#BranchPerformanceDownload").unbind("click");
                            $("#BranchPerformanceDownload").bind("click", function () {
                                DownloadSuccess(7)
                            });
                        }
                    } else {
                        $("#BranchPerformance").text("生成");
                        $("#BranchPerformanceDownload").hide();
                        $("#BranchPerformance").unbind("click");
                        $("#BranchPerformance").bind("click", function () {
                            DownloadReport(7);
                        });
                    }
                    break;
                case 8:
                    if (strJson[i].Status == 1) {
                        $("#btnNoCompleteTreatment").unbind("click");
                        $("#btnNoCompleteTreatment").text("生成中");
                        $("#btnNoCompleteTreatmentDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#btnNoCompleteTreatment").text("生成");
                        $("#btnNoCompleteTreatment").unbind("click");
                        $("#btnNoCompleteTreatment").bind("click", function () {
                            DownloadReport(8);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#btnNoCompleteTreatmentDownload").show();

                            $("#btnNoCompleteTreatmentDownload").unbind("click");
                            $("#btnNoCompleteTreatmentDownload").bind("click", function () {
                                DownloadSuccess(8)
                            });

                        }
                    } else {
                        $("#btnNoCompleteTreatment").text("生成");
                        $("#btnNoCompleteTreatmentDownload").hide();
                        $("#btnNoCompleteTreatment").unbind("click");
                        $("#btnNoCompleteTreatment").bind("click", function () {
                            DownloadReport(8);
                        });
                    }
                    break;
                case 9:
                    if (strJson[i].Status == 1) {
                        $("#AccountStatement").unbind("click");
                        $("#AccountStatement").text("生成中");
                        $("#AccountStatementDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#AccountStatement").text("生成");
                        $("#AccountStatement").unbind("click");
                        $("#AccountStatement").bind("click", function () {
                            DownloadReport(9);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#AccountStatementDownload").show();

                            $("#AccountStatementDownload").unbind("click");
                            $("#AccountStatementDownload").bind("click", function () {
                                DownloadSuccess(9)
                            });

                        }
                    } else {
                        $("#AccountStatement").text("生成");
                        $("#AccountStatementDownload").hide();
                        $("#AccountStatement").unbind("click");
                        $("#AccountStatement").bind("click", function () {
                            DownloadReport(9);
                        });
                    }
                    break;
                case 10:
                    if (strJson[i].Status == 1) {
                        $("#BranchStatement").unbind("click");
                        $("#BranchStatement").text("生成中");
                        $("#BranchStatementDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#BranchStatement").text("生成");
                        $("#BranchStatement").unbind("click");
                        $("#BranchStatement").bind("click", function () {
                            DownloadReport(10);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#BranchStatementDownload").show();

                            $("#BranchStatementDownload").unbind("click");
                            $("#BranchStatementDownload").bind("click", function () {
                                DownloadSuccess(10)
                            });

                        }
                    } else {
                        $("#BranchStatement").text("生成");
                        $("#BranchStatementDownload").hide();
                        $("#BranchStatement").unbind("click");
                        $("#BranchStatement").bind("click", function () {
                            DownloadReport(10);
                        });
                    }
                    break;
                case 11:
                    if (strJson[i].Status == 1) {
                        $("#CardInfo").unbind("click");
                        $("#CardInfo").text("生成中");
                        $("#CardInfoDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#CardInfo").text("生成");
                        $("#CardInfo").unbind("click");
                        $("#CardInfo").bind("click", function () {
                            DownloadReport(11);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#CardInfoDownload").show();

                            $("#CardInfoDownload").unbind("click");
                            $("#CardInfoDownload").bind("click", function () {
                                DownloadSuccess(11)
                            });

                        }
                    } else {
                        $("#CardInfo").text("生成");
                        $("#CardInfoDownload").hide();
                        $("#CardInfo").unbind("click");
                        $("#CardInfo").bind("click", function () {
                            DownloadReport(11);
                        });
                    }
                    break;
                case 12:
                    if (strJson[i].Status == 1) {
                        $("#AccountAttendanceStatement").unbind("click");
                        $("#AccountAttendanceStatement").text("生成中");
                        $("#AccountAttendanceDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#AccountAttendanceStatement").text("生成");
                        $("#AccountAttendanceStatement").unbind("click");
                        $("#AccountAttendanceStatement").bind("click", function () {
                            DownloadReport(12);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#AccountAttendanceDownload").show();

                            $("#AccountAttendanceDownload").unbind("click");
                            $("#AccountAttendanceDownload").bind("click", function () {
                                DownloadSuccess(12)
                            });

                        }
                    } else {
                        $("#AccountAttendanceStatement").text("生成");
                        $("#AccountAttendanceDownload").hide();
                        $("#AccountAttendanceStatement").unbind("click");
                        $("#AccountAttendanceStatement").bind("click", function () {
                            DownloadReport(12);
                        });
                    }
                    break;
                case 13:
                    if (strJson[i].Status == 1) {
                        $("#CommDetailStatement").unbind("click");
                        $("#CommDetailStatement").text("生成中");
                        $("#CommDetailDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#CommDetailStatement").text("生成");
                        $("#CommDetailStatement").unbind("click");
                        $("#CommDetailStatement").bind("click", function () {
                            DownloadReport(13);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#CommDetailDownload").show();

                            $("#CommDetailDownload").unbind("click");
                            $("#CommDetailDownload").bind("click", function () {
                                DownloadSuccess(13)
                            });

                        }
                    } else {
                        $("#CommDetailStatement").text("生成");
                        $("#CommDetailDownload").hide();
                        $("#CommDetailStatement").unbind("click");
                        $("#CommDetailStatement").bind("click", function () {
                            DownloadReport(13);
                        });
                    }
                    break;
                case 14:
                    if (strJson[i].Status == 1) {
                        $("#btnCustomerRelationShip").unbind("click");
                        $("#btnCustomerRelationShip").text("生成中");
                        $("#btnCustomerRelationShipDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#btnCustomerRelationShip").text("生成");
                        $("#btnCustomerRelationShip").unbind("click");
                        $("#btnCustomerRelationShip").bind("click", function () {
                            DownloadReport(14);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#btnCustomerRelationShipDownload").show();
                            $("#btnCustomerRelationShipDownload").unbind("click");
                            $("#btnCustomerRelationShipDownload").bind("click", function () {
                                DownloadSuccess(14)
                            });

                        }
                    } else {
                        $("#btnCustomerRelationShip").text("生成");
                        $("#btnCustomerRelationShipDownload").hide();
                        $("#btnCustomerRelationShip").unbind("click");
                        $("#btnCustomerRelationShip").bind("click", function () {
                            DownloadReport(14);
                        });
                    }
                    break;
                case 15:
                    if (strJson[i].Status == 1) {
                        $("#btnServiceRate").unbind("click");
                        $("#btnServiceRate").text("生成中");
                        $("#btnServiceRateDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#btnServiceRate").text("生成");
                        $("#btnServiceRate").unbind("click");
                        $("#btnServiceRate").bind("click", function () {
                            DownloadReport(15);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#btnServiceRateDownload").show();
                            $("#btnServiceRateDownload").unbind("click");
                            $("#btnServiceRateDownload").bind("click", function () {
                                DownloadSuccess(15)
                            });

                        }
                    } else {
                        $("#btnServiceRate").text("生成");
                        $("#btnServiceRateDownload").hide();
                        $("#btnServiceRate").unbind("click");
                        $("#btnServiceRate").bind("click", function () {
                            DownloadReport(15);
                        });
                    }
                    break;
                case 16:
                    if (strJson[i].Status == 1) {
                        $("#btnInputOrder").unbind("click");
                        $("#btnInputOrder").text("生成中");
                        $("#btnInputOrderDownload").hide();
                    } else if (strJson[i].Status == 2) {
                        $("#btnInputOrder").text("生成");
                        $("#btnInputOrder").unbind("click");
                        $("#btnInputOrder").bind("click", function () {
                            DownloadReport(16);
                        });
                        if (strJson[i].DonwloadUrl != "" && typeof (strJson[i].DonwloadUrl) != "undefined") {

                            $("#btnInputOrderDownload").show();
                            $("#btnInputOrderDownload").unbind("click");
                            $("#btnInputOrderDownload").bind("click", function () {
                                DownloadSuccess(16)
                            });

                        }
                    } else {
                        $("#btnInputOrder").text("生成");
                        $("#btnInputOrderDownload").hide();
                        $("#btnInputOrder").unbind("click");
                        $("#btnInputOrder").bind("click", function () {
                            DownloadReport(16);
                        });
                    }
                    break;
            }
        }
    } else {

        $("#btnCustomer").text("生成");
        $("#btnCustomerDownload").hide();
        $("#btnCustomer").bind("click", function () {
            DownloadReport(1);
        });


        $("#btnCommodityStock").text("生成");
        $("#btnCommodityStockDownload").hide();
        $("#btnCommodityStock").bind("click", function () {
            DownloadReport(2);
        });


        $("#btnProductStockOperateLog").text("生成");
        $("#btnProductStockOperateLogDownload").hide();
        $("#btnProductStockOperateLog").bind("click", function () {
            DownloadReport(3);
        });


        $("#AccountPerformance").text("生成");
        $("#AccountPerformanceDownload").hide();
        $("#AccountPerformance").bind("click", function () {
            DownloadReport(4);
        });

        $("#BalanceDetailData").text("生成");
        $("#BalanceDetailDataDownload").hide();
        $("#BalanceDetailData").bind("click", function () {
            DownloadReport(5);
        });

        $("#BranchPerformance").text("生成");
        $("#BranchPerformanceDownload").hide();
        $("#BranchPerformance").bind("click", function () {
            DownloadReport(7);
        });

        $("#btnNoCompleteTreatment").text("生成");
        $("#btnNoCompleteTreatmentDownload").hide();
        $("#btnNoCompleteTreatment").bind("click", function () {
            DownloadReport(8);
        });



        $("#AccountStatement").text("生成");
        $("#AccountStatementDownload").hide();
        $("#AccountStatement").bind("click", function () {
            DownloadReport(9);
        });



        $("#BranchStatement").text("生成");
        $("#BranchStatementDownload").hide();
        $("#BranchStatement").bind("click", function () {
            DownloadReport(10);
        });



        $("#CardInfo").text("生成");
        $("#CardInfoDownload").hide();
        $("#CardInfo").bind("click", function () {
            DownloadReport(11);
        });



        $("#AccountAttendanceStatement").text("生成");
        $("#AccountAttendanceDownload").hide();
        $("#AccountAttendanceStatement").bind("click", function () {
            DownloadReport(12);
        });


        $("#CommDetailStatement").text("生成");
        $("#CommDetailDownload").hide();
        $("#CommDetailStatement").bind("click", function () {
            DownloadReport(13);
        });

        $("#btnCustomerRelationShip").text("生成");
        $("#btnCustomerRelationShipDownload").hide();
        $("#btnCustomerRelationShip").bind("click", function () {
            DownloadReport(14);
        });

        $("#btnServiceRate").text("生成");
        $("#btnServiceRateDownload").hide();
        $("#btnServiceRate").bind("click", function () {
            DownloadReport(15);
        });

        $("#btnInputOrder").text("生成");
        $("#btnInputOrderDownload").hide();
        $("#btnInputOrder").bind("click", function () {
            DownloadReport(16);
        });

    }

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
    $("#AccountStatement").unbind("click");
    $("#BranchStatement").unbind("click");
    $("#CardInfo").unbind("click");
    $("#AccountAttendanceStatement").unbind("click");
    $("#CommDetailStatement").unbind("click");
    $("#btnCustomerRelationShip").unbind("click");
    $("#btnServiceRate").unbind("click");
    $("#btnInputOrder").unbind("click");
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
        if (result > 366) {
            alert("选择周期不能大于366天");
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
        if (result > 366) {
            alert("选择周期不能大于366天");
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
        if (result > 366) {
            alert("选择周期不能大于366天");
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
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }
    else if (type == 7) {
        if ($("#BranchPerformanceStartTime").val() == "" || $("#BranchPerformanceEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#BranchPerformanceStartTime").val() + " 00:00:00";
        endDay = $("#BranchPerformanceEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }
    else if (type == 9) {
        if ($("#AccountStatementStartTime").val() == "" || $("#AccountStatementEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#AccountStatementStartTime").val() + " 00:00:00";
        endDay = $("#AccountStatementEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }
    else if (type == 10) {
        if ($("#BranchStatementStartTime").val() == "" || $("#BranchStatementEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#BranchStatementStartTime").val() + " 00:00:00";
        endDay = $("#BranchStatementEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }
    else if (type == 12) {
        if ($("#AccountAttendanceStartTime").val() == "" || $("#AccountAttendanceEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#AccountAttendanceStartTime").val() + " 00:00:00";
        endDay = $("#AccountAttendanceEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }
    else if (type == 13) {
        if ($("#CommDetailStartTime").val() == "" || $("#CommDetailEndTime").val() == "") {
            alert("请选择时间");
            return;
        }
        beginDay = $("#CommDetailStartTime").val() + " 00:00:00";
        endDay = $("#CommDetailEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }
    else if (type == 1) {
        if ($("#CustomerStartDay").val() == "" || $("#CustomerEndDay").val() == "") {
            beginDay = null;
            endDay = new Date();;
        }
        else { 
            beginDay = $("#CustomerStartDay").val() + " 00:00:00";
            endDay = $("#CustomerEndDay").val() + " 23:59:59";;
            var result = DaysBetween(beginDay,endDay);
            if (result > 0) {
                alert("结束时间不能小于开始时间");
                return;
            }
        }
    }
    else if (type == 15) {
        if ($("#ServiceRateStartTime").val() == "" || $("#ServiceRateEndTime").val() == "") {
            alert("请选择开始时间和结束时间");
            return;
        }
        if ($("#ServiceRateStartTime").val() > $("#ServiceRateEndTime").val() ) {
            alert("开始时间不能晚于结束时间");
            return;
        }
        beginDay = $("#ServiceRateStartTime").val() + " 00:00:00";
        endDay = $("#ServiceRateEndTime").val() + " 23:59:59";;
        var result = DaysBetween(endDay, beginDay);
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }
    else if (type == 16) {
        var today = new Date();
        if ($("#InputOrderStartTime").val() == "") {
            beginDay = today.toLocaleDateString() + " 00:00:00";
        }
        else {
            beginDay = $("#InputOrderStartTime").val() + " 00:00:00";
        }
        if ($("#InputOrderEndTime").val() == "") {
            endDay = today.toLocaleDateString() + " 23:59:59";
        }
        else {
            endDay = $("#InputOrderEndTime").val() + " 23:59:59";
        }

        if (beginDay > endDay) {
            alert("开始时间不能晚于结束时间");
            return;
        }
        var result = DaysBetween(endDay, beginDay);
        if (result > 366) {
            alert("选择周期不能大于366天");
            return;
        }
    }

    var ReportMode = {
        Type: type,
        BeginDay: beginDay,
        EndDay: endDay
    };

    var strJson = "";
    $.ajax({
        type: "POST",
        url: "/Report/OperationNew",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(ReportMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络异常!");
        },
        success: function (data) {
            if (data.Code == "1") {
                strJson = data.Data;
                $("#txtDownloadFile").data("Report", strJson);
                bindButton();
            }
            else {
                alert(data.Message);
            }
        },
        beforeSend: function () {
            $('body').stopTime();
            unBindButton();
        },
        complete: function () {
            TimesToCheck();
        }
    });
}


function TimesToCheck() {
    var downloadOK = "";
    $('body').everyTime('3s', function () {
        downloadOK = checkDownloadOK();
        bindButton();
        if (typeof (downloadOK) == "undefined" || downloadOK == "" || downloadOK == null) {
            $('body').stopTime();
        }
    }, 0, true);
}

function DownloadCheckDate(e, days) {
    var beginDay = $(e).parent().find(".BeginDate").val();
    var endDay = $(e).parent().find(".EndDate").val();
    var result = (endDay, beginDay);
    if (result > days) {
        alert("选择周期不能大于" + days + "天");
    }
}

function checkDownloadOK() {
    var strJson = "";
    $.ajax({
        type: "POST",
        url: "/Report/CheckDownloadOK",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: null,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络异常!");
        },
        success: function (data) {
            strJson = data.Data;
            if (data.Code == "1" && data.Data != "" && data.Data != null && typeof (data.Data) != "undefined") {
                $("#txtDownloadFile").data("Report", data.Data)
            }
            else {
                alert("文件生成失败！")
            }
        }
    });
    return strJson;
}


function DownloadSuccess(Type) {
    $('body').stopTime();
    var param = '{"Type":"' + Type + '"}';
    var strJson = "";
    $.ajax({
        type: "POST",
        url: "/Report/DownloadSuccess",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络异常!");
        },
        success: function (data) {
            if (data.Code == "1") {
                window.parent.location.href = data.Data;
                //switch (Type) {
                //    case 1:
                //        $("#btnCustomerDownload").unbind("click");
                //        $("#btnCustomerDownload").hide;
                //        break;
                //    case 2:
                //        $("#btnCommodityStockDownload").unbind("click");
                //        $("#btnCommodityStockDownload").hide;
                //        break;
                //    case 3:
                //        $("#btnProductStockOperateLogDownload").unbind("click");
                //        $("#btnProductStockOperateLogDownload").hide;
                //        break;
                //    case 4:
                //        $("#AccountPerformanceDownload").unbind("click");
                //        $("#AccountPerformanceDownload").hide;
                //        break;
                //    case 5:
                //        $("#BalanceDetailDataDownload").unbind("click");
                //        $("#BalanceDetailDataDownload").hide;
                //        break;
                //    case 6:
                //        $("#PeopleStatisticsDownload").unbind("click");
                //        $("#PeopleStatisticsDownload").hide;
                //        break;
                //    case 7:
                //        $("#BranchPerformanceDownload").unbind("click");
                //        $("#BranchPerformanceDownload").hide;
                //        break;
                //    case 8:
                //        $("#btnNoCompleteTreatmentDownload").unbind("click");
                //        $("#btnNoCompleteTreatmentDownload").hide;
                //        break;
                //}
            } else {
                alert("下载失败");
            }
        }
    });
    TimesToCheck();
}