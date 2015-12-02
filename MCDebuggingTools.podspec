Pod::Spec.new do |s|
  s.name     = 'MCDebuggingTools'
  s.version  = '1.0'
  s.license  = 'BSD 3-Clause'
  s.summary  = 'Various debugging tools to make your life easier.'
  s.homepage = 'https://github.com/mirego/MCDebuggingTools'
  s.authors  = { 'Mirego' => 'info@mirego.com' }
  s.source   = { :git => 'https://github.com/mirego/MCDebuggingTools.git', :tag => s.version.to_s }
  s.requires_arc = true

  s.ios.deployment_target = '6.0'
  s.tvos.deployment_target = '9.0'

  s.subspec 'MemoryWarningGenerator' do |ss|
    ss.source_files = 'MCDebuggingTools/MCMemoryWarningGenerator/**/*.{h,m}'
    ss.ios.deployment_target = '6.0'
    ss.tvos.deployment_target = '9.0'
  end

  s.subspec 'ServerEnvironment' do |ss|
    ss.source_files = 'MCDebuggingTools/MCServerEnvironment/**/*.{h,m}'
    ss.ios.deployment_target = '6.0'
  end
end
