//
//  ParameterView.swift
//  Calendar
//
//  Created by 江越瑠一 on 2022/09/19.
//

import SwiftUI
import FSCalendar
import UIKit
import MBCircularProgressBar
import ColorSlider
import CoreData

struct ParameterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentation
    @Binding var classColor: UIColor
    @State private var subject = ""
    @State private var place = ""
    @State private var schoolHoursStart = Date()
    @State private var schoolHoursEnd = ""
    @State private var memo = ""
    @State private var isStartEdit = false
    @State private var isEndEdit = false
    let editMode: String
    @Binding var classIndex: ClassIndex
    @ObservedObject var saveClassIndex: SaveClassIndex
    
    init(classColor: Binding<UIColor>, editMode: String, classIndex: Binding<ClassIndex>, saveClassIndex: SaveClassIndex) {
        self._classColor = classColor
        self.editMode = editMode
        self._classIndex = classIndex
        self.saveClassIndex = saveClassIndex
    }
    
    var body: some View {
        VStack(spacing: 5) {
            VStack {
                HStack {
                    Text("Subject")
                        .frame(width: 70)
                        .offset(y: 11)
                    Spacer()
                }
                ZStack {
                    Rectangle()
                        .fill(Color.TextBackGroundColor)
                        .frame(height: 30)
                        .cornerRadius(10)
                    HStack {
                        Spacer().frame(width: 15)
                        Image(systemName: "book.closed.fill")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(Color.gray)
                        Spacer()
                        TextField(saveClassIndex.subject, text: $saveClassIndex.subject)
                    }
                }
            }
            
            VStack {
                HStack {
                    Text("Place")
                        .frame(width: 53)
                        .offset(y: 11)
                    Spacer()
                }
                ZStack {
                    Rectangle()
                        .fill(Color.TextBackGroundColor)
                        .frame(height: 30)
                        .cornerRadius(10)
                    HStack {
                        Spacer().frame(width: 15)
                        Image(systemName: "mappin.circle")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(Color.gray)
                        Spacer()
                        TextField(saveClassIndex.place, text: $saveClassIndex.place)
                    }
                }
            }
            
            VStack {
                HStack {
                    Text("School hours")
                        .frame(width: 110)
                        .offset(y: 11)
                    Spacer()
                    Text("Color")
                        .frame(width: 60)
                        .offset(y: 11)
                    Spacer().frame(width: 35)
                }
                HStack(spacing: 7) {
                    DatePicker(dateToHour(date: saveClassIndex.startTime), selection: $saveClassIndex.startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .scaleEffect(x: 0.92, y: 0.87)
                    
                    Text("~")
                        .frame(width: 15, height: 20)
                    DatePicker(dateToHour(date: saveClassIndex.endTime), selection: $saveClassIndex.endTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .scaleEffect(x: 0.92, y: 0.87)
                    Spacer().frame(width: 10)
                    ColorPickerView(saveClassIndex: saveClassIndex, classColor: $classColor)
                        .frame(width: 90, height: 20)
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Text("Memo")
                        .frame(width: 58)
                        .offset(y: 11)
                    Spacer()
                }
                ZStack {
                    Rectangle()
                        .fill(Color.TextBackGroundColor)
                        .cornerRadius(10)
                }
            }
        }
    }
    
//    private func addClassIndex(subject: String) {
//    }
    
    func save() {
        if self.editMode == "new" {
            let newClassIndex = ClassIndex(context: viewContext)
            newClassIndex.subject = subject
            try? viewContext.save()
        }
    }
}

struct ColorPickerView: UIViewRepresentable {
    @ObservedObject var saveClassIndex: SaveClassIndex
    @Binding var classColor: UIColor
    func makeUIView(context: Context) -> ColorPicker {
        let colorPickerView = ColorPicker(frame: .zero)
        colorPickerView.delegate = context.coordinator
        return colorPickerView
    }

    func updateUIView(_ uiView: ColorPicker, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(classColor: $classColor, saveClassIndex: saveClassIndex)
    }
    
    class Coordinator: NSObject, ColorPickerViewDelegate {
        @ObservedObject var saveClassIndex: SaveClassIndex
        @Binding var classColor: UIColor

        init(classColor: Binding<UIColor>, saveClassIndex: SaveClassIndex) {
            _classColor = classColor
            self.saveClassIndex = saveClassIndex
        }

        func receiveColor(classColor: UIColor) {
            self.classColor = classColor
            self.saveClassIndex.color = classColor
            print(self.classColor)
        }
    }
}

protocol ColorPickerViewDelegate: NSObjectProtocol {
    func receiveColor(classColor: UIColor)
}

class ColorPicker: UIView {
    var classColorPicked = UIColor.red
    weak var delegate: ColorPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    func loadNib() {
        let previewView = DefaultPreviewView()
        previewView.animationDuration = 0.5 //色の更新間隔
        previewView.offsetAmount = 0 //sliderからの距離
        
        let colorSlider = ColorSlider(orientation: .horizontal, previewView: previewView)
        colorSlider.frame = CGRect(x: 0, y: 0, width: 90, height: 15)
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
        self.addSubview(colorSlider)
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        classColorPicked = slider.color
        delegate?.receiveColor(classColor: classColorPicked)
    }
}
