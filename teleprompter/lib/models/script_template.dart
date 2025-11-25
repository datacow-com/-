import 'teleprompter_settings.dart';

/// 脚本模板模型
class ScriptTemplate {
  final String id;
  final String name;
  final String description;
  final String content;
  final SceneMode sceneMode;
  final int estimatedWords;
  final int estimatedMinutes;

  const ScriptTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.content,
    required this.sceneMode,
    required this.estimatedWords,
    required this.estimatedMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'content': content,
      'sceneMode': sceneMode.index,
      'estimatedWords': estimatedWords,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  factory ScriptTemplate.fromJson(Map<String, dynamic> json) {
    return ScriptTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      sceneMode: SceneMode.values[json['sceneMode'] as int],
      estimatedWords: json['estimatedWords'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int,
    );
  }
}

/// 预设模板库
class TemplateLibrary {
  static final List<ScriptTemplate> presetTemplates = [
    // 演讲类模板
    ScriptTemplate(
      id: 'speech_product_launch',
      name: '产品发布会开场',
      description: '适合新产品发布、功能介绍等正式场合',
      sceneMode: SceneMode.speech,
      estimatedWords: 280,
      estimatedMinutes: 2,
      content: '''欢迎大家参加今天的产品发布会。

今天，我们非常荣幸地向大家介绍我们的最新产品。这款产品凝聚了团队一年多的心血，我们相信它将为大家带来全新的体验。

首先，让我简单介绍一下产品的三大核心功能。

第一，智能化设计。我们采用了最新的AI技术，让产品能够理解用户的需求，提供个性化的服务。

第二，极简操作。我们深知用户的时间宝贵，因此将复杂的功能简化为几个简单的步骤，让每个人都能轻松上手。

第三，专业品质。我们不仅关注功能，更注重细节和品质，力求为用户提供最佳体验。

接下来，让我们一起看看产品的实际演示。''',
    ),
    ScriptTemplate(
      id: 'speech_training',
      name: '团队培训开场',
      description: '适合内部培训、知识分享等场景',
      sceneMode: SceneMode.speech,
      estimatedWords: 240,
      estimatedMinutes: 2,
      content: '''大家好，欢迎参加今天的培训。

今天我们要学习的主题是如何提升工作效率。这是一个非常实用的话题，相信会对大家的日常工作有很大帮助。

在开始之前，我想先问大家一个问题：你们觉得影响工作效率的最大因素是什么？

很多人可能会说是时间管理，也有人会说是工具使用。这些都没错，但我认为最重要的是方法论。

今天的培训分为三个部分。首先，我们会讨论高效工作的核心原则。然后，我会分享一些实用的工具和技巧。最后，我们会通过实际案例来演练。

希望大家积极参与，有任何问题随时提出。让我们开始吧。''',
    ),
    ScriptTemplate(
      id: 'speech_summary',
      name: '会议总结发言',
      description: '适合会议结束时的总结陈述',
      sceneMode: SceneMode.speech,
      estimatedWords: 200,
      estimatedMinutes: 1,
      content: '''感谢大家今天的参与和贡献。

通过今天的讨论，我们达成了几个重要共识。

第一，我们明确了项目的核心目标和时间节点。

第二，我们分配了各自的职责，每个人都清楚自己的任务。

第三，我们建立了有效的沟通机制，确保信息及时同步。

接下来，请大家按照今天的计划推进工作。如果遇到任何问题，及时在群里沟通。

我们下周同一时间再次碰面，检查进度。

再次感谢大家，散会。''',
    ),

    // 口播类模板
    ScriptTemplate(
      id: 'video_review',
      name: '产品评测脚本',
      description: '适合产品开箱、评测类短视频',
      sceneMode: SceneMode.video,
      estimatedWords: 320,
      estimatedMinutes: 2,
      content: '''大家好，今天给大家分享一款我最近在用的神器。

先看外观，包装非常精致，打开后配件齐全，说明书、充电线、保护套都有。

产品本身的设计很简约，拿在手里质感很好，重量适中，不会觉得太重或太轻。

接下来看功能。第一个功能是智能识别，只需要简单操作就能完成，非常方便。

第二个功能是快速响应，我实测了一下，速度确实很快，基本没有延迟。

第三个功能是长续航，官方说能用8小时，我实际用下来差不多7个小时，表现不错。

再说说使用体验。整体来说，这款产品的优点是操作简单、功能实用、品质可靠。缺点是价格稍微有点高，但考虑到品质，我觉得还是值得的。

如果你也在找这类产品，可以考虑一下。好了，今天的分享就到这里，喜欢的话记得点赞关注，我们下期再见。''',
    ),
    ScriptTemplate(
      id: 'video_knowledge',
      name: '知识分享脚本',
      description: '适合教程、知识科普类内容',
      sceneMode: SceneMode.video,
      estimatedWords: 300,
      estimatedMinutes: 2,
      content: '''大家好，今天教大家一个超实用的技巧。

很多人都遇到过这个问题，但不知道怎么解决。其实方法很简单，只需要三步。

第一步，打开设置，找到对应的选项。这里要注意，不同版本的位置可能不一样，大家根据实际情况找。

第二步，点击进入后，会看到几个选项。我们选择第二个，然后按照提示操作。

第三步，确认设置，重启一下就生效了。

是不是很简单？我再演示一遍。看，就是这样，几秒钟就搞定了。

这个技巧不仅能解决当前的问题，还能提升整体效率。我自己用了之后，感觉工作效率提升了至少30%。

如果你也有这个需求，赶紧试试吧。觉得有用的话，记得点赞收藏，分享给更多需要的朋友。我们下期见。''',
    ),
    ScriptTemplate(
      id: 'video_vlog',
      name: 'Vlog开场白',
      description: '适合日常vlog、生活记录',
      sceneMode: SceneMode.video,
      estimatedWords: 250,
      estimatedMinutes: 1,
      content: '''嗨，大家好，我是小明。

今天带大家看看我的一天。早上7点起床，简单洗漱后，我会先做20分钟运动，让自己精神起来。

然后是早餐时间。今天准备了全麦面包、煎蛋和牛奶，营养又健康。

吃完早餐，开始一天的工作。我的工作主要是在电脑前，所以每隔一小时我会起来活动一下，避免久坐。

中午会点个外卖或者自己做点简单的。下午继续工作，晚上6点左右结束。

晚上的时间是我最喜欢的，可以做自己喜欢的事情，看书、追剧或者剪视频。

这就是我普通的一天，虽然平淡但很充实。你们的一天是怎样的呢？欢迎在评论区分享。

好了，今天的vlog就到这里，我们下次再见。''',
    ),

    // 直播类模板
    ScriptTemplate(
      id: 'live_opening',
      name: '直播开场话术',
      description: '适合直播开场，活跃气氛',
      sceneMode: SceneMode.live,
      estimatedWords: 280,
      estimatedMinutes: 2,
      content: '''大家好，欢迎来到我的直播间。

看到有老朋友，也看到很多新朋友，欢迎欢迎。

今天给大家准备了很多好东西，一会儿会一一介绍。在开始之前，先跟大家聊聊天。

有没有小伙伴是第一次来的？打个1让我看看。哇，这么多新朋友，欢迎欢迎。

老朋友们也打个2，让我看看有多少铁粉。好的好的，看到了，谢谢大家的支持。

今天的直播主要分三个环节。第一个环节是产品介绍，我会详细讲解每个产品的特点和使用方法。

第二个环节是互动问答，大家有什么问题都可以提出来，我会一一解答。

第三个环节是福利时间，会有一些优惠和抽奖活动，大家一定要留到最后。

好了，废话不多说，我们马上开始。记得点关注，不迷路。''',
    ),
    ScriptTemplate(
      id: 'live_product',
      name: '产品介绍话术',
      description: '适合带货直播，产品推荐',
      sceneMode: SceneMode.live,
      estimatedWords: 300,
      estimatedMinutes: 2,
      content: '''来来来，家人们看这里。

今天要给大家介绍的这款产品，真的是我用过最好的。不是我吹，你们用了就知道。

先看品质。这个材质是进口的，摸起来手感特别好，而且很耐用。我自己用了半年了，还跟新的一样。

再看功能。它有三大功能，第一个是智能控制，手机上就能操作，非常方便。

第二个是节能环保，比传统产品省电30%，一年下来能省不少钱。

第三个是安全可靠，通过了多项认证，用起来特别放心。

现在重点来了，价格。平时卖299，今天直播间特价，只要199，而且买二送一。

这个价格真的是亏本在卖，就是为了回馈大家。库存不多，想要的赶紧下单。

我看到已经有人下单了，动作真快。还没下单的抓紧了，一会儿就没了。''',
    ),
    ScriptTemplate(
      id: 'live_interaction',
      name: '互动引导话术',
      description: '适合直播互动，提升活跃度',
      sceneMode: SceneMode.live,
      estimatedWords: 220,
      estimatedMinutes: 2,
      content: '''好的，接下来是互动时间。

我看到很多朋友在问问题，我挑几个大家都关心的来回答。

第一个问题，这个产品适合什么人群？我的回答是，基本上所有人都适合，特别是注重品质的朋友。

第二个问题，有没有优惠？当然有，今天直播间专属优惠，错过就没了。

第三个问题，售后怎么样？这个大家放心，我们有专业的售后团队，7天无理由退换，一年质保。

还有朋友问能不能便宜点。家人们，这个价格真的是底价了，我们是薄利多销。

好了，问题先回答到这里。接下来我们继续看下一个产品。

对了，还没关注的朋友记得点个关注，不然下次找不到我了。''',
    ),
  ];
}
