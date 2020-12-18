/// <reference path="../assets/js/jquery-2.0.3.min.js" />
function delBranch(ID, Available) {
    var param = '{"BranchID":' + ID + ',"Available":' + Available + '}';;
    $.ajax({
        type: "POST",
        url: "/Branch/DeleteBranch",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data == "0") {
                alert("操作失败!");
                return;
            }
            else {
                alert("操作成功!");
                window.location.href = "/Branch/GetBranchList";
            }
        }
    });
}

function CompanySubmit() {

    if (confirm("更新之后需要重新登录，是否继续?")) {
        var CompanyMode = {
            Name: $.trim($("#txtCompanyName").val()),
            Abbreviation: $("#txtCompanyAbbreviation").val(),
            Contact: $.trim($("#txtCompanyContact").val()),
            Phone: $.trim($("#txtCompanyPhone").val()),
            Fax: $.trim($("#txtCompanyFax").val()),
            Web: $.trim($("#txtCompanyWeb").val()),
            Summary: $("#txtCompanySummary").val(),
            BalanceRemind: $("#radioBalanceY").is(":checked"),
            Visible: $("#radioVisibleY").is(":checked"),
            IsConfirmed: $("#IsConfirmedY").is(":checked"),
            BigImageUrl: getBigImage(),
            deleteImageUrl: getDeleteImage(),
            Style: $.trim($("#txtStyle").val()),
            ComissionCalc: $("#radioCommissionY").is(":checked"),
            AppointmentMustPaid: $("#appointmentMustPaidY").is(":checked"),
            CommissionRate : $.trim($("#txtCommissionRateWeb").val()),
            IssuedDate: $.trim($("#txtCompanyIssuedDate").val())
        };

        if (CompanyMode.Name == "") {
            alert("公司名称不能为空");
            return false;
        }
        if (isNaN(CompanyMode.CommissionRate)) {
            alert("销售顾问提成比例必须输入数字");
            return false;
        }
        /*if (CompanyMode.IssuedDate != null && CompanyMode.IssuedDate != "") {
            var today = new Date();
            var sTime = CompanyMode.IssuedDate.replace("-", "/");
            sTime = sTime.replace("-", "/");
            today = today.getFullYear() + "/" + (parseInt(today.getMonth()) + 1) + "/" + today.getDate() + " " + today.getHours() + ":" + today.getMinutes();
            var result = (Date.parse(sTime) - Date.parse(today)) / 86400000;
            if (result < 0) {
                alert("销售顾问提成比例生效日期不能小于今天!");
                return false;
            }
        }*/
        $.ajax({
            type: "POST",
            url: "/Company/UpdateCompany",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(CompanyMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    $.cookie('CompanyInfo', null, { path: '/' });
                    $.cookie('HSManger', null, { path: '/' });
                    location.href = "/";
                    location.href = "/Branch/GetBranchList";
                }
                else
                    alert(data.Message);
            }
        });
    }
}


function defaultPasswordChange(e) {
    var name = $(e).attr("id")
    if (name == "DefaultPasswordY") {
        $("#txtBranchDefaultPassword").show();
    } else {
        $("#txtBranchDefaultPassword").val("");
        $("#txtBranchDefaultPassword").hide();
    }
}


