package cn.com.wannian.testsocketim.bean;

import java.util.List;

/**
 * Created by Wan.N
 * Date      :2017/1/3
 * Desc      :${TODO}
 */

public class NetFriendList extends NetBaseBean {
    private List<UserBean> data;

    public NetFriendList() {
    }

    public List<UserBean> getData() {
        return data;
    }

    public void setData(List<UserBean> data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "NetFriendList{" +
                "data=" + data +
                '}';
    }
}
