# TBStateMachine

[![Version](https://img.shields.io/cocoapods/v/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![License](https://img.shields.io/cocoapods/l/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Platform](https://img.shields.io/cocoapods/p/TBStateMachine.svg?style=flat)](http://cocoadocs.org/docsets/TBStateMachine)
[![Build Status](https://travis-ci.org/tarbrain/TBStateMachine.svg?branch=master)](https://travis-ci.org/tarbrain/TBStateMachine)

A lightweight event-driven hierarchical state machine implementation in Objective-C.

## Features

* lightweight implementation
* thread safe event handling and switching
* nested state machines
* wrapper for parallel states and state machines
* block based API

## Example Project

To run the example project, clone the repo, and run `pod install` from the `Example` directory first.

## Requirements

* Xcode 5
* iOS 5.0
* OS X 10.7

## Installation

TBStateMachine is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TBStateMachine"

## Usage

### Configuration

Create state objects, set enter and exit blocks and register event handlers:

```objective-c
TBStateMachineState *stateA = [TBStateMachineState stateWithName:@"StateA"];
stateA.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
        
    // ...
       
};
    
stateA.exitBlock = ^(TBStateMachineState *nextState, NSDictionary *data) {
        
    // ...
       
};
```

Create a state machine instance:

```objective-c
TBStateMachine *stateMachine = [TBStateMachine stateMachineWithName:@"StateMachine"];
```

Add states and set state machine up:

```objective-c
stateMachine.states = @[stateA, stateB, ...];
stateMachine.initialState = stateA;
[stateMachine setup];
```

The state machine will immediately enter the initial state.

### Switching States

Register an event handler which returns a valid node:

```objective-c
[stateA registerEvent:eventA handler:^id<TBStateMachineNode> (TBStateMachineEvent *event, NSDictionary *data) {

    // the follow-up node or nil
    return stateB;
}];
```

Send the event:

```objective-c
NSValue *frame = [NSValue valueWithCGRect:CGRectMake(0.0, 0.0,100.0, 50.0)];
NSDictionary *payload = @{@"text" : @"abcdef", @"frame", frame};
TBStateMachineEvent *eventA = [TBStateMachineEvent eventWithName:@"EventA"];
[stateMachine handleEvent:eventA data:payload];
```

### Sub-State Machines

TBStateMachine instances can also be nested as sub-state machines. Instead of a `TBMachineStateState` instance you can set a `TBStateMachine` instance:

```objective-c
TBStateMachine *subStateMachine = [TBStateMachine stateMachineWithName:@"SubStateMachine"];
subStateMachine.states = @[stateC, stateD];
subStateMachine.initialState = stateC;

stateMachine.states = @[stateA, stateB, subStateMachine];
```

You do not need to call `- (void)setup` and `- (void)tearDown` on the sub-state machine since these methods will be called by the super-state machine.

### Parallel States and State Machines

To run multiple states and sub-state machines in parallel you will use the `TBStateMachineParallelWrapper`:

```objective-c
TBStateMachineParallelWrapper *parallelWrapper = [TBStateMachineParallelWrapper parallelWrapperWithName:@"ParallelWrapper"];
parallelWrapper.states = @[subStateMachineA, subStateMachineB, stateZ];
    
stateMachine.states = @[stateA, stateB, parallelWrapper];
```

### Concurrency

Event handlers, enter and exit handlers will be executed on a background queue. Make sure the code in these blocks is dispatched back onto the right queue:

```objective-c
stateZ.enterBlock = ^(TBStateMachineState *previousState, NSDictionary *data) {
    
    // evaluate payload data
    NSString *text = data[@"text"];
    NSValue *frameValue = data[@"frame"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        CGRect frame = [frameValue CGRectValue];
        UILabel *label = [[UILabel alloc]initWithFrame:frame)];
        label.text = text;
    
    });
       
};
```


## Author

Julian Krumow, julian.krumow@tarbrain.com

## License

TBStateMachine is available under the MIT license. See the LICENSE file for more info.

