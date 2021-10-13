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
@import PrebidMobile;
#import "FLTAd_Internal.h"
#import "FLTAdUtil.h"
#import "FLTConstants.h"

@implementation FLTAdSize
- (instancetype _Nonnull)initWithWidth:(NSNumber *_Nonnull)width height:(NSNumber *_Nonnull)height {
  return
      [self initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(width.doubleValue, height.doubleValue))];
}

- (instancetype _Nonnull)initWithAdSize:(GADAdSize)size {
  self = [super init];
  if (self) {
    _size = size;
    _width = @(size.size.width);
    _height = @(size.size.height);
  }
  return self;
}
@end

@implementation FLTAdSizeFactory
- (GADAdSize)portraitAnchoredAdaptiveBannerAdSizeWithWidth:(NSNumber *_Nonnull)width {
  return GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(width.doubleValue);
}

- (GADAdSize)landscapeAnchoredAdaptiveBannerAdSizeWithWidth:(NSNumber *_Nonnull)width {
  return GADLandscapeAnchoredAdaptiveBannerAdSizeWithWidth(width.doubleValue);
}

- (GADAdSize)currentOrientationAnchoredAdaptiveBannerAdSizeWithWidth:(NSNumber *_Nonnull)width {
  return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width.doubleValue);
}

- (GADAdSize)currentOrientationInlineAdaptiveBannerSizeWithWidth:(NSNumber *_Nonnull)width {
  return GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width.floatValue);
}

- (GADAdSize)portraitOrientationInlineAdaptiveBannerSizeWithWidth:(NSNumber *_Nonnull)width {
  return GADPortraitInlineAdaptiveBannerAdSizeWithWidth(width.floatValue);
}
- (GADAdSize)landscapeInlineAdaptiveBannerAdSizeWithWidth:(NSNumber *_Nonnull)width {
  return GADLandscapeInlineAdaptiveBannerAdSizeWithWidth(width.floatValue);
}
- (GADAdSize)inlineAdaptiveBannerAdSizeWithWidthAndMaxHeight:(NSNumber *_Nonnull)width
                                                   maxHeight:(NSNumber *_Nonnull)maxHeight {
  return GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(width.floatValue, maxHeight.floatValue);
}

@end

@implementation FLTAnchoredAdaptiveBannerSize
- (instancetype _Nonnull)initWithFactory:(FLTAdSizeFactory *_Nonnull)factory
                             orientation:(NSString *)orientation
                                   width:(NSNumber *_Nonnull)width {
  GADAdSize size;
  if ([FLTAdUtil isNull:orientation]) {
    size = [factory currentOrientationAnchoredAdaptiveBannerAdSizeWithWidth:width];
  } else if ([orientation isEqualToString:@"portrait"]) {
    size = [factory portraitAnchoredAdaptiveBannerAdSizeWithWidth:width];
  } else if ([orientation isEqualToString:@"landscape"]) {
    size = [factory landscapeAnchoredAdaptiveBannerAdSizeWithWidth:width];
  } else {
    NSLog(@"Unexpected value for orientation: %@", orientation);
    return nil;
  }

  self = [self initWithAdSize:size];
  if (self) {
    _orientation = orientation;
  }
  return self;
}
@end

@implementation FLTInlineAdaptiveBannerSize
- (instancetype _Nonnull)initWithFactory:(FLTAdSizeFactory *_Nonnull)factory
                                   width:(NSNumber *_Nonnull)width
                               maxHeight:(NSNumber *_Nullable)maxHeight
                             orientation:(NSNumber *_Nullable)orientation {
  GADAdSize gadAdSize;
  if ([FLTAdUtil isNotNull:orientation]) {
    gadAdSize = orientation.intValue == 0
                    ? [factory portraitOrientationInlineAdaptiveBannerSizeWithWidth:width]
                    : [factory landscapeInlineAdaptiveBannerAdSizeWithWidth:width];
  } else if ([FLTAdUtil isNotNull:maxHeight]) {
    gadAdSize = [factory inlineAdaptiveBannerAdSizeWithWidthAndMaxHeight:width maxHeight:maxHeight];
  } else {
    gadAdSize = [factory currentOrientationInlineAdaptiveBannerSizeWithWidth:width];
  }
  self = [self initWithAdSize:gadAdSize];
  if (self) {
    _orientation = orientation;
    _maxHeight = maxHeight;
  }
  return self;
}
@end

