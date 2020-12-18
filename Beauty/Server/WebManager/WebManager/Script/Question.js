/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {    
    var current = $.getUrlParam('QuestionType');
    if (current != null) {
        $('#ddlListStatus').val(current);
    }
    $('#ddlListStatus').change(function () {
        location.href = "/Question/GetQuestionList?QuestionType=" + $(this).val();        
    });
    $("select").change(function () {
        if ($(this).val() == "0") {
            $("#divContent").hide();
        } else { $("#divContent").show(); }
    });
});

function DelQuestion(ID)
{
    if (confirm("确定要进行此操作吗？")) {
        var param = '{"ID":'+ID+'}';
        $.ajax({
            type: "POST",
            url: "/Question/DelQuestion",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: param,
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Question/GetQuestionList"
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function UpdateQuestion()
{
     var QuestionMode = {
        QuestionName: $.trim($("#txtName").val()),
        QuestionType: $("#ddlEditStatus").val(),
        QuestionContent: $.trim($("#txtContent").val()),
        QuestionDescription: $.trim($("#txtQuestionDescription").val()),
        ID: $.getUrlParam('ID')
    };

    if (QuestionMode.QuestionName == "") {
        alert("问题不能为空");
        return;
    }


    if (QuestionMode.QuestionType != "0" && QuestionMode.QuestionContent == "") {
        alert("问题选项不能为空");
        return;
    }

    $.ajax({
        type: "POST",
        url: "/Question/UpdateQuestion",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(QuestionMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {            
            if (data.Data && data.Code == "1")
            {
                alert(data.Message);
                location.href = "/Question/GetQuestionList";
            }
            else
                alert(data.Message);

        }
    });
}

function AddQuestion()
{
    var QuestionMode = {
        QuestionName: $.trim($("#txtName").val()),
        QuestionType: $("#ddlAddStatus").val(),
        QuestionContent: $.trim($("#txtContent").val()),
        QuestionDescription: $.trim($("#txtQuestionDescription").val())
    };

    
    if (QuestionMode.QuestionName == "")
    {
        alert("问题不能为空");
        return;
    }
    if (QuestionMode.QuestionType != "0" && QuestionMode.QuestionContent == "")
    {
        alert("问题选项不能为空");
        return;
    }
    $.ajax({
        type: "POST",
        url: "/Question/AddQuestion",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(QuestionMode),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Question/GetQuestionList";
            }
            else
                alert(data.Message);
        }
    });
}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);