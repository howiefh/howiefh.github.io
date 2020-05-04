title: Git 内幕
date: 2016-05-16 20:51:10
tags: Git
categories: Git
description: Git 原理；Git 内幕；Git 对象；
---
## 基础
### 对待数据的方式
几乎所有版本控制工具都是记录与初始文件的差异，而 Git 是记录快照，每次提交更新时，就是当前工作目录下的所有文件的完整数据，而不是差异，当然如果提交时，文件没有被修改，不再重新存储该文件，而是指向上次存储的文件。

假设提交了5次，对于工作目录的文件A，在第三和第五次提交时有修改
```
# 其他版本控制
A (v1) --------------> △1 (v3) ---------------> △2 (v5)
# Git
A (v1) ---> A (v2) ---> A1 (v3) ---> A1 (v4) ---> A2 (v5)
```

<!-- more -->
### 完整性
Git 中所有数据在存储前都计算校验和，然后以校验和来引用。Git 用以计算校验和的机制叫做 SHA-1 散列（hash，哈希）。 这是一个由 40 个十六进制字符组成字符串，基于 Git 中文件的内容或目录结构计算出来。Git 数据库中保存的信息都是以文件内容的哈希值来索引，而不是文件名。

### 三种状态&三棵树
Git 有三种状态：已提交（committed）、已修改（modified）和已暂存（staged）。 已提交表示数据已经安全的保存在本地数据库中。已修改表示修改了文件，但还没保存到数据库中，又可以分为未暂存已修改和未提交已修改。已暂存表示对一个已修改文件的当前版本做了标记，使之包含在下次提交的快照中。

查看精简的状态
```
$ git status -s
MM README.md
```
结果前面的标记表示状态。

* `??` 新添加的未跟踪文件前面有`??`标记
* A 新添加到暂存区中的文件前面有A标记
* M 修改过的文件前面有M标记，出现在右边表示未暂存已修改、出现在左边表示已暂存但是未提交已修改。

由此引入 Git 的三棵树的概念：HEAD、索引（index）以及工作目录。

先说一下两个重要的目录，工作目录和仓库目录。工作目录是你运行`git init`的目录，是对项目的某个版本独立提取出来的内容。Git 仓库目录（`.git`，通常这是个隐藏文件夹）是 Git 用来保存项目的元数据和对象数据库的地方。 这是 Git 中最重要的部分，从其它计算机克隆仓库时，拷贝的就是这里的数据。

HEAD 和 index 对应着仓库目录下的两个文件，`.git/HEAD`和`.git/index`。

HEAD 是当前分支引用的指针，它总是指向该分支上的最后一次提交。可以将它看做**你的上一次提交**的快照。想看HEAD快照的实际目录列表可以通过命令`git ls-tree -r HEAD`

索引（index，暂存区域）是一个文件，保存了下次将提交的文件列表信息。可以将它看做**预期的下一次提交**。`git ls-files -s`命令可以查看索引的目录列表。

HEAD和index这两棵树高效但不直观，工作目录就相当直观了，可以把工作目录当做**沙盒**。在你将修改提交到暂存区并记录到历史之前，可以随意更改。

基本的 Git 工作流程如下：

1. 在工作目录中修改文件。
2. 暂存文件，**将文件的快照放入暂存区域**。（对应`git add`命令，生成blob对象，添加索引）
3. 提交更新，找到暂存区域的文件，将快照永久性存储到 Git 仓库目录。（对应`git commit`命令，生成树对象、提交对象）

