/// <reference path="../assets/js/jquery-2.0.3.min.js" />

//--下拉选择菜单--

$(function () {
    $("#divSelectCompany").hide();



    document.onkeydown = function (e) {
        var ev = document.all ? window.event : e;
        var srcelement = ev.srcElement || ev.target;

        if (ev.keyCode == 13) {
            switch (srcelement.id) {
                default:
                    loginSumbit();//处理事件
                    break;
                case "txtLoginUserName":
                    if ($("#loginMobile").val().trim() == "") {
                        alert("请输入用户名！");
                    }
                    else {
                        $("#password").focus();
                    }
                    break;
                case "txtPassWord":
                    if ($("#divSelectCompany").css("display") == "none") {
                        loginSumbit();//处理事件
                    }
                    else {
                        $("#validateCode").focus();
                    }
                    break;
                case "txtValidateInput":
                    loginSumbit();
                    break;
            }
        }
    }
})

//$("#e1").select2();
//$("#e2").select2({
//    placeholder: "Select a State",
//    allowClear: true
//});

function selectCompany() {

    $("#selBranch option:not(:first)").remove();
    var company = parseInt($("#selCompany").select().val());
    var branchList = $.parseJSON($("#hid_CompanyList").val())[company].BranchList;

    if (branchList != null && branchList.length > 0) {
        var strOps = "";
        for (var i = 0; i < branchList.length; i++) {
            strOps += "<option value = '" + i + "'" + " >" + (branchList[i].BranchID == 0 ? "总部" : branchList[i].BranchName);
        }
        $("#selBranch").append(strOps);
    }
}

function Login() {

    if ($("#selCompany").val() == "选择公司") {
        alert("请选择公司");
        return;
    }

    if ($("#selBranch").val() == "选择门店") {
        alert("请选择门店");
        return;
    }

    var LoginModel = {
        CompanyIndex: $("#selCompany").val(),
        BranchIndex: $("#selBranch").val()
    };

    //param = '{"CompanyIndex":'+$("#e1").val() +",'BranchIndex':"+$("#e2").val()+'}';
    $.ajax({
        type: "POST",
        url: "/Login/selectCompany",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(LoginModel),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络繁忙,请稍后再登！");
        },
        success: function (data) {
            if (data.Data && data.Code == "1")
                window.location.href = "/Home/index";
            else
                alert(data.Message);
        }
    });
}


function resetValidateCode() {
    $("#imgValidateCode").attr("src", "/Login/ValidateCode?time=" + (new Date()).getTime());
}

function loginSumbit() {

    if ($("#loginMobile").val() == "") {
        alert("请输入登录手机");
        return false;
    }


    if ($("#password").val() == "") {
        alert("请输入登录密码");
        return false;
    }


    var param = '{"loginMobile":"' + $("#loginMobile").val() + '","password":"' + $("#password").val() + '","validateCode":"' + $("#validateCode").val() + '","needRSAEncrypt":true}';
    $.ajax({
        type: "POST",
        url: "/Login/getCompanyList",
        contentType: "application/json; charset=utf-8",
        dataType: "text",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络繁忙,请稍后再登！");
        },
        success: function (data) {
            switch (data) {
                case "-2":
                    alert("请输入正确的验证码！");
                    resetValidateCode();
                    break;
                case "-1":
                    alert("网络繁忙,请稍后再登！");
                    break;
                case "0":
                    alert("请输入正确的用户名和密码！");
                    window.location.href = "/";
                    break;
                case "1":
                    window.location.href = "/Home/index";
                    break;
                case "2":
                    window.location.href = "/Login/select";
                    break;
                default:
                    window.location.href = "/Login/Login?err=2";
                    break;

            }
        }
    });
}