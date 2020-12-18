/// <reference path="../assets/js/jquery-2.0.3.min.js" />
$(function () {
    var titleon = $("input[id='49']");
    var nameon = $("input[id='50']");
    titleon.click(checkListener);
    nameon.click(checkListener);
    function checkListener(argument) {
        if (!(titleon.prop('checked') || nameon.prop('checked'))) {
            titleon.prop("checked", "checked");
        }
    }
})

function eachPid(id) {
    var PrentId = $('input[type="checkbox"][id="' + id + '"]').attr("pid");
    if (PrentId > 0) {
        var isChecked = $('input[type="checkbox"][id="' + PrentId + '"]').is(":checked");
        if (!isChecked) {
            $('input[type="checkbox"][id="' + PrentId + '"]').prop("checked", true);
        }
        eachPid(PrentId);
    }
    else {
        return;
    }
}

function eachChildrenID(id) {
    var childrenID = $('input[type="checkbox"][pId="' + id + '"]').val();
    if (childrenID > 0) {
        var isChecked = $('input[type="checkbox"][pId="' + id + '"]').is(":checked");
        if (isChecked) {
            $('input[type="checkbox"][pId="' + id + '"]').prop("checked", false);
        }
        eachChildrenID(childrenID);
    }
    else {
        return;
    }
}

function addRole() {
    var RoleName = $.trim($("#txt_RoleName").val());
    if (RoleName == "") {
        alert("权限名称不能为空!");
        return;
    }

    var Jurisdictions = "";
    $('input[type="checkbox"][name="chk_Role"]:checked').each(function () {
        Jurisdictions += "|" + this.value;
    });

    var RoleModel = {
        RoleName: RoleName,
        Jurisdictions: Jurisdictions + "|",
    };

    $.ajax({
        type: "POST",
        url: "/Role/AddRole",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(RoleModel),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Role/GetRoleList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function EditRole(ID) {
    var RoleName = $.trim($("#txt_RoleName").val());
    var OldRoleName = $.trim($("#hid_RoleName").val());
    var OldJurisdictions = $.trim($("#hid_Jurisdictions").val());

    if (RoleName == "") {
        alert("权限名称不能为空!");
        return;
    }
 
    var Jurisdictions = "";
    $('input[type="checkbox"][name="chk_Role"]:checked').each(function () {
        Jurisdictions += "|" + this.value;
    });

    var RoleModel = {
        ID: ID,
        RoleName: RoleName,
        Jurisdictions: Jurisdictions + "|",
    };

    if (OldRoleName == RoleName && OldJurisdictions == Jurisdictions) {
        alert("操作成功!");
        location.href = "/Role/GetRoleList";
    }
    else {
        $.ajax({
            type: "POST",
            url: "/Role/UpdateRole",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: JSON.stringify(RoleModel),
            async: false,
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                location.href = "/Home/Index?err=2";
            },
            success: function (data) {
                if (data.Data && data.Code == "1") {
                    alert(data.Message);
                    location.href = "/Role/GetRoleList";
                }
                else {
                    alert(data.Message);
                }
            }
        });
    }
}

function delRole(ID) {
    var RoleModel = {
        ID: ID,
    };

    $.ajax({
        type: "POST",
        url: "/Role/DeleteRole",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(RoleModel),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Data && data.Code == "1") {
                alert(data.Message);
                location.href = "/Role/GetRoleList";
            }
            else {
                alert(data.Message);
            }
        }
    });
}

function allcheck() {
    if ($("#chk_All").is(":checked")) {
        $('input[name="chk_Role"]').prop("checked", "checked");
    }
    else {
        $('input[name="chk_Role"]').prop("checked", "");
    }
}