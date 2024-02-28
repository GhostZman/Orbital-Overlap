//
//  Orbital.swift
//  Orbital Overlap
//
//  Created by Phys440Zachary on 2/28/24.
//

import Foundation
import Observation

@Observable class Orbital {
    
    
    func findOverlap(spacing: Double, bohrRadius: Double, atomicNumber: Int, upperBounds: [Double], lowerBounds: [Double]) {
        
    }
    
    func waveFunction(coordinates: [Double], atomicNumber: Int, bohrRadius: Double, separation: Double) {
        let x: Double = coordinates[0] - separation
        let y: Double = coordinates[1]
        let z: Double = coordinates[2]
        
        let r = sqrt(pow(x, 2)+pow(y, 2)+pow(z, 2))
        let theta = atan(sqrt(pow(x, 2)+pow(y, 2))/z)
        let phi = atan(y/x)
        
        return (1.0/sqrt(Double.pi))*pow((atomicNumber/bohrRadius), (3/2))*exp((-atomicNumber*r)/(2*bohrRadius))
    }
    
    func monteCarloMVT(upperBounds: [Double], lowerBounds: [Double], numGuess: Int, spacing: Double, bohrRadius: Double, atomicNumber: Int) {
        let meanValue = await withTaskGroup(of: Double.self, returning: Double.self, body: { taskGroup in
            
            for _ in 1 ... numGuess {
                taskGroup.addTask {
                    let guess = []
                    for dimension in 0 ... upperBounds.count {
                        guess.append(Double.random(in: lowerBounds[dimension] ... upperBounds[dimension]))
                    }
                    return waveFunction(coordinates: guess, atomicNumber: atomicNumber, bohrRadius: bohrRadius, separation: 0)*waveFunction(coordinates: guess, atomicNumber: atomicNumber, bohrRadius: bohrRadius, separation: spacing)
                }
            }
            var combinedTaskResults: [Bool] = []
            for await result in taskGroup{
                combinedTaskResults.append(result)
            }
            let sum = 0
            for element in combinedTaskResults {
                sum += element
            }
            return sum/numGuess
        })
        return meanValue
    }
}
