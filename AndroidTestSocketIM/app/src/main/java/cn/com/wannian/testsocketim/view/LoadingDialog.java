package cn.com.wannian.testsocketim.view;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.text.TextUtils;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.lang.reflect.Field;

import cn.com.wannian.testsocketim.R;

/**
 * */
public class LoadingDialog extends DialogFragment {
    public static String TAG = LoadingDialog.class.getSimpleName();
    private Display display;
    private Dialog dialog;
    private TextView tips_loading_msg;
    private ProgressBar mProgressBar;
    private String message = "";


    @SuppressLint("ValidFragment")
    public LoadingDialog() {
        super();
    }

    @SuppressLint("ValidFragment")
    public LoadingDialog(String text) {
        super();
        this.message=text;
    }

    private boolean isFastDismiss = false;
    private Handler mHandler = new Handler();

    @Override
    public void dismiss() {
        try {
            if (dialog != null && isShowing()) {
                super.dismiss();
            } else {
                isFastDismiss = true;
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    @Override
    public LayoutInflater getLayoutInflater(Bundle savedInstanceState) {
        return super.getLayoutInflater(savedInstanceState);
    }

    @Override
    public void setCancelable(boolean cancelable) {
        super.setCancelable(cancelable);
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        WindowManager windowManager = (WindowManager) getActivity()
                .getSystemService(Context.WINDOW_SERVICE);
        display = windowManager.getDefaultDisplay();
        LayoutInflater inflater = getActivity().getLayoutInflater();
        View view = inflater.inflate(R.layout.view_loading, null);
        mProgressBar = (ProgressBar) view.findViewById(R.id.progress_bar);
        tips_loading_msg = (TextView) view.findViewById(R.id.tips_loading_msg);

        if (!TextUtils.isEmpty(message)) {
            tips_loading_msg.setVisibility(View.VISIBLE);
            tips_loading_msg.setText(this.message);
        } else {
            tips_loading_msg.setVisibility(View.GONE);
        }
        dialog = new Dialog(getActivity(), R.style.LoadingDialogStyle);
        dialog.setContentView(view);
        //快速关闭dialog
        if (isFastDismiss) {
            isFastDismiss = false;
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    dismiss();
                }
            }, 100l);
        }
        return dialog;
    }

    public void setText(String message) {
//		this.message = message;
//		tips_loading_msg.setText(this.message);
//		if(message.length() > 0){
//			tips_loading_msg.setVisibility(View.VISIBLE);
//		}else{
//			tips_loading_msg.setVisibility(View.GONE);
//		}
    }

    public void setText(int resId) {
//		setText(getContext().getResources().getString(resId));
//		String msg = getContext().getResources().getString(resId);
//		if(msg.length() > 0){
//			tips_loading_msg.setVisibility(View.VISIBLE);
//		}else{
//			tips_loading_msg.setVisibility(View.GONE);
//		}
    }

//	public void show(){
//		super.show(activity.getSupportFragmentManager(), "LoadingDialog");
//	}

    public boolean isShowing() {
        if (null == dialog) {
            return false;
        }
        return dialog.isShowing();
    }

    @Override
    public void show(FragmentManager manager, String tag) {
        try {
            super.show(manager, tag);
        } catch (IllegalStateException e) {
            e.printStackTrace();
        }
    }

    /**
     * 在 show()之前，View  还没创建。需要在对View的操作要在show()之后。
     */
    @Override
    public int show(FragmentTransaction transaction, String tag) {
        try {
            return super.show(transaction, tag);
        } catch (IllegalStateException e) {
            return FragmentTransaction.TRANSIT_UNSET;
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        try {
            Field childFragmentManager = Fragment.class.getDeclaredField("mChildFragmentManager");
            childFragmentManager.setAccessible(true);
            childFragmentManager.set(this, null);

        } catch (NoSuchFieldException e) {
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }

    }
}
