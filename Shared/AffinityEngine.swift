import Foundation

struct AffinityEngine: Sendable {
    
    struct SpaceAffinityResult: Sendable, Identifiable {
        var id: UUID { spaceId }
        let spaceId: UUID
        let score: Double
        let matchedTags: [String]
    }
    
    func resolve(graph: RuntimeContextGraph, spaces: [Space], contributions: [Contribution]) -> [SpaceAffinityResult] {
        var spaceScores: [UUID: Double] = [:]
        var spaceMatchedTags: [UUID: [String]] = [:]
        
        // 1. Calculate scores for each Tag based on Contributions
        var tagScores: [String: Double] = [:]
        for contribution in contributions {
            let isMatched = contribution.requiredContextIds.allSatisfy { graph.has(id: $0) }
            if isMatched {
                tagScores[contribution.targetCapability] = (tagScores[contribution.targetCapability] ?? 0.0) + contribution.weight
            }
        }
        
        // 2. Aggregate tag scores into Spaces
        for space in spaces {
            var totalScore: Double = 0.0
            var matched: [String] = []
            
            for tag in space.tags {
                if let score = tagScores[tag] {
                    totalScore += score
                    matched.append(tag)
                }
            }
            
            spaceScores[space.id] = totalScore
            spaceMatchedTags[space.id] = matched
        }
        
        return spaces.map { space in
            SpaceAffinityResult(
                spaceId: space.id,
                score: spaceScores[space.id] ?? 0.0,
                matchedTags: spaceMatchedTags[space.id] ?? []
            )
        }.sorted { $0.score > $1.score }
    }
}
