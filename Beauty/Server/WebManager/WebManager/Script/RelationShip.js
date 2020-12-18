/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    var type = $.getUrlParam('Type');
    if (type != null) {
        $('#ddlType').val(type);
    }

    getCustomerList();
    getAccountList();
    $("#mutiSelect").val("0");
    $("#selectCustomerId").val("");
})

function getCustomerList() {
    $("#hidData").data("Customer", "");
    var UtilityOperation = {
        BranchID: $("#ddlBranch").val()
    };

    $.ajax({
        type: "POST",
        url: "/RelationShip/GetCustomerList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#txtSearchCustomer").val("");
                $("#hidData").data("Customer", data.Data);
                showCustomerList(0);
            }
        }
    });
}

function getAccountList() {

    $("#hidData").data("Account", "");
    var UtilityOperation = {
        BranchID: $("#ddlBranch").val()
    };

    $.ajax({
        type: "POST",
        url: "/RelationShip/GetAccountList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#txtSearchAccount").val("");
                $("#hidData").data("Account", data.Data);
                showAccountList(0, 0);
            }
        }
    });
}

function getRelationShip(CustomerId, e) {
    $("#hidData").data("selectedAccount","");
    var muti = $("#mutiSelect").val();
    var type = $("#ddlType").val();
    var selectCnt = 1;
    if (muti == "0") {
        $("#selectCustomerId").val("");
        $("#selectCustomerId").val(CustomerId);
        $("#tbCustomer tr").attr("class", "");
        $(e).addClass("selected");
        $("#hidData").data("relationFlg", "");
    } else {
        var temp = $("#selectCustomerId").val();
        if (temp != "") {
            selectCnt = 2;
            temp += "|" + CustomerId;
        } else {
            temp = CustomerId;
        }
        $("#selectCustomerId").val(temp);
        if ($(e).hasClass("selected")) {
            $(e).removeClass("selected");
        } else {
            $(e).addClass("selected");
        }
    }

    if (selectCnt == 1) {
        $("#hidData").data("Account", "");
        var UtilityOperation = {
            BranchID: $("#ddlBranch").val(),
            CustomerID: CustomerId,
            Type: type
        };

        $.ajax({
            type: "POST",
            url: "/RelationShip/GetRelationShipList",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(UtilityOperation),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Code == "1") {
                    $("#txtSearchAccount").val("");
                    $("#hidData").data("Account", data.Data);
                    initSelectAccount();
                    showAccountList(0, 1);
                }
            }
        });
    }
}

function showAccountList(searchFlg, relationFlg) {
    if ($("#selectCustomerId").val() == "" && searchFlg == 1) {
        alert("请先选择客户");
        $("#txtSearchAccount").val("");
        return false;
    }

    var strSearch = $("#txtSearchAccount").val();
    var type = $("#ddlType").val();
    var selectList = new Array();
    if (searchFlg == 1) {
        selectList =  $("#hidData").data("selectedAccount");
    }

    var jsonAccount = $("#hidData").data("Account");
    $("#tbAccount tr").remove();
    for (var i = 0; i < jsonAccount.length; i++) {
        if (searchFlg == 0) {
            if (jsonAccount[i].Available) {
                $("#tbAccount").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" checked="checked" onclick="selectAccount(this)" name="chkAccount" value="' + jsonAccount[i].AccountID + '"><span class="over-text text">' + jsonAccount[i].AccountName + '</span></label></td></tr>');
                if (relationFlg == 1) {
                    $("#hidData").data("relationFlg", "true");
                }
            } else {
                $("#tbAccount").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" name="chkAccount" onclick="selectAccount(this)" value="' + jsonAccount[i].AccountID + '"><span class="over-text text">' + jsonAccount[i].AccountName + '</span></label></td></tr>');
            }
        } else {
            if (jsonAccount[i].SearchOut.indexOf(strSearch) > -1) {
                var Re = false;
                for (var j = 0; j < selectList.length; j++) {
                    if (jsonAccount[i].AccountID == selectList[j]) {
                        Re = true;
                        break;
                    }
                }
                if (Re) {
                    $("#tbAccount").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" checked="checked" onclick="selectAccount(this)" name="chkAccount" value="' + jsonAccount[i].AccountID + '"><span class="over-text text">' + jsonAccount[i].AccountName + '</span></label></td></tr>');
                } else {
                    $("#tbAccount").append('<tr><td><label class="btn-group no-p no-m"><input type="checkbox" name="chkAccount" onclick="selectAccount(this)" value="' + jsonAccount[i].AccountID + '"><span class="over-text text">' + jsonAccount[i].AccountName + '</span></label></td></tr>');
                }
            }
        }
    }

    $("#AccountCnt").text(jsonAccount.length);

}

