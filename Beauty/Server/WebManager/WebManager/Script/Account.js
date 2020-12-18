/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    var currentBranchId = $.getUrlParam('BranchID');
    var currentAvailable = $.getUrlParam('Available');
    var currentInputSearch = $.getUrlParam('InputSearch') != null ? decodeURI($.getUrlParam('InputSearch')) : null;
    if (currentBranchId != null) {
        $('#ddl_branchID').val(currentBranchId);
    }
    if (currentAvailable != null) {
        $('#ddl_flag').val(currentAvailable);
    }
    if (currentInputSearch != null) {
        $('#txtInputSearch').val(currentInputSearch);
    }
    getAccountListUsedByGroup();
});

function SearchAccount() {
    var branchId = $("#ddl_branchID").val();
    var Available = $("#ddl_flag").val();
    var inputSearch = encodeURI(encodeURI($.trim($("#txtInputSearch").val())));


    window.location.href = "/Account/GetAccountList?BranchID=" + branchId + "&Available=" + Available + "&InputSearch=" + inputSearch;
}

function Submit(UserId, selectBranchId, RoleSelect) {
    var result = true;
    var TagsIDList = new Array();
    var newTagList = "";
    $('input[type="checkbox"][name="chk_tags"]:checked').each(function () {
        newTagList += "|" + this.value;
        var TagsModel = {
            TagID: this.value
        }
        TagsIDList.push(TagsModel);
    });

    if ($("#hid_oldTags").val() == newTagList) {
        TagsIDList = null;
    }

    var AccountMode = {
        IsRecommend: $("#IsRecommendY").is(":checked"),
        Available: $("#AvailableY").is(":checked"),
        Mobile: $.trim($("#txtAccountMobile").val()),
        Password: $.trim($("#txtAccountPwd").val()),
        Code: $.trim($("#txtAccountCode").val()),
        Name: $.trim($("#txtAccountName").val()),
        RoleID: RoleSelect ? $("#ddlRole").val() : -2,
        Title: $.trim($("#txtAccountTitle").val()),
        Expert: $.trim($("#txtAccountExpert").val()),
        Introduction: $.trim($("#txtAccountIntro").val()),
        //Department: $.trim($("#txtAccountDepartment").val()),
        TagsList: TagsIDList,
        HeadImageFile: getThumbImage(),
        UserID: UserId,
        CommissionRate: $.trim($("#txtCommissionRateWeb").val()),
        IssuedDate: $.trim($("#txtStaffIssuedDate").val())
    };

    if ($("#AvailableD").is(":checked")) {
        if (confirm("删除的员工不能恢复，且无法再建立相同登录账号的员工，是否继续？")) {
            AccountMode.Available = 2;
        }
        else {
            return false;
        }
    }

    if (isNaN(AccountMode.CommissionRate)) {
        alert("销售顾问提成比例必须输入数字");
        return false;
    }
    /*if (AccountMode.IssuedDate != null && AccountMode.IssuedDate != "") {
        var today = new Date();
        var sTime = AccountMode.IssuedDate.replace("-", "/");
        sTime = sTime.replace("-", "/");
        today = today.getFullYear() + "/" + (parseInt(today.getMonth()) + 1) + "/" + today.getDate() + " " + today.getHours() + ":" + today.getMinutes();
        var result = (Date.parse(sTime) - Date.parse(today)) / 86400000;
        if (result < 0) {
            alert("销售顾问提成比例生效日期不能小于今天!");
            return false;
        }
    }*/
    if (AccountMode.Mobile == "") {
        alert("登录账号不能为空");
        return false;
    } else {
        if (AccountMode.Mobile.length < 8 || AccountMode.Mobile.length > 13) {
            alert("登录账号必须8到13位");
            return false;
        }


        if (isNaN(AccountMode.Mobile)) {
            alert("登录账号必须是数字!")
            return false;
        }

        $.ajax({
            type: "POST",
            url: "/Account/IsExsitAccountMobileInCompany",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(AccountMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    if (data.Data) {
                        {
                            alert(data.Message);
                            result = false;
                        }
                    }
                }
            }
        });

    }

    if (!result) {
        return false;
    }
    if (UserId <= 0) {
        if (AccountMode.Password == "") {
            alert("密码不能为空");
            return false;
        } else {
            if (AccountMode.Password.length < 6) {
                alert("密码不能小于6位");
                return false;
            }
        }
    }

    if (AccountMode.Name == "") {
        alert("用户名不能为空");
        return false;
    } else {
        $.ajax({
            type: "POST",
            url: "/Account/IsExsitAccountNameInCompany",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(AccountMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    if (data.Data) {
                        if (!window.confirm('名字有重复,确定提交吗？')) {
                            result = false;
                        }
                    }
                }
            }
        });
    }
    if (!result) {
        return false;
    }
    if (UserId == 0) {
        $.ajax({
            type: "POST",
            url: "/Account/AddAccount",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(AccountMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data > 0 && data.Code == "1") {
                    alert(data.Message);
                    if (selectBranchId == 0) {
                        location.href = "/Account/EditAccount?UserID=" + data.Data + "&BranchSelect=1"
                    } else {
                        location.href = "/Account/GetAccountList?BranchID="+ selectBranchId+"&Available=-1"
                    }

                }
                else
                    alert(data.Message);
            }
        });
    } else {
        $.ajax({
            type: "POST",
            url: "/Account/UpdateAccount",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(AccountMode),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Account/EditAccount?UserID=" + UserId + "&BranchSelect=1"

                }
                else
                    alert(data.Message);
            }
        });
    }
}



