cd Example
bundle exec slather coverage --html --output-directory ../reports/coverage/ --ignore "Tests/"\* --ignore Pods/\* --scheme TBStateMachineTests --workspace TBStateMachine.xcworkspace/ TBStateMachine.xcodeproj/
cd ..
open reports/coverage/index.html