function showCustomerList(relationFlg) {

    var jsonCustomer = $("#hidData").data("Customer");
    $("#tbCustomer tr").remove();

    if (jsonCustomer.length > 0 && relationFlg == 1) {
        $("#hidData").data("relationFlg", "true");
    }

    for (var i = 0; i < jsonCustomer.length; i++) {
        if ($("#txtSearchCustomer").val() == "") {
            $("#tbCustomer").append('<tr cid=' + jsonCustomer[i].UserID + ' class="" onclick="getRelationShip(' + jsonCustomer[i].UserID + ',this)"><td>' + jsonCustomer[i].Name + '</td></tr>');
        } else {
            var strSearch = $("#txtSearchCustomer").val();
            if (jsonCustomer[i].SearchOut.indexOf(strSearch) > -1) {
                $("#tbCustomer").append('<tr cid=' + jsonCustomer[i].UserID + ' class="" onclick="getRelationShip(' + jsonCustomer[i].UserID + ',this)"><td>' + jsonCustomer[i].Name + '</td></tr>');
            }
        }
    }


    $("#CustomerCnt").text(jsonCustomer.length);
}

function changeBranch() {
    getCustomerList();
    getAccountList();
}


function selectAccount(e) {
    if ($("#selectCustomerId").val() == "") {
        alert("请先选择客户");
        $(e).attr("checked", false)
        return false;
    } else {
        var type = $("#ddlType").val();
        var check = $(e).prop("checked");
        if (type == 1) {
            if (check) {
                var selectList = new Array();
                selectList.push($(e).val());
                $("#hidData").data("selectedAccount", selectList);
            } else {
                $("#hidData").data("selectedAccount", "");
            }
            $('input[type="checkbox"][name="chkAccount"]:checked').attr("checked", false);
            $(e).prop("checked", check);
        } else {
            var selectList;
            if ($("#hidData").data("selectedAccount") == "") {
                selectList = new Array();
            } else {
                selectList = $("#hidData").data("selectedAccount");
            }
            if (check) {
                if (selectList.length > 0) {
                    var IsPush = true;
                    for (var i = 0; i < selectList.length; i++) {
                        if (selectList[i] == $(e).val()) {
                            IsPush = false;
                        }
                    }
                    if (IsPush) {
                        selectList.push($(e).val());
                    }
                } else {
                    selectList.push($(e).val());
                }
              
                $("#hidData").data("selectedAccount", selectList);
            } else {
                if (selectList == "") {
                    $("#hidData").data("selectedAccount", "");
                } else {
                    for (var i = 0; i < selectList.length; i++) {
                        if (selectList[i] == $(e).val()) {
                            selectList.splice(i,1);
                        }
                    }
                    $("#hidData").data("selectedAccount", selectList);
                }
              
            }
            $(e).prop("checked", check);
        }
    }
}

function getCustomerByAccountName() {
    $("#hidData").data("Customer", "");
    $("#hidData").data("relationFlg", "");
    $("#hidData").data("selectedAccount", "");
    var type = $("#ddlType").val();
    var UtilityOperation = {
        BranchID: $("#ddlBranch").val(),
        InputSearch: $.trim($("#txtInputSearch").val()),
        Type: type
    };

    $.ajax({
        type: "POST",
        url: "/RelationShip/GetCustomerListByAccountName",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#txtSearchCustomer").val("");
                if (UtilityOperation.InputSearch == "" || type == 2) {
                    $("#mutiSelect").val("0");
                } else {
                    $("#mutiSelect").val("1");
                }
                $("#selectCustomerId").val("");
                $("#hidData").data("Customer", data.Data);
                showCustomerList(1);
            }
        }
    });
}

function submit() {

    var CustomerList = new Array();

    $('#tbCustomer tr').each(function () {
        if ($(this).hasClass("selected")) {
            var id = $(this).attr("cid");
            CustomerList.push(id);
        }
    });

    if (CustomerList == null) {
        alert("请先选择客户");
        return false;
    }

    var accountId = 0;
    var type = $("#ddlType").val();
    var AccountList = new Array();

    var selectList =  $("#hidData").data("selectedAccount");

    for(var i = 0; i<selectList.length;i++){
        accountId = selectList[i];
        AccountList.push(selectList[i]);
    };


    var relationFlg = $("#hidData").data("relationFlg");

    if (accountId == 0 && relationFlg == "") {
        alert("当前数据未改变");
        return false;
    }
    var RelationShipOperation = {
        BranchID: $("#ddlBranch").val(),
        listSubmitAccountID: AccountList,
        listCustomerID: CustomerList,
        Type: type
    };

    $.ajax({
        type: "POST",
        url: "/RelationShip/ChangeRelationShip",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(RelationShipOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                location.href = "/RelationShip/EditRelationShip?Type=" + type;
            } else {
                alert(data.Message);
            }
        }
    });

}

function changeType() {
    $("#mutiSelect").val("0");
    $("#selectCustomerId").val("");
    $("#txtSearchCustomer").val("");
    $("#txtSearchAccount").val("");
    $("#txtInputSearch").val("");
    $("#hidData").data("selectedAccount", "");
    getCustomerList();
    getAccountList();
}
(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);


function initSelectAccount() {
    var jsonAccount = $("#hidData").data("Account");
    var selectList = new Array();
    for (var i = 0; i < jsonAccount.length; i++) {
        if (jsonAccount[i].Available) {
            selectList.push(jsonAccount[i].AccountID);
        }
    }
    
    $("#hidData").data("selectedAccount", selectList);
}