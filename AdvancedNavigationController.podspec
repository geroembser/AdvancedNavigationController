Pod::Spec.new do |s|
s.name = 'AdvancedNavigationController'
s.version = '1.1'
s.author = 'Gero Embser'
s.homepage = 'https://github.com/geroembser/AdvancedNavigationController'
s.license = { :type => 'MIT', :file => 'LICENSE' }

s.summary = 'An advanced UINavigationController with very few advanced features...'

s.source = { :git => 'https://github.com/geroembser/AdvancedNavigationController.git', :tag => s.version }

s.ios.deployment_target = '12.0'
s.swift_version = '4.2'

#define the source files
s.source_files = 'Source/*.swift'

end
