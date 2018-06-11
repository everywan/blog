# VIM/GDB 学习
> http://man.chinaunix.net/newsoft/vi/doc/help.html

<!-- TOC -->

- [VIM/GDB 学习](#vimgdb-学习)
    - [VIM](#vim)
        - [常用](#常用)
        - [ALL](#all)
    - [GDB](#gdb)

<!-- /TOC -->

## VIM
### 常用
cmd |用途 
|:--:|:--:|
`ZZ`    |保存退出
`ZQ`    |不保存退出
`y`     |复制
`p`     |粘贴
`u`     |撤销 (缓冲区内操作)
`U`     |恢复当前行, 撤销当前行的所有修改
`.`     |重复上一命令
`gg`    |移动到开头
`G`     |移动到结尾
`ggdG`  |删除全部

### ALL
1. 替换 `:%s/str1/str2/g`:全文内,将str1替换为str2
1. 区块选择 `ctrl+v` , 然后 大写`I` 插入, `x/d` 删除
2. 退出
    - `:wq` 保存退出, w表示写入, 不论是否修改, 都会更改时间戳
    - `:x`  保存退出, 如果内容未改, 不会更改时间戳
    - `:q!` 不保存退出
3. 保存时获得sudo权限
    ````
    :w !sudo tee %
    <!-- 命令:w !{cmd}，让 vim 执行一个外部命令{cmd}，然后把当前缓冲区的内容从 stdin 传入。
    tee 是一个把 stdin 保存到文件的小工具。
    %，是vim当中一个只读寄存器的名字，总保存着当前编辑文件的文件路径。
    所以执行这个命令，就相当于从vim外部修改了当前编辑的文件 -->
    ````

## GDB
> 需要在使用 gcc/g++ 时, 加 `-g` 选项, 生成的执行文件才可以调试  
> gcc/g++ 不直接执行 C/C++ 程序, 而是生成可执行文件以供运行和调试

- start: 开始
- finish：结束
- s：step, 逐步跳入
- n：next
- p var：print var, 打印变量值
- help/help arg：帮助文档
