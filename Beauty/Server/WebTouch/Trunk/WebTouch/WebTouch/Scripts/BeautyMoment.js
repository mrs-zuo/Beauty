

function selectYear() {
    var yy = $("#ddlYear").val();
    location.href = "/BeautyMoment/BeautyMomentList?yy=" + yy;
}

function submitTG(GroupNo) {
    var TG = {
        GroupNo: GroupNo,
        Comment: $("#txtComment").val()
    }
    $.ajax({
        type: "POST",
        url: "/BeautyMoment/UpdateTGComment",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(TG),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/BeautyMoment/EditBeautyMoment?gn=" + GroupNo;
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function AddPic(GroupNo) {
    var bg = $("#view").css("background-image");
    var headFlg = $("#hidtxt").data("HeadFlg");
    if (typeof (headFlg) == "undefined") {
        alert("请先上传照片");
        return;
    }
    var listAdd = new Array();
    var Add = {
        ImageString: bg,
        ImageTag: $("#txtImageTag").val()
    }
    listAdd.push(Add);
    var ServiceEffect = {
        GroupNo: GroupNo,
        AddImage: listAdd
    }


    $.ajax({
        type: "POST",
        url: "/BeautyMoment/AddTGPic",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(ServiceEffect),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/BeautyMoment/EditBeautyMoment?gn=" + GroupNo;
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function SubmitPic(RecordImgID, GroupNo) {
    var ImgModel = {
        RecordImgID: RecordImgID,
        Type: 3,
        ImageTag: $("#txtImageTag").val(),
        GroupNo: GroupNo
    }

    $.ajax({
        type: "POST",
        url: "/BeautyMoment/EditCustomerPic",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(ImgModel),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/BeautyMoment/EditBeautyMoment?gn=" + GroupNo;
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function DeleteTGPic(GroupNo) {
    var ImgModel = {
        GroupNo: GroupNo,
        Type: 1
    }



    var r = confirm("确认要删除该记录吗？");
    if (r) {
        $.ajax({
            type: "POST",
            url: "/BeautyMoment/EditCustomerPic",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(ImgModel),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("失败");
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/BeautyMoment/BeautyMomentList?";
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }

}



function DeteleOnePic(RecordImgID, GroupNo) {
    var ImgModel = {
        RecordImgID: RecordImgID,
        Type: 2,
        GroupNo: GroupNo
    }



    var r = confirm("确认要删除该记录吗？");
    if (r) {
        $.ajax({
            type: "POST",
            url: "/BeautyMoment/EditCustomerPic",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(ImgModel),
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("失败");
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/BeautyMoment/EditBeautyMoment?gn=" + GroupNo;
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}



function GoToShare(GroupNo,Comment,ImgUrl,imgShow) {
    var param = '{"GroupNo":"' + GroupNo + '"}';
    if (imgShow == 1) {
        $("#guideImg1").show();
    }
    $.ajax({
        type: "POST",
        url: "/BeautyMoment/GetShareUrl",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                WXShow("我的美丽瞬间", data.Data, Comment, ImgUrl);
            }
            else {
                alert("系统错误");
            }
        }
    });
   
}