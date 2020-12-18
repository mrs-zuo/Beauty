/// <reference path="../assets/js/jquery-2.0.3.min.js" />

function addDiscount() {
    var DiscountName = $.trim($("#txt_DiscountName").val());
    if (DiscountName == "") {
        alert("折扣名称不能为空!");
        return;
    }


    //var param = '{"DiscountName":"' + DiscountName + '"}';
    //// 判断名字有没有重复
    //$.ajax({
    //    type: "POST",
    //    url: "/Discount/IsExistDiscountName",
    //    contentType: "application/json; charset=utf-8",
    //    dataType: "json",
    //    data: param,
    //    async: false,
    //    error: function (XMLHttpRequest, textStatus, errorThrown) {
    //        alert(XMLHttpRequest.status);
    //        alert(XMLHttpRequest.readyState);
    //        alert(textStatus);
    //    },
    //    success: function (data) {
    //        if (data != "0") {
    //            alert("折扣名字重复!")
    //            return;
    //        }
    //    }
    //});

    // 循环取值
    var leveldiscount = "";
    var code = "";
    $(".level").each(function () {
        var LevelID = $(this).find("#hidLevelID").val();
        var Discount = $.trim($(this).find("#txt_discount").val());
        var Available = $(this).find("#chk_Level").is(":checked");
        if (Available) {
            if (Discount == "") {
                alert("折扣率不能为空!");
                code = "1";
                return;
            }

            if (isNaN(Discount)) {
                alert("请输入数字");
                code = "2";
                return;
            }

            if (Discount > 1 || Discount <= 0) {
                alert("请输入0-1之间的数字");
                code = "3";
                return;
            }

            if (Discount.split('.').length > 1) {
                if (Discount.split('.')[1].length > 2) {
                    alert("小数位不能超过2位数");
                    code = "4";
                    return;
                }
            }

            leveldiscount += LevelID + "," + Discount + "|";
        }
    })

    if (code != "") {
        return;
    }

    param = '{"DiscountName":"' + DiscountName + '","LevelDiscount":"' + leveldiscount + '"}';
    $.ajax({
        type: "POST",
        url: "/Discount/AddDiscount",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data == "0") {
                alert("添加折扣失败!")
                return;
            }
            else if (data == "-2") {
                alert("折扣名字重复!")
                return;
            }
            else {
                alert("添加折扣成功!")
                window.location.href = "/Discount/GetDiscountList";
            }
        }
    });
}

function editDiscount(ID) {
    var DiscountName = $.trim($("#txt_DiscountName").val());
    if (DiscountName == "") {
        alert("折扣名称不能为空!");
        return;
    }

    var OldDiscountName = $.trim($("#hidDiscountName").val());
    if (OldDiscountName == DiscountName) {
        var param = '{"DiscountName":"' + DiscountName + '"}';
        // 判断名字有没有重复
        $.ajax({
            type: "POST",
            url: "/Discount/IsExistDiscountName",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert(XMLHttpRequest.status);
                alert(XMLHttpRequest.readyState);
                alert(textStatus);
            },
            success: function (data) {
                if (data != "0") {
                    alert("折扣名字重复!");
                    return;
                }
            }
        });
        DiscountName = "";
    }



    // 循环取值
    //var leveldiscount = "";
    //var code = "";
    //$(".level").each(function () {
    //    var LevelID = $(this).find("#hidLevelID").val();
    //    var OleDiscount = $(this).find("#hidDiscount").val();
    //    var Discount = $.trim($(this).find("#txt_discount").val());
    //    var Available = $(this).find("#chk_Level").is(":checked");
    //    if (Available) {
    //        if (Discount == "") {
    //            alert("折扣率不能为空!");
    //            code = "1";
    //            return;
    //        }

    //        if (isNaN(Discount)) {
    //            alert("请输入数字");
    //            code = "2";
    //            return;
    //        }

    //        if (Discount > 1 || Discount <= 0) {
    //            alert("请输入0-1之间的数字");
    //            code = "3";
    //            return;
    //        }

    //        if (Discount.split('.').length > 1) {
    //            if (Discount.split('.')[1].length > 2) {
    //                alert("小数位不能超过2位数");
    //                code = "4";
    //                return;
    //            }
    //        }

    //        if (Discount != OleDiscount) {
    //            leveldiscount += LevelID + "," + Discount + "|";
    //        }
    //    }
    //})

    //if (code != "") {
    //    return;
    //}

    if (DiscountName != "") {
        param = '{"DiscountID":' + ID + ',"DiscountName":"' + DiscountName +'"}';
        $.ajax({
            type: "POST",
            url: "/Discount/UpdateDiscount",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data == "0") {
                    alert("修改折扣失败!");
                    return;
                }
                else if (data == "-2") {
                    alert("折扣名字重复!");
                    return;
                }
                else {
                    alert("修改折扣成功!");
                    window.location.href = "/Discount/GetDiscountList";
                }
            }
        });
    }
    else {
        alert("修改折扣成功!");
        window.location.href = "/Discount/GetDiscountList";
    }
}

