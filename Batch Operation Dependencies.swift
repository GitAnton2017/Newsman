//
//  Batch Operation Dependencies.swift
//  Newsman
//
//  Created by Anton2016 on 03.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation

extension AppCloudData
{
 final func batchOperationsDependencies(for batchOperation: BatchCloudOperation) -> [BatchCloudOperation]
 {
  batchOperationBuffer
   .compactMap{ $0 as? ModifyBatchCloudOperation }
   .filter{ $0.isJoint(with: batchOperation) }
 }
 
}
