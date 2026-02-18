//
//  SwiftUIView.swift
//  Scrollify
//
//  Created by Phyo Thet Pai on 24/1/26.
//

import SwiftUI

struct ScreenTimeView: View {
    @State private var hours: Int = 1
    @State private var minutes: Int = 0
    @State private var downtime: Date = {
        var components = DateComponents()
        components.hour = 23
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    var limitColor: Color{
        if hours == 1{
            return .yellow
        }
        if hours == 0{
            return .green
        }
        return .red
    }
    var downtimeColor: Color{
        if !haveDowntime{
            return .red
        }
        if let hour = Calendar.current.dateComponents([.hour], from: downtime).hour, hour <= 22{
            return .green
        }
        return .yellow
    }
    @State private var haveDowntime = false
    @Environment(DataManager.self) var dM
    var body: some View {
        @Bindable var dataManager = dM
        NavigationStack{
            Form{
                Section("App Limit"){
                    HStack{
                        Text("Daily Limit")
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24, id: \.self) { i in
                                Text("\(i)").tag(i)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        Text("hours")
                        Picker("Minutes", selection: $minutes) {
                            ForEach([0,15,30,45], id: \.self) { i in
                                Text("\(i)").tag(i)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        Text("minutes")
                    }
                    VStack(alignment: .leading){
                        Text("Level:")
                        HStack{
                            Rectangle()
                                .foregroundStyle(limitColor)
                            if limitColor == .red{
                                Rectangle()
                            }else{
                                Rectangle()
                                    .foregroundStyle(limitColor)
                            }
                            if limitColor == .green{
                                Rectangle()
                                    .foregroundStyle(limitColor)
                            }else{
                                Rectangle()
                            }
                        }
                        .mask(RoundedRectangle(cornerRadius: 25))
                        .foregroundStyle(.quinary)
                        .frame(height: 25)
                        Text(limitColor == .red ? "Try not to set it so high" : limitColor == .green ? "Great! You're good to go!" : "")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Downtime"){
                    Toggle("Have downtime?", isOn: $haveDowntime)
                    if haveDowntime{
                        DatePicker(
                            "Time to stop",
                            selection: $downtime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                        VStack(alignment: .leading){
                            Text("Level:")
                            HStack{
                                Rectangle()
                                    .foregroundStyle(downtimeColor)
                                if downtimeColor == .red{
                                    Rectangle()
                                }else{
                                    Rectangle()
                                        .foregroundStyle(downtimeColor)
                                }
                                if downtimeColor == .green{
                                    Rectangle()
                                        .foregroundStyle(downtimeColor)
                                }else{
                                    Rectangle()
                                }
                            }
                            .mask(RoundedRectangle(cornerRadius: 25))
                            .foregroundStyle(.quinary)
                            .frame(height: 25)
                            if haveDowntime{
                                Text("You should set it to 30-60 minutes before you sleep")
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
            }
            .navigationTitle("Screen Time")
            .onChange(of: [limitColor, downtimeColor]) {
                if limitColor == .green && downtimeColor == .green{
                    dataManager.doneScreentime = true
                }else{
                    dataManager.doneScreentime = false
                }
            }
        }
    }
}
#Preview {
    ScreenTimeView()
        .preferredColorScheme(.dark)
        .environment(DataManager())
}
