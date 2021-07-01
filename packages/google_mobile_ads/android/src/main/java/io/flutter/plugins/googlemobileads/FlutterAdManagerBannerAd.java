// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.flutter.plugins.googlemobileads;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.ResponseInfo;
import com.google.android.gms.ads.admanager.AdManagerAdRequest;
import com.google.android.gms.ads.admanager.AdManagerAdView;
import com.google.android.gms.ads.admanager.AppEventListener;
import com.google.android.gms.common.internal.Preconditions;
import io.flutter.plugin.platform.PlatformView;
import java.util.List;

import org.prebid.mobile.BannerAdUnit;
import org.prebid.mobile.Host;
import org.prebid.mobile.OnCompleteListener;
import org.prebid.mobile.PrebidMobile;
import org.prebid.mobile.ResultCode;

/**
 * Wrapper around {@link com.google.android.gms.ads.admanager.AdManagerAdView} for the Google Mobile
 * Ads Plugin.
 */
class FlutterAdManagerBannerAd extends FlutterAd implements FlutterAdLoadedListener {

  @NonNull private final AdInstanceManager manager;
  @NonNull private final String adUnitId;
  @NonNull private final List<FlutterAdSize> sizes;
  @NonNull private final FlutterAdManagerAdRequest request;
  @NonNull private final BannerAdCreator bannerAdCreator;
  @NonNull private final BannerAdUnit adUnit;
  @Nullable private AdManagerAdView view;

  /**
   * Constructs a `FlutterAdManagerBannerAd`.
   *
   * <p>Call `load()` to instantiate the `AdView` and load the `AdRequest`. `getView()` will return
   * null only until `load` is called.
   */
  public FlutterAdManagerBannerAd(
      int adId,
      @NonNull AdInstanceManager manager,
      @NonNull String adUnitId,
      @NonNull List<FlutterAdSize> sizes,
      @NonNull FlutterAdManagerAdRequest request,
      @NonNull BannerAdCreator bannerAdCreator) {
    super(adId);
    Preconditions.checkNotNull(manager);
    Preconditions.checkNotNull(adUnitId);
    Preconditions.checkNotNull(sizes);
    Preconditions.checkNotNull(request);
    this.manager = manager;
    this.adUnitId = adUnitId;
    this.sizes = sizes;
    this.request = request;
    this.bannerAdCreator = bannerAdCreator;
    this.adUnit = new BannerAdUnit("20685367", 320, 50);
  }

  @Override
  void load() {
    view = bannerAdCreator.createAdManagerAdView();
    view.setAdUnitId(adUnitId);
    view.setAppEventListener(
            new AppEventListener() {
              @Override
              public void onAppEvent(String name, String data) {
                manager.onAppEvent(adId, name, data);
              }
            });

    final AdSize[] allSizes = new AdSize[sizes.size()];
    for (int i = 0; i < sizes.size(); i++) {
      allSizes[i] = sizes.get(i).getAdSize();
    }
    view.setAdSizes(allSizes);
    view.setAdListener(new FlutterBannerAdListener(adId, manager, this));

    preparePrebid();
    final AdManagerAdRequest r = request.asAdManagerAdRequest();
    adUnit.fetchDemand(r, new OnCompleteListener() {
      @Override
      public void onComplete(ResultCode resultCode) {
        view.loadAd(r);
      }
    });
  }

  @Override
  public void onAdLoaded() {
    if (view != null) {
      manager.onAdLoaded(adId, view.getResponseInfo());
    }
  }

  @Nullable
  @Override
  PlatformView getPlatformView() {
    if (view == null) {
      return null;
    }
    return new FlutterPlatformView(view);
  }

  @Override
  void dispose() {
    if (view != null) {
      view.destroy();
      view = null;
    }
  }

  public void preparePrebid() {
    Host host = Host.CUSTOM;
    host.setHostUrl("https://ib.adnxs.com/openrtb2/prebid");
//    host.setHostUrl("https://prebid.adnxs.com/pbs/v1/openrtb2/auction");
    PrebidMobile.setApplicationContext(manager.activity);
    PrebidMobile.setPrebidServerHost(host);
    PrebidMobile.setPrebidServerAccountId("11011");
//    PrebidMobile.setPrebidServerAccountId("bfa84af2-bd16-4d35-96ad-31c6bb888df0");
  }
}
