package com.rover.rovertown.Activity;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;

import com.rover.rovertown.Application.RTApplication;
import com.rover.rovertown.Model.Authentication;
import com.rover.rovertown.Model.CheckAuthentication;
import com.rover.rovertown.Model.Majors;
import com.rover.rovertown.Model.MajorsData;
import com.rover.rovertown.Model.RestError;
import com.rover.rovertown.Model.User;
import com.rover.rovertown.R;
import com.rover.rovertown.Rest.RTEndpoint;
import com.rover.rovertown.Rest.RTRestCallback;
import com.rover.rovertown.Rest.RTService;
import com.rover.rovertown.Util.RTAlertDialog;
import com.rover.rovertown.Util.RTCommonHelper;
import com.rover.rovertown.Util.RTSharedPreferenceHelper;
import com.flurry.android.FlurryAgent;

import java.util.List;

import retrofit.client.Response;

/**
 * Implementation of SplashActivity
 *
 * @author Samir Nassar (23th of April, 2015)
 */
public class SplashActivity extends Activity {

    // Splash screen keeping time.(2 seconds)
    private static int SPLASH_TIME_OUT = 1000;

    private static int UPGRADE_ACTIVITY_CODE = 1000;

    private boolean should_upgrade = false;

    private SplashActivity selfRef;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        RTRestCallback.setContext(this);
        selfRef = this;

        RTSharedPreferenceHelper.init();

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                RTApplication application = (RTApplication)getApplication();

                // testing
                //gotoStore();

                application.checkAndUpgrade(SplashActivity.this, new RTApplication.UpgradeResultListener() {
                    @Override
                    public void success(boolean need_upgrade, boolean should_do) {
                        if (need_upgrade) {
                            should_upgrade = should_do;
                            gotoStore();
                        } else{
                            initializeInformation(RTSharedPreferenceHelper.getInstance(), RTService.get());
                        }
                    }

                    @Override
                    public void failure() {
                        RTAlertDialog.showErrorAlert("We are having trouble connecting to the server right now. Check your connection and try again.", selfRef);
                    }

                });
            }
        }, SPLASH_TIME_OUT);
    }

    private void gotoStore(){
        final String appPackageName = RTApplication.App_ID; // getPackageName() from Context or Activity object
        try {
            startActivityForResult(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appPackageName)), SplashActivity.UPGRADE_ACTIVITY_CODE);
        } catch (android.content.ActivityNotFoundException anfe) {
            startActivityForResult(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + appPackageName)), SplashActivity.UPGRADE_ACTIVITY_CODE);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == SplashActivity.UPGRADE_ACTIVITY_CODE) {

            if (should_upgrade){
                RTAlertDialog.showConfirmDialog("Upgrade Fail", "You must upgrade to new version.", this, new RTAlertDialog.AlertListener() {
                    @Override
                    public void onOK() {
                    }

                    @Override
                    public void onCancel() {
                    }
                });
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        finish();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    // pass in prefHelper and endpoint for mocking purposes
    protected void initializeInformation(final RTSharedPreferenceHelper prefHelper, final RTEndpoint endpoint) {
        // Handler for SPLASH_TIME_OUT
        new Handler().postDelayed(new Runnable() {

            // Showing activity_splash screen with a timer.
            @Override
            public void run() {

                // check if device id is in system
                RTService.get().checkAuthentication(RTCommonHelper.getDeviceUID(), new RTRestCallback<CheckAuthentication>() {
                    @Override
                    public void failure(RestError restError) {
                        // device has never logged in, go to login
                        // saveFirstLaunch should probably be moved to login at some point
                        RTSharedPreferenceHelper.saveFirstLaunch();
                        JumpToLogin();
                    }

                    @Override
                    public void success(CheckAuthentication checkAuthentication, Response response) {
                        // logged in before, attempt to log in automatically from server
                        RTService.get().authenticate(checkAuthentication.getCheckAuthenticationData().getEmail(), RTCommonHelper.getDeviceUID(), new RTRestCallback<Authentication>() {
                            @Override
                            public void failure(RestError restError) {
                                JumpToLogin();
                            }

                            @Override
                            public void success(final Authentication authentication, Response response) {
                                RTService.setUserToken(authentication.getAuthenticationData().getToken());
                                RTService.setUserID(authentication.getAuthenticationData().getUserId());
                                RTSharedPreferenceHelper.saveLogin(authentication.getAuthenticationData());

                                RTService.get().getMajors(new RTRestCallback<Majors>() {
                                    @Override
                                    public void success(Majors majors, Response response) {
                                        List<MajorsData> majorsData = majors.getMajors();
                                        ((RTApplication) getApplicationContext()).setMajorList(majorsData);

                                        if (authentication.getAuthenticationData().getLockedOut()) {
                                            // the session is not valid, must verify email
                                            startActivity(new Intent(SplashActivity.this, VerifyMailActivity.class));
                                        } else {
                                            // the session is valid, go to navigation base
                                            RTService.get().getUser(new RTRestCallback<User>() {
                                                @Override
                                                public void failure(RestError restError) {
                                                    JumpToLogin();
                                                }

                                                @Override
                                                public void success(User user, Response response) {
                                                    RTSharedPreferenceHelper.setUser(user);
                                                    JumptoHomeActivity();
                                                }
                                            });
                                        }
                                    }

                                    @Override
                                    public void failure(RestError restError) {
                                        RTAlertDialog.showErrorAlert("We are having trouble connecting to the server right now. Check your connection and try again.", selfRef);
                                    }
                                });
                            }
                        });
                    }
                });


            }
        }, SPLASH_TIME_OUT);
    }

    /**
     *
     */
    protected void JumpToLogin() {
        // Start Login Activity
        Intent loginActivity = new Intent(SplashActivity.this, LoginActivity.class);
        startActivity(loginActivity);
        finish();
    }

    /**
     * Jump to BlockGPS view instead of Home view when the GPS is disabled.
     */
    protected void JumptoHomeActivity()
    {
        FlurryAgent.setUserId(RTSharedPreferenceHelper.getEmail());
        // If we are going to home activity, then auto-login was succesfull
        FlurryAgent.logEvent("user_login");

        // Check whether GPS service is enabled or not in device.
        if (!RTApplication.gpsTracker.isGPSEnabled()) {
            Intent blockActivity = new Intent(SplashActivity.this, BlockForGpsActivity.class);
            startActivity(blockActivity);
            finish();
        } else {
            Intent mainActivity = new Intent(SplashActivity.this, NavigationBaseActivity.class);
            startActivity(mainActivity);
            finish();
        }
    }
}
