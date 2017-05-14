# TBStateMachine CHANGELOG

## 6.3.0

- Added TBSMDebugger to DebugSupport subspec for clearer debug API

## 6.2.0

- Additional debug output for remaining events in queue

## 6.1.2

- Minor bugfixes

## 6.1.1

- Minor bugfixes

## 6.1.0

- Add asynchronous logging to `DebugSupport` to prevent logging from affecting performance measuring too much.

## 6.0.0

- Remove parameters `sourceState` and `targetState` from handlers and notification user info to simplify API.

## 5.15.0

- Cleanup interfaces for class methods. Using instancetype now.

## 5.12.0

- Remove superfluous factory methods

## 5.11.0

- Rework nullability by using audited regions

## 5.10.0

- Add nullability annotations and generics for improved Swift compatibility to sub spec `DebugSupport`

## 5.9.0

- Bugfixes

## 5.8.2

- Bugfixes

## 5.8.1

- Add nullability annotations and generics for improved Swift compatibility

## 5.8.0

- Add convenience method `scheduleEventNamed:data:`

## 5.7.0

- Add support for tvOS 9.0

## 5.6.0

- changed payload from `NSDictionary` to id

## 5.5.0

- add support for watchOS 2

## 5.4.2

- general house keeping and cleanup
- upadated documentation

## 5.4.1

- using mach_time instead of `CACurrentMediaTime` for time measurement

## 5.4.0

- added junction pseudo state

## 5.3.3

- simplified debug support code

## 5.3.2

- fixed a bug which caused a join transition to be triggered before all source transitions were performed

## 5.3.1

- fixed a bug which caused a statemachine to perform a compound transition when the event handler's target was 'nil'

## 5.3.0

- support for pseudo states
- implementation of fork and join pseudo states
- optional `DebugSupport` subspec for logging and performance measurements

## 5.2.1

- minor fixes

## 5.2.0

- improved error messages

## 5.1.0

- thread safety increased
- event scheduling is asynchronuous now
- simplified notification generation
- removed event deferral

## 5.0.0

- clear separation between transition types external, local, internal when registering events
- local transitions
- added notifications for enter and exit handlers
- remove option for concurrent queue in `TBSMParallelState`
- renamed `-registerEvent:` to `-addHandlerForEvent:`
- improved thread safety

## 4.4.0

- made changes to `TBSMStateMachine` so TBSMState class and subtypes can be inherited

## 4.3.0

- made concurrent queue in `TBSMParallelState` optional

## 4.2.0

- states can register multiple event handlers for the same event, guard block decides which one gets executed

## 4.1.0

- fixed bug which caused `TBSMParallelState` not to setup all sub machines when performing transition into one state machine
- fixed a bug which caused events not to bubble up to super states when not being handled by a sub state
- reworked event handling and state switching

## 4.0.1

- corrected event deferral algorithm

## 4.0.0

- corrected event deferral algorithm
- changed event registration / deferral API

## 3.1.0

- added internal transitions
- added event deferral
- removed method `-unregisterEvent:` from class `TBSMState`
- renamed property `states` to `stateMachines` in class `TBSMParallelState`

## 3.0.4

- re-added internal dispatch queue for `TBSMParallelState`

## 3.0.3

- removed internal dispatch queues

## 3.0.2

- removed log messages
- code cleanup

## 3.0.1

- removed method `- (TBSMTransition *)handleEvent:(TBSMEvent *)event` from `TBSMNode` protocol

## 3.0.0

- changed class name to use prefix `TBSM` instead of `TBStateMachine`
- added TBSMSubState which derives from `TBSMState` (formerly known as `TBStateMachineState`)

## 2.0.1

### fixes

- LCA handling was broken and resulted in a wrong execution sequence of exit - action - enter
- corrected typos in CHANGELOG.md (this document)

## 2.0.0

### enhanced state switching:

- state machine can now switch from a substate of a sub state machine deep into another submachine. Implementation uses LCA (Least Common Ancestor) - algorithm

### re-worked event handling:

- events will be registered by setting target action and guard:

```
- (void)registerEvent:(TBStateMachineEvent *)event
               target:(id<TBStateMachineNode>)target
               action:(TBStateMachineActionBlock)action
                guard:(TBStateMachineGuardBlock)guard;
```

- event processing follows RTC-model. The state machine will queue all events it receives until processing of the current event has finished

## 1.0.0

- updated documentation
- updated API

## 0.9.0

- initial release
