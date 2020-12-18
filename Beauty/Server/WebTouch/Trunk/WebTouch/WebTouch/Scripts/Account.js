function setDefaultCard(cd) {
    var SetModel = {
        UserCardNo: cd,
    }

    $.ajax({
        type: "POST",
        url: "/Account/SetDefaultCard",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(SetModel),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Account/AccountDetail?cd=" + cd;
            }
            else {
                alert(data.Message);
            }
        }
    });
}


function CustomerLocation(longitude, latitude) {
    var CustomerLocation = {
        Longitude: longitude,
        Latitude: latitude
    }

    $.ajax({
        type: "POST",
        url: "/Account/CustomerLocation",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(CustomerLocation),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
           
        }
    });
}