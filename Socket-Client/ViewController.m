//
//  ViewController.m
//  Socket-Client
//
//  Created by xuhui on 15/6/1.
//  Copyright (c) 2015年 xuhui. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
{
    NSMutableString *_logInfo;
    
    BOOL _isConnection;
    GCDAsyncSocket *asyncSocket;
    
    int msgID;
}

@property (weak, nonatomic) IBOutlet UITextField *ipText;
@property (weak, nonatomic) IBOutlet UITextField *portText;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet UITextView *logView;

@property (weak, nonatomic) IBOutlet UITextField *writeText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _isConnection = NO;
    _logInfo = [NSMutableString new];
    
    //初始化socket对象
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
 
}

#pragma mark - Start Or Stop Connection
- (IBAction)btnChack:(id)sender {
    
    if (_isConnection) {
        [asyncSocket disconnect];
        [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
    } else {
        self.startBtn.enabled = NO;
        
        NSString *ip = self.ipText.text;
        NSString *port = self.portText.text;
        
        [self showInfo:[NSString stringWithFormat:@"Connection host %@ and port %@", ip, port]];
        
        //连接服务器
        NSError *err = nil;
        [asyncSocket connectToHost:ip onPort:[port intValue] error:&err];
        
    }
}

#pragma mark - Write Data
- (IBAction)writeDataToServer:(id)sender
{
    msgID ++;
    
    /*
     * 发送的数据后面需要带（重要）\r\n
     */
    
    NSString *writeStr = [NSString stringWithFormat:@"%@\r\n", self.writeText.text];
    
    [self showInfo:[NSString stringWithFormat:@"[Write][%d]： %@", msgID, writeStr]];
    
    //发送消息
    [asyncSocket writeData:[writeStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
//连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self showInfo:@"Socket connection success"];
    
    self.startBtn.enabled = YES;
    [self.startBtn setTitle:@"Stop" forState:UIControlStateNormal];
    _isConnection = YES;
    
    //持续接收服务端返回的数据
    [asyncSocket readDataWithTimeout:-1 tag:0];
}

//读取数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //持续接收服务端返回的数据
    [asyncSocket readDataWithTimeout:-1 tag:0];
    
    NSString *info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    info = [NSString stringWithFormat:@"[Read]：%@", info];
    
    [self showInfo:info];
    
}

//socket已完成写数据的请求后调用，如果有错误则不调用
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
    [asyncSocket readDataWithTimeout:-1 tag:109];
    NSLog(@"Write data done");
    
}

//连接失败时和断开（手动和被动）时调用(如果连接成功貌似不会进此函数)  待调整
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (_isConnection) {
        if (err == nil) {
            [self showInfo:[NSString stringWithFormat:@"Disconnect Success"]];
        } else {
            [self showInfo:[NSString stringWithFormat:@"Socket closed by remote peer"]];
            NSLog(@"%@", err);
            [self.startBtn setTitle:@"Start" forState:UIControlStateNormal];
        }
        _isConnection = NO;
    } else {
        if(err != nil){
            [self showInfo:[NSString stringWithFormat:@"Connection Error"]];
            NSLog(@"%@", err);
        }
    }
    
    self.startBtn.enabled = YES;
}

//作为服务端，当有Socket接受连接后，调用此函数(客户端可以忽略)
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket");
}

//当使用SSL/TLS并且成功后调用此函数，如果SSL/TLS negotiation失败（证书无效），Socket将立即关闭，并调用socketDidDisconnect:withError:
- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"socketDidSecure");
}

//如果autoDisconnectOnClosedReadStream(默认YES)设置为NO时该函数调用
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    NSLog(@"socketDidCloseReadStream");
}



#pragma mark - show log
- (void)showInfo:(NSString *)log
{
    [_logInfo appendString:[NSString stringWithFormat:@"%@\n", log]];
    
    self.logView.text = _logInfo;
    
    [self.logView scrollRangeToVisible:NSMakeRange(self.logView.text.length, 1)];
}

@end
