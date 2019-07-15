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

#pragma mark - - - - UITableViewDelegate - - - -
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"分享" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * selectedIndexPath) {
        NSString *fileName = [self.datas objectAtIndex:indexPath.row];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",[JKLogHelper folderPath],fileName];
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSString stringWithFormat:@"file://%@",filePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        UIActivityViewController *activityController=[[UIActivityViewController alloc] initWithActivityItems:@[data] applicationActivities:nil];
        activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            if (completed) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"分享成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertVC dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:nil];
            }else{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"分享失败" message:activityError.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertVC dismissViewControllerAnimated:YES completion:nil];
                }];
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        };
        
         [self presentViewController:activityController animated:YES completion:nil];
        
    }];
    shareAction.backgroundColor = [UIColor blueColor];
    
    
    return @[shareAction];
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
