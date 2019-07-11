//
//  JKLogFileListViewController.m
//  JKLogHelper
//
//  Created by JackLee on 2019/6/20.
//

#import "JKLogFileListViewController.h"
#import "JKLogHelper.h"
#import "JKLogViewController.h"

@interface JKLogFileListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray *datas;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation JKLogFileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
}

- (void)close:(UIButton *)button{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configDatas];
    [self.tableView reloadData];
}

- (void)configDatas{
    self.datas = [JKLogHelper getLogFiles];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [self.datas objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileName = [self.datas objectAtIndex:indexPath.row];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[JKLogHelper folderPath],fileName];
    JKLogViewController *logVC = [JKLogViewController new];
    logVC.filePath = filePath;
    logVC.title = fileName;
    [self.navigationController pushViewController:logVC animated:YES];
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