function SubmitPassword(userId) {
    if (userId <= 0) {
        alert("异常");
        location.href = "/Account/GetAccountList?BranchID=-1&Available=-1";
    }

    var newPassword = $.trim($("#txtNewPassWord").val());
    if (newPassword.length < 6) {
        alert("密码不能小于6位");
        return;
    }
    if (newPassword.length > 20) {
        alert("密码不能大于20位");
        return;
    }
    var ConfirmPassword = $.trim($("#txtConfirmPassWord").val());
    if (newPassword != ConfirmPassword) {
        alert("两次输入的不一致");
        return;
    }
    var AccountMode = {
        UserID: userId,
        Password: newPassword
    };

    $.ajax({
        type: "POST",
        url: "/Account/ResetPassword",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(AccountMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Account/GetAccountList?BranchID=-1&Available=-1";
            }
            else
                alert(data.Message);
        }
    });

}

function TagsOk() {
    var CustomerIDList = new Array();
    var TagsName = "";
    var i = 0;
    $('input[type="checkbox"][name="chk_tags"]:checked').each(function () {
        if (i == 0) {
            TagsName = $(this).attr("TagName");
        }
        else {
            TagsName += "," + $(this).attr("TagName");
        }
        CustomerIDList.push(this.value);
        i++;
    });

    if (CustomerIDList.length > 0) {
        $("#txt_allTags").attr("placeholder", TagsName);
        $("#txt_allTags").val(TagsName);
        return;
    }
    else {
        $("#txt_allTags").val("");
        $("#txt_allTags").attr("placeholder", "点击选择分组");
        return;
    }
}

function delTag(ID) {
    var TagModel = {
        ID: ID,
        Type: 2
    };

    $.ajax({
        type: "POST",
        url: "/Account/DeleteTag",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(TagModel),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Account/GetAccountGroupList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function getAccountListUsedByGroup() {
    $.ajax({
        type: "POST",
        url: "/Account/GetAccountListUsedByGroup",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: null,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#txtSearchAccount").val("");
                $("#hidData").data("Account", data.Data);
                showAccountListUsedByGroup();
            }
        }
    });
}

function showAccountListUsedByGroup() {
    var jsonAccount = $("#hidData").data("Account");
    if (jsonAccount != null && jsonAccount.length > 0) {
        $("#tbAccount tr").remove();
        for (var i = 0; i < jsonAccount.length; i++) {
            if ($("#txtSearchAccount").val() == "") {
                $("#tbAccount").append('<tr id="ltr' + jsonAccount[i].AccountID + 'a" aname="' + jsonAccount[i].AccountName + '" class="" ><td><span class="text over-text col-xs-12 no-pm">' + jsonAccount[i].AccountName + '</span><a onclick="AddAccountToSelect(' + jsonAccount[i].AccountID + ')" style="cursor:pointer;display:block;"><i class="eag-plus fa fa-plus"></i></a></td></tr>');
            } else {
                var strSearch = $("#txtSearchAccount").val();
                if (jsonAccount[i].SearchOut.indexOf(strSearch) > -1) {
                    $("#tbAccount").append('<tr id="ltr' + jsonAccount[i].AccountID + 'a" aname="' + jsonAccount[i].AccountName + '" class=""><td><span class="text over-text col-xs-12 no-pm">' + jsonAccount[i].AccountName + '</span><a onclick="AddAccountToSelect(' + jsonAccount[i].AccountID + ')" style="cursor:pointer;display:block;"><i class="eag-plus fa fa-plus"></i></a></td></tr>');
                }
            }
        }
    }
}

function AddAccountToSelect(ID) {
    var aname = $("#ltr" + ID + "a").attr("aname");
    var rhtml = $("#tbAccountRight").html();
    if (rhtml.indexOf("rtr" + ID + "a") > -1) {
        alert(aname + "已经选择");
    }
    else {
        $("#tbAccountRight").append('<tr id="rtr' + ID + 'a" aname="' + aname + '" aid="' + ID + '"><td><span class="text over-text col-xs-12 no-pm">' + aname + '</span><a onclick="minusAccountToSelect(' + ID + ')" style="cursor:pointer;display:block;"><i class="eag-plus fa fa-minus"></i></a></td></tr>');
    }
}

function minusAccountToSelect(ID) {
    $("#rtr" + ID + "a").remove();
}

function AddTag() {
    var tagName = $.trim($("#txt_TagName").val());
    if (tagName == "") {
        alert("分组名字不能为空!");
        return;
    }

    var userList = new Array();
    $("#tbAccountRight tr").each(function () {
        var userDetail = {
            AccountID: $(this).attr("aid")
        }
        userList.push(userDetail);
    });

    var tagModel = {
        Name: tagName,
        UserList: userList,
        Type: 2
    }

    $.ajax({
        type: "POST",
        url: "/Account/AddTag",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(tagModel),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Account/GetAccountGroupList";
            }
            else {
                alert(data.Message);
            }
        }
    });

}

