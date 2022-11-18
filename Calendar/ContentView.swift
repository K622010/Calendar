import SwiftUI
import FSCalendar
import UIKit
import CoreData

struct CalendarTestView: UIViewRepresentable {
    @Binding var selectedDate: Date
    
    func makeUIView(context: Context) -> UIView {
        
        typealias UIViewType = FSCalendar
        
        let fsCalendar = FSCalendar()
        fsCalendar.delegate = context.coordinator
        fsCalendar.dataSource = context.coordinator
        
        fsCalendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.thin)
        fsCalendar.appearance.headerTitleColor = .black
        fsCalendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)
        fsCalendar.appearance.weekdayTextColor = .black
        fsCalendar.appearance.titleFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.thin)
        fsCalendar.appearance.selectionColor = .systemCyan
        fsCalendar.appearance.todayColor = .systemOrange
        fsCalendar.appearance.titleWeekendColor = .red
        
        return fsCalendar
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarTestView
        let dateFormatter = DateFormatter()
        
        init(_ parent:CalendarTestView){
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            guard let eventDate = dateFormatter.date(from: "24-09-2022") else { return 0 }
            
            if date.compare(eventDate) == .orderedSame{
                return 1
            }
            return 0
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
    }
}

struct ClassButtonView: View {
    @Binding var attendCounter: Dictionary<String, Int>
    @Binding var isClassDelete: Bool
    @Binding var selectedDate: Date
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ClassIndex.entity(),
        sortDescriptors: [NSSortDescriptor(key: "startTime", ascending: false)],
        animation: .default
    ) var fetchedClassList: FetchedResults<ClassIndex>
    let calendar = Calendar(identifier: .gregorian)
    
    var body: some View {
        ScrollView {
            if fetchedClassList.count == 0 {
                Text("no class")
                    .foregroundColor(Color.gray)
                    .font(.title)
            }
            LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) { // カラム数の指定
                ForEach(fetchedClassList) { classIndex in
                    ButtonView(attendCounter: $attendCounter, classIndex: classIndex, isClassDelete: $isClassDelete)
                    
                }
            }
        }
    }
}


struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var selectedDate = Date()
    @State var attendCounter: Dictionary<String, Int> = ["Attend": 0, "Absent": 0, "Late": 0]
    @State var isShowingDetail = false
    @State var isClassDelete = false
    @State var classIndex = ClassIndex()
    @ObservedObject var saveClassIndex = SaveClassIndex()
    @State var classColor: UIColor = UIColor.systemBlue
    let editMode: String = "new"
    
    var body: some View {
        HStack {
            Spacer(minLength: 30)
            
            VStack {
                CalendarTestView(selectedDate: $selectedDate)
                    .frame(height: 400)
                HStack {
                    Spacer()
                        .frame(width: 10)
                    Text("Class")
                        .font(.title)
                    Spacer(minLength: 170)
                    Button(action: {
                        self.isShowingDetail.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(.gray))
                    }.sheet(isPresented: $isShowingDetail, onDismiss: {
                        saveClassIndex.newClassSave(viewContext: viewContext)
                    }) {
                        EditClassInformationView(attendCounter: $attendCounter, editMode: "new", classIndex: $classIndex, saveClassIndex: saveClassIndex)
                    }.disabled(isClassDelete)
                    Button(action: {
                        self.isClassDelete.toggle()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(.gray))
                    }
                    Spacer()
                        .frame(width: 5)
                }
                ClassButtonView(attendCounter: $attendCounter, isClassDelete: $isClassDelete, selectedDate: $selectedDate)
            }
            
            Spacer(minLength: 30)
        }
    }
}

struct ContentView: View {
    
    var body: some View {
        CalendarView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