@implementation FLTSmartBannerSize
- (instancetype _Nonnull)initWithOrientation:(NSString *_Nonnull)orientation {
  GADAdSize size;
  if ([orientation isEqualToString:@"portrait"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    size = kGADAdSizeSmartBannerPortrait;
  } else if ([orientation isEqualToString:@"landscape"]) {
    size = kGADAdSizeSmartBannerLandscape;
#pragma clang diagnostic pop
  } else {
    NSLog(@"SmartBanner orientation should be 'portrait' or 'landscape': %@", orientation);
    return nil;
  }

  self = [self initWithAdSize:size];
  if (self) {
    _orientation = orientation;
  }
  return self;
}
@end

@implementation FLTLocationParams

- (instancetype _Nonnull)initWithAccuracy:(NSNumber *_Nonnull)accuracy
                                longitude:(NSNumber *_Nonnull)longitude
                                 latitude:(NSNumber *_Nonnull)latitude {
  self = [super init];
  if (self) {
    _accuracy = accuracy;
    _longitude = longitude;
    _latitude = latitude;
  }
  return self;
}
@end

@implementation FLTFluidSize
- (instancetype _Nonnull)init {
  self = [self initWithAdSize:kGADAdSizeFluid];
  return self;
}
@end

@implementation FLTAdRequest
- (GADRequest *_Nonnull)asGADRequest {
  GADRequest *request = [GADRequest request];
  request.keywords = _keywords;
  request.contentURL = _contentURL;
  if (_nonPersonalizedAds) {
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"npa" : @"1"};
    [request registerAdNetworkExtras:extras];
  }
  request.neighboringContentURLStrings = _neighboringContentURLs;
  request.requestAgent = FLT_REQUEST_AGENT_VERSIONED;
  if ([FLTAdUtil isNotNull:_location]) {
    [request setLocationWithLatitude:_location.latitude.floatValue
                           longitude:_location.longitude.floatValue
                            accuracy:_location.accuracy.floatValue];
  }
  return request;
}
@end

@implementation FLTGADResponseInfo

- (instancetype _Nonnull)initWithResponseInfo:(GADResponseInfo *_Nonnull)responseInfo {
  self = [super init];
  if (self) {
    _responseIdentifier = responseInfo.responseIdentifier;
    _adNetworkClassName = responseInfo.adNetworkClassName;
    NSMutableArray<FLTGADAdNetworkResponseInfo *> *infoArray = [[NSMutableArray alloc] init];
    for (GADAdNetworkResponseInfo *adNetworkInfo in responseInfo.adNetworkInfoArray) {
      [infoArray
          addObject:[[FLTGADAdNetworkResponseInfo alloc] initWithResponseInfo:adNetworkInfo]];
    }
    _adNetworkInfoArray = infoArray;
  }
  return self;
}
@end

@implementation FLTGADAdNetworkResponseInfo

- (instancetype _Nonnull)initWithResponseInfo:(GADAdNetworkResponseInfo *_Nonnull)responseInfo {
  self = [super init];
  if (self) {
    _adNetworkClassName = responseInfo.adNetworkClassName;
    NSNumber *timeInMillis = [[NSNumber alloc] initWithDouble:responseInfo.latency * 1000];
    _latency = @(timeInMillis.longValue);
    _dictionaryDescription = responseInfo.dictionaryRepresentation.description;
    _credentialsDescription = responseInfo.credentials.description;
    _error = responseInfo.error;
  }
  return self;
}
@end

@implementation FLTLoadAdError

- (instancetype _Nonnull)initWithError:(NSError *_Nonnull)error {
  self = [super init];
  if (self) {
    _code = error.code;
    _domain = error.domain;
    _message = error.localizedDescription;
    GADResponseInfo *responseInfo = error.userInfo[GADErrorUserInfoKeyResponseInfo];
    if (responseInfo) {
      _responseInfo = [[FLTGADResponseInfo alloc] initWithResponseInfo:responseInfo];
    }
  }
  return self;
}
@end

#pragma mark - FLTGAMAdRequest

@implementation FLTGAMAdRequest
- (GADRequest *_Nonnull)asGAMRequest {
  GAMRequest *request = [GAMRequest request];
  request.keywords = self.keywords;
  request.contentURL = self.contentURL;
  request.neighboringContentURLStrings = self.neighboringContentURLs;
  request.publisherProvidedID = self.pubProvidedID;

  NSMutableDictionary<NSString *, id> *targetingDictionary =
      [NSMutableDictionary dictionaryWithDictionary:self.customTargeting];
  [targetingDictionary addEntriesFromDictionary:self.customTargetingLists];
  request.customTargeting = targetingDictionary;

  if (self.nonPersonalizedAds) {
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"npa" : @"1"};
    [request registerAdNetworkExtras:extras];
  }
  if ([FLTAdUtil isNotNull:self.location]) {
    [request setLocationWithLatitude:self.location.latitude.floatValue
                           longitude:self.location.longitude.floatValue
                            accuracy:self.location.accuracy.floatValue];
  }
  request.requestAgent = FLT_REQUEST_AGENT_VERSIONED;
  return request;
}
@end

