$(document).ready(function(){

	//banner
	var bannerLength = $(".bannerUl li").length;

	var bannerBtnLi = "";
	for(i=1;i<=bannerLength;i++){
		bannerBtnLi += "<li class='bkgColor1'></li>";
    }
    $(".bannerBtn").append(bannerBtnLi);
    var bannerBtnLiMr = parseInt($(".bannerBtn li").css("margin-right"))
    var bannerBtnMl = -(bannerLength * $(".bannerBtn li").width() + (bannerLength - 1) * bannerBtnLiMr) / 2
    $(".bannerBtn").css("margin-left",bannerBtnMl)
    
    var bannerPage = 1;
	var bannerTime = 5000;
    var gotoBanner = function(page){
   	    $(".bannerUl li").stop().animate({opacity: 0}, "fast",function(){
	   	    $(this).hide();
   	    });
   	    $(".bannerUl li:eq("+ page +")").show().stop().animate({opacity: 1}, "fast");
   	    $(".bannerBtn li").removeClass("bkgColor2");
   	    $(".bannerBtn li:eq("+ page +")").addClass("bkgColor2");
    }
    gotoBanner(0);
    var bannerNext = function(){
		if(bannerPage >= bannerLength){
			bannerPage = 1;
		}else{
			bannerPage++;
		}
		gotoBanner(bannerPage-1);	
	}
    $(".bannerBtn li").each(function(i){
		$(this).hover(function() {
			clearInterval(bannerTimer);
			gotoBanner($(this).index())
		},function(){
			bannerTimer = setInterval( bannerNext , bannerTime);
		});
   	});
	var bannerTimer = setInterval( bannerNext , bannerTime);


});