/// <reference path="../assets/js/jquery-2.0.3.min.js" />

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);


$(document).ready(function () {
    $('.addButton').on('click', function () {
        var index = $(this).data('index');
        if (!index) {
            index = 1;
            $(this).data('index', 1);
        }
        index++;
        $(this).data('index', index);

        var template = $(this).attr('data-template'),
            $templateEle = $('#' + template + 'Template'),
            $row = $templateEle.clone().removeAttr('id').insertBefore($templateEle).removeClass('hide'),
            $el = $row.find('input').eq(0).attr('name', template + '[]');
        $('#defaultForm').bootstrapValidator('addField', $el);

        $row.on('click', '.removeButton', function (e) {
            $('#defaultForm').bootstrapValidator('removeField', $el);
            $row.remove();
        });
    });


    $(".removeButton").on("click", function () {
        $(this).parent().parent().remove();
    })

    $('input[type="radio"]').on('click', function () {
        var name = $(this).attr("name");
        switch (name) {
            case "NeedVisit":
                $("#ck_NeedVisit").is(":checked") ? $("#lb_VisitTime").show() : $("#lb_VisitTime").hide();
                break;

            case "HaveExpiration":
                $("#ck_HaveExpiration").is(":checked") ? $("#lb_HaveExpiration").show() : $("#lb_HaveExpiration").hide();
                break;

            case "AutoConfirm":
                $("#IsAutoComfirm1").is(":checked") ? $("#lb_AutoConfirmDays").show() : $("#lb_AutoConfirmDays").hide();
                break;

        }
    });
});

function selectCommodity() {
    var branchID = $("#selBra").val();
    var categoryID = $("#seCal").val();

    window.location.href = "/Service/GetServiceList?b=" + branchID + "&c=" + categoryID;
}

function selectServiceSort() {
    var categoryID = $("#seCal").val();
    window.location.href = "/Service/EditServiceSort?c=" + categoryID;
}

function marketingSelect() {
    var policy = $("#selPoli").val();
    switch (policy) {
        case "0":
            $("#form_Poli").hide();
            $("#input_PromotionPrice").hide();
            $("#p_yuan").hide();
            $("#selDis").hide();
            break;
        case "1":
            $("#form_Poli").show();
            $("#selDis").show();
            $("#input_PromotionPrice").hide();
            $("#p_yuan").hide();
            break;
        case "2":
            $("#form_Poli").show();
            $("#input_PromotionPrice").show();
            $("#p_yuan").show();
            $("#selDis").hide();
            break;
    }
}

function downloadService() {
    var param = {
        BranchID: $("#selBra").val(),
        CategoryID: $("#seCal").val()
    }
    $.ajax({
        type: "POST",
        url: "/Service/downloadService",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                window.parent.location.href = data.Data;
            }
            else
                alert(data.Message);
        },
        beforeSend: function () {
            $("#divWait").removeClass("hidden");
        },
        complete: function () {
            $("#divWait").addClass("hidden");
        }
    });
}

function mulityDelete() {
    var branchID = $("#selBra").val();
    var categoryID = $("#seCal").val();


    if (confirm("确认删除？")) {
        var list = new Array();
        $('input[type="checkbox"][name="chk_Com"]:checked').each(function () {
            list.push($(this).attr("code"));
        });

        var model = {
            CodeList: list
        }

        if (model.CodeList.length == 0) {
            alert("请先选择！");
            return;
        }

        $.ajax({
            type: "POST",
            url: "/Service/deteleMultiService",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            data: JSON.stringify(model),
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Service/GetServiceList?b=" + branchID + "&c=" + categoryID;
                }
                else
                    alert(data.Message);
            }
        });
    }
}

