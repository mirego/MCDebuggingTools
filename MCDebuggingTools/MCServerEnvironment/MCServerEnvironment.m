// Copyright (c) 2013, Mirego
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the Mirego nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "MCServerEnvironment.h"
#import "MCServerEnvironmentViewController.h"

static NSString* const kMCServerEnvironmentSavedInfoDict = @"kMCServerEnvironmentSavedInfoDict";
static NSString* const kMCServerEnvironmentURLSchemeAction = @"env";
static NSString* const kMCServerEnvironmentURLActionParameterKey = @"action";
static NSString* const kMCServerEnvironmentURLResetParameterValue = @"reset";

@interface MCServerEnvironment() <MCServerEnvironmentViewControllerDelegate, UIAlertViewDelegate>
{
    NSURL *_defaultURL;
    NSMutableArray *_serverInfos;
    MCServerEnvironmentViewController *_viewController;
}

@end

@implementation MCServerEnvironment

- (id)initWithDefaultURL:(NSURL *)defaultURL
          developmentURL:(NSURL *)developmentURL
                   ciURL:(NSURL *)ciURL
                   qaURL:(NSURL *)qaURL
              stagingURL:(NSURL *)stagingURL
           productionURL:(NSURL *)productionURL
               otherURLs:(NSURL *)otherURLs, ...
{
    self = [super init];
    if (self) {
        NSAssert(defaultURL != nil, @"Default URL is required for MCServerEnvironment initialization.");
        _defaultURL = defaultURL;
        _serverInfos = [NSMutableArray array];
        if (developmentURL) [_serverInfos addObject:[[MCServerEnvironmentInfo alloc] initWithType:MCServerEnvironmentDevelopment URL:developmentURL]];
        if (ciURL) [_serverInfos addObject:[[MCServerEnvironmentInfo alloc] initWithType:MCServerEnvironmentCI URL:ciURL]];
        if (qaURL) [_serverInfos addObject:[[MCServerEnvironmentInfo alloc] initWithType:MCServerEnvironmentQA URL:qaURL]];
        if (stagingURL) [_serverInfos addObject:[[MCServerEnvironmentInfo alloc] initWithType:MCServerEnvironmentStaging URL:stagingURL]];
        if (productionURL) [_serverInfos addObject:[[MCServerEnvironmentInfo alloc] initWithType:MCServerEnvironmentProduction URL:productionURL]];
        
        id eachObject;
        va_list argumentList;
        if (otherURLs) {
            // The first argument isn't part of the varargs list,
            // so we'll handle it separately.
            [_serverInfos addObject:[[MCServerEnvironmentInfo alloc] initWithType:MCServerEnvironmentUnknow URL:otherURLs]];
            va_start(argumentList, otherURLs);
            while ((eachObject = va_arg(argumentList, id))) {
                [_serverInfos addObject:[[MCServerEnvironmentInfo alloc] initWithType:MCServerEnvironmentUnknow URL:eachObject]];
            }
            va_end(argumentList);
        }
    }
    return self;
}


//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (BOOL)openURL:(NSURL *)url presenterViewController:(UIViewController *)presenterViewController completionBlock:(void (^)(void))completionBlock
{
    if ([[self URLAction:url] isEqualToString:kMCServerEnvironmentURLSchemeAction]) {
        NSDictionary *parameters = [self URLParameters:url];
        NSString *actionParameter = parameters[kMCServerEnvironmentURLActionParameterKey];
        BOOL hasActionParameter = (actionParameter != nil);
        if (hasActionParameter) {
            if ([actionParameter isEqualToString:kMCServerEnvironmentURLResetParameterValue]) {
                [self saveServerEnvironmentInfo:nil dismissController:YES];
            }
        }
        else {
            _viewController = [[MCServerEnvironmentViewController alloc] initWithServerEnvironmentInfos:_serverInfos selectedServerEnvironmentInfo:[self savedServerEnvironmentInfo]];
            [_viewController setDelegate:self];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_viewController];
            [presenterViewController presentViewController:navigationController animated:YES completion:completionBlock];
        }
        return YES;
    }
    return NO;
}

- (NSURL *)URL
{
    NSURL *url = nil;
    MCServerEnvironmentInfo *info = [self savedServerEnvironmentInfo];
    if (info) {
        url = info.URL;
    }
    else {
        url = _defaultURL;
    }
    
    return url;
}

- (void)showDebugAlert
{
#ifdef DEBUG
    BOOL isCustomServerEnvironmentSetted = ([self savedServerEnvironmentInfo] != nil);
    if (isCustomServerEnvironmentSetted) {
        CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, mainScreenBounds.size.width, 20.0f)];
        [view setBackgroundColor:[UIColor redColor]];
        UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:12.0f]];
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:[self URL].absoluteString];
        [view addSubview:label];
        [[[UIApplication sharedApplication] keyWindow] addSubview:view];
        [UIView animateWithDuration:0.3f animations:^{
            [view setFrame:CGRectMake(0.0f, 20.0f, view.frame.size.width, view.frame.size.height)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f delay:3.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [view setFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }];
    }
#endif
}

