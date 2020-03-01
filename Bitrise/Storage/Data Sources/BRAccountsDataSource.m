//
//  BRAccountsDataSource.m
//  BitBot
//
//  Created by Deszip on 06/07/2018.
//  Copyright © 2018 BitBot. All rights reserved.
//

#import "BRAccountsDataSource.h"

#import <CoreData/CoreData.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "BTRAccount+CoreDataClass.h"
#import "BRApp+CoreDataClass.h"
#import "BRAccountCellView.h"
#import "BRManagingAppCellView.h"

@interface BRAccountsDataSource () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSOutlineView *outlineView;

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) NSFetchedResultsController *accountsFRC;

@end

@implementation BRAccountsDataSource

- (instancetype)initWithContainer:(NSPersistentContainer *)container {
    if (self = [super init]) {
        _container = container;
        _accountsFRC = [self buildAccountsFRC:self.container.viewContext];
        [_accountsFRC setDelegate:self];
    }
    
    return self;
}

#pragma mark - Actions -

- (void)bind:(NSOutlineView *)outlineView {
    _outlineView = outlineView;
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView reloadData];
}

- (void)fetch {
    NSError *fetchError = nil;
    if (![self.accountsFRC performFetch:&fetchError]) {
        NSLog(@"Failed to fetch apps: %@", fetchError);
    }
    [self.outlineView reloadData];
}

#pragma mark - Builders -

- (NSFetchedResultsController *)buildAccountsFRC:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [BTRAccount fetchRequest];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
    [context setAutomaticallyMergesChangesFromParent:YES];
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - NSOutlineViewDataSource -

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if ([item isKindOfClass:[BTRAccount class]]) {
        return [[(BTRAccount *)item apps] objectAtIndex:index];
    }
    
    return [self.accountsFRC.sections[0] objects][index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[BTRAccount class]]) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if ([item isKindOfClass:[BTRAccount class]]) {
        return [[(BTRAccount *)item apps] count];
    }
    
    return [[self.accountsFRC.sections[0] objects] count];
}

#pragma mark - NSOutlineViewDelegate -

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    return 52.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    if ([item isKindOfClass:[BTRAccount class]]) {
        BTRAccount *account = (BTRAccount *)item;
        BRAccountCellView *cell = [outlineView makeViewWithIdentifier:@"BRAccountCellView" owner:self];
        
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:account.avatarURL]
                                placeholderImage:[NSImage imageNamed:@"avatar-default"]];
        [cell.accountNameLabel setStringValue:account.username ? account.username : @""];
        
        NSString *email = @"";
        if (account.email) {
            email = account.email;
        } else if (account.emailUnconfirmed) {
            email = account.emailUnconfirmed;
        }
        [cell.emailLabel setStringValue:email];
        
        return cell;
    }
    
    if ([item isKindOfClass:[BRApp class]]) {
        BRApp *app = (BRApp *)item;
        BRManagingAppCellView *cell = [outlineView makeViewWithIdentifier:@"BRManagingAppCellView" owner:self];
        [cell.appIcon sd_setImageWithURL:[NSURL URLWithString:app.avatarURL]
                        placeholderImage:[NSImage imageNamed:@"avatar-default"]];
        [cell.appName setStringValue:app.title];
        [cell.appRepoURL setStringValue:app.repoURL];
        if (app.buildToken) {
            [cell.buildToken setHidden:NO];
            [cell.buildToken setStringValue:app.buildToken];
        } else {
            [cell.buildToken setHidden:YES];
        }
        
        return cell;
    }

    return nil;
}

#pragma mark - NSFetchedResultsControllerDelegate -

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.outlineView reloadData];
}

@end
