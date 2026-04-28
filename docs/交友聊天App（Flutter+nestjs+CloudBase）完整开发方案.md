# 交友聊天App（Flutter+Express+CloudBase）完整开发方案

# 一、项目概述

## 1.1 项目定位

打造多场景轻量化交友聊天应用，精准匹配用户社交需求，覆盖休闲放松、深度共鸣、同好聚集三大核心场景，实现生产级高可用、低延迟、易部署的跨端交友App，支持Android、iOS双端原生体验，对接腾讯云CloudBase实现快速部署与运维。

- 休闲放松：内置「你画我猜」实时互动小游戏，实现多人实时画板同步与语音沟通

- 深度共鸣：慢社交文字/语音倾诉模式（对标Slowly/Tell），支持延迟消息、匿名交流

- 同好聚集：兴趣圈子+精准用户匹配（对标Dots/趣鸭），实现话题分享、同好互动

## 1.2 核心目标

- 生产级可用：支持高并发、低延迟、数据安全、服务稳定，适配IM实时消息与游戏同步场景

- 全功能覆盖：即时通讯、实时消息、用户匹配、兴趣圈子、实时小游戏、慢社交等核心功能

- 易部署运维：基于腾讯云CloudBase CloudRun实现后端一键部署，Flutter前端打包双端，无需复杂容器编排

- 跨端适配：Flutter开发，实现Android、iOS双端原生渲染，保证流畅交互体验

## 1.3 目标用户

核心用户为18-35岁年轻群体，涵盖有休闲社交、深度倾诉、兴趣交友需求，追求轻量化、无压力社交的用户，注重App流畅度与交互体验。

# 二、前端技术方案（Flutter 生产级）

## 2.1 核心技术栈（国内流行适配版·优化完整版）

|**技术类型**|**优化后选型**|**说明**|
|---|---|---|
|核心框架|Flutter 3.22+、Dart 3.0+|保持最新稳定版，适配国内双端机型，保障交互流畅度|
|状态管理|GetX|国内主流，一站式解决方案，兼顾状态管理、路由、依赖注入|
|路由管理|GetX 路由|无需额外依赖，与GetX状态管理无缝衔接，配置简单|
|UI组件|Material 3 + 自定义主题|国内主流做法，兼顾原生质感与个性化，适配国内用户审美|
|图标|iconfont（阿里）|国内主流图标库，资源丰富、免费可用，适配各类场景|
|即时通讯|腾讯IM SDK|国内成熟云服务，无需自建IM服务，稳定高效，适配社交场景|
|实时画板|自研 CustomPaint|仅需200行代码，完全可控，适配你画我猜实时同步场景|
|录音/播放|record + audioplayers|最新活跃库，适配国内机型，录音清晰、播放稳定|
|图片处理|wechat_assets_picker + image_cropper|微信风格交互，用户体验友好，支持图片选择、裁剪等核心需求|
|本地存储|Hive + flutter_secure_storage|分工明确，Hive存聊天记录，flutter_secure_storage存Token，安全高效|
|网络请求|Dio + retrofit|国内开发标配，请求封装便捷，支持鉴权、拦截，适配国内接口规范|
|消息推送|极光推送（个人）|按个人场景选择，触达率高，适配国内各大手机厂商|
|内测分发|蒲公英|国内团队常用内测工具，操作便捷，支持快速分发测试|
## 2.2 前端架构（生产级目录结构）

结合Flutter 3.22+、GetX、腾讯IM SDK等优化后技术栈，遵循生产级开发规范，目录结构分层清晰、职责明确，支持高可维护性、可扩展性，适配双端开发与后期迭代，具体如下：

```plain text
frontend/
├── lib/                      # 核心代码目录（Flutter项目核心）
│   ├── main.dart             # 入口文件，初始化GetX、腾讯IM SDK、全局配置
│   ├── core/                 # 核心配置与工具（全局复用）
│   │   ├── config/           # 全局配置（统一管理第三方服务参数）
│   │   │   ├── app_config.dart  # App基础配置（主题、端口、环境）
│   │   │   ├── im_config.dart   # 腾讯IM SDK配置（SDKAppID、密钥等）
│   │   │   ├── push_config.dart # 极光推送配置（AppKey等）
│   │   │   └── cloudbase_config.dart # CloudBase配置（环境ID等）
│   │   ├── utils/            # 工具类（全局复用）
│   │   │   ├── toast_util.dart   # 提示工具（适配双端）
│   │   │   ├── storage_util.dart # 本地存储工具（封装Hive、flutter_secure_storage）
│   │   │   ├── network_util.dart # 网络请求工具（封装Dio+retrofit）
│   │   │   ├── im_util.dart      # 腾讯IM工具（封装SDK初始化、消息处理）
│   │   │   └── common_util.dart  # 通用工具（日期、加密、格式转换等）
│   │   ├── constants/        # 常量定义（全局统一）
│   │   │   ├── app_constants.dart # App常量（路由、存储key等）
│   │   │   ├── style_constants.dart # 样式常量（颜色、字体、间距）
│   │   │   └── api_constants.dart # 接口常量（接口地址、请求类型）
│   │   └── providers/        # 全局状态管理（GetX，替代原Riverpod）
│   │       ├── user_provider.dart # 用户状态（登录、个人信息）
│   │       ├── im_provider.dart   # IM状态（消息、在线状态）
│   │       ├── game_provider.dart # 游戏状态（房间、积分）
│   │       └── circle_provider.dart # 圈子状态（帖子、关注）
│   ├── api/                  # 接口封装（对接后端+第三方服务）
│   │   ├── api_client.dart   # retrofit接口客户端初始化
│   │   ├── user_api.dart     # 用户相关接口（注册、登录、资料）
│   │   ├── im_api/           # 即时通讯接口（封装腾讯IM SDK相关）
│   │   │   ├── tencent_im_sdk.dart # 腾讯IM SDK核心封装
│   │   │   └── message_api.dart    # 消息相关接口（发送、接收、撤回）
│   │   ├── game_api.dart     # 你画我猜游戏接口
│   │   └── circle_api.dart   # 兴趣圈子接口（发帖、评论）
│   ├── pages/                # 页面目录（按功能模块划分）
│   │   ├── splash/           # 启动页（闪屏、初始化检查）
│   │   │   ├── splash_page.dart
│   │   │   └── splash_controller.dart # GetX控制器
│   │   ├── login/            # 登录注册页
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   └── login_controller.dart
│   │   ├── chat/             # 聊天相关页面（适配腾讯IM）
│   │   │   ├── chat_list_page.dart # 聊天列表页
│   │   │   ├── chat_detail_page.dart # 聊天详情页
│   │   │   ├── chat_controller.dart
│   │   │   └── widgets/      # 聊天页面子组件
│   │   ├── game/             # 你画我猜游戏页面
│   │   │   ├── game_room_list.dart # 房间列表页
│   │   │   ├── game_room_page.dart # 游戏房间页
│   │   │   ├── game_controller.dart
│   │   │   └── widgets/      # 游戏子组件（画板、倒计时）
│   │   ├── slow_chat/        # 慢社交页面
│   │   │   ├── slow_chat_list.dart # 慢消息列表
│   │   │   ├── write_letter_page.dart # 写信页
│   │   │   └── slow_chat_controller.dart
│   │   ├── circle/           # 兴趣圈子页面
│   │   │   ├── circle_list.dart # 圈子列表
│   │   │   ├── post_detail.dart # 帖子详情
│   │   │   ├── publish_post.dart # 发帖子
│   │   │   └── circle_controller.dart
│   │   └── mine/             # 我的页面（个人中心）
│   │       ├── mine_page.dart
│   │       ├── profile_edit.dart # 资料编辑
│   │       ├── setting_page.dart # 设置页
│   │       └── mine_controller.dart
│   ├── widgets/              # 通用组件（全局复用）
│   │   ├── common/           # 基础通用组件
│   │   │   ├── custom_app_bar.dart # 自定义导航栏
│   │   │   ├── empty_view.dart # 空状态视图
│   │   │   ├── loading_view.dart # 加载视图
│   │   │   └── custom_button.dart # 自定义按钮
│   │   ├── chat/             # 聊天相关组件（适配腾讯IM）
│   │   │   ├── message_item.dart # 消息item（文字/图片/语音）
│   │   │   ├── chat_input.dart # 聊天输入框（适配IM SDK）
│   │   │   └── unread_dot.dart # 未读消息红点
│   │   ├── game/             # 游戏相关组件
│   │   │   ├── drawing_board.dart # 自研CustomPaint画板
│   │   │   └── game_score.dart # 积分展示组件
│   │   └── circle/           # 圈子相关组件
│   │       ├── post_item.dart # 帖子item
│   │       ├── comment_item.dart # 评论item
│   │       └── tag_widget.dart # 标签组件
│   ├── routes/               # 路由配置（GetX路由）
│   │   └── app_routes.dart   # 路由定义、路由跳转工具
│   ├── theme/                # 主题配置
│   │   ├── app_theme.dart    # 全局主题（Material 3 + 自定义主题）
│   │   └── iconfont.dart     # 阿里iconfont图标引入
│   └── res/                  # 资源目录
│       ├── images/           # 图片资源（头像、背景、图标）
│       ├── sounds/           # 音频资源（提示音、背景音乐）
│       └── fonts/            # 字体资源
├── assets/                   # 静态资源（Flutter打包依赖）
│   ├── images/               # 图片资源（与lib/res/images对应）
│   └── fonts/                # 字体资源（与lib/res/fonts对应）
├── ios/                      # iOS工程目录（双端打包）
├── android/                  # Android工程目录（双端打包）
├── pubspec.yaml              # 依赖配置（Flutter插件、第三方库）
└── README.md                 # 项目说明文档（开发规范、部署步骤）
```