function delDiscount(ID, Type) {
    var param = '{"DiscountID":' + ID + ',"Available":' + Type + '}';
    if (confirm("确定要进行此操作吗？")) {
        $.ajax({
            type: "POST",
            url: "/Discount/DeleteDiscount",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data == "0") {
                    if (Type == 0) {
                        alert("删除折扣分类失败!")
                    }
                    else {
                        alert("激活折扣分类失败!")
                    }
                    return;
                }
                else {
                    if (Type == 0) {
                        alert("删除折扣分类成功!")
                        window.location.href = "/Discount/GetDiscountList";
                    }
                    else {
                        alert("激活折扣分类成功!")
                        window.location.href = "/Discount/GetDiscountList";
                    }
                }
            }
        });
    }
}

function addLevel() {
    var LevelName = $.trim($("#txt_LevelName").val());
    if (LevelName == "") {
        alert("会员等级名称不能为空!");
        return;
    }

    var Threshold = $.trim($("#txt_Threshold").val());
    if (Threshold == "") {
        Threshold = 0;
    }

    if (isNaN(Threshold)) {
        alert("余额不足提醒金额请输入数字");
        return;
    }

    if (Threshold < 0) {
        alert("余额不足提醒金额请输入0-1之间的数字");
        return;
    }

    // 循环取值
    var leveldiscount = "";
    var code = "";
    $(".dicount").each(function () {
        var DiscountID = $(this).find("#hidDiscountID").val();
        var Discount = $.trim($(this).find("#txt_discount").val());
        var Available = $(this).find("#chk_Discount").is(":checked");
        if (Available) {
            if (Discount == "") {
                alert("折扣率不能为空!");
                code = "1";
                return;
            }

            if (isNaN(Discount)) {
                alert("请输入数字");
                code = "2";
                return;
            }

            if (Discount > 1 || Discount <= 0) {
                alert("请输入0-1之间的数字");
                code = "3";
                return;
            }

            if (Discount.split('.').length > 1) {
                if (Discount.split('.')[1].length > 2) {
                    alert("小数位不能超过2位数");
                    code = "4";
                    return;
                }
            }

            leveldiscount += DiscountID + "," + Discount + "|";
        }
    })

    if (code != "") {
        return;
    }

    param = '{"LevelName":"' + LevelName + '","Threshold":' + Threshold + ',"LevelDiscount":"' + leveldiscount + '"}';
    $.ajax({
        type: "POST",
        url: "/Level/AddLevel",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data == "0") {
                alert("添加会员等级失败!")
                return;
            }
            else if (data == "-2") {
                alert("折扣名字重复!")
                return;
            }
            else {
                alert("添加会员等级成功!")
                window.location.href = "/Level/GetLevelList";
            }
        }
    });
}

