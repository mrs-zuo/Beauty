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
                        //$("#validateCode").focus();
                    }
                    break;
                    //case "txtValidateInput":
                    //    loginSumbit();
                    //    break;
            }
        }
    }
})

function loginSumbit() {

    if ($("#loginMobile").val() == "") {
        alert("请输入登陆手机");
        return false;
    }


    if ($("#password").val() == "") {
        alert("请输入登陆密码");
        return false;
    }

    var urlPath = $("#hidUrlPath").val()

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
                    break;
                case "1":
                    if (urlPath == "" || urlPath == "/") {
                        window.location.href = "/Home/index";
                    }
                    else {
                        window.location.href = urlPath;
                    }
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

function BindSumbit() {

    if ($("#loginMobile").val() == "") {
        alert("请输入登陆手机");
        return false;
    }


    if ($("#password").val() == "") {
        alert("请输入登陆密码");
        return false;
    }

    var urlPath = $("#hidUrlPath").val()
    var param = '{"loginMobile":"' + $("#loginMobile").val() + '","password":"' + $("#password").val() + '","validateCode":"' + $("#validateCode").val() + '","needRSAEncrypt":true}';
    $.ajax({
        type: "POST",
        url: "/Login/BindWeChatOpenID",
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
                    break;
                case "1":
                    if (urlPath == "" || urlPath == "/") {
                        window.location.href = "/Home/index";
                    }
                    else {
                        window.location.href = urlPath;
                    }
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

function Login() {

    if ($("#selCompany").val() == "选择公司") {
        alert("请选择公司");
        return;
    }

    var LoginModel = {
        CompanyIndex: $("#selCompany").val(),
    };

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
            if (data.Data && data.Code == "1") {
                window.location.href = "/Home/index";
            }
            else {
                alert(data.Message);
            }
        }
    });
}