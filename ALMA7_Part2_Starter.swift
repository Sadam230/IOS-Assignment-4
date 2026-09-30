// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck:", deck.rawValue, "Priority:", deck.evacuationPriority)
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let rawLevel = min(mass / 500, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: rawLevel) ?? .red
    }
}

print("Alarm test 1:", AlarmLevel.level(forTotalMass: 0))
print("Alarm test 2:", AlarmLevel.level(forTotalMass: 940))


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

let manifestTest1 = ManifestEntry.crate(id: 101, massKg: 120)
let manifestTest2 = ManifestEntry.unknown(raw: "corrupted")

print("Manifest test 1:", manifestTest1)
print("Manifest test 2:", manifestTest2)

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)

    if parts.count == 3 && parts[0] == "crate" {
        if let id = Int(parts[1]), let mass = Int(parts[2]) {
            return .crate(id: id, massKg: mass)
        }
    }

    if parts.count == 3 && parts[0] == "container" {
        if let mass = Int(parts[2]) {
            return .container(code: parts[1], massKg: mass)
        }
    }

    if parts.count == 4 && parts[0] == "livestock" {
        if let count = Int(parts[2]),
           let massPerUnit = Int(parts[3]) {
            return .livestock(
                species: parts[1],
                count: count,
                massPerUnitKg: massPerUnit
            )
        }
    }

    return .unknown(raw: line)
}

print("Parse test 1:", parseEntry("crate:101:120"))
print("Parse test 2:", parseEntry("wrong:data"))
// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg

    case .container(_, let massKg):
        return massKg

    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg

    case .unknown:
        return 0
    }
}
var A = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    A += mass(of: entry)

    if case .unknown = entry {
        unknownCount += 1
    }
}

print("Total mass:", A)
print("Unknown lines:", unknownCount)


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var crewTest = CrewSnapshot.rookie(named: "Test")
print("Crew test 1:", crewTest.name, crewTest.deck.rawValue, crewTest.oxygen)

crewTest.breathe(30)
print("Crew test 2:", crewTest.name, crewTest.deck.rawValue, crewTest.oxygen)
// 3.2
var crewRoster: [CrewSnapshot] = []

for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        let member = CrewSnapshot(
            name: record.name,
            deck: deck,
            oxygen: record.oxygen
        )
        crewRoster.append(member)
    } else {
        print("Warning: unknown deck for \(record.name): \(record.deck)")
    }
}

print("Roster count:", crewRoster.count)

for member in crewRoster {
    print("Crew:", member.name, member.deck.rawValue, member.oxygen)
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)

// 1. Copy: changing the copy does not change the original
var original = CrewSnapshot.rookie(named: "Dana")
var copy = original

print("Copy test before:", original.oxygen, copy.oxygen)
copy.breathe(20)
print("Copy test after:", original.oxygen, copy.oxygen)


// 2. Plain parameter: changing the parameter does not change the original
func changeOxygen(_ member: CrewSnapshot) {
    var changedMember = member
    changedMember.breathe(30)
    print("Plain function inside:", changedMember.oxygen)
}

print("Plain function before:", original.oxygen)
changeOxygen(original)
print("Plain function after:", original.oxygen)


// 3. inout: changing the parameter changes the original
func changeOxygenInout(_ member: inout CrewSnapshot) {
    member.breathe(30)
}

print("Inout before:", original.oxygen)
changeOxygenInout(&original)
print("Inout after:", original.oxygen)

// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 {
            return false
        }

        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        if let crew = occupant {
            chargeLevel -= 20
            occupant = nil
            return crew
        }

        return nil
    }
    
    deinit {
        print("TeleportPod \(id) deinitialized")
    }
}

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
let missionPod = TeleportPod(id: "P-1", chargeLevel: 100)

for member in crewRoster {
    if member.name == "Timur" {
        print("Load Timur:", missionPod.load(member))
        _ = missionPod.fire()
        print("Charge after Timur:", missionPod.chargeLevel)
    }
}

for member in crewRoster {
    if member.name == "Dana" {
        print("Load Dana:", missionPod.load(member))
        _ = missionPod.fire()
        print("Charge after Dana:", missionPod.chargeLevel)
    }
}

for member in crewRoster {
    if member.name == "Nurlan" {
        print("Load Nurlan:", missionPod.load(member))
        _ = missionPod.fire()
        print("Charge after Nurlan:", missionPod.chargeLevel)
    }
}

_ = missionPod.fire()
print("Charge after empty fire:", missionPod.chargeLevel)

let C = missionPod.chargeLevel
print("C =", C)
// 4.3 · Reference-semantics demonstration
// Class: both variables refer to the same object
let podReference = missionPod

