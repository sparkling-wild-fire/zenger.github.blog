# github相关知识

## ssh_key

git从github上传拉取资源，一般有两种方式：https协议(每次上传代码都需要tocken验证)和ssh协议(配置ssh-key后直接上传)

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303242300728.png" alt="202303242300728" width="450px">

### ssh生成过程

ssh-key生成以及加解密大致过程：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303242255466.png" alt="202303242255466" width="450px">

###

ssh两种验证方式：
1. 客户端输入密码，并用公钥加密，发送到服务器，服务器用私钥解密，验证密码进行登录。vscode的remote-ssh插件就是这种类似这种形式。
2. 客户端向服务器发送请求，携带公钥，服务器从ssh配置文件种比对公钥是相同的话，生成一个随机数，发送给客户端，客户端通过私钥加密，然后发送给服务器，如果服务器通过公钥解密后，得到的数字一样，即验证成功。git上传代码到github就是这种方式，具体流程如图：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/202303252203342.png" alt="202303252203342" width="450px">

使用ssh-key,会在c盘的用户目录下生成一个ssh文件夹，其各文件的作用：

| 文件名称             | 	文件功能                      |
|------------------|----------------------------|
| known_hosts	     | 记录ssh访问过计算机的公钥(public key) |
| id_rsa	          | 生成的私钥                      |
| id_rsa.pub       | 	生成的公钥                     |
| authorized_keys	 | 存放授权过的无密登录服务器公钥            |

具体参考该链接：[参考链接](https://www.cnblogs.com/fengfengyang/p/15519311.html)       

### 与tocken的区别：

注意网上经常说通过ssh-key实现免密登录，这种说法是比较容易把人带偏
，ssh-key通过公私钥加密数据，如果服务器能收到并解密客户端的数据，服务器只能知道客户端是合法的，本身不能识别客户端的身份（如果你传了密码那另说了）

对比tocken，一个tocken只能被一个客户端（用户）使用，因而具备用户识别功能
；而一个ssh-key可以被多个客户端（用户）使用

### 非对称加密的使用场景：
- 远程连接服务器：如vscode的remote-ssh插件
- github的ssh clon方式：ssh-key一般用于单向请求，因为只有公钥加密数据能用私钥解，而私钥加密的数据公钥无法解
- TSL加密SSL对称密钥：在tcp三次握手后，服务器和客户端会协商对称加密算法，以对数据进行加密传输（非对称加密算法太复杂了，加解密时间太多，不适合交互场景），而在此之前，为防止对称加密密钥伪造，客户端会将对称密钥通过公钥进行加密，发送给服务器，服务器用私钥解密后，拿到对称密钥，继而进行数据的加密传输。那客户端的公钥和服务端的私钥又是怎么来的呢，这就牵涉到数字证书了，这里不讲那么深

### github中ssh-key的应用

[git通过ssh-key拉取远程服务器代码](https://www.zhihu.com/question/63484557/answer/2921314116)

[github https和ssh拉取代码的区别](https://www.bbsmax.com/A/RnJW9NQRdq/)

【使用区别】
1. clone项目：

- 使用ssh方式时，需要配置ssh key，即要将生成的SSH密钥对的公钥上传至服务器；

- 使用http方式时，没有要求，可以直接克隆下来。

2. push项目：

- 使用ssh方式时，不需要验证用户名和密码，之前配置过ssh key，(如果你没设置密码)直接push即可；

- 使用http方式时，需要验证用户名和密码。

总结：

- HTTPS利于匿名访问，适合开源项目，可以方便被别人克隆和读取,需开放端口443和80
- SSH不利于匿名访问，比较适合内部项目，只要配置了SSH公钥可自由实现clone和push操作，需开放端口22