#pragma mark - FLTBaseAd

@interface FLTBaseAd ()
@property(readwrite) NSNumber *_Nonnull adId;
@end

@implementation FLTBaseAd
@synthesize adId;
@end

#pragma mark - FLTBannerAd

@implementation FLTBannerAd {
  GADBannerView *_bannerView;
  FLTAdRequest *_adRequest;
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                            size:(FLTAdSize *_Nonnull)size
                         request:(FLTAdRequest *_Nonnull)request
              rootViewController:(UIViewController *_Nonnull)rootViewController
                            adId:(NSNumber *_Nonnull)adId {
  self = [super init];
  if (self) {
    _adRequest = request;
    _bannerView = [[GADBannerView alloc] initWithAdSize:size.size];
    _bannerView.adUnitID = adUnitId;
    self.adId = adId;
    self.bannerView.rootViewController = rootViewController;
    __weak FLTBannerAd *weakSelf = self;
    self.bannerView.paidEventHandler = ^(GADAdValue *_Nonnull value) {
      if (weakSelf.manager == nil) {
        return;
      }
      [weakSelf.manager onPaidEvent:weakSelf
                              value:[[FLTAdValue alloc] initWithValue:value.value
                                                            precision:(NSInteger)value.precision
                                                         currencyCode:value.currencyCode]];
    };
  }
  return self;
}

- (GADBannerView *_Nonnull)bannerView {
  return _bannerView;
}

- (void)load {
  self.bannerView.delegate = self;
  [self.bannerView loadRequest:_adRequest.asGADRequest];
}

- (FLTAdSize *)getAdSize {
  if (self.bannerView) {
    return [[FLTAdSize alloc] initWithAdSize:self.bannerView.adSize];
  }
  return nil;
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  [manager onAdLoaded:self responseInfo:bannerView.responseInfo];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  [manager onAdFailedToLoad:self error:error];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  [manager onBannerImpression:self];
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  [manager onBannerWillPresentScreen:self];
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  [manager onBannerWillDismissScreen:self];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  [manager onBannerDidDismissScreen:self];
}

#pragma mark - FlutterPlatformView
- (nonnull UIView *)view {
  return self.bannerView;
}

@synthesize manager;

@end

#pragma mark - FLTGAMBannerAd
@implementation FLTGAMBannerAd {
  GAMBannerView *_bannerView;
  FLTGAMAdRequest *_adRequest;
  BannerAdUnit *_bannerUnit;
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                           sizes:(NSArray<FLTAdSize *> *_Nonnull)sizes
                         request:(FLTGAMAdRequest *_Nonnull)request
              rootViewController:(UIViewController *_Nonnull)rootViewController
                            adId:(NSNumber *_Nonnull)adId {
  self = [super init];
  if (self) {
    Prebid.shared.prebidServerAccountId = @"11011";
    NSError* err=nil;
      [[Prebid shared] setCustomPrebidServerWithUrl:@"https://ib.adnxs.com/openrtb2/prebid" error:&err];
    if(err == nil)

    _bannerUnit = [[BannerAdUnit alloc] initWithConfigId:@"20685367" size:CGSizeMake(320, 50)];

    self.adId = adId;
    _adRequest = request;
    _bannerView = [[GAMBannerView alloc] initWithAdSize:sizes[0].size];
    _bannerView.adUnitID = adUnitId;
    _bannerView.rootViewController = rootViewController;
    _bannerView.appEventDelegate = self;
    _bannerView.delegate = self;

    NSMutableArray<NSValue *> *validAdSizes = [NSMutableArray arrayWithCapacity:sizes.count];
    for (FLTAdSize *size in sizes) {
      [validAdSizes addObject:NSValueFromGADAdSize(size.size)];
    }
    _bannerView.validAdSizes = validAdSizes;

    __weak FLTGAMBannerAd *weakSelf = self;
    self.bannerView.paidEventHandler = ^(GADAdValue *_Nonnull value) {
      if (weakSelf.manager == nil) {
        return;
      }
      [weakSelf.manager onPaidEvent:weakSelf
                              value:[[FLTAdValue alloc] initWithValue:value.value
                                                            precision:(NSInteger)value.precision
                                                         currencyCode:value.currencyCode]];
    };
  }
  return self;
}

- (GADBannerView *_Nonnull)bannerView {
  return _bannerView;
}

- (void)load {
//  [self.bannerView loadRequest:_adRequest.asGAMRequest];
 //  [self.bannerView loadRequest:_adRequest.asDFPRequest];
    GAMRequest *_dfpRequest = _adRequest.asGAMRequest;
    [_bannerUnit fetchDemandWithAdObject:_dfpRequest completion:^(enum ResultCode result) {
         NSLog(@"Prebid demand result %ld", (long)result);
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.bannerView loadRequest:_dfpRequest];
         });
    }];
}

