/// <reference path="../assets/js/jquery-2.0.3.min.js" />

function SelectFile(type) {

    $.ajaxFileUpload
(
    {
        url: '/BatchImport/Import', //用于文件上传的服务器端请求地址
        secureuri: false, //一般设置为false
        fileElementId: 'fileInput', //文件上传空间的id属性  <input type="file" id="file" name="file" />
        dataType: "json", //返回值类型 一般设置为json
        data: { Type: type },
        type: "post",
        success: function (json)  //服务器成功响应处理函数
        {
            switch (json.Code) {
                //case "-1":
                //    alert("列名与数据不符,请检查!" + "(" + json.Code + ")");
                //    break;
                //case "-2":
                //    //alert("列名与数据不符,请检查!" + "(" + json.Code + ")");
                //    alert(json.Message + "(" + json.Code + ")");
                //    break;
                //case "-3":
                //    alert(json.Message + "(" + json.Code + ")");
                //    break;
                //case "-5":
                //    alert("列名与数据不符,请检查!" + "(" + json.Code + ")");
                //    break;
                //case "0":
                //    alert(json.Message + "(" + json.Code + ")");
                //    break;
                case "1":
                    window.location.href = "/BatchImport/BatchView?Type=" + type + "&FileName=" + json.Data+"&errorRowNumber="+json.Message;
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

//function bindTable(json, addType) {

//    $("#hid_FileName").val(json.Message);
//    $div = $("#div_View");

//    var strhtml = "<table class=\"table table-striped\">";

//    var data = JSON.parse(json.Data);
//    if (addType == 0) {
//        for (var i = 0; i < data.length; i++) {
//            //第一行显示标题 不做处理
//            if (i == 0) {
//                strhtml += "<tr>";
//                strhtml += "<th >" + data[i].CategoryName + "</th>";
//                strhtml += "<th >" + data[i].ServiceName + "</th>";
//                strhtml += "<th >" + data[i].UnitPrice + "</th>";
//                strhtml += "<th >" + data[i].MarketingPolicy + "</th>";
//                strhtml += "<th >" + data[i].PromotionPrice + "</th>";
//                strhtml += "<th >" + data[i].CourseFrequency + "</th>";
//                strhtml += "<th >" + data[i].SpendTime + "</th>";
//                strhtml += "<th >" + data[i].VisitTime + "</th>";
//                strhtml += "</tr>";
//            }
//            else {
//                //ispass==0的时候，说明有错误，tr标红
//                var unitPrice = FixedValue(data[i].UnitPrice);
//                var promotionPrice = FixedValue(data[i].PromotionPrice);
//                if (data[i].IsPass == "0") {
//                    strhtml += "<tr bgcolor=\"red\" >";
//                }
//                else {
//                    strhtml += "<tr>";
//                }
//                strhtml += "<td >" + data[i].CategoryName + "</td>";
//                strhtml += "<td >" + data[i].ServiceName + "</td>";
//                strhtml += "<td >" + unitPrice + "</td>";
//                strhtml += "<td >" + data[i].MarketingPolicy + "</td>";
//                strhtml += "<td >" + promotionPrice + "</td>";
//                strhtml += "<td >" + data[i].CourseFrequency + "</td>";
//                strhtml += "<td >" + data[i].SpendTime + "</td>";
//                strhtml += "<td >" + data[i].VisitTime + "</td>";
//                strhtml += "</tr>";
//            }
//        }
//    }
//    else {
//        for (var i = 0; i < data.length; i++) {
//            //第一行显示标题 不做处理
//            if (i == 0) {
//                strhtml += "<tr class=\"trTitleRow\" >";
//                strhtml += "<th >" + data[i].CategoryName + "</th>";
//                strhtml += "<th >" + data[i].CommodityName + "</th>";
//                strhtml += "<th >" + data[i].Specification + "</th>";
//                strhtml += "<th >" + data[i].UnitPrice + "</th>";
//                strhtml += "<th >" + data[i].MarketingPolicy + "</th>";
//                strhtml += "<th >" + data[i].PromotionPrice + "</th>";
//                strhtml += "<th >" + data[i].New + "</th>";
//                strhtml += "<th >" + data[i].Recommended + "</th>";
//                strhtml += "</tr>";
//            }
//            else {
//                var unitPrice = FixedValue(data[i].UnitPrice);
//                var promotionPrice = FixedValue(data[i].PromotionPrice);
//                //ispass==0的时候，说明有错误，tr标红
//                if (data[i].IsPass == "0") {
//                    strhtml += "<tr bgcolor=\"red\" >";
//                }
//                else {
//                    strhtml += "<tr>";
//                }
//                strhtml += "<td >" + data[i].CategoryName + "</td>";
//                strhtml += "<td >" + data[i].CommodityName + "</td>";
//                strhtml += "<td >" + data[i].Specification + "</td>";
//                strhtml += "<td >" + unitPrice + "</td>";
//                strhtml += "<td >" + data[i].MarketingPolicy + "</td>";
//                strhtml += "<td >" + promotionPrice + "</td>";
//                strhtml += "<td >" + data[i].New + "</td>";
//                strhtml += "<td >" + data[i].Recommended + "</td>";
//                strhtml += "</tr>";
//            }
//        }

//    }
//    strhtml = strhtml + "</table><br><button class='btn btn-primary' type ='button' onclick='importSubmit()'>确 定</button><a href='javascript:history.go(0);' class='btn btn-default'> 返 回 </a><br><br>";
//    $div.html(strhtml);
//    $div.removeClass("hidden");
//    $(".filePath").addClass("hidden");
//}

//function FixedValue(e) {
//    if (e.indexOf(".") > 0) {
//        return e.substring(0, e.indexOf(".") + 3);
//    }
//    else {
//        return e;
//    }
//}

function importSubmit() {
    var model = {
        FileName: $("#hid_FileName").val(),
        Type: $("#hid_Type").val()
    }

    $.ajax({
        type: "POST",
        url: "/BatchImport/importProduct",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(model),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "0") {
                alert("添加失败! \n" + data.Message);
                return;
            }
            else {
                alert("添加成功!");
                window.location.href = $("#hid_Type").val() == "1" ? "/Commodity/GetCommodityList?b=-1&c=-1&d=-1" : "/Service/GetServiceList?b=-1&c=-1";
            }
        }
    });



}


