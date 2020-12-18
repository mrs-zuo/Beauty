/// <reference path="../assets/js/jquery-2.0.3.min.js" />

function submit(ID) {
    var name = $.trim($("#txtName").val());
    if (name == "") {
        alert("请输入名称!");
        return;
    }

    var SourceType = {
        ID: ID,
        Name: name
    };

    $.ajax({
        type: "POST",
        url: "/CustomerSource/OperateCustomerSource",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(SourceType),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                window.location.href = "/CustomerSource/CustomerSourceList";
            } else {
                alert(data.Message);
            }
        }
    });
}

function deleteSourceType(ID) {
    if (ID <= 0) {
        alert("系统错误");
        window.location.href = "/CustomerSource/CustomerSourceList";
        return;
    }

    if (confirm("确定要进行此操作吗？")) {

        $.ajax({
            type: "POST",
            url: "/CustomerSource/deleteCustomerSource",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: '{"ID" : "' + ID + '"}',
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    window.location.href = "/CustomerSource/CustomerSourceList";
                } else {
                    alert(data.Message);
                }
            }
        });
    }
}