#pragma mark - FlutterPlatformView

- (nonnull UIView *)view {
  return self.bannerView;
}

#pragma mark - GADAppEventDelegate
- (void)adView:(nonnull GADBannerView *)banner
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info {
  [self.manager onAppEvent:self name:name data:info];
}

@end

#pragma mark - FLTFluidGAMBannerAd

@implementation FLTFluidGAMBannerAd {
  GAMBannerView *_bannerView;
  FLTGAMAdRequest *_adRequest;
  UIScrollView *_containerView;
  CGFloat _height;
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                         request:(FLTGAMAdRequest *_Nonnull)request
              rootViewController:(UIViewController *_Nonnull)rootViewController
                            adId:(NSNumber *_Nonnull)adId {
  self = [super init];
  if (self) {
    self.adId = adId;
    _height = -1;
    _adRequest = request;
    _bannerView = [[GAMBannerView alloc] initWithAdSize:kGADAdSizeFluid];
    _bannerView.adUnitID = adUnitId;
    _bannerView.rootViewController = rootViewController;
    _bannerView.appEventDelegate = self;
    _bannerView.delegate = self;
    _bannerView.adSizeDelegate = self;

    __weak FLTFluidGAMBannerAd *weakSelf = self;
    self.bannerView.paidEventHandler = ^(GADAdValue *_Nonnull value) {
      if (weakSelf.manager == nil) {
        return;
      }
      [weakSelf.manager onPaidEvent:weakSelf
                              value:[[FLTAdValue alloc] initWithValue:value.value
                                                            precision:(NSInteger)value.precision
                                                         currencyCode:value.currencyCode]];
    };
  }
  return self;
}

- (GADBannerView *_Nonnull)bannerView {
  return _bannerView;
}

- (void)load {
  [self.bannerView loadRequest:_adRequest.asGAMRequest];
}

#pragma mark - FlutterPlatformView

- (nonnull UIView *)view {
  if (_containerView) {
    return _containerView;
  }

  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  [scrollView setShowsHorizontalScrollIndicator:NO];
  [scrollView setShowsVerticalScrollIndicator:NO];
  [scrollView addSubview:_bannerView];

  _bannerView.translatesAutoresizingMaskIntoConstraints = false;
  NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:_bannerView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:0
                                                              toItem:scrollView
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0];
  [scrollView addConstraint:width];
  _containerView = scrollView;
  [_bannerView.widthAnchor constraintEqualToAnchor:scrollView.widthAnchor].active = YES;
  [_bannerView.topAnchor constraintEqualToAnchor:scrollView.topAnchor].active = YES;
  return scrollView;
}

#pragma mark - GADAdSizeDelegate

- (void)adView:(GADBannerView *)bannerView willChangeAdSizeTo:(GADAdSize)adSize {
  CGFloat height = adSize.size.height;
  [self.manager onFluidAdHeightChanged:self height:height];
}

#pragma mark - GADAppEventDelegate
- (void)adView:(nonnull GADBannerView *)banner
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info {
  [self.manager onAppEvent:self name:name data:info];
}

@end

@implementation FLTInterstitialAd {
  GADInterstitialAd *_interstitialView;
  FLTAdRequest *_adRequest;
  UIViewController *_rootViewController;
  NSString *_adUnitId;
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                         request:(FLTAdRequest *_Nonnull)request
              rootViewController:(UIViewController *_Nonnull)rootViewController
                            adId:(NSNumber *_Nonnull)adId {
  self = [super init];
  if (self) {
    self.adId = adId;
    _adRequest = request;
    _adUnitId = [adUnitId copy];
    _rootViewController = rootViewController;
  }
  return self;
}

- (GADInterstitialAd *_Nullable)interstitial {
  return _interstitialView;
}

- (NSString *_Nonnull)adUnitId {
  return _adUnitId;
}

- (void)load {
  [GADInterstitialAd loadWithAdUnitID:_adUnitId
                              request:[_adRequest asGADRequest]
                    completionHandler:^(GADInterstitialAd *ad, NSError *error) {
                      if (error) {
                        [self.manager onAdFailedToLoad:self error:error];
                        return;
                      }
                      ad.fullScreenContentDelegate = self;
                      self->_interstitialView = ad;
                      __weak FLTInterstitialAd *weakSelf = self;
                      ad.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                        if (weakSelf.manager == nil) {
                          return;
                        }
                        [weakSelf.manager
                            onPaidEvent:weakSelf
                                  value:[[FLTAdValue alloc] initWithValue:value.value
                                                                precision:(NSInteger)value.precision
                                                             currencyCode:value.currencyCode]];
                      };

                      [self.manager onAdLoaded:self responseInfo:ad.responseInfo];
                    }];
}

