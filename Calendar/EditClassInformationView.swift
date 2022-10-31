//
//  EditClassInformation.swift
//  Calendar
//
//  Created by 江越瑠一 on 2022/09/11.
//

import SwiftUI
import FSCalendar
import UIKit
import MBCircularProgressBar
import CoreData


struct EditClassInformationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var attendCounter: Dictionary<String, Int>
    @State var classColor: UIColor = UIColor.systemBlue
    let editMode: String
    @Binding var classIndex: ClassIndex
    @ObservedObject var saveClassIndex: SaveClassIndex
    
    init(attendCounter: Binding<Dictionary<String, Int>>, editMode: String, classIndex: Binding<ClassIndex>, saveClassIndex: SaveClassIndex) {
        self._attendCounter = attendCounter
        self.editMode = editMode
        self._classIndex = classIndex
        self.saveClassIndex = saveClassIndex
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: 30)
            VStack(spacing: 10) {
                Spacer().frame(height: 10)
                AttendView(attendCounter: $attendCounter, classColor: $classColor, editMode: editMode, classIndex: $classIndex, saveClassIndex: saveClassIndex)
                ParameterView(classColor: $classColor, editMode: editMode, classIndex: $classIndex, saveClassIndex: saveClassIndex)
//                    .onDisappear() {
//                        ParameterView(classColor: $classColor, editMode: editMode, classIndex: $classIndex).save()
//                        print("disapper")
//                    }
            }
            Spacer(minLength: 30)
        }
    }
}

class CircularProgressBarView: UIViewController {
    var progressView: MBCircularProgressBarView!
    //@IBOutlet weak var progressValueLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        progressView.value = 0
        progressView.maxValue = 30
        //progressValueLabel.text = "\(progressView.value)"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIView.animate(withDuration: 1.0) {
            self.progressView.value = 15
        }
    }
}

//struct AttendCircularProgressBarView: UIViewControllerRepresentable {
////    @Binding var isPresented: Bool
//
//    func makeUIViewController(context: Context) -> CircularProgressBarView {
//        return CircularProgressBarView()
//    }
//
//    func updateUIViewController(_ uiViewController: CircularProgressBarView, context: Context) {
//    }
//}

struct AttendCircularProgressBarView: View {
    @Binding var attendCounter: Dictionary<String, Int>
    @Binding var classColor: UIColor
    @State var attendRate: Double = 0
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 80, y: 90))
                path.addArc(center: .init(x: 80, y: 90),
                            radius: 60,
                            startAngle: Angle(degrees: 270),
                            endAngle: Angle(degrees: 270.0 + attendRate),
                            clockwise: false)
            }
            .fill(Color(classColor))
            .onAppear {
                attendRate = graphCalculator(attendCounter: attendCounter)
            }
            .onChange(of: attendCounter) { newAttend in
                attendRate = graphCalculator(attendCounter: newAttend)
            }
            .animation(.easeInOut, value: attendRate)
            
            Circle()
                .fill(Color.white)
                .frame(width: 100, height: 100)
                .offset(x: -1)
            
            Text(calculatePercentage())
        }
    }
    
    func graphCalculator(attendCounter: Dictionary<String, Int>) -> Double {
        let allClass: Double = Double(Array(attendCounter.values).reduce(0, +))
        var percentageCounter: Double = 0
        if allClass != 0 {
            percentageCounter = Double(attendCounter["Attend"]!) / allClass * 360.0
        }
        return percentageCounter
    }
    
    func calculatePercentage() -> String {
        var percent = Int(attendRate * 100 / 360)
        if attendRate == 0 {
            percent = 0
        }
        return String(percent)+"%"
    }
}

struct AttendView: View {
    @Binding var attendCounter: Dictionary<String, Int>
    @Binding var classColor: UIColor
    @State var transratedClassColor: Color = Color.white
    @State var ButtonColors: Dictionary<String, Color> = ["Attend": Color.white, "Late": Color.white, "Absent": Color.white]
    @State var TextColors: Dictionary<String, Color> = ["Attend": Color.orange,  "Late": Color.orange, "Absent": Color.orange]
    @State var ButtonState: String = ""
    @State var buttonPushFlag: Bool = false
    @State var buttonPushState: String = ""
    let editMode: String
    @Binding var classIndex: ClassIndex
    @ObservedObject var saveClassIndex: SaveClassIndex
    
