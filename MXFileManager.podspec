
Pod::Spec.new do |s|
  s.name         = 'MXFileManager'
  s.version      = '2.0.0'
  s.summary      = 'iOS 沙盒文件创建与管理'

  s.description  = <<-DESC
                    1.缓存文件创建与管理
                    2.临时文件创建与管理
                   DESC

  s.homepage     = 'https://github.com/kuroky/MXFileManager.git'

  s.license      = 'MIT'

  s.author             = { 'kuroky' => 'kuro2007cumt@gmail.com' }
  
  s.platform     = :ios, '10.0'

  s.ios.deployment_target = '10.0'

  s.source       = { :git => 'https://github.com/kuroky/MXFileManager.git', :tag => '#{s.version}' }
  s.swift_version = '5.0'

  s.source_files  = 'MXFileManager/**/*.swift'

  s.requires_arc = true

end
