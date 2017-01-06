package cn.com.wannian.testsocketim.bean;

import java.io.Serializable;

/**
 * Created by Wan.N
 * Date      :2017/1/3
 * Desc      :${TODO}
 */

public class UserBean implements Serializable {
    private String userID;
    private String userName;
    private int state;

    public UserBean() {
    }

    public UserBean(String userID, String userName, int state) {
        this.userID = userID;
        this.userName = userName;
        this.state = state;
    }

    public String getUserID() {
        return userID;
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        UserBean userBean = (UserBean) o;

        return userID != null ? userID.equals(userBean.userID) : userBean.userID == null;

    }

    @Override
    public int hashCode() {
        return userID != null ? userID.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "UserBean{" +
                "userID='" + userID + '\'' +
                ", userName='" + userName + '\'' +
                ", state='" + state + '\'' +
                '}';
    }
}
