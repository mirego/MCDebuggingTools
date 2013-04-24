Pod::Spec.new do |s|
  s.name     = 'MCDebuggingTools'
  s.version  = '0.5.0'
  s.license  = 'BSD 3-Clause'
  s.summary  = 'Various debugging tools to make your life easier.'
  s.homepage = 'https://github.com/mirego/MCDebuggingTools.git'
  s.authors  = { 'Mirego' => 'info@mirego.com' }
  s.source   = { :git => 'https://github.com/mirego/MCDebuggingTools.git', :tag => s.version }
  s.source_files = 'MCDebuggingTools/*.{h,m}'
  s.requires_arc = true

  s.platform = :ios, '5.0'
end