- (void)show {
  if (self.interstitial) {
    [self.interstitial presentFromRootViewController:_rootViewController];
  } else {
    NSLog(@"InterstitialAd failed to show because the ad was not ready.");
  }
}

#pragma mark - GADFullScreenContentDelegate

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
  [self.manager didFailToPresentFullScreenContentWithError:self error:error];
}

- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [self.manager onAdDidPresentFullScreenContent:self];
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [self.manager adDidDismissFullScreenContent:self];
}

- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [self.manager adWillDismissFullScreenContent:self];
}

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
  [self.manager adDidRecordImpression:self];
}

@synthesize manager;

@end

@implementation FLTGAMInterstitialAd {
  GAMInterstitialAd *_insterstitial;
  FLTGAMAdRequest *_adRequest;
  UIViewController *_rootViewController;
  NSString *_adUnitId;
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                         request:(FLTGAMAdRequest *_Nonnull)request
              rootViewController:(UIViewController *_Nonnull)rootViewController
                            adId:(NSNumber *_Nonnull)adId {
  self = [super init];
  if (self) {
    self.adId = adId;
    _adRequest = request;
    _adUnitId = [adUnitId copy];
    _rootViewController = rootViewController;
  }
  return self;
}

- (GADInterstitialAd *_Nullable)interstitial {
  return _insterstitial;
}

- (void)load {
  [GAMInterstitialAd
      loadWithAdManagerAdUnitID:_adUnitId
                        request:[_adRequest asGAMRequest]
              completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
                if (error) {
                  [self.manager onAdFailedToLoad:self error:error];
                  return;
                }
                [self.manager onAdLoaded:self responseInfo:ad.responseInfo];
                ad.fullScreenContentDelegate = self;
                ad.appEventDelegate = self;
                __weak FLTGAMInterstitialAd *weakSelf = self;
                ad.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                  if (weakSelf.manager == nil) {
                    return;
                  }
                  [weakSelf.manager
                      onPaidEvent:weakSelf
                            value:[[FLTAdValue alloc] initWithValue:value.value
                                                          precision:(NSInteger)value.precision
                                                       currencyCode:value.currencyCode]];
                };

                self->_insterstitial = ad;
              }];
}

- (void)show {
  if (self.interstitial) {
    [self.interstitial presentFromRootViewController:_rootViewController];
  } else {
    NSLog(@"InterstitialAd failed to show because the ad was not ready.");
  }
}

#pragma mark - GADAppEventDelegate

- (void)interstitialAd:(nonnull GADInterstitialAd *)interstitialAd
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info {
  [self.manager onAppEvent:self name:name data:info];
}

@end

#pragma mark - FLTRewardedAd
@implementation FLTRewardedAd {
  GADRewardedAd *_rewardedView;
  FLTAdRequest *_adRequest;
  UIViewController *_rootViewController;
  FLTServerSideVerificationOptions *_serverSideVerificationOptions;
  NSString *_adUnitId;
}

- (instancetype)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                          request:(FLTAdRequest *_Nonnull)request
               rootViewController:(UIViewController *_Nonnull)rootViewController
    serverSideVerificationOptions:
        (FLTServerSideVerificationOptions *_Nullable)serverSideVerificationOptions
                             adId:(NSNumber *_Nonnull)adId {
  self = [super init];
  if (self) {
    self.adId = adId;
    _adRequest = request;
    _rootViewController = rootViewController;
    _serverSideVerificationOptions = serverSideVerificationOptions;
    _adUnitId = [adUnitId copy];
  }
  return self;
}

- (GADRewardedAd *_Nullable)rewardedAd {
  return _rewardedView;
}

- (void)load {
  GADRequest *request;
  if ([_adRequest isKindOfClass:[FLTGAMAdRequest class]]) {
    FLTGAMAdRequest *gamRequest = (FLTGAMAdRequest *)_adRequest;
    request = gamRequest.asGAMRequest;
  } else if ([_adRequest isKindOfClass:[FLTAdRequest class]]) {
    request = _adRequest.asGADRequest;
  } else {
    NSLog(@"A null or invalid ad request was provided.");
    return;
  }

  [GADRewardedAd loadWithAdUnitID:_adUnitId
                          request:request
                completionHandler:^(GADRewardedAd *_Nullable rewardedAd, NSError *_Nullable error) {
                  if (error) {
                    [self.manager onAdFailedToLoad:self error:error];
                    return;
                  }
                  if (self->_serverSideVerificationOptions != NULL &&
                      ![self->_serverSideVerificationOptions isEqual:[NSNull null]]) {
                    rewardedAd.serverSideVerificationOptions =
                        [self->_serverSideVerificationOptions asGADServerSideVerificationOptions];
                  }
                  __weak FLTRewardedAd *weakSelf = self;
                  rewardedAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                    if (weakSelf.manager == nil) {
                      return;
                    }
                    [weakSelf.manager
                        onPaidEvent:weakSelf
                              value:[[FLTAdValue alloc] initWithValue:value.value
                                                            precision:(NSInteger)value.precision
                                                         currencyCode:value.currencyCode]];
                  };
                  rewardedAd.fullScreenContentDelegate = self;
                  self->_rewardedView = rewardedAd;
                  [self.manager onAdLoaded:self responseInfo:rewardedAd.responseInfo];
                }];
}

