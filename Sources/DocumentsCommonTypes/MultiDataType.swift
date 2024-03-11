import Foundation

public enum MultiDataType<T> {
    case single(T)
    case multiple([T])
    
    public var count: Int {
        switch self {
        case .single:
            return 1
        case .multiple(let values):
            return values.count
        }
    }

    public func getValues() -> [T] {
        switch self {
        case .single(let value):
            return [value]
        case .multiple(let values):
            return values
        }
    }
    
    public func getValue() -> T {
        switch self {
        case .single(let value):
            return value
        case .multiple(let values):
            guard !values.isEmpty else {
                fatalError("Impossible case. Multiple case with empty array. Check this before creating")
            }
            return values[0]
        }
    }
}
