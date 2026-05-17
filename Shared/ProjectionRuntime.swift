import Foundation

struct ProjectionSection: Identifiable, Sendable {
    let id: String
    let title: String
    let spaceAffinities: [AffinityEngine.SpaceAffinityResult]
    let type: SectionType
    
    enum SectionType: Sendable {
        case anchor
        case fluid
    }
}

struct ProjectionRuntime: Sendable {
    
    func project(affinities: [AffinityEngine.SpaceAffinityResult]) -> [ProjectionSection] {
        guard !affinities.isEmpty else { return [] }
        
        // NOW Section: Top Space
        let nowSection = ProjectionSection(
            id: "anchor.now",
            title: "NOW",
            spaceAffinities: [affinities[0]],
            type: .anchor
        )
        
        // DISCOVER Section: Rest of the Spaces
        let discoverSection = ProjectionSection(
            id: "fluid.discover",
            title: "DISCOVER",
            spaceAffinities: Array(affinities.dropFirst()),
            type: .fluid
        )
        
        var sections = [nowSection]
        if affinities.count > 1 {
            sections.append(discoverSection)
        }
        
        return sections
    }
}
