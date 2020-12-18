/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    var url = window.location.pathname;
    if (url.indexOf("EditPaper") > -1) {
        getSortFunction();
        getQuestionList();
    }
})

function deletePaper(paperId) {
    if (confirm("确认删除？")) {
        $.ajax({
            type: "POST",
            url: "/Paper/DeletePaper",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            data: '{"PaperId":"' + paperId + '"}',
            error: function () {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Paper/GetPaperList";
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}


function getQuestionList() {
    $("#hidData").data("Question", "");

    $.ajax({
        type: "POST",
        url: "/Paper/GetQuestionList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: null,
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                if (data.Data != null) {
                    for (var i = 0; i < data.Data.length; i++) {
                        if (data.Data[i].QuestionType == 0) {
                            data.Data[i].QuestionName = data.Data[i].QuestionName + " (文本) ";
                        } else if (data.Data[i].QuestionType == 1) {
                            data.Data[i].QuestionName = data.Data[i].QuestionName + " (单选) ";
                        } else if (data.Data[i].QuestionType == 2) {
                            data.Data[i].QuestionName = data.Data[i].QuestionName + " (多选) ";
                        }
                    }
                }
                $("#hidData").data("Question", data.Data);
                showQuestion();
            }
        }
    });
}

function showQuestion() {
    var jsonQuestion = $("#hidData").data("Question");
    var strInput = $.trim($("#txtInputSearch").val());
    $("#tbQuestion tr").remove();
    if (jsonQuestion != null) {
        for (var i = 0; i < jsonQuestion.length; i++) {
            if (strInput == "") {
                $("#tbQuestion").append('<tr><td><span class="text over-text col-xs-12 no-pm">' + jsonQuestion[i].QuestionName + '</span><a style="cursor: pointer; display: block;" onclick="addQuestion(this,' + jsonQuestion[i].ID + ')"><i class="eag-plus fa fa-plus"></i></a></td></tr>');
            } else {
                if (jsonQuestion[i].QuestionName.indexOf(strInput) > -1) {
                    $("#tbQuestion").append('<tr><td><span class="text over-text col-xs-12 no-pm">' + jsonQuestion[i].QuestionName + '</span><a style="cursor: pointer; display: block;" onclick="addQuestion(this,' + jsonQuestion[i].ID + ')"><i class="eag-plus fa fa-plus"></i></a></td></tr>');
                }
            }
        }
    }
}

function addQuestion(e, questionId) {
    var result = true
    $('#foo tr').each(function () {
        var temp = $(this).attr("ques");
        if (questionId == temp) {
            result = false;
            return false;
        }
    });
    if (!result) {
        alert("该题已被选择");
        return false;
    }
    $("#foo").append('<tr ques="' + questionId + '"><td><span class="text over-text col-xs-12 no-pm" >' + $(e).prev().text() + '</span> <a style="cursor: pointer; display: block;"  onclick="deleteQuestion(this)"><i class="eag-plus fa fa-minus"></i></a></td></tr>');
}

function deleteQuestion(e) {
    $(e).parent().parent().remove();
}

function getSortFunction() {
    var console = window.console;

    if (!console.log) {
        console.log = function () {
            alert([].join.apply(arguments, ' '));
        };
    }
    window.x = new Sortable(foo, {
        group: "words",
    });
}

function submit(paperId) {
    var paperTitle = $.trim($("#txtPaperName").val());
    if (paperTitle == "") {
        alert("卷子名称不能为空!");
        return false;
    }


    var paperControl = 0;
    var RelationArray = new Array();
    var newQuestionList = "";
    var oldQuestion = $("#hid_oldQues").val();
    var sort = 1;
    $('#foo tr').each(function () {
        var temp = $(this).attr("ques");
        if (temp != "0") {
            if (paperId > 0 && paperControl != 1) {
                if (oldQuestion.indexOf(temp) == -1) {
                    paperControl = 1;
                }
            }
            newQuestionList += "|" + temp;

            var RelationModel = {
                QuestionID: temp,
                SortID: sort
            }
            RelationArray.push(RelationModel);
            sort++;
        }
    });

    if (oldQuestion == newQuestionList && $.trim(oldQuestion) != "") {
        paperControl = -1;
    }

    if (RelationArray == null || $.trim(RelationArray) == "") {
        alert("请选择问题!");
        return false;
    }
    var PaperMode = {
        ID: paperId,
        Title: paperTitle,
        IsVisible: $("#radioVisibleY").is(":checked"),
        CanEditAnswer: $("#radioCanEditAnswerY").is(":checked"),
        PaperControl: paperControl,
        listRelation: RelationArray
    };

    $.ajax({
        type: "POST",
        url: "/Paper/ControlPaper",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(PaperMode),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Paper/GetPaperList";
            }
            else {
                alert(data.Message);
            }
        }
    });

}