![三棵树](https://cdn.jsdelivr.net/gh/howiefh/assets/img/git-tree.jpg)

* 图中左侧为工作区，右侧为版本库。在版本库中标记为index的区域是暂存区（stage，亦称index），标记为master的是master分支所代表的目录树。
* 图中可以看出此时HEAD实际是指向master分支的一个“游标”。所以图示的命令中出现HEAD的地方可以用master来替换。
* 图中的objects标识的区域为Git的对象库，实际位于`.git/objects`目录下。
* 当对工作区修改（或新增）的文件执行`git add`命令时，暂存区的目录树被更新，同时工作区修改（或新增）的文件内容被写入到对象库中的一个新的对象中，而该对象的ID被记录在暂存区的文件索引中。
* 当执行提交操作（`git commit`）时，暂存区的目录树写到版本库（对象库）中，master分支会做相应的更新。即master最新指向的目录树就是提交时原暂存区的目录树。
* 当执行`git reset HEAD`命令时，暂存区的目录树会被重写，被master分支指向的目录树所替换，但是工作区不受影响。
* 当执行`git rm --cached <file>`命令时，会直接从暂存区删除文件，工作区则不做出改变。
* 当执行`git checkout .`或者`git checkout -- <file>`命令时，会用暂存区全部或指定的文件替换工作区的文件。这个操作很危险，会清除工作区中未添加到暂存区的改动。
* 当执行`git checkout HEAD .`或者`git checkout HEAD <file>`命令时，会用HEAD指向的master分支中的全部或者部分文件替换暂存区和以及工作区中的文件。这个命令也是极具危险性的，因为不但会清除工作区中未提交的改动，也会清除暂存区中未提交的改动。

## 分支合并
假设你在分支hotfix上进行了紧急修复，并进行了提交，这时master分支和hotfix分别指向C2和C3。你需要切换回master分支，将修改的内容合并回master分支，执行`git merge hotfix`。在合并的时候，你会发现"快进（fast-forward）"这个词。由于当前 master 分支所指向的提交是你当前提交（hotfix 的提交）的直接上游，所以 Git 只是简单的将指针向前移动。合并两个分支时，如果顺着一个分支走下去能够到达另一个分支，那么 Git 在合并两者的时候，只会简单的将指针向前推进（指针右移），这种情况下不需要解决分歧。
```
               +--------+  +--------+
               | master |  | hotfix |
               +--------+  +--------+
                    |         |
                    v         v
+----+   +----+   +----+   +----+
| C0 |<--+ C1 |<--+ C2 |<--+ C4 |
+----+   +----+   +----+   +----+
                     ^
                     |     +----+
                     +-----+ c3 |
                           +----+
                              ^
                          +---+---+
                          | iss53 |
                          +-------+
```
你还有一个分支iss53在解决 issue#53 的问题。做完hotfix后，iss53上的工作也完成了，并且有了一次新的提交（C5），你需要将这个分支也合并到master上，和之前合并hotfix不同，现在你的iss53和master已经出现分叉了。出现这种情况的时候，Git 会使用两个分支的末端所指的快照（C4 和 C5）以及这两个分支的工作祖先（C2），做一个简单的三方合并。Git 将此次三方合并的结果做了一个新的快照并且自动创建一个新的提交指向它。 这个被称作一次合并提交，它的特别之处在于他有不止一个父提交。
```
                                        +--------+
                                        | master |
                                        +----+---+
                                             |
                                             v
+----+   +----+   +----+   +----+         +--+-+
| C0 |<--+ C1 |<--+ C2 |<--+ C4 |<--------+ C6 |
+----+   +----+   +--+-+   +----+         +--+-+
                     ^                       |
                     |     +----+   +----+   |
                     +-----+ C3 |<--+ C5 |<--+
                           +----+   +--+-+
                                       ^
                                   +---+---+
                                   | iss53 |
                                   +-------+
```
如果你对 #53 问题的修改和有关 hotfix 的修改都涉及到同一个文件的同一处，在合并它们的时候就会产生合并冲突。此时 Git 做了合并，但是没有自动地创建一个新的合并提交。 Git 会暂停下来，等待你去解决冲突。 在合并冲突后的任意时刻可以使用 git status 命令来查看那些因包含合并冲突而处于未合并（unmerged）状态的文件。

可以通过`git mergetool`使用图形化工具解决冲突，也可以直接对冲突文件进行修改，解决冲突。

在你解决了所有文件里的冲突之后，对每个文件使用 `git add` 命令来将其标记为冲突已解决。如果所有冲突已经解决，就可以提交这次合并了。

### 合并策略

Git 有很多合并策略，可以在合并时候指定合并策略，不指定的话，Git也会使用它认为合适的策略完成合并。

```
git merge [-s <strategy>] [-X <strategy-option>] <commit>...
```
其中参数-s用于设定合并策略，参数-X用于为所选的合并策略提供附加的参数。

Git的合并策略：
* resolve
    该合并策略只能用于合并两个头（即当前分支和另外的一个分支），使用三向合并策略。这个合并策略被认为是最安全、最快的合并策略。
* recursive
    该合并策略只能用于合并两个头（即当前分支和另外的一个分支），使用三向合并策略。这个合并策略是合并两个头指针时的默认合并策略。
    当合并的头指针拥有一个以上的祖先的时候，会针对多个公共祖先创建一个合并的树，并以此作为三向合并的参照。这个合并策略被认为可以实现冲突的最小化，而且可以发现和处理由于重命名导致的合并冲突。
    这个合并策略可以使用下列选项。
    * ours
        在遇到冲突的时候，选择我们的版本（当前分支的版本），而忽略他人的版本。如果他人的改动和本地改动不冲突，会将他人改动合并进来。
        不要将此模式和后面介绍的单纯的ours合并策略相混淆。后面介绍的ours合并策略直接丢弃其他分支的变更，无论冲突与否。
    * theirs
        和ours选项相反，遇到冲突时选择他人的版本，丢弃我们的版本。
    * subtree[=path]
        这个选项使用子树合并策略，比下面介绍的subtree（子树合并）策略的定制能力更强。下面的subtree合并策略要对两个树的目录移动进行猜测，而recursive合并策略可以通过此参数直接对子树目录进行设置。
* octopus
    可以合并两个以上的头指针，但是拒绝执行需要手动解决的复杂合并。主要的用途是将多个主题分支合并到一起。这个合并策略是对三个及三个以上头指针进行合并时的默认合并策略。
* ours
    可以合并任意数量的头指针，但是合并的结果总是使用当前分支的内容，丢弃其他分支的内容。
* subtree
    这是一个经过调整的recursive策略。当合并树A和B时，如果B和A的一个子树相同，B首先进行调整以匹配A的树的结构，以免两棵树在同一级别进行合并。同时也针对两棵树的共同祖先进行调整。

## 变基
除了使用`git merge`合并分支，还有其它方法：可以提取在 C4 中引入的补丁和修改，然后在 C5 的基础上再应用一次。 在 Git 中，这种操作就叫做变基。 你可以使用 `rebase` 命令将提交到某一分支上的所有修改都移至另一分支上，就好像“重新播放”一样。

```
git checkout iss53
git rebase master  # 以master为基（master原有的提交不会变），重做iss53的提交
```
变基原理是首先找到这两个分支（即当前分支 iss53、变基操作的目标基底分支 master）的最近共同祖先 C2，然后对比当前分支相对于该祖先的历次提交，提取相应的修改并存为临时文件，然后将当前分支指向目标基底 C4, 最后以此将之前另存为临时文件的修改依序应用，应用完后当前分支（iss53）也就指向了最后一个提交（C5'）。
```
                        +--------+
                        | master |
                        +----+---+
                             |
                             v
+----+   +----+   +----+   +----+   +----+   +----+
| C0 |<--+ C1 |<--+ C2 |<--+ C4 |<--+ C3'|<--+ C5'|
+----+   +----+   +--+-+   +----+   +----+   +--+-+
                     ^                          ^
                     |     +----+   +----+      |
                     +-----+ C3 |<--+ C5 |  +---+---+
                           +----+   +--+-+  | iss53 |
                                            +-------+
```
注意上图的线性分支上并不是 `C3'<--C4<--C5'`（假设以数字大小表示提交时间的先后，数字小提交时间更早）。rebase把iss53的基础定为master（C4），将iss53的修改（C3，C5）重做一遍，提交记录不再按时间排序了，而且提交的哈希值已经变了。看上去像是直接将iss53的修改拼接到master后面了，但是我觉得最好不要这样理解，拼接和重做还是有区别的，重做后C3'，C5'哈希值已经变了（作者、提交说明这些没变）。

现在回到 master 分支，进行一次快进合并。

```
git checkout master
git merge iss53
```
此时C5'指向的对象就和`merge`指向的快照一样了。

使用 `git rebase [basebranch] [topicbranch]` 命令可以直接将特性分支（即本例中的 iss53）变基到目标分支（即 master）上。
```
git rebase master iss53
# 然后再执行
git checkout master
git merge iss53
```

为什么不是直接在master分支上`git rebase iss53`？我的理解是这条命令是以iss53为基，重做master上的提交（C2之后的提交）。效果上和上面的操作结果是一样的，master分支最后包含了iss53上的更改，而且只用了一条命令。执行这条命令后会是这样：`C0 <-- C1 <-- C2 <-- C3 <-- C5(iss53) <-- C4'(master)`，而远程master应该还是这样`C0 <-- C1 <-- C2 <-- C4`。本地分支和远程分支在C2后分叉了，你不得不再去解决这个问题。而且这样会改变master分支上之前的提交，`C4'`已经不是`C4`了，尽管内容没太大区别。

`--onto`选项，取出（checkout） b 分支，找出处于 b 分支和 a 分支的共同祖先之后的修改（在b分支上而不在a分支上的修改），然后把它们在 master 分支上重演一遍。
```
git rebase --onto master a b
```

**变基有风险，不要对在你的仓库外有副本的分支执行变基（不要对推送至远程仓库的提交执行变基）。**只要你把变基命令当作是在推送前清理提交使之整洁的工具，并且只在从未推送至共用仓库的提交上执行变基命令，你就不会有事。 假如你在那些已经被推送至共用仓库的提交上执行变基命令，并因此丢弃了一些别人的开发所基于的提交，那你就有大麻烦了，你的同事也会因此鄙视你。

git rebase 与git merge 区别：

1. 历史记录不同： rebase是简洁的，历史记录是线性的，但commit不是按照日期排序，重做后的提交的哈希值也改变了。merge之后历史记录是非线性的看着比较复杂，但是commit按日期排序，每个提交还是原来的提交。
2. merge会多一次提交，merge 后还需要再提交一次，rebase不需要。

## 内部原理
从根本上来讲 Git 是一个内容寻址（content-addressable）文件系统，并在此之上提供了一个版本控制系统的用户界面。Git 提供了底层命令和高层命令，我们平时使用的checkout、branch、remote都是高层命令，底层命令我们平时可能接触不到，这些命令被设计成能以 UNIX 命令行的风格连接在一起，抑或藉由脚本调用，来完成工作。底层命令可以帮助我们了解Git是怎么工作的。

先看一下`git init`命令后`.git`目录的内容。

```
$ ls -F1
HEAD
config*
description
hooks/
info/
objects/
refs/
```

config 文件包含项目特有的配置选项。 info 目录包含一个全局性排除（global exclude）文件，用以放置那些不希望被记录在 .gitignore 文件中的忽略模式（ignored patterns）。 hooks 目录包含客户端或服务端的钩子脚本（hook scripts）。

剩下的四个条目很重要：HEAD 文件、（尚待创建的）index 文件，和 objects 目录、refs 目录。 这些条目是 Git 的核心组成部分。 objects 目录存储所有数据内容；refs 目录存储指向数据（分支）的提交对象的指针；HEAD 文件指示目前被检出的分支；index 文件保存暂存区信息。 我们将详细地逐一检视这四部分，以期理解 Git 是如何运转的。

### Git 对象
Git 是一个内容寻址文件系统。意味着 Git 的核心部分是一个简单的键值对数据库（key-value data store）。通过实践体会一下，执行下面任一条命令
```
echo 'test content' | git hash-object -w --stdin # -w表示存储数据对象，--stdin表示从终端读数据
git hash-object -w test.txt                      # 保存test.txt的数据
```

会返回一个哈希码`d670460b4b4aece5915caf5c68d12f560a9fe3e4`，这个就是键，看一下是怎么存储，打开`.git/objects/`会发现`d6`目录，然后目录里面有文件`70460b4b4aece5915caf5c68d12f560a9fe3e4`， 校验和的前两个字符用于命名子目录，余下的 38 个字符则用作文件名。有了键，怎么取值呢，用`git cat-file -p <key>`，执行`git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4`就会输出之前的数据内容。`-p` 选项可指示该命令自动判断内容的类型，并为我们显示格式友好的内容。

Git 中的对象的格式大致是这样的`<对象类型><空格><内容的字节数><\0><内容>`，看一下commit、tree、blob、tag（附注标签）这四种对象（blob对象对应一个文件，tree对象对应一个目录）的内容吧，Git中的对象文件是通过zlib压缩的，所以要看内容你还得解压。

看一下数据对象`d670460b4b4aece5915caf5c68d12f560a9fe3e4`对应文件的内容，对象类型是blob，然后一个空格，然后是长度13，后面一个字节的值是0，"test content"是12个字节，还有最后一个字节值是`10`也就是`\n`换行符，加起来就是13个字节了，注意blob下面应该还有一个空行
```
blob 13\0test content\n
```
如果你对上面的内容用SHA1加密，得到的结果就是`d670460b4b4aece5915caf5c68d12f560a9fe3e4`

提交对象`253e0582cd4b955b53cbcc2011197e028c31518b`的内容如下，commit对象内容包含了tree对象`a2310bc7e99afc10f781b87fa87bfe6b6447a4ec`、作者、提交者、提交信息
```
commit 170\0tree a2310bc7e99afc10f781b87fa87bfe6b6447a4ec
author Feng Hao <howiefh@gmail.com> 1462757839 +0800
committer Feng Hao <howiefh@gmail.com> 1462757839 +0800

add index.htm\n
```

tree对象`a2310bc7e99afc10f781b87fa87bfe6b6447a4ec`内容如下
```
tree 37\0100644 index.htm\0S??B?I/x?wy?a???
```
100644是文件模式，然后是文件名，然后又是一个`\0`字节，后面的乱码是什么呢？是index.htm对应的blob对象哈希值，是直接以二进制存的，而不是转成十六进制的字符串，所以看着是一堆乱码，看一下下面的字节数组，从83开始就是这个哈希值`53a7f2429549142f78b7777904b26102858d9716`。可以使用`git ls-tree -r <object>`查看树对象的内容。
```
[116, 114, 101, 101, 32, 51, 55, 0, 49, 48, 48, 54, 52, 52, 32, 105, 110, 100, 101, 120, 46, 104, 116, 109, 0, 83, -89, -14, 66, -107, 73, 20, 47, 120, -73, 119, 121, 4, -78, 97, 2, -123, -115, -105, 22]
```
再看下`53a7f2429549142f78b7777904b26102858d9716`的内容
```
blob 45\0<html>
<head>
</head>
<body>
</body>
</html>\n
```

附注标签对象`2232ed02d3a75f2027c5a31728c36a4d32c20b25`（`.git/refs/tags`这里可以找到对应tag文件，文件内容就是对应tag的哈希值）内容如下
```
tag 138\0object 253e0582cd4b955b53cbcc2011197e028c31518b
type commit
tag 0.0.1
tagger Feng Hao <howiefh@gmail.com> 1462847525 +0800

version 0.0.1\n
```
可以看到tag对象内容包含了上面commit对象的引用`253e0582cd4b955b53cbcc2011197e028c31518b`

总结一下，一个commit对象包含了一条tree对象（工作目录的根目录）记录，一个tree对象包含一条或多条树对象或blob对象记录。一个数据对象对应一个文件，包含了文件内容。

下面通过底层命令进行一次提交
```
# 新建一个文件
mkdir src
vim src/index.htm
# 添加到暂存区 git add src/index.htm
git update-index --add src/index.htm
# 记录下目录树（将当前暂存区的状态记录为一个树对象）
git write-tree
# 创建一次提交 d71a1bbe2730a62e875a7e242584a48d8681b0cd是上一步返回的哈希码
echo 'first commit' | git commit-tree d71a1bbe2730a62e875a7e242584a48d8681b0cd
# 验证 8f97c86c8f07bfdae3a628ed8bf33829d7cf71dd 上一步返回的哈希码
git log --stat 8f97c86c8f07bfdae3a628ed8bf33829d7cf71dd
```

下面是此时对象的关系，正如前文提到的，对于一次提交只有改变了的文件或目录才需要重新生成对象，`blob e738`就是之前生成的对象，其它对则是这次更新后新生成的。
```
        +------------+
        |commit  8f97|
        +------------+
             ./
              |
         +----v-----+
      +--+ tree d71a+--+
index.htm+----------+  src
      |                |
 +----v----+      +----v----+
 |blob e738|      |tree a231|
 +---------+      +---------+
                    index.htm
                       |
                  +----v----+
                  |blob 53a7|
                  +---------+
```

### 引用
Git 中的引用位于`.git/refs`中，分支引用位于`.git/refs/heads`中，远程分支引用位于`.git/refs/remotes`中，标签引用位于`.git/refs/tags`。对于前两者是可变的，分支引用是一个指向某一系列提交之首的指针或引用，每有提交就会向前推进。远程分支引用和分支引用最大区别是它是只读的，它在向远程服务器推送或拉去分支时才会变化。虽然可以 git checkout 到某个远程引用，但是 Git 并不会将 HEAD 引用指向该远程引用。因此，你永远不能通过 commit 命令来更新远程引用。 Git 将这些远程引用作为记录远程服务器上各分支最后已知位置状态的书签来管理。标签引用是固定的引用，它的内容不会随着你提交而变化，附注标签和轻量标签区别在于，附注标签引用指向了标签对象，而轻量标签引用指向的是提交对象（创建轻量引用并不会创建标签对象）

通过`git update-ref`更新分支引用、轻量标签引用
```
git update-ref refs/heads/master 8f97c86c8f07bfdae3a628ed8bf33829d7cf71dd
git update-ref refs/tags/v1.0 8f97c86c8f07bfdae3a628ed8bf33829d7cf71dd
```

还有一个引用就是 HEAD 引用，位于`.git/HEAD`。HEAD 文件是一个符号引用（symbolic reference），指向目前所在的分支。 所谓符号引用，意味着它并不像普通引用那样包含一个 SHA-1 值——它是一个指向其他引用的指针。 下面是 HEAD 文件的内容

```
$ cat .git/HEAD
ref: refs/heads/master
```
通过`git symbolic-ref`可以查看或者更新HEAD引用的值
```
git symbolic-ref HEAD
git symbolic-ref HEAD refs/heads/test
```
当运行类似于 `git branch (branchname)` 这样的命令时，Git 实际上会运行 update-ref 命令，取得当前所在分支最新提交对应的 SHA-1 值，并将其加入你想要创建的任何新引用中。Git 就是通过HEAD文件知道当前所在分支最新提交的 SHA-1 值的。

### 包文件
正如前面说的，Git 是记录快照，数据对象中保存着完整的文件内容，这样如果有文件比较大，比如十几KB，那么对文件做一次很小的更改，在Git就会保存两个十几KB的数据对象，这有点浪费空间，Git 最初向磁盘中存储对象时所使用的格式被称为“松散（loose）”对象格式。其实 Git 会时不时地将多个这些对象打包成一个称为“包文件（packfile）”的二进制文件，以节省空间和提高效率。当版本库中有太多的松散对象，或者执行 `git gc` 命令，或者你向远程服务器执行推送时，Git 都会这样做。要看到打包过程，可以执行 `git gc` 命令
```
git gc
```
你会发现`.git/objects`目录下的数据对象都消失了（未被引用的对象除外）。然后还多了两个pack文件。git verify-pack 这个底层命令可以让你查看已打包的内容：
```
git verify-pack -v .git/objects/pack/pack-978e03944f5c581011e6998cd0e9e30000905586.idx
```
可以观察下输出中一行有两个哈希码的行，Git已经帮你进行差量保存。比如下面 033b4 这个数据对象引用了数据对象 b042a，即文件的第二个版本。 命令输出内容的第三列显示的是各个对象在包文件中的大小，可以看到 b042a 占用了 22K 空间，而 033b4 仅占用 9 字节。
```
b042a60ef7dff760008df33cee372b945b6e884e blob   22054 5799 1463
033b4468fa6b2a9547a70d88d1bbe8bf3f9ed0d5 blob   9 20 7262 1 b042a60ef7dff760008df33cee372b945b6e884e
```

`git gc`也把引用给打包了，`.git/refs`现在也空了，多了一个文件`.git/packed-refs`。如果你更新了引用，Git 并不会修改这个文件，而是向 `.git/refs/` 创建一个新的文件。如果Git在`.git/refs`目录下找不到引用，就会到`.git/packed-refs`中查找。

### 引用规格（refspec）
```
git remote add origin https://github.com/schacon/simplegit-progit
```
上述命令会在 `.git/config` 文件中添加一个小节，并在其中指定远程版本库的名称（origin）、URL 和一个用于获取操作的引用规格（refspec）：

```
[remote "origin"]
    url = https://github.com/schacon/simplegit-progit
    fetch = +refs/heads/*:refs/remotes/origin/*
```
引用规格的格式由一个可选的 `+` 号和紧随其后的 `<src>:<dst>` 组成，其中 `<src>` 是一个模式（pattern），代表远程版本库中的引用；`<dst>` 是那些远程引用在本地所对应的位置。`+` 号告诉 Git 即使在不能快进的情况下也要（强制）更新引用。
```
         X---Y---Z  远程服务器上的分支master
        /
o---o---o---A---B  本地远程分支引用origin/dev
```

`git fetch origin +refs/heads/master:refs/remotes/origin/dev`将使`origin/dev`指向Z，不加`+`的话你会得到这样的信息`! [rejected]        master     -> origin/dev  (non-fast-forward)`。

默认情况下，引用规格由 `git remote add` 命令自动生成， Git 获取服务器中 `refs/heads/` 下面的所有引用，并将它写入到本地的 `refs/remotes/origin/` 中。

下面三条命令实际是一样的，Git 会把它们都扩展成 refs/remotes/origin/master
```
git log origin/master
git log remotes/origin/master
git log refs/remotes/origin/master
```

如果想让 Git 每次只拉取远程的 master 分支，而不是所有分支，可以把（引用规格的）获取那一行修改为：

```
fetch = +refs/heads/master:refs/remotes/origin/master
```
你也可以指定多个引用规格。 在命令行中，你可以按照如下的方式拉取多个分支：

```
git fetch origin master:refs/remotes/origin/mymaster topic:refs/remotes/origin/topic
```

不能在模式中使用部分通配符，下面是不合法的：
```
fetch = +refs/heads/qa*:refs/remotes/origin/qa*
```
但可以使用命名空间（或目录）来达到类似目的。
```
fetch = +refs/heads/qa/*:refs/remotes/origin/qa/*
```

QA 团队想把 `master` 分支推送到远程服务器的 `qa/master` 分支上，可以运行：
```
git push origin master:refs/heads/qa/master
```
如果他们希望 Git 每次运行 `git push origin` 时都像上面这样推送，可以在配置文件中添加一条 push 值：

```
[remote "origin"]
    url = https://github.com/schacon/simplegit-progit
    fetch = +refs/heads/*:refs/remotes/origin/*
    push = refs/heads/master:refs/heads/qa/master
```
对于push 的引用规格的格式中的 `<src>` 应该代表本地版本库中的引用；`<dst>` 是那些远程版本库中的引用。

当你把`<src>`留空时，意味着将远程版本定义为空，也就是删除它，可以达到远程分支的效果。
```
git push origin :topic
```

`git push`的行为：如果不加`<remote>`，也不指定引用规格，这个命令等效于`git push <remote>`，`<remote>`的值由`.git/config`中的`branch.<branchname>.remote`指定，如果没有指定，默认推送至`origin`远程仓库。

`git push <remote>`的行为：如果为注册的远程版本库设置了push参数，即通过`remote.<remote>.push`配置了引用规格，则执行`git push <remote>`时使用该引用规格执行推送。否则根据`push.default`配置的策略执行。

`git push`的策略

* nothing 什么都不干除非指定了引用规格。
* current 把当前的分支push到远程的同名分支。本地分支和远程分支不需要有追踪关系。
* upstream/tracking 当本地分支有upstream（即本地分支和远程分支要有追踪关系）时push到对应的远程分支。当执行`git push`时按照追踪关系推送，追踪关系可以在`.git/config`中配置`branch.<branchname>.remote`和`branch.<branchname>.merge`。通过`git branch -vv`就可以看到追踪关系。一般推荐这种策略。
* simple 和upstream一样, 但不允许将本地分支提交到远程不一样名字的分支，例如你的本地分支是`refs/heads/foo`而你通过`git branch --set-upstream-to=origin/bar`指定了远程追踪分支`refs/heads/bar`，在执行`git push`就会提示错误了。Git 2.0后的默认策略
* matching 本地所有的分支都推送到远程同名分支上去，如果没有对应同名的远程分支，Git什么也不会做。Git 2.0前的默认的策略。

通过下面命令可以配置策略
```
git config --global push.default simple
```

`git push origin :`，`:`该表达式的含义是同名分支推送，即对所有在远程版本库有同名分支的本地分支执行推送。参考matching策略。

`git push origin foo`，Git 自动将 foo 分支名字展开为 `refs/heads/foo:refs/heads/foo`。`git push origin foo:foo`也会做同样的事。所以你在`bar`分支时，想推送`foo`分支，当你指定了引用规格时，不用担心会错将`bar`推送。

要推送的远程版本库的URL地址由`remote.<remote>.pushurl`指定。如果没有配置，则使用`remote.<remote>.url`配置的URL地址。

对于Git 2.0之后的版本，`git push`默认策略为simple，所以一般在第一次推送时候指定`-u`参数，建立追踪关系，之后你就可以不用再加这个参数了，甚至可以直接执行`git push`。

### 数据恢复
当删除分支却发现分支还有用时，当你硬重置了一个分支，却想找回丢失的提交时。可以使用`git reglog`工具尝试恢复丢失的提交。你正在工作时，Git 会默默地记录每一次你改变 HEAD 时它的值。 每一次你提交或改变分支，引用日志都会被更新。 引用日志（reflog）也可以通过 git update-ref 命令更新。

`git reset --hard HEAD~2`将会使最新的两次提交丢失，执行`git reflog`
```
$ git reflog
3b75ed9 HEAD@{0}: reset: moving to HEAD~2
df55ffe HEAD@{1}: commit: add foot.html
19eb010 HEAD@{2}: commit: add head.html
3b75ed9 HEAD@{3}: commit (initial): add index.html
```
这时可以通过执行`git branch recover-branch df55ffe`让一个分支指向提交`df55ffe`

为了使显示的信息更加有用，我们可以执行 git log -g，这个命令会以标准日志的格式输出引用日志。

另一个命令是`git fsck`，它会检查数据库的完整性， 如果使用一个 --full 选项运行它，它会向你显示出所有没有被其他对象指向的对象。还需要一个`--no-reflogs`选项，这样可以忽略reflog引用的对象。

```
$ git fsck --full --no-reflogs
Checking object directories: 100% (256/256), done.
dangling commit df55ffedca681c04e700463f023e3c96f93f274f
```
`dangling`后的就是你需要的那次提交。如果你的reflog不幸被删了，这个命令就能派上用场了。

### 移除对象
有时，一个文件已经从工作目录中删除了，并且很确定不再需要这个文件，但是这个文件还是存在于版本库中，所以每次clone的时候都还是会clone这个文件。有办法可以从版本库删除数据对象，然后重写那之后的每次提交。

从`git count-objects -v`输出的内容可以看到版本库数据的大小。size-pack就是包文件的大小，如果执行了 `git gc` 可以通过`git verify-pack -v .git/objects/pack/pack-29…69.idx | sort -k 3 -n | tail -3`找到最大的三个对象，然后通过`git rev-list --objects --all | grep <SHA-1>`可以找到和`git verify-pack`命令找到的哈希值相关联的文件名，通过`git log --oneline --branches -- <file>`可以找到和文件相关的提交。然后重写历史`git filter-branch --index-filter 'git rm --ignore-unmatch --cached git.tgz' -- 7b30847^..`，`7b30847`是上一步找到的最早的提交记录的哈希。你的历史中将不再包含对那个文件的引用。 不过，你的引用日志和你在 `.git/refs/original` 通过 filter-branch 选项添加的新引用中还存有对这个文件的引用，所以你必须移除它们然后重新打包数据库。此时大文件还是以松散对象的形式存在，不过不会再克隆时出现了，通过`git prune --expire now`可以彻底的删除它。

参考：
* [Pro Git](http://git-scm.com/book/zh/v2)
* [Git权威指南](http://www.worldhello.net/gotgit/)
