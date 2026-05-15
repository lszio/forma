import SwiftUI

struct RuleEditorView: View {
    @Binding var rule: RuleNode?
    
    var body: some View {
        List {
            if let currentRule = rule {
                RuleNodeView(node: currentRule) { newNode in
                    rule = newNode
                }
                
                Button("Clear Rule", role: .destructive) {
                    rule = nil
                }
            } else {
                Button("Add Rule") {
                    rule = .time(TimeRule(startHour: 9, endHour: 17, weekdays: [2, 3, 4, 5, 6]))
                }
            }
        }
        .navigationTitle("Edit Rule")
    }
}

struct RuleNodeView: View {
    let node: RuleNode
    let onUpdate: (RuleNode) -> Void
    
    var body: some View {
        switch node {
        case .and(let nodes):
            Section("ALL of these") {
                ForEach(0..<nodes.count, id: \.self) { index in
                    RuleNodeView(node: nodes[index]) { newNode in
                        var newNodes = nodes
                        newNodes[index] = newNode
                        onUpdate(.and(newNodes))
                    }
                }
                Button("Add Sub-rule") {
                    var newNodes = nodes
                    newNodes.append(.time(TimeRule(startHour: 0, endHour: 24, weekdays: [1, 2, 3, 4, 5, 6, 7])))
                    onUpdate(.and(newNodes))
                }
            }
        case .or(let nodes):
            Section("ANY of these") {
                ForEach(0..<nodes.count, id: \.self) { index in
                    RuleNodeView(node: nodes[index]) { newNode in
                        var newNodes = nodes
                        newNodes[index] = newNode
                        onUpdate(.or(newNodes))
                    }
                }
                Button("Add Sub-rule") {
                    var newNodes = nodes
                    newNodes.append(.time(TimeRule(startHour: 0, endHour: 24, weekdays: [1, 2, 3, 4, 5, 6, 7])))
                    onUpdate(.or(newNodes))
                }
            }
        case .not(let subNode):
            Section("NOT") {
                RuleNodeView(node: subNode) { newNode in
                    onUpdate(.not(newNode))
                }
            }
        case .time(let rule):
            TimeRuleEditor(rule: rule) { newRule in
                onUpdate(.time(newRule))
            }
        case .battery(let rule):
            BatteryRuleEditor(rule: rule) { newRule in
                onUpdate(.battery(newRule))
            }
        case .focus(let rule):
            FocusRuleEditor(rule: rule) { newRule in
                onUpdate(.focus(newRule))
            }
        case .device(let rule):
            DeviceRuleEditor(rule: rule) { newRule in
                onUpdate(.device(newRule))
            }
        }
    }
}

struct DeviceRuleEditor: View {
    let rule: ConnectedDeviceRule
    let onUpdate: (ConnectedDeviceRule) -> Void
    
    var body: some View {
        TextField("Device Identifier", text: Binding(get: { rule.deviceIdentifier }, set: { onUpdate(ConnectedDeviceRule(deviceIdentifier: $0)) }))
    }
}

struct TimeRuleEditor: View {
    let rule: TimeRule
    let onUpdate: (TimeRule) -> Void
    
    var body: some View {
        VStack {
            Stepper("Start Hour: \(rule.startHour)", value: Binding(get: { rule.startHour }, set: { onUpdate(TimeRule(startHour: $0, endHour: rule.endHour, weekdays: rule.weekdays)) }), in: 0...23)
            Stepper("End Hour: \(rule.endHour)", value: Binding(get: { rule.endHour }, set: { onUpdate(TimeRule(startHour: rule.startHour, endHour: $0, weekdays: rule.weekdays)) }), in: 0...23)
        }
    }
}

struct BatteryRuleEditor: View {
    let rule: BatteryRule
    let onUpdate: (BatteryRule) -> Void
    
    var body: some View {
        VStack {
            Text("Battery Range: \(Int(rule.minLevel * 100))% - \(Int(rule.maxLevel * 100))%")
            Slider(value: Binding(get: { rule.minLevel }, set: { onUpdate(BatteryRule(minLevel: $0, maxLevel: rule.maxLevel, isCharging: rule.isCharging)) }))
            Slider(value: Binding(get: { rule.maxLevel }, set: { onUpdate(BatteryRule(minLevel: rule.minLevel, maxLevel: $0, isCharging: rule.isCharging)) }))
        }
    }
}

struct FocusRuleEditor: View {
    let rule: FocusModeRule
    let onUpdate: (FocusModeRule) -> Void
    
    var body: some View {
        TextField("Focus Mode Name", text: Binding(get: { rule.name }, set: { onUpdate(FocusModeRule(name: $0)) }))
    }
}
