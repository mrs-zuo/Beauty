function changeProductCategory() {
    var ProductType = $("#ddlProductType").val();
    $.ajax({
        type: "POST",
        url: "/Statement/GetProductCategoryList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: '{"ProductType":"' + ProductType + '"}',
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                showProductCategory(data.Data);
            }
            else
                alert(data.Message);
        }
    });
}

function showProductCategory(jsonCategory) {
    $("#ddlProductCategory option").remove();
    if (typeof (jsonCategory) != "undefined") {
        for (var i = 0; i < jsonCategory.length; i++) {
            $("#ddlProductCategory").append('<option  value="' + jsonCategory[i].CategoryID + '" >' + jsonCategory[i].CategoryName + '</option>');
           
        }
    }
    GetProductListByCategory();
}

function GetProductListByCategory() {
    var ProductType = $("#ddlProductType").val();
    var CategoryID = $("#ddlProductCategory").val();
    $.ajax({
        type: "POST",
        url: "/Statement/GetProductList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: '{"ProductType":"' + ProductType + '","CategoryID":"' + CategoryID + '"}',
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                showProduct(data.Data);
            }
            else
                alert(data.Message);
        }
    });

}


function showProduct(jsonProduct) {
    $("#tbProduct tr").remove();
    if (typeof (jsonProduct) != "undefined") {
        for (var i = 0; i < jsonProduct.length; i++) {
            $("#tbProduct").append('<tr pcd=' + jsonProduct[i].ProductCode + '><td><span class="text over-text col-xs-12 no-pm">' + jsonProduct[i].ProductName + '</span><a style="cursor:pointer;display:block;" onclick="addProduct(this,' + jsonProduct[i].ProductCode + ')"><i class="eag-plus fa fa-plus"></i></a></td></tr>');

        }
    }
}

function addProduct(e, ProductCode) {
    var ProductName = $(e).prev().text();
    var ProductType = $("#ddlProductType").val();
    var result = true
    $('#foo tr').each(function () {
        var temp = $(this).attr("pcd");
        var pt = $(this).attr("pt");
        if (ProductCode == temp && ProductType == pt) {
            result = false;
            return false;
        }
    });
    if (!result) {
        alert("该产品已被选择");
        return true;
    }
    if (ProductCode > 0) {
        $("#foo").append('<tr pt="' + ProductType + '" pcd="' + ProductCode + '"><td><span class="text over-text col-xs-12 no-pm">' + ProductName + '</span><a style="cursor: pointer; display: block;" onclick="minusProduct(this)"> <i class="eag-plus fa fa-minus"></i></a></td></tr>');
    }
}

function addAllProduct() {
    var chosen = "";
    var ProductType = $("#ddlProductType").val();
    $('#foo tr').each(function () {
        var temp = $(this).attr("pcd");
        var pt = $(this).attr("pt");
        chosen += "|" + pt + temp;
    });
    chosen += "|";
    $("#tbProduct tr").each(function () {
        var ProductCode = $(this).attr("pcd");
        var ProductName = $(this).children().children(0).text();
        var check = "|" + ProductType + ProductCode + "|";
        if (chosen.indexOf(check) < 0) {
            $("#foo").append('<tr  pt="' + ProductType + '" pcd="' + ProductCode + '"><td><span class="text over-text col-xs-12 no-pm">' + ProductName + '</span><a style="cursor: pointer; display: block;" onclick="minusProduct(this)"> <i class="eag-plus fa fa-minus"></i></a></td></tr>');
        }
    });
}

function EditStatement(ID) {
    if ($("#txtCategoryName").val() == "") {
        alert("分类名称不能为空!");
        return false;
    }

    var ListStatement = new Array();
    $('#foo tr').each(function () {
        var ProductCode = $(this).attr("pcd");
        var ProductType = $(this).attr("pt");
        if (ProductCode > 0) {
            var Detail = {
                ProductCode: ProductCode,
                ProductType: ProductType
            }
            ListStatement.push(Detail);
        }
    });
    if (ListStatement == "") {
        alert("产品不能为空");
        return false;
    }
    var Statement = {
        ID: ID,
        CategoryName: $.trim($("#txtCategoryName").val()),
        ListStatement: ListStatement
    }
    $.ajax({
        type: "POST",
        url: "/Statement/ControlStatement",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: JSON.stringify(Statement),
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Statement/GetStatementList";
            }
            else
                alert(data.Message);
        }
    });

}

function minusProduct(e) {
    $(e).parent().parent().remove();
}



function deleteStatement(ID) {
   
    $.ajax({
        type: "POST",
        url: "/Statement/DeleteStatement",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        data: '{"ID":"' + ID + '"}',
        error: function () {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                alert(data.Message);
                location.href = "/Statement/GetStatementList";
            }
            else
                alert(data.Message);
        }
    });

}