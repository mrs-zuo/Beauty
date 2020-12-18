function GetBranchList(longitude, latitude) {
    var Branch = {
        Longitude: longitude,
        Latitude: latitude
    }


    $("#ulBranch li").remove();
    var navigationLinkData = new Array();
    var jsonBranch = "";
    $.ajax({
        type: "POST",
        url: "/Company/GetBranchList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Branch),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                jsonBranch = data.Data;
            }
            else {
                alert(data.Message);
            }
        }
    });

    if (jsonBranch != "") {
        for (var i = 0; i < jsonBranch.length; i++) {

            var model = {
                BranchID: jsonBranch[i].BranchID,
                BranchName: jsonBranch[i].BranchName,
                Phone: jsonBranch[i].Phone,
                Fax: jsonBranch[i].Fax,
                Address: jsonBranch[i].Address,
                Visible: jsonBranch[i].Visible,
                Longitude: jsonBranch[i].Longitude,
                Latitude: jsonBranch[i].Latitude,
                Distance: jsonBranch[i].Distance,
                DisplayDistance: jsonBranch[i].DisplayDistance
            }
            navigationLinkData.push(model);
        }
        var getNavContent = function (data) {
            if (!data || !data.length) {
                return '';
            }
            var res = easyTemplate($('#templateSign').html(), data).toString();
            return res;
        };
        $('#ulBranch').html(getNavContent(navigationLinkData));
    }

}