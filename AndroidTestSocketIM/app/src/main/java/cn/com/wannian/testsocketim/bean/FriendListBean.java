package cn.com.wannian.testsocketim.bean;

import java.io.Serializable;

/**
 * Created by Wan.N
 * Date      :2017/1/5
 * Desc      :${TODO}
 */

public class FriendListBean implements Serializable {
    private UserBean firend;
    private int unreadCount;
    private String layestMsg;

    public FriendListBean() {
    }

    public UserBean getFirend() {
        return firend;
    }

    public void setFirend(UserBean firend) {
        this.firend = firend;
    }

    public int getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(int unreadCount) {
        this.unreadCount = unreadCount;
    }

    public String getLayestMsg() {
        return layestMsg;
    }

    public void setLayestMsg(String layestMsg) {
        this.layestMsg = layestMsg;
    }



    @Override
    public String toString() {
        return "FriendListBean{" +
                "firend=" + firend +
                ", unreadCount=" + unreadCount +
                ", layestMsg='" + layestMsg + '\'' +
                '}';
    }
}