- (void)show {
  if (self.rewardedAd) {
    [self.rewardedAd presentFromRootViewController:_rootViewController
                          userDidEarnRewardHandler:^{
                            GADAdReward *reward = self.rewardedAd.adReward;
                            FLTRewardItem *fltReward =
                                [[FLTRewardItem alloc] initWithAmount:reward.amount
                                                                 type:reward.type];
                            [self.manager onRewardedAdUserEarnedReward:self reward:fltReward];
                          }];
  } else {
    NSLog(@"RewardedAd failed to show because the ad was not ready.");
  }
}

#pragma mark - GADFullScreenContentDelegate

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
  [manager didFailToPresentFullScreenContentWithError:self error:error];
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager onAdDidPresentFullScreenContent:self];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager adDidDismissFullScreenContent:self];
}

- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager adWillDismissFullScreenContent:self];
}

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager adDidRecordImpression:self];
}

@synthesize manager;

@end

#pragma mark - FLTAppOpenAd
@implementation FLTAppOpenAd {
  GADAppOpenAd *_appOpenAd;
  FLTAdRequest *_adRequest;
  UIViewController *_rootViewController;
  NSNumber *_orientation;
  NSString *_adUnitId;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                       rootViewController:(UIViewController *_Nonnull)rootViewController
                              orientation:(NSNumber *_Nonnull)orientation
                                     adId:(NSNumber *_Nonnull)adId {
  self = [super init];
  if (self) {
    self.adId = adId;
    _adRequest = request;
    _rootViewController = rootViewController;
    _orientation = orientation;
    _adUnitId = [adUnitId copy];
  }
  return self;
}

- (GADAppOpenAd *_Nullable)appOpenAd {
  return _appOpenAd;
}

- (void)load {
  GADRequest *request;
  if ([_adRequest isKindOfClass:[FLTGAMAdRequest class]]) {
    FLTGAMAdRequest *gamRequest = (FLTGAMAdRequest *)_adRequest;
    request = gamRequest.asGAMRequest;
  } else if ([_adRequest isKindOfClass:[FLTAdRequest class]]) {
    request = _adRequest.asGADRequest;
  } else {
    NSLog(@"A null or invalid ad request was provided.");
    return;
  }

  UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
  if ([_orientation isEqualToNumber:@1]) {
    orientation = UIInterfaceOrientationPortrait;
  } else if ([_orientation isEqualToNumber:@2]) {
    orientation = UIInterfaceOrientationLandscapeLeft;
  } else if ([_orientation isEqualToNumber:@3]) {
    orientation = UIInterfaceOrientationLandscapeRight;
  }

  [GADAppOpenAd loadWithAdUnitID:_adUnitId
                         request:request
                     orientation:orientation
               completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
                 if (error) {
                   [self.manager onAdFailedToLoad:self error:error];
                   return;
                 }
                 __weak FLTAppOpenAd *weakSelf = self;
                 appOpenAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
                   if (weakSelf.manager == nil) {
                     return;
                   }
                   [weakSelf.manager
                       onPaidEvent:weakSelf
                             value:[[FLTAdValue alloc] initWithValue:value.value
                                                           precision:(NSInteger)value.precision
                                                        currencyCode:value.currencyCode]];
                 };
                 appOpenAd.fullScreenContentDelegate = self;
                 self->_appOpenAd = appOpenAd;
                 [self.manager onAdLoaded:self responseInfo:appOpenAd.responseInfo];
               }];
}

- (void)show {
  if (self.appOpenAd) {
    [self.appOpenAd presentFromRootViewController:_rootViewController];
  } else {
    NSLog(@"AppOpenAd failed to show because the ad was not ready.");
  }
}

#pragma mark - GADFullScreenContentDelegate

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
  [manager didFailToPresentFullScreenContentWithError:self error:error];
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager onAdDidPresentFullScreenContent:self];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager adDidDismissFullScreenContent:self];
}

- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager adWillDismissFullScreenContent:self];
}

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
  [manager adDidRecordImpression:self];
}

@synthesize manager;

@end

#pragma mark - FLTNativeAd

