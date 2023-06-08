# RabbitMq

除了日志落库以外，大部分的场景都是用的RabbitMq

## 基础知识

### 确认机制

- 手动ack：调接口给消息队列确认，可靠性好（消息队列设置了手动ack，消费端一定要写对应的代码）；
- 自动ack：消息发送出去就ack，速率高

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/253bf2341406f52bf1cfa99c4f1965ad.png" alt="253bf2341406f52bf1cfa99c4f1965ad" width="450" >

推模式用的多，服务端主动推； 拉模式用的少

### 死信队列

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685011793508_AD46DA1E-0D7B-43d6-8B6D-99FBB27C4F9E.png" alt="1685011793508_AD46DA1E-0D7B-43d6-8B6D-99FBB27C4F9E" width="450" >

第三种情况能少见，即使出现积压，那也一般是服务先崩，而不是打到最大长度

RabbitMq大致流程图：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685011890204_245D3C6A-FBD2-4ea7-A7FC-06CC4436216A.png" alt="1685011890204_245D3C6A-FBD2-4ea7-A7FC-06CC4436216A" width="450" >


#### 延迟队列

超时时间+死信队列

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/76f0f083313fd62fcf7cd91bb4d3effb.png" alt="76f0f083313fd62fcf7cd91bb4d3effb" width="450" >

从死信队列取消息

### 存储机制

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685012084079_7AECFC4C-49CD-4604-85F8-B202C22249FD.png" alt="1685012084079_7AECFC4C-49CD-4604-85F8-B202C22249FD" width="450" >
<br/>

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685012139284_03BC5A48-E9E7-4303-BC74-DECC477DCF52.png" alt="1685012139284_03BC5A48-E9E7-4303-BC74-DECC477DCF52" width="450" >

告警后，将阻塞消息发送，需进行流控（如两种算法？）


<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685012355823_96DF7AC1-58B3-4a2e-9429-A05F46052F9E.png" alt="1685012355823_96DF7AC1-58B3-4a2e-9429-A05F46052F9E" width="450" >
<br/>

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/410aeebe6d7094e3b635575ad3739449.png" alt="410aeebe6d7094e3b635575ad3739449" width="450" >
<br/>

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1905c1042f83ef5a62f730a48d45a30b.png" alt="1905c1042f83ef5a62f730a48d45a30b" width="450" >

什么时候写磁盘，设置一个内存阈值，如到达40%写磁盘


### 集群

分为普通集群与镜像队列集群

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685012500479_761AA8D7-D647-4770-93C4-74C7A40041F2.png" alt="1685012500479_761AA8D7-D647-4770-93C4-74C7A40041F2" width="450" ><br/>

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/129f6fb1a16b9345dfc2269b9923fb04.png" alt="129f6fb1a16b9345dfc2269b9923fb04" width="450" >

一个消息从主节点转一圈，才发ack

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685012704346_128169DC-8F4E-45ca-A58A-158664975220.png" alt="1685012704346_128169DC-8F4E-45ca-A58A-158664975220" width="450" >

#### 负载均衡

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/5a956cfcd0f3366477710e10bf447dad.png" alt="5a956cfcd0f3366477710e10bf447dad" width="450" >

三个broker无主从概念，队列有主从，但是也是负载均衡的 =》 不要把所有master放到一个broker

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/1685012865718_B83043FB-B837-450d-A4D5-B92A6F9CF5D9.png" alt="1685012865718_B83043FB-B837-450d-A4D5-B92A6F9CF5D9" width="450" >


## 使用

