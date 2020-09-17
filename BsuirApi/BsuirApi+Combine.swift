//
//  BsuirApi+Combine.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 8/6/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import Foundation
import Combine

extension RequestsManager {

    public func dataRequest<T: Target>(for target: T) -> AnyPublisher<(Data, URLResponse), DataRequestError> {
        Deferred { Future { handler in
            self.dataRequest(for: target, completion: handler)
        } }.eraseToAnyPublisher()
    }

    public func request<T: Target>(_ target: T) -> AnyPublisher<T.Value, RequestError> {
        Deferred { Future { handler in
            self.request(target, completion: handler)
        } }.eraseToAnyPublisher()
    }
}