function delService(e) {
    var branchID = $("#selBra").val();
    var categoryID = $("#seCal").val();

    if (confirm("确认删除？")) {
        var list = new Array();

        var id = $(e).attr("id");
        if (id > 0) {
            list.push(id);
        }

        var model = {
            CodeList: list
        }

        if (model.CodeList.length == 0) {
            alert("请先选择！");
            return;
        }

        $.ajax({
            type: "POST",
            url: "/Service/deteleMultiService",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            data: JSON.stringify(model),
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Service/GetServiceList?b=" + branchID + "&c=" + categoryID;
                }
                else
                    alert(data.Message);
            }
        });
    }
}

function printProduct() {
    var list = new Array();
    $('input[type="checkbox"][name="chk_Com"]:checked').each(function () {
        list.push($(this).attr("code"));
    });

    var model = {
        CodeList: list
    }

    if (model.CodeList.length == 0) {
        alert("请先选择！");
        return;
    }

    $.ajax({
        type: "POST",
        url: "/Service/getServicePrintList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(model),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                bindPrint(data.Data)
            }
            else
                alert(data.Message);
        }
    });
}

function bindPrint(data) {
    var divRoot = $("#divWholeQRcode");
    var strHtml = "";
    if (data != null && data.length > 0) {
        for (var i = 0; i < data.length; i++) {
            strHtml += '<div class="col-xs-4 col-md-2 text-align-center">';
            strHtml += '<img src="' + data[i].QRcodeUrl + '"/>&nbsp;';
            strHtml += '<p class="over-text col-xs-12">' + data[i].ServiceName + '&nbsp;</p>';
            strHtml += '<p>' + data[i].CourseFrequency + '&nbsp;</p>';
            strHtml += '<p>' + data[i].UnitPrice + '&nbsp;</p></div>';
        }
    }
    $("#divWholeQRcode").html(strHtml);
    $("#divPrint").show();
    $("#divContent").hide();


}

function closeDiv() {
    $("#divPrint").hide();
    $("#divContent").show();
}

function gotoPrint() {
    var oper = 1;
    bdhtml = window.document.body.innerHTML; //获取当前页的html代码  
    sprnstr = "<!--startprint" + oper + "-->"; //设置打印开始区域  
    eprnstr = "<!--endprint" + oper + "-->"; //设置打印结束区域  
    prnhtml = bdhtml.substring(bdhtml.indexOf(sprnstr) + 18); //从开始代码向后取html  

    prnhtml = prnhtml.substring(0, prnhtml.indexOf(eprnstr)); //从结束代码向前取html  


    window.document.body.innerHTML = prnhtml;
    window.print();
    window.document.body.innerHTML = bdhtml;
    minusPrinterArea();
    closePrintDiv();
}

function AllSelect(e) {
    $('#tbBranch input[type="checkbox"]').each(function () {
        $(this).prop("checked", $(e).is(":checked"));
    });
}

function AllServiceSelect(e) {
    $('#tbServiceList input[type="checkbox"]').each(function () {
        $(this).prop("checked", $(e).is(":checked"));
    });
}

function updateService(e) {
    if (e == "1")
        updateDetail();
    else
        addService();
}

