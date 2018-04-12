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
TBSMState *a = [TBSMState stateWithName:@"a"];
a.enterBlock = ^(id data) {

};
    
a.exitBlock = ^(id data) {

};
```

Create a state machine:

```objc
TBSMStateMachine *stateMachine = [TBSMStateMachine stateMachineWithName:@"main"];
```

Add states and set state machine up. The state machine will always set the first state in the given array as the initial state unless you set the initial state explicitly:

```objc
stateMachine.states = @[a, b, ...];
stateMachine.initialState = a;
[stateMachine setUp:nil];
```

### Event Handling

You can add event handlers which trigger transitions to specified target states:

```objc
[a addHandlerForEvent:@"transition_1" target:b];
```

You can also add event handlers with additional action and guard blocks:

```objc

TBSMActionBlock action = ^(id data) {

};

TBSMGuardBlock guard = ^BOOL(id data) {

    return YES;
};

[a addHandlerForEvent:@"transition_1" target:b kind:TBSMTransitionExternal action:action guard:guard];
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
TBSMEvent *event = [TBSMEvent eventWithName:@"transition_1" data:aPayloadObject];
[stateMachine scheduleEvent:event];
```

The payload will be available in all action, guard, enter and exit blocks which are executed until the event is successfully handled.

### Enumerating events

If you do not want to write string contants for every event like this:

```objc
FOUNDATION_EXPORT NSString * const Transition_1;

NSString * const Transition_1 = @"transition_1";
```

you can use a struct:

```objc
FOUNDATION_EXPORT const struct StateMachineEvents {
    __unsafe_unretained NSString *Transition_1;
    __unsafe_unretained NSString *Transition_2;
} StateMachineEvents;

const struct StateMachineEvents StateMachineEvents = {
    .Transition_1 = @"transition_1",
    .Transition_2 = @"transition_2"
};
```

or you can also create a special enumeration type `StateMachineEvents `:

```objc
typedef NS_ENUM(NSInteger, StateMachineEvents) {
    Transition_1,
    Transition_2
};
```

And access them using a macro of the same name:

```objc
[stateMachine scheduleEventNamed:StateMachineEvents(Transition_1) data:aPayloadObject];
```

#### Run-to-Completion

Event processing follows the Run-to-Completion model to ensure that only one event will be handled at a time. A single RTC-step encapsulates the whole logic from evaluating the event to performing the transition to executing guards, actions, exit and enter blocks.

Events will be queued and processed one after the other.

### Nested States

`TBSMState` instances can also be nested by using `TBSMSubState`:

```objc
TBSMSubState *b2 = [TBSMSubState subStateWithName:@"b2"];
b2.states = @[b21, b22];
```

You can also register events, add enter and exit blocks on `TBSMSubState`, since it is a subtype of `TBSMState`.

### Orthogonal Regions

To build orthogonal regions you will use `TBSMParallelState`:

```objc
TBSMParallelState *b3 = [TBSMParallelState parallelStateWithName:@"b3"];
b3.states = @[@[b311, b312], @[b321, b322]];
```

### Pseudo States

TBStateMachine supports fork and join pseudo states to construct compound transitions:

#### Fork

```objc
TBSMFork *fork = [TBSMFork forkWithName:@"fork"];
[a addHandlerForEvent:@"transition_15" target:fork];
[fork setTargetStates:@[c212, c222] inRegion:c2];
```

#### Join

```objc
TBSMJoin *join = [TBSMJoin joinWithName:@"join"];
[c212 addHandlerForEvent:@"transition_16" target:join];
[c222 addHandlerForEvent:@"transition_17" target:join];
[join setSourceStates:@[c212, c222] inRegion:c2 target:b];
```

#### Junction

```objc
TBSMJunction *junction = [TBSMJunction junctionWithName:@"junction"];
[a addHandlerForEvent:@"transition_18" target:junction];
[junction addOutgoingPathWithTarget:b1 action:nil guard:^BOOL(id data) {
    return (data[@"goB1"]);
}];
[junction addOutgoingPathWithTarget:c2 action:nil guard:^BOOL(id data) {
    return (data[@"goC2"]);
}];
```

### Notifications

`TBSMState` posts an `NSNotification` on entry and exit:

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
[self.stateMachine subscribeToEntryAtPath:@"c/c2@1/c222" forObserver:self selector:@selector(myHandler:)];
[self.stateMachine subscribeToExitAtPath:@"c/c2@1/c222" forObserver:self selector:@selector(myHandler:)];

- (void)myHandler:(NSNotification *)notification
{
    id myPayloadObject = notification.userInfo[TBSMDataUserInfo];
}
```

`TBSMState` also posts an `NSNotification` with the event name when an internal transition has been performed:

```objc
[self.stateMachine subscribeToAction:@"transition_10" atPath:@"a/a1" forObserver:self selector:@selector(myHandler:)];
```

To locate a specified state inside the hierarchy you can use the path scheme seen above. The path consists of names of the states separated by slashes:

```
b/b2/b21
```

In orthogonal regions an `@` sign and an index is added to select the particular child region:

```
c/c2@1/c222
```

### Configuration Files

A state machine can be configured via json file and built by `TBSMStateMachineBuilder`:

```objc
NSString *path = // path to file
TBMSStateMachine *stateMachine = [TBSMStateMachineBuilder buildFromFile:path];
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
[Main]: attempt to handle event 'transition_4' data: 12345
[stateA] will handle event 'transition_4' data: 12345
[Main] performing transition: stateA --> stateCc data: 12345
    Exit 'a3' data: 12345
    Exit 'a' data: 12345
    Enter 'b' data: 12345
    Enter 'b2' data: 12345
    Enter 'b21' data: 12345
[Main]: run-to-completion step took 1.15 milliseconds
[Main]: remaining events in queue: 1
[Main]: (
    transition_8
)
```

When calling `-activeStateConfiguration` on the debugger instance you will get the current active state configuration of the whole hierarchy:

```objc
NSLog(@"%@", [[TBSMDebugger sharedInstance] activeStateConfiguration]);
```

```
Main
    b
        bSubMachine
            b2
            	b2Submachine
            		b21
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
