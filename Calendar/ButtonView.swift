//
//  ButtonView.swift
//  Calendar
//
//  Created by 江越瑠一 on 2022/09/11.
//

import SwiftUI
import CoreData

class SaveClassIndex: ObservableObject, Identifiable {
    var subject = ""
    var place = ""
    var startTime = Date()
    var endTime = Date()
    var color = UIColor.red
    var attend: Int16 = 0
    var absent: Int16 = 0
    var late: Int16 = 0
    var date: Date

    init(date: Date) {
        self.date = date
    }
    
    func newClassSave(viewContext: NSManagedObjectContext) {
        let newClassIndex = ClassIndex(context: viewContext)
        newClassIndex.subject = subject
        newClassIndex.place = place
        newClassIndex.startTime = startTime
        newClassIndex.endTime = endTime
        newClassIndex.color = color.toHexString()
        newClassIndex.attend = attend
        newClassIndex.absent = absent
        newClassIndex.late = late
        newClassIndex.date = date
        try? viewContext.save()
    }
    
    func editClassSave(viewContext: NSManagedObjectContext, classIndex: ClassIndex) {
        classIndex.subject = subject
        classIndex.place = place
        classIndex.startTime = startTime
        classIndex.endTime = endTime
        classIndex.color = color.toHexString()
        classIndex.attend = attend
        classIndex.absent = absent
        classIndex.late = late
        classIndex.date = date
        try? viewContext.save()
    }
    
    func deleteClass(viewContext: NSManagedObjectContext, classIndex: ClassIndex){
        viewContext.delete(classIndex)
        try? viewContext.save()
    }
}

struct ButtonView: View {
    @State var showingDetail = false
    @Binding var attendCounter: Dictionary<String, Int>
    @Binding var isClassDelete: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var saveClassIndex = SaveClassIndex()
    @State var classIndex: ClassIndex
    init(attendCounter: Binding<Dictionary<String, Int>>, classIndex: ClassIndex, isClassDelete: Binding<Bool>) {
        self._attendCounter = attendCounter
        self.classIndex = classIndex
        self._isClassDelete = isClassDelete
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                self.showingDetail.toggle()
            }) {
                VStack(spacing: 5) {
                    Spacer(minLength: 20)
                    Text(self.classIndex.subject!)
                        .fontWeight(.semibold)
                    HStack(spacing: 5) {
                        Spacer()
                            .frame(width: 5)
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text(stringFromDate(date: self.classIndex.startTime ?? Date()) + "~" + stringFromDate(date: self.classIndex.endTime ?? Date()))
                        Spacer()
                    }
                    HStack(spacing: 5) {
                        Spacer()
                            .frame(width: 5)
                        Image(systemName: "mappin.circle")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text(self.classIndex.place ?? "")
                            //.frame(width: 50)
                        Spacer()
                    }
                    Spacer(minLength: 20)
                }
            }.frame(width: 150, height: 80)
            .foregroundColor(Color(.white))
            .background(SwiftUI.Color(UInt(Int(self.classIndex.color ?? "000000", radix: 16) ?? 000000), alpha: 1.0))
            .cornerRadius(10)
            .padding(.all, 8)
            .disabled(isClassDelete)
            .sheet(isPresented: $showingDetail, onDismiss: {
                saveClassIndex.editClassSave(viewContext: viewContext, classIndex: classIndex)
            }) {
                EditClassInformationView(attendCounter: $attendCounter, editMode: "edit", classIndex: $classIndex, saveClassIndex: saveClassIndex)
            }
            
            Circle()
                .fill(Color(.red))
                .frame(width: 15, height: 15)
                .position(x: 154, y: 11)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            
            if isClassDelete == true {
                Button(action: {
                    saveClassIndex.deleteClass(viewContext: viewContext, classIndex: classIndex)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .cyan)
                        .frame(width: 50, height: 50)
                        .position(x: 15, y: 12)
                }
            }
        }
    }
    
    func stringFromDate(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
