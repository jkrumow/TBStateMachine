# TBStateMachine CHANGELOG

## 2.0.0

### enhanced event switching:

- state machine can now switch from a substate of a sub state machine deep into another submachine. Implementation uses LCA (Lowest Common Ancestor) - algorithm.

### re-worked event handling:

- events will be registered by setting target action and guard:

```
- (void)registerEvent:(TBStateMachineEvent *)event
               target:(id<TBStateMachineNode>)target
               action:(TBStateMachineActionBlock)action
                guard:(TBStateMachineGuardBlock)guard;
```

- events processing follows RTC-model. The state machine will queue all events it receives until processing of the current state has finished.

- transitions from substate to substate of different submachine are possible now ()using LCA-algorithm).

## 1.0.0

- updated documentation
- updated API


## 0.9.0

Initial release.