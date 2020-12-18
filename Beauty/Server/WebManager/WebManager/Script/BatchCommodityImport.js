/// <reference path="../assets/js/jquery-2.0.3.min.js" />

function SelectFile(type,branchID) {

    $.ajaxFileUpload
(
    {
        url: '/BatchImport/CommodityBatchImport', //用于文件上传的服务器端请求地址
        secureuri: false, //一般设置为false
        fileElementId: 'fileInput', //文件上传空间的id属性  <input type="file" id="file" name="file" />
        dataType: "json", //返回值类型 一般设置为json
        data: { Type: type, BranchID: branchID },
        type: "post",
        success: function (json)  //服务器成功响应处理函数
        {
            switch (json.Code) {
                case "-1":
                    alert("列名与数据不符,请检查!" + "(" + json.Code + ")");
                    break;
                case "-2":
                    alert("列名与数据不符,请检查!" + "(" + json.Code + ")");
                    break;
                case "-3":
                    alert(json.Message + "(" + json.Code + ")");
                    break;
                case "-5":
                    alert("列名与数据不符,请检查!" + "(" + json.Code + ")");
                    break;
                case "0":
                    alert(json.Message + "(" + json.Code + ")");
                    break;

                case "1":
                    if (json.Message != null && json.Message != '') {
                        var re = confirm(json.Message);
                        if (re == true) {
                            json.Message = "";
                            window.location.href = "/BatchImport/BatchCommodityView?Type=" + type + "&BranchID=" + branchID + "&FileName=" + json.Data + "&errorRowNumber=" + json.Message;
                        } 
                    }else{
                        window.location.href = "/BatchImport/BatchCommodityView?Type=" + type + "&BranchID=" + branchID + "&FileName=" + json.Data + "&errorRowNumber=" + json.Message;
                    }
                    break;
                default:
                    alert(json.Message + "(" + json.Code + ")");
                    break;
                    //bindTable(json,type);
                    //break;
            }
        },
        error: function (request, status, e)//服务器响应失败处理函数
        {
            alert(request.responseText);
        }
    }
)
}

function bindTable(json, addType) {

    $("#hid_FileName").val(json.Message);
    $div = $("#div_View");

    var strhtml = "<table class=\"table table-striped\">";

    var data = JSON.parse(json.Data);
    if (addType == 0) {
        for (var i = 0; i < data.length; i++) {
            trhtml += "<tr>";
            strhtml += "<th >" + data[i].CommodityName + "</th>";
            strhtml += "<th >" + data[i].BatchNO + "</th>";
            strhtml += "<th >" + data[i].Quantity + "</th>";
            strhtml += "<th >" + data[i].ExpiryDate + "</th>";
            strhtml += "<th >" + data[i].SupplierName + "</th>";
            strhtml += "</tr>";
        }
    }
   
    strhtml = strhtml + "</table><br><button class='btn btn-primary' type ='button' onclick='importSubmit()'>确 定</button><a href='javascript:history.go(0);' class='btn btn-default'> 返 回 </a><br><br>";
    $div.html(strhtml);
    $div.removeClass("hidden");
    $(".filePath").addClass("hidden");
}

function FixedValue(e) {
    if (e.indexOf(".") > 0) {
        return e.substring(0, e.indexOf(".") + 3);
    }
    else {
        return e;
    }
}

function importSubmit() {
    if ($("#hid_branchID").val() == null || $("#hid_branchID").val() == '') {
        alert("请选择一个门店！");
        retur;
    }
    var model = {
        FileName: $("#hid_FileName").val(),
        Type: $("#hid_Type").val(),
        BranchID: $("#hid_branchID").val()
    }

    $.ajax({
        type: "POST",
        url: "/BatchImport/importCommodityBatchInfo",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(model),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "0") {
                alert("添加失败!");
                return;
            }
            else {
                alert("添加成功!");
                window.location.href = $("#hid_Type").val() == "1" ? "/Commodity/GetCommodityList?b=-1&c=-1" : "/Service/GetServiceList?b=-1&c=-1";
            }
        }
    });



}

function downloadCommodityBatchTemplate() {
    var param = {
        BranchID: $("#hid_BranchID").val(),
    }
    $.ajax({
        type: "POST",
        url: "/Commodity/downloadCommodityBatchTemplate",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                window.parent.location.href = data.Data;
            }
            else
                alert(data.Message);
        }
    });
}

