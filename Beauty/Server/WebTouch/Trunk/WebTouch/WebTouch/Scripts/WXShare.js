function WXShow(title, url, desc, imgUrl) {   
    wx.ready(function () {
        wx.onMenuShareTimeline({
            title: title, // 分享标题
            link: url, // 分享链接
            imgUrl: imgUrl, // 分享图标
            success: function () {
                alert("分享朋友圈成功!");
                $("#guideImg1").hide();
                // 用户确认分享后执行的回调函数
            },
            cancel: function () {
                $("#guideImg1").hide();
                // 用户取消分享后执行的回调函数
            }
        });

        wx.onMenuShareAppMessage({
            title: title, // 分享标题
            desc: desc, // 分享描述
            link: url, // 分享链接
            imgUrl: imgUrl, // 分享图标
            type: 'link', // 分享类型,music、video或link，不填默认为link
            dataUrl: '', // 如果type是music或video，则要提供数据链接，默认为空
            success: function () {
                alert("发送朋友成功!");
            },
            cancel: function () {
                $("#guideImg1").hide();
            }
        });
    });

}