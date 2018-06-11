<!-- TOC -->

- [网络基础概念](#网络基础概念)
    - [基础知识](#基础知识)
    - [进阶](#进阶)
        - [代理类型](#代理类型)
        - [DMZ](#dmz)
        - [NAT](#nat)

<!-- /TOC -->

# 网络基础概念
## 基础知识
1. 网关：发送的数据包目的地址不在本地网络中, 则转发给网关
2. `ip/ifconfig`:iproute/net-tools
1. DMZ: Perimeter network, 是一种网络架构的布置方案: 在不信任的外部网络和可信任的内部网络外,创建一个面向外部网络的物理/逻辑子网,该子网可用于对往外网络的服务器主机.
2. NAT: Network Address Translation(网络地址转换),也叫作网络掩蔽/IP掩蔽, 是一种在数据包通过路由器或防火墙时重写 来源IP/目的IP地址 的技术.

## 进阶
### 代理类型
1. 透明代理(Transparent Proxy): 直接“隐藏”你的IP地址, 但是能从HTTP_X_FORWARDED_FOR来查到你是谁. 
    ````
    REMOTE_ADDR = Proxy IP
    HTTP_VIA = Proxy IP
    HTTP_X_FORWARDED_FOR = Your IP
    ````
2. 匿名代理(Anonymous Proxy): 知道你用了代理, 但不知道你是谁
    ````
    REMOTE_ADDR = proxy IP
    HTTP_VIA = proxy IP
    HTTP_X_FORWARDED_FOR = proxy IP
    ````
3. 混淆代理(Distorting Proxies):  
    ````
    REMOTE_ADDR = Proxy IP
    HTTP_VIA = Proxy IP
    HTTP_X_FORWARDED_FOR = Random IP address
    ````
4. 高匿代理(Elite proxy): 无法发现你是在用代理
    ````
    REMOTE_ADDR = Proxy IP
    HTTP_VIA = not determined
    HTTP_X_FORWARDED_FOR = not determined
    ````

### DMZ
1. DMZ可以理解为一个不同于外网或内网的特殊网络区域，DMZ内通常放置一些不含机密信息的公用服务器，比如Web、Mail、FTP等。这样来自外网的访问者可以访问DMZ中的服务，但不可能接触到存放在内网中的公司机密或私人信息等，即使DMZ中服务器受到破坏，也不会对内网中的机密信息造成影响。
2. 在一些家用路由器中，DMZ是指一部所有端口都暴露在外部网络的内部网络主机，除此以外的端口都被转发。严格来说这不是真正的DMZ，因为该主机仍能访问内部网络，并非独立于内部网络之外的。但真正的DMZ是不允许访问内部网络的，DMZ和内部网络是分开的。这种 DMZ主机并没有真正DMZ所拥有的子网划分的安全优势，其常常以一种简单的方法将所有端口转发到另外的防火墙或NAT设备上。

### NAT
> https://zh.wikipedia.org/wiki/网络地址转换
1. NAT技术普遍使用在有多台主机但只通过一个公有IP地址访问因特网的私有网络中。根据规范，路由器是不能这样工作，但它的确是一个方便且得到了广泛应用的技术。当然，NAT也让主机之间的通信变得复杂，导致降低了通信效率。
    - 在一个具有NAT功能的路由器下的主机并没有创建真正的IP地址，并且不能参与一些因特网协议: 如从外部创建的TCP链接(考虑家用网络,非独立IP导致不能作为服务器)
    - 端对端连接是被IAB委员会（Internet Architecture Board）支持的核心因特网协议之一, 而NAT并不提供独立IP
2. NAT分类
    - 静态NAT: 一个内网IP对应一个外网IP(由于改变了IP源地址，在重新封装数据包时候必须重新计算校验和，网络层以上的只要涉及到IP地址的头部校验和都要重新计算)
    - NAPT: 网络地址端口转换. 将一个公网IP的一个端口映射到一个内网IP. 有 源地址转换/目的地地址转换 两种.
3. NAT用途
    - 负载均衡: 目的地址转换NAT可以重定向一些服务器的连接到其他随机选定的服务器。
    - 失效终结: 目的地址转换NAT可以用来提供高可靠性的服务。如果一个系统有一台通过路由器访问的关键服务器，一旦路由器检测到该服务器宕机，它可以使用目的地址转换NAT透明的把连接转移到一个备份服务器上。
    - 透明代理: NAT可以把连接到因特网的HTTP连接重定向到一个指定的HTTP代理服务器以缓存数据和过滤请求。一些因特网服务提供商就使用这种技术来减少带宽的使用而不用让他们的客户配置他们的浏览器支持代理连接。