function updateDetail() {
    var param = {
        ServiceID: $("#hidID").val(),
        ServiceName: $("#input_Name").val().trim()
    }

    var count = 0;
    $.ajax({
        type: "POST",
        url: "/Service/getCountbyServiceName",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                count = data.Data;
            }
            else {
                alert(data.Message);
            }
        }
    });
    if (count > 0) {
        if (confirm("服务名称已存在，是否继续？") == false) {
            return;
        }
    }

    var SubserviceCodes = "|";
    if ($("#ck_HaveServiceCode").is(":checked")) {
        $('select[name="selSubservice"]').each(function () {
            if ($(this).parent().parent().attr("id") != "textboxTemplate") {
                SubserviceCodes += $(this).val();
                SubserviceCodes += "|";
            }
        });
    }

    var isConfirmed = 0;
    if ($("#IsConfirmed1").is(":checked")) {
        isConfirmed = 1;
    } else if ($("#IsConfirmed2").is(":checked")) {
        isConfirmed = 2;
    }


    var param = {
        UnitPrice: $("#input_UnitPrice").val(),
        CategoryID: $("#selCat").val(),
        ServiceID: $("#hidID").val(),
        ServiceCode: $("#hidCode").val(),
        MarketingPolicy: $("#selPoli").val(),
        DiscountID: $("#selPoli").val() == "1" ? $("#selDis").val() : "-1",
        PromotionPrice: $("#selPoli").val() == "2" ? $("#input_PromotionPrice").val() : "",
        ServiceName: $("#input_Name").val().trim(),
        SerialNumber: $("#input_SerialNumber").val().trim(),
        Describe: $("#input_Describe").val().trim(),
        VisibleForCustomer: $("#ck_VisibleForCustomer").is(":checked"),
        SpendTime:  $("#input_SpendTime").val().trim(),
        HaveExpiration: $("#ck_HaveExpiration").is(":checked"),
        ExpirationDate: $("#ck_HaveExpiration").is(":checked") ? $("#input_HaveExpiration").val().trim() : null,
        CourseFrequency: $("#input_CourseFrequency").val().trim(),
        NeedVisit: $("#ck_NeedVisit").is(":checked"),
        VisitTime: $("#ck_NeedVisit").is(":checked") ? $("#input_VisitTime").val().trim() : "-1",
        HaveSubService: $("#ck_HaveServiceCode").is(":checked"),
        SubServiceCodes: $("#ck_HaveServiceCode").is(":checked") ? SubserviceCodes.trim() : "",
        IsConfirmed: isConfirmed,
        // 2020.06.18 Lou
        AutoConfirm: $("#IsAutoComfirm1").is(":checked")? 1 : 0,
        AutoConfirmDays: $("#IsAutoComfirm1").is(":checked") ? $("#input_AutoConfirmDays").val().trim() : "7",
        // 2020.06.18 Lou END
        Thumbnail: getThumbImage(),
        BigImageUrl: getBigImage(),
        deleteImageUrl: getDeleteImage(),
        Recommended: $("#ck_Recommended").is(":checked") ? true : false
    }

    if (param.ServiceName == "") {
        alert("请输入服务名称！");
        return;
    }

    if (param.NeedVisit && param.VisitTime == "") {
        alert("请输入回访时间！");
        return;
    }

    //判断单价是否正确
    if (!priceChk(param.UnitPrice)) {
        return;
    }

    if (param.HaveExpiration && param.ExpirationDate == "") {
        alert("请输入服务有效期！");
        return;
    }

    if (param.HaveSubService && param.SubServiceCodes == "|") {
        alert("服务子项错误！" + param.SubServiceCodes);
    }

    if ($("#selPoli").val() == "2" && param.PromotionPrice == "") {
        alert("请输入促销价！");
    }

    if (!param.HaveSubService) {
        if (param.SpendTime == "" || param.SpendTime == "0") {
            param.SpendTime = 60;
        }
        if (parseInt(param.SpendTime) <= 0) {
            alert("请输入大于0的数");
            return;
        }
        if (parseInt(param.SpendTime) % 5 != 0) {
            alert("服务时间应为5的倍数！");
            return;
        }
    }

    // 2020.06.23 Lou
    if (param.AutoConfirm == 1) {
        if (param.AutoConfirmDays != parseInt(param.AutoConfirmDays) || parseInt(param.AutoConfirmDays) <= 0) {
            alert("自动确认等待日数，请输入大于0的整数");
            return;
        }
    }
    // 2020.06.23 Lou END

    $.ajax({
        type: "POST",
        url: "/Service/updateServiceDetail",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                //location.href = "/Service/GetServiceList?b=-1&c=-1";
                $("#a_profile").click();
            }
            else
                alert(data.Message);
        }
    });
}

