function selectAccount() {
    var accountID = $("#sel_flag").val();
    window.location.href = "/MarketMessage/GetMarketMessageList?a=" + accountID;
}

function addMessage() {
    var textcontent = $.trim($('#txt_content').val());
    if (textcontent == "") {
        alert("请输入营销文字!")
        return;
    }

    var CustomerIDList = new Array();
    $('input[type="checkbox"][name="chk_customer"]:checked').each(function () {
        CustomerIDList.push(this.value);
    });

    if (CustomerIDList.length <= 0) {
        alert("请选择接受人!")
        return;
    }

    var messageModel = {
        MessageContent: textcontent,
        listToUserID: CustomerIDList
    };

    $.ajax({
        type: "POST",
        url: "/MarketMessage/AddMarketMessage",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(messageModel),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/MarketMessage/GetMarketMessageList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function allcheck() {
    if ($("#chk_All").is(":checked")) {
        $('input[name="chk_customer"]').prop("checked", "checked");
    }
    else {
        $('input[name="chk_customer"]').prop("checked", "");
    }
}

function customerOk() {
    var CustomerIDList = new Array();
    var i = 0;
    var firstCustomerName = "";
    $('input[type="checkbox"][name="chk_customer"]:checked').each(function () {
        if (i == 0)
        {
            firstCustomerName = $(this).attr("customerName");
        }
        CustomerIDList.push(this.value);
        i++;
    });

    if (CustomerIDList.length > 0) {
        $("#txt_allCustomer").attr("placeholder", firstCustomerName + "等" + CustomerIDList.length + "人");
    }
    else {
        $("#txt_allCustomer").attr("placeholder", "点击选择接受人");
    }
}