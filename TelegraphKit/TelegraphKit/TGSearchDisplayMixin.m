#import "TGSearchDisplayMixin.h"

#import "TGHacks.h"

#import "TGSearchBar.h"

#import <QuartzCore/QuartzCore.h>

@interface TGSearchDisplayMixin () <UISearchBarDelegate, TGSearchBarDelegate>

@property (nonatomic) UIEdgeInsets controllerInset;

@property (nonatomic, strong) UIView *dimView;

@property (nonatomic, strong) UIView *tableViewContainer;

@end

@implementation TGSearchDisplayMixin

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        
    }
    return self;
}

- (void)dealloc
{
    [self unload];
}

- (void)unload
{
    [self _unloadTableView];
}

- (void)_unloadTableView
{
    [_searchResultsTableView removeFromSuperview];
    
    _searchResultsTableView.delegate = nil;
    _searchResultsTableView.dataSource = nil;
    _searchResultsTableView = nil;
}

- (void)setSearchBar:(UISearchBar *)searchBar
{
    if (_searchBar != nil)
        _searchBar.delegate = nil;
    
    _searchBar = searchBar;
    _searchBar.delegate = self;
}

- (void)setIsActive:(bool)isActive
{
    [self setIsActive:isActive animated:true];
}

- (void)setIsActive:(bool)isActive animated:(bool)animated
{
    if (_isActive != isActive)
    {
        _isActive = isActive;
        
        [_searchBar setShowsCancelButton:isActive animated:animated];
        
        if (isActive)
        {
            id<TGSearchDisplayMixinDelegate> delegate = _delegate;
            
            UIView *referenceView = [delegate referenceViewForSearchResults];
            
            [self setSearchResultsTableViewHidden:true];
            _searchResultsTableView.alpha = 1.0f;
            
            if (_dimView == nil)
            {
                _dimView = [[UIView alloc] init];
                _dimView.backgroundColor = UIColorRGBA(0x000000, 0.8f);
                _dimView.alpha = 0.0f;
                _dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            }
            
            if (_tableViewContainer == nil)
            {
                _tableViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
                _tableViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                UIView *tapView = [[UIView alloc] initWithFrame:_tableViewContainer.bounds];
                tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [tapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapped:)]];
                [_tableViewContainer addSubview:tapView];
            }
            
            CGRect dimViewFrame = referenceView.bounds;

            if ([referenceView isKindOfClass:[UIScrollView class]])
            {
                UIScrollView *referenceScrollView = (UIScrollView *)referenceView;
                dimViewFrame.origin.y = -referenceScrollView.contentOffset.y + _searchBar.frame.size.height;
            }
            else
            {
                CGRect searchBarReferenceFrame = [_searchBar convertRect:_searchBar.bounds toView:referenceView.superview];
                dimViewFrame.origin.y = searchBarReferenceFrame.origin.y + searchBarReferenceFrame.size.height;
            }
            
            [[referenceView superview] insertSubview:_tableViewContainer aboveSubview:referenceView];
            
            [[referenceView superview] insertSubview:_dimView aboveSubview:referenceView];
            
            _dimView.frame = dimViewFrame;
            
            CALayer *presentationLayer = _dimView.layer.presentationLayer;
            presentationLayer.frame = dimViewFrame;
            
            CGRect tableViewContainerFrame = referenceView.frame;
            tableViewContainerFrame.origin.y = _controllerInset.top + _searchBar.frame.size.height;
            _tableViewContainer.frame = tableViewContainerFrame;
            
            CALayer *containerPresentationLayer = _tableViewContainer.layer.presentationLayer;
            containerPresentationLayer.frame = _tableViewContainer.frame;
            
            if (animated)
            {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
                {
                    _dimView.alpha = 1.0f;
                } completion:nil];
            }
            else
            {
                _dimView.alpha = 1.0f;
            }
            
            [self _updateSearchBarLayout:animated];
            
            if ([delegate respondsToSelector:@selector(searchMixinWillActivate:)])
                [delegate searchMixinWillActivate:animated];
        }
        else
        {
            [self _updateSearchBarLayout:animated];
            
            [_searchBar resignFirstResponder];
            [_searchBar setText:@""];
            
            if (animated)
            {
                id<TGSearchDisplayMixinDelegate> delegate = _delegate;
                if ([delegate respondsToSelector:@selector(searchMixinWillDeactivate:)])
                    [delegate searchMixinWillDeactivate:animated];
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
                {
                    _dimView.alpha = 0.0f;
                    _searchResultsTableView.alpha = 0.0f;
                } completion:^(BOOL finished)
                {
                    if (finished)
                    {
                        [_dimView removeFromSuperview];
                        [_tableViewContainer removeFromSuperview];
                        [_searchResultsTableView removeFromSuperview];
                        
                        [self _unloadTableView];
                    }
                }];
            }
            else
            {
                id<TGSearchDisplayMixinDelegate> delegate = _delegate;
                if ([delegate respondsToSelector:@selector(searchMixinWillDeactivate:)])
                    [delegate searchMixinWillDeactivate:animated];
                
                _dimView.alpha = 0.0f;
                
                [_dimView removeFromSuperview];
                [_tableViewContainer removeFromSuperview];
                [_searchResultsTableView removeFromSuperview];
                
                [self _unloadTableView];
            }
        }
    }
}

