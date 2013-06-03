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

#import "MCServerEnvironmentViewController.h"
#import "MCServerEnvironment.h"

@interface MCServerEnvironmentViewController() <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *_serverEnvironmentInfos;
    MCServerEnvironmentInfo *_selectedServerEnvironmentInfo;
}

@end

@implementation MCServerEnvironmentViewController

- (id)initWithServerEnvironmentInfos:(NSArray *)infos selectedServerEnvironmentInfo:(MCServerEnvironmentInfo *)info
{
    self = [super init];
    if (self) {
        _serverEnvironmentInfos = infos;
        _selectedServerEnvironmentInfo = info;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    UIBarButtonItem* resetDefaultButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset default" style:UIBarButtonItemStyleBordered target:self action:@selector(resetDefault:)];
    [self.navigationItem setRightBarButtonItems:@[saveButton, resetDefaultButton]];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_selectedServerEnvironmentInfo) {
        NSInteger selectedServerEnvironmentInfoIndex = [_serverEnvironmentInfos indexOfObject:_selectedServerEnvironmentInfo];
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedServerEnvironmentInfoIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource
//------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_serverEnvironmentInfos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"Identifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    MCServerEnvironmentInfo* serverEnvironmentInfo = _serverEnvironmentInfos[indexPath.row];
    [cell.textLabel setText:[serverEnvironmentInfo localizedType]];

    return cell;
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDelegate
//------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedServerEnvironmentInfo = _serverEnvironmentInfos[indexPath.row];
}

//------------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------------

- (void)resetDefault:(id)sender
{
    if ([_delegate respondsToSelector:@selector(serverEnvironmentViewControllerDidResetDefaultServerEnvironment:)]) {
        [_delegate serverEnvironmentViewControllerDidResetDefaultServerEnvironment:self];
    }
}

- (void)save:(id)sender
{
    if ([_delegate respondsToSelector:@selector(serverEnvironmentViewController:didSelectServerEnvironmentInfo:)]) {
        [_delegate serverEnvironmentViewController:self didSelectServerEnvironmentInfo:_selectedServerEnvironmentInfo];
    }
}

- (void)cancel:(id)sender
{
    if ([_delegate respondsToSelector:@selector(serverEnvironmentViewControllerDidCancelServerEnvironmentSelection:)]) {
        [_delegate serverEnvironmentViewControllerDidCancelServerEnvironmentSelection:self];
    }
}

@end
