$(function(){
    $(function() {
        $(window).scroll(function(){
            if($(window).scrollTop()<800){
                $(".goTop").hide();
            }else{
                $(".goTop").show();
            }
        });
        $(".goTop").click(function(){
            $('body,html').animate({scrollTop:0},"1000");
            return false;
        });
    });
});