- (void)_updateSearchBarLayout:(bool)animated
{
    float currentHeight = _searchBar.frame.size.height;
    float currentWidth = _searchBar.frame.size.width;
    
    if (_searchBar.scopeButtonTitles.count > 1)
    {
        bool updateSize = false;
        
        if ([_searchBar showsScopeBar] != _isActive)
        {
            [_searchBar setShowsScopeBar:_isActive];
            updateSize = true;
        }
        
        if (currentWidth < 400)
        {
            [(TGSearchBar *)_searchBar setSearchBarCombinesBars:false];
            updateSize = true;
        }
        else
        {
            [(TGSearchBar *)_searchBar setSearchBarCombinesBars:true];
            updateSize = true;
        }
        
        if (updateSize)
        {
            [_searchBar sizeToFit];
        }
    }
    
    if (ABS(currentHeight - _searchBar.frame.size.height) > FLT_EPSILON)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^
            {
                [self searchBar:(TGSearchBar *)_searchBar willChangeHeight:_searchBar.frame.size.height];
                [_searchBar layoutSubviews];
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                }
            }];
        }
        else
        {
            [self searchBar:(TGSearchBar *)_searchBar willChangeHeight:_searchBar.frame.size.height];
            [_searchBar layoutSubviews];
        }
    }
}

- (void)controllerInsetUpdated:(UIEdgeInsets)controllerInset
{
    _controllerInset = controllerInset;
    
    [self controllerLayoutUpdated:CGSizeZero];
}

- (void)controllerLayoutUpdated:(CGSize)__unused layoutSize
{
    [self _updateSearchBarLayout:false];
    
    if (_dimView != nil && _dimView.superview != nil)
    {
        CGRect frame = _dimView.superview.bounds;
        frame.origin.y = _controllerInset.top + _searchBar.frame.size.height;
        _dimView.frame = frame;
    }
    
    if (_tableViewContainer != nil && _tableViewContainer.superview != nil)
    {
        CGRect tableViewContainerFrame = _tableViewContainer.frame;
        tableViewContainerFrame.origin.y = _controllerInset.top + _searchBar.frame.size.height;
        _tableViewContainer.frame = tableViewContainerFrame;
    }
    
    if (_searchResultsTableView != nil && _searchResultsTableView.superview != nil)
    {
        UIEdgeInsets tableInset = _controllerInset;
        tableInset.bottom += tableInset.top + _searchBar.frame.size.height;
        tableInset.top = 0;
        _searchResultsTableView.contentInset = tableInset;
        _searchResultsTableView.scrollIndicatorInsets = tableInset;
    }
    
    if (_searchBar.showsScopeBar)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2 * TGAnimationSpeedFactor();
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_searchBar.layer addAnimation:transition forKey:@"content"];
    }
}

- (void)searchBar:(TGSearchBar *)searchBar willChangeHeight:(float)newHeight
{
    if (searchBar == _searchBar)
    {
        id<TGSearchDisplayMixinDelegate> delegate = _delegate;
        UIView *referenceView = [delegate referenceViewForSearchResults];
        
        if ([referenceView isKindOfClass:[UITableView class]])
        {
            static NSInvocation *invocation = nil;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                SEL selector = NSSelectorFromString(TGEncodeText(@"`ubcmfIfbefsIfjhiuEjeDibohfUpIfjhiu;", -1));
                
                NSMethodSignature *signature = [[UITableView class] instanceMethodSignatureForSelector:selector];
                if (signature == nil)
                {
                    TGLog(@"***** Method not found");
                }
                else
                {
                    invocation = [NSInvocation invocationWithMethodSignature:signature];
                    [invocation setSelector:selector];
                }
            });
            
            if (invocation != nil)
            {
                [invocation setTarget:referenceView];
                float height = newHeight;
                [invocation setArgument:&height atIndex:2];
                [invocation invoke];
                
                [invocation setTarget:nil];
            }
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (searchBar == _searchBar)
    {
        [self setIsActive:true animated:true];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchBar == _searchBar)
    {
        id<TGSearchDisplayMixinDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(searchMixin:hasChangedSearchQuery:withScope:)])
            [delegate searchMixin:self hasChangedSearchQuery:searchText withScope:_searchBar.selectedScopeButtonIndex];
        
        if (searchText.length == 0)
            [self setSearchResultsTableViewHidden:true];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar == _searchBar)
    {
        [self setIsActive:false animated:true];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar == _searchBar)
    {
        [_searchBar resignFirstResponder];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if (searchBar == _searchBar)
    {
        id<TGSearchDisplayMixinDelegate> delegate = _delegate;
        if ([delegate respondsToSelector:@selector(searchMixin:hasChangedSearchQuery:withScope:)])
            [delegate searchMixin:self hasChangedSearchQuery:_searchBar.text withScope:selectedScope];
    }
}

- (void)dimViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_searchResultsTableView == nil || _searchResultsTableView.hidden)
            [self setIsActive:false animated:true];
    }
}

#pragma mark -

- (bool)searchResultsTableViewHidden
{
    return _searchResultsTableView == nil || _searchResultsTableView.hidden;
}

- (void)setSearchResultsTableViewHidden:(bool)searchResultsTableViewHidden
{
    _searchResultsTableView.hidden = searchResultsTableViewHidden;
    _dimView.hidden = !searchResultsTableViewHidden;
}

- (void)reloadSearchResults
{
    if (_searchResultsTableView == nil)
    {
        id<TGSearchDisplayMixinDelegate> delegate = _delegate;
        
        _searchResultsTableView = [delegate createTableViewForSearchMixin:self];
        _searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self setSearchResultsTableViewHidden:true];
    }

    if (_searchResultsTableView.superview == nil)
    {
        _searchResultsTableView.frame = _tableViewContainer.bounds;
        
        UIEdgeInsets tableInset = _controllerInset;
        tableInset.bottom += tableInset.top + _searchBar.frame.size.height;
        tableInset.top = 0;
        _searchResultsTableView.contentInset = tableInset;
        _searchResultsTableView.scrollIndicatorInsets = tableInset;
        
        [_tableViewContainer addSubview:_searchResultsTableView];
    }
    
    [_searchResultsTableView reloadData];
}

@end
