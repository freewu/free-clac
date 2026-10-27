{{flutter_js}}
{{flutter_build_config}}

// 字体回退文件放在 web/fonts/（`just web-fonts` 生成，已 gitignore），
// 让 CanvasKit 从本地取 Roboto / Noto Sans SC，断网或内网环境也能正常显示，
// 不会去 fonts.gstatic.com 拉取。
_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: "fonts/",
  },
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}} /* Flutter 的 service worker 已废弃 */,
  },
});