## 2.3 核心功能前端实现说明

### 2.3.1 即时通讯（IM）

- 集成腾讯IM SDK（Flutter版），完成初始化配置（传入SDKAppID、密钥），依托腾讯云服务实现稳定长连接，保障消息实时推送，无需自建IM服务

- 利用腾讯IM SDK内置消息队列机制，自动处理发送失败重试、弱网重发、离线消息缓存，无需手动开发，大幅提升消息可靠性

- 基于腾讯IM SDK原生能力，支持文字、图片、语音消息，一键实现已读回执、消息撤回、删除功能，自动维护前端消息状态（未读、已读、撤回），简化开发

- 聊天列表使用ListView.builder/SliverList实现懒加载，结合腾讯IM SDK分页拉取历史消息接口，避免卡顿，下拉加载更多历史消息，适配SDK消息分页逻辑

- 键盘高度适配，确保输入框不被键盘遮挡，结合腾讯IM SDK输入框组件（或自定义适配），优化聊天交互体验，同步适配SDK消息发送回调逻辑

### 2.3.2 你画我猜（实时游戏）

- 使用CustomPaint + Canvas绘制高性能画板，支持画笔粗细、颜色切换、橡皮擦、清空、撤销功能，保持原有交互体验不变

- 通过腾讯IM SDK自定义消息通道实现多人笔触实时同步，复用IM长连接，采用二进制压缩优化传输效率，避免卡顿，依托腾讯云网络优化提升同步速度

- 实现房间匹配、倒计时、积分统计、游戏状态管理，游戏内实时语音沟通直接对接腾讯IM SDK内置语音能力，替代WebRTC，简化集成，提升语音通话稳定性

- 适配不同手机分辨率，确保画板显示一致，优化多点触控体验，笔触同步数据通过腾讯IM自定义消息格式封装，保障跨机型兼容性

### 2.3.3 慢社交（Slowly/Tell风格）

- 设计信件风格UI，实现延迟消息发送、倒计时显示，模拟慢社交体验

- 支持匿名模式切换，隐藏个人信息，实现纯内容交流

- 添加信件未开封、已开封状态，配合动画效果，提升用户体验

- 支持信纸皮肤、邮票等个性化设置，丰富交互细节

### 2.3.4 兴趣圈子（Dots/趣鸭风格）

- 采用瀑布流布局展示圈子列表、帖子信息流，实现下拉刷新、上拉加载

- 支持发帖、点赞、评论、二级评论，实现关注/粉丝体系UI交互

- 实现话题标签筛选，方便用户快速找到同好内容

- 图片九宫格展示，支持图片预览、放大查看，优化多媒体展示体验

## 2.4 第三方账号注册与配置说明（适配前端技术栈）

结合前端优化后的核心技术栈，需注册并配置以下第三方服务账号，确保各功能正常运行，所有配置均适配国内开发场景、操作便捷且符合生产级要求，具体如下：

|**第三方服务**|**关联前端技术栈**|**注册要求**|**核心配置内容**|
|---|---|---|---|
|腾讯云CloudBase|CloudBase Flutter SDK、云数据库、云存储|注册腾讯云账号，完成实名认证，创建CloudBase环境（推荐广州/上海节点）|1. 记录环境ID（配置到前端全局config）；2. 开通云数据库（PostgreSQL）、云存储服务；3. 配置跨域规则，允许前端域名访问|
|腾讯IM|腾讯IM SDK（即时通讯核心）|腾讯云账号（同CloudBase账号），开通IM服务，创建IM应用|1. 获取SDKAppID、密钥（配置到前端IM接口封装）；2. 配置IM消息类型（文字、图片、语音）；3. 开启好友关系、群聊功能|
|阿里图标库（iconfont）|前端图标资源（iconfont）|注册阿里账号，创建个人/企业项目，收藏所需图标|1. 生成项目在线链接/下载图标文件；2. 配置到前端主题，全局引入使用；3. 按需调整图标颜色、大小|
|极光推送|极光推送（个人版，消息推送）|注册极光账号，创建应用（区分Android/iOS双端），完成个人实名认证|1. 获取AppKey、Master Secret（配置到前端推送工具）；2. 配置双端包名/ Bundle ID；3. 开启离线推送，适配国内手机厂商|
|蒲公英|内测分发（前端双端内测）|注册蒲公英账号，创建应用，绑定开发者信息|1. 配置应用名称、图标；2. 上传Android（APK/AAB）、iOS（IPA）安装包；3. 获取内测链接，用于团队测试|
补充说明：所有第三方服务均选用国内主流平台，注册配置流程简洁，无需复杂资质（个人版可满足开发需求），配置完成后需在前端`core/config`目录统一管理配置参数，确保后续维护便捷。

CloudBase 环境ID：dating-app-d2grdu112752d3ecd

腾讯IM 密钥：cc076985a47befd2726f22bb77b7ce0a9c7d1361212568478483bd856fd27227

腾讯IM SDKAppID：1600138422

## 2.5 性能优化与合规要求

### 2.5.1 性能优化（适配Flutter双端，保障流畅体验）

结合Flutter 3.22+特性与项目核心场景（IM、实时游戏、多图展示），针对性做性能优化，确保App启动速度、页面切换、交互响应达到生产级标准，适配中低端机型，具体优化措施如下：

- 启动优化：采用Flutter延迟初始化（lazy loading），将腾讯IM SDK、极光推送等第三方服务初始化放在首屏渲染完成后，减少启动阻塞；优化首屏资源加载，压缩启动页图片，移除首屏不必要的组件渲染，确保冷启动时间≤3秒、热启动时间≤1秒。

- UI渲染优化：列表（聊天列表、圈子信息流）统一使用ListView.builder/SliverList懒加载，避免一次性渲染所有列表项；自定义组件（画板、消息Item）重写didUpdateWidget、dispose方法，及时释放资源，避免内存泄漏；减少不必要的setState调用，依托GetX状态管理实现局部刷新，降低UI重绘频率。

- 资源优化：图片资源按分辨率分类（mdpi、hdpi、xhdpi等），使用WebP格式压缩（比PNG小30%-50%），通过cached_network_image实现图片缓存，避免重复请求；音频、图标资源统一压缩，iconfont按需引入，减少包体积；Flutter包体积优化，剔除无用资源、混淆代码，Android端包体积控制在15MB以内，iOS端控制在20MB以内。

- IM与游戏性能优化：腾讯IM SDK消息分页拉取，每次拉取20条历史消息，下拉加载更多，避免大量消息一次性渲染；画板笔触同步采用二进制压缩传输，减少数据量，依托腾讯IM长连接优化，降低笔触同步延迟≤100ms；游戏房间状态、用户在线状态通过本地缓存+定时同步，减少网络请求频次。

- 内存与功耗优化：及时释放无用对象（如关闭页面时销毁控制器、取消网络请求），避免内存溢出；录音、定位等功能使用时开启，不用时立即关闭，降低设备功耗；避免后台频繁唤醒，推送消息采用极光推送离线模式，减少后台耗电。