@implementation FLTNativeAd {
  NSString *_adUnitId;
  FLTAdRequest *_adRequest;
  NSObject<FLTNativeAdFactory> *_nativeAdFactory;
  NSDictionary<NSString *, id> *_customOptions;
  GADNativeAdView *_view;
  GADAdLoader *_adLoader;
  FLTNativeAdOptions *_nativeAdOptions;
}

- (instancetype _Nonnull)initWithAdUnitId:(NSString *_Nonnull)adUnitId
                                  request:(FLTAdRequest *_Nonnull)request
                          nativeAdFactory:(NSObject<FLTNativeAdFactory> *_Nonnull)nativeAdFactory
                            customOptions:(NSDictionary<NSString *, id> *_Nullable)customOptions
                       rootViewController:(UIViewController *_Nonnull)rootViewController
                                     adId:(NSNumber *_Nonnull)adId
                          nativeAdOptions:(FLTNativeAdOptions *_Nullable)nativeAdOptions {
  self = [super init];
  if (self) {
    self.adId = adId;
    _adUnitId = adUnitId;
    _adRequest = request;
    _nativeAdFactory = nativeAdFactory;
    _customOptions = customOptions;
    NSArray<GADAdLoaderOptions *> *adLoaderOptions =
        (nativeAdOptions == nil || [[NSNull null] isEqual:nativeAdOptions])
            ? @[]
            : nativeAdOptions.asGADAdLoaderOptions;

    _adLoader = [[GADAdLoader alloc] initWithAdUnitID:_adUnitId
                                   rootViewController:rootViewController
                                              adTypes:@[ kGADAdLoaderAdTypeNative ]
                                              options:adLoaderOptions];
    _nativeAdOptions = nativeAdOptions;
    self.adLoader.delegate = self;
  }
  return self;
}

- (GADAdLoader *_Nonnull)adLoader {
  return _adLoader;
}

- (void)load {
  GADRequest *request;
  if ([_adRequest isKindOfClass:[FLTGAMAdRequest class]]) {
    FLTGAMAdRequest *gamRequest = (FLTGAMAdRequest *)_adRequest;
    request = gamRequest.asGAMRequest;
  } else {
    request = _adRequest.asGADRequest;
  }

  [self.adLoader loadRequest:request];
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
  // Use Nil instead of Null to fix crash with Swift integrations.
  NSDictionary<NSString *, id> *customOptions =
      [[NSNull null] isEqual:_customOptions] ? nil : _customOptions;
  _view = [_nativeAdFactory createNativeAd:nativeAd customOptions:customOptions];
  nativeAd.delegate = self;

  __weak FLTNativeAd *weakSelf = self;
  nativeAd.paidEventHandler = ^(GADAdValue *_Nonnull value) {
    if (weakSelf.manager == nil) {
      return;
    }
    [weakSelf.manager onPaidEvent:weakSelf
                            value:[[FLTAdValue alloc] initWithValue:value.value
                                                          precision:(NSInteger)value.precision
                                                       currencyCode:value.currencyCode]];
  };
  [manager onAdLoaded:self responseInfo:nativeAd.responseInfo];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
  [manager onAdFailedToLoad:self error:error];
}

#pragma mark - GADNativeAdDelegate

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
  [manager onNativeAdClicked:self];
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
  [manager onNativeAdImpression:self];
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
  [manager onNativeAdWillPresentScreen:self];
}

- (void)nativeAdWillDismissScreen:(nonnull GADNativeAd *)nativeAd {
  [manager onNativeAdWillDismissScreen:self];
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
  [manager onNativeAdDidDismissScreen:self];
}

#pragma mark - FlutterPlatformView
- (UIView *)view {
  return _view;
}

@synthesize manager;

@end

@implementation FLTRewardItem
- (instancetype _Nonnull)initWithAmount:(NSNumber *_Nonnull)amount type:(NSString *_Nonnull)type {
  self = [super init];
  if (self) {
    _amount = amount;
    _type = type;
  }
  return self;
}

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  } else if (![super isEqual:other]) {
    return NO;
  } else {
    FLTRewardItem *item = other;
    return [_amount isEqual:item.amount] && [_type isEqual:item.type];
  }
}

- (NSUInteger)hash {
  return _amount.hash | _type.hash;
}
@end

@implementation FLTAdValue
- (instancetype _Nonnull)initWithValue:(NSDecimalNumber *_Nonnull)value
                             precision:(NSInteger)precision
                          currencyCode:(NSString *_Nonnull)currencyCode {
  self = [super init];
  if (self) {
    _valueMicros =
        [value decimalNumberByMultiplyingBy:[[NSDecimalNumber alloc] initWithInteger:1000000]];
    _precision = precision;
    _currencyCode = currencyCode;
  }
  return self;
}
@end