//------------------------------------------------------------------------------
#pragma mark - Private
//------------------------------------------------------------------------------

- (void)dismissViewControllerWithAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"This will kill the application"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Boom!", nil];
    [alert show];
}

- (MCServerEnvironmentInfo *)savedServerEnvironmentInfo
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kMCServerEnvironmentSavedInfoDict];
    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    MCServerEnvironmentInfo *info = nil;
    if (dict) {
        info = [[MCServerEnvironmentInfo alloc] initWithDictValue:dict];
    }
    return info;
}

- (void)saveServerEnvironmentInfo:(MCServerEnvironmentInfo *)info dismissController:(BOOL)dismissController
{
    if (info) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[info dictValue]];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kMCServerEnvironmentSavedInfoDict];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMCServerEnvironmentSavedInfoDict];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (dismissController) {
        [self dismissViewControllerWithAlert];
    }
}

- (NSString *)URLAction:(NSURL *)url
{
    return [[url host] lowercaseString];
}

- (NSDictionary *)URLParameters:(NSURL *)url
{
    NSMutableDictionary *params = nil;
    NSArray *urlQueryParams = [[url query] componentsSeparatedByString:@"&"];
    
    for (NSString *part in urlQueryParams) {
        NSArray *partComponents = [part componentsSeparatedByString:@"="];
        if (partComponents.count == 2) {
            if (!params) params = [NSMutableDictionary dictionary];
            [params setObject:partComponents[1] forKey:[partComponents[0] lowercaseString]];
        }
    }
    
    return params;
}

//------------------------------------------------------------------------------
#pragma mark - MCServerEnvironmentViewControllerDelegate
//------------------------------------------------------------------------------

- (void)serverEnvironmentViewControllerDidResetDefaultServerEnvironment:(MCServerEnvironmentViewController *)controller
{
    [self saveServerEnvironmentInfo:nil dismissController:YES];
}

- (void)serverEnvironmentViewControllerDidCancelServerEnvironmentSelection:(MCServerEnvironmentViewController *)controller
{
    [_viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)serverEnvironmentViewController:(MCServerEnvironmentViewController *)controller didSelectServerEnvironmentInfo:(MCServerEnvironmentInfo *)serverEnvironmentInfo
{
    [self saveServerEnvironmentInfo:serverEnvironmentInfo dismissController:YES];
}

//------------------------------------------------------------------------------
#pragma mark - UIAlertViewDelegate
//------------------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        [_viewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        exit(0);
    }
}

@end

//------------------------------------------------------------------------------
#pragma mark - MCServerEnvironmentInfo
//------------------------------------------------------------------------------

static NSString* const kMCServerEnvironmentInfoType = @"kMCServerEnvironmentInfoType";
static NSString* const kMCServerEnvironmentInfoURL = @"kMCServerEnvironmentInfoURL";
static NSString* const kMCServerEnvironmentLocalizedDev = @"Development (Local server)";
static NSString* const kMCServerEnvironmentLocalizedCI = @"Continus Integration";
static NSString* const kMCServerEnvironmentLocalizedQA = @"Quality Assurance";
static NSString* const kMCServerEnvironmentLocalizedStaging = @"Staging (Client version)";
static NSString* const kMCServerEnvironmentLocalizedProd = @"Production (AppStore)";

@implementation MCServerEnvironmentInfo

- (id)initWithType:(MCServerEnvironmentType)type URL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _type = type;
        _URL = url;
    }
    return self;
}

- (id)initWithDictValue:(NSDictionary *)dictValue
{
    self = [super init];
    if (self) {
        _type = [dictValue[kMCServerEnvironmentInfoType] integerValue];
        _URL = dictValue[kMCServerEnvironmentInfoURL];
    }
    return self;
}

- (NSString *)localizedType
{
    NSString *localizedType = nil;
    switch (_type) {
        case MCServerEnvironmentDevelopment:
            localizedType = NSLocalizedString(kMCServerEnvironmentLocalizedDev, nil);
            break;
        case MCServerEnvironmentCI:
            localizedType = NSLocalizedString(kMCServerEnvironmentLocalizedCI, nil);
            break;
        case MCServerEnvironmentQA:
            localizedType = NSLocalizedString(kMCServerEnvironmentLocalizedQA, nil);
            break;
        case MCServerEnvironmentStaging:
            localizedType = NSLocalizedString(kMCServerEnvironmentLocalizedStaging, nil);
            break;
        case MCServerEnvironmentProduction:
            localizedType = NSLocalizedString(kMCServerEnvironmentLocalizedProd, nil);
            break;
        default:
        case MCServerEnvironmentUnknow:
            localizedType = [_URL absoluteString];
            break;
    }
    return localizedType;
}

- (NSDictionary *)dictValue
{
    return @{ kMCServerEnvironmentInfoType : @(_type), kMCServerEnvironmentInfoURL : _URL };
}

- (BOOL)isEqual:(id)object
{
    MCServerEnvironmentInfo* serverEnvironmentInfo = (MCServerEnvironmentInfo *)object;
    return serverEnvironmentInfo.type == _type;
}

@end
