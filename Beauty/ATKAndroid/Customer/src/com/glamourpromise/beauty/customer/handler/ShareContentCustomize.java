package com.glamourpromise.beauty.customer.handler;

import android.content.Context;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.framework.Platform.ShareParams;
import cn.sharesdk.onekeyshare.ShareContentCustomizeCallback;
import cn.sharesdk.wechat.favorite.WechatFavorite;
import cn.sharesdk.wechat.friends.Wechat;
import cn.sharesdk.wechat.moments.WechatMoments;
public class ShareContentCustomize implements ShareContentCustomizeCallback {
	private String  mShareUrl;
	private Context mContext;
	public ShareContentCustomize(String shareURL,Context  context){
		this.mShareUrl=shareURL;
		this.mContext=context;
	}
    public void onShare(Platform platform, ShareParams paramsToShare) {
            if (Wechat.NAME.equals(platform.getName())) {
            	ShareParams wechat = new ShareParams();
    			wechat.setText("美丽记录分享");
    			wechat.setImageUrl("");
    			wechat.setUrl(mShareUrl);
    			wechat.setShareType(Platform.SHARE_WEBPAGE);
    			Platform weixin = ShareSDK.getPlatform(mContext,Wechat.NAME);
    			weixin.share(wechat);
            }
            else if(WechatMoments.NAME.equals(platform.getName())){
            	ShareParams wechatMoments = new ShareParams();
            	wechatMoments.setText("美丽记录分享");
            	wechatMoments.setImageUrl("");
    			wechatMoments.setUrl(mShareUrl);
    			wechatMoments.setShareType(Platform.SHARE_WEBPAGE);
    			Platform weixin = ShareSDK.getPlatform(mContext, WechatMoments.NAME);
    			weixin.share(wechatMoments);
            }
            else if(WechatFavorite.NAME.equals(platform.getName())){
            	ShareParams wechatFavorite = new ShareParams();
            	wechatFavorite.setText("美丽记录分享");
            	wechatFavorite.setImageUrl("");
            	wechatFavorite.setUrl(mShareUrl);
            	wechatFavorite.setShareType(Platform.SHARE_WEBPAGE);
    			Platform weixin = ShareSDK.getPlatform(mContext,WechatFavorite.NAME);
    			weixin.share(wechatFavorite);
            }
    }

}
