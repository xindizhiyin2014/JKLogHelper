//
//  JKLogViewController.m
//  Pods
//
//  Created by Jack on 17/2/24.
//
//

#define PrintLog_WeakObj(obj) __weak typeof(obj) obj##Weak = obj;


#import "JKLogViewController.h"

#import "ICTextView.h"


@interface JKLogViewController ()

@property (nonatomic, strong) ICTextView *textView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation JKLogViewController

- (void)loadView
{
    [super loadView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar = searchBar;
    searchBar.delegate = self;
    
    if ([searchBar respondsToSelector:@selector(setInputAccessoryView:)])
    {
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        
        UIBarButtonItem *prevButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"last"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(searchPreviousMatch)];
        
        UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(searchNextMatch)];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.textColor = [UIColor blackColor];
        
        UIBarButtonItem *counter = [[UIBarButtonItem alloc] initWithCustomView:countLabel];
        
        toolBar.items = [[NSArray alloc] initWithObjects:prevButtonItem, nextButtonItem, spacer, counter, nil];
        
        [(id)searchBar setInputAccessoryView:toolBar];
        
        self.toolBar = toolBar;
        self.toolBar.backgroundColor = [UIColor blackColor];
        self.countLabel = countLabel;
    }
    
    ICTextView *textView = [[ICTextView alloc] initWithFrame:CGRectZero];
    self.textView = textView;
    textView.font = [UIFont systemFontOfSize:14.0];
    textView.circularSearch = YES;
    PrintLog_WeakObj(_searchBar);
    PrintLog_WeakObj(self);
    
    textView.searchCallback =^(NSString *selectedStr){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _searchBarWeak.text = selectedStr;
            [selfWeak updateCountLabel];
            [_searchBarWeak becomeFirstResponder];
        });
        
    };
    textView.editable =NO;
    textView.scrollPosition = ICTextViewScrollPositionMiddle;
    textView.searchOptions = NSRegularExpressionCaseInsensitive;
    
    [self.view addSubview:textView];
    [self.view addSubview:searchBar];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"log Message";
    [self updateTextViewInsetsWithKeyboardNotification:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTextViewInsetsWithKeyboardNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    
    
    if (_filePath)
    {
        self.textView.text = [NSString stringWithContentsOfFile:_filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    }
    
    [self updateCountLabel];
    
    
    
    
}

- (void)viewDidLayoutSubviews
{
    CGRect viewBounds = self.view.bounds;
    
    CGRect searchBarFrame = viewBounds;
    searchBarFrame.size.height = 44.0f;
    
    CGRect toolBarFrame = viewBounds;
    toolBarFrame.size.height = 34.0f;
    
    self.searchBar.frame = searchBarFrame;
    self.toolBar.frame = toolBarFrame;
    self.textView.frame = viewBounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
    [self.textView scrollRectToVisible:CGRectZero animated:YES consideringInsets:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _Pragma("unused(searchBar, searchText)")
    [self searchNextMatch];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    _Pragma("unused(searchBar)")
    [self.textView becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _Pragma("unused(searchBar)")
    [self searchNextMatch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [self.textView resetSearch];
    [self updateCountLabel];
}

#pragma mark - ICTextView

- (void)searchNextMatch
{
    [self searchMatchInDirection:ICTextViewSearchDirectionForward];
}

- (void)searchPreviousMatch
{
    [self searchMatchInDirection:ICTextViewSearchDirectionBackward];
}

- (void)searchMatchInDirection:(ICTextViewSearchDirection)direction
{
    NSString *searchString = self.searchBar.text;
    
    if (searchString.length)
        [self.textView scrollToString:searchString searchDirection:direction];
    else
        [self.textView resetSearch];
    
    [self updateCountLabel];
}

- (void)updateCountLabel
{
    ICTextView *textView = self.textView;
    UILabel *countLabel = self.countLabel;
    
    NSUInteger numberOfMatches = textView.numberOfMatches;
    countLabel.text = numberOfMatches ? [NSString stringWithFormat:@"%lu/%lu", (unsigned long)textView.indexOfFoundString + 1, (unsigned long)numberOfMatches] : @"0/0";
    [countLabel sizeToFit];
}

#pragma mark - Keyboard

- (void)updateTextViewInsetsWithKeyboardNotification:(NSNotification *)notification
{
    UIEdgeInsets newInsets = UIEdgeInsetsZero;
    newInsets.top = self.searchBar.frame.size.height;
    
    if (notification)
    {
        CGRect keyboardFrame;
        
        [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
        
        newInsets.bottom = self.view.frame.size.height - keyboardFrame.origin.y;
    }
    
    ICTextView *textView = self.textView;
    textView.contentInset = newInsets;
    textView.scrollIndicatorInsets = newInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
