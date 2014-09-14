Pod::Spec.new do |s|
  s.name             = "TBStateMachine"
  s.version          = "2.0.1"
  s.summary          = "A lightweight implementation of a hierarchical state machine in Objective-C."
  s.description      = <<-DESC
                       A lightweight implementation of a hierarchical state machine in Objective-C.
                       
                       DESC
  s.homepage         = "https://github.com/tarbrain/TBStateMachine"
  s.license          = 'MIT'
  s.author           = { "Julian Krumow" => "julian.krumow@tarbrain.com" }
  s.source           = { :git => "https://github.com/tarbrain/TBStateMachine.git", :tag => s.version.to_s }

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

end
