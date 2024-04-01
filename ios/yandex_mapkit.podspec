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
  s.public_header_files = 'Classes/**/*.h'
  s.static_framework = true
  s.dependency 'Flutter'

  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => "$(inherited) -D YANDEX_MAPKIT_#{variant.upcase}"
  }
  s.dependency 'YandexMapsMobile', "4.5.1-#{variant}"
  s.source_files = [
    'Classes/*',
    'Classes/lite/*'
  ]

  if variant == 'full'
    s.source_files = [
      'Classes/*',
      'Classes/lite/*',
      'Classes/full/*'
    ]
  end

  s.ios.deployment_target = '12.0'
end
