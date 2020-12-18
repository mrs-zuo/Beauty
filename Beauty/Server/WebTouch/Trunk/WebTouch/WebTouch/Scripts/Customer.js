/// <reference path="../js/jquery-1.11.1.min.js" />
function submit() {
    var bg = $("#view").css("background-image");
    var headFlg = $("#hidtxt").data("HeadFlg");
    var Customer = {
        ImageString: bg,
        CustomerName: $("#txtCustomerName").val(),
        Gender: $("#tadioSexMale").prop("checked") == true ? 0 : 1,
        HeadFlag: typeof (headFlg) == "undefined" ? 0 : 1
    }

    $.ajax({
        type: "POST",
        url: "/Customer/customerUpdateBasic",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(Customer),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("失败");
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Customer/MyInformation";
            }
            else {
                alert(data.Message);
            }
        }
    });
      
}
