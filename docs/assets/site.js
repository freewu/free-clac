/* 官网前端：多语言 + 深浅配色 + 截图灯箱。
 *
 * 工具卡片的名字、卖点、说明与强调色来自 assets/tools-data.js
 * （由 tool/site_data.py 从 lib/ui/tools/ 导出），其余文案写在本文件里。
 */
(function () {
  'use strict';

  /* ── 语言列表（顺序与 App 内一致） ───────────────────────────── */
  var LANGS = [
    { code: 'zh-Hans', label: '简体中文', htmlLang: 'zh-Hans', ogLocale: 'zh_CN' },
    { code: 'zh-Hant', label: '繁體中文', htmlLang: 'zh-Hant', ogLocale: 'zh_TW' },
    { code: 'en', label: 'English', htmlLang: 'en', ogLocale: 'en_US' },
    { code: 'ja', label: '日本語', htmlLang: 'ja', ogLocale: 'ja_JP' },
    { code: 'es', label: 'Español', htmlLang: 'es', ogLocale: 'es_ES' },
  ];

  var REPO = 'https://github.com/freewu/free-clac';

  /* ── 各语言文案 ──────────────────────────────────────────────── */
  var I18N = {
    'zh-Hans': {
      title: 'Magic 计算器 · 科学计算与函数绘图',
      description:
        'Flutter 写的科学计算器：自研表达式引擎、四种曲线绘图、17 个离线小工具，深色 / 浅色与五种界面语言。',
      skip: '跳到正文',
      brand: 'Magic 计算器',
      nav: {
        features: '特性',
        shots: '截图',
        theme: '配色',
        tools: '工具',
        languages: '语言',
      },
      hero: {
        badge: 'Flutter · 离线运行 · 无广告无追踪',
        title: '会画图的<span class="grad">科学计算器</span>',
        lead:
          '自研词法与递归下降解析器负责表达式，像素级自适应采样负责曲线，' +
          '一堆日常小工具负责生活里那些琐碎的算术——全部本地计算，Web、Windows、Android 都能跑。',
        ctaShots: '看看界面',
        ctaRepo: '源码与文档',
        windowTitle: 'Magic 计算器',
      },
      stats: [
        { value: '48', label: '内置函数' },
        { value: '4', label: '曲线类型' },
        { value: '{tools}', label: '离线工具' },
        { value: '5', label: '界面语言' },
      ],
      features: {
        eyebrow: '核心能力',
        title: '该有的都有，不该有的没有',
        lead: '没有账号、没有广告、没有联网权限。打开就能算，关掉也不留痕。',
        items: [
          {
            icon: 'code',
            title: '自带表达式引擎',
            body:
              '词法 + 递归下降，隐式乘法（2π、3sinx）、右结合幂、48 个内置函数，' +
              '还有定积分、求和与数值求导。',
          },
          {
            icon: 'chart',
            title: '四种曲线',
            body:
              '直角坐标、极坐标、参数方程，以及隐式方程 f(x, y) = 0——用 marching squares 逐格求等值线。',
          },
          {
            icon: 'sampling',
            title: '像素级采样',
            body:
              '按屏幕像素细分，1/x、tan x 这类间断点自动断线，拖动缩放都不会连出错误的直线。',
          },
          {
            icon: 'sparkles',
            title: '示例曲线库',
            body: '心形、玫瑰线、李萨如……点一下追加到画布，视口自动扩到刚好装得下。',
          },
          {
            icon: 'moon',
            title: '深色与浅色',
            body:
              '两套完整配色：按键渐变、卡片描边、绘图网格与曲线调色板一起换，也可以跟随系统。',
          },
          {
            icon: 'globe',
            title: '五种语言',
            body: '简体、繁體、English、日本語、Español，连错误提示、函数说明和示例曲线名都翻了。',
          },
          {
            icon: 'export',
            title: '导出与分享',
            body: '绘图可导出 PNG / WebP / SVG，计算结果一键复制成 LaTeX。',
          },
          {
            icon: 'tools',
            title: '记住上次输入',
            body: '每个小工具都有草稿和历史记录，切出去再回来，数字还在。',
          },
        ],
      },
      shots: {
        eyebrow: '界面截图',
        title: '一屏一屏看过去',
        lead: '下面是同一套界面在五种语言下的样子：切换右上角的语言，整套截图会跟着换。',
        items: {
          calculator: { name: '计算器', desc: '实时预览、历史记录、LaTeX 复制' },
          plot: { name: '函数绘图', desc: '自适应网格、拖动缩放、追踪读数' },
          heart: { name: '示例曲线', desc: '心形参数方程一键载入' },
          implicit: { name: '隐式方程', desc: 'f(x, y) = 0 的等值线' },
          tools: { name: '工具页', desc: '应用商店式卡片，图钉置顶' },
          settings: { name: '设置', desc: '外观、语言、货币与默认值' },
        },
        phoneTitle: '手机上也好用',
        phoneLead:
          '窄屏自动切成单列，按键为拇指放大；Android 导出的图片直接落进系统相册。',
      },
      theme: {
        eyebrow: '配色',
        title: '深色与浅色，都是一等公民',
        lead:
          '不是把背景刷白：两套配色各自调过对比度，按键渐变、卡片描边、绘图网格与曲线调色板都单独配过。',
        dark: '深色',
        light: '浅色',
      },
      toolsSection: {
        eyebrow: '工具箱',
        title: '{tools} 个离线小工具',
        lead: '健康、换算、金融、税社保——每个工具一张小卡片，可以置顶，也会记住草稿。',
        hint: '点击任意卡片查看大图',
        note: '养老金、退休年龄、个税只在简繁中文界面出现（口径只适用于中国大陆）。',
      },
      languages: {
        eyebrow: '多语言',
        title: '五种语言，翻到错误提示',
        lead:
          '界面文案、工具语言包、48 个函数说明、运算错误提示、示例曲线名称……都跟着语言走。点一下即可切换整站。',
        current: '当前',
        note: '界面语言与官网语言一致，截图也是同一语言下截的。',
      },
      footer: {
        note: '用 Flutter 构建 · 本地计算，不联网',
        repo: '源码仓库',
        docs: 'README',
        license: 'MIT 许可',
      },
    },

    'zh-Hant': {
      title: 'Magic 計算器 · 科學計算與函數繪圖',
      description:
        'Flutter 寫的科學計算器：自研運算式引擎、四種曲線繪圖、17 個離線小工具，深色 / 淺色與五種介面語言。',
      skip: '跳至內容',
      brand: 'Magic 計算器',
      nav: {
        features: '特色',
        shots: '截圖',
        theme: '配色',
        tools: '工具',
        languages: '語言',
      },
      hero: {
        badge: 'Flutter · 離線執行 · 無廣告無追蹤',
        title: '會繪圖的<span class="grad">科學計算器</span>',
        lead:
          '自研詞法與遞迴下降解析器負責算式，像素級自適應取樣負責曲線，' +
          '還有一堆日常小工具處理生活裡的零碎算術——全部在本機計算，Web、Windows、Android 都能跑。',
        ctaShots: '看看介面',
        ctaRepo: '原始碼與文件',
        windowTitle: 'Magic 計算器',
      },
      stats: [
        { value: '48', label: '內建函數' },
        { value: '4', label: '曲線類型' },
        { value: '{tools}', label: '離線工具' },
        { value: '5', label: '介面語言' },
      ],
      features: {
        eyebrow: '核心能力',
        title: '該有的都有，不該有的沒有',
        lead: '沒有帳號、沒有廣告、沒有連網權限。打開就能算，關掉也不留痕。',
        items: [
          {
            icon: 'code',
            title: '自帶運算式引擎',
            body:
              '詞法 + 遞迴下降，隱含乘法（2π、3sinx）、右結合次方、48 個內建函數，' +
              '還有定積分、求和與數值求導。',
          },
          {
            icon: 'chart',
            title: '四種曲線',
            body:
              '直角座標、極座標、參數方程式，以及隱函數 f(x, y) = 0——用 marching squares 逐格求等值線。',
          },
          {
            icon: 'sampling',
            title: '像素級取樣',
            body:
              '依螢幕像素細分，1/x、tan x 這類間斷點自動斷線，拖曳縮放都不會連出錯誤的直線。',
          },
          {
            icon: 'sparkles',
            title: '範例曲線庫',
            body: '心形、玫瑰線、利薩茹……點一下加入畫布，視口自動擴到剛好裝得下。',
          },
          {
            icon: 'moon',
            title: '深色與淺色',
            body:
              '兩套完整配色：按鍵漸層、卡片描邊、繪圖網格與曲線調色盤一起換，也可以跟隨系統。',
          },
          {
            icon: 'globe',
            title: '五種語言',
            body: '簡體、繁體、English、日本語、Español，連錯誤提示、函數說明和範例曲線名稱都翻了。',
          },
          {
            icon: 'export',
            title: '匯出與分享',
            body: '繪圖可匯出 PNG / WebP / SVG，計算結果一鍵複製成 LaTeX。',
          },
          {
            icon: 'tools',
            title: '記住上次輸入',
            body: '每個小工具都有草稿與歷史記錄，切出去再回來，數字還在。',
          },
        ],
      },
      shots: {
        eyebrow: '介面截圖',
        title: '一屏一屏看過去',
        lead: '以下是同一套介面在五種語言下的樣子：切換右上角的語言，整套截圖會跟著換。',
        items: {
          calculator: { name: '計算器', desc: '即時預覽、歷史記錄、LaTeX 複製' },
          plot: { name: '函數繪圖', desc: '自適應網格、拖曳縮放、追蹤讀數' },
          heart: { name: '範例曲線', desc: '心形參數方程式一鍵載入' },
          implicit: { name: '隱函數', desc: 'f(x, y) = 0 的等值線' },
          tools: { name: '工具頁', desc: '應用程式商店式卡片，圖釘置頂' },
          settings: { name: '設定', desc: '外觀、語言、貨幣與預設值' },
        },
        phoneTitle: '手機上也順手',
        phoneLead:
          '窄螢幕自動切成單欄，按鍵為拇指放大；Android 匯出的圖片直接存進系統相簿。',
      },
      theme: {
        eyebrow: '配色',
        title: '深色與淺色，都是一等公民',
        lead:
          '不是把背景刷白：兩套配色各自調過對比度，按鍵漸層、卡片描邊、繪圖網格與曲線調色盤都單獨配過。',
        dark: '深色',
        light: '淺色',
      },
      toolsSection: {
        eyebrow: '工具箱',
        title: '{tools} 個離線小工具',
        lead: '健康、換算、金融、稅務勞保——每個工具一張小卡片，可以置頂，也會記住草稿。',
        hint: '點擊任意卡片查看大圖',
        note: '退休金、退休年齡、個人所得稅只在簡繁中文介面出現（口徑僅適用於中國大陸）。',
      },
      languages: {
        eyebrow: '多語言',
        title: '五種語言，翻到錯誤提示',
        lead:
          '介面文案、工具語言包、48 個函數說明、運算錯誤提示、範例曲線名稱……都跟著語言走。點一下即可切換整站。',
        current: '目前',
        note: '介面語言與官網語言一致，截圖也是同一語言下截的。',
      },
      footer: {
        note: '以 Flutter 打造 · 本機計算，不連網',
        repo: '原始碼倉庫',
        docs: 'README',
        license: 'MIT 授權',
      },
    },

    en: {
      title: 'Magic Calculator · Scientific calculation and function plots',
      description:
        'A Flutter scientific calculator with a hand-written expression engine, four kinds of plots and 14 offline tools — dark and light themes, five UI languages.',
      skip: 'Skip to content',
      brand: 'Magic Calculator',
      nav: {
        features: 'Features',
        shots: 'Screenshots',
        theme: 'Themes',
        tools: 'Tools',
        languages: 'Languages',
      },
      hero: {
        badge: 'Flutter · Runs offline · No ads, no tracking',
        title: 'A scientific calculator <span class="grad">that draws</span>',
        lead:
          'A hand-written lexer and recursive-descent parser for expressions, pixel-level adaptive sampling for curves, ' +
          'and a pile of small tools for everyday math — all computed on device, on Web, Windows and Android.',
        ctaShots: 'See the screenshots',
        ctaRepo: 'Source & docs',
        windowTitle: 'Magic Calculator',
      },
      stats: [
        { value: '48', label: 'built-in functions' },
        { value: '4', label: 'plot types' },
        { value: '{tools}', label: 'offline tools' },
        { value: '5', label: 'UI languages' },
      ],
      features: {
        eyebrow: 'Under the hood',
        title: 'Everything it needs, nothing it does not',
        lead: 'No account, no ads, no network permission. Open it, calculate, close it.',
        items: [
          {
            icon: 'code',
            title: 'Its own expression engine',
            body:
              'Lexer plus recursive descent: implicit multiplication (2π, 3sinx), right-associative powers, ' +
              '48 built-in functions, definite integrals, sums and numeric derivatives.',
          },
          {
            icon: 'chart',
            title: 'Four kinds of plots',
            body:
              'Cartesian, polar, parametric — and implicit curves f(x, y) = 0, traced with marching squares.',
          },
          {
            icon: 'sampling',
            title: 'Pixel-level sampling',
            body:
              'Sampling follows the pixels, so 1/x or tan x break at their poles instead of drawing a false straight line.',
          },
          {
            icon: 'sparkles',
            title: 'Preset gallery',
            body: 'Heart, rose curve, Lissajous… one tap adds the curve and fits the viewport to it.',
          },
          {
            icon: 'moon',
            title: 'Dark and light',
            body:
              'Two complete palettes — key gradients, card outlines, plot grid and curve colours all change together, or follow the system.',
          },
          {
            icon: 'globe',
            title: 'Five languages',
            body:
              'Simplified and Traditional Chinese, English, Japanese and Spanish — down to error messages and function help.',
          },
          {
            icon: 'export',
            title: 'Export and share',
            body: 'Plots export to PNG, WebP or SVG; results copy as LaTeX with one tap.',
          },
          {
            icon: 'tools',
            title: 'Remembers your input',
            body: 'Every tool keeps a draft and its history, so the numbers are still there when you come back.',
          },
        ],
      },
      shots: {
        eyebrow: 'Screenshots',
        title: 'Screen by screen',
        lead: 'The same interface in five languages — switch the language up top and the whole set changes with it.',
        items: {
          calculator: {
            name: 'Calculator',
            desc: 'Live preview, history, copy as LaTeX',
          },
          plot: {
            name: 'Plotting',
            desc: 'Adaptive grid, pan and zoom, trace readouts',
          },
          heart: { name: 'Preset curve', desc: 'A heart parametric curve in one tap' },
          implicit: { name: 'Implicit curve', desc: 'Contours of f(x, y) = 0' },
          tools: { name: 'Tools', desc: 'Store-style cards, pin your favourites' },
          settings: { name: 'Settings', desc: 'Appearance, language, currency, defaults' },
        },
        phoneTitle: 'Comfortable on a phone',
        phoneLead:
          'Narrow screens switch to a single column with thumb-sized keys; on Android exports land straight in the gallery.',
      },
      theme: {
        eyebrow: 'Themes',
        title: 'Dark and light are both first-class',
        lead:
          'Light mode is not a painted-over dark mode: both palettes have their own contrast tuning, key gradients, card outlines, plot grid and curve colours.',
        dark: 'Dark',
        light: 'Light',
      },
      toolsSection: {
        eyebrow: 'Toolbox',
        title: '{tools} offline tools',
        lead: 'Health, unit conversion, finance, tax and social insurance — each one a small card you can pin, with its draft saved.',
        hint: 'Click any card to enlarge',
        note: 'Pension, retirement age and income tax appear in Chinese UIs only, because they follow mainland China rules.',
      },
      languages: {
        eyebrow: 'Languages',
        title: 'Five languages, error messages included',
        lead:
          'UI copy, tool strings, 48 function descriptions, calculation errors and preset names all follow the language. Pick one to switch the whole site.',
        current: 'Current',
        note: 'The site language matches the in-app language, so the screenshots are taken in the same one.',
      },
      footer: {
        note: 'Built with Flutter · Calculated on device, never online',
        repo: 'Repository',
        docs: 'README',
        license: 'MIT licence',
      },
    },

    ja: {
      title: 'Magic 計算機 · 関数電卓とグラフ描画',
      description:
        'Flutter 製の関数電卓。自前の数式エンジン、4 種類のグラフ、14 個のオフラインツール、ダーク / ライトと 5 言語の UI。',
      skip: '本文へ',
      brand: 'Magic 計算機',
      nav: {
        features: '機能',
        shots: '画面',
        theme: '配色',
        tools: 'ツール',
        languages: '言語',
      },
      hero: {
        badge: 'Flutter · オフライン動作 · 広告も追跡もなし',
        title: 'グラフも描ける<span class="grad">関数電卓</span>',
        lead:
          '式は自前の字句解析＋再帰下降パーサ、曲線はピクセル単位の適応サンプリング、' +
          '暮らしの計算は小さなツールたち。すべて端末内で計算し、Web・Windows・Android で動きます。',
        ctaShots: '画面を見る',
        ctaRepo: 'ソースとドキュメント',
        windowTitle: 'Magic 計算機',
      },
      stats: [
        { value: '48', label: '組み込み関数' },
        { value: '4', label: 'グラフの種類' },
        { value: '{tools}', label: 'オフラインツール' },
        { value: '5', label: 'UI 言語' },
      ],
      features: {
        eyebrow: '中身の話',
        title: '必要なものは全部、余計なものは何も',
        lead: 'アカウントも広告も通信権限もありません。開いて計算して、閉じるだけ。',
        items: [
          {
            icon: 'code',
            title: '自前の数式エンジン',
            body:
              '字句解析＋再帰下降。暗黙の積（2π、3sinx）、右結合の累乗、48 個の組み込み関数に加えて、' +
              '定積分・総和・数値微分まで。',
          },
          {
            icon: 'chart',
            title: '4 種類のグラフ',
            body:
              '直交座標・極座標・媒介変数、そして陰関数 f(x, y) = 0。等値線は marching squares で追います。',
          },
          {
            icon: 'sampling',
            title: 'ピクセル単位のサンプリング',
            body:
              '画面のピクセルに合わせて分割するので、1/x や tan x の不連続点は線を切り、拡大しても誤った直線を引きません。',
          },
          {
            icon: 'sparkles',
            title: 'サンプル曲線',
            body: 'ハート、バラ曲線、リサージュ……タップで追加、表示範囲は自動でぴったりに。',
          },
          {
            icon: 'moon',
            title: 'ダークとライト',
            body:
              'どちらも作り込んだ 2 つの配色。キーのグラデーション、カードの枠線、グラフのグリッドと曲線色まで一緒に変わります。',
          },
          {
            icon: 'globe',
            title: '5 言語',
            body:
              '簡体字・繁体字・English・日本語・Español。エラー文言も関数の説明も翻訳済みです。',
          },
          {
            icon: 'export',
            title: '書き出しと共有',
            body: 'グラフは PNG / WebP / SVG で書き出し、計算結果は LaTeX としてコピーできます。',
          },
          {
            icon: 'tools',
            title: '入力を覚えている',
            body: 'どのツールも下書きと履歴を保存。離れて戻ってきても数字はそのまま。',
          },
        ],
      },
      shots: {
        eyebrow: 'スクリーンショット',
        title: '画面をひとつずつ',
        lead: '同じ UI を 5 言語で。右上の言語を切り替えると、画像もまとめて入れ替わります。',
        items: {
          calculator: {
            name: '計算機',
            desc: 'リアルタイム表示、履歴、LaTeX コピー',
          },
          plot: { name: 'グラフ', desc: '適応グリッド、ドラッグと拡大、トレース表示' },
          heart: { name: 'サンプル曲線', desc: 'ハートの媒介変数曲線をワンタップで' },
          implicit: { name: '陰関数', desc: 'f(x, y) = 0 の等値線' },
          tools: { name: 'ツール', desc: 'ストア風カード、ピンで固定' },
          settings: { name: '設定', desc: '外観、言語、通貨、既定値' },
        },
        phoneTitle: 'スマホでも快適',
        phoneLead:
          '狭い画面では 1 列に切り替わり、キーは親指サイズに。Android の書き出しはそのままギャラリーへ。',
      },
      theme: {
        eyebrow: '配色',
        title: 'ダークもライトも主役',
        lead:
          'ライトはダークを白く塗っただけではありません。2 つの配色それぞれにコントラスト、キーのグラデーション、カードの枠線、グリッドと曲線色を用意しています。',
        dark: 'ダーク',
        light: 'ライト',
      },
      toolsSection: {
        eyebrow: 'ツールボックス',
        title: '{tools} 個のオフラインツール',
        lead: '健康、単位換算、金融、税と社会保険。どれも小さなカードで、ピン留めも下書き保存もできます。',
        hint: 'カードをクリックすると拡大します',
        note: '年金・退休年齢・個人所得税は中国大陸向けの計算なので、中国語 UI にのみ表示されます。',
      },
      languages: {
        eyebrow: '言語',
        title: '5 言語、エラー文言まで',
        lead:
          'UI の文言、ツールの語言データ、48 個の関数説明、計算エラー、サンプル曲線の名前まで言語に追従します。クリックでサイト全体が切り替わります。',
        current: '選択中',
        note: 'サイトの言語とアプリ内の言語は揃えてあり、スクリーンショットも同じ言語で撮っています。',
      },
      footer: {
        note: 'Flutter 製 · 端末内で計算、通信しません',
        repo: 'リポジトリ',
        docs: 'README',
        license: 'MIT ライセンス',
      },
    },

    es: {
      title: 'Magic Calculadora · Cálculo científico y gráficas',
      description:
        'Una calculadora científica hecha con Flutter: motor de expresiones propio, cuatro tipos de gráficas y 14 herramientas sin conexión — temas claro y oscuro, cinco idiomas.',
      skip: 'Ir al contenido',
      brand: 'Magic Calculadora',
      nav: {
        features: 'Funciones',
        shots: 'Capturas',
        theme: 'Temas',
        tools: 'Herramientas',
        languages: 'Idiomas',
      },
      hero: {
        badge: 'Flutter · Sin conexión · Sin anuncios ni rastreo',
        title: 'Una calculadora científica <span class="grad">que dibuja</span>',
        lead:
          'Analizador léxico y sintáctico propio para las expresiones, muestreo adaptativo al píxel para las curvas ' +
          'y un montón de herramientas para el día a día: todo se calcula en el dispositivo, en Web, Windows y Android.',
        ctaShots: 'Ver las capturas',
        ctaRepo: 'Código y documentación',
        windowTitle: 'Magic Calculadora',
      },
      stats: [
        { value: '48', label: 'funciones incluidas' },
        { value: '4', label: 'tipos de gráfica' },
        { value: '{tools}', label: 'herramientas' },
        { value: '5', label: 'idiomas' },
      ],
      features: {
        eyebrow: 'Bajo el capó',
        title: 'Todo lo necesario, nada de más',
        lead: 'Sin cuenta, sin anuncios, sin permiso de red. Abrir, calcular, cerrar.',
        items: [
          {
            icon: 'code',
            title: 'Motor de expresiones propio',
            body:
              'Léxico y descenso recursivo: multiplicación implícita (2π, 3sinx), potencias asociativas a la derecha, ' +
              '48 funciones incluidas, integrales definidas, sumatorios y derivadas numéricas.',
          },
          {
            icon: 'chart',
            title: 'Cuatro tipos de gráfica',
            body:
              'Cartesianas, polares, paramétricas y curvas implícitas f(x, y) = 0, trazadas con marching squares.',
          },
          {
            icon: 'sampling',
            title: 'Muestreo al píxel',
            body:
              'El muestreo sigue los píxeles, así que 1/x o tan x se cortan en sus asíntotas en vez de dibujar una recta falsa.',
          },
          {
            icon: 'sparkles',
            title: 'Galería de ejemplos',
            body: 'Corazón, rosa, Lissajous… un toque añade la curva y ajusta la vista para que quepa entera.',
          },
          {
            icon: 'moon',
            title: 'Claro y oscuro',
            body:
              'Dos paletas completas: degradados de teclas, bordes de tarjeta, rejilla y colores de curva cambian juntos, o siguen al sistema.',
          },
          {
            icon: 'globe',
            title: 'Cinco idiomas',
            body:
              'Chino simplificado y tradicional, inglés, japonés y español, hasta los mensajes de error y la ayuda de funciones.',
          },
          {
            icon: 'export',
            title: 'Exportar y compartir',
            body: 'Las gráficas salen en PNG, WebP o SVG; los resultados se copian como LaTeX con un toque.',
          },
          {
            icon: 'tools',
            title: 'Recuerda lo que escribiste',
            body: 'Cada herramienta guarda un borrador y su historial: los números siguen ahí al volver.',
          },
        ],
      },
      shots: {
        eyebrow: 'Capturas',
        title: 'Pantalla a pantalla',
        lead: 'La misma interfaz en cinco idiomas: cambia el idioma arriba y todo el conjunto de capturas cambia con él.',
        items: {
          calculator: {
            name: 'Calculadora',
            desc: 'Vista previa al instante, historial, copiar como LaTeX',
          },
          plot: {
            name: 'Gráficas',
            desc: 'Rejilla adaptativa, arrastrar y hacer zoom, lectura del trazo',
          },
          heart: { name: 'Curva de ejemplo', desc: 'Un corazón paramétrico con un toque' },
          implicit: { name: 'Curva implícita', desc: 'Curvas de nivel de f(x, y) = 0' },
          tools: { name: 'Herramientas', desc: 'Tarjetas tipo tienda, fija tus favoritas' },
          settings: { name: 'Ajustes', desc: 'Aspecto, idioma, moneda y valores por defecto' },
        },
        phoneTitle: 'Cómoda en el móvil',
        phoneLead:
          'En pantallas estrechas pasa a una sola columna con teclas para el pulgar; en Android las exportaciones van directas a la galería.',
      },
      theme: {
        eyebrow: 'Temas',
        title: 'Claro y oscuro, ambos de primera',
        lead:
          'El modo claro no es el oscuro pintado de blanco: cada paleta tiene su propio contraste, degradados de teclas, bordes, rejilla y colores de curva.',
        dark: 'Oscuro',
        light: 'Claro',
      },
      toolsSection: {
        eyebrow: 'Caja de herramientas',
        title: '{tools} herramientas sin conexión',
        lead: 'Salud, unidades, finanzas, impuestos y seguridad social: cada una es una tarjeta que puedes fijar y que guarda su borrador.',
        hint: 'Haz clic en una tarjeta para ampliarla',
        note: 'Pensión, edad de jubilación e IRPF aparecen solo en chino, porque siguen las normas de China continental.',
      },
      languages: {
        eyebrow: 'Idiomas',
        title: 'Cinco idiomas, hasta los errores',
        lead:
          'Textos de la interfaz, cadenas de las herramientas, 48 descripciones de funciones, errores de cálculo y nombres de ejemplos: todo sigue al idioma. Elige uno para cambiar el sitio entero.',
        current: 'Actual',
        note: 'El idioma del sitio coincide con el de la app, así que las capturas están hechas en el mismo.',
      },
      footer: {
        note: 'Hecho con Flutter · Se calcula en el dispositivo, nunca en línea',
        repo: 'Repositorio',
        docs: 'README',
        license: 'Licencia MIT',
      },
    },
  };

  /* ── 图标（24×24 线性） ─────────────────────────────────────── */
  var ICONS = {
    code: '<path d="M9 6 4 12l5 6M15 6l5 6-5 6"/>',
    chart:
      '<path d="M4 19h16M6 15.5l4-4.5 3 2.8 5-6.3"/><circle cx="10" cy="11" r="1.4"/><circle cx="13" cy="13.8" r="1.4"/>',
    sampling: '<path d="M3 12h2.5l2-5.5 3 11 3-8 2 2.5H21"/>',
    sparkles:
      '<path d="M12 3.5 13.7 9l5.5 1.7-5.5 1.7L12 18l-1.7-5.6L4.8 10.7 10.3 9 12 3.5Z"/><path d="M18.5 15.5l.8 2.4 2.4.8-2.4.8-.8 2.4-.8-2.4-2.4-.8 2.4-.8.8-2.4Z"/>',
    moon: '<path d="M20.5 14.2A8.5 8.5 0 1 1 9.8 3.5a6.8 6.8 0 0 0 10.7 10.7Z"/>',
    globe:
      '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 9h17M3.5 15h17"/><path d="M12 3.5c2.4 2.2 3.8 5.3 3.8 8.5S14.4 18.3 12 20.5C9.6 18.3 8.2 15.2 8.2 12S9.6 5.7 12 3.5Z"/>',
    export: '<path d="M12 15V4m0 0L8.5 7.5M12 4l3.5 3.5"/><path d="M5 13.5V19h14v-5.5"/>',
    tools:
      '<circle cx="12" cy="12" r="3.2"/><path d="M12 3.6v2.2M12 18.2v2.2M20.4 12h-2.2M5.8 12H3.6M18 6l-1.6 1.6M7.6 16.4 6 18M18 18l-1.6-1.6M7.6 7.6 6 6"/>',
  };

  /* ── 小工具函数 ─────────────────────────────────────────────── */
  function $(sel, root) {
    return (root || document).querySelector(sel);
  }

  function h(tag, attrs, children) {
    var node = document.createElement(tag);
    if (attrs) {
      Object.keys(attrs).forEach(function (key) {
        var value = attrs[key];
        if (value === null || value === undefined || value === false) return;
        if (key === 'text') {
          node.textContent = value;
        } else if (key === 'html') {
          node.innerHTML = value;
        } else if (key === 'style') {
          node.setAttribute('style', value);
        } else if (key.slice(0, 2) === 'on') {
          node.addEventListener(key.slice(2).toLowerCase(), value);
        } else {
          node.setAttribute(key, value === true ? '' : value);
        }
      });
    }
    (children || []).forEach(function (child) {
      if (child === null || child === undefined) return;
      node.appendChild(typeof child === 'string' ? document.createTextNode(child) : child);
    });
    return node;
  }

  function icon(name) {
    return (
      '<svg class="feature-icon" viewBox="0 0 24 24" aria-hidden="true" fill="none" ' +
      'stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">' +
      (ICONS[name] || ICONS.code) +
      '</svg>'
    );
  }

  function fill(template, values) {
    return String(template).replace(/\{(\w+)\}/g, function (whole, key) {
      return Object.prototype.hasOwnProperty.call(values, key) ? values[key] : whole;
    });
  }

  function shotPath(code, name) {
    return 'screenshots/' + code + '/' + name + '.png';
  }

  function toolsFor(code) {
    var all = window.FREE_CLAC_TOOLS || [];
    return all.filter(function (tool) {
      return !tool.only || tool.only.indexOf(code) >= 0;
    });
  }

  /* ── 状态 ───────────────────────────────────────────────────── */
  var state = { lang: 'zh-Hans', theme: 'dark' };

  function detectLang() {
    var fromUrl = new URLSearchParams(location.search).get('lang');
    if (fromUrl && I18N[fromUrl]) return fromUrl;
    var saved = null;
    try {
      saved = localStorage.getItem('free-clac-site-lang');
    } catch (err) {
      saved = null;
    }
    if (saved && I18N[saved]) return saved;

    var candidates = navigator.languages || [navigator.language || 'en'];
    for (var i = 0; i < candidates.length; i += 1) {
      var tag = String(candidates[i]).toLowerCase();
      if (tag.indexOf('zh') === 0) {
        return tag.indexOf('hant') >= 0 ||
          tag.indexOf('tw') >= 0 ||
          tag.indexOf('hk') >= 0 ||
          tag.indexOf('mo') >= 0
          ? 'zh-Hant'
          : 'zh-Hans';
      }
      if (tag.indexOf('ja') === 0) return 'ja';
      if (tag.indexOf('es') === 0) return 'es';
      if (tag.indexOf('en') === 0) return 'en';
    }
    return 'en';
  }

  function detectTheme() {
    var fromUrl = new URLSearchParams(location.search).get('theme');
    if (fromUrl === 'light' || fromUrl === 'dark') return fromUrl;
    var saved = null;
    try {
      saved = localStorage.getItem('free-clac-site-theme');
    } catch (err) {
      saved = null;
    }
    if (saved === 'light' || saved === 'dark') return saved;
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches
      ? 'light'
      : 'dark';
  }

  function store(key, value) {
    try {
      localStorage.setItem(key, value);
    } catch (err) {
      /* 隐私模式下写不了，忽略 */
    }
  }

  function syncUrl() {
    var params = new URLSearchParams(location.search);
    params.set('lang', state.lang);
    params.set('theme', state.theme);
    var next = location.pathname + '?' + params.toString() + location.hash;
    history.replaceState(null, '', next);
  }

  /* ── 渲染 ───────────────────────────────────────────────────── */
  function setSlot(name, value) {
    document.querySelectorAll('[data-slot="' + name + '"]').forEach(function (node) {
      node.innerHTML = '';
      node.textContent = value;
    });
  }

  function renderHeader(t) {
    var brand = $('#brand-name');
    if (brand) brand.textContent = t.brand;

    var nav = $('#nav');
    nav.setAttribute('aria-label', t.nav.features + ' / ' + t.nav.tools);
    nav.innerHTML = '';
    [
      ['#features', t.nav.features],
      ['#shots', t.nav.shots],
      ['#theme', t.nav.theme],
      ['#tools', t.nav.tools],
      ['#languages', t.nav.languages],
    ].forEach(function (entry) {
      nav.appendChild(h('a', { href: entry[0], text: entry[1] }));
    });
  }

  function renderHero(t, code) {
    setSlot('badge', t.hero.badge);
    var title = document.querySelector('[data-slot="title"]');
    if (title) title.innerHTML = t.hero.title;
    setSlot('lead', t.hero.lead);
    setSlot('cta-shots', t.hero.ctaShots);
    setSlot('cta-repo', t.hero.ctaRepo);
    setSlot('window-title', t.hero.windowTitle);

    var repo = $('#hero-repo');
    if (repo) repo.href = REPO;

    var stats = $('#hero-stats');
    stats.innerHTML = '';
    var toolCount = toolsFor(code).length;
    t.stats.forEach(function (item) {
      stats.appendChild(
        h('li', {}, [
          h('strong', { text: fill(item.value, { tools: toolCount }) }),
          h('span', { text: item.label }),
        ])
      );
    });
  }

  // 让图片能用鼠标和键盘打开灯箱（截图本身也是可交互内容，别只给鼠标用）
  function zoomable(node, src, caption) {
    node.setAttribute('tabindex', '0');
    node.setAttribute('role', 'button');
    node.setAttribute('aria-label', caption);
    node.addEventListener('click', function () {
      openLightbox(src, caption);
    });
    node.addEventListener('keydown', function (event) {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        openLightbox(src, caption);
      }
    });
    return node;
  }

  function renderFeatures(t) {
    setSlot('features-eyebrow', t.features.eyebrow);
    setSlot('features-title', t.features.title);
    setSlot('features-lead', t.features.lead);

    var grid = $('#feature-grid');
    grid.innerHTML = '';
    t.features.items.forEach(function (item) {
      grid.appendChild(
        h('article', { class: 'feature-card reveal' }, [
          h('span', { class: 'feature-badge', html: icon(item.icon) }),
          h('h3', { text: item.title }),
          h('p', { text: item.body }),
        ])
      );
    });
  }

  function renderShots(t, code) {
    setSlot('shots-eyebrow', t.shots.eyebrow);
    setSlot('shots-title', t.shots.title);
    setSlot('shots-lead', t.shots.lead);

    var grid = $('#shot-grid');
    grid.innerHTML = '';
    ['calculator', 'plot', 'heart', 'implicit', 'tools', 'settings'].forEach(function (key) {
      var meta = t.shots.items[key];
      var figure = h('figure', { class: 'shot-card reveal' }, [
        h('div', {
          class: 'shot-frame',
          'data-shot': code,
        }, []),
        h('figcaption', {}, [
          h('span', { class: 'shot-name', text: meta.name }),
          h('span', { class: 'shot-desc', text: meta.desc }),
        ]),
      ]);
      var image = h('img', {
        src: shotPath(code, key),
        alt: meta.name + ' — ' + meta.desc,
        loading: 'lazy',
      });
      zoomable(image, shotPath(code, key), meta.name + ' · ' + meta.desc);
      figure.firstChild.appendChild(image);
      grid.appendChild(figure);
    });

    setSlot('phone-title', t.shots.phoneTitle);
    setSlot('phone-lead', t.shots.phoneLead);
    var phone = $('#phone-shot');
    phone.src = shotPath(code, 'mobile');
    phone.alt = t.shots.phoneTitle;
    zoomable(phone, shotPath(code, 'mobile'), t.shots.phoneTitle);
  }

  function renderTheme(t, code) {
    setSlot('theme-eyebrow', t.theme.eyebrow);
    setSlot('theme-title', t.theme.title);
    setSlot('theme-lead', t.theme.lead);

    var pair = $('#theme-pair');
    pair.innerHTML = '';
    [
      ['calculator', t.theme.dark, 'dark'],
      ['calculator-light', t.theme.light, 'light'],
    ].forEach(function (entry) {
      var figure = h('figure', { class: 'theme-card reveal' }, [
        h('figcaption', {}, [
          h('span', { class: 'theme-dot theme-dot-' + entry[2] }),
          h('span', { text: entry[1] }),
        ]),
      ]);
      var image = h('img', {
        src: shotPath(code, entry[0]),
        alt: t.hero.windowTitle + ' — ' + entry[1],
        loading: 'lazy',
      });
      zoomable(image, shotPath(code, entry[0]), t.hero.windowTitle + ' · ' + entry[1]);
      figure.appendChild(image);
      pair.appendChild(figure);
    });
  }

  function renderTools(t, code) {
    setSlot('tools-eyebrow', t.toolsSection.eyebrow);
    var tools = toolsFor(code);
    setSlot('tools-title', fill(t.toolsSection.title, { tools: tools.length }));
    setSlot('tools-lead', t.toolsSection.lead);
    setSlot('tools-hint', t.toolsSection.hint);

    var grid = $('#tool-grid');
    grid.innerHTML = '';
    tools.forEach(function (tool) {
      var text = tool.text[code] || tool.text.en || tool.text['zh-Hans'];
      var colors = tool.color || {};
      var card = h(
        'figure',
        {
          class: 'tool-card reveal',
          style:
            '--accent-dark:' +
            (colors.dark || '#4F9CFF') +
            ';--accent-light:' +
            (colors.light || '#1F6FEB') +
            ';',
        },
        [
          h('div', { class: 'tool-shot' }, [
            h('img', {
              src: shotPath(code, tool.id),
              alt: text.name,
              loading: 'lazy',
            }),
          ]),
          h('figcaption', {}, [
            h('h3', { text: text.name }),
            h('p', { class: 'tool-tagline', text: text.tagline }),
          ]),
        ]
      );
      var image = card.querySelector('img');
      zoomable(image, shotPath(code, tool.id), text.name + ' — ' + text.tagline);
      grid.appendChild(card);
    });

    var note = document.querySelector('[data-slot="tools-note"]');
    if (!note) {
      note = h('p', { class: 'hint', 'data-slot': 'tools-note' });
      var head = $('#tools .section-head');
      if (head) head.appendChild(note);
    }
    note.textContent = t.toolsSection.note;
  }

  function renderLanguages(t) {
    setSlot('languages-eyebrow', t.languages.eyebrow);
    setSlot('languages-title', t.languages.title);
    setSlot('languages-lead', t.languages.lead);

    var grid = $('#language-grid');
    grid.innerHTML = '';
    LANGS.forEach(function (lang) {
      var active = lang.code === state.lang;
      var card = h(
        'button',
        {
          type: 'button',
          class: 'language-card reveal' + (active ? ' is-active' : ''),
          'aria-pressed': active ? 'true' : 'false',
          'data-lang': lang.code,
        },
        [
          h('span', { class: 'language-label', text: lang.label }),
          h('span', {
            class: 'language-sample',
            text: I18N[lang.code].brand,
          }),
          active ? h('span', { class: 'language-current', text: t.languages.current }) : null,
        ]
      );
      card.addEventListener('click', function () {
        applyLang(lang.code);
      });
      grid.appendChild(card);
    });

    var note = document.querySelector('[data-slot="languages-note"]');
    if (!note) {
      note = h('p', { class: 'hint', 'data-slot': 'languages-note' });
      var head = $('#languages .section-head');
      if (head) head.appendChild(note);
    }
    note.textContent = t.languages.note;
  }

  function renderFooter(t) {
    setSlot('footer-brand', t.footer.note && t.brand);
    setSlot('footer-note', t.footer.note);
    setSlot('footer-repo', t.footer.repo);
    setSlot('footer-docs', t.footer.docs);
    setSlot('footer-license', t.footer.license);
  }

  function renderMeta(t, lang) {
    document.title = t.title;
    document.documentElement.lang = lang.htmlLang;
    var desc = document.querySelector('meta[name="description"]');
    if (desc) desc.setAttribute('content', t.description);
    var ogTitle = document.querySelector('meta[property="og:title"]');
    if (ogTitle) ogTitle.setAttribute('content', t.title);
    var ogDesc = document.querySelector('meta[property="og:description"]');
    if (ogDesc) ogDesc.setAttribute('content', t.description);
    var ogImage = document.querySelector('meta[property="og:image"]');
    if (ogImage) ogImage.setAttribute('content', shotPath(state.lang, 'calculator'));
  }

  function render() {
    var lang = LANGS.filter(function (item) {
      return item.code === state.lang;
    })[0];
    var t = I18N[state.lang];
    var code = state.lang;

    state.lang = code;
    renderMeta(t, lang);
    renderHeader(t);
    renderHero(t, code);
    renderFeatures(t);
    renderShots(t, code);
    renderTheme(t, code);
    renderTools(t, code);
    renderLanguages(t);
    renderFooter(t);

    var select = $('#lang-select');
    if (select) select.value = code;
    var skip = document.querySelector('.skip-link');
    if (skip) skip.textContent = t.skip;

    refreshReveal();
  }

  /* ── 主题 ───────────────────────────────────────────────────── */
  function applyTheme(theme) {
    state.theme = theme;
    document.documentElement.setAttribute('data-theme', theme);
    store('free-clac-site-theme', theme);
    var button = $('#theme-toggle');
    if (button) {
      button.innerHTML =
        '<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" ' +
        'stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">' +
        (theme === 'dark'
          ? '<circle cx="12" cy="12" r="4.2"/><path d="M12 2.6v2.2M12 19.2v2.2M21.4 12h-2.2M4.8 12H2.6M18.6 5.4l-1.6 1.6M7 17l-1.6 1.6M18.6 18.6 17 17M7 7 5.4 5.4"/>'
          : '<path d="M20.5 14.2A8.5 8.5 0 1 1 9.8 3.5a6.8 6.8 0 0 0 10.7 10.7Z"/>') +
        '</svg>';
    }
    var hero = $('#hero-shot');
    if (hero) {
      hero.src = shotPath(state.lang, theme === 'light' ? 'calculator-light' : 'calculator');
      hero.alt = I18N[state.lang].hero.windowTitle;
    }
    syncUrl();
  }

  /* ── 灯箱 ───────────────────────────────────────────────────── */
  var lightbox = $('#lightbox');

  var lastFocused = null;

  function openLightbox(src, caption) {
    lastFocused = document.activeElement;
    $('#lightbox-image').src = src;
    $('#lightbox-image').alt = caption || '';
    $('#lightbox-caption').textContent = caption || '';
    lightbox.hidden = false;
    document.body.classList.add('is-locked');
    $('#lightbox-close').focus();
  }

  function closeLightbox() {
    lightbox.hidden = true;
    $('#lightbox-image').removeAttribute('src');
    document.body.classList.remove('is-locked');
    if (lastFocused && lastFocused.focus) lastFocused.focus();
    lastFocused = null;
  }

  /* ── 入场动画 ───────────────────────────────────────────────── */
  var observer = null;

  function refreshReveal() {
    var nodes = document.querySelectorAll('.reveal');
    if (!('IntersectionObserver' in window)) {
      nodes.forEach(function (node) {
        node.classList.add('is-in');
      });
      return;
    }
    if (!observer) {
      observer = new IntersectionObserver(
        function (entries) {
          entries.forEach(function (entry) {
            if (entry.isIntersecting) {
              entry.target.classList.add('is-in');
              observer.unobserve(entry.target);
            }
          });
        },
        { rootMargin: '0px 0px -8% 0px', threshold: 0.05 }
      );
    }
    nodes.forEach(function (node) {
      if (node.classList.contains('is-in')) return;
      observer.observe(node);
    });
  }

  /* ── 语言切换 ───────────────────────────────────────────────── */
  function applyLang(code) {
    if (!I18N[code]) return;
    state.lang = code;
    store('free-clac-site-lang', code);
    render();
    applyTheme(state.theme);
    syncUrl();
  }

  /* ── 初始化 ─────────────────────────────────────────────────── */
  function init() {
    state.lang = detectLang();

    var select = $('#lang-select');
    LANGS.forEach(function (lang) {
      select.appendChild(h('option', { value: lang.code, text: lang.label }));
    });
    select.addEventListener('change', function () {
      applyLang(select.value);
    });

    $('#theme-toggle').addEventListener('click', function () {
      applyTheme(state.theme === 'dark' ? 'light' : 'dark');
    });

    $('#lightbox-close').addEventListener('click', closeLightbox);
    lightbox.addEventListener('click', function (event) {
      if (event.target === lightbox) closeLightbox();
    });
    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape' && !lightbox.hidden) closeLightbox();
    });

    // 顶栏滚动后加一点阴影，避免和内容糊在一起
    var topbar = document.querySelector('.topbar');
    window.addEventListener(
      'scroll',
      function () {
        topbar.classList.toggle('is-scrolled', window.scrollY > 8);
      },
      { passive: true }
    );

    render();
    applyTheme(detectTheme());
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
