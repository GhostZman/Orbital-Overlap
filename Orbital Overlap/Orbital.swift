//
//  Orbital.swift
//  Orbital Overlap
//
//  Created by Phys440Zachary on 2/28/24.
//

import Foundation
import Observation

@Observable class Orbital {
    
    let bohrRadius = 0.529177210903 //Angstrom
    
    
    func findOverlap(spacing: Double, atomicNumber: Int, upperBounds: [Double], lowerBounds: [Double], numGuesses: Int, orbitalSet: Int) async -> Double {
        var boundsCoefficient: Double = 1.0
        for dim in 0...upperBounds.count-1 {
            boundsCoefficient *= (upperBounds[dim]-lowerBounds[dim])
        }
        var meanValue: Double = 0.0
        switch orbitalSet {
        case 0:
            meanValue = await monteCarloMeanValue1s1s(upperBounds: upperBounds, lowerBounds: lowerBounds, numGuess: numGuesses, atomicNumber: atomicNumber, separation: spacing)
        case 1:
            meanValue = await monteCarloMeanValue1s2px(upperBounds: upperBounds, lowerBounds: lowerBounds, numGuess: numGuesses, atomicNumber: atomicNumber, separation: spacing)
        default:
            meanValue = await monteCarloMeanValue1s1s(upperBounds: upperBounds, lowerBounds: lowerBounds, numGuess: numGuesses, atomicNumber: atomicNumber, separation: spacing)
        }
        
        
        return meanValue*boundsCoefficient
        
    }
    
    func cartesianToSpherical(xCoordinate: Double, yCoordinate: Double, zCoordinate: Double) -> [Double] {
        
        let r: Double = sqrt(pow(xCoordinate, 2)+pow(yCoordinate, 2)+pow(zCoordinate, 2))
        let theta: Double = acos(zCoordinate/r)
        let phi: Double = atan2(yCoordinate,xCoordinate)
        
        return [r, theta, phi]
    }
    
    func sphericalToCartesian(rCoordinate: Double, thetaCoordinate: Double, phiCoordinate: Double) -> [Double] {
        
        let x = rCoordinate*cos(phiCoordinate)*sin(thetaCoordinate)
        let y = rCoordinate*sin(phiCoordinate)*sin(thetaCoordinate)
        let z = rCoordinate*cos(thetaCoordinate)
        
        return [x,y,z]
    }
    
    func waveFunction1s(rCoordinate: Double, atomicNumber: Int) -> Double {
        return (1.0/sqrt(Double.pi))*pow((Double(atomicNumber)/self.bohrRadius), (3/2))*exp((-Double(atomicNumber)*rCoordinate)/(self.bohrRadius))
    }
    
    func waveFunction2px(SphericalCoordinates: [Double], atomicNumber: Int) -> Double {
        let rCoordinate = SphericalCoordinates[0]
        let thetaCoordinate = SphericalCoordinates[1]
        let phiCoordinate = SphericalCoordinates[2]
        
        return (1.0/sqrt(32.0*Double.pi))*pow(Double(atomicNumber)/bohrRadius,(5/2))*rCoordinate*exp((-1.0*Double(atomicNumber)*rCoordinate)/(2*bohrRadius))*sin(thetaCoordinate)*cos(phiCoordinate)
    }
    