- 网络优化：基于Dio封装请求拦截器，实现请求重试、超时处理（默认30秒）、弱网提示；高频请求（如用户在线状态）做防抖、节流处理；利用CloudBase CDN加速静态资源（图片、音频）加载，降低网络延迟，适配国内不同网络环境（4G、5G、WiFi）。

### 2.5.2 合规要求（适配国内应用审核，规避上线风险）

严格遵循国内应用审核规范（工信部、应用商店、隐私保护相关法规），结合社交类App特性，落实以下合规要求，确保顺利上线Android、iOS主流应用商店：

- 隐私合规：用户首次启动App时，弹出隐私政策弹窗，明确告知用户数据收集范围（手机号、头像、兴趣标签等）、使用目的，用户同意后再进行数据收集；提供隐私政策详情页面，支持用户查看、撤回同意；不收集与App功能无关的用户数据，敏感数据（如手机号）加密存储（使用flutter_secure_storage），不泄露、不滥用。

- 权限合规：按需申请权限，不强制申请无关权限（如仅在录音、拍照时申请对应权限），权限申请前明确告知用户用途，提供权限关闭入口；核心权限（如存储、麦克风）未授权时，提供替代方案或友好提示，不影响App基础功能使用。

- 内容合规：内置内容审核机制，对用户发布的帖子、聊天消息、头像等内容进行基础过滤（敏感词、违规图片），对接腾讯云内容审核API，及时处理违规内容；提供用户举报功能，支持用户举报违规内容、违规用户，建立违规处理机制。

- 账号合规：支持手机号注册/登录，实现短信验证码验证，确保账号真实性；提供账号注销功能，注销后彻底删除用户相关数据（数据库、缓存），符合用户数据删除权益；不支持匿名注册，确保用户可追溯，规避恶意行为。

- 其他合规：适配国内应用商店审核要求，填写真实应用信息（名称、描述、分类），不虚假宣传；包含用户协议、隐私政策、联系方式等必备页面；Android端适配64位架构，iOS端适配最新系统版本，符合双端审核规范；不包含违规功能（如诱导分享、恶意广告）。

补充说明：合规相关页面（隐私政策、用户协议）需单独开发，嵌入个人中心设置页面，确保用户可随时查看；定期更新合规内容，适配最新法规要求，避免上线后因合规问题被下架。

## 2.6 打包与发布（生产级规范，适配Flutter双端）

结合前端Flutter技术栈及国内应用上线要求，规范打包流程、明确发布标准，兼顾内测分发与正式上线，确保双端适配、审核顺利，具体步骤与注意事项如下：

### 2.6.1 Android 打包（适配国内应用商店）

1. 签名配置：生成自有签名证书（.jks格式），记录密钥库密码、密钥密码、别名，妥善保存（用于后续版本更新，不可丢失）；在Flutter项目`android/app`目录下配置build.gradle文件，关联签名证书，确保签名一致。

2. 打包优化与生成：优先打包生成AAB格式（Android App Bundle，适配Google Play及国内主流应用商店，体积更小、分发更高效），备用APK格式（适配部分小众应用商店）；打包前进行应用加固（推荐腾讯云应用加固），防范篡改、反编译，提升App安全性。

3. 商店提交：提交至华为应用市场、小米应用商店、应用宝、OPPO应用商店、vivo应用商店等国内主流平台；提交时需准备完整材料（应用图标、截图、应用描述、隐私政策、开发者资质），确保符合各平台审核规范，重点适配64位架构要求。

4. 注意事项：同一应用的不同版本签名必须一致，否则无法覆盖更新；应用名称、图标、描述需与前端配置一致，避免虚假宣传；提交后及时关注审核进度，配合平台完成审核修改。

### 2.6.2 iOS 打包（适配App Store及内测）

1. 证书配置：注册Apple Developer账号（个人/企业版），创建p12开发者证书、推送证书，配置描述文件（区分开发环境、测试环境、生产环境），确保描述文件与Bundle ID、证书匹配，签名配置正确。

2. 打包与内测：通过Xcode打包生成IPA文件，优先通过TestFlight进行内测（邀请测试人员参与，收集反馈，优化Bug）；内测期间需确保测试设备已添加至描述文件，避免安装失败。

3. App Store提交：内测通过后，提交IPA文件至App Store Connect，填写应用信息（名称、描述、截图、隐私政策链接），选择发布模式（手动发布/自动发布）；配合Apple审核，及时响应审核意见（重点关注隐私合规、功能合规），审核通过后完成正式上线。

4. 注意事项：Bundle ID需与前端配置、极光推送配置一致；iOS版本需适配最新系统版本，避免兼容性问题；隐私政策需符合Apple隐私规范，明确数据收集与使用场景。

### 2.6.3 热更新（生产级迭代优化）

集成Flutter热更新插件（推荐flutter_downloader + flutter_webview_plugin，适配国内网络环境），实现无需重新下载App即可更新部分功能（如UI细节、非核心业务逻辑、Bug修复），提升迭代效率，减少用户流失。

- 热更新配置：在前端`core/config`目录配置热更新服务器地址，关联后端更新接口，实现更新包检测、下载、安装全流程自动化；设置更新提示逻辑，区分强制更新（核心Bug修复）与可选更新（优化类更新）。

- 注意事项：热更新内容不可涉及核心功能变更、权限变更，避免触发应用商店重新审核；更新包需进行加密处理，防范篡改；记录热更新日志，便于排查更新失败问题。

### 2.6.4 内测分发（衔接蒲公英工具）

结合前端技术栈中提到的蒲公英内测工具，实现双端快速内测分发，简化测试流程，具体操作如下：

- 上传安装包：将Android（APK/AAB）、iOS（IPA）安装包上传至蒲公英平台，配置应用名称、图标、测试说明，获取内测链接。

- 测试管理：邀请开发、测试人员通过内测链接安装App，收集测试反馈；支持测试版本管理，区分不同测试迭代版本，便于追溯问题。

- 注意事项：内测包需关闭生产环境接口，对接测试环境，避免测试数据污染；限制内测人数，符合蒲公英平台规则，避免违规。

# 三、后端技术方案（NestJS + CloudBase 国内最新流行适配版）

核心定位：**适配前端Flutter方案+国内开发场景**，选用2026年国内后端最新流行技术栈（NestJS为主），兼顾高并发、低延迟、易部署，无缝对接前端腾讯IM SDK、极光推送等组件，依托腾讯云生态简化运维，完全贴合交友App IM、实时游戏、慢社交、兴趣圈子四大核心场景，确保前后端协同高效、生产级可用。NestJS框架基于TypeScript，结构严谨、分层清晰，支持依赖注入、模块化开发，适配国内中大型项目生产级需求，同时兼容各类第三方插件，完美对接项目核心需求，相比Express更具可维护性和可扩展性。

## 3.1 核心技术栈（国内最新流行，适配前端需求）

