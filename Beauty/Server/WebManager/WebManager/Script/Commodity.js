/// <reference path="Commodity.js" />
/// <reference path="../assets/js/jquery-2.0.3.min.js" />
//验证有效期格式
var dateMatch = /^(\d{4})(\d{2})(\d{2})$/;
//验证有效期合法性
function IsDate(str) {
    arr = str.split("-");
    if (arr.length == 3) {
        intYear = parseInt(arr[0], 10);
        intMonth = parseInt(arr[1], 10);
        intDay = parseInt(arr[2], 10);
        if (isNaN(intYear) || isNaN(intMonth) || isNaN(intDay)) {
            return false;
        }
        if (intYear > 2100 || intYear < 1900 || intMonth > 12 || intMonth < 1 || intDay > 31 || intDay < 1) {
            return false;
        }
        if ((intMonth == 4 || intMonth == 6 || intMonth == 9 || intMonth == 11) && intDay > 30) {
            return false;
        }
        if ((intMonth == 1 || intMonth == 3 || intMonth == 5 || intMonth == 7 || intMonth == 8 || intMonth == 10 || intMonth == 12) && intDay > 31) {
            return false;
        }
        if (intYear % 100 == 0 && intYear % 400 || intYear % 100 && intYear % 4 == 0) {
            if (intMonth == 2 && intDay > 29) return false;
        } else {
            if (intMonth == 2 && intDay > 28) return false;
        }
        return true;
    }
    return false;
}

function GetNumberOfDays(date1, date2) {//获得天数
    //date1：开始日期，date2结束日期
    var a1 = Date.parse(date1);
    date2 = date2.substr(0, 4) + "-" + date2.substr(4, 2) + "-" + date2.substr(6, 2)
    var a2 = Date.parse(new Date(date2));
    var day = parseInt((a2 - a1) / (1000 * 60 * 60 * 24));//核心：时间戳相减，然后除以天数
    return day
};

