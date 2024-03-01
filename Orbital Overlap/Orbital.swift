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
    
    func waveFunction1s(rCoordinate: Double, atomicNumber: Int, bohrRadius: Double) -> Double {
        return (1.0/sqrt(Double.pi))*pow((Double(atomicNumber)/bohrRadius), (3/2))*exp((-Double(atomicNumber)*rCoordinate)/(bohrRadius))
    }
    
    func monteCarloMVT(upperBounds: [Double], lowerBounds: [Double], numGuess: Int, spacing: Double, bohrRadius: Double, atomicNumber: Int) async -> Double {
        let meanValue = await withTaskGroup(of: Double.self, returning: Double.self, body: { taskGroup in
            
            for _ in 1 ... numGuess {
                taskGroup.addTask {
                    var guess: [Double] = []
                    for dimension in 0 ... upperBounds.count {
                        guess.append(Double.random(in: lowerBounds[dimension] ... upperBounds[dimension]))
                        
                    }
                    let sphericalGuess = self.cartesianToSpherical(xCoordinate: guess[0], yCoordinate: guess[1], zCoordinate: guess[2])
                    
                    return self.waveFunction1s(rCoordinate: sphericalGuess[0], atomicNumber: atomicNumber, bohrRadius: bohrRadius)*self.waveFunction1s(rCoordinate: sphericalGuess[0], atomicNumber: atomicNumber, bohrRadius: bohrRadius)
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