|**技术类型**|**具体选型（国内最新流行）**|**用途说明（适配前端+国内场景）**|
|---|---|---|
|核心框架|Node.js 20+ + NestJS 10.3+|国内主流后端企业级框架，基于TypeScript开发，结构严谨、分层清晰，支持模块化、依赖注入，适配国内生产级项目开发规范；内置中间件、拦截器、管道等特性，无缝对接Socket.IO、Prisma，完美适配前端GetX状态管理的接口规范，兼顾开发效率与长期可维护性，相比Express更适合复杂业务场景的扩展。|
|实时通信|Socket.IO 4.7+ + @nestjs/platform-socket.io|最新稳定版，通过@nestjs/platform-socket.io无缝集成NestJS框架，实现长连接、消息推送、房间管理；无缝对接前端腾讯IM SDK自定义消息通道，支撑IM单聊/群聊、你画我猜笔触实时同步，适配国内网络环境，延迟低、稳定性高，同时依托NestJS模块化特性，便于实时业务逻辑的拆分与维护。|
|认证鉴权|JWT + @nestjs/jwt + @nestjs/passport + 腾讯云CAM|国内主流鉴权方案，@nestjs/jwt与@nestjs/passport简化NestJS鉴权逻辑，JWT生成安全Token；对接腾讯云CAM权限管理，结合前端flutter_secure_storage加密存储，确保接口安全、用户数据安全，适配NestJS守卫（Guard）机制，集成便捷且可扩展。|
|数据库|腾讯云CloudBase自带MySQL 8.0 + Prisma 5.10+|腾讯云CloudBase自带MySQL 8.0，属于国内生产级云数据库，深度集成CloudBase生态，支持自动扩容、低延迟，适配国内网络环境；MySQL 8.0兼容性强、社区成熟，支持高并发场景，适配交友App用户数据、IM消息等核心存储需求；Prisma 5.10+最新版，类型安全、操作简洁，通过NestJS模块封装后，无缝对接NestJS服务，降低开发成本，提升数据操作效率。|
|缓存|Upstash Redis + @nestjs/redis|国内主流Serverless Redis方案，无需自建缓存服务，通过@nestjs/redis模块无缝集成NestJS框架，可直接注入使用；核心用于缓存高频访问数据（用户在线状态、游戏房间信息、热门圈子帖子），减轻MySQL数据库压力，配合Socket.IO提升IM消息、游戏笔触同步的响应速度，延迟低至毫秒级，同时适配CloudBase部署环境，无需额外运维，完美贴合交友App高并发场景。|
|文件存储|CloudBase Storage + 腾讯云COS|CloudBase Storage适配轻量文件，腾讯云COS适配大文件（图片、语音），通过官方SDK封装为NestJS服务，无缝对接NestJS控制器，适配前端图片选择、录音功能，国内CDN加速，确保文件加载快速，适配双端体验，接口封装简洁，便于开发调用。|
|部署环境|腾讯云CloudBase CloudRun + Docker|国内主流无服务器部署方案，一键部署、自动容器化、弹性扩缩容；Docker封装NestJS项目依赖（含Node.js环境、TypeScript编译环境），确保开发、测试、生产环境一致，适配NestJS项目的模块化特性，无需复杂运维，部署效率高。|
|消息推送|TPNS 腾讯移动推送 SDK + 极光推送API|双推送方案，TPNS对接腾讯生态，极光推送适配国内所有手机厂商，通过官方SDK/API封装为NestJS服务，实现离线消息触达，确保前端消息不遗漏，适配NestJS服务注入机制，接口调用简洁，便于维护。|
|日志与监控|腾讯云监控 + ELK Stack（国内流行）+ @nestjs/logger|腾讯云监控实时监控服务状态，ELK Stack集中收集、分析日志，通过@nestjs/logger集成NestJS全局日志系统，便于排查异常；适配国内运维习惯，确保后端服务稳定，支撑前端高可用需求，同时日志可按模块拆分，便于定位业务问题。|
基于上述核心技术栈，后端将围绕前端四大核心场景（IM即时通讯、你画我猜实时游戏、慢社交、兴趣圈子），搭建NestJS模块化分层架构、设计合理的数据模型、封装高效接口，同时依托腾讯云CloudBase生态实现快速部署与运维，确保后端服务与前端Flutter应用无缝协同，为整个交友App提供稳定、高效、安全的后端支撑，后续将详细阐述后端架构设计、数据模型、核心接口及部署运维方案。

后端架构设计将严格遵循NestJS模块化、分层解耦、高内聚低耦合的生产级开发原则，结合Prisma的数据操作优势，同步适配前端GetX状态管理的接口调用规范，兼顾开发效率与后期可扩展性；数据模型将围绕用户、消息、游戏、圈子四大核心模块设计，通过Prisma ORM实现与MySQL 8.0数据库的高效联动，同时利用Upstash Redis缓存高频数据，进一步提升服务响应速度，全方位支撑前端各项功能的稳定运行。

## 3.1.1 NestJS生产级项目目录结构（适配CloudBase部署+前端需求）

遵循NestJS模块化开发规范，结合交友App四大核心业务场景，设计分层清晰、职责明确的生产级目录结构，支持高可维护性、可扩展性，适配CloudBase CloudRun部署、Docker容器化，无缝对接Prisma、Socket.IO等技术栈，具体结构如下（注释清晰，便于开发与后期迭代）：

```plain text
backend/
├── src/                      # 核心代码目录（NestJS项目核心）
│   ├── main.ts               # 入口文件，初始化NestJS应用、配置全局中间件、连接数据库与缓存
│   ├── app.module.ts         # 根模块，聚合所有业务模块、公共模块，配置全局依赖
│   ├── config/               # 全局配置模块（统一管理第三方服务参数、环境变量）
│   │   ├── config.module.ts  # 配置模块，注册所有配置服务
│   │   ├── config.service.ts # 配置服务，读取环境变量、第三方服务配置（CloudBase、IM等）
│   │   └── config.types.ts   # 配置类型定义（TypeScript类型约束）
│   ├── common/               # 公共模块（全局复用，无需重复开发）
│   │   ├── common.module.ts  # 公共模块，注册公共服务、拦截器、管道等
│   │   ├── interceptors/     # 全局拦截器（统一响应格式、异常处理、日志记录）
│   │   │   ├── response.interceptor.ts # 统一响应拦截器（适配前端Dio+retrofit）
│   │   │   ├── exception.interceptor.ts # 全局异常拦截器（统一错误返回）
│   │   │   └── logging.interceptor.ts # 日志拦截器（记录请求与响应日志）
│   │   ├── pipes/            # 全局管道（参数校验、数据转换）
│   │   │   ├── validation.pipe.ts # 参数校验管道（基于class-validator）
│   │   │   └── transform.pipe.ts # 数据转换管道（统一返回格式）
│   │   ├── guards/           # 全局守卫（鉴权、权限控制）
│   │   │   ├── jwt-auth.guard.ts # JWT鉴权守卫（保护需要登录的接口）
│   │   │   └── role.guard.ts # 角色守卫（可选，用于后期权限扩展）
│   │   ├── filters/          # 全局异常过滤器（捕获未处理异常）
│   │   │   └── http-exception.filter.ts # HTTP异常过滤器
│   │   ├── decorators/       # 自定义装饰器（全局复用）
│   │   │   ├── current-user.decorator.ts # 获取当前登录用户装饰器
│   │   │   └── public.decorator.ts # 公开接口装饰器（无需鉴权）
│   │   └── utils/            # 公共工具类（全局复用）
│   │       ├── encryption.util.ts # 加密工具（bcrypt加密、数据加密）
│   │       ├── redis.util.ts # Redis工具（封装缓存操作）
│   │       ├── cos.util.ts   # 腾讯云COS工具（文件上传/下载）
│   │       ├── push.util.ts  # 推送工具（极光/TPNS推送封装）
│   │       └── common.util.ts # 通用工具（日期、格式转换、敏感词过滤）
│   ├── prisma/               # Prisma数据库模块（适配MySQL 8.0）
│   │   ├── prisma.module.ts  # Prisma模块，注册Prisma客户端
│   │   ├── prisma.service.ts # Prisma服务，封装数据操作方法
│   │   └── schema.prisma     # 数据库schema配置（完整数据模型）
│   ├── modules/              # 业务模块（按核心场景划分，模块化开发）
│   │   ├── user/             # 用户管理模块（对应前端登录、个人中心）
│   │   │   ├── user.module.ts # 用户模块，聚合控制器、服务、实体
│   │   │   ├── user.controller.ts # 控制器，处理用户相关接口请求
│   │   │   ├── user.service.ts # 服务，实现用户相关业务逻辑
│   │   │   ├── user.entity.ts # 实体类（TypeScript类型约束，对应Prisma模型）
│   │   │   ├── dto/          # 数据传输对象（请求/响应参数校验）
│   │   │   │   ├── create-user.dto.ts # 注册用户请求参数
│   │   │   │   ├── login-user.dto.ts # 登录请求参数
│   │   │   │   └── update-user.dto.ts # 更新用户资料请求参数
│   │   │   └── interfaces/   # 接口定义（TypeScript类型约束）
│   │   │       └── user.interface.ts # 用户相关接口类型
│   │   ├── im/               # IM即时通讯模块（适配前端腾讯IM SDK）
│   │   │   ├── im.module.ts  # IM模块
│   │   │   ├── im.controller.ts # IM接口控制器
│   │   │   ├── im.service.ts # IM业务逻辑服务
│   │   │   ├── im.entity.ts # IM实体类
│   │   │   ├── dto/          # IM相关请求/响应DTO
│   │   │   └── interfaces/   # IM相关接口类型
│   │   ├── game/             # 你画我猜游戏模块（实时游戏场景）
│   │   │   ├── game.module.ts # 游戏模块
│   │   │   ├── game.controller.ts # 游戏接口控制器
│   │   │   ├── game.service.ts # 游戏业务逻辑服务
│   │   │   ├── game.entity.ts # 游戏实体类
│   │   │   ├── dto/          # 游戏相关请求/响应DTO
│   │   │   ├── interfaces/   # 游戏相关接口类型
│   │   │   └── socket/       # 游戏Socket.IO实时交互（单独拆分，便于维护）
│   │   │       ├── game.gateway.ts # 游戏Socket网关（处理实时笔触、房间通知）
│   │   │       └── game.socket.service.ts # 游戏Socket业务逻辑
│   │   ├── slow-chat/        # 慢社交模块（适配前端Slowly/Tell风格）
│   │   │   ├── slow-chat.module.ts # 慢社交模块
│   │   │   ├── slow-chat.controller.ts # 慢社交接口控制器
│   │   │   ├── slow-chat.service.ts # 慢社交业务逻辑服务
│   │   │   ├── slow-chat.entity.ts # 慢社交实体类
│   │   │   ├── dto/          # 慢社交相关请求/响应DTO
│   │   │   └── interfaces/   # 慢社交相关接口类型
│   │   ├── circle/           # 兴趣圈子模块（适配前端Dots/趣鸭风格）
│   │   │   ├── circle.module.ts # 圈子模块
│   │   │   ├── circle.controller.ts # 圈子接口控制器
│   │   │   ├── circle.service.ts # 圈子业务逻辑服务
│   │   │   ├── circle.entity.ts # 圈子实体类
│   │   │   ├── dto/          # 圈子相关请求/响应DTO
│   │   │   └── interfaces/   # 圈子相关接口类型
│   │   └── common/           # 公共业务模块（支撑全场景）
│   │       ├── common-business.module.ts # 公共业务模块
│   │       ├── common.controller.ts # 公共接口控制器（文件上传、Token刷新等）
│   │       ├── common.service.ts # 公共业务服务
│   │       ├── dto/          # 公共接口请求/响应DTO
│   │       └── interfaces/   # 公共业务接口类型
│   ├── socket/               # Socket.IO全局配置（统一管理实时交互）
│   │   ├── socket.module.ts  # Socket模块，注册所有Socket网关
│   │   └── socket.gateway.ts # 全局Socket网关（处理连接、断开等通用逻辑）
│   └── types/                # 全局类型定义（TypeScript，统一类型约束）
│       ├── global.types.ts   # 全局通用类型
│       └── response.types.ts # 统一响应类型（适配前端）
├── test/                     # 测试目录（生产级必备，确保代码可靠性）
│   ├── unit/                 # 单元测试（测试单个服务、工具类）
│   └── e2e/                  # 端到端测试（测试接口完整流程）
├── .env                      # 环境变量配置（开发、测试、生产环境区分）
├── .env.development          # 开发环境配置
├── .env.production           # 生产环境配置（CloudBase部署时使用）
├── .env.test                 # 测试环境配置
├── nest-cli.json             # NestJS CLI配置（项目编译、运行参数）
├── package.json              # 依赖配置（NestJS插件、第三方库）
├── tsconfig.json             # TypeScript配置（编译选项、类型约束）
├── tsconfig.build.json       # TypeScript构建配置
├── Dockerfile                # Docker配置（封装项目，适配CloudBase CloudRun部署）
├── docker-compose.yml        # Docker Compose配置（本地开发环境模拟）
└── README.md                 # 项目说明文档（开发规范、部署步骤、接口文档）
```

