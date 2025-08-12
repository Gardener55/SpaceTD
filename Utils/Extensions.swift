//
//  Extensions.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let deltaX = x - point.x
        let deltaY = y - point.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
}
