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

function loginSumbit(rsaE, rsaM) {

    if ($("#loginMobile").val() == "") {
        alert("请输入登陆手机");
        return false;
    }


    if ($("#password").val() == "") {
        alert("请输入登陆密码");
        return false;
    }

    var urlPath = $("#hidUrlPath").val();


    setMaxDigits(131);
    var key = new RSAKeyPair(rsaE, "", rsaM);
    var loginMobile = encryptedString(key, base64encode(strUnicode2Ansi($("#loginMobile").val())));
    var pwd = encryptedString(key, base64encode(strUnicode2Ansi($("#password").val())));

    var param = '{"loginMobile":"' + loginMobile + '","password":"' + pwd + '","validateCode":"' + $("#validateCode").val() + '","needRSAEncrypt":true}';
    $.ajax({
        type: "POST",
        url: "/Login/getCompanyList",
        contentType: "application/json; charset=utf-8",
        dataType: "text",
        data: param,
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

function BindSumbit(rsaE,rsaM) {

    if ($("#loginMobile").val() == "") {
        alert("请输入登陆手机");
        return false;
    }


    if ($("#password").val() == "") {
        alert("请输入登陆密码");
        return false;
    }

    setMaxDigits(131);
    var key = new RSAKeyPair(rsaE, "", rsaM);
    var loginMobile = encryptedString(key, base64encode(strUnicode2Ansi($("#loginMobile").val())));
    var pwd = encryptedString(key, base64encode(strUnicode2Ansi($("#password").val())));

    var urlPath = $("#hidUrlPath").val()
    var param = '{"loginMobile":"' + loginMobile + '","password":"' + pwd + '","validateCode":"' + $("#validateCode").val() + '","needRSAEncrypt":true}';
    $.ajax({
        type: "POST",
        url: "/Login/BindWeChatOpenID",
        contentType: "application/json; charset=utf-8",
        dataType: "text",
        data: param,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络繁忙,请稍后再登！");
        },
        success: function (data) {
            var dataobj = eval("(" + data + ")");
            switch (dataobj.Code) {
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
                    alert(dataobj.Message);
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




function UpdatePassWord(rsaE, rsaM) {
    if ($("#newPwd").val() != $("#confirmPwd").val()) {
        alert("新密码2次输入的不一致");
        return false;
    }


    if ($("#newPwd").val().length < 6 || $("#newPwd").val().length > 20) {
        alert("新密码长度应该在6-20位");
        return false;
    }

    setMaxDigits(131);
    var key = new RSAKeyPair(rsaE, "", rsaM);
    var OldPassword = encryptedString(key, base64encode(strUnicode2Ansi($("#oldPwd").val())));
    var NewPassword = encryptedString(key, base64encode(strUnicode2Ansi($("#newPwd").val())));

    var UpdatePwd = {
        OldPassword: OldPassword,
        NewPassword: NewPassword
    }



    $.ajax({
        type: "POST",
        url: "/Login/UpdatePassWord",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UpdatePwd),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if ( data.Code == "1") {
                alert(data.Message);
                location.href = "/Login/Setup";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function UnBindWeChat() {
    $.ajax({
        type: "POST",
        url: "/Login/UnBindWeChat",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data:null,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/";
            }
            else {
                alert(data.Message);
            }
        }
    });
}