目录结构说明：该结构严格遵循NestJS模块化开发规范，按“根模块-公共模块-业务模块”分层，每个业务模块内部再按“控制器-服务-实体-DTO-接口”拆分，职责明确、低耦合；Socket.IO实时交互按业务场景拆分到对应模块，同时保留全局Socket配置，便于统一管理；Prisma模块单独封装，确保数据操作的一致性；全局配置、工具类、拦截器等公共资源集中管理，提升复用性；适配Docker容器化与CloudBase CloudRun部署，可直接打包部署，无需额外修改目录结构；TypeScript类型约束贯穿全项目，提升代码可靠性与可维护性，完美适配生产级开发需求。

核心定位：**适配前端Flutter方案+国内开发场景**，选用2026年国内后端最新流行技术栈（Express为主），兼顾高并发、低延迟、易部署，无缝对接前端腾讯IM SDK、极光推送等组件，依托腾讯云生态简化运维，完全贴合交友App IM、实时游戏、慢社交、兴趣圈子四大核心场景，确保前后端协同高效、生产级可用。Express框架轻量灵活、生态成熟，适配国内中小团队开发节奏，无需复杂配置即可快速上手，同时兼容各类第三方插件，完美对接项目核心需求。

## 3.1 核心技术栈（国内最新流行，适配前端需求）

|**技术类型**|**具体选型（国内最新流行）**|**用途说明（适配前端+国内场景）**|
|---|---|---|
|核心框架|Node.js 20+ + Express 4.18+|国内最主流后端轻量框架，生态完善、插件丰富，开发成本低、上手快，适配国内中小团队开发节奏；支持中间件灵活扩展，无缝对接Socket.IO、Prisma，完美对接前端GetX状态管理的接口规范，兼顾开发效率与生产级稳定性。|
|实时通信|Socket.IO 4.7+ + express-socket.io|最新稳定版，通过express-socket.io无缝集成Express框架，实现长连接、消息推送、房间管理；无缝对接前端腾讯IM SDK自定义消息通道，支撑IM单聊/群聊、你画我猜笔触实时同步，适配国内网络环境，延迟低、稳定性高。|
|认证鉴权|JWT + passport + 腾讯云CAM|国内主流鉴权方案，passport简化Express鉴权逻辑，JWT生成安全Token；对接腾讯云CAM权限管理，结合前端flutter_secure_storage加密存储，确保接口安全、用户数据安全，适配Express中间件架构，集成便捷。|
|数据库|腾讯云CloudBase自带MySQL 8.0 + Prisma 5.10+|腾讯云CloudBase自带MySQL 8.0，属于国内生产级云数据库，深度集成CloudBase生态，支持自动扩容、低延迟，适配国内网络环境；MySQL 8.0兼容性强、社区成熟，支持高并发场景，适配交友App用户数据、IM消息等核心存储需求；Prisma 5.10+最新版，类型安全、操作简洁，替代原生SDK，无缝对接Express，同时完美适配MySQL 8.0，降低开发成本，提升数据操作效率。|
|缓存|Upstash Redis + ioredis|国内主流Serverless Redis方案，无需自建缓存服务，通过ioredis插件无缝集成Express框架，可直接调用；核心用于缓存高频访问数据（用户在线状态、游戏房间信息、热门圈子帖子），减轻MySQL数据库压力，配合Socket.IO提升IM消息、游戏笔触同步的响应速度，延迟低至毫秒级，同时适配CloudBase部署环境，无需额外运维，完美贴合交友App高并发场景。|
|文件存储|CloudBase Storage + 腾讯云COS|CloudBase Storage适配轻量文件，腾讯云COS适配大文件（图片、语音），通过官方SDK无缝对接Express，适配前端图片选择、录音功能，国内CDN加速，确保文件加载快速，适配双端体验，接口封装简洁，便于开发调用。|
|部署环境|腾讯云CloudBase CloudRun + Docker|国内主流无服务器部署方案，一键部署、自动容器化、弹性扩缩容；Docker封装Express项目依赖，确保开发、测试、生产环境一致，适配Express项目轻量特性，无需复杂运维，部署效率高。|
|消息推送|TPNS 腾讯移动推送 SDK + 极光推送API|双推送方案，TPNS对接腾讯生态，极光推送适配国内所有手机厂商，通过官方SDK/API无缝集成Express，实现离线消息触达，确保前端消息不遗漏，接口调用简洁，适配Express路由架构。|
|日志与监控|腾讯云监控 + ELK Stack（国内流行）|腾讯云监控实时监控服务状态，ELK Stack集中收集、分析日志，通过express-winston插件快速集成Express，便于排查异常；适配国内运维习惯，确保后端服务稳定，支撑前端高可用需求。|
基于上述核心技术栈，后端将围绕前端四大核心场景（IM即时通讯、你画我猜实时游戏、慢社交、兴趣圈子），搭建分层架构、设计合理的数据模型、封装高效接口，同时依托腾讯云CloudBase生态实现快速部署与运维，确保后端服务与前端Flutter应用无缝协同，为整个交友App提供稳定、高效、安全的后端支撑，后续将详细阐述后端架构设计、数据模型、核心接口及部署运维方案。

