/// <reference path="../assets/js/jquery-2.0.3.min.js" />


(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function EditPromo(Code) {
    var starttime = $.trim($('#txt_startDate').val());
    var endtime = $.trim($('#txt_endDate').val());
    if (starttime == "" || endtime == "") {
        alert('日期不能为空！');
        return false;
    }
    var start = new Date(starttime.replace("-", "/").replace("-", "/"));
    var end = new Date(endtime.replace("-", "/").replace("-", "/"));

    if (end < start) {
        alert('结束日期不能小于开始日期！');
        return false;
    }

    if (end == start) {
        alert('结束日期不能等于开始日期！');
        return false;
    }

    //var BranchIDList = new Array();
    //$('input[type="checkbox"][name="imgBranchID"]:checked').each(function () {
    //    var PromotionBranchList = {
    //        BranchID: this.value
    //    };
    //    BranchIDList.push(PromotionBranchList);
    //});

    //if (BranchIDList.length <= 0) {
    //    alert('请选择门店！');
    //    return false;
    //}

    var ImageFile = getBigImage()

 
    //if (PromotionImgUrl == "") {
    //    alert('请上传图片！');
    //    return false;
    //}
    if ($.trim($('#ddlType').val()) == 1 && ImageFile == "" && Code == "") {
        alert('请上传图片！');
        return false;
    }

    var PromotionMode = {
        PromotionCode: Code,
        StartDate: start,
        EndDate: end,
        Type: $.trim($('#ddlType').val()),
        Title: $.trim($('#txt_Title').val()),
        Description: $.trim($('#txt_Description').val()),
        ImageFile: ImageFile,
        PromotionType: $.trim($('#ddlPromotionType').val())
        //, BranchList: BranchIDList
    };
    $.ajax({
        type: "POST",
        url: "/Promotion/UpdatePromotion_New",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(PromotionMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Promotion/EditPromotionNew?active=1&cd=" + data.Data;
            }
            else
                alert(data.Message);
        }
    });
}

function delPromotion(Code) {
    if (confirm("确定要进行此操作吗？")) {
        var PromotionMode = {
            PromotionCode: Code,
        };

        $.ajax({
            type: "POST",
            url: "/Promotion/DeletePromotion_NEW",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(PromotionMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Promotion/GetPromotionList?";
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function returnPromoList(Type) {
    location.href = "/Promotion/GetPromotionListNew?";
}


function submitBranch(Code) {
    var BranchIDList = new Array();
    var newBranch = "";
    $('input[type="checkbox"][name="imgBranchID"]:checked').each(function () {
        newBranch += "|" + this.value;
        BranchIDList.push(this.value);
    });

    if ($("#hid_imgOldBranchs").val() == newBranch) {
        alert("门店选择未改变")
        return false;
    }

    var BranchSelectMode = {
        ObjectCode: Code,
        BranchList: BranchIDList
    };

    $.ajax({
        type: "POST",
        url: "/Promotion/OperationBranchSelect",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(BranchSelectMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Promotion/GetPromotionListNew";
            }
            else
                alert(data.Message);
        }
    });
}


function selectAllBranch(e) {
    if ($(e).is(":checked")) {
        $('input[type="checkbox"][name="imgBranchID"]').prop("checked", true);
    } else {
        $('input[type="checkbox"][name="imgBranchID"]').prop("checked", false);
    }
}


function AddPromotionProduct(promotionCode, productType) {
    var url = "";
    $('[name="productId"]:checked').each(function () {
        url = "/Promotion/EditPromotionProduct?pc="+ promotionCode + "&pcd=" + $(this).val() + "&pt=" + productType+ "&a=1";
    });
    if (url == "") {
        alert("请先选择产品");
    } else {
        location.href = url;
    }
}

function EditPromotionProductDetail(promotionCode, promotionType, ProductID, ProductType, isAdd) {
    var result = true;
    var ListPromotionRule = new Array();
    $('#divRule input[type="checkbox"][name="RuleCode"]:checked').each(function () {
        if ($(this).parent().next().children().val() <= 0) {
            result = false;
            return false;
        } else {
            var PromotionRule = {
                PRCode: $(this).val(),
                PRValue: $(this).parent().next().children().val()
            }
            ListPromotionRule.push(PromotionRule);
        }
    });

    if (!result) {
        alert("选中的规则请输入大于0的值");
        return;
    }

    if ($.trim($("#txtProductPromotionName").val()) == "") {
        alert("请输入产品促销名称");
        return;
    }


    if (!priceChk($("#txtDiscountPrice").val())) {
       // alert("请输入正确的优惠价");
        return;
    } 

    var ProductMode = {
        PromotionID: promotionCode,
        ProductID: ProductID,
        ProductPromotionName: $.trim($("#txtProductPromotionName").val()),
        ProductType: ProductType,
        DiscountPrice: $("#txtDiscountPrice").val(),
        Notice: $.trim($("#txtNotice").val()),
        SoldQuantity: 0,
        PromotionRuleList: ListPromotionRule,
        IsAdd: isAdd,
        PromotionType: promotionType
    };



    $.ajax({
        type: "POST",
        url: "/Promotion/SubmitPromotionProduct",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(ProductMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Promotion/GetPromotionProductList?pc=" + promotionCode;
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
    } else if (value <= 0) {
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



function DeletePromotionProduct(promotionCode, ProductID, ProductType) {
 

    var ProductMode = {
        PromotionID: promotionCode,
        ProductID: ProductID,
        ProductType: ProductType
    };



    $.ajax({
        type: "POST",
        url: "/Promotion/DeletePromotionProduct",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(ProductMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Promotion/GetPromotionProductList?pc=" + promotionCode;
            }
            else
                alert(data.Message);
        }
    });
}