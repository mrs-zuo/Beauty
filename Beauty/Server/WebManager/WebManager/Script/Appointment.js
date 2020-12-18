/// <reference path="../assets/js/jquery-2.0.3.min.js" />

$(function () {
    getBranchList();  
})

function getBranchList() {
    $("#hidData").data("Branch", "");
    var UtilityOperation = {
    };
    $.ajax({
        type: "POST",
        url: "/Appointment/GetBranchList",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(UtilityOperation),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#hidData").data("Branch", data.Data);
                showBranchList(0);
            }
        }
    });
}

function showBranchList(relationFlg) {
    
    var jsonBranch = $("#hidData").data("Branch");
    $("#selBra option").remove();

    var braID = "";
    var branchID = $("#hidbraid").val();
    var BranchName = $("#hidbrana").val();
    var isBranch = $("#hidisbra").val();

    if (jsonBranch.length > 0 && relationFlg == 1) {
        $("#hidData").data("relationFlg", "true");
    }
    if (!isBranch) {
        if (jsonBranch != null && jsonBranch.length > 0) {
            for (var i = 0; i < jsonBranch.length; i++) {
                if (jsonBranch[i].ID == branchID) {
                    $("#selBra").append('<option  value="' + jsonBranch[i].ID + '"  selected="selected"> ' + jsonBranch[i].BranchName + '</option>');
                    braID = jsonBranch[i].ID;
                } else {
                    $("#selBra").append('<option  value="' + jsonBranch[i].ID + ' "> ' + jsonBranch[i].BranchName + '</option>');
                    braID = jsonBranch[0].ID;
                }
            }
        }
    } else {
        $("#selBra").append('<option  value="' + branchID + ' "> ' + BranchName + '</option>');
        braID = branchID;
    }

    getAppointmentList(braID);
}

function getAppointmentList(branchID) {
    $("#hidData").data("Appointment", "");

    tempBraID = branchID;

    if ($("#chk_Sta1").is(":checked")) {
        TaskStatus1 = 1;
    } else {
        TaskStatus1 = 0;
    }

    if ($("#chk_Sta2").is(":checked")) {
        TaskStatus2 = 1;
    } else {
        TaskStatus2 = 0;
    }

    if ($("#chk_Sta3").is(":checked")) {
        TaskStatus3 = 1;
    } else {
        TaskStatus3 = 0;
    }

    var bra = {
        ReserveDate: $("#txtTimeDate").val(),
        BranchID: tempBraID,
        inCustomerName: $("#inputCustomer").val(),
        inServiceName: $("#inputService").val(),
        inStaffName: $("#inputStaff").val(),
        inTaskStatus_1: TaskStatus1,
        inTaskStatus_2: TaskStatus2,
        inTaskStatus_3: TaskStatus3,
    };
   
    $.ajax({
        type: "POST",
        url: "/Appointment/GetAppointmentListForWeb",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(bra),
        async: false,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            location.href = "/Home/Index?err=2";
        },
        success: function (data) {
            if (data.Code == "1") {
                $("#hidData").data("Appointment", data.Data);
                showAppointmentList(0);
            }
        }
    });
}

function SearchOption() {
    braID = $("#selBra").val();
    getAppointmentList(braID);
}

function showAppointmentList(relationFlg) {
    var html = "";
    var jsonAppointment = $("#hidData").data("Appointment");
    $("#tbAppointment tr").remove();

    if (jsonAppointment.length > 0 && relationFlg == 1) {
        $("#hidData").data("relationFlg", "true");
    }
    for (var ReserveTime in jsonAppointment[0]) {
        var k = 0;
        while (k < jsonAppointment.length) {

            jsonAppointment[k][ReserveTime + 'span'] = 1;
            jsonAppointment[k][ReserveTime + 'show'] = "";

            for (var i = k + 1; i <= jsonAppointment.length - 1; i++) {
                if (jsonAppointment[k][ReserveTime] == jsonAppointment[i][ReserveTime] && jsonAppointment[k][ReserveTime] != '') {
                    jsonAppointment[k][ReserveTime + 'span']++;
                    jsonAppointment[k][ReserveTime + 'show'] = "";
                    jsonAppointment[i][ReserveTime + 'span'] = 1;
                    jsonAppointment[i][ReserveTime + 'show'] = "none";
                } else {
                    break;
                }
            }
            k = i;
        }
    }
  
    for (var j = 0; j < jsonAppointment.length; j++) {
        if (jsonAppointment[j].ReserveTimespan == 1&&jsonAppointment[j].ReserveTimeshow =="") {
            html += "<tr>";
            html += "<td rowspan = \"2\">" + jsonAppointment[j].ReserveTime + "</td>";
            html += "<td>" + jsonAppointment[j].CustomerName + "</td>";
            html += "<td>" + jsonAppointment[j].ServiceName + "</td>";
            html += "<td>" + jsonAppointment[j].StaffName + "</td>";
            html += "<td>" + jsonAppointment[j].Remark + "</td>";
            if (jsonAppointment[j].TaskStatus == 1) {
                html += "<td>待确认</td>";
            } else if (jsonAppointment[j].TaskStatus == 2) {
                html += "<td>已确认</td>";
            } else if (jsonAppointment[j].TaskStatus == 3) {
                html += "<td>已执行</td>";
            } else {
                html += "<td></td>";
            }
            html += "</tr><tr><td></td><td></td><td></td><td></td><td></td></tr>";
        } else {
            html += "<tr>";
            if (jsonAppointment[j].ReserveTimeshow =="") {
                html += "<td rowspan = \"" + jsonAppointment[j].ReserveTimespan + "\">" + jsonAppointment[j].ReserveTime + "</td>";
                }
            html += "<td>" + jsonAppointment[j].CustomerName + "</td>";
            html += "<td>" + jsonAppointment[j].ServiceName + "</td>";
            html += "<td>" + jsonAppointment[j].StaffName + "</td>";
            html += "<td>" + jsonAppointment[j].Remark + "</td>";
            if (jsonAppointment[j].TaskStatus == 1) {
                html += "<td>待确认</td>";
            } else if (jsonAppointment[j].TaskStatus == 2) {
                html += "<td>已确认</td>";
            } else if (jsonAppointment[j].TaskStatus == 3) {
                html += "<td>已执行</td>";
            } else {
                html += "<td></td>";
            }
            html += "</tr>";
        }
    }
    html += "<tr><td colspan=\"6\"></td></tr>";
    $("#tbAppointment").append(html);
}
