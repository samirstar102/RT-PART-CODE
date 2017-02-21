package com.rover.rovertown.Activity;

import android.app.Dialog;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;

import com.rover.rovertown.R;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.rover.rovertown.Rest.RTRestCallback;

/**
 * Implementation of RootActivity
 * @author Samir on 06/05/15.
 */
public class RootActivity extends AppCompatActivity {
    int onStartCount = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        RTRestCallback.setContext(this);

        ActionBar actionBar = getSupportActionBar();
        actionBar.hide();

        onStartCount = 1;
        if (savedInstanceState == null) // 1st time
        {
            //this.overridePendingTransition(R.anim.activity_slidein_left,
                    //R.anim.activity_slideout_left);
        } else // already created so reverse animation
        {
            onStartCount = 2;
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (onStartCount > 1) {
            //this.overridePendingTransition(R.anim.activity_slidein_right,
                    //R.anim.activity_slideout_right);

        } else if (onStartCount == 1) {
            onStartCount++;
        }
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
    }

    @Override
    protected void onResume() {
        super.onResume();

        int gsStatus = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
        if (gsStatus != ConnectionResult.SUCCESS)
        {
            Dialog errDlg = GooglePlayServicesUtil.getErrorDialog(gsStatus, this, 7);
            if (errDlg != null) {
                errDlg.show();
            }
        }
    }
}