(function ($) {

    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function hideAutoConfirmDays() {
    $("#lb_AutoConfirmDays").hide();
}

function showAutoConfirmDays() {
    $("#lb_AutoConfirmDays").show();
}

function marketingSelect() {
    var policy = $("#selPoli").val();
    switch (policy) {
        case "0":
            $("#form_Poli").hide();
            $("#input_PromotionPrice").css("display", "none");
            $("#p_yuan").css("display", "none");
            $("#selDis").css("display", "none");
            break;
        case "1":
            $("#form_Poli").show();
            $("#selDis").css("display", "block");
            $("#input_PromotionPrice").css("display", "none");
            $("#p_yuan").css("display", "none");
            break;
        case "2":
            $("#form_Poli").show();
            $("#input_PromotionPrice").css("display", "block");
            $("#p_yuan").css("display", "block");
            $("#selDis").css("display", "none");
            break;
    }
}

function selectCommodity() {
    var branchID = $("#selBra").val();
    var categoryID = $("#seCal").val();
    var supplierID = $("#selSup").val();

    window.location.href = "/Commodity/GetCommodityList?b=" + branchID + "&c=" + categoryID + "&d=" + supplierID;
}
function selectCommoditySort() {
    var categoryID = $("#seCal").val();
    window.location.href = "/Commodity/EditCommoditySort?c=" + categoryID;
}

function delCommodity(e) {
    if (confirm("确认删除？")) {
        $.ajax({
            type: "POST",
            url: "/Commodity/deleteCommodity",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            data: '{"CommodityCode":"' + $(e).attr("ID") + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    location.href = "/Commodity/GetCommodityList?b=" + $("#selBra").val() + "&c=" + $("#seCal").val() + "&d=" + $("#selSup").val();

                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function updateCommodity(e) {
    if (e)
        updateDetail();
    else
        addCommodity();
}



function updateDetail() {
    var param = {
        CommodityID: $("#hidID").val(),
        CommodityName: $("#input_Name").val().trim()
    }
    var count = 0;
    $.ajax({
        type: "POST",
        url: "/Commodity/getCountbyCommodityName",
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
        if(confirm("商品名称已存在，是否继续？") == false){
            return;
        }
    }

    var isConfirmed = 0;
    if ($("#IsConfirmed1").is(":checked")) {
        isConfirmed = 1;
    } else if ($("#IsConfirmed2").is(":checked")) {
        isConfirmed = 2;
    }

    var param = {
        CategoryID: $("#selCat").val(),
        CommodityID: $("#hidID").val(),
        CommodityCode: $("#hidCode").val(),
        MarketingPolicy: $("#selPoli").val(),
        CommodityName: $("#input_Name").val(),
        Describe: $("#input_Describe").val(),
        Specification: $("#input_Specification").val(),
        VisibleForCustomer: $("#radio_VisibleForCustomer").is(":checked"),
        New: $("#ck_New").is(":checked") ? true : false,
        Recommended: $("#ck_Recommended").is(":checked") ? true : false,
        DiscountID: $("#selPoli").val() == "1" ? $("#selDis").val() : "",
        PromotionPrice: $("#selPoli").val() == "2" ? $("#input_PromotionPrice").val() : "",
        SerialNumber: $("#input_SerialNumber").val(),
        UnitPrice: $("#input_UnitPrice").val(),
        Manufacturer: $("#input_Manufacturer").val(),
        ApprovalNumber: $("#input_ApprovalNumber").val(),
        IsConfirmed: isConfirmed,
        // 2020.06.18 Lou
        AutoConfirm: $("#IsAutoComfirm1").is(":checked") ? 1 : 0,
        AutoConfirmDays: $("#IsAutoComfirm1").is(":checked") ? $("#input_AutoConfirmDays").val().trim() : "7",
        // 2020.06.18 Lou END
        Thumbnail: getThumbImage(),
        BigImageUrl: getBigImage(),
        deleteImageUrl: getDeleteImage()
    }

    if (param.CommodityName == null || param.CommodityName == "") {
        alert("商品名称不能为空！");
        return;
    }
    if (!priceChk(param.UnitPrice)) {
        return;
    }

    if ($("#selPoli").val() == "2" && param.PromotionPrice == "") {
        alert("请输入促销价！");
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

    $.ajax({
        type: "POST",
        url: "/Commodity/updateCommodity",
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
                $("#a_profile").click();
                //location.href = "/Commodity/GetCommodityList?b=-1&c=-1";
            }
            else
                alert(data.Message);
        }
    });
}

function addCommodity() {
    var param = {
        CommodityID: $("#hidID").val(),
        CommodityName: $("#input_Name").val().trim()
    }
    var count = 0;
    $.ajax({
        type: "POST",
        url: "/Commodity/getCountbyCommodityName",
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
        if (confirm("商品名称已存在，是否继续？") == false) {
            return;
        }
    }

    var isConfirmed = 0;
    if ($("#IsConfirmed1").is(":checked")) {
        isConfirmed = 1;
    } else if ($("#IsConfirmed2").is(":checked")) {
        isConfirmed = 2;
    }

    var param = {
        CategoryID: $("#selCat").val(),
        CommodityID: $("#hidID").val(),
        CommodityCode: $("#hidCode").val(),
        MarketingPolicy: $("#selPoli").val(),
        CommodityName: $("#input_Name").val(),
        Describe: $("#input_Describe").val(),
        Specification: $("#input_Specification").val(),
        VisibleForCustomer: $("#radio_VisibleForCustomer").is(":checked"),
        New: $("#ck_New").is(":checked") ? true : false,
        Recommended: $("#ck_Recommended").is(":checked") ? true : false,
        DiscountID: $("#selPoli").val() == "1" ? $("#selDis").val() : "",
        PromotionPrice: $("#selPoli").val() == "2" ? $("#input_PromotionPrice").val() : "",
        SerialNumber: $("#input_SerialNumber").val(),
        UnitPrice: $("#input_UnitPrice").val(),
        Manufacturer: $("#input_Manufacturer").val(),
        ApprovalNumber: $("#input_ApprovalNumber").val(),
        IsConfirmed: isConfirmed,
        // 2020.06.18 Lou
        AutoConfirm: $("#IsAutoComfirm1").is(":checked") ? 1 : 0,
        AutoConfirmDays: $("#IsAutoComfirm1").is(":checked") ? $("#input_AutoConfirmDays").val().trim() : "7",
        // 2020.06.18 Lou END
        Thumbnail: getThumbImage(),
        BigImageUrl: getBigImage()
    }

    if (param.CommodityName == null || param.CommodityName == "") {
        alert("商品名称不能为空！");
        return;
    }
    if (!priceChk(param.UnitPrice)) {
        return;
    }
    if ($("#selPoli").val() == "2" && param.PromotionPrice == "") {
        alert("请输入促销价！");
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

    $.ajax({
        type: "POST",
        url: "/Commodity/addCommodity",
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

function ProductStock() {
    var BranchID = 0;
    var Code = 0;

    //TBL_PRODUCT_STOCK表
    var ProductStockID = 0;
    var ProductQty = 0;
    var StockCalcType = 0;

    //TBL_PRODUCT_STOCK_OPERATELOG
    var OperateType = 0;
    var OperateQty = 0;
    var OperateSign = 0;
    var OperateRemark = "";
    //TBL_PRODUCT_RELATIONSHIP
    var ProductRelationShipID = 0;
    var BranchAvailable = false;
}

function updateBranchStock() {
    var id = $("#hidCode").val();
    if (id == "0") {
        alert("请先添加商品！")
    }

    var result = true;

    var list = new Array();
    $("#tbRelation tr:not(:first)").each(function (a) {
        if (!result) {
            return;
        }

        var ProductStockID = "-1";
        if ($("#hidPro" + a).val() == "" && !$("#branchAvailable" + a).is(":checked"))
            ProductStockID = "-1";
        else if ($("#hidPro" + a).val() == "" && $("#branchAvailable" + a).is(":checked"))
            ProductStockID = "0";
        else
            ProductStockID = $("#hidPro" + a).val();

        var ProductRelationShipID = "-1";
        if ($("#hidPro" + a).val() == "" && $("#selOperationType" + a).val() == "0")
            ProductRelationShipID = "-1";
        else if ($("#selOperationType" + a).val() != "0")
            ProductRelationShipID = "0";
        else
            ProductRelationShipID = $("#hidPro" + a).val();

        var ProductStock = {
            BranchID: $("#hidBra" + a).val(),

            //TBL_PRODUCT_STOCK表
            ProductStockID: ProductStockID,
            ProductQty: $("#tdProductQty" + a).val(),
            StockCalcType: $("#selStockCal" + a).val(),
            BuyingPrice: $("#txtStockUnitPrice" + a).val(),
            InsuranceQty: $("#txtInsuranceQty" + a).val(),
            //TBL_PRODUCT_STOCK_OPERATELOG
            OperateType: $("#selOperationType" + a).val(),
            OperateQty: $("#input_Quantity" + a).val(),
            OperateSign: 0,
            OperateRemark: $("#input_Remark" + a).val(),
            //TBL_PRODUCT_RELATIONSHIP
            ProductRelationShipID: ($("#hidPro" + a).val() == "") && $("#branchAvailable" + a).is(":checked") ? "-1" : $("#hidPro" + a).val(),
            BranchAvailable: $("#branchAvailable" + a).is(":checked"),
        }
        if (ProductStock.OperateType != "0" && ProductStock.OperateQty == "") {
            alert("请输入操作库存数！");
            result = false;
            return;
        }

        if (isNaN(ProductStock.BuyingPrice)) {
            alert("库存单价请输入数字！");
            result = false;
            return;
        } else {
            if (ProductStock.BuyingPrice < 0) {
                alert("库存单价必须大于等于0！");
                result = false;
                return;
            }
        }

        if (isNaN(ProductStock.InsuranceQty)) {
            alert("安全库存请输入数字！");
            result = false;
            return;
        } else {
            if (ProductStock.InsuranceQty < 0) {
                alert("安全库存必须大于等于0！");
                result = false;
                return;
            }
            var ex = /^\d+$/;
            if (!ex.test(ProductStock.InsuranceQty)) {
                alert("安全库存请输入整数");
                result = false;
                return;

            }
        }

        list.push(ProductStock);
    });

    if (!result) {
        return;
    }

    var model = {
        Code: $("#hidCode").val(),
        operationList: list
    }

    $.ajax({
        type: "POST",
        url: "/Commodity/updateProductStocks",
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
                var categoryId = $.getUrlParam('c');
                var branchId = $.getUrlParam('b');
                var supplierID = $.getUrlParam('d');
                var cd = $.getUrlParam('CD');
                location.href = "/Commodity/GetCommodityList?b=" + branchId + "&c=" + categoryId + "&d=" + supplierID + "#" + cd;
            }
            else
                alert(data.Message);
        }
    });


}

function AllSelect(e) {
    $('input[type="checkbox"]').each(function () {
        $(this).prop("checked", $(e).is(":checked"));
    });
}

function mulityDelete() {
    var branchID = $("#selBra").val();
    var categoryID = $("#seCal").val();
    var supplierID = $("#selSup").val();

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

    if (confirm("确认删除？")) {
        $.ajax({
            type: "POST",
            url: "/Commodity/deleteMultiCommodity",
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
                    location.href = "/Commodity/GetCommodityList?b=" + branchID + "&c=" + categoryID + "&d=" + supplierID;
                }
                else
                    alert(data.Message);
            }
        });
    }
}

function downloadCommodity() {
    var param = {
        BranchID: $("#selBra").val(),
        CategoryID: $("#seCal").val()
    }
    $.ajax({
        type: "POST",
        url: "/Commodity/downloadCommodity",
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
        }
    });
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
        url: "/Commodity/getCommodityPrintList",
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
            strHtml += '<p class="over-text col-xs-12">' + data[i].CommodityName + '&nbsp;</p>';
            strHtml += '<p>' + data[i].Specification + '&nbsp;</p>';
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

function UpdateCommoditySort() {
    var strParma = "";
    $("#foo tr").each(function (i) {
        strParma += $(this).find("#hidcommdityCode").val() + ",";
    });
    strParma += "|" + $("#hidoldSortID").val();

    var SortMode = {
        Prama: strParma
    };

    var calid = $("#seCal").val();

    $.ajax({
        type: "POST",
        url: "/Commodity/UpdateCommoditySort",
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
                location.href = "/Commodity/GetCommodityList?b=-1&c=" + calid + "&d=-1";
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


function editCommodity(code) {
    var categoryId = $("#seCal").val();
    var branchId = $("#selBra").val();
    var supplierID = $("#selSup").val();

    location.href = "/Commodity/EditCommodity?CD=" + code + "&b=" + branchId + "&c=" + categoryId + "&d=" + supplierID;
}

function goback() {
    var categoryId = $.getUrlParam('c');
    var branchId = $.getUrlParam('b');
    var supplierID = $.getUrlParam('d');
    var cd = $.getUrlParam('CD');
    location.href = "/Commodity/GetCommodityList?b=" + branchId + "&c=" + categoryId + "&d=" + supplierID + "#" + cd;

}

function AddBatch(code) {
    location.href = "/Commodity/AddBatch?code=" + code + "&b=-1&c=-1&d=-1";
}

function delBatch(ID, BranchID, ProductCode, Quantity, BatchNo) {
    if (confirm("确认删除？")) {
        $.ajax({
            type: "POST",
            url: "/Commodity/DeleteBatch",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            data: '{"ID":"' + ID + '","BranchID":"' + BranchID + '","ProductCode":"' + ProductCode + '","Quantity":"' + Quantity + '","BatchNo":"' + BatchNo + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    var categoryId = $.getUrlParam('c');
                    var branchId = $.getUrlParam('b');
                    var supplierID = $.getUrlParam('d');
                    var cd = $.getUrlParam('CD');
                    location.href = "/Commodity/GetCommodityList?b=" + branchId + "&c=" + categoryId + "&d=" + supplierID + "#" + cd;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}
function checkExpiryDate(txt_DateId) {
    if ($(txt_DateId).val().match(dateMatch) == null) {
        $(txt_DateId).parent().attr("style", "background-color:red");
        alert("请输入正确的有效期格式,如:20190101");
        result = false;
        return;
    } else {
        var dateStr = $(txt_DateId).val();
        dateStr = dateStr.substr(0, 4) + "-" + dateStr.substr(4, 2) + "-" + dateStr.substr(6, 2)
        if (!IsDate(dateStr)) {
            alert("请输入正确的有效期格式,如:20190101");
            result = false;
            return;
        }
    }
    if (GetNumberOfDays(new Date(), $(txt_DateId).val()) <= 180) {
        $(txt_DateId).parent().attr("style", "background-color:red");
    } else {
        $(txt_DateId).parent().attr("style", "background-color:");
    }
}

function selectSupplier(supplier, m) {
    var supplierID = $(supplier).val();
    if (supplierID == "0") {
        supplierID = null;
    }
    $("#hidSupplierID" + m).val(supplierID);
    //$("#input_Supplier").val($("#selSupplier").val());
}

function updateBatchStock() {
    var id = $("#hidCode").val();
    if (id == "0") {
        alert("请先添加批次！")
    }

    var result = true;

    var list = new Array();
    $("#tbBatch tr:not(:first)").each(function (a) {
        if (!result) {
            return;
        }

        var BatProductStock = {
            CompanyID: $("#hidCompanyID" + a).val(),
            ID: $("#hidID" + a).val(),
            Quantity: $("#Batch_Quantity" + a).val(),
            ExpiryDate: $("#txt_Date" + a).val(),
            BranchID: $("#hidBranchID" + a).val(),
            ProductCode: $("#hidProductCode" + a).val(),
            BatchNO: $("#hidBatchNO" + a).val(),
            SupplierID: $("#hidSupplierID" + a).val()
        }
        if (isNaN(BatProductStock.Quantity) || BatProductStock.Quantity == "") {
            alert("批次数量请输入数字！");
            result = false;
            return;
        } else {
            if (BatProductStock.Quantity < 0) {
                alert("批次数量必须大于等于0！");
                result = false;
                return;
            }
        }

        if (BatProductStock.ExpiryDate == "" || BatProductStock.ExpiryDate == null) {
            alert("请输入有效期！");
            result = false;
            return;
        } else {
            var expiryDate_match = BatProductStock.ExpiryDate.match(dateMatch);
            if (expiryDate_match == null) {
                alert("请输入正确的有效期格式,如:20190101");
                result = false;
                return;
            }
        }
        BatProductStock.ExpiryDate = BatProductStock.ExpiryDate.substr(0, 4) + "-" + BatProductStock.ExpiryDate.substr(4, 2) + "-" + BatProductStock.ExpiryDate.substr(6, 2)
        if (!IsDate(BatProductStock.ExpiryDate)) {
            alert("请输入正确的有效期格式,如:20190101");
            result = false;
            return;
        }
        if (BatProductStock.Supplier == "0") {
            BatProductStock.Supplier = null;
        }
        /*if (BatProductStock.Supplier == null || BatProductStock.Supplier == "") {
            alert("请输入供应商！");
            result = false;
            return;
        }*/
        list.push(BatProductStock);
    });

    if (!result) {
        return;
    }

    var model = {
        batchList: list
    }

    $.ajax({
        type: "POST",
        url: "/Commodity/updateBatchStocks",
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
                var categoryId = $.getUrlParam('c');
                var branchId = $.getUrlParam('b');
                var supplierID = $.getUrlParam('d');
                var cd = $.getUrlParam('CD');
                location.href = "/Commodity/GetCommodityList?b=" + branchId + "&c=" + categoryId + "&d=" + supplierID + "#" + cd;
            }
            else
                alert(data.Message);
        }
    });


}

function addStorage() {
    var piece = $("#txtpiece").val();
    var cd = $.getUrlParam('CD');
    var b = $.getUrlParam('b');
    var c = $.getUrlParam('c');
    var d = $.getUrlParam('d');
    if (!/^[0-9]*$/.test(piece)) {
        alert("请正确输入件数")
        $("#txtpiece").focus();
        return;
    }
    if (piece <= 0) {
        alert("请正确输入件数")
        $("#txtpiece").focus();
        return;
    }
    if (confirm("确定件数提交")) {
        var count = {
            Quantity: piece,
            commodityCode: cd
        }
        $.ajax({
            type: "POST",
            url: "/Commodity/operateQuantity",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(count),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("网络繁忙,请稍后再试！");
            },
            success: function (data) {
                if (data.Code == "1") {
                    alert("入库成功");
                    location.href = "/Commodity/EditCommodity?CD=" + cd + "&b=" + b + "&c=" + c + "&d=" + d;

                }
                else {
                    alert(data.Message);
                }
            }
        });
    }

}

function addApply(BranchName, totalPiece) {
    var html = '';
    html += ' <tr>'
    html += ' <td style="padding-left: 20px;">' + BranchName + '</td>';
    html += ' <td></td>';
    html += ' <td><input style="width: 52px;" type="text" id="txtApplyPiece"></td>';
    html += ' <td></td>';
    html += ' <td></td>';
    html += ' <td><a onclick="Apply(' + totalPiece + ')" class="btn" style="padding-bottom: 0px;padding-top: 0px;">申请</a>'
    html += ' </tr>'
    $("#applyArea").append(html);

}

function Confirm(ID) {
    var cd = $.getUrlParam('CD');
    var b = $.getUrlParam('b');
    var c = $.getUrlParam('c');
    var d = $.getUrlParam('d');

    if (confirm("确定提交")) {
        var count = {
            id: ID
        }
        $.ajax({
            type: "POST",
            url: "/Commodity/confirmCommodityCode",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(count),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("网络繁忙,请稍后再试！");
            },
            success: function (data) {
                if (data.Code == "1") {
                    location.href = "/Commodity/EditCommodity?CD=" + cd + "&b=" + b + "&c=" + c + "&d=" + d;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }

}

function Apply(totalPiece) {
    var piece = $("#txtApplyPiece").val();
    var cd = $.getUrlParam('CD');
    var b = $.getUrlParam('b');
    var c = $.getUrlParam('c');
    var d = $.getUrlParam('d');

    if (!/^[0-9]*$/.test(piece)) {
        alert("请正确输入件数")
        return;
    }
    if (piece <= 0) {
        alert("至少申请1件")
        return;
    }
    if (piece > totalPiece) {
        alert("申请件数大于库中件数")
        return;
    }
    if (confirm("确定申请提交")) {
        var count = {
            Quantity: piece,
            commodityCode: cd
        }
        $.ajax({
            type: "POST",
            url: "/Commodity/applyCommodityCode",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(count),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("网络繁忙,请稍后再试！");
            },
            success: function (data) {
                if (data.Code == "1") {
                    alert("申请成功");
                    location.href = "/Commodity/EditCommodity?CD=" + cd + "&b=" + b + "&c=" + c + "&d=" + d;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }

}

function Agree(ID, totalPiece, quantity) {
    var cd = $.getUrlParam('CD');
    var b = $.getUrlParam('b');
    var c = $.getUrlParam('c');
    var d = $.getUrlParam('d');

    var BatchNO = $.trim($("#txtBatchNO").val());
    var ExpiryDate = $("#txtExpiryDate").val();
    if (BatchNO == "") {
        alert("请输入批次番号");
        $("#txtBatchNO").focus();
        return;
    }
    if (!/^[0-9-]{10}$/.test(ExpiryDate)) {
        alert("请选择有效期");
        $("#txtExpiryDate").focus();
        return;
    }
    if (quantity > totalPiece) {
        alert("申请件数大于库中件数")
        return;
    }


    if (confirm("确定同意")) {
        var count = {
            id: ID,
            batchNO: BatchNO,
            expiryDate: ExpiryDate
        }
        $.ajax({
            type: "POST",
            url: "/Commodity/agreeCommodityCode",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(count),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("网络繁忙,请稍后再试！");
            },
            success: function (data) {
                if (data.Code == "1") {
                    location.href = "/Commodity/EditCommodity?CD=" + cd + "&b=" + b + "&c=" + c + "&d=" + d;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }

}

function checkBranch() {
    if ($("#selBra").val() == null || ($("#selBra").val() <= 0)) {
        alert("请选择一个门店！");
        return;
    } else {
        window.location.href = "/BatchImport/BatchCommodityImport?Type=1&BranchID="+$("#selBra").val();
    }
}
function Negative(ID) {
    var cd = $.getUrlParam('CD');
    var b = $.getUrlParam('b');
    var c = $.getUrlParam('c');
    var d = $.getUrlParam('d');

    if (confirm("确定否决")) {
        var count = {
            id: ID
        }
        $.ajax({
            type: "POST",
            url: "/Commodity/negativeCommodityCode",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(count),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("网络繁忙,请稍后再试！");
            },
            success: function (data) {
                if (data.Code == "1") {
                    location.href = "/Commodity/EditCommodity?CD=" + cd + "&b=" + b + "&c=" + c + "&d=" + d;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }

}

function getCountbyCommodityName() {
    var commodityName = $("#input_Name").val().trim();
    if (commodityName == "") {
        return;
    }

    var param = {
        CommodityID: $("#hidID").val(),
        CommodityName: commodityName
    }
    var count = 0;
    $.ajax({
        type: "POST",
        url: "/Commodity/getCountbyCommodityName",
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
        alert("商品名称已存在！");
    }
    return;
}