后端架构设计将严格遵循分层解耦、高内聚低耦合的生产级开发原则，结合Express框架的轻量特性与Prisma的数据操作优势，同步适配前端GetX状态管理的接口调用规范，兼顾开发效率与后期可扩展性；数据模型将围绕用户、消息、游戏、圈子四大核心模块设计，通过Prisma ORM实现与MySQL 8.0数据库的高效联动，同时利用Upstash Redis缓存高频数据，进一步提升服务响应速度，全方位支撑前端各项功能的稳定运行。

## 3.2 核心数据模型（schema.prisma 完整配置）

基于Prisma 5.10+与MySQL 8.0，结合交友App四大核心场景（用户、IM消息、你画我猜游戏、兴趣圈子），设计完整数据模型，包含表关联、字段约束、索引优化，适配前端接口调用需求，同时兼容Upstash Redis缓存逻辑，确保数据操作高效、安全，以下是完整的schema.prisma配置文件：

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

// 配置腾讯云CloudBase自带MySQL 8.0数据库连接
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL") // 环境变量配置，部署时在CloudBase设置
  // 适配MySQL 8.0特性，开启严格模式，确保数据一致性
  relationMode = "prisma"
}

// 1. 用户核心表（User）- 存储用户基础信息，关联所有核心场景
model User {
  id              String    @id @default(uuid()) // 唯一用户ID，适配前端用户标识
  phone           String    @unique // 手机号，用户登录唯一凭证（合规要求）
  password        String    // 加密存储密码（bcrypt加密，配合前端flutter_secure_storage）
  nickname        String    // 用户昵称
  avatar          String?   // 头像URL（存储在腾讯云COS/CloudBase Storage）
  gender          String?   // 性别（male/female/other）
  age             Int?      // 年龄
  bio             String?   // 个人简介
  tags            String[]  // 兴趣标签（适配同好匹配、圈子筛选）
  isAnonymous     Boolean   @default(false) // 是否开启匿名模式（适配慢社交）
  onlineStatus    Boolean   @default(false) // 在线状态（缓存至Upstash Redis）
  gameScore       Int       @default(0) // 你画我猜游戏积分
  createdAt       DateTime  @default(now()) // 创建时间
  updatedAt       DateTime  @updatedAt // 更新时间
  deletedAt       DateTime? // 软删除时间（合规要求，支持账号注销后数据保留）

  // 关联关系
  slowChatsSent   SlowChat[] @relation("SenderSlowChat") // 发送的慢消息
  slowChatsReceived SlowChat[] @relation("ReceiverSlowChat") // 接收的慢消息
  circlePosts     CirclePost[] // 发布的圈子帖子
  circleComments  CircleComment[] // 发布的圈子评论
  gameRooms       GameRoomMember[] // 加入的游戏房间
  friendRelations FriendRelation[] @relation("UserFriend") // 好友关系
  imMessages      ImMessage[] // 发送的IM消息
}

// 2. 好友关系表（FriendRelation）- 适配IM好友功能
model FriendRelation {
  id              String   @id @default(uuid())
  userId          String   // 发起好友请求的用户ID
  friendId        String   // 接收好友请求的用户ID
  status          String   @default("pending") // 好友状态（pending/accepted/rejected）
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  // 关联用户表（双向关联）
  user            User     @relation("UserFriend", fields: [userId], references: [id], onDelete: Cascade)
  friend          User     @relation("UserFriend", fields: [friendId], references: [id], onDelete: Cascade)

  // 联合唯一索引，避免重复好友关系
  @@unique([userId, friendId])
}

// 3. IM消息表（ImMessage）- 适配腾讯IM SDK消息存储，同步前端消息状态
model ImMessage {
  id              String    @id @default(uuid())
  senderId        String    // 发送者ID（关联User表）
  receiverId      String    // 接收者ID（关联User表，单聊）
  groupId         String?   // 群聊ID（可选，适配群聊场景）
  messageType     String    // 消息类型（text/image/voice/custom）
  content         String    // 消息内容（文字消息直接存，图片/语音存URL，自定义消息存JSON）
  isRead          Boolean   @default(false) // 已读状态（适配前端已读回执）
  isRecalled      Boolean   @default(false) // 撤回状态（适配前端消息撤回）
  sendTime        DateTime  @default(now()) // 发送时间
  deletedAt       DateTime? // 软删除时间

  // 关联发送者
  sender          User      @relation(fields: [senderId], references: [id], onDelete: Cascade)

  // 索引优化，提升IM消息查询效率（高频场景）
  @@index([senderId, receiverId, sendTime])
  @@index([groupId, sendTime])
}

// 4. 慢社交消息表（SlowChat）- 适配慢社交场景，支持延迟发送
model SlowChat {
  id              String    @id @default(uuid())
  senderId        String    // 发送者ID
  receiverId      String    // 接收者ID
  content         String    // 消息内容（文字/语音URL）
  messageType     String    // 消息类型（text/voice）
  delayTime       Int       // 延迟时间（单位：分钟，适配慢社交延迟发送）
  sendTime        DateTime  @default(now()) // 发起发送时间
  actualSendTime  DateTime? // 实际发送时间（延迟结束后更新）
  isOpened        Boolean   @default(false) // 是否已开封（适配信件未开封状态）
  isAnonymous     Boolean   @default(false) // 是否匿名发送
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // 关联发送者和接收者
  sender          User      @relation("SenderSlowChat", fields: [senderId], references: [id], onDelete: Cascade)
  receiver        User      @relation("ReceiverSlowChat", fields: [receiverId], references: [id], onDelete: Cascade)

  // 索引优化，提升慢消息查询效率
  @@index([senderId, receiverId])
  @@index([receiverId, isOpened])
}

// 5. 你画我猜游戏房间表（GameRoom）- 管理游戏房间状态
model GameRoom {
  id              String    @id @default(uuid())
  roomName        String    // 房间名称
  roomCode        String    @unique // 房间编码（前端加入房间时使用）
  status          String    @default("waiting") // 房间状态（waiting/playing/ended）
  hostId          String    // 房主ID（关联User表）
  maxPlayers      Int       @default(4) // 最大玩家数
  currentPlayers  Int       @default(1) // 当前玩家数
  gameRound       Int       @default(1) // 当前回合数
  roundTime       Int       @default(60) // 每回合时间（单位：秒）
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  endedAt         DateTime? // 房间结束时间

  // 关联房主
  host            User      @relation(fields: [hostId], references: [id], onDelete: Cascade)
  // 关联房间内玩家
  members         GameRoomMember[]
  // 关联房间内游戏记录
  gameRecords     GameRecord[]

  // 索引优化，提升房间查询效率
  @@index([roomCode])
  @@index([status, currentPlayers])
}

// 6. 游戏房间成员表（GameRoomMember）- 关联房间与玩家
model GameRoomMember {
  id              String    @id @default(uuid())
  roomId          String    // 房间ID（关联GameRoom表）
  userId          String    // 玩家ID（关联User表）
  role            String    @default("player") // 角色（host/player）
  score           Int       @default(0) // 该房间内玩家积分
  joinTime        DateTime  @default(now()) // 加入房间时间

  // 关联房间和玩家
  room            GameRoom  @relation(fields: [roomId], references: [id], onDelete: Cascade)
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  // 联合唯一索引，避免同一玩家重复加入同一房间
  @@unique([roomId, userId])
}

// 7. 游戏记录/画板同步表（GameRecord）- 存储你画我猜游戏过程与笔触数据
model GameRecord {
  id              String    @id @default(uuid())
  roomId          String    // 房间ID
  round           Int       // 回合数
  drawerId        String    // 画画玩家ID（关联User表）
  word            String    // 本轮题目
  brushData       String    // 笔触数据（JSON格式，存储画板同步信息，二进制压缩后存储）
  isFinished      Boolean   @default(false) // 本轮是否结束
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // 关联房间和画画玩家
  room            GameRoom  @relation(fields: [roomId], references: [id], onDelete: Cascade)
  drawer          User      @relation(fields: [drawerId], references: [id], onDelete: Cascade)

  // 索引优化，提升游戏记录查询效率
  @@index([roomId, round])
}

