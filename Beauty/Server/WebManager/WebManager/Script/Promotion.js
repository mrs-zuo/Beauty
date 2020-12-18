/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    var branchID = $.getUrlParam('branchID');
    if (branchID != null) {
        $('#ddl_branchID').val(branchID);
    }

    var flag = $.getUrlParam('flag');
    if (flag != null) {
        $('#ddl_flag').val(flag);
    }

    var viewtype = $.getUrlParam('viewtype');
    if (viewtype == null || viewtype == 0) {
        viewtype = 0;
    }
    else {
        viewtype = 1;
    }

    $('#ddl_branchID').change(function () {
        if (branchID != null) {
            branchID = 0;
        }
        var url = "/Promotion/GetPromotionList?viewtype=" + viewtype + "&branchID=" + $(this).val();
        if (flag != null) {
            url += "&flag=" + $('#ddl_flag').val();
        }
        location.href = url;
    });

    $('#ddl_flag').change(function () {
        if (flag != null) {
            flag = 0;
        }
        var url = "/Promotion/GetPromotionList?viewtype=" + viewtype + "&flag=" + $(this).val();
        if (branchID != null) {
            url += "&branchID=" + $('#ddl_branchID').val();
        }
        location.href = url;
    });
});

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function addImgPromo() {
    var starttime = $.trim($('#txt_imgstartDate').val());
    var endtime = $.trim($('#txt_imgendDate').val());
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

    var PromotionImgUrl = getBigImage()
    if (PromotionImgUrl == "") {
        alert('请上传图片！');
        return false;
    }


    var PromotionMode = {
        StartDate: start,
        EndDate: end,
        Type: 0,
        PromotionImgUrl: PromotionImgUrl
        //, BranchList: BranchIDList
    };

    $.ajax({
        type: "POST",
        url: "/Promotion/AddPromotion",
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
                location.href = "/Promotion/EditPromotion?viewtype=0&active=1&ID=" + data.Data;
            }
            else
                alert(data.Message);
        }
    });
}

function editImgPromo(ID) {
    var starttime = $.trim($('#txt_imgstartDate').val());
    var endtime = $.trim($('#txt_imgendDate').val());
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
    //var strOldBranchIDs = $.trim($('#hid_imgOldBranchs').val());
    //var strbranchIds = "";

    //var BranchIDList = new Array();
    //$('input[type="checkbox"][name="imgBranchID"]:checked').each(function () {
    //    var PromotionBranchList = {
    //        BranchID: this.value
    //    };
    //    strbranchIds += "|" + this.value;
    //    BranchIDList.push(PromotionBranchList);
    //});

    //if (BranchIDList.length <= 0) {
    //    alert('请选择门店！');
    //    return false;
    //}

    //if (strbranchIds == strOldBranchIDs) {
    //    BranchIDList = null;
    //}

    var oldImg = $.trim($('#hid_imgUrl').val());
    var PromotionImgUrl = getBigImage()
    if (PromotionImgUrl == "") {
        if (oldImg == "") {
            alert('请上传图片！');
            return false;
        }
        else {
            PromotionImgUrl = oldImg;
        }
    }

    var PromotionMode = {
        ID: ID,
        StartDate: start,
        EndDate: end,
        Type: 0,
        ImageFile: oldImg,
        PromotionImgUrl: PromotionImgUrl
        //, BranchList: BranchIDList
    };

    $.ajax({
        type: "POST",
        url: "/Promotion/UpdatePromotion",
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
                location.href = "/Promotion/GetPromotionList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function addTextPromo() {
    var starttime = $.trim($('#txt_imgstartDate').val());
    var endtime = $.trim($('#txt_imgendDate').val());
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

    var textcontent = $.trim($('#txt_textpromotion').val());
    if (textcontent == "") {
        alert('促销文字不能为空！');
        return false;
    }

    //var BranchIDList = new Array();
    //$('input[type="checkbox"][name="textBranchID"]:checked').each(function () {
    //    var PromotionBranchList = {
    //        BranchID: this.value
    //    };
    //    BranchIDList.push(PromotionBranchList);
    //});

    //if (BranchIDList.length <= 0) {
    //    alert('请选择门店！');
    //    return false;
    //}

    var PromotionMode = {
        StartDate: start,
        EndDate: end,
        Type: 1,
        TextContent: textcontent
        //, BranchList: BranchIDList
    };

    $.ajax({
        type: "POST",
        url: "/Promotion/AddPromotion",
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
                location.href = "/Promotion/EditPromotion?viewtype=1&active=1&ID=" + data.Data;
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function editTextPromo(ID) {
    var starttime = $.trim($('#txt_imgstartDate').val());
    var endtime = $.trim($('#txt_imgendDate').val());
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
    //var strOldBranchIDs = $.trim($('#hid_textOldBranchs').val());
    //var strbranchIds = "";

    //var BranchIDList = new Array();
    //$('input[type="checkbox"][name="textBranchID"]:checked').each(function () {
    //    var PromotionBranchList = {
    //        BranchID: this.value
    //    };
    //    strbranchIds += "|" + this.value;
    //    BranchIDList.push(PromotionBranchList);
    //});

    //if (BranchIDList.length <= 0) {
    //    alert('请选择门店！');
    //    return false;
    //}

    //if (strbranchIds == strOldBranchIDs) {
    //    BranchIDList = null;
    //}

    var textcontent = $.trim($('#txt_textpromotion').val());
    if (textcontent == "") {
        alert('促销文字不能为空！');
        return false;
    }

    var PromotionMode = {
        ID: ID,
        StartDate: start,
        EndDate: end,
        Type: 1,
        TextContent: textcontent
        //, BranchList: BranchIDList
    };

    $.ajax({
        type: "POST",
        url: "/Promotion/UpdatePromotion",
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
                location.href = "/Promotion/GetPromotionList?viewtype=1";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function delPromotion(ID, Type) {
    if (confirm("确定要进行此操作吗？")) {
        var PromotionMode = {
            ID: ID,
            Type: Type
        };

        $.ajax({
            type: "POST",
            url: "/Promotion/DeletePromotion",
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
                    location.href = "/Promotion/GetPromotionList?viewtype=" + Type;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function returnPromoList(Type) {
    location.href = "/Promotion/GetPromotionList?viewtype=" + Type;
}