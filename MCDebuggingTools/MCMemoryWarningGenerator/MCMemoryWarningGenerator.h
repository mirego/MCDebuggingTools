// Copyright (c) 2013-2015, Mirego
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

#import <mach/mach.h>
#import <mach/mach_host.h>

#ifdef DEBUG

#define PERFORM_MEMORY_WARNING_AT_INTERVAL(interval) \
    [NSTimer scheduledTimerWithTimeInterval:interval target:[MCMemoryWarningGenerator class] selector:@selector(performMemoryWarning) userInfo:nil repeats:YES];

#if !TARGET_IPHONE_SIMULATOR
#define ALLOCATE_MEMORY_BLOCK_AT_INTERNAL(interval) \
    [NSTimer scheduledTimerWithTimeInterval:interval target:[MCMemoryWarningGenerator sharedInstance] selector:@selector(allocateMemoryBlock) userInfo:nil repeats:YES];
#else
#define ALLOCATE_MEMORY_BLOCK_AT_INTERNAL(interval)
#endif

@interface MCMemoryWarningGenerator : NSObject
+ (MCMemoryWarningGenerator *)sharedInstance;
+ (void)performMemoryWarning;
- (void)allocateMemoryBlock;
@end

@interface MCMemoryWarningGenerator ()
@property (atomic, strong) NSMutableArray* memoryBlocks;
@end

@implementation MCMemoryWarningGenerator
@synthesize memoryBlocks;

+ (MCMemoryWarningGenerator *)sharedInstance {
    static MCMemoryWarningGenerator* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MCMemoryWarningGenerator alloc] init];
        instance.memoryBlocks = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(memoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    });

    return instance;
}

+ (void)performMemoryWarning {
#if !TARGET_IPHONE_SIMULATOR
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[UIApplication sharedApplication] performSelector:@selector(_performMemoryWarning)];
#pragma clang diagnostic pop
#else
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
#endif
}

- (void)allocateMemoryBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        size_t block_size = 5 * (1024 * 1024);
        void* block = malloc(block_size);
        if (block != NULL) {
            bzero(block, block_size);
            [self.memoryBlocks addObject:[NSData dataWithBytesNoCopy:block length:block_size freeWhenDone:YES]];
        }
    });
}

- (void)memoryWarning:(NSNotification *)notification {
    vm_size_t pagesize;
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);

    // CGFloat MB = (1024.0f * 1024.0f);
    vm_statistics_data_t vm_stat;
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    } else {
        // natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
        // natural_t mem_free = vm_stat.free_count * pagesize;
        // natural_t mem_total = mem_used + mem_free;
        // NSLog(@"[B] Received memory warning - used: %.2f MB free: %.2f MB total: %.2f MB", mem_used/MB, mem_free/MB, mem_total/MB);
    }

    [self.memoryBlocks removeAllObjects];

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    } else {
        // natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
        // natural_t mem_free = vm_stat.free_count * pagesize;
        // natural_t mem_total = mem_used + mem_free;
        // NSLog(@"[A] Received memory warning - used: %.2f MB free: %.2f MB total: %.2f MB", mem_used/MB, mem_free/MB, mem_total/MB);
    }
}

@end

#else

#define PERFORM_MEMORY_WARNING_AT_INTERVAL(interval)
#define ALLOCATE_MEMORY_BLOCK_AT_INTERNAL(interval)

#endif
