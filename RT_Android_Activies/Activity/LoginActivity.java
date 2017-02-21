package com.rover.rovertown.Activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.transition.ChangeBounds;
import android.support.transition.Transition;
import android.support.transition.TransitionManager;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.flurry.android.FlurryAgent;
import com.rover.rovertown.Application.RTApplication;
import com.rover.rovertown.Listener.AWSDownloadFileCompletedListener;
import com.rover.rovertown.Model.Authentication;
import com.rover.rovertown.Model.AuthenticationData;
import com.rover.rovertown.Model.BaseResponse;
import com.rover.rovertown.Model.Majors;
import com.rover.rovertown.Model.MajorsData;
import com.rover.rovertown.Model.RestError;
import com.rover.rovertown.Model.User;
import com.rover.rovertown.R;
import com.rover.rovertown.Rest.RTRestCallback;
import com.rover.rovertown.Rest.RTService;
import com.rover.rovertown.Util.RTAWSManager;
import com.rover.rovertown.Util.RTAlertDialog;
import com.rover.rovertown.Util.RTCommonHelper;
import com.rover.rovertown.Util.RTConstants;
import com.rover.rovertown.Util.RTImageUtil;
import com.rover.rovertown.Util.RTSharedPreferenceHelper;

import java.io.InputStream;
import java.util.List;

import retrofit.client.Response;

/*
    Using the Transitions Framework so I don't have to write animations. Using a backport to get it down
    to api 14. Tested on API 15 and it worked
 */
public class LoginActivity extends RootActivity {

    private enum LoginState {
        INITIAL,
        LOADING,
        FAILURE,
        VERIFIED
    }

    private ViewGroup mSceneRoot;

    private Button btnContinue;
    private ViewGroup loadingContainer;
    private ImageView ivLoading;
    private RelativeLayout warningContainer;
    private TextView tvWarning;
    private TextView tvLoading;
    private TextView tvWarningDesc;
    private EditText etReferral;
    private EditText etEmail;
    private Animation animRotate;
    private AuthenticationData authData;
    private TextWatcher tw, tw2;

    private RTAWSManager awsManager;

    private boolean hasSubmittedReferral;

