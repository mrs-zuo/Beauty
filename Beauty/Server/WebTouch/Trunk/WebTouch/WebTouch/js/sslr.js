//another 5单双 参数解释 orignNum:原始数据 n:精确位数
function EffectiveNum(orignNum, n) {
    var loc; //标记位置，用于截取有效位的值
    var returnNum;
    var str;
    if (orignNum.toString() == "NaN" || orignNum.toString() == "Infinity" || orignNum.toString() == "0") {
        return 0;
    }

    str = orignNum.toString().split(".");
    //数字格式不正确
    if (str.length < 1 || str.length > 2) {
        return 0;
    }
    else if (str.length == 1) {
        str[1] = "";
    }

    //判断奇偶时初始化参数
    loc = str[0].length + parseInt(n - 1);

    //合并数字
    var uniteNum;
    if (parseInt(str[0]) > 0 || parseInt(str[0]) == 0) {
        uniteNum = str[0].concat(str[1]);
    }
    ////////////////////////////////////////////////////////////////////////////////////////////
    //小数点前部分大于0
    ////////////////////////////////////////////////////////////////////////////////////////////
    if (parseInt(str[0]) > 0 || parseInt(str[0]) == 0) {
        //取舍的数字和舍弃的数字
        var mender = str[0].length + parseInt(n);
        var leaver = uniteNum.slice(loc);

        //拟舍弃数字的最左一位数字大于5或者小于5
        if (uniteNum.charAt(mender) > 5 || uniteNum.charAt(mender) < 5) {
            //采用四舍五入的方法
            returnNum = (parseFloat(orignNum)).toFixed(n);
            //console.info('四舍五入====='+returnNum);
        } else if (uniteNum.charAt(mender) == 5) {
            //待舍弃数字最左第二位
            //计算5后面是第几位开始截取,并计算其值
            var needCal = mender + 1;
            var vary = parseInt(uniteNum.substring(needCal));
            //5后面一定是数值
            if (!isNaN(vary) && vary != 0) {
                returnNum = (parseFloat(orignNum)).toFixed(n);
                //console.info('vary是数字哦==='+returnNum);
            } else {
                if (uniteNum.charAt(loc) % 2 == 0) {
                    //判断最后的有效位为偶数时
                    returnNum = (uniteNum.substring(0, (loc + 1))) / Math.pow(10, n);
                    var tem = (returnNum.toString()).indexOf('.');
                    if (tem == -1) {
                        returnNum = returnNum + '.0';
                    }
                    //console.info('==偶数'+returnNum);
                } else {
                    //判断最后的有效位为奇数时
                    var i = 1 / Math.pow(10, n);
                    returnNum = uniteNum.substring(0, (loc + 1)) / Math.pow(10, n);
                    returnNum = i + returnNum;
                    if (n == 1) {
                        returnNum = returnNum.toFixed(1);
                    }
                    //console.info('===奇数'+returnNum);
                }

            }
        }
    }

    return returnNum;
}