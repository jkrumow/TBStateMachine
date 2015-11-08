Pod::Spec.new do |s|
  s.name             = "TBStateMachine"
  s.version          = "5.8.1"
  s.summary          = "A lightweight hierarchical state machine framework in Objective-C."
  s.description      = <<-DESC
                       Supports all common features of a UML state machine like:

                       - nested states
                       - orthogonal regions
                       - pseudo states
                       - transitions with guards and actions
                       - state switching using least common ancestor algorithm and run-to-completion model
                       DESC
  s.homepage         = "https://github.com/tarbrain/TBStateMachine"
  s.license          = 'MIT'
  s.author           = { "Julian Krumow" => "julian.krumow@tarbrain.com" }

  s.ios.deployment_target = '5.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.7'

  s.requires_arc = true
  s.source = { :git => "https://github.com/tarbrain/TBStateMachine.git", :tag => s.version.to_s }

  s.default_subspec = 'Core'
  s.subspec 'Core' do |core|
    core.source_files = 'Pod/Core'
  end

  s.subspec 'DebugSupport' do |debug|
    debug.source_files = "Pod/DebugSupport"
    debug.dependency 'TBStateMachine/Core'
  end
end