function EditTag(ID) {
    var tagName = $.trim($("#txt_TagName").val());
    if (tagName == "") {
        alert("分组名字不能为空!");
        return;
    }

    var userList = new Array();
    var oldUserList = $.trim($("#hid_oldUserList").val());
    var strUserList = "";
    $("#tbAccountRight tr").each(function () {
        strUserList += "|" + $(this).attr("aid")
        var userDetail = {
            AccountID: $(this).attr("aid")
        }
        userList.push(userDetail);
    });

    strUserList += "|";


    var oldTagName = $.trim($("#hid_TagName").val());
    if (oldTagName == tagName && oldUserList == strUserList) {
        alert("操作成功!");
        location.href = "/Account/GetAccountGroupList";
        return;
    }
    else {

        if (oldTagName == tagName) {
            tagName = "";
        }

        var tagModel = {
            Name: tagName,
            UserList: userList,
            Type: 2,
            ID: ID
        }

        $.ajax({
            type: "POST",
            url: "/Account/UpdateTag",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(tagModel),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Account/GetAccountGroupList";
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function isCanAddAccount() {
    $.ajax({
        type: "POST",
        url: "/Account/IsCanAddAccount",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: null,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data) {
                window.location.href = "/Account/EditAccount?UserID=-1&BranchSelect=0";
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
}

function OpenAccount() {
    $.ajax({
        type: "POST",
        url: "/Account/IsCanAddAccount",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: null,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data) {
                $("#AvailableY").prop("checked", "checked");
            }
            else {
                alert(data.Message);
                $("#AvailableN").prop("checked", "checked");
                return;
            }
        }
    });

}


function changeStatus(UserID) {
    $.ajax({
        type: "POST",
        url: "/Account/CanDeleteAccount",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"UserID":"' + UserID + '"}',
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                
            }
            else {
                alert(data.Message);
                $("#AvailableY").prop("checked", "checked");
                return;
            }
        }
    });
}


function getBranchSelectList(UserID) {
    var BranchIDList = new Array();
    var newBranch = "";
    $('input[type="checkbox"][name="imgBranchID"]:checked').each(function () {
        newBranch += "|" + this.value;
        var BranchMode = {
            BranchID: this.value,
            VisibleForCustomer: $(this).parent().parent().parent().find('[name="chkVisible"]').is(":checked")
        };
        BranchIDList.push(BranchMode);
    });

    var BranchSelectMode = {
        UserID: UserID,
        BranchList: BranchIDList
    };

    $.ajax({
        type: "POST",
        url: "/Account/OperationBranchSelect",
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
                location.href = "/Account/GetAccountList?BranchID=-1&Available=-1";
            }
            else
                alert(data.Message);
        }
    });
}


function checkAccount(e, branchId, accountId) {
    if (!$(e).is(":checked")) {
        var OperationMode = {
            UserID: accountId,
            BranchID: branchId
        };

        $.ajax({
            type: "POST",
            url: "/Account/AccountBranchCheck",
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


function selectAll(e) {
    var check = $(e).prop("checked");
    $("[name='imgBranchID']").prop("checked", check);
}