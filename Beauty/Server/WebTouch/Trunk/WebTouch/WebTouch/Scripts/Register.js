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
    var CompanyID = $("#txtCd").val();


    setMaxDigits(131);
    var key = new RSAKeyPair(rsaE, "", rsaM);
    var LoginMobile = encryptedString(key, base64encode(strUnicode2Ansi($("#txtMobile").val())));

    $("#btnCode").unbind("click");
    $("#btnCode").attr("class", "bkgColor6 width40 textC whiteTex fr clearfix");
    $.ajax({
        type: "POST",
        url: "/Register/GetAuthenticationCode",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"LoginMobile":"' + LoginMobile + '","CompanyID":' + CompanyID + '}',
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("网络错误");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                GetBranchList();
                $("#divPassWord").show();
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


function checkAuthenticationCode(CompanyID, rsaE, rsaM) {
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

    if ($("#newPwd").val() != $("#confirmPwd").val()) {
        alert("新密码2次输入的不一致");
        return false;
    }


    if ($("#newPwd").val().length < 6 || $("#newPwd").val().length > 20) {
        alert("新密码长度应该在6-20位");
        return false;
    }
     
    var BranchID = 0;
    $('#ulBranch [name="radioBranch"]:checked').each(function () {
        BranchID = this.value;
    });
    if (BranchID == 0) {
        alert("请选择门店");
        return false;
    }


    setMaxDigits(131);
    var key = new RSAKeyPair(rsaE, "", rsaM);
    var LoginMobile = encryptedString(key, base64encode(strUnicode2Ansi($("#txtMobile").val())));
    var AuthenticationCode = encryptedString(key, base64encode(strUnicode2Ansi($("#txtCode").val())));
    var Password = encryptedString(key, base64encode(strUnicode2Ansi($("#newPwd").val())));

    var Register = {
        LoginMobile: LoginMobile,
        AuthenticationCode: AuthenticationCode,
        Password: Password,
        CompanyID: CompanyID,
        BranchID: BranchID
    }
    $.ajax({
        type: "POST",
        url: "/Register/checkAuthenticationCode",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Register),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1" && data.Data) {
                alert(data.Message);
                // location.href = "/Login/Login?co=" + CompanyID;
                BindSumbit(Register.LoginMobile,Register.Password);
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function GetBranchList(longitude, latitude) {
    var longitude = $("#txtCd").data("longitude");
    var latitude = $("#txtCd").data("latitude");
    var Branch = {
        Longitude: longitude,
        Latitude: latitude
    }


    $("#ulBranch li").remove();
    var navigationLinkData = new Array();
    var jsonBranch = "";
    $.ajax({
        type: "POST",
        url: "/Company/GetBranchList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Branch),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                jsonBranch = data.Data;
            }
            else {
                alert(data.Message);
            }
        }
    });

    if (jsonBranch != "") {
        for (var i = 0; i < jsonBranch.length; i++) {

            var model = {
                BranchID: jsonBranch[i].BranchID,
                BranchName: jsonBranch[i].BranchName,
                Distance: jsonBranch[i].Distance
            }
            navigationLinkData.push(model);
        }
        var getNavContent = function (data) {
            if (!data || !data.length) {
                return '';
            }
            var res = easyTemplate($('#templateSign').html(), data).toString();
            return res;
        };
        $('#ulBranch').html(getNavContent(navigationLinkData));
    }

}



function BindSumbit(loginMobile,password) {

    var param = '{"loginMobile":"' + loginMobile + '","password":"' + password + '","validateCode":"' + "" + '","needRSAEncrypt":true}';
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
            switch (data) {
                case "1":
                    window.location.href = "/Home/index";
                    break;
                default:
                    window.location.href = "/Login/Login?err=2";
                    break;

            }
        }
    });
}

