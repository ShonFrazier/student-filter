import Foundation

public enum LineEndingConversion {
    case dos2unix
    case dos2mac
    case mac2dos
    case mac2unix
    case unix2dos
    case unix2mac
}

extension Data {
    var CR: Data { "\r".data(using: .utf8)! }
    var LF: Data { "\n".data(using: .utf8)! }
    var CRLF: Data { "\r\n".data(using: .utf8)! }

    public func convertingLineEndings(with: LineEndingConversion) -> Data {
        let dos_le = CRLF
        let mac_le = CR
        let unix_le = LF

        let (from, to) = { () -> (Data, Data) in
            switch with {
                case .dos2unix: return (dos_le, unix_le)
                case .dos2mac:  return (dos_le, mac_le)
                case .mac2dos:  return (mac_le, dos_le)
                case .mac2unix: return (mac_le, unix_le)
                case .unix2dos: return (unix_le, dos_le)
                case .unix2mac: return (unix_le, mac_le)
            }
        }()

        var newData = self
        while let range = newData.lastRange(of: from) {
            newData.replaceSubrange(range, with: to)
        }

        return newData
    }

    static func == (lhs: Data, rhs: Data) -> Bool {
        if lhs.count != rhs.count {
            return false
        }

        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                return false
            }
        }

        return true
    }
}
