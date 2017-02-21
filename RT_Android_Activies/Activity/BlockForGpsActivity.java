package com.rover.rovertown.Activity;

import android.content.Intent;
import android.os.Bundle;
import android.provider.Settings;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.rover.rovertown.Application.RTApplication;
import com.rover.rovertown.R;
import com.flurry.android.FlurryAgent;

/**
 * Created by Jonas on 6/25/2015.
 */
public class BlockForGpsActivity extends RootActivity {
    private LinearLayout blockLayout;            // Top parent Layout of this screen.
    private Button btn_go;           // Button to go to Location setting

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_block_for_gps);

        // Flurry Log
        //FlurryAgent.logEvent("Main Activity Started", true);

        // Initialize widgets
        btn_go = (Button)this.findViewById(R.id.btn_gotogps);
        btn_go.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent callGPSSettingIntent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                startActivity(callGPSSettingIntent);
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();

        // Check the current enable status of Location service.
        if (RTApplication.gpsTracker.isGPSEnabled())
        {
            Intent mainActivity = new Intent(BlockForGpsActivity.this, NavigationBaseActivity.class);
            startActivity(mainActivity);
            finish();
        }
    }
}
