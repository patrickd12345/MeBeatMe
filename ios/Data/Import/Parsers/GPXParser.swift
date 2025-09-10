import Foundation
import os

/// Parser for GPX (GPS Exchange Format) files
class GPXParser {
    private let logger = Logger(subsystem: "com.mebeatme.ios", category: "GPXParser")
    
    /// Parses GPX data into a RunRecord
    /// - Parameters:
    ///   - data: GPX file data
    ///   - fileName: Original filename
    /// - Returns: Parsed RunRecord
    func parse(data: Data, fileName: String) async throws -> RunRecord {
        logger.info("Parsing GPX file: \(fileName)")
        
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw AppError.invalidFileFormat("Unable to decode GPX file as UTF-8")
        }
        
        // Parse XML using a simple approach (in production, use XMLParser)
        let trackPoints = try extractTrackPoints(from: xmlString)
        
        guard !trackPoints.isEmpty else {
            throw AppError.noTrackData("No track points found in GPX file")
        }
        
        // Calculate run metrics
        let distance = calculateDistance(from: trackPoints)
        let duration = calculateDuration(from: trackPoints)
        let averagePace = duration > 0 ? Double(duration) / (distance / 1000.0) : 0
        let splits = calculateSplits(from: trackPoints)
        let heartRateData = extractHeartRateData(from: xmlString, trackPoints: trackPoints)
        let elevationGain = calculateElevationGain(from: trackPoints)
        
        let runRecord = RunRecord(
            distance: distance,
            duration: duration,
            averagePace: averagePace,
            splits: splits,
            source: "gpx",
            fileName: fileName,
            heartRateData: heartRateData,
            elevationGain: elevationGain
        )
        
        logger.info("Successfully parsed GPX: \(String(format: "%.2f", distance/1000))km in \(Units.formatTime(duration))")
        
        return runRecord
    }
    
    /// Extracts track points from GPX XML
    private func extractTrackPoints(from xmlString: String) throws -> [TrackPoint] {
        var trackPoints: [TrackPoint] = []
        
        // Simple regex-based parsing (in production, use proper XML parser)
        let trackPointPattern = #"<trkpt[^>]*lat="([^"]*)"[^>]*lon="([^"]*)"[^>]*>.*?<time>([^<]*)</time>"#
        let regex = try NSRegularExpression(pattern: trackPointPattern, options: [.dotMatchesLineSeparators])
        let matches = regex.matches(in: xmlString, range: NSRange(xmlString.startIndex..., in: xmlString))
        
        for match in matches {
            guard match.numberOfRanges == 4 else { continue }
            
            let latRange = Range(match.range(at: 1), in: xmlString)!
            let lonRange = Range(match.range(at: 2), in: xmlString)!
            let timeRange = Range(match.range(at: 3), in: xmlString)!
            
            let latString = String(xmlString[latRange])
            let lonString = String(xmlString[lonRange])
            let timeString = String(xmlString[timeRange])
            
            guard let lat = Double(latString),
                  let lon = Double(lonString),
                  let timestamp = parseTimestamp(timeString) else {
                continue
            }
            
            trackPoints.append(TrackPoint(latitude: lat, longitude: lon, timestamp: timestamp))
        }
        
        return trackPoints.sorted { $0.timestamp < $1.timestamp }
    }
    
    /// Parses ISO 8601 timestamp
    private func parseTimestamp(_ timeString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: timeString)
    }
    
    /// Calculates total distance from track points
    private func calculateDistance(from trackPoints: [TrackPoint]) -> Double {
        guard trackPoints.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        
        for i in 1..<trackPoints.count {
            let distance = calculateDistanceBetween(
                trackPoints[i-1],
                trackPoints[i]
            )
            totalDistance += distance
        }
        
        return totalDistance
    }
    
    /// Calculates distance between two track points using Haversine formula
    private func calculateDistanceBetween(_ point1: TrackPoint, _ point2: TrackPoint) -> Double {
        let earthRadius: Double = 6371000 // meters
        
        let lat1Rad = point1.latitude * .pi / 180
        let lat2Rad = point2.latitude * .pi / 180
        let deltaLatRad = (point2.latitude - point1.latitude) * .pi / 180
        let deltaLonRad = (point2.longitude - point1.longitude) * .pi / 180
        
        let a = sin(deltaLatRad/2) * sin(deltaLatRad/2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLonRad/2) * sin(deltaLonRad/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return earthRadius * c
    }
    
    /// Calculates total duration from track points
    private func calculateDuration(from trackPoints: [TrackPoint]) -> Int {
        guard trackPoints.count > 1 else { return 0 }
        
        let startTime = trackPoints.first!.timestamp
        let endTime = trackPoints.last!.timestamp
        
        return Int(endTime.timeIntervalSince(startTime))
    }
    
    /// Calculates splits (every kilometer)
    private func calculateSplits(from trackPoints: [TrackPoint]) -> [Split] {
        guard trackPoints.count > 1 else { return [] }
        
        var splits: [Split] = []
        var currentSplitDistance: Double = 0
        var splitStartIndex = 0
        
        for i in 1..<trackPoints.count {
            let segmentDistance = calculateDistanceBetween(trackPoints[i-1], trackPoints[i])
            currentSplitDistance += segmentDistance
            
            // Create split every 1000 meters
            if currentSplitDistance >= 1000 {
                let splitDuration = Int(trackPoints[i].timestamp.timeIntervalSince(trackPoints[splitStartIndex].timestamp))
                let splitPace = splitDuration > 0 ? Double(splitDuration) / (currentSplitDistance / 1000.0) : 0
                
                splits.append(Split(
                    distance: currentSplitDistance,
                    duration: splitDuration,
                    pace: splitPace
                ))
                
                currentSplitDistance = 0
                splitStartIndex = i
            }
        }
        
        return splits
    }
    
    /// Extracts heart rate data from GPX XML
    private func extractHeartRateData(from xmlString: String, trackPoints: [TrackPoint]) -> [HeartRatePoint] {
        // TODO: Implement heart rate extraction from GPX extensions
        // This would parse <extensions><ns3:TrackPointExtension><ns3:hr>...</ns3:hr></ns3:TrackPointExtension></extensions>
        return []
    }
    
    /// Calculates elevation gain from track points
    private func calculateElevationGain(from trackPoints: [TrackPoint]) -> Double {
        // TODO: Implement elevation extraction from GPX <ele> tags
        // For now, return 0
        return 0
    }
}

/// Represents a track point with GPS coordinates and timestamp
private struct TrackPoint {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
}
