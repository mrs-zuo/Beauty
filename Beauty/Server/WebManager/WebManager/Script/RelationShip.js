/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    var type = $.getUrlParam('Type');
    if (type != null) {
        $('#ddlType').val(type);
    }

    getAccountList1();
    getCustomerList(0);
})

function getCustomerList(accountID) {
    $("#hidData").data("Customer", "");
    var UtilityOperation = {
        BranchID: $("#ddlBranch").val(),
        AccountID: accountID,
        Type:$("#ddlType").val()
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
                showCustomerList();
            }
        }
    });
}

function getAccountList1() {

    $("#hidData").data("Account1", "");
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
                $("#txtSearchAccount1").val("");
                $("#hidData").data("Account1", data.Data);
                showAccountList1();
            }
        }
    });
}

function getAccountList2() {

    $("#hidData").data("Account2", "");
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
                $("#txtSearchAccount2").val("");
                $("#hidData").data("Account2", data.Data);
                showAccountList2();
            }
        }
    });
}

function getRelationShip(CustomerId) {
    $("#hidData").data("Account2", "");
    var UtilityOperation = {
        BranchID: $("#ddlBranch").val(),
        CustomerID: CustomerId,
        Type: $("#ddlType").val()
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
                $("#txtSearchAccount2").val("");
                $("#hidData").data("Account2", data.Data);
                showAccountList2();
            }
        }
    });
}

function showAccountList1() {
    var strSearch = $("#txtSearchAccount1").val().toLowerCase();
    var jsonAccount = $("#hidData").data("Account1");
    $("#tbAccount1 tr").remove();
    var cnt = 0;
    for (var i = 0; i < jsonAccount.length; i++) {
        if (strSearch == "" || jsonAccount[i].SearchOut.toLowerCase().indexOf(strSearch) > -1) {
            $("#tbAccount1").append('<tr cid=' + jsonAccount[i].AccountID + ' class="" onclick="getCustomerList(' + jsonAccount[i].AccountID + ')"><td>' + jsonAccount[i].SearchOut + '</td></tr>');
            cnt++;
        }
    }
    $("#AccountCnt1").text(cnt);
}

function showAccountList2() {
    var strSearch = $("#txtSearchAccount2").val().toLowerCase();
    var jsonAccount = $("#hidData").data("Account2");
    $("#tbAccount2 tr").remove();
    var cnt = 0;
    for (var i = 0; i < jsonAccount.length; i++) {
        if (strSearch == "" || jsonAccount[i].SearchOut.toLowerCase().indexOf(strSearch) > -1) {
            if (jsonAccount[i].Available) {
                $("#tbAccount2").append('<tr><td><label class="btn-group no-p no-m"><input type="radio" checked="checked" name="chkAccount" value="' + jsonAccount[i].AccountID + '"><span class="over-text text">' + jsonAccount[i].SearchOut + '</span></label></td></tr>');
            } else {
                $("#tbAccount2").append('<tr><td><label class="btn-group no-p no-m"><input type="radio" name="chkAccount" value="' + jsonAccount[i].AccountID + '"><span class="over-text text">' + jsonAccount[i].SearchOut + '</span></label></td></tr>');
            }
            cnt++;
        }
    }
    $("#AccountCnt2").text(cnt);
}

function showCustomerList() {
    var jsonCustomer = $("#hidData").data("Customer");
    $("#tbCustomer tr").remove();

    var cnt = 0;
    var strSearch = $("#txtSearchCustomer").val().toLowerCase();
    for (var i = 0; i < jsonCustomer.length; i++) {
        if (strSearch == "" || jsonCustomer[i].SearchOut.toLowerCase().indexOf(strSearch) > -1) {
            $("#tbCustomer").append('<tr cid=' + jsonCustomer[i].UserID + ' class="" onclick="getRelationShip(' + jsonCustomer[i].UserID + ')"><td><label class="btn-group no-p no-m"><input type="checkbox" checked="checked" name="chkCustomer" value="' + jsonCustomer[i].UserID + '"><span class="over-text text">' + jsonCustomer[i].SearchOut + '</span></label></td></tr>');
            cnt++;
            if (cnt == 1) {
                getRelationShip(jsonCustomer[i].UserID);
            }
        }
    }
    $("#CustomerCnt").text(cnt);
    $("#hidData").data("selectAll", "1"); 
}

