package cn.com.antika.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import java.util.List;

import cn.com.antika.bean.ChatEmoji;

import cn.com.antika.business.R;

@SuppressLint("ResourceType")
public class FaceAdapter extends BaseAdapter {
    private List<ChatEmoji> data;
    private LayoutInflater inflater;
    private int size=0;

    public FaceAdapter(Context context, List<ChatEmoji> list) {
        this.inflater=LayoutInflater.from(context);
        this.data=list;
        this.size=list.size();
    }
    @Override
    public int getCount() {
        return this.size;
    }
    @Override
    public Object getItem(int position) {
        return data.get(position);
    }
    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ChatEmoji emoji=data.get(position);
        ViewHolder viewHolder=null;
        if(convertView == null) {
            viewHolder=new ViewHolder();
            convertView=inflater.inflate(R.xml.item_face,null);
            viewHolder.iv_face=(ImageView)convertView.findViewById(R.id.item_iv_face);
            convertView.setTag(viewHolder);
        } else {
            viewHolder=(ViewHolder)convertView.getTag();
        }
        if(emoji.getId() == R.drawable.face_del_icon) {
            convertView.setBackgroundDrawable(null);
            viewHolder.iv_face.setImageResource(emoji.getId());
        } 
        else if(TextUtils.isEmpty(emoji.getCharacter())) {
            convertView.setVisibility(View.GONE);
            viewHolder.iv_face.setVisibility(View.GONE);
        } else {
            viewHolder.iv_face.setTag(emoji);
            viewHolder.iv_face.setImageResource(emoji.getId());
        }
        return convertView;
    }
    class ViewHolder {
        public ImageView iv_face;
    }
}