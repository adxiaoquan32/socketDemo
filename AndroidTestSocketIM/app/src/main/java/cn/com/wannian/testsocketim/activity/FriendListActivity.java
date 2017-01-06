package cn.com.wannian.testsocketim.activity;

import android.content.Intent;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Process;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import cn.com.wannian.testsocketim.eventbean.EventLocalMsg;
import cn.com.wannian.testsocketim.bean.FriendListBean;
import cn.com.wannian.testsocketim.bean.MsgBean;
import cn.com.wannian.testsocketim.MyApplication;
import cn.com.wannian.testsocketim.bean.NetFriendList;
import cn.com.wannian.testsocketim.bean.NetMsgBean;
import cn.com.wannian.testsocketim.bean.NetUserInfo;
import cn.com.wannian.testsocketim.R;
import cn.com.wannian.testsocketim.service.SocketService;
import cn.com.wannian.testsocketim.bean.UserBean;
import de.greenrobot.event.EventBus;
import de.greenrobot.event.Subscribe;
import de.greenrobot.event.ThreadMode;

/**
 * Created by Wan.N
 * Date      :2017/1/4
 * Desc      :好友列表界面
 */

public class FriendListActivity extends AppCompatActivity {
    private static final String TAG = FriendListActivity.class.getSimpleName();
    private List<FriendListBean> friendlistdata = new ArrayList<>();
    private FriendListAdapter adapter;
    private Drawable mDivider;
    private boolean recordUnreadCount = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chatroom_activity);
        setTitle(MyApplication.userBean.getUserName() + "的好友列表");

        EventBus.getDefault().register(this);

        RecyclerView friendlist_lv = (RecyclerView) findViewById(R.id.firends_list);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        friendlist_lv.setLayoutManager(linearLayoutManager);

        adapter = new FriendListAdapter(friendlistdata);
        friendlist_lv.setAdapter(adapter);

        TypedArray a = obtainStyledAttributes(new int[]{android.R.attr.listDivider});
        mDivider = a.getDrawable(0);
        a.recycle();

        friendlist_lv.addItemDecoration(new RecyclerView.ItemDecoration() {
            @Override
            public void onDraw(Canvas c, RecyclerView parent, RecyclerView.State state) {
                super.onDraw(c, parent, state);
                int left = parent.getPaddingLeft();
                int right = parent.getWidth() - parent.getPaddingRight();

                int childCount = parent.getChildCount();
                for (int i = 0; i < childCount; i++) {
                    View child = parent.getChildAt(i);
                    RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child
                            .getLayoutParams();
                    int top = child.getBottom() + params.bottomMargin;
                    int bottom = top + mDivider.getIntrinsicHeight();
                    mDivider.setBounds(left, top, right, bottom);
                    mDivider.draw(c);
                }
            }

            @Override
            public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
                super.getItemOffsets(outRect, view, parent, state);
                outRect.set(0, 0, 0, mDivider.getIntrinsicHeight());
            }
        });
        intiIntent();
    }

    private void intiIntent() {
        Intent intent = getIntent();
        if (intent != null && intent.hasExtra("friendList")) {
            NetFriendList netfriendList = (NetFriendList) intent.getSerializableExtra("friendList");
            updateFriendList(netfriendList);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        recordUnreadCount = true;
    }

    /**
     * 刷新好友基本信息列表
     *
     * @param netfriendList
     */
    private void updateFriendList(NetFriendList netfriendList) {
        if (netfriendList == null) {
            return;
        }
        friendlistdata.clear();

        List<UserBean> data = netfriendList.getData();
        FriendListBean bean;
        for (UserBean user : data) {
            bean = new FriendListBean();
            bean.setFirend(user);
            bean.setLayestMsg("");
            bean.setUnreadCount(0);
            friendlistdata.add(bean);
        }

        adapter.notifyDataSetChanged();
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void getFriendList(NetFriendList netFriendList) {
        Log.i(TAG, "getFriendList:" + netFriendList.toString());
        updateFriendList(netFriendList);
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void getFriendMsg(NetMsgBean netMsgBean) {
        Log.i(TAG, "getFriendMsg:" + netMsgBean.toString());
        if (netMsgBean == null) {
            return;
        }
        MsgBean msgBean = netMsgBean.getData();
        //保存聊天数据
        Map<String, List<NetMsgBean>> msgMap = MyApplication.msgMap;
        if (msgMap.containsKey(msgBean.getSender().getUserID())) {
            List<NetMsgBean> netMsgBeens = msgMap.get(msgBean.getSender().getUserID());
            netMsgBeens.add(netMsgBean);
        } else {
            List<NetMsgBean> netMsgBeens = new ArrayList<>();
            netMsgBeens.add(netMsgBean);
            msgMap.put(msgBean.getSender().getUserID(), netMsgBeens);
        }
        //
        for (FriendListBean firend : friendlistdata) {
            if (MyApplication.userBean.getUserID().equals(msgBean.getReceiver().getUserID()) &&
                    firend.getFirend().getUserID().equals(msgBean.getSender().getUserID())) {
                firend.setLayestMsg(msgBean.getBody());
                if (recordUnreadCount) {
                    firend.setUnreadCount(firend.getUnreadCount() + 1);
                }
                adapter.notifyDataSetChanged();
                break;
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void getFriendOnLineState(NetUserInfo netUserInfo) {
        Log.i(TAG, "getFriendOnLineState:" + netUserInfo.toString());
        if (netUserInfo == null) {
            return;
        }
        UserBean netUserInfoData = netUserInfo.getData();
        boolean isExist = false;//记录原有列表中是否有此好友
        for (FriendListBean firend : friendlistdata) {
            UserBean item = firend.getFirend();
            if (item.getUserID().equals(netUserInfoData.getUserID())) {
                //原有列表包含此好友，则刷新其在线状态
                item.setState(netUserInfoData.getState());
                item.setUserName(netUserInfoData.getUserName());
                isExist = true;
                adapter.notifyDataSetChanged();
                break;
            }
        }
        if (!isExist) {
            //原有列表不包含此好友，则加入列表
            FriendListBean bean = new FriendListBean();
            bean.setFirend(netUserInfoData);
            bean.setLayestMsg("");
            bean.setUnreadCount(0);
            friendlistdata.add(bean);
            adapter.notifyDataSetChanged();
        }
    }

    @Subscribe(threadMode = ThreadMode.MainThread)
    public void getLocalUserMsg(EventLocalMsg localMsg) {
        if (localMsg == null) {
            return;
        }
        NetMsgBean netMsgBean = localMsg.getNetMsgBean();
        if (netMsgBean == null) {
            return;
        }
        MsgBean msgBean = netMsgBean.getData();
        if (msgBean == null) {
            return;
        }
        Log.i(TAG, "getLocalUserMsg:" + msgBean.toString());
        for (FriendListBean firend : friendlistdata) {
            if (msgBean.getReceiver().getUserID().equals(firend.getFirend().getUserID())) {
                firend.setLayestMsg(msgBean.getBody());
                adapter.notifyDataSetChanged();
                break;
            }
        }
    }


    class FriendListAdapter extends RecyclerView.Adapter<MyViewHolder> {
        private List<FriendListBean> list = new ArrayList<>();
        private final LayoutInflater layoutInflater;

        public FriendListAdapter(List<FriendListBean> list) {
            this.list = list;
            layoutInflater = LayoutInflater.from(FriendListActivity.this);
        }

        @Override
        public MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view = layoutInflater.inflate(R.layout.friendlist_itemview, parent, false);
            return new MyViewHolder(view);
        }

        @Override
        public void onBindViewHolder(MyViewHolder holder, int position) {
            final FriendListBean friendlistbean = list.get(position);
            final UserBean userBean = friendlistbean.getFirend();
            if (userBean.getState() == 1) {
                holder.guest_name.setTextColor(Color.BLUE);
            } else {
                holder.guest_name.setTextColor(Color.GRAY);
            }
            holder.guest_name.setText(userBean.getUserName());
            holder.msg_content.setText(friendlistbean.getLayestMsg());
            if (friendlistbean.getUnreadCount() > 0) {
                holder.unread_count.setText(friendlistbean.getUnreadCount() + "");
            } else {
                holder.unread_count.setText("");
            }

            holder.mitemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    recordUnreadCount = false;
                    friendlistbean.setUnreadCount(0);
                    adapter.notifyDataSetChanged();
                    //
                    Intent intent = new Intent(FriendListActivity.this, ChatActivity.class);
                    intent.putExtra("friend", userBean);
                    startActivity(intent);
                }
            });
        }

        @Override
        public int getItemCount() {
            return list.size();
        }
    }

    class MyViewHolder extends RecyclerView.ViewHolder {
        View mitemView;
        TextView guest_name;
        TextView unread_count;
        TextView msg_content;

        public MyViewHolder(View itemView) {
            super(itemView);
            mitemView = itemView;
            guest_name = (TextView) itemView.findViewById(R.id.guest_name);
            unread_count = (TextView) itemView.findViewById(R.id.unread_count);
            msg_content = (TextView) itemView.findViewById(R.id.msg_content);
        }
    }

    @Override
    public void onBackPressed() {
        Log.i(TAG, "onBackPressed");
        if ((System.currentTimeMillis() - exitTime) > 2000) {
            Log.i(TAG, "再按一次");
            Toast.makeText(this, "再按一次", Toast.LENGTH_SHORT).show();
            exitTime = System.currentTimeMillis();
        } else {
            Log.i(TAG, "退出app");
            unbindSocketService();
            finish();
            Process.killProcess(Process.myPid());
            System.exit(0);
        }
    }

    private long exitTime = 0;

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK
                && event.getAction() == KeyEvent.ACTION_DOWN) {
            Log.i(TAG, "onKeyDown");
            if ((System.currentTimeMillis() - exitTime) > 2000) {
                Log.i(TAG, "再按一次");
                Toast.makeText(this, "再按一次", Toast.LENGTH_SHORT).show();
                exitTime = System.currentTimeMillis();
            } else {
                Log.i(TAG, "退出app");
                unbindSocketService();
                finish();
                Process.killProcess(Process.myPid());
                System.exit(0);
            }
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    private void unbindSocketService() {
        Intent intent = new Intent(FriendListActivity.this, SocketService.class);
        stopService(intent);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
    }
}