function changeBranch() {
    getAccountList1();
    getCustomerList();
}


//function selectAccount(e) {
//    if ($("#selectCustomerId").val() == "") {
//        alert("请先选择客户");
//        $(e).attr("checked", false)
//        return false;
//    } else {
//        var type = $("#ddlType").val();
//        var check = $(e).prop("checked");
//        if (type == 1) {
//            if (check) {
//                var selectList = new Array();
//                selectList.push($(e).val());
//                $("#hidData").data("selectedAccount", selectList);
//            } else {
//                $("#hidData").data("selectedAccount", "");
//            }
//            $('input[type="checkbox"][name="chkAccount"]:checked').attr("checked", false);
//            $(e).prop("checked", check);
//        } else {
//            var selectList;
//            if ($("#hidData").data("selectedAccount") == "") {
//                selectList = new Array();
//            } else {
//                selectList = $("#hidData").data("selectedAccount");
//            }
//            if (check) {
//                if (selectList.length > 0) {
//                    var IsPush = true;
//                    for (var i = 0; i < selectList.length; i++) {
//                        if (selectList[i] == $(e).val()) {
//                            IsPush = false;
//                        }
//                    }
//                    if (IsPush) {
//                        selectList.push($(e).val());
//                    }
//                } else {
//                    selectList.push($(e).val());
//                }
              
//                $("#hidData").data("selectedAccount", selectList);
//            } else {
//                if (selectList == "") {
//                    $("#hidData").data("selectedAccount", "");
//                } else {
//                    for (var i = 0; i < selectList.length; i++) {
//                        if (selectList[i] == $(e).val()) {
//                            selectList.splice(i,1);
//                        }
//                    }
//                    $("#hidData").data("selectedAccount", selectList);
//                }
              
//            }
//            $(e).prop("checked", check);
//        }
//    }
//}

//function getCustomerByAccountName() {
//    $("#hidData").data("Customer", "");
//    $("#hidData").data("relationFlg", "");
//    $("#hidData").data("selectedAccount", "");
//    var type = $("#ddlType").val();
//    var UtilityOperation = {
//        BranchID: $("#ddlBranch").val(),
//        InputSearch: $.trim($("#txtInputSearch").val()),
//        Type: type
//    };

//    $.ajax({
//        type: "POST",
//        url: "/RelationShip/GetCustomerListByAccountName",
//        contentType: "application/json; charset=utf-8",
//        dataType: "json",
//        data: JSON.stringify(UtilityOperation),
//        async: false,
//        error: function (XMLHttpRequest, textStatus, errorThrown) {
//            location.href = "/Home/Index?err=2";
//        },
//        success: function (data) {
//            if (data.Code == "1") {
//                $("#txtSearchCustomer").val("");
//                if (UtilityOperation.InputSearch == "" || type == 2) {
//                    $("#mutiSelect").val("0");
//                } else {
//                    $("#mutiSelect").val("1");
//                }
//                $("#selectCustomerId").val("");
//                $("#hidData").data("Customer", data.Data);
//                showCustomerList(1);
//            }
//        }
//    });
//}

function submit() {
    var CustomerList = new Array();
    obj = document.getElementsByName("chkCustomer");
    for (k in obj) {
        if (obj[k].checked) {
            CustomerList.push(obj[k].value);
        }
    }

    if (CustomerList == null) {
        alert("请先选择客户");
        return false;
    }

    var AccountList = new Array();
    obj = document.getElementsByName("chkAccount");
    for (k in obj) {
        if (obj[k].checked) {
            AccountList.push(obj[k].value);
        }
    }

    var RelationShipOperation = {
        BranchID: $("#ddlBranch").val(),
        listSubmitAccountID: AccountList,
        listCustomerID: CustomerList,
        Type: $("#ddlType").val()
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
    $("#txtSearchCustomer").val("");
    $("#txtSearchAccount1").val("");
    $("#txtSearchAccount2").val("");
    getCustomerList();
    getAccountList1();
}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function selectAllCustomer() {
    if ($("#hidData").data("selectAll") == "1") {
        $("#hidData").data("selectAll", "0");
        $("[name='chkCustomer']").removeAttr("checked");
    }
    else {
        $("#hidData").data("selectAll", "1");
        $("[name='chkCustomer']").prop("checked", 'true');
    }
}

function showAllCustomer() {
    getCustomerList(0);
}