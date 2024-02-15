# 缓存

Redis也是一块共享内存，UFT不会产生数据不一致的问题吗？（比如说没有落库完成）


## 主动更新策略

uft的作用不是缓存，只是加快数据操作，因为缓存的查询逻辑是：缓存查询失败的时候，会查数据库；
而uft是要么查uft（常用的表，而有一些表可以通过异步线程自动落库，有一些表需要双写），要么查数据库

自动落库：
- 自动落库的好处：数据量大的表，可以将数据库的多次写入操作，缩减为一次写入操作
- 缺点：开发难度高，一致性不能保证（在落库的过程中宕机）

所以，双写+自动落库可以结合使用

#### 操作缓存和数据库

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151056808.png" alt="202402151056808" width="850px">

线程安全问题：先操作缓存再操作数据库，以及先操作数据库，再操作缓存，都是是线程不安全的

但一个是在写数据库时发生不一致性，一个是在写缓存时发生不一致性，后面一种的可能性较低

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151104101.png" alt="202402151104101" width="850px">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151105342.png" alt="202402151105342" width="850px">


## 缓存问题

1. 缓存穿透：请求数据在数据库和缓存中不存在

解决方案：
- 缓存空对象，对于不存在的数据也在redis建立缓存，值为null，并设置一个时间较短的TTL
- 布隆过滤器：在查询redis之前，首先判断数据存不存在redis中

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151635585.png" alt="202402151635585" width="850px">

2. 缓存雪崩：大量或全部key同时失效

解决方案：
- TTL设置随机值，防止所有key在同一时间过期
- 搭建主从集群
- 给缓存业务添加降级限流策略：当redis宕机时，进行请求限流
- 多级缓存：浏览器、nigix设置多个缓存

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151643573.png" alt="202402151643573" width="850px">

3. 缓存击穿：部分热点key失效

解决方案：
- 互斥锁：先加锁，查询数据库后，更新缓存，再释放锁； 高并发下，有很多线程会卡住，获取不了锁
- 逻辑过期：在redis的热点key中存入一个逻辑的过期时间（不是redis自带的TTL），线程1查询缓存过期后，先获取锁，新开一个线程2去当查询redis，操作数据库更新缓存数据，然后直接返回旧数据，
  其他线程查询缓存发现过期后，去获取互斥锁，如果获取互斥锁失败，则直接返回旧数据

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151649373.png" alt="202402151649373" width="850px">

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202402151659995.png" alt="202402151659995" width="850px">