    func overlapping1s2pxWaveFunctions(separation: Double, atomicNumber1: Int, atomicNumber2: Int, testCoordinatesCartesian:[Double]) -> Double {
        
        let atom1CoordinatesCartesian: [Double] = [separation/2.0, 0, 0]
        let atom2CoordinatesCartesian: [Double] = [(-1)*separation/2.0, 0, 0]
        
        let testCoordRelativeToAtom1 = [testCoordinatesCartesian[0]-atom1CoordinatesCartesian[0], testCoordinatesCartesian[1]-atom1CoordinatesCartesian[1], testCoordinatesCartesian[2]-atom1CoordinatesCartesian[2]]
        let testCoordRelativeToAtom2 = [testCoordinatesCartesian[0]-atom2CoordinatesCartesian[0], testCoordinatesCartesian[1]-atom2CoordinatesCartesian[1], testCoordinatesCartesian[2]-atom2CoordinatesCartesian[2]]
        
        let sphericalRelativeTo1 = cartesianToSpherical(xCoordinate: testCoordRelativeToAtom1[0], yCoordinate: testCoordRelativeToAtom1[1], zCoordinate: testCoordRelativeToAtom1[2])
        let sphericalRelativeTo2 = cartesianToSpherical(xCoordinate: testCoordRelativeToAtom2[0], yCoordinate: testCoordRelativeToAtom2[1], zCoordinate: testCoordRelativeToAtom2[2])
        
        let waveFunction1 = waveFunction1s(rCoordinate: sphericalRelativeTo1[0], atomicNumber: atomicNumber1)
        let waveFunction2 = waveFunction2px(SphericalCoordinates: sphericalRelativeTo2, atomicNumber: atomicNumber2)
        
        return waveFunction1*waveFunction2
    }
    
    
    func distanceFormula(coordinates1: [Double], coordinates2: [Double]) -> Double {
        
        var sum: Double = 0.0
        
        for dim in 0...coordinates1.count - 1 {
            sum += pow(coordinates2[dim] - coordinates1[dim], 2)
        }
        
        return sqrt(sum)
    }
    
    /// Calculates the overlapping wave functions of 2 1s orbitals at some point
    /// - Parameters:
    ///   - separation: Separation between the 2 atoms in Angstrom
    ///   - atomicNumber1: Atomic number of the first atom
    ///   - atomicNumber2: Atomic number of the second atom
    ///   - testCoordinates: Cartesian coordinates [x, y, z]  at which to evaluate the wave function overlap
    func overlapping1sWaveFunctions(separation: Double, atomicNumber1: Int, atomicNumber2: Int, testCoordinates:[Double]) -> Double {
        
        let atom1Coordinates: [Double] = [separation/2.0, 0, 0]
        let atom2Coordinates: [Double] = [(-1)*separation/2.0, 0, 0]
        
        let distanceAtom1ToTest = distanceFormula(coordinates1: atom1Coordinates, coordinates2: testCoordinates)
        let distanceAtom2ToTest = distanceFormula(coordinates1: atom2Coordinates, coordinates2: testCoordinates)
        
        let waveFunction1 = waveFunction1s(rCoordinate: distanceAtom1ToTest, atomicNumber: atomicNumber1)
        let waveFunction2 = waveFunction1s(rCoordinate: distanceAtom2ToTest, atomicNumber: atomicNumber2)
        
        return waveFunction1*waveFunction2
    }
    
    func monteCarloMeanValue1s1s(upperBounds: [Double], lowerBounds: [Double], numGuess: Int, atomicNumber: Int, separation: Double) async -> Double {
        let meanValue = await withTaskGroup(of: Double.self, returning: Double.self, body: { taskGroup in
            
            for _ in 1 ... numGuess {
                taskGroup.addTask {
                    var guess: [Double] = []
                    for dimension in 0 ... upperBounds.count - 1 {
                        guess.append(Double.random(in: lowerBounds[dimension] ... upperBounds[dimension]))
                        
                    }
                    
                    return self.overlapping1sWaveFunctions(separation: separation, atomicNumber1: atomicNumber, atomicNumber2: atomicNumber, testCoordinates: guess)
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
    
    func monteCarloMeanValue1s2px(upperBounds: [Double], lowerBounds: [Double], numGuess: Int, atomicNumber: Int, separation: Double) async -> Double {
        let meanValue = await withTaskGroup(of: Double.self, returning: Double.self, body: { taskGroup in
            
            for _ in 1 ... numGuess {
                taskGroup.addTask {
                    var guess: [Double] = []
                    for dimension in 0 ... upperBounds.count - 1 {
                        guess.append(Double.random(in: lowerBounds[dimension] ... upperBounds[dimension]))
                        
                    }
                    
                    return self.overlapping1s2pxWaveFunctions(separation: separation, atomicNumber1: atomicNumber, atomicNumber2: atomicNumber, testCoordinatesCartesian: guess)
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
