/// <reference path="../assets/js/jquery-2.0.3.min.js" />
(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function EditBenefit(PolicyID) {
   var BenefitMode = {
       PolicyID: PolicyID,
       PolicyName:  $.trim($('#txtPolicyName').val()),
       PolicyType: $.trim($('#ddlPolicyType').val()),
       PolicyActType: $.trim($('#ddlPolicyActType').val()),
       PolicyActPosition: $.trim($('#ddlPolicyActPosition').val()),
       StartDate: $.trim($('#txtstartDate').val()),
       Amount: $.trim($('#txtAmount').val()),
       PRCode: $.trim($('#ddlPRCode').val()),
       PRValue1: $.trim($('#txtPRValue1').val()),
       PRValue2: $.trim($('#txtPRValue2').val()),
       ValidDays: $.trim($('#txtValidDays').val()),
       PolicyDescription: $.trim($('#txtPolicyDescription').val()),
       PolicyComments: $.trim($('#txtPolicyComments').val())
   };

   if (BenefitMode.PolicyName == "") {
       alert("优惠政策名称不能为空");
       return;
   }



   if (BenefitMode.StartDate == "") {
       alert("政策实施起始日期不能为空");
       return;
   }

   if (BenefitMode.ValidDays == "") {
       alert("政策实施起始日期不能为空");
       return;
   } else {
       if (isNaN(BenefitMode.ValidDays)) {
           alert("有效天数必须是数字!")
           return false;
       } else if (BenefitMode.ValidDays < 0) {
           alert("有效天数不能小于0!")
           return false;
       }
   }


   if (BenefitMode.PRValue1 == "") {
       alert("满足金额不能为空");
       return;
   } else {
       if (isNaN(BenefitMode.PRValue1)) {
           alert("满足金额必须是数字!")
           return false;
       } else if (BenefitMode.PRValue1 <= 0) {
           alert("满足金额必须大于0!")
           return false;
       }
   }


   if (BenefitMode.PRValue2 == "") {
       alert("抵扣金额不能为空");
       return;
   } else {
       if (isNaN(BenefitMode.PRValue2)) {
           alert("抵扣金额必须是数字!")
           return false;
       } else if (BenefitMode.PRValue2 <= 0) {
           alert("抵扣金额必须大于0!")
           return false;
       }
   }

    $.ajax({
        type: "POST",
        url: "/Benefit/SubmitBenefit",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(BenefitMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                if (PolicyID == "") {
                    location.href = "/Benefit/EditBenefit?f=1&active=1&pd=" + data.Data;
                } else {
                    location.href = "/Benefit/GetBenefitList";
                }
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
        url: "/Benefit/OperationBranchSelect",
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
                location.href = "/Benefit/GetBenefitList";
            }
            else
                alert(data.Message);
        }
    });
}


function delBenefit(policyId){
    var BenefitMode = {
        PolicyID: policyId
    };

    $.ajax({
        type: "POST",
        url: "/Benefit/DeteleBenefitPolicy",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(BenefitMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Benefit/GetBenefitList?bId=" + $("#ddl_branchID").val();
            }
            else
                alert(data.Message);
        }
    });
}