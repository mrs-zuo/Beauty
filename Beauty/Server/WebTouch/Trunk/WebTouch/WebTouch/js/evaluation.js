window.onload = function () {
    eva("star");
    $("#small .starSmall").each(function () {
        eva($(this).attr("id"));
    })
}
function eva(name) {
    var oStar = document.getElementById(name);
    var aLi = oStar.getElementsByTagName("li");
    var oUl = oStar.getElementsByTagName("ul")[0];
    var oSpan = oStar.getElementsByTagName("span")[1];
    var i = iScore = iStar = 5;
    for (i = 1; i <= aLi.length; i++) {
        aLi[i - 1].index = i;
        //鼠标移过显示分数
        aLi[i - 1].onmouseover = function () {
            fnPoint(this.index);
        };
        //鼠标离开后恢复上次评分
        aLi[i - 1].onmouseout = function () {
            fnPoint();
        };
        //点击后进行评分处理
        aLi[i - 1].onclick = function () {
            iStar = this.index;
        }
    }
    //评分处理
    function fnPoint(iArg) {
        //分数赋值
        iScore = iArg || iStar;
        for (i = 0; i < aLi.length; i++) {
            aLi[i].className = i < iScore ? "on" : "";
        }
    }

}
