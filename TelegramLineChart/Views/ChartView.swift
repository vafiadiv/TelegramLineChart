//
//  ChartView.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit

internal class ChartView: UIView {

	var debug = false

	var border = CGSize(width: 10, height: 10) {
		didSet {
			(self.layer as? ChartLayer)?.border = border
		}
	}

	///Data points of the chart in measurement units; assuming that are sorted in ascending order by X coordinate
	var dataLine: DataLine? {
		didSet {
//			(self.layer as? ChartLayer)?.dataLine = dataLine
			self.setNeedsDisplay()
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.bounds = self.bounds
	}

/*
	override class var layerClass: AnyClass {
		return ChartLayer.self
	}
*/

	override func draw(_ rect: CGRect) {
		super.draw(rect)
		guard let dataLine = dataLine, !dataLine.points.isEmpty else {
			return
		}

        
        let drawingRect = rect.insetBy(dx: border.width, dy: border.height)
        type(of: self).drawDataLinePoints(dataLine.points,
                                          drawingRect: drawingRect,
                                          color: dataLine.color,
                                          context: UIGraphicsGetCurrentContext(),
                                          debugPrint: true)
		
	}
    
    private static func drawDataLinePoints(_ points: [DataPoint],
                                           drawingRect: CGRect,
                                           color: UIColor,
                                           context: CGContext?,
                                           debugPrint: Bool = false) {
        guard let context = context else {
            return
        }

        context.saveGState()
        context.translateBy(x: drawingRect.origin.x, y: drawingRect.origin.y)
        
        //dimensions in chart measurement units
        let minUnitX = points[0].x
        let maxUnitX = points.last!.x
        
        var minUnitY = 0
        var maxUnitY = 0
        points.forEach { point in
            if point.y < minUnitY {
                minUnitY = point.y
            }
            
            if point.y > maxUnitY {
                maxUnitY = point.y
            }
        }
        
        let pointsPerUnitX = self.pointsPerUnit(drawingDistance: drawingRect.width, unitMin: minUnitX, unitMax: maxUnitX)
        let pointsPerUnitY = self.pointsPerUnit(drawingDistance: drawingRect.height, unitMin: minUnitY, unitMax: maxUnitY)
        
        let path = UIBezierPath()
        path.lineWidth = 3.0
        context.setStrokeColor(color.cgColor)
        
        for i in 0..<points.count {
            let point = points[i]
            let unitRelativeX = CGFloat(point.x - minUnitX)
            let unitRelativeY = CGFloat(point.y - minUnitY)
            
            let screenPoint = CGPoint(
                x: unitRelativeX * pointsPerUnitX,
                y: drawingRect.height - (unitRelativeY * pointsPerUnitY))
            
            if i == 0 {
                path.move(to: screenPoint)
            } else {
                path.addLine(to: screenPoint)
            }
            
            if debugPrint {
//                self.drawCoordinates(x: point.x, y: point.y, at: screenPoint)
                let borderRectPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: drawingRect.width, height: drawingRect.height))
                borderRectPath.stroke()
            }
        }
        
        path.stroke()

        context.restoreGState()
    }

	private static func drawCoordinates(x: Int, y: Int, at point: CGPoint/*, in context: CGContext*/) {
		let string = "x: \(x), y: \(y)"
		NSString(string: string).draw(at: point, withAttributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
	}

	///Returns on-screen Core Graphics points per 1 of chart measurement units
	private static func pointsPerUnit(drawingDistance: CGFloat, unitMin: Int, unitMax: Int) -> CGFloat {
		return drawingDistance / CGFloat(unitMax - unitMin)
	}

}