print("Pod reference before:", missionPod.chargeLevel, podReference.chargeLevel)
podReference.chargeLevel = 25
print("Pod reference after:", missionPod.chargeLevel, podReference.chargeLevel)


// Struct: the second variable gets its own copy
var crewOriginal = CrewSnapshot.rookie(named: "Reference Test")
var crewCopy = crewOriginal

print("Crew value before:", crewOriginal.oxygen, crewCopy.oxygen)
crewCopy.breathe(20)
print("Crew value after:", crewOriginal.oxygen, crewCopy.oxygen)

// Rule: classes have reference semantics; structs have value semantics.

// MARK: Level 5 · Station Systems

// 5.1
// final class Station { }

final class Station {
    let callSign: String

    var hullIntegrity: Int {
        willSet {
            print("Hull integrity: \(hullIntegrity) -> \(newValue)")
        }

        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    var oxygenByDeck: [Deck: Int]

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Station \(callSign): hull \(hullIntegrity), total oxygen \(totalOxygen)"
    }()

    var totalOxygen: Int {
        var total = 0

        for oxygen in oxygenByDeck.values {
            total += oxygen
        }

        return total
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty {
                return 0
            }

            return totalOxygen / oxygenByDeck.count
        }

        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        self.oxygenByDeck = [:]

        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                self.oxygenByDeck[deck] = reading.oxygen
            }
        }
    }
}
let station = Station(callSign: "ALMA-7", hullIntegrity: 100)

let B = station.averageOxygen

print("Station total oxygen:", station.totalOxygen)
print("Station starting average oxygen:", B)

print("Before first diagnostics access")
print(station.fullDiagnostics)
print("Second diagnostics access")
print(station.fullDiagnostics)

// 5.2 · The clamp trap: 130, then -40, then 55
station.hullIntegrity = 130
print("Hull after 130:", station.hullIntegrity)

station.hullIntegrity = -40
print("Hull after -40:", station.hullIntegrity)

station.hullIntegrity = 55
print("Hull after 55:", station.hullIntegrity)

// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/
/*
Report 1
Expectation: oxygen in roster should decrease.
Actual: roster does not change.
Rule: CrewSnapshot is a struct, so each loop variable is a copy.
Fix: modify roster by index or use inout.

Report 2
Expectation: changing podB should not change podA.
Actual: podA.chargeLevel also becomes 0.
Rule: TeleportPod is a class, so podA and podB refer to the same object.
Fix: create a separate TeleportPod object.

Report 3
Expectation: add() should append a new entry.
Actual: the code does not compile.
Rule: a struct method that changes a stored property must be marked mutating.
Fix: write mutating func add(_ entry: String).

Report 4
Expectation: both let values should prevent property changes.
Actual: snapshot.oxygen = 40 does not compile, but pod.chargeLevel = 10 does compile.
Rule: let freezes the whole value of a struct, but for a class it freezes only the reference.
Fix: use var snapshot if its properties need to change.
*/

// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

final class FlightRecorder {
    // private: entries can only be accessed inside FlightRecorder.
    private var entries: [String] = []

    // private(set): readable outside, but writable only inside FlightRecorder.
    private(set) var isSealed = false

    func record(_ entry: String) {
        if !isSealed {
            entries.append(entry)
        }
    }

    func seal() {
        isSealed = true
    }

    // fileprivate: accessible elsewhere in this same Swift file.
    fileprivate func transcript() -> String {
        return entries.joined(separator: " | ")
    }
}

// A free function elsewhere in the file that uses your fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    return recorder.transcript()
}
let recorder = FlightRecorder()

recorder.record("ALMA-7 online")
recorder.record("Teleport incident detected")

print("Recorder sealed:", recorder.isSealed)

recorder.seal()

print("Recorder sealed:", recorder.isSealed)
print("Audit:", auditTranscript(of: recorder))


// MARK: Finale · Integrity Code

var D = 0

for reading in deckReadings {
    if reading.oxygen < 60 {
        if let deck = Deck(rawValue: reading.deck) {
            D += deck.evacuationPriority
        }
    }
}

let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")

// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity
do {
    let temporaryPod = TeleportPod(id: "TEMP", chargeLevel: 50)
    print("Temporary pod created:", temporaryPod.id)
}

let identityPod = TeleportPod(id: "IDENTITY", chargeLevel: 50)
let sameIdentityPod = identityPod

print("Same pod identity:", identityPod === sameIdentityPod)

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?

 2. What does `mutating` do to self, and why do classes never need it?

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?

*/