function BranchSubmit(branchID) {

    var startTime = null;
    if ($("#txtBranchStartTime").attr("disabled") == "disabled") {
        startTime = null;
    } else {
        startTime = $.trim($("#txtBranchStartTime").val());
    }

    var isUseRate = 2;
    if ($("#IsUseRateY").is(":checked")) {
        isUseRate = 1;
    }
    else if ($("#IsUseRateN").is(":checked")) {
        isUseRate = 2;
    }

    var DefaultConsultant = 0;
    if (branchID > 0) {
        DefaultConsultant = $("#ddlConsultant").val();
    }

    var BranchMode = {
        ID: branchID,
        BranchName: $("#txtBranchName").val(),
        Contact: $.trim($("#txtBranchContact").val()),
        Phone: $.trim($("#txtBranchPhone").val()),
        Fax: $.trim($("#txtBranchFax").val()),
        Address: $.trim($("#txtBranchAddress").val()),
        Longitude: $.trim($("#txtBranchLongitude").val()),
        Latitude: $.trim($("#txtBranchLatitude").val()),
        Zip: $.trim($("#txtBranchZip").val()),
        Web: $.trim($("#txtBranchWeb").val()),
        BusinessHours: $.trim($("#txtBranchBusinessHours").val()),
        StartTime: startTime,
        Remark: $.trim($("#txtBranchRemark").val()),
        Visible: $("#BranchVisibleY").is(":checked"),
        IsShowECardHis: $("#IsShowECardHisY").is(":checked"),
        IsConfirmed: false,
        IsPartPay: $("#IsPartPayY").is(":checked"),
        IsPay: $("#IsPayN").is(":checked"),
        RemindTime: $.trim($("#txtBranchRemindTime").val()),
        BirthdayRemindTime: $.trim($("#txtBranchBirthdayRemindTime").val()),
        DefaultPassword: $("#DefaultPasswordY").is(":checked") ? $.trim($("#txtBranchDefaultPassword").val()) : "",
        BigImageUrl: getBigImage(),
        IsUseRate: isUseRate,
        DefaultConsultant: DefaultConsultant,
        DeleteImageUrl: getDeleteImage(),
        LostRemind: $.trim($("#txtLostRemind").val()),
        ExpiryRemind: $.trim($("#txtExpiryRemind").val()),
        CommissionRate: $.trim($("#txtCommissionRateWeb").val()),
        IssuedDate: $.trim($("#txtBranchIssuedDate").val()),
    };

    if (BranchMode.IsPartPay && BranchMode.IsUseRate == 1) {
        alert("分期支付和使用业绩折扣率不能同时使用");
        return false;
    }

    if (BranchMode.BranchName == "") {
        alert("门店名称不能为空");
        return false;
    }
    if (BranchMode.RemindTime == "") {
        alert("提醒时间不能为空");
        return false;
    } else {
        if (isNaN(BranchMode.RemindTime)) {
            alert("请输入数字");
            return false;
        }
        else if (BranchMode.RemindTime <= 0) {
            alert("提醒时间不能小于0");
            return false;
        } else if (BranchMode.RemindTime > 999.99) {
            alert("提醒时间不能大于999.99");
            return false;

        }
    }
    if (isNaN(BranchMode.CommissionRate)) {
        alert("销售顾问提成比例必须输入数字");
        return false;
    }
    var reg = /^\+?[0-9]*$/;;
    if (BranchMode.BirthdayRemindTime == "") {
        BranchMode.BirthdayRemindTime = -1;
    } else {
        if (!reg.test(BranchMode.BirthdayRemindTime)) {
            alert("生日提醒时间请输入0-255");
            return false;
        } else if (BranchMode.BirthdayRemindTime > 255) {
            alert("生日提醒时间不能大于255");
            return false;

        }
    }


    if (BranchMode.StartTime != null && BranchMode.StartTime != "") {
        var today = new Date();
        var sTime = BranchMode.StartTime.replace("-", "/");
        sTime = sTime.replace("-", "/");
        today = today.getFullYear() + "/" + (parseInt(today.getMonth()) + 1) + "/" + today.getDate() + " " + today.getHours() + ":" + today.getMinutes();
        var result = (Date.parse(sTime) - Date.parse(today)) / 86400000;
        if (result < 0) {
            alert("开始日期不能小于今天!");
            return false;
        }
    }
    /*if (BranchMode.IssuedDate != null && BranchMode.IssuedDate != "") {
        var today = new Date();
        var sTime = BranchMode.IssuedDate.replace("-", "/");
        sTime = sTime.replace("-", "/");
        today = today.getFullYear() + "/" + (parseInt(today.getMonth()) + 1) + "/" + today.getDate() + " " + today.getHours() + ":" + today.getMinutes();
        var result = (Date.parse(sTime) - Date.parse(today)) / 86400000;
        if (result < 0) {
            alert("销售顾问提成比例生效日期不能小于今天!");
            return false;
        }
    }*/
    if (BranchMode.Longitude == "") {
        alert("请输入经度");
        return false;
    } else {

        if (isNaN(BranchMode.Longitude)) {
            alert("请输入数字");
            return false;
        }
        else if (BranchMode.Longitude > 180) {
            alert("经度整数不能超过180");
            return false;
        } else {
            if (BranchMode.Longitude.split('.').length > 1) {
                if (BranchMode.Longitude.split('.')[1].length > 16) {
                    alert("经度小数位不能超过16位数");
                    return false;
                }
            }
        }
    }

    //当选为自定义密码 则密码不能为空且长度为6-20的数字或字母
    if ($("#DefaultPasswordY").is(":checked")) {

        if (BranchMode.DefaultPassword == "") {
            alert("密码不能为空");
            return false;
        }
        else if (BranchMode.DefaultPassword.length < 6 || BranchMode.DefaultPassword.length > 20) {

            alert("密码长度需为6-20");
            return false;
        }
    }

    if (BranchMode.Latitude == "") {
        alert("请输入纬度");
        return false;
    } else {
        if (isNaN(BranchMode.Latitude)) {
            alert("请输入数字");
            return false;
        }
        else if (BranchMode.Latitude > 90) {
            alert("纬度整数不能超过90");
            return false;
        } else {
            if (BranchMode.Latitude.split('.').length > 1) {
                if (BranchMode.Latitude.split('.')[1].length > 16) {
                    alert("经度小数位不能超过16位数");
                    return false;
                }
            }
        }
    }

    if (BranchMode.LostRemind == "") {

    } else {

        if (isNaN(BranchMode.LostRemind)) {
            alert("请输入数字");
            return false;
        }
    }

    if (BranchMode.ExpiryRemind == "") {

    } else {

        if (isNaN(BranchMode.ExpiryRemind)) {
            alert("请输入数字");
            return false;
        }
    }

    $.ajax({
        type: "POST",
        url: "/Branch/OperationBranch",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(BranchMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Branch/GetBranchList";
            }
            else
                alert(data.Message);
        }
    });
}


