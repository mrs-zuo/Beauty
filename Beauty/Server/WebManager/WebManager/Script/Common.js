

//check开始日是否小于结束日
function CheckDate(e) {
    var endDate = $(e).val();
    var startDate = $(e).parent().parent().prev("tr").find(".txtNormal").val();
    var result = DaysBetween(startDate, endDate);
    if (result > 0) {
        alert("结束日不能小于开始日!");
        $(e).val("").focus();
    }
}

//check开始日是否小于结束日
function DaysBetween(DateOne, DateTwo) {
    var cha = ((Date.parse(DateOne) - Date.parse(DateTwo)) / 86400000);
    return cha;
}


//金额判断
function priceChk(value) {
    if (isNaN(value)) {
        alert("请输入数字");
        return false;
    }
    if (value > 922337203685477) {
        alert("价格不能超过922337203685477");
        return false;
    } else if (value < 0) {
        alert("价格不能低于0");
        return false;

    }

    if (value.split('.').length > 1) {
        if (value.split('.')[1].length > 4) {
            alert("小数位不能超过4位数");
            return false;
        }
    }
    return true;
}