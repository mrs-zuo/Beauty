/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    var flag = $.getUrlParam('flag');
    if (flag != null) {
        $('#sel_flag').val(flag);
    }
});

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

function addNews(type) {
    var content = "";
    var title = $.trim($("#xlginput").val());
    if (title == "") {
        if (type == 0) {
            alert("请输入公告标题");
        }
        else {
            alert("请输入新闻标题");
        }
        return;
    }

    if (type == 0) {
        content = $("#form-field-8").val();
    }
    else {
        content = $("#summernote").val();
    }
    if (content == "") {
        if (type == 0) {
            alert("请输入公告内容");
        }
        else {
            alert("请输入新闻内容");
        }
        return;
    }

    var param = '{"NoticeTitle":"' + title + '","NoticeContent":"' + content + '"';
    if (type == 0) {
        var StartDate = $.trim($("#txt_StartDate").val());
        var EndDate = $.trim($("#txt_EndDate").val());
        if (StartDate == "")
        {
            alert("请输入开始时间");
            return;
        }

        if (EndDate == "") {
            alert("请输入结束时间");
            return;
        }

        var start = new Date(StartDate.replace("-", "/").replace("-", "/"));
        var end = new Date(EndDate.replace("-", "/").replace("-", "/"));

        if (end < start) {
            alert('结束日期不能小于开始日期！');
            return;
        }

        param += ',"StartDate":"' + StartDate + '"';
        param += ',"EndDate":"' + $("#txt_EndDate").val() + '"';
        
    }
    param += ',"TYPE":' + type + '}'
    $.ajax({
        type: "POST",
        url: "/News/InsertNews",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data == "0") {
                if (type == 0) {
                    alert("添加公告失败!")
                }
                else {
                    alert("添加新闻失败!")
                }
                return;
            }
            else {
                if (type == 0) {
                    alert("添加公告成功!")
                    window.location.href = "/News/GetNoticeList";
                }
                else {
                    alert("添加新闻成功!")
                    window.location.href = "/News/GetNewsList";
                }
            }
        }
    });
}

function editNews(ID, type) {
    var content = "";
    var title = $("#xlginput").val();

    if (title.replace(/(^\s*)|(\s*$)/g, '') == "") {
        alert("请输入新闻标题");
        return;
    }

    if (type == 0) {
        content = $("#form-field-8").val();
    }
    else {
        content = $("#summernote").val();
    }

    var param = '{"NoticeTitle":"' + title + '","NoticeContent":"' + content + '","NoticeID":' + ID + '';
    if (type == 0) {

        var StartDate = $.trim($("#txt_StartDate").val());
        var EndDate = $.trim($("#txt_EndDate").val());
        if (StartDate == "") {
            alert("请输入开始时间");
            return;
        }

        if (EndDate == "") {
            alert("请输入结束时间");
            return;
        }

        var start = new Date(StartDate.replace("-", "/").replace("-", "/"));
        var end = new Date(EndDate.replace("-", "/").replace("-", "/"));

        if (end < start) {
            alert('结束日期不能小于开始日期！');
            return;
        }

        param += ',"StartDate":"' + $("#txt_StartDate").val() + '"';
        param += ',"EndDate":"' + $("#txt_EndDate").val() + '"';
    }

    param += ',"TYPE":' + type + '}'

    $.ajax({
        type: "POST",
        url: "/News/UpdateNews",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data == "0") {
                if (type == 0) {
                    alert("修改公告失败!")
                }
                else {
                    alert("修改新闻失败!")
                }
                return;
            }
            else {
                if (type == 0) {
                    alert("修改公告成功!")
                    window.location.href = "/News/GetNoticeList";
                }
                else {
                    alert("修改新闻成功!")
                    window.location.href = "/News/GetNewsList";
                }
            }
        }
    });
}

function delNews(ID, type) {
    var param = '{"NoticeID":' + ID + '}';
    if (confirm("确定要进行此操作吗？")) {
        $.ajax({
            type: "POST",
            url: "/News/DeleteNews",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data == "0") {
                    if (type == 0) {
                        alert("删除公告失败!")
                    }
                    else {
                        alert("删除新闻失败!")
                    }
                    return;
                }
                else {
                    if (type == 0) {
                        alert("删除公告成功!")
                        window.location.href = "/News/GetNoticeList";
                    }
                    else {
                        alert("删除新闻成功!")
                        window.location.href = "/News/GetNewsList";
                    }
                }
            }
        });
    }
}

function selNews(type) {
    var flag = $("#sel_flag").val();
    window.location.href = "/News/GetNoticeList?flag=" + flag;
}