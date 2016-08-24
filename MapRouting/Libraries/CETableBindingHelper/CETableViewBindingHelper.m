//
//  RWTableViewBindingHelper.m
//  RWTwitterSearch
//
//  Created by Colin Eberhardt on 24/04/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import "CETableViewBindingHelper.h"
#import "CEReactiveView.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface CETableViewBindingHelper () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation CETableViewBindingHelper {
  UITableView *_tableView;
  NSArray *_data;
  UITableViewCell *_templateCell;
  RACCommand *_selection;
  RACCommand *_loadMoreCommand;
}

#pragma  mark - initialization

- (instancetype)initWithTableView:(UITableView *)tableView
                     sourceSignal:(RACSignal *)source
                 selectionCommand:(RACCommand *)selection
                     templateCell:(UINib *)templateCellNib {
    return [self initWithTableView:tableView sourceSignal:source selectionCommand:selection loadingMoreCommand:nil templateCell:templateCellNib];
}

- (instancetype)initWithTableView:(UITableView *)tableView
                     sourceSignal:(RACSignal *)source
                 selectionCommand:(RACCommand *)selection
               loadingMoreCommand:(RACCommand*)loadingMore
                     templateCell:(UINib *)templateCellNib {
  
  if (self = [super init]) {
    _tableView = tableView;
    _data = [NSArray array];
    _selection = selection;
    _loadMoreCommand = loadingMore;
    
    // each time the view model updates the array property, store the latest
    // value and reload the table view
    [source subscribeNext:^(id x) {
      self->_data = x;
      [self->_tableView reloadData];
        NSLog(@"change data: %d", (int)self->_data.count);
    }];
    
    // create an instance of the template cell and register with the table view
    _templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    NSString *identifier = _templateCell.reuseIdentifier ? _templateCell.reuseIdentifier : NSStringFromClass([_templateCell class]);
    [_tableView registerNib:templateCellNib forCellReuseIdentifier:identifier];
    
    // use the template cell to set the row height
    _tableView.rowHeight = _templateCell.bounds.size.height;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
  }
  return self;
}

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)source
                         selectionCommand:(RACCommand *)selection
                       loadingMoreCommand:(RACCommand*)loadingMore
                             templateCell:(UINib *)templateCellNib {
    
    return [[CETableViewBindingHelper alloc] initWithTableView:tableView
                                                  sourceSignal:source
                                              selectionCommand:selection
                                            loadingMoreCommand:loadingMore
                                                  templateCell:templateCellNib];
}

+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                             sourceSignal:(RACSignal *)source
                         selectionCommand:(RACCommand *)selection
                             templateCell:(UINib *)templateCellNib{
  
  return [[CETableViewBindingHelper alloc] initWithTableView:tableView
                                                sourceSignal:source
                                            selectionCommand:selection
                                                templateCell:templateCellNib];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = _templateCell.reuseIdentifier ? _templateCell.reuseIdentifier : NSStringFromClass([_templateCell class]);
    id<CEReactiveView> cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell bindViewModel:_data[indexPath.row]];
    if ([cell respondsToSelector:@selector(setIndexPath:)])
        [cell performSelector:@selector(setIndexPath:) withObject:indexPath];
    return (UITableViewCell *)cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _data.count - 1) {
        if (_loadMoreCommand) {
            [_loadMoreCommand execute:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_templateCell class] respondsToSelector:@selector(heightForItem:)]) {
        return [[_templateCell class] heightForItem:_data[indexPath.row]];
    }
    return _tableView.rowHeight;
}

#pragma mark = UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [_selection execute:_data[indexPath.row]];
  
  // forward the delegate method
  if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
  }
}

#pragma mark = UITableViewDelegate forwarding

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
    [self.delegate scrollViewDidScroll:scrollView];
  }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  if ([self.delegate respondsToSelector:aSelector]) {
    return YES;
  }
  return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
  if ([self.delegate respondsToSelector:aSelector]) {
    return self.delegate;
  }
  return [super forwardingTargetForSelector:aSelector];
}

@end
