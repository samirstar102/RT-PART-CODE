package com.rover.rovertown.Activity;


import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;

import com.rover.rovertown.Fragment.VerifyMailIntroFragment;
import com.rover.rovertown.Fragment.VerifyMailMainFragment;
import com.rover.rovertown.Fragment.VerifyMailSuccFragment;
import com.rover.rovertown.R;
import com.rover.rovertown.Util.RTConstants;

/**
 * Implementation of ExplanationActivity
 *
 * @author Samir on 04/05/15.
 */
public class VerifyMailActivity extends RootActivity implements
    VerifyMailIntroFragment.OnIntroFragmentInteractionListener,
    VerifyMailMainFragment.OnMainFragmentInteractionListener,
    VerifyMailSuccFragment.OnSuccFragmentInteractionListener,
    FragmentManager.OnBackStackChangedListener{

    private FragmentManager fragmentManager;
    private FragmentTransaction fragmentTransaction;

    public static final String FROM_REMINDER = "from_reminder";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_verifymail);

        VerifyMailIntroFragment introFragment = new VerifyMailIntroFragment();
        introFragment.setArguments(getIntent().getExtras());

        fragmentManager = getSupportFragmentManager();
        fragmentManager.addOnBackStackChangedListener(this);
        fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.replace(R.id.verifyInteractContent, introFragment, RTConstants.VERIFYMAIL_FRAG_TAG1);
        fragmentTransaction.commit();
    }

    @Override
    protected  void onSaveInstanceState(Bundle outState) {
    }

    @Override
    public void onBackStackChanged() {

    }

    @Override
    public void onIntroSignupPressed() {
        VerifyMailMainFragment signupFragment = new VerifyMailMainFragment();
        signupFragment.setArguments(getIntent().getExtras());

        fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.setCustomAnimations(R.anim.activity_slidein_left, R.anim.activity_slideout_left, 0, 0);
        fragmentTransaction.replace(R.id.verifyInteractContent, signupFragment, RTConstants.VERIFYMAIL_FRAG_TAG2);
        fragmentTransaction.addToBackStack(RTConstants.VERIFYMAIL_FRAG_TAG2);
        fragmentTransaction.commit();
    }

    @Override
    public void onIntroResendPressed() {
        VerifyMailSuccFragment succFragment = new VerifyMailSuccFragment();
        succFragment.setArguments(getIntent().getExtras());

        fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.replace(R.id.verifyInteractContent, succFragment, RTConstants.VERIFYMAIL_FRAG_TAG3);
        fragmentTransaction.addToBackStack(RTConstants.VERIFYMAIL_FRAG_TAG3);
        fragmentTransaction.commit();
    }

    @Override
    public void onMainBackPressed() {
        if (fragmentManager.getBackStackEntryCount() > 0) {
            fragmentManager.popBackStack();
        }
    }

    @Override
    public void onSuccessNewSignup() {
        if (fragmentManager.getBackStackEntryCount() > 0) {
            fragmentManager.popBackStackImmediate();
        }
        VerifyMailSuccFragment succFragment = new VerifyMailSuccFragment();
        succFragment.setArguments(getIntent().getExtras());

        fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.replace(R.id.verifyInteractContent, succFragment, RTConstants.VERIFYMAIL_FRAG_TAG3);
        fragmentTransaction.addToBackStack(RTConstants.VERIFYMAIL_FRAG_TAG3);
        fragmentTransaction.commit();
    }

    @Override
    public void goToMain() {
        Intent mainActivity = new Intent(VerifyMailActivity.this, NavigationBaseActivity.class);
        startActivity(mainActivity);
        finish();
    }
}
