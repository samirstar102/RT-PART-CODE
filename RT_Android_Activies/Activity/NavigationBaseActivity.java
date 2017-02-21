package com.rover.rovertown.Activity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.graphics.Point;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewTreeObserver;
import android.view.animation.Animation;
import android.widget.FrameLayout;

import com.afollestad.materialdialogs.MaterialDialog;
import com.flurry.android.FlurryAgent;
import com.rover.rovertown.Adapters.SidemenuAdapter;
import com.rover.rovertown.Application.RTApplication;
import com.rover.rovertown.CustomView.TutorialView;
import com.rover.rovertown.Fragment.Container.ActivityFeedContainerFragment;
import com.rover.rovertown.Fragment.Container.BoneBadgeContainerFragment;
import com.rover.rovertown.Fragment.Container.BusinessContainerFragment;
import com.rover.rovertown.Fragment.Container.DiscountContainerFragment;
import com.rover.rovertown.Fragment.Container.MyProfileContainerFragment;
import com.rover.rovertown.Fragment.Container.SubmitDiscountContainerFragment;
import com.rover.rovertown.Fragment.Container.SupportContainerFragment;
import com.rover.rovertown.Fragment.DiscountMainFragment;
import com.rover.rovertown.Fragment.D4DMainFragment;
import com.rover.rovertown.Fragment.ProfileStudentIDFragment2;
import com.rover.rovertown.Fragment.RedeemDiscountFragment;
import com.rover.rovertown.ListItem.DiscountItem;
import com.rover.rovertown.ListItem.TutorialItem;
import com.rover.rovertown.Listener.RecyclerItemClickListener;
import com.rover.rovertown.Listener.ShareListener;
import com.rover.rovertown.Model.BaseResponse;
import com.rover.rovertown.Model.DiscountData;
import com.rover.rovertown.Model.RestError;
import com.rover.rovertown.Model.User;
import com.rover.rovertown.R;
import com.rover.rovertown.Rest.RTRestCallback;
import com.rover.rovertown.Rest.RTService;
import com.rover.rovertown.Service.RTGcmRegistrationIntentService;
import com.rover.rovertown.Util.RTAlertDialog;
import com.rover.rovertown.Util.RTConstants;
import com.rover.rovertown.Util.RTFragmentManager;
import com.rover.rovertown.Util.RTGPSTracker;
import com.rover.rovertown.Util.RTMock;
import com.rover.rovertown.Util.RTSharedPreferenceHelper;
import com.rover.rovertown.Util.RTToolbar;
import com.rover.rovertown.ViewModel.SideMenuItemModel;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

import java.util.ArrayList;

import it.sephiroth.android.library.tooltip.TooltipManager;
import retrofit.client.Response;

/**
 * Implementation of Base Activity to show Navigation menu and each of it's content.
 * This activity is started after Tip page of the explanation.
 *
 * Created by Samir on 07/05/15.
 */
public class NavigationBaseActivity extends RootActivity implements FragmentManager.OnBackStackChangedListener {

    private static final long DEFAULT_ANIM_TIME = 300;

    private BroadcastReceiver mGcmRegBroadcastReceiver;
    NavigationBaseActivity selfRef;

    private RTToolbar toolbarManager;
    private DrawerLayout mDrawerLayout;
    private RecyclerView mSideMenuView;
    private SidemenuAdapter mSideMenuAdapter;
    private RecyclerView.LayoutManager mSideMenuLayoutManager;
    private ActionBarDrawerToggle mDrawerToogle;
    private FrameLayout contentLayout;
    private TutorialView tutorialView;

    private RTFragmentManager mOwnFragmentManager;
    private FragmentManager fragmentManager;

    private ShareListener shareListener;
    private BackwardListener backwardListener;

    private User mUser;

    private Point size;
    private boolean touchModeDisabled;
    private ArrayList<View> mClickableViews;
    private float startX, startY;

    private TutorialItem mTutorialItem;
    private DiscountMainFragment mTutorialFragment;

    public static final int TOOLTIP_ID = 0;

    private enum NotificationStatus {
        ONCREATE,
        NEWINTENT
    }

    public enum TutorialStep {
        OPEN_DISCOUNT,
        REDEEM_DISCOUNT
    }