// 8. 兴趣圈子表（Circle）- 管理兴趣圈子分类
model Circle {
  id              String    @id @default(uuid())
  name            String    @unique // 圈子名称（如“美食”“游戏”“旅行”）
  description     String?   // 圈子描述
  coverImage      String?   // 圈子封面图URL
  memberCount     Int       @default(0) // 圈子成员数
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // 关联圈子内帖子
  posts           CirclePost[]
}

// 9. 圈子帖子表（CirclePost）- 存储圈子内用户发布的内容
model CirclePost {
  id              String    @id @default(uuid())
  userId          String    // 发布者ID（关联User表）
  circleId        String    // 圈子ID（关联Circle表）
  content         String    // 帖子内容
  images          String[]? // 帖子图片URL数组（存储在腾讯云COS）
  likes           Int       @default(0) // 点赞数
  comments        Int       @default(0) // 评论数
  isTop           Boolean   @default(false) // 是否置顶
  isDeleted       Boolean   @default(false) // 是否删除（软删除）
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // 关联发布者和圈子
  user            User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  circle          Circle    @relation(fields: [circleId], references: [id], onDelete: Cascade)
  // 关联帖子评论
  commentsList    CircleComment[]

  // 索引优化，提升帖子查询效率（高频场景）
  @@index([userId, createdAt])
  @@index([circleId, createdAt])
  @@index([likes, createdAt])
}

// 10. 圈子评论表（CircleComment）- 存储帖子评论及二级评论
model CircleComment {
  id              String    @id @default(uuid())
  postId          String    // 帖子ID（关联CirclePost表）
  userId          String    // 评论者ID（关联User表）
  content         String    // 评论内容
  parentId        String?   // 父评论ID（二级评论时使用，关联自身）
  likes           Int       @default(0) // 评论点赞数
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // 关联帖子和评论者
  post            CirclePost @relation(fields: [postId], references: [id], onDelete: Cascade)
  user            User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  // 关联父评论（二级评论）
  parentComment   CircleComment? @relation("CommentReply", fields: [parentId], references: [id], onDelete: Cascade)
  // 关联子评论（二级评论）
  childComments   CircleComment[] @relation("CommentReply")

  // 索引优化，提升评论查询效率
  @@index([postId, createdAt])
  @@index([parentId, createdAt])
}

// 11. 系统配置表（SystemConfig）- 存储后端全局配置，适配前端参数
model SystemConfig {
  id              String    @id @default(uuid())
  configKey       String    @unique // 配置键（如“hotCircleIds”“gameWordList”）
  configValue     String    // 配置值（JSON格式存储）
  description     String?   // 配置描述
  updatedAt       DateTime  @updatedAt

  // 索引优化，提升配置查询效率
  @@index([configKey])
}

// 补充说明：
// 1. 所有关联关系均设置级联删除（onDelete: Cascade），确保数据一致性；
// 2. 高频查询字段（如消息发送时间、房间编码、帖子创建时间）均添加索引，提升查询效率；
// 3. 敏感数据（密码）将通过bcrypt加密存储，配合前端flutter_secure_storage实现双重安全；
// 4. 图片、语音等大文件存储在腾讯云COS/CloudBase Storage，数据库仅存储URL，降低数据库压力；
// 5. 适配Upstash Redis缓存逻辑，将用户在线状态、游戏房间信息、热门圈子帖子等高频数据缓存，提升响应速度；
// 6. 支持软删除（deletedAt/isDeleted字段），符合合规要求，便于账号注销后数据追溯与恢复。