function addService() {
    var param = {
        ServiceID: $("#hidID").val(),
        ServiceName: $("#input_Name").val().trim()
    }
    var count = 0;
    $.ajax({
        type: "POST",
        url: "/Service/getCountbyServiceName",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                count = data.Data;
            }
            else {
                alert(data.Message);
            }
        }
    });
    if (count > 0) {
        if (confirm("服务名称已存在，是否继续？") == false) {
            return;
        }
    }

    var SubserviceCodes = "|";
    if ($("#ck_HaveServiceCode").is(":checked")) {
        $('select[name="selSubservice"]').each(function () {
            if ($(this).parent().parent().attr("id") != "textboxTemplate") {
                SubserviceCodes += $(this).val();
                SubserviceCodes += "|";
            }
        });
    }

    var isConfirmed = 0;
    if ($("#IsConfirmed1").is(":checked")) {
        isConfirmed = 1;
    } else if ($("#IsConfirmed2").is(":checked")) {
        isConfirmed = 2;
    }

    var param = {
        UnitPrice: $("#input_UnitPrice").val(),
        CategoryID: $("#selCat").val(),
        MarketingPolicy: $("#selPoli").val(),
        DiscountID: $("#selPoli").val() == "1" ? $("#selDis").val() : "-1",
        PromotionPrice: $("#selPoli").val() == "2" ? $("#input_PromotionPrice").val() : "",
        ServiceName: $("#input_Name").val().trim(),
        SerialNumber: $("#input_SerialNumber").val().trim(),
        Describe: $("#input_Describe").val().trim(),
        VisibleForCustomer: $("#ck_VisibleForCustomer").is(":checked"),
        SpendTime: $("#input_SpendTime").val().trim() ,
        HaveExpiration: $("#ck_HaveExpiration").is(":checked"),
        ExpirationDate: $("#ck_HaveExpiration").is(":checked") ? $("#input_HaveExpiration").val().trim() : null,
        CourseFrequency: $("#input_CourseFrequency").val().trim(),
        NeedVisit: $("#ck_NeedVisit").is(":checked"),
        VisitTime: $("#ck_NeedVisit").is(":checked") ? $("#input_VisitTime").val().trim() : "-1",
        HaveSubService: $("#ck_HaveServiceCode").is(":checked"),
        SubServiceCodes: $("#ck_HaveServiceCode").is(":checked") ? SubserviceCodes.trim() : "",
        IsConfirmed: isConfirmed,
        // 2020.06.18 Lou
        AutoConfirm: $("#IsAutoComfirm1").is(":checked") ? 1 : 0,
        AutoConfirmDays: $("#IsAutoComfirm1").is(":checked") ? $("#input_AutoConfirmDays").val().trim() : "7",
        // 2020.06.18 Lou END
        Thumbnail: getThumbImage(),
        BigImageUrl: getBigImage(),
        Recommended: $("#ck_Recommended").is(":checked") ? true : false
    }

    if (param.ServiceName == "") {
        alert("请输入服务名称！");
        return;
    }

    if ((!param.HaveSubService) && param.NeedVisit && param.VisitTime == "") {
        alert("请输入回访时间！");
        return;
    }

    if (!priceChk(param.UnitPrice)) {
        return;
    }

    if (param.HaveExpiration && param.ExpirationDate == "") {
        alert("请输入服务有效期！");
        return;
    }

    if (param.HaveSubService && param.SubServiceCodes == "|") {
        alert("服务子项错误！" + param.SubServiceCodes);
        return;
    }

    if ($("#selPoli").val() == "2" && param.PromotionPrice == "") {
        alert("请输入促销价！");
        return;
    }

    if (!param.HaveSubService) {
        if (param.SpendTime == "" || param.SpendTime == "0") {
            param.SpendTime = 60;
        }
        if (parseInt(param.SpendTime) <= 0) {
            alert("请输入大于0的数");
            return;
        }


        if (parseInt(param.SpendTime) % 5 != 0) {
            alert("请输入5的倍数！");
            return;
        }

        // 2020.06.23 Lou
        if (param.AutoConfirm == 1) {
            if (param.AutoConfirmDays != parseInt(param.AutoConfirmDays) || parseInt(param.AutoConfirmDays) <= 0) {
                alert("自动确认等待日数，请输入大于0的整数");
                return;
            }
        }
        // 2020.06.23 Lou END
    }

    $.ajax({
        type: "POST",
        url: "/Service/addService",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                $("#hidCode").val(data.Data.ProductCode);
                $("#hidID").val(data.Data.ProductID);
                $("#li_profile").show();
                $("#profile").show();
                $("#a_profile").click();
                $("#li_home").hide();
            }
            else
                alert(data.Message);
        }
    });
}