    @Override
    protected void onCreate(Bundle savedInstance) {
        super.onCreate(savedInstance);

        RTRestCallback.setContext(this);
        selfRef = this;

        // For temp
        setContentView(R.layout.activity_navigation_base);
        mDrawerLayout = (DrawerLayout)findViewById(R.id.layout_navigationBase);  // Drawer object Assigned to the view
        contentLayout = (FrameLayout)findViewById(R.id.rl_fragment_layout);
        tutorialView = (TutorialView) findViewById(R.id.tutorial_slide);

        tutorialView.setOnExitListener(new TutorialView.OnExitListener() {
            @Override
            public void onExit(int step) {
                TooltipManager.getInstance().hide(TOOLTIP_ID);
                RTSharedPreferenceHelper.dismissTutorial();
                touchModeDisabled = false;
                DiscountMainFragment mainFragment = mOwnFragmentManager.popFullBackStack();
                mainFragment.resetFragment();
            }
        });

        size = new Point();
        Display display = getWindowManager().getDefaultDisplay();
        display.getSize(size);

        initSideMenu();

        // Init fragment manager
        fragmentManager = getSupportFragmentManager();
        fragmentManager.addOnBackStackChangedListener(this);
        mOwnFragmentManager = new RTFragmentManager(getSupportFragmentManager());

        // Init ToolBar
        toolbarManager = new RTToolbar(this, mDrawerLayout, fragmentManager);

        toolbarManager.setBoneCount(RTSharedPreferenceHelper.getUser().getUserData().getBoneCount());

        if(savedInstance == null) {

            // Set Auth token to service instance again for push notification
            RTService.setUserToken(RTSharedPreferenceHelper.getAuthToken());
            RTService.setUserID(RTSharedPreferenceHelper.getEmail());

            checkPushNotification(NotificationStatus.ONCREATE);
        }

        // Init GCM to get token from InstanceID
        mGcmRegBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                SharedPreferences sharedPreferences =
                        PreferenceManager.getDefaultSharedPreferences(context);
                boolean sentToken = sharedPreferences
                        .getBoolean(RTConstants.SENT_TOKEN_TO_SERVER, false);
            }
        };

        // Rovertown uses google service for GCM and need to check google service on main activity.
        // Check google service is available, if not prompt it to user.
        if (checkPlayServices()) {
            // Start IntentService to register this application with GCM.
            Intent intent = new Intent(this, RTGcmRegistrationIntentService.class);
            startService(intent);
        }

        final Context mContext = this;

        // user exists in shared pref after splash screen, login screen or verify screen
        mUser = RTSharedPreferenceHelper.getUser();

        // ************************ REMINDER TO VERIFY ************************** //
        final boolean condition1 = RTSharedPreferenceHelper.isPastHour(24) && RTSharedPreferenceHelper.getNumTimesDismissedVerify() == 0;
        final boolean condition2 = RTSharedPreferenceHelper.isPastHour(48) && RTSharedPreferenceHelper.getNumTimesDismissedVerify() == 0;
        final boolean condition3 = RTSharedPreferenceHelper.isPastHour(48) && RTSharedPreferenceHelper.getNumTimesDismissedVerify() == 1;

        // show reminder to verify dialog
        if (!mUser.getUserData().getVerified() && RTSharedPreferenceHelper.getFirstLaunchTime() != 0 && (
                condition1 || condition2 || condition3)) {

            RTAlertDialog.getNotificationStyleDialog(mContext)
                    .content(getString(R.string.verify_reminder))
                    .positiveText("Help")
                    .negativeText("Dismiss")
                    .callback(new MaterialDialog.ButtonCallback() {
                        @Override
                        public void onPositive(MaterialDialog dialog) {
                            RTSharedPreferenceHelper.dismissVerifyReminder();
                            // Do not want to show again if past 48 and first time seeing it
                            if (condition2)
                                RTSharedPreferenceHelper.dismissVerifyReminder();

                            Intent intent = new Intent(dialog.getContext(), VerifyMailActivity.class);
                            intent.putExtra(VerifyMailActivity.FROM_REMINDER, true);
                            dialog.cancel();
                            dialog.getContext().startActivity(intent);
                        }

                        @Override
                        public void onNegative(MaterialDialog dialog) {
                            RTSharedPreferenceHelper.dismissVerifyReminder();
                            // Do not want to show again if past 48 and first time seeing it
                            if (condition2)
                                RTSharedPreferenceHelper.dismissVerifyReminder();

                            dialog.cancel();
                        }
                    })
                    .show();
        }

    }

    public void setShareListener(ShareListener listener) {
        shareListener = listener;
    }

    @Override
    protected void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (shareListener != null) {
            shareListener.onShare(requestCode, resultCode, data);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        setIntent(intent);
        checkPushNotification(NotificationStatus.NEWINTENT);
    }

    private void checkPushNotification(NotificationStatus notificationStatus)
    {
        Bundle extras = getIntent().getExtras();

        if(extras != null) {
            String msgType = getIntent().getStringExtra(RTConstants.GCM_MESSAGE_TYPE);
            String msgContent = getIntent().getStringExtra(RTConstants.GCM_MESSAGE_CONTENT);

            if (msgType.equals(RTConstants.GCM_TEXT_MSG)) {
                RTAlertDialog.getNormalStyleDialog(this)
                        .title(R.string.GCM_Notification_Title)
                        .content(msgContent)
                        .positiveText(R.string.Btn_OK)
                        .show();

            } else if (msgType.equals(RTConstants.GCM_BUSS_MSG)) {
                final String storeId = getIntent().getStringExtra(RTConstants.GCM_NOTIFIED_STOREID);

                RTAlertDialog.getNormalStyleDialog(this)
                        .title(R.string.GCM_Notification_Title)
                        .content(msgContent)
                        .positiveText(R.string.Btn_OK)
                        .callback(new MaterialDialog.ButtonCallback() {
                            @Override
                            public void onPositive(MaterialDialog dialog) {
                                mOwnFragmentManager.replaceFragment(BusinessContainerFragment.newInstance(storeId),
                                        RTFragmentManager.DISCOUNT_BUSINESS_FRAGMENT, RTFragmentManager.PageTransitionType.SlideIn);
                            }

                            @Override
                            public void onNegative(MaterialDialog dialog) {

                            }
                        })
                        .show();
            }

        } else {
            // Show "Student Discounts" fragment as default.
            mOwnFragmentManager.addDefaultFragment();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        if(RTService.getUserToken() != null) {
            savedInstanceState.putString(RTConstants.AUTH_TOKEN, RTService.getUserToken());
        }

        super.onSaveInstanceState(savedInstanceState);
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        if(savedInstanceState.containsKey(RTConstants.AUTH_TOKEN)) {
            RTService.setUserToken(savedInstanceState.getString(RTConstants.AUTH_TOKEN));
        }

        super.onRestoreInstanceState(savedInstanceState);
    }

    @Override
    public void onBackStackChanged() {

        // When pop to main page We reset toolbar and orientation
        if(fragmentManager.getBackStackEntryCount() > 0) {
            FragmentManager.BackStackEntry backStackEntry = fragmentManager.getBackStackEntryAt(fragmentManager.getBackStackEntryCount() - 1);

            mSideMenuAdapter.setSelectedItemPosByTag(backStackEntry.getName());

            String lastFragmentTag = backStackEntry.getName();
            if(lastFragmentTag.equals(RTFragmentManager.DISCOUNT_MAIN_FRAGMENT))
            {
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                toolbarManager.initDiscountMainToolbar();
                toolbarManager.setTitle(getString(R.string.DiscountMainPageTitle));

                // current best solution, may change later
                Fragment mainFrag = fragmentManager.findFragmentByTag(RTFragmentManager.DISCOUNT_MAIN_FRAGMENT);
                ((DiscountMainFragment) mainFrag).showBoneAndBadgesAnimation();
            }
        } else {
            Fragment currFragment = fragmentManager.findFragmentByTag(RTFragmentManager.DISCOUNT_BUSINESS_FRAGMENT);

            // We need to confirm that the last fragment is Business View,
            // if so we need to add Discount View.
            if (currFragment != null) {
                mOwnFragmentManager.addDefaultFragment();
            } else {
                // We need to finish app when the stack buffer is empty,
                // otherwise there would be empty screen and user can't interact with discounts at that moment.
                this.finish();
            }
        }
    }

    public RTToolbar getToolbar()
    {
        return toolbarManager;
    }

    public RTFragmentManager getOwnFragmentManager() {
        return this.mOwnFragmentManager;
    }

    public FragmentManager getActivityFragmentManager() {
        return this.fragmentManager;
    }

    /**
     * Init Side Menu
     */
    public void initSideMenu()
    {
        // Init SideMenu
        mSideMenuView = (RecyclerView)findViewById(R.id.rv_sideMenu);
        mSideMenuView.setHasFixedSize(true);
        mSideMenuAdapter = new SidemenuAdapter(RTMock.getSideMenuItems(this), RTSharedPreferenceHelper.getEmail(),
                R.layout.rt_sidemenu_header, R.layout.rt_sidemenu_item, R.layout.rt_sidemenu_share, this);
        mSideMenuView.setAdapter(mSideMenuAdapter);
        mSideMenuLayoutManager = new LinearLayoutManager(this);
        mSideMenuView.setLayoutManager(mSideMenuLayoutManager);

        mSideMenuAdapter.setOnItemClickListener(new RecyclerItemClickListener<SideMenuItemModel>() {
            @Override
            public void onItemClick(View view, SideMenuItemModel discountListViewModel) {
                goToSideMenuPage(discountListViewModel.getItemType());
            }
        });

        mDrawerToogle = new ActionBarDrawerToggle(this, mDrawerLayout, R.string.side_menu_open, R.string.side_menu_close) {
            // I override this to move content to animate right and left when menu open and hide.
            @Override
            public void onDrawerSlide(View drawerView, float slideOffset) {
                float moveFactor = (mSideMenuView.getWidth() * slideOffset);
                if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
                    contentLayout.setTranslationX(moveFactor);
                }
            }
        };
        mDrawerLayout.setDrawerListener(mDrawerToogle);
    }

    public void goToSideMenuPage(SideMenuItemModel.SideMenuItemType itemType)
    {
        mDrawerLayout.closeDrawer(Gravity.LEFT);
        mSideMenuAdapter.setSelectedItemByType(itemType);
        switch(itemType)
        {
            case DISCOUNT:
                // If the current fragment is the same as the new one, DO NOT INSTANIATE A NEW FRAGMENT
                if (!mOwnFragmentManager.currFragmentIsOfClass(DiscountMainFragment.class)) {
                    mOwnFragmentManager.replaceFragment(DiscountMainFragment.newInstance(),
                            RTFragmentManager.DISCOUNT_MAIN_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            case FEED:
                if (!mOwnFragmentManager.currFragmentIsOfClass(ActivityFeedContainerFragment.class)) {
                    FlurryAgent.logEvent("user_activity_view");
                    mOwnFragmentManager.replaceFragment(ActivityFeedContainerFragment.newInstance(),
                            RTFragmentManager.ACTIVITY_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            case PROFILE:
                if (!mOwnFragmentManager.currFragmentIsOfClass(MyProfileContainerFragment.class)) {
                    mOwnFragmentManager.replaceFragment(MyProfileContainerFragment.newInstance(RTSharedPreferenceHelper.getUser(), true),
                            RTFragmentManager.PROFILE_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            case STUDENT_ID:
                if (!mOwnFragmentManager.currFragmentIsOfClass(ProfileStudentIDFragment2.class)) {
                    mOwnFragmentManager.replaceFragment(ProfileStudentIDFragment2.newInstance(),
                            RTFragmentManager.STUDENT_ID_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            case DOLLAR:
                if (!mOwnFragmentManager.currFragmentIsOfClass(D4DMainFragment.class)) {
                    FlurryAgent.logEvent("user_dollars_view");
                    mOwnFragmentManager.replaceFragment(D4DMainFragment.newInstance(),
                            RTFragmentManager.D4D_MAIN_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            case BONE_BADGE:
                if (!mOwnFragmentManager.currFragmentIsOfClass(BoneBadgeContainerFragment.class)) {
                    mOwnFragmentManager.replaceFragment(BoneBadgeContainerFragment.newInstance(),
                            RTFragmentManager.BONE_BADGE_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            case SUBMIT_DISCOUNT:
                if (!mOwnFragmentManager.currFragmentIsOfClass(SubmitDiscountContainerFragment.class)) {
                    mOwnFragmentManager.replaceFragment(SubmitDiscountContainerFragment.newInstance(),
                            RTFragmentManager.SUBMIT_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            case SUPPORT:
                if (!mOwnFragmentManager.currFragmentIsOfClass(SupportContainerFragment.class)) {
                    mOwnFragmentManager.replaceFragment(SupportContainerFragment.newInstance(false, null),
                            RTFragmentManager.SUPPORT_CONTAINER_FRAGMENT, RTFragmentManager.PageTransitionType.None);
                }
                break;
            default:
                break;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        getGPSEnabled();

        LocalBroadcastManager.getInstance(this).registerReceiver(mGcmRegBroadcastReceiver,
                new IntentFilter(RTConstants.REGISTRATION_COMPLETE));

    }

    public void setBackwardListener(BackwardListener listener) {
        backwardListener = listener;
    }

    // On android, back button while searching should exit search and return to standard
    @Override
    public void onBackPressed() {
        if (touchModeDisabled) {
            RTAlertDialog.showOkCancelDialog("Exit Tutorial", getString(R.string.tutorial_exit),
                    this, new RTAlertDialog.AlertListener() {
                        @Override
                        public void onOK() {
                            getTutorialView().exitTutorial();
                        }

                        @Override
                        public void onCancel() {
                        }
                    });
            return;
        }

        int backStackCount = getSupportFragmentManager().getBackStackEntryCount();

        if (backStackCount > 0) {
            // Check current fragment tag, make sure it is DISCOUNT_MAIN_FRAGMENT
            String tag = getSupportFragmentManager().getBackStackEntryAt(backStackCount - 1).getName();

            if (tag.equals(RTFragmentManager.DISCOUNT_MAIN_FRAGMENT)) {
                DiscountMainFragment mainFragment = (DiscountMainFragment) getSupportFragmentManager().findFragmentByTag(tag);

                // cancel search if back pressed
                if (mainFragment.searchButtonPressed) {
                    mainFragment.showCancel();
                    return;
                }
            }
        }
        super.onBackPressed();
    }

    /**
     * This function is made to get the Location service to be enabled.
     * Please use this function to get the GPS Tracker in this Activity.
     * @return GPSTracker instance which was created in Application.
     */
    public RTGPSTracker getGPSEnabled()
    {
        if (!RTApplication.gpsTracker.isGPSEnabled())
        {
            Intent mainActivity = new Intent(NavigationBaseActivity.this, BlockForGpsActivity.class);
            startActivity(mainActivity);
            finish();
        }

        return RTApplication.gpsTracker;
    }

    @Override
    protected void onPause() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mGcmRegBroadcastReceiver);

        RTService.get().saveAction("enter_background", "Android", new RTRestCallback<BaseResponse>() {
            @Override
            public void failure(RestError restError) {
            }

            @Override
            public void success(BaseResponse baseResponse, Response response) {
            }
        });

        super.onPause();
    }

    @Override
    protected void onStop() {
        RTService.get().saveAction("terminate", "Android", new RTRestCallback<BaseResponse>() {
            @Override
            public void failure(RestError restError) {
            }

            @Override
            public void success(BaseResponse baseResponse, Response response) {
            }
        });

        super.onStop();
    }

    private boolean checkPlayServices() {
        int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
                GooglePlayServicesUtil.getErrorDialog(resultCode, this,
                        RTConstants.PLAY_SERVICES_RESOLUTION_REQUEST).show();
            } else {
                Log.i("RovertownMainActivity", "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

    public void closeDrawer() {
        if (mDrawerLayout != null)
            mDrawerLayout.closeDrawer(Gravity.LEFT);
    }


    public TutorialView getTutorialView() {
        return tutorialView;
    }

    public interface BackwardListener {
        public boolean onBackwardPressed();
    }

    public void initTutorial() {
        touchModeDisabled = true;
    }

    // returns id of tooltip
    public int showToolTip(boolean centerHorizontal, int x, int y, String text, TooltipManager.Gravity gravity, View... clickableViews) {
        addClickableViews(clickableViews);

        Point p;
        if (!centerHorizontal)
            p = new Point(x, y);
        else
            p = new Point(size.x / 2, y);

        TooltipManager.getInstance()
                .create(this, NavigationBaseActivity.TOOLTIP_ID)
                .anchor(p, gravity)
                .closePolicy(TooltipManager.ClosePolicy.None, 100000000)
                .text(text)
                .fadeDuration(TutorialView.ANIM_DURATION)
                .show();
        return NavigationBaseActivity.TOOLTIP_ID;
    }

    public void addClickableViews(View... clickableViews) {
        mClickableViews = new ArrayList<>();
        for (View v : clickableViews)
            mClickableViews.add(v);

        // add tutorial view to clickable so that exit button works
        mClickableViews.add(tutorialView);
    }

    public Point getScreenSize() {
        return size;
    }

    // this was the best way I could think of disabling an arbitrary number of touch events
    // while allowing only a few clickable views to be selected
    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        // if not in tutorial, allow all touch events
        if (!touchModeDisabled) {
            return super.dispatchTouchEvent(ev);
        }

        // only allow "clicks" (source = http://stackoverflow.com/questions/17831395/how-can-i-detect-a-click-in-an-ontouch-listener)
        if (ev.getAction() == MotionEvent.ACTION_DOWN) {
            startX = ev.getX();
            startY = ev.getY();
            return super.dispatchTouchEvent(ev);
        }

        // if we've moved past default slop, consume the event (only register clicks)
        int systemSlop = ViewConfiguration.get(this).getScaledTouchSlop();
        float diffX = Math.abs(ev.getX() - startX);
        float diffY = Math.abs(ev.getY() - startY);
        if (diffX >= systemSlop || diffY >= systemSlop)
            return true;

        if (ev.getAction() == MotionEvent.ACTION_UP) {
            if (withinArea(startX, startY, mClickableViews))
                return super.dispatchTouchEvent(ev);
            else
                return true;
        }

        // default to returning the touch event
        return super.dispatchTouchEvent(ev);
    }

    private boolean withinArea(float startX, float startY, ArrayList<View> clickableViews) {
        for (View v : clickableViews) {
            int[] viewLoc = new int[2];
            v.getLocationOnScreen(viewLoc);

            if (startX >= viewLoc[0] && startX < viewLoc[0] + v.getWidth()
                    && startY >= viewLoc[1] && startY < viewLoc[1] + v.getHeight()) {
                return true;
            }

        }
        return false;
    }

    // Tutorial is completely contained within the NavigationBaseActivity now. At some point may move code
    // to a TutorialController class or some such
    public void startTutorialAtStep(final int step, final TutorialItem view, final DiscountData discountData) {
        touchModeDisabled = true;
        mTutorialItem = view;
        mTutorialFragment = (DiscountMainFragment) getSupportFragmentManager().findFragmentById(RTFragmentManager.FRAGMENT_LAYOUT_ID);
        switch (step) {
            default:
                int[] locOnScreen = new int[2];
                view.getLocationOnScreen(locOnScreen);

                getTutorialView().showTutorial(1, getString(R.string.tutorial_step_1), TutorialView.Gravity.BOTTOM, null);
                showToolTip(true, getScreenSize().x / 2, locOnScreen[1], "Tap this button", TooltipManager.Gravity.TOP, view);

                view.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        RTSharedPreferenceHelper.setTutorialStep(step);
                        TooltipManager.getInstance().hide(NavigationBaseActivity.TOOLTIP_ID);
                        getTutorialView().hideTutorial(null);

                        view.animate(DiscountItem.AnimationType.EXPAND, new DiscountItem.AnimationFinishListener() {
                            @Override
                            public void onAnimationFinish() {
                                setUpTutorialStep(2, view.getRedeemButtonView(), mTutorialFragment, discountData, true);
                            }
                        });
                    }
                });
                break;
            case 3: // goto case 2
            case 2:
                view.animate(DiscountItem.AnimationType.EXPAND, new DiscountItem.AnimationFinishListener() {
                    @Override
                    public void onAnimationFinish() {
                        setUpTutorialStep(2, view.getRedeemButtonView(), mTutorialFragment, discountData, true);
                    }
                });
                break;
            case 4:
                view.animate(DiscountItem.AnimationType.EXPAND, new DiscountItem.AnimationFinishListener() {
                    @Override
                    public void onAnimationFinish() {
                        setUpTutorialStep(4, view.getFollowButtonView(), mTutorialFragment, discountData, true);
                    }
                });
                break;
            case 7: // go to case 5
            case 6: // go to case 5
            case 5:
                view.setFollowed();
                view.animate(DiscountItem.AnimationType.EXPAND, new DiscountItem.AnimationFinishListener() {
                    @Override
                    public void onAnimationFinish() {
                        setUpTutorialStep(5, view.getCommentButtonView(), mTutorialFragment, discountData, true);
                    }
                });
                break;
        }
    }

    public void setUpTutorialStep(int step, final View viewToClick, final Fragment currentFrag, final DiscountData discountData, boolean show) {
        int[] locOnScreen = new int[2];

        RTSharedPreferenceHelper.setTutorialStep(step);

        switch(step) {
            case 1:
                break;
            case 2: // viewToClick is redeem button
                viewToClick.getLocationOnScreen(locOnScreen);

                if (show) {
                    getTutorialView().showTutorial(2, getString(R.string.tutorial_step_2), TutorialView.Gravity.TOP, null);
                    showToolTip(true, 0, locOnScreen[1], "Tap this button", TooltipManager.Gravity.TOP, viewToClick);
                }

                viewToClick.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TooltipManager.getInstance().hide(NavigationBaseActivity.TOOLTIP_ID);
                        getTutorialView().hideTutorial(null);

                        final RedeemDiscountFragment fragment = RedeemDiscountFragment.newInstance(discountData, true);
                        fragment.setFragmentAnimationListener(new Animation.AnimationListener() {
                            @Override
                            public void onAnimationStart(Animation animation) {
                            }

                            @Override
                            public void onAnimationEnd(Animation animation) {
                                setUpTutorialStep(3, fragment.getRedeemButton(), fragment, discountData, true);
                            }

                            @Override
                            public void onAnimationRepeat(Animation animation) {
                            }
                        });
                        mOwnFragmentManager.replaceFragment(fragment, RTFragmentManager.REDEEM_FRAGMENT, RTFragmentManager.PageTransitionType.SlideUp);
                    }
                });
                break;
            case 3:
                viewToClick.getLocationOnScreen(locOnScreen);

                if (show) {
                    getTutorialView().showTutorial(3, getString(R.string.tutorial_step_3), TutorialView.Gravity.TOP, null);
                    showToolTip(true, getScreenSize().x / 2, locOnScreen[1], "Tap this button", TooltipManager.Gravity.TOP, viewToClick);
                }
                viewToClick.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TooltipManager.getInstance().hide(NavigationBaseActivity.TOOLTIP_ID);
                        getTutorialView().hideTutorial(null);

                        // set on return to main discount view listener
                        mTutorialFragment.setFragmentAnimationListener(new Animation.AnimationListener() {
                            @Override
                            public void onAnimationStart(Animation animation) {}

                            @Override
                            public void onAnimationEnd(Animation animation) {
                                mTutorialFragment.setFragmentAnimationListener(null);
                                setUpTutorialStep(4, mTutorialItem.getFollowButtonView(), mTutorialFragment, discountData, true);
                            }

                            @Override
                            public void onAnimationRepeat(Animation animation) {}
                        });
                        mOwnFragmentManager.manuallyPopFragment();
                    }
                });
                break;
            case 4:
                viewToClick.getLocationOnScreen(locOnScreen);

                if (show) {
                    getTutorialView().showTutorial(4, getString(R.string.tutorial_step_4), TutorialView.Gravity.BOTTOM, null);
                    showToolTip(false, locOnScreen[0], locOnScreen[1] - viewToClick.getHeight() / 2, "Tap this button", TooltipManager.Gravity.LEFT, viewToClick);
                }
                viewToClick.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mTutorialItem.setFollowed();
                        TooltipManager.getInstance().hide(NavigationBaseActivity.TOOLTIP_ID);
                        getTutorialView().hideTutorial(new TutorialView.AnimationFinishListener() {
                            @Override
                            public void onAnimationFinished() {
                                setUpTutorialStep(5, mTutorialItem.getCommentButtonView(), mTutorialFragment, discountData, true);
                            }
                        });
                    }
                });
                break;
            case 5:
                viewToClick.getLocationOnScreen(locOnScreen);

                if (show) {
                    getTutorialView().showTutorial(5, getString(R.string.tutorial_step_5), TutorialView.Gravity.TOP, null);
                    showToolTip(false, locOnScreen[0] + viewToClick.getWidth() / 2, locOnScreen[1], "Tap this button", TooltipManager.Gravity.TOP, viewToClick);
                }
                viewToClick.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TooltipManager.getInstance().hide(NavigationBaseActivity.TOOLTIP_ID);
                        getTutorialView().hideTutorial(null);

                        final DiscountContainerFragment fragment = DiscountContainerFragment.newInstance(discountData);
                        fragment.setFragmentAnimationListener(new Animation.AnimationListener() {
                            @Override
                            public void onAnimationStart(Animation animation) {
                            }

                            @Override
                            public void onAnimationEnd(Animation animation) {
                                fragment.setFragmentAnimationListener(null);
                                setUpTutorialStep(6, fragment.getExpandButtonView(), fragment, discountData, true);
                            }

                            @Override
                            public void onAnimationRepeat(Animation animation) {
                            }
                        });
                        mOwnFragmentManager.replaceFragment(fragment, RTFragmentManager.DISCOUNT_COMMENT_FRAGMENT, RTFragmentManager.PageTransitionType.SlideIn);
                    }
                });
                break;
            case 6:
                viewToClick.getLocationOnScreen(locOnScreen);

                if (show) {
                    getTutorialView().showTutorial(6, getString(R.string.tutorial_step_6), TutorialView.Gravity.BOTTOM, null);
                    showToolTip(false, locOnScreen[0], locOnScreen[1] - viewToClick.getHeight() / 2, "Tap this icon", TooltipManager.Gravity.LEFT, viewToClick);
                }
                viewToClick.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TooltipManager.getInstance().hide(NavigationBaseActivity.TOOLTIP_ID);
                        getTutorialView().hideTutorial(null);

                        final DiscountContainerFragment fragment = (DiscountContainerFragment) currentFrag;
                        fragment.expand(new DiscountItem.AnimationFinishListener() {
                            @Override
                            public void onAnimationFinish() {
                                setUpTutorialStep(7, fragment.getViewBusinessView(), fragment, discountData, true);
                            }
                        });
                    }
                });
                break;
            case 7:
                viewToClick.getLocationOnScreen(locOnScreen);

                if (show) {
                    getTutorialView().showTutorial(7, getString(R.string.tutorial_step_7), TutorialView.Gravity.TOP, null);
                    showToolTip(false, locOnScreen[0] + viewToClick.getWidth() / 2, locOnScreen[1], "Tap this button", TooltipManager.Gravity.TOP, viewToClick);
                }
                viewToClick.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        TooltipManager.getInstance().hide(NavigationBaseActivity.TOOLTIP_ID);
                        getTutorialView().hideTutorial(null);

                        final BusinessContainerFragment fragment = BusinessContainerFragment.newInstance(discountData.getStoreData().getId());
                        fragment.setFragmentAnimationListener(new Animation.AnimationListener() {
                            @Override
                            public void onAnimationStart(Animation animation) {
                            }

                            @Override
                            public void onAnimationEnd(Animation animation) {
                                setUpTutorialStep(8, null, null, discountData, true);
                            }

                            @Override
                            public void onAnimationRepeat(Animation animation) {
                            }
                        });
                        mOwnFragmentManager.replaceFragment(fragment, RTFragmentManager.DISCOUNT_BUSINESS_FRAGMENT, RTFragmentManager.PageTransitionType.SlideIn);
                    }
                });
                break;
            case 8:
                getTutorialView().showTutorial(7, getString(R.string.tutorial_step_7_2), TutorialView.Gravity.BOTTOM, null);
                addClickableViews();

                break;
        }
    }
}
