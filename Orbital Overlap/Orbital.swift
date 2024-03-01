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
    
    func cartesianToSpherical(xCoordinate: Double, yCoordinate: Double, zCoordinate: Double) -> [Double] {
        
        let r: Double = sqrt(pow(xCoordinate, 2)+pow(yCoordinate, 2)+pow(zCoordinate, 2))
        let theta: Double = acos(zCoordinate/r)
        let phi: Double = atan2(yCoordinate,xCoordinate)
        
        return [r, theta, phi]
    }
    
    func waveFunction1s(coordinates: [Double], atomicNumber: Int, bohrRadius: Double, separation: Double) -> Double {
        return (1.0/sqrt(Double.pi))*pow((Double(atomicNumber)/bohrRadius), (3/2))*exp((-Double(atomicNumber)*coordinates[0])/(2*bohrRadius))
    }
    
    func monteCarloMVT(upperBounds: [Double], lowerBounds: [Double], numGuess: Int, spacing: Double, bohrRadius: Double, atomicNumber: Int) async -> Double {
        let meanValue = await withTaskGroup(of: Double.self, returning: Double.self, body: { taskGroup in
            
            for _ in 1 ... numGuess {
                taskGroup.addTask {
                    var guess: [Double] = []
                    for dimension in 0 ... upperBounds.count {
                        guess.append(Double.random(in: lowerBounds[dimension] ... upperBounds[dimension]))
                    }
                    return self.waveFunction1s(coordinates: guess, atomicNumber: atomicNumber, bohrRadius: bohrRadius, separation: 0)*self.waveFunction1s(coordinates: guess, atomicNumber: atomicNumber, bohrRadius: bohrRadius, separation: spacing)
                }
            }
            var combinedTaskResults: [Double] = []
            for await result in taskGroup{
                combinedTaskResults.append(result)
            }
            var sum: Double = 0
            for element in combinedTaskResults {
                sum += element
            }
            return sum/Double(numGuess)
        })
        return meanValue
    }
}