@implementation FLTVideoOptions
- (instancetype _Nonnull)initWithClickToExpandRequested:(NSNumber *_Nullable)clickToExpandRequested
                                customControlsRequested:(NSNumber *_Nullable)customControlsRequested
                                             startMuted:(NSNumber *_Nullable)startMuted {
  self = [super init];
  if (self) {
    _clickToExpandRequested = clickToExpandRequested;
    _customControlsRequested = customControlsRequested;
    _startMuted = startMuted;
  }
  return self;
}

- (GADVideoOptions *_Nonnull)asGADVideoOptions {
  GADVideoOptions *options = [[GADVideoOptions alloc] init];
  if ([FLTAdUtil isNotNull:_clickToExpandRequested]) {
    options.clickToExpandRequested = _clickToExpandRequested.boolValue;
  }
  if ([FLTAdUtil isNotNull:_customControlsRequested]) {
    options.customControlsRequested = _customControlsRequested.boolValue;
  }
  if ([FLTAdUtil isNotNull:_startMuted]) {
    options.startMuted = _startMuted.boolValue;
  }
  return options;
}

@end

@implementation FLTNativeAdOptions
- (instancetype _Nonnull)initWithAdChoicesPlacement:(NSNumber *_Nullable)adChoicesPlacement
                                   mediaAspectRatio:(NSNumber *_Nullable)mediaAspectRatio
                                       videoOptions:(FLTVideoOptions *_Nullable)videoOptions
                            requestCustomMuteThisAd:(NSNumber *_Nullable)requestCustomMuteThisAd
                        shouldRequestMultipleImages:(NSNumber *_Nullable)shouldRequestMultipleImages
                     shouldReturnUrlsForImageAssets:
                         (NSNumber *_Nullable)shouldReturnUrlsForImageAssets {
  self = [super init];
  if (self) {
    _adChoicesPlacement = adChoicesPlacement;
    _mediaAspectRatio = mediaAspectRatio;
    _videoOptions = videoOptions;
    _requestCustomMuteThisAd = requestCustomMuteThisAd;
    _shouldRequestMultipleImages = shouldRequestMultipleImages;
    _shouldReturnUrlsForImageAssets = shouldReturnUrlsForImageAssets;
  }
  return self;
}

- (NSArray<GADAdLoaderOptions *> *_Nonnull)asGADAdLoaderOptions {
  NSMutableArray<GADAdLoaderOptions *> *options = [NSMutableArray array];

  GADNativeAdImageAdLoaderOptions *imageOptions = [[GADNativeAdImageAdLoaderOptions alloc] init];
  if ([FLTAdUtil isNotNull:_shouldReturnUrlsForImageAssets]) {
    imageOptions.disableImageLoading = _shouldReturnUrlsForImageAssets.boolValue;
  }
  if ([FLTAdUtil isNotNull:_shouldRequestMultipleImages]) {
    imageOptions.shouldRequestMultipleImages = _shouldRequestMultipleImages.boolValue;
  }
  [options addObject:imageOptions];

  if ([FLTAdUtil isNotNull:_adChoicesPlacement]) {
    GADNativeAdViewAdOptions *adViewOptions = [[GADNativeAdViewAdOptions alloc] init];
    switch (_adChoicesPlacement.intValue) {
      case 0:
        adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionTopRightCorner;
        break;
      case 1:
        adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionTopLeftCorner;
        break;
      case 2:
        adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;
        break;
      case 3:
        adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionBottomLeftCorner;
        break;
      default:
        NSLog(@"AdChoicesPlacement should be an int in the range [0, 3]: %d",
              _adChoicesPlacement.intValue);
        break;
    }
    [options addObject:adViewOptions];
  }

  if ([FLTAdUtil isNotNull:_mediaAspectRatio]) {
    GADNativeAdMediaAdLoaderOptions *mediaOptions = [[GADNativeAdMediaAdLoaderOptions alloc] init];
    switch (_mediaAspectRatio.intValue) {
      case 0:
        mediaOptions.mediaAspectRatio = GADMediaAspectRatioUnknown;
        break;
      case 1:
        mediaOptions.mediaAspectRatio = GADMediaAspectRatioAny;
        break;
      case 2:
        mediaOptions.mediaAspectRatio = GADMediaAspectRatioLandscape;
        break;
      case 3:
        mediaOptions.mediaAspectRatio = GADMediaAspectRatioPortrait;
        break;
      case 4:
        mediaOptions.mediaAspectRatio = GADMediaAspectRatioSquare;
        break;
      default:
        NSLog(@"MediaAspectRatio should be an int in the range [0, 4]: %d",
              _mediaAspectRatio.intValue);
        break;
    }
    [options addObject:mediaOptions];
  }

  if ([FLTAdUtil isNotNull:_videoOptions]) {
    [options addObject:_videoOptions.asGADVideoOptions];
  }
  return options;
}

@end
