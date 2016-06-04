Pod::Spec.new do |s|
  s.name             = "RxVisualDebugger"
  s.version          = "0.1"
  s.summary          = "Swift Visual Debugger"
  s.description      = <<-DESC
			Swift Visual Debugger
                        DESC
  s.homepage         = "https://github.com/RxSwiftCommunity/RxVisualDebugger"
  s.license          = 'MIT'
  s.author           = { "Marin Todorov" => "touch-code-magazine@underplot.com" }
  s.source           = { :git => "https://github.com/RxSwiftCommunity/RxVisualDebugger", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files          = 'Sources/**/*.swift', 'Sources/**/*.html', 'Sources/**/*.css', 'Sources/**/*.js'

  s.dependency 'RxSwift', '~> 2.2'
  s.dependency 'Swifter'
end