```



schema.prisma配置说明：该文件完全适配前文后端技术栈（MySQL 8.0+Prisma 5.10+），覆盖交友App所有核心场景的数据存储需求，字段设计贴合前端接口调用规范，同时做了索引优化、数据安全、合规性处理，可直接用于后端开发，通过Prisma CLI生成客户端后，即可无缝集成到Express框架中，实现数据的增删改查操作。

## 3.3 核心模块接口开发详情

结合前端四大核心场景（用户管理、IM即时通讯、你画我猜游戏、慢社交、兴趣圈子），基于Express + Prisma + Socket.IO技术栈，开发对应后端接口，所有接口均适配前端GetX请求规范，支持JWT鉴权，兼顾高并发、安全性与可扩展性，每个模块接口开发详情如下，明确接口功能、请求方式、核心逻辑，确保前端可直接调用。

### 3.3.1 用户管理模块接口（适配前端登录、个人中心功能）

核心作用：处理用户注册、登录、资料管理、好友关系等，对接前端登录页、个人中心、资料编辑等页面，支撑用户全生命周期管理，关联User、FriendRelation数据模型。

- **用户注册接口**：POST /api/user/register，接收手机号、密码、昵称参数，密码通过bcrypt加密存储，校验手机号唯一性，生成用户ID，返回注册结果（成功/失败）及用户基础信息，适配前端注册页面表单提交。

- **用户登录接口**：POST /api/user/login，接收手机号、密码参数，校验账号密码正确性，生成JWT Token（有效期7天），同步更新用户在线状态（缓存至Redis），返回Token、用户信息，适配前端登录验证及状态持久化。

- **获取个人资料接口**：GET /api/user/profile，接收用户ID（从Token解析），查询User表，返回用户完整资料（昵称、头像、年龄、标签等），适配前端个人中心展示。

- **编辑个人资料接口**：PUT /api/user/profile，接收用户ID、修改后的资料（昵称、头像、简介等），更新User表，同步更新Redis中缓存的用户信息，返回更新后的资料，适配前端资料编辑页面。

- **好友请求接口**：POST /api/user/friend/request，接收发起者ID、接收者ID，创建FriendRelation记录（状态为pending），通过极光/TPNS推送好友请求通知给接收者，返回请求结果，适配前端好友添加功能。

- **好友请求处理接口**：PUT /api/user/friend/handle，接收好友关系ID、处理结果（accept/reject），更新FriendRelation表状态，返回处理结果，适配前端好友请求处理弹窗。

- **好友列表接口**：GET /api/user/friend/list，接收用户ID，查询该用户所有已通过的好友关系，关联查询好友基础信息，返回好友列表，适配前端聊天列表、好友列表展示。

- **账号注销接口**：DELETE /api/user/logout，接收用户ID，软删除用户（更新deletedAt字段），删除Redis中缓存的用户信息，清空相关缓存，返回注销结果，符合合规要求，适配前端设置页注销功能。

- **用户在线状态接口**：GET /api/user/online/status，接收用户ID列表，从Redis中查询用户在线状态，返回状态列表，适配前端聊天列表、游戏房间在线状态展示。

### 3.3.2 IM即时通讯模块接口（适配前端腾讯IM SDK协同）

核心作用：配合腾讯IM SDK，处理消息存储、已读回执、消息撤回、群聊管理等，对接前端聊天列表、聊天详情页，关联ImMessage数据模型，复用腾讯IM长连接，降低开发成本。

- **消息存储接口**：POST /api/im/message/save，接收发送者ID、接收者ID、消息类型、消息内容等参数，存储至ImMessage表，同步更新Redis中未读消息数，返回存储结果，适配前端消息发送后的持久化。

- **历史消息查询接口**：GET /api/im/message/history，接收发送者ID、接收者ID、分页参数（页码、每页条数），查询ImMessage表，按发送时间倒序返回历史消息，适配前端聊天详情页下拉加载历史消息。

- **消息已读接口**：PUT /api/im/message/read，接收接收者ID、发送者ID（或消息ID列表），更新ImMessage表中对应消息的isRead状态为true，同步更新Redis未读消息数，返回更新结果，适配前端已读回执功能。

- **消息撤回接口**：PUT /api/im/message/recall，接收消息ID、发送者ID，校验发送者权限后，更新ImMessage表中消息的isRecalled状态为true，返回撤回结果，适配前端消息撤回功能。

- **未读消息数接口**：GET /api/im/message/unread/count，接收用户ID，从Redis中查询该用户所有未读消息总数及各聊天对象的未读数量，返回未读统计数据，适配前端聊天列表未读红点展示。

- **群聊创建接口**：POST /api/im/group/create，接收群主ID、群聊名称、成员ID列表，创建群聊（对接腾讯IM群聊接口），同步存储群聊基础信息，返回群聊ID、群信息，适配前端群聊创建功能。

- **群聊成员管理接口**：PUT /api/im/group/member，接收群聊ID、操作类型（添加/移除）、成员ID列表，对接腾讯IM群成员管理接口，同步更新群聊成员信息，返回操作结果，适配前端群聊成员管理。

### 3.3.3 你画我猜游戏模块接口（适配前端实时游戏场景）

核心作用：处理游戏房间创建、匹配、玩家加入、笔触同步、积分统计等，对接前端游戏房间列表、游戏房间页，关联GameRoom、GameRoomMember、GameRecord数据模型，结合Socket.IO实现实时交互。

- **游戏房间创建接口**：POST /api/game/room/create，接收房主ID、房间名称、最大玩家数，生成唯一房间编码，创建GameRoom记录，添加房主为房间成员，返回房间信息（ID、编码、状态），适配前端创建游戏房间功能。

- **游戏房间列表接口**：GET /api/game/room/list，接收分页参数、房间状态（waiting/playing），查询GameRoom表，返回房间列表（包含当前玩家数、房主信息），适配前端游戏房间列表展示。

- **房间加入接口**：POST /api/game/room/join，接收房间编码、玩家ID，校验房间状态（是否为waiting）、玩家数量，添加玩家至GameRoomMember表，更新GameRoom表当前玩家数，通过Socket.IO通知房间内所有玩家，返回加入结果，适配前端加入房间功能。

- **房间退出接口**：POST /api/game/room/exit，接收房间ID、玩家ID，删除GameRoomMember表对应记录，更新GameRoom表当前玩家数（若房主退出，解散房间），通过Socket.IO通知房间内玩家，返回退出结果，适配前端退出房间功能。

- **笔触同步接口**：POST /api/game/brush/sync（配合Socket.IO实时推送），接收房间ID、玩家ID、笔触数据（JSON格式，二进制压缩），存储至GameRecord表，通过Socket.IO将笔触数据推送至房间内其他玩家，实现实时同步，适配前端画板交互。

- **游戏回合开始接口**：PUT /api/game/round/start，接收房间ID、回合数、题目、画画玩家ID，创建GameRecord记录，更新GameRoom表当前回合数、状态，通过Socket.IO通知房间内玩家，返回回合信息，适配前端游戏回合启动。

- **游戏回合结束接口**：PUT /api/game/round/end，接收房间ID、回合数、玩家积分列表，更新GameRecord表状态为finished，更新GameRoomMember表玩家积分、User表游戏总积分，通过Socket.IO通知房间内玩家，返回回合结果，适配前端回合结束结算。

- **游戏房间解散接口**：DELETE /api/game/room/destroy，接收房间ID、房主ID，校验权限后，更新GameRoom表状态为ended，删除房间相关缓存，通过Socket.IO通知房间内玩家，返回解散结果，适配前端房主解散房间功能。

### 3.3.4 慢社交模块接口（适配前端Slowly/Tell风格慢消息场景）

核心作用：处理慢消息发送、延迟推送、消息开封、匿名设置等，对接前端慢消息列表、写信页，关联SlowChat数据模型，结合极光/TPNS推送实现延迟消息触达。

- **慢消息发送接口**：POST /api/slowchat/send，接收发送者ID、接收者ID、消息内容、消息类型、延迟时间、是否匿名，创建SlowChat记录，设置实际发送时间（当前时间+延迟时间），添加延迟任务（定时推送），返回发送结果，适配前端写信页消息提交。

- **慢消息列表接口**：GET /api/slowchat/list，接收用户ID、消息类型（sent/received）、分页参数，查询SlowChat表，返回消息列表（包含发送时间、实际发送时间、是否开封），适配前端慢消息列表展示。

- **慢消息开封接口**：PUT /api/slowchat/open，接收消息ID、接收者ID，校验权限后，更新SlowChat表isOpened状态为true，返回开封结果，适配前端慢消息开封交互。

- **慢消息删除接口**：DELETE /api/slowchat/delete，接收消息ID、用户ID（发送者/接收者），校验权限后，删除SlowChat表对应记录，返回删除结果，适配前端慢消息删除功能。

- **延迟消息推送接口**：内部定时接口（无需前端调用），通过定时任务查询SlowChat表中到达实际发送时间的消息，通过极光/TPNS推送消息给接收者，更新消息推送状态，确保延迟消息按时触达。

- **匿名模式切换接口**：PUT /api/slowchat/anonymous，接收用户ID、是否匿名，更新User表isAnonymous状态，返回切换结果，适配前端慢社交匿名设置功能。

### 3.3.5 兴趣圈子模块接口（适配前端Dots/趣鸭风格圈子场景）

核心作用：处理圈子管理、帖子发布、评论、点赞等，对接前端圈子列表、帖子详情、发帖子页，关联Circle、CirclePost、CircleComment数据模型，适配瀑布流展示、分页加载需求。

- **兴趣圈子列表接口**：GET /api/circle/list，接收分页参数，查询Circle表，返回圈子列表（包含封面图、成员数、描述），适配前端圈子列表瀑布流展示。

- **圈子帖子发布接口**：POST /api/circle/post/publish，接收用户ID、圈子ID、帖子内容、图片URL数组，创建CirclePost记录，更新Circle表帖子数，返回帖子详情，适配前端发帖子页提交功能。

- **圈子帖子列表接口**：GET /api/circle/post/list，接收圈子ID、分页参数、排序方式（最新/最热），查询CirclePost表，关联查询发布者信息，返回帖子列表，适配前端圈子详情页帖子展示。

- **帖子详情接口**：GET /api/circle/post/detail，接收帖子ID，查询CirclePost表，关联查询发布者信息、评论列表（分页），返回帖子完整详情，适配前端帖子详情页展示。

- **帖子点赞接口**：POST /api/circle/post/like，接收帖子ID、用户ID，校验是否已点赞（避免重复点赞），更新CirclePost表点赞数，返回更新后的点赞数，适配前端帖子点赞交互。

- **帖子评论接口**：POST /api/circle/comment/add，接收帖子ID、用户ID、评论内容、父评论ID（可选），创建CircleComment记录，更新CirclePost表评论数，返回评论详情，适配前端帖子评论功能。

- **评论点赞接口**：POST /api/circle/comment/like，接收评论ID、用户ID，校验是否已点赞，更新CircleComment表点赞数，返回更新后的点赞数，适配前端评论点赞交互。

- **帖子删除接口**：DELETE /api/circle/post/delete，接收帖子ID、用户ID（发布者），校验权限后，更新CirclePost表isDeleted状态为true，返回删除结果，适配前端帖子删除功能。

- **标签筛选帖子接口**：GET /api/circle/post/filter，接收标签列表、分页参数，查询CirclePost表（关联User表标签），返回符合条件的帖子列表，适配前端标签筛选功能。

### 3.3.6 通用公共接口（支撑全前端场景）

核心作用：提供全局通用功能，适配前端各类场景，无需单独模块依赖，确保接口复用性。

- **文件上传接口**：POST /api/common/upload，接收文件（图片/语音）、用户ID、文件类型，上传至腾讯云COS/CloudBase Storage，返回文件URL，适配前端头像上传、帖子图片上传、语音消息上传。

- **Token刷新接口**：POST /api/common/token/refresh，接收旧Token，校验有效性后，生成新Token（有效期7天），返回新Token，适配前端Token过期自动刷新。

- **系统配置接口**：GET /api/common/config，接收配置键（如gameWordList、hotCircleIds），查询SystemConfig表，返回配置值，适配前端游戏题目、热门圈子等全局配置展示。

- **敏感词过滤接口**：POST /api/common/sensitive/filter，接收文本内容，对接腾讯云内容审核API，过滤敏感词，返回过滤后的文本、是否包含敏感词，适配前端发帖、发消息内容合规校验。

接口开发补充说明：所有接口均统一封装请求拦截器（JWT鉴权、参数校验）、响应拦截器（统一返回格式、异常处理），适配前端Dio+retrofit请求封装规范；高频接口（如历史消息、帖子列表）均支持分页，默认每页20条，同时利用Redis缓存提升响应速度；实时交互类接口（笔触同步、房间状态更新）结合Socket.IO实现毫秒级推送，确保前端实时体验；所有接口均做异常捕获，返回清晰的错误信息，便于前端调试。




> （注：文档部分内容可能由 AI 生成）