//
//  ContentView.swift
//  Orbital Overlap
//
//  Created by Phys440Zachary on 2/28/24.
//

import SwiftUI

struct ContentView: View {
    @State private var xValueLow = "-10"
    @State private var yValueLow = "-10"
    @State private var zValueLow = "-10"
    @State private var xValueUp = "10"
    @State private var yValueUp = "10"
    @State private var zValueUp = "10"
    @State private var spacing = "0"
    @State private var atomicNumber = "1"
    @State private var numberOfGuesses = "100000"
    @State private var result = ""
    @State private var isLoading = false
    @State private var selectedOrbital = 0
    
    @Bindable var orbitalOverlapCalculator = Orbital()
    
    let options = ["1s - 1s", "1s - 2px"]
    
    var body: some View {
        VStack {
            Picker("Select an option", selection: $selectedOrbital) {
                            ForEach(0..<options.count) {
                                Text(options[$0])
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
            HStack{
                VStack {
                    Text("Lower Bounds:")
                    HStack{
                        Text("X:")
                        TextField("Enter X value", text: $xValueLow)
                    }
                    HStack{
                        Text("Y:")
                        TextField("Enter Y value", text: $yValueLow)
                    }
                    HStack{
                        Text("Z:")
                        TextField("Enter Z value", text: $zValueLow)
                    }
                }
                VStack {
                    Text("Upper Bounds:")
                    HStack{
                        Text("X:")
                        TextField("Enter X value", text: $xValueUp)
                    }
                    HStack{
                        Text("Y:")
                        TextField("Enter Y value", text: $yValueUp)
                    }
                    HStack{
                        Text("Z:")
                        TextField("Enter Z value", text: $zValueUp)
                    }
                }
            }
            Text("Atomic Number:")
            TextField("Enter atomic number", text: $atomicNumber)
            Text("Spacing (Angstrom):")
            TextField("Enter Spacing", text: $spacing)
            Text("Number of Guesses:")
            TextField("Enter number of guesses", text: $numberOfGuesses)
            
            
            // Calculate button
            Button(action: calculateResult) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Calculate")
                }
            }
            .disabled(isLoading)
            
            // Result field
            Text("Result: \(result)")
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func calculateResult() {
        isLoading = true
        let upperBounds: [Double] = [Double(xValueUp) ?? 0, Double(yValueUp) ?? 0, Double(zValueUp) ?? 0]
        let lowerBounds: [Double] = [Double(xValueLow) ?? 0, Double(yValueLow) ?? 0, Double(zValueLow) ?? 0]
        
        Task {
            result = await orbitalOverlapCalculator.findOverlap(spacing: Double(spacing) ?? 0, atomicNumber: Int(atomicNumber) ?? 1, upperBounds: upperBounds, lowerBounds: lowerBounds, numGuesses: Int(numberOfGuesses) ?? 10, orbitalSet: selectedOrbital).formatted(.number.precision(.fractionLength(5)).notation(.scientific))
            isLoading = false
        }
        
        result = "\(result)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
