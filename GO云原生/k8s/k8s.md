# k8s

## 简介

基于容器技术平台、部署的都是镜像

k8s能做什么：
- 服务发现和负载均衡：使用dns名称或自己的ip来暴露容器，如果进入容器的流量很大，可以负载均衡地分配网络流量。
- 部署和回滚：
- 弹性伸缩：配置自动伸缩策略，以应对突发流量
- 容器配额管理：允许为每个容器指定所需的CPU和内存
- 故障发现和自我修复：自动发现不符合运行状态标准的容器，并尝试去重启、替换这些容器。
- 密钥和配置管理：Kubernetes提供secret和configMap，两种资源来分别管理密钥信息和配置信
  息。
-  支持多种数据卷类型，例如：本地存储、公有云提供商、分布式存储系统等。

k8s组件：

- 控制平面组件
master节点会为集群做出全局决策，比如资源调度，检测和和响应集群事件，例如：启动或删除pod。
master节点通常不运行任何工作负载。
  1. kube-apiserver ,apiserver是 Kubernetes master节点的组件， 该组件负责公开了 Kubernetes
     API，负责处理接受请求的工作。 kube-apiser 支持高可用部署。
  2. etcd，兼顾一致性与高可用的键值数据库，用来保存Kubernetes集群数据。
  3. kube-scheduler，是master节点组件，负责监视新创建的、未指定运行节点的Pod，并选择节点
     来运行Pod。
  4. kube-controller-manager，是master节点组件，负责运行控制器进程。

- Node节点组件

1. kubelet，在集群中每个节点（node）上运行。 它保证容器（containers）都运行在 Pod 中。配
   合master节点管理node节点，向master节点报告node节点信息，例如：操作系统、Docker版
   本、机器的CPU和内存情况，以及当前有哪些Pod在运行等。通过定时心跳向master报告节点状
   态。若超时未能上报节点状态，则master节点会判断该节点为“失联”并调度pod到其他节点运行。
2. kube-proxy，是集群中每个节点上所运行的网络代理，实现Kubernetes服务（service）概念的一
   部分。kube-proxy 维护节点上的一些网络规则， 这些网络规则会允许从集群内部或外部的网络会
   话与 Pod 进行网络通信。
3. 容器运行时，例如：docker engine + cri-dockerd （k8s已经和docker分离了）

架构：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202304141323184.png" alt="202304141323184" width="450px">

## 基本概念和术语

### pod

至少有一个根容器“Pause容器”，此外，还每个Pod还包含了一个或多个紧密相关的用户业务容
器。

