# UFTso加载失败问题排查

UFTDB最近可能升级过，algo升级到最新版本报错：

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/79869dc89fd8bf36a0bed7cdb3b37b26.png" alt="79869dc89fd8bf36a0bed7cdb3b37b26" width="850">

，但这个so的路径和权限都正确:

<img src="https://cdn.jsdelivr.net/gh/sparkling-wild-fire/picgo@main/blogs/pictures/b16477f4ef3885c22066528b97000051.png" alt="b16477f4ef3885c22066528b97000051" width="850">

。原因是Oralce客户端版本太低，链接libclntsh.so.11.1的时候发生错误，Oracle从13年的升级到17年的就正常了。