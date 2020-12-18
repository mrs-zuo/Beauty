/// <reference path="../assets/js/jquery-2.0.3.min.js" />

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);



function delCategory(id) {
    if (confirm("确认删除？")) {
        $.ajax({
            type: "POST",
            url: "/Category/deleteCategory",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            data: '{"CategoryID":"' + id + '","Type":"' + $("#hidType").val() + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    var parentId = $.getUrlParam('p');
                    location.href = "/Category/GetCategoryList?&Type=" + $("#hidType").val() + "&p=" + parentId;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function updateCategory() {
    var id = parseInt($("#hidID").val());
    var type = parseInt($("#hidType").val());
    if (id > 0) {
        updateCatgeoryDetail(id, type);
    }
    else {
        addCategory(type);
    }
}

function updateCatgeoryDetail(id, type) {
    var param = {
        ParentID: $("#selCat").val(),
        ID: id,
        CategoryName: $("#input_CategoryName").val().trim(),
        Type: type
    }

    if (param.CategoryName == "") {
        alert("请输入分类名字！");
        return;
    }

    $.ajax({
        type: "POST",
        url: "/Category/UpdateCategory",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                var parentId = $.getUrlParam('p');
                location.href = "/Category/GetCategoryList?&Type=" + $("#hidType").val() + "&p=" + parentId;
            }
            else
                alert(data.Message);
        }
    });
}

function addCategory(type) {
    var param = {
        ParentID: $("#selCat").val(),
        CategoryName: $("#input_CategoryName").val().trim(),
        Type: type
    }

    if (param.CategoryName == "") {
        alert("请输入分类名字！");
        return;
    }

    $.ajax({
        type: "POST",
        url: "/Category/addCategory",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(param),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                var parentId = $.getUrlParam('p');
                location.href = "/Category/GetCategoryList?&Type=" + $("#hidType").val() + "&p=" + parentId;
            }
            else
                alert(data.Message);
        }
    });
}

function selectCategoryList() {
    var categoryID = $("#selCat").val();
    var type = parseInt($("#hidType").val());
    location.href = "/Category/GetCategoryList?type=" + type + "&p=" + categoryID;

}


function editCategory(id, type) {
    var categoryId = $("#selCat").val();
    if (id == 0) {
        location.href = "/Category/EditCategory?type=" + type + "&p=" + categoryId;
    } else {
        location.href = "/Category/EditCategory?ID=" + id + "&type=" + type + "&p=" + categoryId;
    }
}