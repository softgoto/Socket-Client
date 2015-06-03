# Socket-Client
这个Demo是基于[**GCDAsyncSocket**](https://github.com/robbiehanson/CocoaAsyncSocket)库构建的

简单实现了基于**Socket TCP**方式和服务端通讯，服务端使用的是**GCDAsyncSocket**库中提供的`EchoServer`这个Demo

下面简单说下**GCDAsyncSocket**的使用方式以及我在学习过程中遇到的一些问题：

* 下载**GCDAsyncSocket**到本地并解压，将GCD中的`GCDAsyncSocket.h`和`GCDAsyncSocket.m`导入到项目中。当前Demo中只用到TCP方式，
如果需要用到UDP方式，请自行导入`GCDAsyncUdpSocket.h`和`GCDAsyncUdpSocket.m`文件
* 在Controller中导入头文件`#import "GCDAsyncSocket.h"`并实现`GCDAsyncSocketDelegate`委托
* 初始化一个socket对象
```
    //初始化socket对象
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
```
* 根据IP和Port连接服务器
```
    //连接服务器
    NSError *err = nil;
    [asyncSocket connectToHost:ip onPort:port error:&err];
```
* 连接成功会进入`GCDAsyncSocketDelegate`定义的协议中
```
    - (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
```
* 在`socket:didConnectToHost:port:`函数中需要添加下面代码，如果不加则不能接收到服务端返回的数据
```
    //持续接收服务端返回的数据
    [asyncSocket readDataWithTimeout:-1 tag:0];
```
* 以`EchoServer`这个Demo为例，服务端收到有客户端接入后会write一条数据，内容是：`Welcome to the AsyncSocket Echo Server`
* 这个时候在`socket:didReadData:withTag:`函数中(`GCDAsyncSocketDelegate`定义的协议)，就能读到服务端write的数据，
read到数据后别忘了还需要加上下面代码
```
    //持续接收服务端返回的数据
    [asyncSocket readDataWithTimeout:-1 tag:0];
```
* 然后就是客户端write数据了，可以调用`writeData:withTimeout:tag:`函数来write数据，这里需要注意的是，write数据的末尾必须加上`\r\n`
来标示当前write已经结束，否则服务端会读不到客户端write的数据
```
    //发送消息
    [asyncSocket writeData:[writeStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
```
* 数据write完后会调用`socket:didWriteDataWithTag:`函数(`GCDAsyncSocketDelegate`定义的协议)
* 到此整个流程就结束了，另外如果连接服务器时失败了会调用`socketDidDisconnect:withError`函数，客户端手动断开连接`[asyncSocket disconnect];`

在我查找资料的过程中，有一篇博客对我启发很大，有兴趣的朋友可以看看[《GCDAsyncSocket类库，IOS下TCP通讯使用心得》](http://cvito.net/index.php/archives/1081)



OK，到这里就结束了。
