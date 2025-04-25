//
//  Created by yugo.sugiyama on 2025/04/19
//  Copyright ©Sugiy All rights reserved.
//

import Foundation

public struct TableData: Identifiable {
    public var id: String {
        return leading + trailing
    }

    public let leading: String
    public let trailing: String

    public init(leading: String, trailing: String) {
        self.leading = leading
        self.trailing = trailing
    }
}

public struct TableTripleData: Identifiable {
    public var id: String {
        return leading + center + trailing
    }

    public let leading: String
    public let center: String
    public let trailing: String

    public init(leading: String, center: String, trailing: String) {
        self.leading = leading
        self.center = center
        self.trailing = trailing
    }
}
