//
//  ContentView.swift
//  Detecting Motion and Orientation
//
//  Created by Eddington, Nick on 11/13/23.
//

import SwiftUI
import CoreMotion

struct MotionData {
    var acceleration: CMAcceleration
    var rotationRate: CMRotationRate
    var magneticField: CMCalibratedMagneticField
    var attitude: CMAttitude
}

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var motionData = MotionData(acceleration: CMAcceleration(), rotationRate: CMRotationRate(), magneticField: CMCalibratedMagneticField(), attitude: CMAttitude())

    init() {
        motionManager.accelerometerUpdateInterval = 0.1 // 10 times per second
        motionManager.gyroUpdateInterval = 0.1 // 10 times per second
        motionManager.magnetometerUpdateInterval = 0.1 // 10 times per second

        startUpdating()
    }

    func startUpdating() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async {
                    self.motionData.acceleration = data.userAcceleration
                    self.motionData.rotationRate = data.rotationRate
                    self.motionData.magneticField = data.magneticField
                    self.motionData.attitude = data.attitude
                }
            }
        }
    }

    func stopUpdating() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
}

struct MotionView: View {
    @ObservedObject var motionManager = MotionManager()

    var body: some View {
        VStack {
            Text("Acceleration: X: \(motionManager.motionData.acceleration.x), Y: \(motionManager.motionData.acceleration.y), Z: \(motionManager.motionData.acceleration.z)")
            Text("Rotation Rate: X: \(motionManager.motionData.rotationRate.x), Y: \(motionManager.motionData.rotationRate.y), Z: \(motionManager.motionData.rotationRate.z)")
            Text("Magnetic Field: X: \(motionManager.motionData.magneticField.field.x), Y: \(motionManager.motionData.magneticField.field.y), Z: \(motionManager.motionData.magneticField.field.z)")
            Text("Attitude: Roll: \(motionManager.motionData.attitude.roll), Pitch: \(motionManager.motionData.attitude.pitch), Yaw: \(motionManager.motionData.attitude.yaw)")
        }
        .onAppear {
            // Try sampling every 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.motionManager.stopUpdating()
            }
        }
        .onDisappear {
            // Resume sampling every 10 times per second when the view disappears
            self.motionManager.startUpdating()
        }
    }
}

#Preview {
    MotionView()
}