    private int whatDownloadingNow = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_final);

        btnContinue = (Button) findViewById(R.id.btn_continue);
        loadingContainer = (ViewGroup) findViewById(R.id.loadingLayout);
        ivLoading = (ImageView) findViewById(R.id.img_loading);
        warningContainer = (RelativeLayout) findViewById(R.id.warning_container);
        tvWarning = (TextView) findViewById(R.id.lbl_warning);
        tvLoading = (TextView) findViewById(R.id.lbl_loadingLabel);
        tvWarningDesc = (TextView) findViewById(R.id.lbl_warning_description);
        etReferral = (EditText) findViewById(R.id.et_referral);
        etEmail = (EditText) findViewById(R.id.txt_email);
        animRotate = AnimationUtils.loadAnimation(ivLoading.getContext(), R.anim.rotate_simple);

        mSceneRoot = (ViewGroup) findViewById(R.id.login_layout);

        awsManager = new RTAWSManager(this);

        tw = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                TransitionManager.beginDelayedTransition(mSceneRoot);
                setUpTransition(LoginState.INITIAL);
            }
        };

        setUpTransition(LoginState.INITIAL);
    }

    private void setUpTransition(LoginState state) {
        switch (state) {
            case INITIAL:
                hasSubmittedReferral = false;

                // hide or show any views that could have changed
                alignBottom(warningContainer, R.id.et_referral);
                alignBottom(tvWarningDesc, R.id.btn_continue);
                etEmail.removeTextChangedListener(tw);
                etReferral.removeTextChangedListener(tw);

                // set up what clicks do in this state
                btnContinue.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TransitionManager.beginDelayedTransition(mSceneRoot);
                        setUpTransition(LoginState.LOADING);
                    }
                });

                break;
            case LOADING:
                etEmail.clearFocus();
                etReferral.clearFocus();

                moveBelow(loadingContainer, R.id.btn_continue);
                alignBottom(warningContainer, R.id.et_referral);
                alignBottom(tvWarningDesc, R.id.btn_continue);
                etEmail.removeTextChangedListener(tw);
                etReferral.removeTextChangedListener(tw);

                // start loading animation
                ivLoading.startAnimation(animRotate);

                // hide keyboard
                View view = getCurrentFocus();
                if (view != null) {
                    InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                }

                // begin standard login procedure
                RTService.get().authenticate(etEmail.getText().toString(), RTCommonHelper.getDeviceUID(), new RTRestCallback<Authentication>() {
                    @Override
                    public void failure(RestError restError) {
                        FlurryAgent.logEvent("user_login_failure"); // Failed to authenticate

                        tvWarning.setText(restError.getStatus());

                        switch (restError.getCode()) {
                            case 404:
                                tvWarningDesc.setText(R.string.School_Not_Registered_Description);
                                break;
                            case RTConstants.RTERR_NO_NETWORK:
                                tvWarning.setText(R.string.MSG_Unable_To_ResolveHost);
                                tvWarning.setText(R.string.MSG_Check_Internet);
                                break;
                            default:
                                tvWarningDesc.setText("Sorry, " + restError.getStatus());
                                break;
                        }
                        TransitionManager.beginDelayedTransition(mSceneRoot);
                        setUpTransition(LoginState.FAILURE);
                    }

                    @Override
                    public void success(Authentication authentication, Response response) {
                        RTSharedPreferenceHelper.setAuthTimeStamp();

                        authData = authentication.getAuthenticationData();

                        RTService.setUserToken(authData.getToken());
                        RTService.setUserID(authData.getUserId());
                        RTSharedPreferenceHelper.saveLogin(authentication.getAuthenticationData());

                        tvLoading.setText(R.string.Retrieving_Me);

                        String referralCode = etReferral.getText().toString();
                        if (!referralCode.isEmpty()) {
                            hasSubmittedReferral = true;

                            RTService.get().submitReferral(RTCommonHelper.getDeviceUID(), referralCode, new RTRestCallback<BaseResponse>() {
                                @Override
                                public void failure(RestError restError) {
                                    tvWarning.setText(restError.getStatus());
                                    // 404 means the code was not found
                                    switch (restError.getCode()) {
                                        // We need to confirm what message should be shown when we get 401, 403 errors.
                                        case 401:
                                        case 403:
                                            tvWarningDesc.setText(R.string.GetMe_Failed_Desc);
                                            break;
                                        case 404:
                                            tvWarning.setText(R.string.referral_code_error);
                                            tvWarningDesc.setText(R.string.referral_code_error_desc);
                                            break;
                                        case RTConstants.RTERR_NO_NETWORK:
                                            tvWarning.setText(R.string.MSG_Unable_To_ResolveHost);
                                            tvWarningDesc.setText(R.string.MSG_Check_Internet);
                                            break;
                                        default:
                                            tvWarningDesc.setText("Sorry, " + restError.getStatus());
                                            break;
                                    }
                                    TransitionManager.beginDelayedTransition(mSceneRoot);
                                    setUpTransition(LoginState.FAILURE);
                                }

                                @Override
                                public void success(BaseResponse baseResponse, Response response) {
                                    getUserInfo(); // helper since we need two enter points
                                }
                            });
                        } else {
                            getUserInfo();
                        }
                    }
                });

                break;
            case FAILURE:
                hasSubmittedReferral = false;

                alignBottom(loadingContainer, R.id.btn_continue);
                moveBelow(warningContainer, R.id.et_referral);
                moveBelow(tvWarningDesc, R.id.btn_continue);
                etEmail.addTextChangedListener(tw);
                etReferral.addTextChangedListener(tw);

                btnContinue.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TransitionManager.beginDelayedTransition(mSceneRoot);
                        setUpTransition(LoginState.LOADING);
                    }
                });

                break;
            case VERIFIED:
                alignBottom(loadingContainer, R.id.btn_continue);

                TextView tvDesc = (TextView) findViewById(R.id.lbl_description);
                TextView lblSuccess = (TextView) findViewById(R.id.lbl_succ_email);
                TextView tvReferralAccepted = (TextView) findViewById(R.id.tv_referral_accepted);

                etEmail.setKeyListener(null);

                lblSuccess.setText(RTSharedPreferenceHelper.getEmail());

                // since these states are never changed anywhere else, keep them up here
                // show verified page
                RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) tvDesc.getLayoutParams();
                lp.addRule(RelativeLayout.ALIGN_TOP, 0);
                lp.addRule(RelativeLayout.BELOW, R.id.successTopLayout);
                tvDesc.setLayoutParams(lp);

                // show referral accepted code
                if (hasSubmittedReferral) {
                    moveBelow(tvReferralAccepted, R.id.btn_continue);
                }

                btnContinue.setText("OK");
                btnContinue.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        RTSharedPreferenceHelper.saveFirstLaunch();

                        Intent intent = new Intent(v.getContext(), NavigationBaseActivity.class);
                        startActivity(intent);

                        finish();
                    }
                });

                findViewById(R.id.successTopLayout).setVisibility(View.VISIBLE);

                // change to verified text
                tvDesc.setText(R.string.Login_Success_Description);

                if (hasSubmittedReferral)
                    RTSharedPreferenceHelper.saveReferralSubmission(true);

                RTSharedPreferenceHelper.saveFirstLaunch();
                RTSharedPreferenceHelper.initFirstLoginPreferences();

                break;
        }
    }

    private void getUserInfo() {

        RTService.get().getUser(new RTRestCallback<User>() {
            @Override
            public void success(User user, Response response) {
                RTSharedPreferenceHelper.setUser(user);

                final RTRestCallback<User> callback1 = this;
                RTService.get().getMajors(new RTRestCallback<Majors>() {
                    @Override
                    public void success(Majors majors, Response response) {
                        List<MajorsData> majorsData = majors.getMajors();
                        ((RTApplication) getApplicationContext()).setMajorList(majorsData);

                        TransitionManager.beginDelayedTransition(mSceneRoot);
                        setUpTransition(LoginState.VERIFIED);
                    }

                    @Override
                    public void failure(RestError restError) {
                        callback1.failure(restError);
                    }
                });
            }

            @Override
            public void failure(RestError restError) {
                FlurryAgent.logEvent("user_login_failure"); // "Failed to get user information"

                tvWarning.setText(R.string.GetMe_Failed);

                switch (restError.getCode()) {
                    // We need to confirm what message should be shown when we get 401, 403 errors.
                    case 401:
                    case 403:
                        tvWarningDesc.setText(R.string.GetMe_Failed_Desc);
                        break;
                    case RTConstants.RTERR_NO_NETWORK:
                        tvWarning.setText(R.string.MSG_Unable_To_ResolveHost);
                        tvWarningDesc.setText(R.string.MSG_Check_Internet);
                        break;
                    default:
                        tvWarningDesc.setText("Sorry, " + restError.getStatus());
                        break;
                }
                TransitionManager.beginDelayedTransition(mSceneRoot);
                setUpTransition(LoginState.FAILURE);
            }
        });
    }

    // hide view by moving the view to allign bottom with another one
    private void alignBottom(View viewToMove, int idToAllignBottom) {
        RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) viewToMove.getLayoutParams();
        lp.addRule(RelativeLayout.BELOW, 0);
        lp.addRule(RelativeLayout.ALIGN_BOTTOM, idToAllignBottom);
        viewToMove.setLayoutParams(lp);
    }
    // show view by moving the view below the one it was hiding behind
    private void moveBelow(View viewToMove, int idToMoveBelow) {
        RelativeLayout.LayoutParams lp = (RelativeLayout.LayoutParams) viewToMove.getLayoutParams();
        lp.addRule(RelativeLayout.ALIGN_BOTTOM, 0);
        lp.addRule(RelativeLayout.BELOW, idToMoveBelow);
        viewToMove.setLayoutParams(lp);
    }

}
