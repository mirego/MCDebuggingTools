Pod::Spec.new do |s|
  s.name     = 'MCDebuggingTools'
  s.version  = '0.1.0'
  s.license  = 'BSD 3-Clause'
  s.summary  = 'Various debugging tools to make your life easier.'
  s.homepage = 'https://github.com/mirego/MCDebuggingTools.iOS.git'
  s.authors  = { 'Mirego, Inc.' => 'info@mirego.com' }
  s.source   = { :git => 'https://github.com/mirego/MCDebuggingTools.iOS.git', :tag => '0.1.0' }
  s.source_files = 'MCDebuggingTools/*.{h,m}'
  s.requires_arc = true
  
  s.platform = :ios, '5.0'
end
