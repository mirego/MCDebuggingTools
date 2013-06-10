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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MCServerEnvironmentType) {
    MCServerEnvironmentDevelopment,     // Local server
    MCServerEnvironmentCI,              // Continuous Integration
    MCServerEnvironmentQA,              // Quality Assurance
    MCServerEnvironmentStaging,         // Client version
    MCServerEnvironmentProduction,      // AppStore
    MCServerEnvironmentUnknow
};

@interface MCServerEnvironment : NSObject

- (id)initWithDefaultURL:(NSURL *)defaultURL
          developmentURL:(NSURL *)developmentURL
                   ciURL:(NSURL *)ciURL
                   qaURL:(NSURL *)qaURL
              stagingURL:(NSURL *)stagingURL
           productionURL:(NSURL *)productionURL
               otherURLs:(NSURL *)otherURLs, ... NS_REQUIRES_NIL_TERMINATION;

- (BOOL)openURL:(NSURL *)url presenterViewController:(UIViewController *)presenterViewController completionBlock:(void (^)(void))completionBlock;
- (NSURL *)URL;
- (void)showDebugAlert;

@end

@interface MCServerEnvironmentInfo : NSObject

@property (nonatomic, readonly) MCServerEnvironmentType type;
@property (nonatomic, readonly) NSURL *URL;

- (id)initWithType:(MCServerEnvironmentType)type URL:(NSURL *)url;
- (id)initWithDictValue:(NSDictionary *)dictValue;
- (NSString *)localizedType;
- (NSDictionary *)dictValue;

@end