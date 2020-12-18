function GotoShare(PromotionCode, Title, Desc, ImageUrl, imgShow) {
    var param = '{"PromotionCode":"' + PromotionCode + '"}';
    if (imgShow == 1) {
        $("#guideImg1").show();
    }
    $.ajax({
        type: "POST",
        url: "/Promotion/GetShareUrl",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: param,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                WXShow(Title, data.Data, Desc, ImageUrl);
            }
            else {
                alert("系统错误");
            }
        }
    });
}