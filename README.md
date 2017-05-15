# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Build Status](https://img.shields.io/travis/jkrumow/TBStateMachine/master.svg?style=flat)](https://travis-ci.org/jkrumow/TBStateMachine)


A lightweight hierarchical state machine framework in Objective-C.

## Features

* Block based API
* Nested states
* Orthogonal regions
* Pseudo states (fork, join and junction)
* External, internal and local transitions with guards and actions
* State switching using least common ancestor algorithm (LCA)
* Thread safe event handling
* Asynchronous event handling
* NSNotificationCenter support

![Features](https://raw.githubusercontent.com/jkrumow/TBStateMachine/master/Documentation/test_setup.png)

## Requirements

* watchOS 2.0
* tvOS 9.0
* iOS 6.0
* OS X 10.8

## Installation

TBStateMachine is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TBStateMachine'
```

## Usage

### Configuration

```objc
#import <TBStateMachine/TBSMStateMachine.h>
```

Create a state, set enter and exit blocks:

```objc
TBSMState *stateA = [TBSMState stateWithName:@"StateA"];
stateA.enterBlock = ^(id data) {

};
    
stateA.exitBlock = ^(id data) {

};
```

Create a state machine:

```objc
TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:@"Main"];
```

Add states and set state machine up. The state machine will always set the first state in the given array as the initial state unless you set the initial state explicitly:

```objc
stateMachine.states = @[stateA, stateB, ...];
stateMachine.initialState = stateB;
[stateMachine setUp:nil];
```

### Event Handling

You can add event handlers which trigger transitions to specified target states:

```objc
[stateA addHandlerForEvent:@"EventA" target:stateB];
```

You can also add event handlers with additional action and guard blocks:

```objc

TBSMActionBlock action = ^(id data) {

};

TBSMGuardBlock guard = ^BOOL(id data) {

    return YES;
};

[stateA addHandlerForEvent:@"EventA" target:stateB kind:TBSMTransitionExternal action:action guard:guard];
```

If you register multiple handlers for the same event the guard blocks decide which transition will be fired.

#### Different Kinds of Transitions

By default transitions are external. To define a transition kind explicitly choose one of the three kind attributes:

```
TBSMTransitionExternal
TBSMTransitionInternal
TBSMTransitionLocal
```

#### Scheduling Events

To schedule the event call `scheduleEvent:` and pass the specified `TBSMEvent` instance and (optionally) an object as payload:

```objc
TBSMEvent *event = [TBSMEvent eventWithName:@"EventA" data:aPayloadObject];
[stateMachine scheduleEvent:event];
```

The payload will be available in all action, guard, enter and exit blocks which are executed until the event is successfully handled.

#### Run-to-Completion

Event processing follows the Run-to-Completion model to ensure that only one event will be handled at a time. A single RTC-step encapsulates the whole logic from evaluating the event to performing the transition to executing guards, actions, exit and enter blocks.

Events will be queued and processed one after the other.

### Nested States

`TBSMState` instances can also be nested by using `TBSMSubState`:

```objc
TBSMSubState *subState = [TBSMSubState subStateWithName:@"SubState"];
substate.stateMachine = subMachine;

stateMachine.states = @[stateA, stateB, subState];
```

You can also register events, add enter and exit blocks on `TBSMSubState`, since it is a subtype of `TBSMState`.

### Orthogonal Regions

To build orthogonal regions you will use `TBSMParallelState`:

```objc
TBSMParallelState *parallel = [TBSMParallelState parallelStateWithName:@"ParallelState"];
parallel.stateMachines = @[subMachineA, subMachineB, subMachineC];
    
stateMachine.states = @[stateA, stateB, parallel];
```

### Pseudo States

TBStateMachine supports fork and join pseudo states to construct compound transitions:

#### Fork

```objc
TBSMFork *fork = [TBSMFork forkWithName:@"fork"];
[stateA addHandlerForEvent:@"EventA" target:fork];
[fork setTargetStates:@[stateB, stateC] inRegion:parallel];
```

#### Join

```objc
TBSMJoin *join = [TBSMJoin joinWithName:@"join"];
[stateA addHandlerForEvent:@"EventA" target:join];
[stateB addHandlerForEvent:@"EventB" target:join];
[join setSourceStates:@[stateA, stateB] inRegion:parallel target:stateC];
```

#### Junction

```objc
TBSMJunction *junction = [TBSMJunction junctionWithName:@"junction"];
[stateA addHandlerForEvent:@"EventA" target:junction];
[junction addOutgoingPathWithTarget:stateB action:nil guard:^BOOL(id data) {
    
    return // ...
}];
[junction addOutgoingPathWithTarget:stateC action:nil guard:^BOOL(id data) {
    
    return // ...
}];
```

### Notifications

`TBSMState` posts NSNotifications on entry and exit:

* TBSMStateDidEnterNotification
* TBSMStateDidExitNotification

The notification's `userInfo` contains:

```objc
{
    TBSMDataUserInfo:theData
}
```

To receive a notification:

```objc
[[NSNotificationCenter defaultCenter] addObserver:myObject selector:@selector(myHandler:) name:TBSMStateDidEnterNotification object:stateA];

- (void)myHandler:(NSNotification *)notification
{
    id myPayloadObject = notification.userInfo[TBSMDataUserInfo];
}
```

### Thread Safety and Concurrency

`TBStateMachine` is thread safe. Each event is processed asynchronously on the main queue by default. This makes handling of UIKit components convenient.

To use a dedicated background queue simply set:

```objc
NSOperationQueue *queue = [NSOperationQueue new];
queue.name = @"com.myproject.queue";
queue.maxConcurrentOperationCount = 1;
stateMachine.scheduledEventsQueue = queue;
```

### Debug Support

`TBStateMachine` offers debug support through the subspec `DebugSupport`. Simply add it to your `Podfile` (most likely to a beta target to keep it out of production code):

```ruby
target 'MyBetaApp', :exclusive => true do
  pod 'TBStateMachine/DebugSupport'
end
```

Then include `TBSMDebugger.h` to the debug the state machine **at the top of the hierarchy**:

```objc
#import <TBStateMachine/TBSMDebugger.h>

[[TBSMDebugger sharedInstance] debugStateMachine:stateMachine];
```

The statemachine will then output a log message for every event, transition, setup, teardown, enter and exit including the duration of the performed Run-to-Completion step:

```
[Main]: will handle event 'EventA' data: 12345
[Main] attempt to perform transition: stateA --> stateCc data: 12345
    Exit 'stateB' data: 12345
    Enter 'stateC' data: 12345
    Enter 'stateCc' data: 12345
[Main]: run-to-completion step took 1.15 milliseconds
[Main]: remaining events in queue: 0
```

When calling `-activeStateConfiguration` on the debugger instance you will get the current active state configuration of the whole hierarchy:

```objc
NSLog(@"%@", [[TBSMDebugger sharedInstance] activeStateConfiguration]);
```

```
Main
    stateC
        subMachineC
            stateCc
```

## Development Setup

Clone the repo and run `pod install` from the `Example` directory first. The project contains a unit test target for development.

## Useful Theory on UML State Machines

- http://en.wikipedia.org/wiki/UML_state_machine
- http://www.omg.org/spec/UML/2.5/Beta2/

## Author

Julian Krumow, julian.krumow@bogusmachine.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.