    var body: some View {
        HStack {
            VStack(spacing: 20) {
                Button(action: {
                    ChangeButtonColor(state: "Attend")
                    (buttonPushFlag, attendCounter) = pushAttendButton(stateBefore: buttonPushState, stateAfter: "Attend", buttonPushFlag: buttonPushFlag, attendCounter: attendCounter)
                    buttonPushState = "Attend"
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ButtonColors["Attend"]!)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(TextColors["Attend"]!, lineWidth: 1)
                        Text("Attend"+String(attendCounter["Attend"]!))
                            .foregroundColor(TextColors["Attend"])
                    }
                }.frame(height: 40)
                
                Button(action: {
                    ChangeButtonColor(state: "Late")
                    (buttonPushFlag, attendCounter) = pushAttendButton(stateBefore: buttonPushState, stateAfter: "Late", buttonPushFlag: buttonPushFlag, attendCounter: attendCounter)
                    buttonPushState = "Late"
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ButtonColors["Late"]!)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(TextColors["Late"]!, lineWidth: 1)
                        Text("Late"+String(attendCounter["Late"]!))
                            .foregroundColor(TextColors["Late"])
                    }
                }.frame(height: 40)
                Button(action: {
                    ChangeButtonColor(state: "Absent")
                    (buttonPushFlag, attendCounter) = pushAttendButton(stateBefore: buttonPushState, stateAfter: "Absent", buttonPushFlag: buttonPushFlag, attendCounter: attendCounter)
                    buttonPushState = "Absent"
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ButtonColors["Absent"]!)
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(TextColors["Absent"]!, lineWidth: 1)
                        Text("Absent"+String(attendCounter["Absent"]!))
                            .foregroundColor(TextColors["Absent"])
                    }
                }.frame(height: 40)
            }
            AttendCircularProgressBarView(attendCounter: $attendCounter, classColor: $saveClassIndex.color)
                .frame(height: 180)
        }.onAppear {
            ChangeButtonColor(state: buttonPushState)
        }.onChange(of: classColor) { _ in
            ChangeButtonColor(state: buttonPushState)
        }
    }
    
    func ChangeButtonColor(state: String) {
//        SwiftUI.Color(UInt(Int(self.classIndex.color ?? "000000", radix: 16) ?? 000000), alpha: 1.0)
        switch state {
        case "Attend":
            ButtonColors["Attend"] = Color(saveClassIndex.color)
            ButtonColors["Late"] = Color.white
            ButtonColors["Absent"] = Color.white
            TextColors["Attend"] = Color.white
            TextColors["Late"] = Color(saveClassIndex.color)
            TextColors["Absent"] = Color(saveClassIndex.color)
        case "Late":
            ButtonColors["Attend"] = Color.white
            ButtonColors["Late"] = Color(saveClassIndex.color)
            ButtonColors["Absent"] = Color.white
            TextColors["Attend"] = Color(saveClassIndex.color)
            TextColors["Late"] = Color.white
            TextColors["Absent"] = Color(saveClassIndex.color)
        case "Absent":
            ButtonColors["Attend"] = Color.white
            ButtonColors["Late"] = Color.white
            ButtonColors["Absent"] = Color(saveClassIndex.color)
            TextColors["Attend"] = Color(saveClassIndex.color)
            TextColors["Late"] = Color(saveClassIndex.color)
            TextColors["Absent"] = Color.white
        case "":
            ButtonColors["Attend"] = Color.white
            ButtonColors["Late"] = Color.white
            ButtonColors["Absent"] = Color.white
            TextColors["Attend"] = Color(saveClassIndex.color)
            TextColors["Late"] = Color(saveClassIndex.color)
            TextColors["Absent"] = Color(saveClassIndex.color)
        default:
            print("Not Found")
        }
    }
}


func dateToHour(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: Date())
}

func pushAttendButton(stateBefore: String, stateAfter: String, buttonPushFlag: Bool, attendCounter: Dictionary<String, Int>) -> (Bool, Dictionary<String, Int>) {
//    @Environment(\.managedObjectContext) var viewContext
//    let classIndex = ClassIndex(context: viewContext)
//    @Environment(\.presentationMode) var presentation
    let pushStateList: [String] = ["Attend", "Absent", "Late"]
    var attendCounterEdit: Dictionary<String, Int> = attendCounter
    if buttonPushFlag {
        for pushState in pushStateList {
            if pushState == stateAfter && pushState != stateBefore {
                attendCounterEdit[pushState]! = attendCounterEdit[pushState]! + 1
            } else if pushState == stateBefore && pushState != stateAfter {
                attendCounterEdit[pushState]! = attendCounterEdit[pushState]! - 1
            }
        }
    } else {
        for pushState in pushStateList {
            if pushState == stateAfter {
                attendCounterEdit[pushState]! = attendCounterEdit[pushState]! + 1
            }
        }
    }
    
//    classIndex.attend = Int16(attendCounter["Attend"] ?? 0)
//    classIndex.absent = Int16(attendCounter["Absent"] ?? 0)
//    classIndex.late = Int16(attendCounter["Late"] ?? 0)
//    try? viewContext.save()
//    presentation.wrappedValue.dismiss()
    
    return (true, attendCounterEdit)
}

extension Color {
    static let TextBackGroundColor = Color("TextBackGroundColor")
    
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
          .sRGB,
          red: Double((hex >> 16) & 0xFF) / 255,
          green: Double((hex >> 8) & 0xFF) / 255,
          blue: Double(hex & 0xFF) / 255,
          opacity: alpha
        )
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
    
    class var TextBackGroundColor: UIColor {
        return UIColor(named: "TextBackGroundColor")!
    }
    
    func toHexString() -> String {
        var red: CGFloat = 1.0
        var green: CGFloat = 1.0
        var blue: CGFloat = 1.0
        var alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(String(Int(floor(red*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let g = Int(String(Int(floor(green*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        let b = Int(String(Int(floor(blue*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!
        _ = Int(String(Int(floor(alpha*100)/100 * 255)).replacingOccurrences(of: "-", with: ""))!

        let resultRed = String(r, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let resultGreen = String(g, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let resultBlue = String(b, radix: 16).leftPadding(toLength: 2, withPad: "0")
        //let resultAlpha = String(a, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let result = resultRed + resultGreen + resultBlue
//        let result = String(r, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(g, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(b, radix: 16).leftPadding(toLength: 2, withPad: "0") + String(a, radix: 16).leftPadding(toLength: 2, withPad: "0")
        return result
    }
}

extension String {
    // 左から文字埋めする
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}
