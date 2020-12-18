/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    getInOutItemAList();
})

function tableTrSelect(e, num) {
    var parentOb = $(e).parent();
    parentOb.addClass("table-tr-select");
    parentOb.siblings().removeClass("table-tr-select");
    if (num == 1) {
        //$("#RevenueInItemB").css("display", "");
        $("#InOutItemCList tr").remove();
        //$("#RevenueInItemC").css("display", "none");
        getInOutItemBList(parentOb.attr("aid"));
    }else if(num == 2){
        //$("#RevenueInItemC").css("display", "");
        getInOutItemCList(parentOb.attr("bid"));
    }
    
}

//加载大项目
function getInOutItemAList() {
    var UtilityOperation = {
    };

    $.ajax({
        type: "POST",
        url: "/InOutItem/GetInOutItemAList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                shownInOutItemAList(data.Data);
            }
        }
    });
}

function shownInOutItemAList(dataValue) {
    $("#InOutItemAList tr").remove();
    for (var i = 0; i < dataValue.length; i++) {
        $("#InOutItemAList").append('<tr aid=' + dataValue[i].ItemAID+'>'
            + ' <td id="ItemAID' + dataValue[i].ItemAID + '" onclick="tableTrSelect(this,1)" style="cursor:pointer;">' + dataValue[i].ItemAName + '</td>'
            + '<td>'
                + '<a class="btn btn-default btn-sm" onclick="editInOutItem(1,' + dataValue[i].ItemAID + ',' +'\''+ dataValue[i].ItemAName+'\'' + ')"><i class="fa fa-edit"></i>编辑</a>'
                + '<a class="btn btn-default btn-sm" id="" onclick="deleteInOutItem(1,' + dataValue[i].ItemAID + ')"><i class="fa fa-trash-o"></i>删除</a>'
            + '</td></tr>');
    }
    //默认选中第一个大项目
    if (dataValue.length > 0) {
        tableTrSelect($("#ItemAID" + dataValue[0].ItemAID), 1);
    }
}
//加载中项目
function getInOutItemBList(itemAID) {
    var UtilityOperation = {
        "ItemAID": itemAID
    };

    $.ajax({
        type: "POST",
        url: "/InOutItem/GetInOutItemBList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                shownInOutItemBList(data.Data);
            }
        }
    });
}

function shownInOutItemBList(dataValue) {
    $("#InOutItemBList tr").remove();
    for (var i = 0; i < dataValue.length; i++) {
        $("#InOutItemBList").append('<tr bid=' + dataValue[i].ItemBID + '>'
            + ' <td id="ItemBID' + dataValue[i].ItemBID + '" onclick="tableTrSelect(this,2)" style="cursor:pointer;">' + dataValue[i].ItemBName + '</td>'
            + '<td>'
                + '<a class="btn btn-default btn-sm" onclick="editInOutItem(2,' + dataValue[i].ItemBID + ',' +'\''+ dataValue[i].ItemBName +'\''+ ')"><i class="fa fa-edit"></i>编辑</a>'
                + '<a class="btn btn-default btn-sm" id="" onclick="deleteInOutItem(2,' + dataValue[i].ItemBID + ')"><i class="fa fa-trash-o"></i>删除</a>'
            + '</td></tr>');
    }
    //默认选中第一个中项目
    if (dataValue.length > 0) {
        tableTrSelect($("#ItemBID" + dataValue[0].ItemBID), 2);
    }
}
//加载小项目
function getInOutItemCList(itemBID) {
    var UtilityOperation = {
        "ItemBID": itemBID
    };

    $.ajax({
        type: "POST",
        url: "/InOutItem/GetInOutItemCList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                shownInOutItemCList(data.Data);
            }
        }
    });
}

