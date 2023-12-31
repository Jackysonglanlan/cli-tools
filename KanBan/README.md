# Scrum Sprint

个人工作 Sprint Board。

## 使用方式

```console
$ ./build.sh add_task 任务描述 # 会自动在 board.md 中的 "Tasks" 段下添加一条记录，并自动在 TODO 文件夹生成对应的 task 目录
```

## general idea

我想要一个极简的 sprint board 系统，来追踪每天要做的事情，尽量使用已经有的东西，而不是过多的开发功能。

最重要的一点，**我不想启动一个服务来做这件事，最好像 `static site` 一样，可以离线工作，不需要维护任何事情**

## 总体设计

### 基于文件夹的 board 表达系统

标准的 TODO/DOING/DONE 3 阶段都有对应的同名文件夹，浏览这个文件夹，就可以知道对应阶段的任务信息。

每个文件夹都包含 _用任务 id (task id) 命名的子文件夹，存放和该 task 有关的文件_。

### task id

_task id_ 是一个 **Unix timestamp**，代表创建任务的时间，这种设计有如下好处:

1. 这个值精确到秒，对于这个 KanBan 系统来说，可以有效解决 id 撞车问题
2. 这是通用标准，如果要做进一步的事情，有扩展空间
3. stateless: 不用维护一个全局累加状态
4. 同时记录了 "任务是什么时候创建的"

通过 terminal 可以很容易获得这个值，以及如何解码为人类可读的时间:

```bash
$ date +'%s' # unix timestamp
$ date -r $timestamp # 把 timestamp 解码为人类可读的时间
```

### 示例 (注意这里为了方便演示，id 取的数字并非 `unix timestamp`)

```bash
- LONGTERM # 长期事项: 没有 due date，暂时空闲时做的事情，id 手工维护

  - 10 # task 10 是长期事务，这里存放该任务执行过程中产生的各种文件

- IMPULSION # 冲动类事情: 比如突然扔过来一堆文件，大概说了一下要做什么事情，或说先看看，熟悉情况。事件特点是需求描述模糊，前置条件也不满足，未达到可以落地做的程度

  - xxx # xxx 代表自己对这个事情的概括，因为没有形成 task, 所以不用 id

- TODO

  - 1,2 # 代表 task 1 和 2 还未开始(处于准备阶段)，准备的资料在这个文件夹中

- DOING

  - 5 # 正在进行 task 5，进行过程中产出的资料在这个文件夹

- DONE

  - 3 # task 3 已经完成，工作成果在这个文件夹

- ARCHIVE # 任务中可能涉及某些资料需要归档，放入这里

  - 7 # task 7 已经完成，完成过程中需要归档的资料在这里
```
