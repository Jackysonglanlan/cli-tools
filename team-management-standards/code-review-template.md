# 重庆气象局项目 - 历史遗留代码的问题汇总

## 代码规范度(由于我们没有规范，所有只能采用业界通用规范来评估)

### 检查标准

- 命名是否规范
- 注释的质量
- 代码行数是否太多
- 是否有复制粘贴代码的情况

### 问题案例

由于项目从一开始就没有规范，所以项目代码呈现各种风格，除了类名遵守了一定的约定，其余都很随意，一看就知道是不同的人写的。

后续建议以 [《阿里巴巴Java开发手册》](https://github.com/alibaba/p3c) 为参照，配合 maven 规范检查插件 PMD，利用 gitlab pipeline 推行代码规范化工作，具体实施方法见 [这里](https://www.rectcircle.cn/posts/java-code-style-check-implement/#p3c-%E4%BB%A3%E7%A0%81%E6%A3%80%E6%9F%A5)。

## 代码质量

### 检查标准

- `if`/`else`/`switch` 嵌套是否太深(超过 3 层)
- 类/接口 是否有职责范围，以及职责范围是否合理(比如如果采用 MVC，是否 MVC 3 类组件边界混乱，M 的事情实际是 C 在做的情况)
- 耦合度(比如上帝对象)
- 扩展性
- 有没有利用 OOP 特性而不是传统的面向过程思维来编写代码
  - 比如使用多态自动绑定实现，而不是使用 `if` 改变代码执行路径
- 异常处理是否全面
- 资源(文件、socket 句柄等)是否有泄露
  - 比如在异常情况下导致资源未释放
- 数据结构的使用是否高效
  - 比如使用 `skip list` 做范围查找而不是自己想的野路子
  - 比如数据量很大时使用 `radix tree` 做整数映射而不是 `Map<Interger, ?>`
- 有没有编程策略的运用，比如 时间换空间/空间换时间、`lazy loading`、`fail fast` 等
- 对流行框架的使用是否专业
  - 比如代码是否符合 spring 最佳实践

### 问题案例

| 对应代码位置                                                              | 问题描述                                                                                                             |
| ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `ts-dataq` `GlobalStatisticsServiceImpl.modelSubitem()`                   | if 套 for 套 if 套 for 套 if .... 且没有注释说明                                                                     |
| `ts-dataq` `GlobalStatisticsServiceImpl.modelSubitem()`                   | if 套 for 套 if 套 for 套 if .... 且没有注释说明                                                                     |
| `ts-common-queue` `AbstractConsumer.java`                                 | spring 注入到类的 private 属性，不符合最佳实践                                                                       |
| `ts-modules-conc` `DataSourceTask.java`                                   | spring 专用的 `@Component` 标注和 java 平台标准的 `@Resource` 标注混用，不符合最佳实践                               |
| `ts-modules-conc` `DataStoreClient.java`                                  | 一个类承担了所有责任，责任并未继续下分，属于 "上帝对象"，耦合严重，且缺乏注释，不利于维护和扩展                      |
| `ts-modules-conc` `DataStoreClient.java`                                  | 多处出现 if 嵌套太深，且缺乏必要注释，维护困难，且容易引入 bug                                                       |
| `ts-modules-conc` `DataStoreClient.readClientConfig()`                    | 相同逻辑的代码重复过多，有复制/粘贴嫌疑，不利于维护                                                                  |
| `ts-modules-conc` `DatasoruceCommandRunner.run()`                         | 相同逻辑的代码重复过多，有复制/粘贴嫌疑，不利于维护                                                                  |
| `ts-modules-conc` `FtpBufferZoneConsumer.java`                            | 一个类承担了所有责任，责任并未继续下分，属于 "上帝对象"，耦合严重，不利于维护和扩展                                  |
| `ts-modules-conc` `ConcLocalFileServiceImpl.java`                         | 一个类承担了所有责任，责任并未继续下分，属于 "上帝对象"，耦合严重，不利于维护和扩展                                  |
| `ts-modules-conc` `ConcSyncOtherConfigServiceImpl.java`                   | 一个类承担了所有责任，责任并未继续下分，属于 "上帝对象"，耦合严重，不利于维护和扩展                                  |
| `ts-modules-conc` `DataAccessServiceImpl.java`                            | 一个类承担了所有责任，责任并未继续下分，属于 "上帝对象"，耦合严重，不利于维护和扩展                                  |
| `ts-modules-conc` `ConcTableMetadataServiceImpl.tableList()`              | 相同逻辑的代码重复过多，有复制/粘贴嫌疑，不利于维护                                                                  |
| `ts-modules-conc` `OperatorTableServiceImpl.java`                         | 类的职责混乱，`service` 类应该和数据如何交互的具体实现无关，但其中却出现了 `AjaxResult` 这种明显属于数据交互范围的类 |
| `ts-modules-conc` `OperatorTableServiceImpl.save()`                       | if 套 for 套 for 套 if 套 switch                                                                                     |
| `ts-modules-conc` `SftpHelper.java` 和 `StandardFtpHelper.java`           | 两个类绝大部分的代码都一样，是复制粘贴后再修改，不利于维护                                                           |
| `ts-modules-service` `InterfaceResourceServiceImpl.java`                  | 一个类承担了所有责任，责任并未继续下分，属于 "上帝对象"，耦合严重，不利于维护和扩展                                  |
| `ts-modules-service` `ServiceHandler.java` 和 `DataResourcePushTask.java` | 两个类绝大部分的代码都一样，是复制粘贴后再修改，不利于维护                                                           |
| `ts-modules-storage` `StorageResourceApprovalController.add()`            | if 套 for 套 for 套 if 套 if                                                                                         |
| `ts-modules-storage` `StorageResourceInfoController.upd()`                | 条件嵌套太多，不利于维护                                                                                             |
| `ts-modules-storage` `DateTimeUtil.dateDiff()`                            | 用 `Date` 计算时间间隔，非常容易出错，而且还不准，java 早就已经不建议使用 `Date`，应该用 `LocalTime` 类              |

## 代码运行时效率

### 检查标准

- cpu 的使用效率
  - 比如是否频繁创建/销毁大对象，是否创建了过多的线程
- 内存的使用效率
  - 比如在合适的场景使用 `LRU` 替代普通 `HashMap` 做缓存
- 网络/磁盘 IO 是否过多
  - 比如在循环中一条条提交 `sql` 而不使用事务一次性提交
  - 比如在循环中打开关闭文件
- 是否有同步阻塞调用
  - 比如 `main` 线程以阻塞方式请求外部的 `restful` 接口

### 问题案例

| 对应代码位置                                                  | 问题描述                                                                                                                                    |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| 所有用到 `feign` 的代码库                                     | `feign` 接口全部声明为同步调用(的返回值直接是 domain 对象)，容易造成调用方阻塞，影响性能                                                    |
| `ts-modules-govern` `OssServiceImpl.downloadOssByFileNames()` | 在 `for` 循环中用同步阻塞方式，串行下载文件，非常影响性能(容易导致请求方超时)，而且会出现因为一个文件下载失败，导致后续文件都无法下载的情况 |

## 中间件、外部服务的使用效率

### 检查标准(包括但不限于)

- 程序对 redis/kafka/各种 DB 等服务的使用上是否高效
- sql 是否有慢查询(比如 `using where` / `using filesort` / `using temporary` 等情况)

### 问题案例

#### 1. 对 redis 的使用太粗糙，比较随意，导致 redis 内存浪费严重

场景: 我们使用 sub/pub 监听 list，以作为 mq 使用

我们把程序使用的原始 json 直接放入 list 作为其元素，导致出现大量冗余的 json key。

这些 json key 的内容完全一样，很多地方重复出现(比如 list 中每个元素都有相同的 json key)，冗余严重。而由于这些 json key 很长(某些 key 有 30 个字符)，导致占用大量 redis 内存。

## 普遍性问题

某些问题具有普遍性，存在于多个代码库，因为数量太多，不单独列出，如下:

#### 1. 我们的库中有大量被注释的代码(甚至有全部都被注释的文件)，但并没有写出被注释的原因(比如是技术原因，还是因为业务变了导致代码不适用)，导致这些注释既没有被删除，也没有人敢改，给理解和维护代码带来干扰

#### 2. 我们的生产环境支持 Java 8，但是整个代码库倾向于用 Java 8 之前的老风格编写，Java 8 引入的很多新特性**几乎未被使用**(比如 `Stream`/`CompletableFuture`/`fork-join` 等)，导致出现大量冗余繁琐的代码，不仅代码量多，还容易引入 bug，维护起来也更困难

#### 3. `magic number` 问题，即硬编码的值。在我们的代码库中，很多地方都出现了直接写死的 `"0"` `"1"` `"17"` 等硬编码的值，不了解具体实现的新人根本看不懂是什么意思，导致维护困难

## 不算问题的特殊情况

"特殊情况的代码" 是那些因为需求变动太频繁，导致开发人员**被迫**写出的一些不符合常理的代码，谈不上错误，但这些代码会干扰正常的代码，增加维护难度。在需求清晰的正常开发流程中，这样的代码不应该出现。

### "僵尸代码"

有开发人员反应，已开发的功能中，很多都是为了应标或者给客户看，做了可能没有意义，也不是想要的，导致代码库中有很多 "僵尸代码": 没有执行，**但是又怕哪天要用，所以不敢删除**，放在那里和正常的代码混合，对有用的代码造成污染和干扰。

### "和注释绑定的代码"

因为需求频繁的修改，新老需求中某些地方又有重叠，所以开发人员在实现功能的时候，会根据需求变更，在一个完整的逻辑里面去注释掉某一部分的代码，达到 "快速变更代码" 的效果，这样就会形成 "某段代码被注释了一半，形成了一个功能，把注释去掉又会形成另一个功能"。

这就导致了整个实现逻辑非常混乱，而且不知道去掉哪些被注释的代码会形成一个新功能，导致几乎不可能让一个新人来维护。

### "半成品代码"

同样因为需求频繁改动的原因，开发人员只是定义了类/接口，而没有任何具体实现，相当于仅仅写了个框框。这样的类保留在代码库中，也不知道有用没用，什么时候用，放在那里和正常的代码混合，对有用的代码造成污染和干扰。

### 问题案例

| 对应代码位置                                                                   | 问题描述                                                                                                                                 |
| ------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `ts-dataq` 多个地方                                                            | 僵尸代码。需求变化太过剧烈: 从一开始的调用接口，到直接跳转。导致以前调用接口的代码变得无用，但是开发人员不敢删除，因为怕以后需求又变回来 |
| `ts-dataq` `DataSourceServiceImpl.addDataSource()`                             | 和注释绑定的代码                                                                                                                         |
| `ts-modules-conc` `DataCreateInstanceServiceImpl.createPostgreSQL()`           | 和注释绑定的代码                                                                                                                         |
| `ts-modules-conc` `ConcTableMetadataServiceImpl.tableList()`                   | 和注释绑定的代码                                                                                                                         |
| `ts-modules-conc` `com.ts.conc.mapper` 包下的很多 `Mapper` 接口                | 半成品代码                                                                                                                               |
| `ts-modules-conc` `com.ts.conc.service.impl` 包下的很多 `ServiceImpl` 类       | 半成品代码                                                                                                                               |
| `ts-modules-conc` `IConcDirectoryServiceImpl.obsCreateDirectory()`             | 和注释绑定的代码                                                                                                                         |
| `ts-modules-service` `com.ts.service.mapper` 包下的很多 `Mapper` 接口          | 半成品代码                                                                                                                               |
| `ts-modules-service` `com.ts.service.service.impl` 包下的很多 `ServiceImpl` 类 | 半成品代码                                                                                                                               |
| `ts-modules-storage` `com.ts.storage.controller` 包下的很多 `Controller` 类    | 半成品代码                                                                                                                               |
| `ts-modules-storage` `com.ts.storage.mapper` 包下的很多 `Mapper` 接口          | 半成品代码                                                                                                                               |
