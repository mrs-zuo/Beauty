/// <reference path="../assets/js/jquery-2.0.3.min.js" />



function getAuthenticationCode(rsaE, rsaM) {

    if ($("#txtMobile").val() == "") {
        alert("请输入手机号码");
        return false;
    } else {
        if ($("#txtMobile").val().len < 8 || $("#txtMobile").val().len > 11) {
            alert("请输入正确的手机号码");
            return false;
        }
    }

    setMaxDigits(131);
    var key = new RSAKeyPair(rsaE, "", rsaM);
    var LoginMobile = encryptedString(key, base64encode(strUnicode2Ansi($("#txtMobile").val())));
    $("#btnCode").unbind("click"); 
    $("#btnCode").attr("class", "bkgColor6 width40 textC whiteTex fr clearfix");
    $.ajax({
        type: "POST",
        url: "/ResetPassword/GetAuthenticationCode",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"LoginMobile":"' + LoginMobile + '"}',
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络错误");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                n = 60;
                $("#btnCode").everyTime('1s', function () {
                    $("#btnCode").text(n + "秒后重新获取");
                    n--;
                    if (n == 0) {
                        $("#btnCode").text("点击获取");
                        $("#btnCode").bind("click", function () {
                            getAuthenticationCode(rsaE, rsaM);
                        });
                        $("#btnCode").attr("class", "bkgColor2 width55 textC whiteTex fr clearfix");
                    }

                }, 60);
            } else {
                alert(data.Message);
                $("#btnCode").bind("click", function () {
                    getAuthenticationCode(rsaE, rsaM);
                });
                $("#btnCode").attr("class", "bkgColor2 width55 textC whiteTex fr clearfix");
            }
        }
    });
}


function checkAuthenticationCode(rsaE, rsaM) {
    if ($("#txtMobile").val() == "") {
        alert("请输入手机号码");
        return false;
    } else {
        if ($("#txtMobile").val().len < 8 || $("#txtMobile").val().len > 11) {
            alert("请输入正确的手机号码");
            return false;
        }
    }

    if ($("#txtCode").val() == "") {
        alert("请输入验证码");
        return false;
    }

    setMaxDigits(131);
    var key = new RSAKeyPair(rsaE, "", rsaM);
    var LoginMobile = encryptedString(key, base64encode(strUnicode2Ansi($("#txtMobile").val())));
    var AuthenticationCode = encryptedString(key, base64encode(strUnicode2Ansi($("#txtCode").val())));

    var CheckModel = {
        LoginMobile: LoginMobile,
        AuthenticationCode: AuthenticationCode
    }
    $.ajax({
        type: "POST",
        url: "/ResetPassword/checkAuthenticationCode",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(CheckModel),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                if (data.Data.length == 1) {

                    $("#txtData").val(data.Data[0].UserID);
                    $("#formReset").attr("action", "/ResetPassword/ChangePassword");
                } else if (data.Data.length > 1) {
                    $("#txtData").val(JSON.stringify(data.Data));
                    $("#formReset").attr("action", "/ResetPassword/SelectCompany");
                }

                $("#formReset").submit();
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function selectAllCompany(){
    var checked = $("#chkAll").prop("checked");
    $('#ulCompany  input[type="checkbox"][name="chkCompany"]').prop("checked", checked);
}

function goToChangePassword() {

    var customerId = "";
    $('#ulCompany input[type="checkbox"][name="chkCompany"]:checked').each(function () {
        if (customerId != "") {
            customerId += ",";
        }
        customerId += $(this).val();
    });
    if (customerId == "") {
        alert("请选择公司");
        return false;
    }
    $("#txtData").val(customerId);
    $("#formSelectCompany").submit();

}



function UpdatePassWord(CustomerIDs, Mobile, rsaE, rsaM) {
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
    var Password = encryptedString(key, base64encode(strUnicode2Ansi($("#newPwd").val())));
    Mobile = encryptedString(key, base64encode(strUnicode2Ansi(Mobile)));


    var UpdatePwd = {
        CustomerIDs: CustomerIDs,
        Password: Password,
        LoginMobile: Mobile
    }



    $.ajax({
        type: "POST",
        url: "/ResetPassword/UpdatePassWord",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UpdatePwd),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Login/Login";
            }
            else {
                alert(data.Message);
            }
        }
    });
}