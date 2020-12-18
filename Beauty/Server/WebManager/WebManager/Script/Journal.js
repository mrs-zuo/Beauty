/// <reference path="../assets/js/jquery-2.0.3.min.js" />
(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);
var hrefURLOut = "/Journal/EditJournal?jd=0&e=0&InOutType=1";
var hrefURLIn = "/Journal/EditJournal?jd=0&e=0&InOutType=2";
function deleteJournal(ID) {
    if (!confirm("您确认删除吗？")) {
        return;
    }

    $.ajax({
        type: "POST",
        url: "/Journal/DeleteJournal",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: '{"ID":"' + ID + '"}',
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            alert(data.Message);
            if (data.Data && data.Code == "1") {
                //重新加载table数据
                SearchJournal();
            }
            else {
                return;
            }
        }
    });
}

function SearchJournal() {
    
    var StartDate = $.trim($("#txtStartDate").val());
    var EndDate = $.trim($("#txtEndDate").val());
    var ItemName = $.trim($("#txtItemName").val());
    var BranchID = $.trim($("#txtBranchID").val());
    var InOutType = $.trim($("#txtInOutType").val());
    var SearchModel = {
        StartDate: StartDate,
        EndDate: EndDate,
        ItemName: ItemName,
        BranchID: BranchID,
        InOutType: InOutType
    }
    $("#addIn").attr("href", hrefURLIn + "&hbid=" + BranchID + "&hname=" + encodeURI(ItemName) + "&htp=" + InOutType + "&hsd=" + StartDate + "&hed=" + EndDate);
    $("#addOut").attr("href", hrefURLOut + "&hbid=" + BranchID + "&hname=" + encodeURI(ItemName) + "&htp=" + InOutType + "&hsd=" + StartDate + "&hed=" + EndDate);


    /*if (StartDate != "" && EndDate == "") {
        alert("请输入结束时间");
        return false;
    } else if (StartDate == "" && EndDate != "") {
        alert("请输入开始时间");
        return false;
    }*/
    //location.href = "/Journal/JournalList?sd=" + sd + "&ed=" + ed;
    $.ajax({
        type: "POST",
        url: "/Journal/GetSearchAccountList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(SearchModel),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                showSearchAccountList(data.Data);
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
}

function GetOperateList(ID, OperateID) {
    var Journal = {
        ID:ID,
        BranchID: $("#ddlBranch").val()
    }
    $.ajax({
        type: "POST",
        url: "/Journal/GetOperatorList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Journal),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                showOperatorList(data.Data, OperateID);
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
}

function GetInOutItemAList(SelectItemAID) {
    var param = {
    }
    $.ajax({
        type: "POST",
        url: "/InOutItem/GetInOutItemAList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                showInOutItemAList(data.Data, SelectItemAID);
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
}
//当大项目下拉框变化时
function GetInOutItemBList(SelectItemAID, SelectItemBID, SelectItemCID) {
    var ItemAIDValue = $("#InOutItemAList").val();
    if (ItemAIDValue != null && ItemAIDValue != '' && ItemAIDValue != SelectItemAID) {
        //当大项目下拉框变化时且不是上次选中的大项目时
        SelectItemAID = ItemAIDValue;
        SelectItemBID = "";
        SelectItemCID = "";
    }
    var param = {
        ItemAID: SelectItemAID
    }
    $.ajax({
        type: "POST",
        url: "/InOutItem/GetInOutItemBList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                showInOutItemBList(data.Data, SelectItemBID);
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
   GetInOutItemCList(SelectItemBID, SelectItemCID);
}
//中项目下拉框变化时
function GetInOutItemCList(SelectItemBID, SelectItemCID) {
    var ItemBIDValue = $("#InOutItemBList").val();
    if (ItemBIDValue != null && ItemBIDValue != '' && ItemBIDValue != SelectItemBID) {
        SelectItemBID = ItemBIDValue;
    }
    var param = {
        ItemBID: SelectItemBID
    }
    $.ajax({
        type: "POST",
        url: "/InOutItem/GetInOutItemCList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(param),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                showInOutItemCList(data.Data, SelectItemCID);
            }
            else {
                alert(data.Message);
                return;
            }
        }
    });
}
//展示大项目下拉框
function showInOutItemAList(list, SelectItemAID) {
    $("#InOutItemAList").empty();
    for (var i = 0; i < list.length; i++) {
        $("#InOutItemAList").append("<option value='" + list[i].ItemAID + "'>" + list[i].ItemAName + "</option>");
    }
    if (SelectItemAID == null || SelectItemAID == '' || SelectItemAID == 0) {//当添加记录时
        if (list.length > 0) {
            $("#InOutItemAList").val(list[0].ItemAID);
            GetInOutItemBList(list[0].ItemAID, "", "");
        }
    } else {
        $("#InOutItemAList").val(SelectItemAID);
    }
   
}
//展示中项目下拉框
function showInOutItemBList(list, SelectItemBID) {
    $("#InOutItemBList").empty();
    var isExist = false;
    for (var i = 0; i < list.length; i++) {
        if (list[i].ItemBID == SelectItemBID) {
            $("#InOutItemBList").append("<option value='" + list[i].ItemBID + "' selected=\'selected\'>" + list[i].ItemBName + "</option>");
            isExist = true;
        } else {
            $("#InOutItemBList").append("<option value='" + list[i].ItemBID + "'>" + list[i].ItemBName + "</option>");
        }
    }
    if (!isExist && list.length > 0) {
        $("#InOutItemBList").val(list[0].ItemBID);
    }
}
//展示小项目下拉框
function showInOutItemCList(list, SelectItemCID) {
    $("#InOutItemCList").empty();
    var isExist = false;
    for (var i = 0; i < list.length; i++) {
        if (list[i].ItemCID == SelectItemCID) {
            $("#InOutItemCList").append("<option value='" + list[i].ItemCID + "'  selected=\'selected\'>" + list[i].ItemCName + "</option>");
            isExist = true;
        } else {
            $("#InOutItemCList").append("<option value='" + list[i].ItemCID + "'>" + list[i].ItemCName + "</option>");
        }
    }
    if (!isExist && list.length > 0) {
        $("#InOutItemCList").val(list[0].ItemCID);
    }
}

展示经办人拉框
function showOperatorList(Operator, OperateID) {
    $("#ddlOperator").empty();
    for (var i = 0; i < Operator.length; i++) {
        $("#ddlOperator").append("<option value='" + Operator[i].UserID + "'>" + Operator[i].Name + "</option>");
    }

    $("#ddlOperator").val(OperateID);
}

//展示table
function showSearchAccountList(list) {
    $("#AccountTableList tr").remove();
    $("#AccountTableListTotal tr").remove();
    for (var i = 0; i < list.length; i++) {
        if (list[i].ID > 0) {
            if (list[i].CheckResult != 1) {
                $("#AccountTableList").append('<tr>'
                + '<td>' + (i + 1) + '</td>'
                + '<td>' + list[i].BranchName + '</td>'
                + '<td>' + list[i].InOutTypeName + '</td>'
                + '<td>' + list[i].ItemAName + '&nbsp;&nbsp;' + list[i].ItemBName + '&nbsp;&nbsp;' + list[i].ItemCName + '</td>'
                + '<td>' + list[i].InOutDate + '</td>'
                + '<td class="table-tr-td-digit">' + list[i].Amount + '元' + '</td>'
                + '<td>' + list[i].OperatorName + '</td>'
                + '<td style="word-wrap:break-word;">' + list[i].Remark + '</td>'
                + '<td>' + list[i].CheckResultName + '</td>'
                + '<td>'
                + '<a href="/Journal/EditJournal?jd=' + list[i].ID
                + '&e=1&InOutType='
                + list[i].InOutType
                + '&hbid=' + $('#txtBranchID').val()
                + '&hname=' + encodeURI($('#txtItemName').val())
                + '&hsd=' + $('#txtStartDate').val()
                + '&hed=' + $('#txtEndDate').val()
                + '&htp=' + $('#txtInOutType').val()
                + '" class="btn btn-default btn-sm"><i class="fa fa-edit"></i>编辑</a>'
                + '<a onclick="deleteJournal(' + list[i].ID + ')" class="btn btn-default btn-sm" id=""><i class="fa fa-trash-o"></i>删除</a>'
                + '</td>'
                + '</tr>');
                
            } else {
                $("#AccountTableList").append('<tr>'
                + '<td>' + (i + 1) + '</td>'
                + '<td>' + list[i].BranchName + '</td>'
                + '<td>' + list[i].InOutTypeName + '</td>'
                + '<td>' + list[i].ItemAName + '&nbsp;&nbsp;' + list[i].ItemBName + '&nbsp;&nbsp;' + list[i].ItemCName + '</td>'
                + '<td>' + list[i].InOutDate + '</td>'
                + '<td class="table-tr-td-digit">' + list[i].Amount + '元' + '</td>'
                + '<td>' + list[i].OperatorName + '</td>'
                + '<td style="word-wrap:break-word;">' + list[i].Remark + '</td>'
                + '<td>' + list[i].CheckResultName + '</td>'
                +'<td></td>'
                + '</tr>');
            }
            
        } else {
            $("#AccountTableListTotal").append('<tr>'
            + '<td></td>'
            + '<td></td>'
            + '<td>' + list[i].InOutTypeName + '</td>'
            + '<td></td>'
            + '<td></td>'
            + '<td class="table-tr-td-digit">' + list[i].Amount + '元' + '</td>'
            + '<td></td>'
            + '<td></td>'
            + '<td></td>'
            + '<td></td>'
            + '</tr>');
        }
    }
}



//编辑记录
function EditJournal(ID) {

    if ($("#ddlBranch").val() < 1) {
        alert("请选择门店");
        return;
    }
    
    /*if ($("#InOutItemAList").val() < 1) {
        alert("请选择大项目");
        return;
    }
    if ($("#InOutItemBList").val() < 1) {
        alert("请选择中项目");
        return;
    }
    if ($("#InOutItemCList").val() < 1) {
        alert("请选择小项目");
        return;
    }*/

    if ($.trim($("#txtstartDate").val()) == "") {
        alert("请选择时间");
        return;
    }

    if ($.trim($("#txtAmount").val()) == "") {
        alert("请输入金额");
        return;
    } else {
        if (isNaN($.trim($("#txtAmount").val()))) {
            alert("金额请输入数字");
            return

        }
    }

    // lou 2020.05.21
    //if ($("#ddlOperator").val() < 1) {
    //    alert("请选择经办人");
    //    return;
    //}

    var Journal = {
        ID: ID,
        BranchID: $("#ddlBranch").val(),
        ItemAID: $("#InOutItemAList").val(),
        ItemBID: $("#InOutItemBList").val(),
        ItemCID: $("#InOutItemCList").val(),
        InOutDate: $.trim($("#txtstartDate").val()),
        InOutType: $("#InOutType").val(),
        Amount: $.trim($("#txtAmount").val()),
        OperatorID: $("#ddlOperator").val(),
        Remark: $.trim($("#txtRemark").val())
    }
    $.ajax({
        type: "POST",
        url: "/Journal/OperateJournal",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Journal),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Journal/JournalList?hbid=" + $.getUrlParam('hbid')
                    + '&hname=' + encodeURI($("#hiddenItemName").val())
                    + '&htp=' + $.getUrlParam('htp')
                    + '&hsd=' + $.getUrlParam('hsd')
                    + '&hed=' + $.getUrlParam('hed');
            }
            else
                alert(data.Message);
        }
    });
}

//填写默认金额
function GetDefaultAMount() {
    var Journal = {
        BranchID: $("#ddlBranch").val(),
        ItemAID: $("#InOutItemAList").val(),
        ItemBID: $("#InOutItemBList").val(),
        ItemCID: $("#InOutItemCList").val(),
        InOutType: $("#InOutType").val(),
    }
    $.ajax({
        type: "POST",
        url: "/Journal/GetDefaultAMount",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Journal),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                if (data.Data != null && data.Data !='') {
                    $("#txtAmount").val(data.Data.Amount);
                } else {
                    $("#txtAmount").val('0.00');
                }
               
            }
        }
    });
}