function isCanAddBranch() {
    $.ajax({
        type: "POST",
        url: "/Branch/IsCanAddBranch",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: null,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data) {
                window.location.href = "/Branch/EditBranch?BranchID=-1";
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
}


function selectAll(e, name) {
    var checked = $(e).prop("checked");
    $("#" + name + " [name='object_chk']").prop("checked", checked);
}

function CommoditySubmit(branchId, Type) {
    var ObjectList = new Array();

    var result = true;
    $("#tbCommodity tr").each(function () {
        if (!result) {
            return;
        }
        var OperateSign = "";
        switch ($(this).find("[name='object_OperateType']").val()) {
            case "1":
                OperateSign = "+";
                break;
            case "2":
                OperateSign = "-";
                break;
            case "3":
                OperateSign = "=";
                break;
        }
        var ObjectDetail = {
            ObjectID: $(this).attr("oId"),
            Available: $(this).find("[name='object_chk']").prop("checked"),
            OperateType: $(this).find("[name='object_OperateType']").val(),
            OperateSign: OperateSign,
            OperateQty: $(this).find("[name='object_Qty']").val(),
            StockCalcType: $(this).find("[name='object_StockCalcType']").val(),
            StockID: $(this).attr("sId"),
            BuyingPrice: $(this).find("[name='object_BuyPrice']").val(),
            InsuranceQty: $(this).find("[name='object_InsuranceQty']").val(),
            Remark: $(this).find("[name='object_Remark']").val()
        }
        if (ObjectDetail.OperateType != "0" && ObjectDetail.OperateQty == "") {
            alert("请输入操作库存数！");
            result = false;
            return;
        }

        if (isNaN(ObjectDetail.BuyingPrice)) {
            alert("库存单价请输入数字！");
            result = false;
            return;
        } else {
            if (ObjectDetail.BuyingPrice < 0) {
                alert("库存单价必须大于等于0！");
                result = false;
                return;
            }
        }

        if (isNaN(ObjectDetail.InsuranceQty)) {
            alert("安全库存请输入数字！");
            result = false;
            return;
        } else {
            if (ObjectDetail.InsuranceQty < 0) {
                alert("安全库存必须大于等于0！");
                result = false;
                return;
            }
            var ex = /^\d+$/;
            if (!ex.test(ObjectDetail.InsuranceQty)) {
                alert("安全库存请输入整数");
                result = false;
                return;

            }
        }

        ObjectList.push(ObjectDetail);
    });


    if (!result) {
        return;
    }

    var EditMarketRelationShipForBranch = {
        MarketType: Type,
        BranchID: branchId,
        EditList: ObjectList
    }

    $.ajax({
        type: "POST",
        url: "/Branch/EditMarketRelationShipForBranch",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(EditMarketRelationShipForBranch),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                location.href = "/Branch/GetBranchList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}




function ServiceSubmit(branchId, Type) {
    var ObjectList = new Array();

    $("#tbService tr").each(function () {
        var ObjectDetail = {
            ObjectID: $(this).attr("oId"),
            Available: $(this).find("[name='object_chk']").prop("checked")
        }
        ObjectList.push(ObjectDetail);
    });

    var EditMarketRelationShipForBranch = {
        MarketType: Type,
        BranchID: branchId,
        EditList: ObjectList
    }


    $.ajax({
        type: "POST",
        url: "/Branch/EditMarketRelationShipForBranch",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(EditMarketRelationShipForBranch),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                location.href = "/Branch/GetBranchList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}




function RangePriceSubmit(branchId) {

    var strRange = $.trim($("#txtRangePrice").val());

    if (strRange == "") {
        alert("价格区间设定不能为空")
        return;
    } else {
        re = new RegExp("\n", "g");
        strRange = strRange.replace(re, "|");

        var array = strRange.split("|");
        var number = new RegExp("^[0-9]*$");

        var result = true;

        for (var i = 0; i < array.length; i++) {
            if (!number.test(array[i])) {
                result = false;
            }
        }

        if (!result) {
            alert("价格区间输入不合法");
            return;
        }

        strRange = "|" + strRange + "|";
    }

    var RangePrice = {
        PriceRangeValue: strRange,
        BranchID: branchId,
        PriceRangeName: "默认"
    }


    $.ajax({
        type: "POST",
        url: "/Branch/EditPriceRange",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(RangePrice),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                location.href = "/Branch/GetBranchList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function UpdateAccountSort(BranchID) {
    var SortList = new Array();
    var num = 0;
    var newSort = "";
    $("#foo tr").each(function () {
        num += 1;
        var UserID = $(this).attr("aId");
        newSort += "|" + UserID;
        var Sort = {
            UserID: UserID,
            SortID: num
        }
        SortList.push(Sort);
    });
    var oldSort = $("#hidoldSortID").val();
    if (newSort == oldSort) {
        alert("排序没改变");
        return false;
    }
    var AccountSort = {
        ID: BranchID,
        ListAccountSort: SortList
    }

    $.ajax({
        type: "POST",
        url: "/Branch/EditAccountSort",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(AccountSort),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data) {
                alert(data.Message);
                location.href = "/Branch/GetBranchList";
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
}


function WXUpload() {
    $.ajaxFileUpload
  (
      {
          url: '/File/WXFileUpload', //用于文件上传的服务器端请求地址
          secureuri: false, //一般设置为false
          fileElementId: 'WXfileInput', //文件上传空间的id属性  <input type="file" id="file" name="file" />
          dataType: 'json', //返回值类型 一般设置为json
          success: function (data)  //服务器成功响应处理函数
          {
              if (data.Status == 1) {
                  alert("上传成功")
              }
          },
          error: function (data, status, e)//服务器响应失败处理函数
          {
              alert(e);
          }
      }
  )
}