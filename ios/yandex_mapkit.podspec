Pod::Spec.new do |s|
  variant = ENV['YANDEX_MAPKIT_VARIANT'] || 'lite'

  s.name             = 'yandex_mapkit'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = 'A new flutter plugin project.'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.static_framework = true
  s.dependency 'Flutter'

  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => "$(inherited) -D YANDEX_MAPKIT_#{variant.upcase}"
  }
  s.dependency 'YandexMapsMobile', "4.39.1-#{variant}"
  s.source_files = [
    'yandex_mapkit/Sources/yandex_mapkit/*',
    'yandex_mapkit/Sources/yandex_mapkit/lite/*'
  ]

  if variant == 'full'
    s.source_files = [
      'yandex_mapkit/Sources/yandex_mapkit/*',
      'yandex_mapkit/Sources/yandex_mapkit/lite/*',
      'yandex_mapkit/Sources/yandex_mapkit/full/*'
    ]
  end

  s.ios.deployment_target = '15.0'
end