function editLevel(ID) {
    var LevelName = $.trim($("#txt_LevelName").val());
    if (LevelName == "") {
        alert("折扣名称不能为空!");
        return;
    }

    var Threshold = $.trim($("#txt_Threshold").val());
    if (Threshold == "") {
        alert("会员等级名称不能为空!");
        return;
    }

    if (isNaN(Threshold)) {
        alert("余额不足提醒金额请输入数字");
        return;
    }

    if (Threshold < 0) {
        alert("余额不足提醒金额请输入0-1之间的数字");
        return;
    }

    var OldLevelName = $.trim($("#hidLevelName").val());
    var OldThreshold = $.trim($("#hidThreshold").val());
    if (OldLevelName == LevelName) {
        //var param = '{"DiscountName":"' + DiscountName + '"}';
        //// 判断名字有没有重复
        //$.ajax({
        //    type: "POST",
        //    url: "/Discount/IsExistDiscountName",
        //    contentType: "application/json; charset=utf-8",
        //    dataType: "json",
        //    data: param,
        //    async: false,
        //    error: function (XMLHttpRequest, textStatus, errorThrown) {
        //        alert(XMLHttpRequest.status);
        //        alert(XMLHttpRequest.readyState);
        //        alert(textStatus);
        //    },
        //    success: function (data) {
        //        if (data != "0") {
        //            alert("折扣名字重复!");
        //            return;
        //        }
        //    }
        //});
        LevelName = "";
    }

    if (OldThreshold == Threshold) {
        Threshold = -1;
    }

    // 循环取值
    var leveldiscount = "";
    var code = "";
    $(".dicount").each(function () {
        var DisCountID = $(this).find("#hidDiscountID").val();
        var OldDiscount = $(this).find("#hidDiscount").val();
        var Discount = $.trim($(this).find("#txt_discount").val());
        var Available = $(this).find("#chk_Discount").is(":checked");
        if (Available)
        {
            if (Discount == "") {
                alert("折扣率不能为空!");
                code = "1";
                return;
            }

            if (isNaN(Discount)) {
                alert("请输入数字");
                code = "2";
                return;
            }

            if (Discount > 1 || Discount <= 0) {
                alert("请输入0-1之间的数字");
                code = "3";
                return;
            }

            if (Discount.split('.').length > 1) {
                if (Discount.split('.')[1].length > 2) {
                    alert("小数位不能超过2位数");
                    code = "4";
                    return;
                }
            }

            if (Discount != OldDiscount) {
                leveldiscount += DisCountID + "," + Discount + "|";
            }
        }        
    })

    if (code != "")
    {
        return;
    }

    if (LevelName != "" || Threshold >= 0 || leveldiscount != "") {
        param = '{"LevelID":' + ID + ',"Threshold":' + Threshold + ',"LevelName":"' + LevelName + '","LevelDiscount":"' + leveldiscount + '"}';
        $.ajax({
            type: "POST",
            url: "/Level/UpdateLevel",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data == "0") {
                    alert("修改会员等级失败!");
                    return;
                }
                else if (data == "-2") {
                    alert("折扣名字重复!");
                    return;
                }
                else {
                    alert("修改会员等级成功!");
                    window.location.href = "/Level/GetLevelList";
                }
            }
        });
    }
    else {
        alert("修改会员等级成功!");
        window.location.href = "/Level/GetLevelList";
    }

}

function delLevel(ID, Type) {
    var param = '{"LevelID":' + ID + ',"Available":' + Type + '}';

    if (confirm("确定要进行此操作吗？")) {
        $.ajax({
            type: "POST",
            url: "/Level/DeleteLevel",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data == "0") {
                    if (Type == 0) {
                        alert("删除会员等失败!")
                    }
                    else {
                        alert("激活会员等失败!")
                    }
                    return;
                }
                else {
                    if (Type == 0) {
                        alert("删除会员等成功!")
                        window.location.href = "/Level/GetLevelList";
                    }
                    else {
                        alert("激活会员等类成功!")
                        window.location.href = "/Level/GetLevelList";
                    }
                }
            }
        });
    }
}

function changeDefaultLevel(ID) {
    var param = '{"LevelID":' + ID + '}';
    $.ajax({
        type: "POST",
        url: "/Level/ChangDefaultLevel",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data == "0") {
                alert("修改默认会员等失败!")
                return;
            }
            else {
                alert("修改默认会员等级成功!")
                window.location.href = "/Level/GetLevelList";
            }
        }
    });
}