function UpdateServiceSort() {
    var strParma = "";
    $("#foo tr").each(function (i) {
        strParma += $(this).find("#hidserviceCode").val() + ",";
    });
    strParma += "|" + $("#hidoldSortID").val();

    var SortMode = {
        Prama: strParma
    };

    var calid = $("#seCal").val();

    $.ajax({
        type: "POST",
        url: "/Service/UpdateServiceSort",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(SortMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Service/GetServiceList?b=-1&c=" + calid;
            }
            else
                alert(data.Message);
        }
    });
}

//金额判断
function priceChk(value) {

    if (value.trim() == "") {
        alert("价格不能为空");
        return false;
    }

    if (isNaN(value)) {
        alert("请输入数字");
        return false;
    }
    if (value > 922337203685477) {
        alert("价格不能超过922337203685477");
        return false;
    } else if (value < 0) {
        alert("价格不能低于0");
        return false;
    }

    if (value.split('.').length > 1) {
        if (value.split('.')[1].length > 4) {
            alert("小数位不能超过4位数");
            return false;
        }
    }
    return true;
}

function changeSubservice(haveSubservice) {
    if (haveSubservice) {
        $('div[name="subservice"]').show();
    }
    else {
        $('div[name="subservice"]').hide();
    }
}

function updateBranchRelationship() {

    var code = $("#hidCode").val();
    if (code == "0") {
        alert("请先添加服务！");
    }

    var branchList = new Array();
    $('#tbBranch input[type="checkbox"]:checked').each(function (a) {
        var branch = {
            BranchID: $(this).attr("id")
        }
        branchList.push(branch);
    });

    var param = {
        ServiceCode: code,
        BranchList: branchList
    }

    $.ajax({
        type: "POST",
        url: "/Service/OperationServiceBranch",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                var categoryId = $.getUrlParam('c');
                var branchId = $.getUrlParam('b');
                var cd = $.getUrlParam('CD');
                location.href = "/Service/GetServiceList?b=" + branchId + "&c=" + categoryId + "#" + cd;
            }
            else
                alert(data.Message);
        }
    });
}


function editService(code) {
    var categoryId = $("#seCal").val();
    var branchId = $("#selBra").val();
    location.href = "/Service/EditService?CD=" + code + "&b=" + branchId + "&c=" + categoryId;
}

function goback() {
    var categoryId = $.getUrlParam('c');
    var branchId = $.getUrlParam('b');
    var cd = $.getUrlParam('CD');
    location.href = "/Service/GetServiceList?b=" + branchId + "&c=" + categoryId + "#" + cd;

}

function getCountbyServiceName() {
    var serviceName = $("#input_Name").val().trim();
    if (serviceName == "") {
        return;
    }

    var param = {
        ServiceID: $("#hidID").val(),
        ServiceName: serviceName
    }
    var count = 0;
    $.ajax({
        type: "POST",
        url: "/Service/getCountbyServiceName",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                count = data.Data;
            }
            else {
                alert(data.Message);
            }
        }
    });
    if(count > 0) {
        alert("服务名称已存在！");
    }
    return;
}