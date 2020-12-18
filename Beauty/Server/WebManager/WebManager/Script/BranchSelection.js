/// <reference path="../assets/js/jquery-2.0.3.min.js" />
function getBranchSelectList(ID, Type, Url) {
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
        ObjectID: ID,
        ObjectType: Type,
        BranchList: BranchIDList
    };

    $.ajax({
        type: "POST",
        url: "/Shared/OperationBranchSelect",
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
                if ($.trim(Url) == "") {
                    if (Type == 1) {
                        location.href = "/Account/GetAccountList?BranchID=-1&Available=-1";
                    } else if (Type == 2) {
                        location.href = "/Promotion/GetPromotionList";
                    }
                }
                else {
                    location.href = Url;
                }
            }
            else
                alert(data.Message);
        }
    });

}


function selectAll(e, accountId) {
    if ($(e).is(":checked")) {
        $('input[type="checkbox"][name="imgBranchID"]').prop("checked", true);
    } else {
        var OperationMode = {
            UserID: accountId,
            BranchID: 0
        };

        $.ajax({
            type: "POST",
            url: "/Shared/AccountBranchCheck",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(OperationMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    $('input[type="checkbox"][name="imgBranchID"]').prop("checked", false);
                }
                else {
                    alert(data.Message);
                    $(e).prop("checked", true);
                }
            }
        });
    }
}

function checkAccount(e, branchId, accountId) {
    if (!$(e).is(":checked")) {
        var OperationMode = {
            UserID: accountId,
            BranchID: branchId
        };

        $.ajax({
            type: "POST",
            url: "/Shared/AccountBranchCheck",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(OperationMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                }
                else {
                    alert(data.Message);
                    $(e).prop("checked", true);
                }
            }
        });
    }
}

function goBack(Type, Url) {
    if ($.trim(Url) == "") {
        if (Type == 1) {
            location.href = "/Account/GetAccountList?BranchID=-1&Available=-1";
        } else {
            location.href = "/Promotion/GetPromotionList";
        }
    } else {
        location.href = Url;
    }

}