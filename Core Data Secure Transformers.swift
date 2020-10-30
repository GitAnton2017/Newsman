//
//  Core Data Secure Transformers.swift
//  Newsman
//
//  Created by Anton2016 on 11.03.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation

// 1. Subclass from `NSSecureUnarchiveFromDataTransformer`
final class NSValueDataSecureTransformer: NSSecureUnarchiveFromDataTransformer {

    /// The name of the transformer. This is the name used to register the transformer using ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: NSValueDataSecureTransformer.self))

    // 2. Make sure `UIColor` is in the allowed class list.
    override static var allowedTopLevelClasses: [AnyClass] { [NSValue.self] }

    /// Registers the transformer.
    public static func register()
    {
        let transformer = NSValueDataSecureTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