function shownInOutItemCList(dataValue) {
    $("#InOutItemCList tr").remove();
    for (var i = 0; i < dataValue.length; i++) {
        $("#InOutItemCList").append('<tr bid=' + dataValue[i].ItemCID + '>'
            + ' <td id="ItemCID' + dataValue[i].ItemCID + '" onclick="tableTrSelect(this,3)" style="cursor:pointer;">' + dataValue[i].ItemCName + '</td>'
            + '<td>'
                + '<a class="btn btn-default btn-sm" onclick="editInOutItem(3,' + dataValue[i].ItemCID + ',' +'\''+ dataValue[i].ItemCName +'\''+ ')"><i class="fa fa-edit"></i>编辑</a>'
                + '<a class="btn btn-default btn-sm" id="" onclick="deleteInOutItem(3,' + dataValue[i].ItemCID + ')"><i class="fa fa-trash-o"></i>删除</a>'
            + '</td></tr>');
    }
    //默认选中第一个小项目
    if (dataValue.length > 0) {
        tableTrSelect($("#ItemCID" + dataValue[0].ItemCID), 3);
    }
}
//删除项目
function deleteInOutItem(ItemNum, ItemID) {
    var UtilityOperation = {
    };
    if (ItemNum == 1) {//删除大项目
        UtilityOperation.ItemAID = ItemID
        $.ajax({
            type: "POST",
            url: "/InOutItem/DeleteInOutItemA",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(UtilityOperation),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                alert(data.Message);
                if (data.Data && data.Code == "1") {
                    //清空小项目
                    $("#InOutItemCList tr").remove();
                    //清空中项目
                    $("#InOutItemBList tr").remove();
                    //重新加载大项目
                    getInOutItemAList();;
                }
            }
        });
    } else if (ItemNum == 2) {//删除中项目
        UtilityOperation.ItemBID = ItemID
        var selectNode;
        selectNode = $("#InOutItemAList .table-tr-select");
        $.ajax({
            type: "POST",
            url: "/InOutItem/DeleteInOutItemB",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(UtilityOperation),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                alert(data.Message);
                if (data.Data && data.Code == "1") {
                    //清空小项目
                    $("#InOutItemCList tr").remove();
                    //重新加载中项目
                    getInOutItemBList(selectNode.attr("aid"));;
                }
            }
        });
    } else if (ItemNum == 3) {//删除小项目
        UtilityOperation.ItemCID = ItemID
        var selectNode;
        selectNode = $("#InOutItemBList .table-tr-select");
        $.ajax({
            type: "POST",
            url: "/InOutItem/DeleteInOutItemC",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(UtilityOperation),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                alert(data.Message);
                if (data.Data && data.Code == "1") {
                    getInOutItemCList(selectNode.attr("bid"));;
                }
            }
        });
    }
    
}
//编辑项目
function editInOutItem(ItemNum, ItemID,ItemName) {
    //初始化弹窗标题
    var title = "编辑大项目";
    if (ItemNum == 1) {
        title = "编辑大项目";
    } else if (ItemNum == 2) {
        title = "编辑中项目";       
    } else if (ItemNum == 3) {
        title = "编辑小项目";
    }
    $("#ItemType").data("ItemType", "edit");
    $("#ItemNum").data("ItemNum", ItemNum);
    $("#ItemID").data("ItemID", ItemID);
    $("#InOutItemName").val(ItemName);
    $("#demo1").layerModel({
        title: title
    });
}
//添加项目
function addInOutItem(ItemNum) {
    //初始化弹窗标题
    var title = "添加大项目";
    var selectNode;
    if (ItemNum == 1) {
        title = "添加大项目";
    } else if (ItemNum == 2) {
        selectNode = $("#InOutItemAList .table-tr-select");
        if (selectNode.attr("aid") == undefined) {
            alert("请选择大项目");
            return false;
        }
        title = "添加中项目";
    } else if (ItemNum == 3) {
        selectNode = $("#InOutItemBList .table-tr-select");
        if (selectNode.attr("bid") == undefined) {
            alert("请选择中项目");
            return false;
        }
        title = "添加小项目";
    }
    $("#ItemType").data("ItemType", "add");
    $("#ItemNum").data("ItemNum", ItemNum);
    $("#InOutItemName").val("");
    $("#demo1").layerModel({
        title: title
    });
}
//保存项目
function saveInOutItem() {
    var UtilityOperation = {
    };
    var InOutItemName = $("#InOutItemName").val();
    var ItemType = $("#ItemType").data("ItemType");
    var ItemNum = $("#ItemNum").data("ItemNum");
    var ItemID = $("#ItemID").data("ItemID");
    if (InOutItemName == null || InOutItemName == '') {
        alert("项目名称不能为空！");
        return false;
    }
    var selectNode;
    //保存大项目
    if (ItemNum == 1) {
        //编辑
        if (ItemType == "edit") {
            UtilityOperation.ItemAID = ItemID;
            UtilityOperation.ItemAName = InOutItemName;
            $.ajax({
                type: "POST",
                url: "/InOutItem/UpdateInOutItemA",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(UtilityOperation),
                async: false,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {
                    alert(data.Message);
                    if (data.Data && data.Code == "1") {
                        $("#demo1").close();
                        getInOutItemAList();;
                    }
                }
            });
        } else if (ItemType == "add") {//添加
            UtilityOperation.ItemAName = InOutItemName;
            $.ajax({
                type: "POST",
                url: "/InOutItem/AddInOutItemA",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(UtilityOperation),
                async: false,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {
                    alert(data.Message);
                    if (data.Data && data.Code == "1") {
                        $("#demo1").close();
                        getInOutItemAList();;
                    }
                }
            });
        }
        
    } else if (ItemNum == 2) {//保存中项目
        selectNode = $("#InOutItemAList .table-tr-select");
        UtilityOperation.ItemAID = selectNode.attr("aid");
        //编辑
        if (ItemType == "edit") {
            UtilityOperation.ItemBID = ItemID;
            UtilityOperation.ItemBName = InOutItemName;
            $.ajax({
                type: "POST",
                url: "/InOutItem/UpdateInOutItemB",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(UtilityOperation),
                async: false,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {
                    alert(data.Message);
                    if (data.Data && data.Code == "1") {
                        $("#demo1").close();
                        getInOutItemBList(UtilityOperation.ItemAID);
                    } 
                }
            });
        } else if (ItemType == "add") {//添加
            if (selectNode == undefined || selectNode.attr("aid") == null || selectNode.attr("aid") == "") {
                alert("请选择大项目！");
                return false;
            }
            UtilityOperation.ItemBName = InOutItemName;
            $.ajax({
                type: "POST",
                url: "/InOutItem/AddInOutItemB",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(UtilityOperation),
                async: false,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {
                    alert(data.Message);
                    if (data.Data && data.Code == "1") {
                        $("#demo1").close();
                        getInOutItemBList(UtilityOperation.ItemAID);
                    }
                }
            });
        }
        
    } else if (ItemNum == 3) {//保存小项目
        selectNode = $("#InOutItemBList .table-tr-select");
        UtilityOperation.ItemBID = selectNode.attr("bid");
        //编辑
        if (ItemType == "edit") {
            UtilityOperation.ItemCID = ItemID;
            UtilityOperation.ItemCName = InOutItemName;
            $.ajax({
                type: "POST",
                url: "/InOutItem/UpdateInOutItemC",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(UtilityOperation),
                async: false,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {
                    alert(data.Message);
                    if (data.Data && data.Code == "1") {
                        $("#demo1").close();
                        getInOutItemCList(UtilityOperation.ItemBID);
                    }
                }
            });
        } else if (ItemType == "add") {//添加
            selectNode = $("#InOutItemBList .table-tr-select");
            if (selectNode == undefined || selectNode.attr("bid") == null || selectNode.attr("bid") == "") {
                alert("请选择中项目！");
                return false;
            }
            UtilityOperation.ItemBID = selectNode.attr("bid");
            UtilityOperation.ItemCName = InOutItemName;
            $.ajax({
                type: "POST",
                url: "/InOutItem/AddInOutItemC",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify(UtilityOperation),
                async: false,
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    location.href = "/Home/Index?err=2";
                },
                success: function (data) {
                    alert(data.Message);
                    if (data.Data && data.Code == "1") {
                        $("#demo1").close();
                        getInOutItemCList(UtilityOperation.ItemBID);
                    }
                }
            });
        }
        
    }

}

(function ($) {
    $.getUrlParam = function (name) {
        var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
        var r = window.location.search.substr(1).match(reg);
        if (r != null) return unescape(r[2]); return null;
    }
})(jQuery);

